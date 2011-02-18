From: David Miller <davem@davemloft.net>
Subject: [v2 PATCH 1/2] ipv4: Add hash table of interface addresses.
Date: Fri, 18 Feb 2011 14:49:37 -0800 (PST)
Message-ID: <20110218.144937.246522051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55805
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750891Ab1BRWtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 17:49:01 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B661F24C087
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 14:49:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will be used to optimize __ip_dev_find() and friends.

With help from Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/inetdevice.h |    1 +
 net/ipv4/devinet.c         |   45 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ae8fdc5..5f81466 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -144,6 +144,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
 
 struct in_ifaddr {
+	struct hlist_node	hash;
 	struct in_ifaddr	*ifa_next;
 	struct in_device	*ifa_dev;
 	struct rcu_head		rcu_head;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 748cb5b..2fe5076 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -51,6 +51,7 @@
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/slab.h>
+#include <linux/hash.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -92,6 +93,38 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 };
 
+/* inet_addr_hash's shifting is dependent upon this IN4_ADDR_HSIZE
+ * value.  So if you change this define, make appropriate changes to
+ * inet_addr_hash as well.
+ */
+#define IN4_ADDR_HSIZE	256
+static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
+static DEFINE_SPINLOCK(inet_addr_hash_lock);
+
+static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
+{
+	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
+
+	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
+		(IN4_ADDR_HSIZE - 1));
+}
+
+static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
+{
+	unsigned int hash = inet_addr_hash(net, ifa->ifa_address);
+
+	spin_lock(&inet_addr_hash_lock);
+	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
+	spin_unlock(&inet_addr_hash_lock);
+}
+
+static void inet_hash_remove(struct in_ifaddr *ifa)
+{
+	spin_lock(&inet_addr_hash_lock);
+	hlist_del_init_rcu(&ifa->hash);
+	spin_unlock(&inet_addr_hash_lock);
+}
+
 static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
@@ -265,6 +298,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			}
 
 			if (!do_promote) {
+				inet_hash_remove(ifa);
 				*ifap1 = ifa->ifa_next;
 
 				rtmsg_ifa(RTM_DELADDR, ifa, nlh, pid);
@@ -281,6 +315,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 	/* 2. Unlink it */
 
 	*ifap = ifa1->ifa_next;
+	inet_hash_remove(ifa1);
 
 	/* 3. Announce address deletion */
 
@@ -368,6 +403,8 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	ifa->ifa_next = *ifap;
 	*ifap = ifa;
 
+	inet_hash_insert(dev_net(in_dev->dev), ifa);
+
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
 	   listeners of netlink will know about new ifaddr */
@@ -521,6 +558,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh)
 	if (tb[IFA_ADDRESS] == NULL)
 		tb[IFA_ADDRESS] = tb[IFA_LOCAL];
 
+	INIT_HLIST_NODE(&ifa->hash);
 	ifa->ifa_prefixlen = ifm->ifa_prefixlen;
 	ifa->ifa_mask = inet_make_mask(ifm->ifa_prefixlen);
 	ifa->ifa_flags = ifm->ifa_flags;
@@ -728,6 +766,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		if (!ifa) {
 			ret = -ENOBUFS;
 			ifa = inet_alloc_ifa();
+			INIT_HLIST_NODE(&ifa->hash);
 			if (!ifa)
 				break;
 			if (colon)
@@ -1069,6 +1108,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			struct in_ifaddr *ifa = inet_alloc_ifa();
 
 			if (ifa) {
+				INIT_HLIST_NODE(&ifa->hash);
 				ifa->ifa_local =
 				  ifa->ifa_address = htonl(INADDR_LOOPBACK);
 				ifa->ifa_prefixlen = 8;
@@ -1710,6 +1750,11 @@ static struct rtnl_af_ops inet_af_ops = {
 
 void __init devinet_init(void)
 {
+	int i;
+
+	for (i = 0; i < IN4_ADDR_HSIZE; i++)
+		INIT_HLIST_HEAD(&inet_addr_lst[i]);
+
 	register_pernet_subsys(&devinet_ops);
 
 	register_gifconf(PF_INET, inet_gifconf);
-- 
1.7.4.1

