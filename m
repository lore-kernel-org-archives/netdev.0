From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: change inet_addr_hash()
Date: Sat, 04 Aug 2012 09:06:50 +0200
Message-ID: <1344064010.9299.1468.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42972 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab2HDHGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 03:06:55 -0400
Received: by wibhm11 with SMTP id hm11so185897wib.1
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 00:06:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use net_hash_mix(net) instead of hash_ptr(net, 8), and use
hash_32() instead of using a serie of XOR

Define IN4_ADDR_HSIZE_SHIFT for clarity

__ip_dev_find() can perform the net_eq() call only if ifa_local
matches the key, to avoid unneeded dereferences.

remove inline attributes

# size net/ipv4/devinet.o.before net/ipv4/devinet.o
   text	   data	    bss	    dec	    hex	filename
  17471	   2545	   2048	  22064	   5630	net/ipv4/devinet.o.before
  17335	   2545	   2048	  21928	   55a8	net/ipv4/devinet.o

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/devinet.c |   39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 44bf82e..adf273f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -94,25 +94,22 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 };
 
-/* inet_addr_hash's shifting is dependent upon this IN4_ADDR_HSIZE
- * value.  So if you change this define, make appropriate changes to
- * inet_addr_hash as well.
- */
-#define IN4_ADDR_HSIZE	256
+#define IN4_ADDR_HSIZE_SHIFT	8
+#define IN4_ADDR_HSIZE		(1U << IN4_ADDR_HSIZE_SHIFT)
+
 static struct hlist_head inet_addr_lst[IN4_ADDR_HSIZE];
 static DEFINE_SPINLOCK(inet_addr_hash_lock);
 
-static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
+static u32 inet_addr_hash(struct net *net, __be32 addr)
 {
-	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
+	u32 val = (__force u32) addr ^ net_hash_mix(net);
 
-	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
-		(IN4_ADDR_HSIZE - 1));
+	return hash_32(val, IN4_ADDR_HSIZE_SHIFT);
 }
 
 static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
 {
-	unsigned int hash = inet_addr_hash(net, ifa->ifa_local);
+	u32 hash = inet_addr_hash(net, ifa->ifa_local);
 
 	spin_lock(&inet_addr_hash_lock);
 	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
@@ -136,18 +133,18 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
  */
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
-	unsigned int hash = inet_addr_hash(net, addr);
+	u32 hash = inet_addr_hash(net, addr);
 	struct net_device *result = NULL;
 	struct in_ifaddr *ifa;
 	struct hlist_node *node;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(ifa, node, &inet_addr_lst[hash], hash) {
-		struct net_device *dev = ifa->ifa_dev->dev;
-
-		if (!net_eq(dev_net(dev), net))
-			continue;
 		if (ifa->ifa_local == addr) {
+			struct net_device *dev = ifa->ifa_dev->dev;
+
+			if (!net_eq(dev_net(dev), net))
+				continue;
 			result = dev;
 			break;
 		}
@@ -182,10 +179,10 @@ static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 static void devinet_sysctl_register(struct in_device *idev);
 static void devinet_sysctl_unregister(struct in_device *idev);
 #else
-static inline void devinet_sysctl_register(struct in_device *idev)
+static void devinet_sysctl_register(struct in_device *idev)
 {
 }
-static inline void devinet_sysctl_unregister(struct in_device *idev)
+static void devinet_sysctl_unregister(struct in_device *idev)
 {
 }
 #endif
@@ -205,7 +202,7 @@ static void inet_rcu_free_ifa(struct rcu_head *head)
 	kfree(ifa);
 }
 
-static inline void inet_free_ifa(struct in_ifaddr *ifa)
+static void inet_free_ifa(struct in_ifaddr *ifa)
 {
 	call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 }
@@ -659,7 +656,7 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
  *	Determine a default network mask, based on the IP address.
  */
 
-static inline int inet_abc_len(__be32 addr)
+static int inet_abc_len(__be32 addr)
 {
 	int rc = -1;	/* Something else, probably a multicast. */
 
@@ -1124,7 +1121,7 @@ skip:
 	}
 }
 
-static inline bool inetdev_valid_mtu(unsigned int mtu)
+static bool inetdev_valid_mtu(unsigned int mtu)
 {
 	return mtu >= 68;
 }
@@ -1239,7 +1236,7 @@ static struct notifier_block ip_netdev_notifier = {
 	.notifier_call = inetdev_event,
 };
 
-static inline size_t inet_nlmsg_size(void)
+static size_t inet_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
 	       + nla_total_size(4) /* IFA_ADDRESS */
