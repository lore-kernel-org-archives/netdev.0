From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] RFC3484 Configurable Policy Table.
Date: Wed, 14 Nov 2007 16:37:28 +0900 (JST)
Message-ID: <20071114.163728.134148765.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33127 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbXKNHhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 02:37:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Please consider pulling from
	inet6-2.6.25
branch at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
which contains the following commits on top of your net-2.6.25 tree.

Regards,

--

HEADLINES
---------

    [IPV6] ADDRCONF: Rename ipv6_saddr_label() to ipv6_addr_label().
    [IPV6] ADDRCONF: Allow address selection policy with ifindex.
    [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.

DIFFSTAT
--------

 include/linux/if_addrlabel.h |   32 ++
 include/linux/rtnetlink.h    |    7 +
 include/net/addrconf.h       |    8 +
 net/ipv6/Makefile            |    1 
 net/ipv6/addrconf.c          |   50 +---
 net/ipv6/addrlabel.c         |  551 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 616 insertions(+), 33 deletions(-)

CHANGESETS
----------

commit d4e85a45763d572e39f3c040253a4d7b45ca67aa
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Nov 14 15:55:29 2007 +0900

    [IPV6] ADDRCONF: Rename ipv6_saddr_label() to ipv6_addr_label().
    
    This patch renames ipv6_saddr_label() to ipv6_addr_label() because
    address label is used for both of source address and destination
    address.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f825b92..a30f4e3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -875,7 +875,7 @@ static inline int ipv6_saddr_preferred(int type)
 }
 
 /* static matching label */
-static inline int ipv6_saddr_label(const struct in6_addr *addr, int type)
+static inline int ipv6_addr_label(const struct in6_addr *addr, int type)
 {
  /*
   * 	prefix (longest match)	label
@@ -910,7 +910,7 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 	struct inet6_ifaddr *ifa_result = NULL;
 	int daddr_type = __ipv6_addr_type(daddr);
 	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
-	u32 daddr_label = ipv6_saddr_label(daddr, daddr_type);
+	u32 daddr_label = ipv6_addr_label(daddr, daddr_type);
 	struct net_device *dev;
 
 	memset(&hiscore, 0, sizeof(hiscore));
@@ -1083,11 +1083,13 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 
 			/* Rule 6: Prefer matching label */
 			if (hiscore.rule < 6) {
-				if (ipv6_saddr_label(&ifa_result->addr, hiscore.addr_type) == daddr_label)
+				if (ipv6_addr_label(&ifa_result->addr,
+						    hiscore.addr_type) == daddr_label)
 					hiscore.attrs |= IPV6_SADDR_SCORE_LABEL;
 				hiscore.rule++;
 			}
-			if (ipv6_saddr_label(&ifa->addr, score.addr_type) == daddr_label) {
+			if (ipv6_addr_label(&ifa->addr,
+					    score.addr_type) == daddr_label) {
 				score.attrs |= IPV6_SADDR_SCORE_LABEL;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LABEL)) {
 					score.rule = 6;

---
commit 010ae4d3b1209c724050f10e1832fd8a54d40ef2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Nov 14 15:56:15 2007 +0900

    [IPV6] ADDRCONF: Allow address selection policy with ifindex.
    
    Think patch allows ifindex to be a key for address selection policy table.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a30f4e3..0076010 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -875,7 +875,8 @@ static inline int ipv6_saddr_preferred(int type)
 }
 
 /* static matching label */
-static inline int ipv6_addr_label(const struct in6_addr *addr, int type)
+static inline int ipv6_addr_label(const struct in6_addr *addr, int type,
+				  int ifindex)
 {
  /*
   * 	prefix (longest match)	label
@@ -910,7 +911,8 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 	struct inet6_ifaddr *ifa_result = NULL;
 	int daddr_type = __ipv6_addr_type(daddr);
 	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
-	u32 daddr_label = ipv6_addr_label(daddr, daddr_type);
+	int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;
+	u32 daddr_label = ipv6_addr_label(daddr, daddr_type, daddr_ifindex);
 	struct net_device *dev;
 
 	memset(&hiscore, 0, sizeof(hiscore));
@@ -1084,12 +1086,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			/* Rule 6: Prefer matching label */
 			if (hiscore.rule < 6) {
 				if (ipv6_addr_label(&ifa_result->addr,
-						    hiscore.addr_type) == daddr_label)
+						    hiscore.addr_type,
+						    ifa_result->idev->dev->ifindex) == daddr_label)
 					hiscore.attrs |= IPV6_SADDR_SCORE_LABEL;
 				hiscore.rule++;
 			}
 			if (ipv6_addr_label(&ifa->addr,
-					    score.addr_type) == daddr_label) {
+					    score.addr_type,
+					    ifa->idev->dev->ifindex) == daddr_label) {
 				score.attrs |= IPV6_SADDR_SCORE_LABEL;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LABEL)) {
 					score.rule = 6;

---
commit 184e391ee61e6c73db746bbd572da94266bd0cbf
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Nov 14 15:56:23 2007 +0900

    [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.
    
    Policy table is implemented as an RCU linear list since we do not expect
    large list nor frequent updates.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_addrlabel.h b/include/linux/if_addrlabel.h
new file mode 100644
index 0000000..9fe79c9
--- /dev/null
+++ b/include/linux/if_addrlabel.h
@@ -0,0 +1,32 @@
+/*
+ * if_addrlabel.h - netlink interface for address labels
+ *
+ * Copyright (C)2007 USAGI/WIDE Project,  All Rights Reserved.
+ *
+ * Authors:
+ *	YOSHIFUJI Hideaki @ USAGI/WIDE <yoshfuji@linux-ipv6.org>
+ */
+
+#ifndef __LINUX_IF_ADDRLABEL_H
+#define __LINUX_IF_ADDRLABEL_H
+
+struct ifaddrlblmsg
+{
+	__u8		ifal_family;		/* Address family */
+	__u8		__ifal_reserved;	/* Reserved */
+	__u8		ifal_prefixlen;		/* Prefix length */
+	__u8		ifal_flags;		/* Flags */
+	__u32		ifal_index;		/* Link index */
+	__u32		ifal_seq;		/* sequence number */
+};
+
+enum
+{
+	IFAL_ADDRESS = 1,
+	IFAL_LABEL = 2,
+	__IFAL_MAX
+};
+
+#define IFAL_MAX	(__IFAL_MAX - 1)
+
+#endif
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 4e81836..e20dcc8 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -100,6 +100,13 @@ enum {
 	RTM_NEWNDUSEROPT = 68,
 #define RTM_NEWNDUSEROPT RTM_NEWNDUSEROPT
 
+	RTM_NEWADDRLABEL = 72,
+#define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
+	RTM_DELADDRLABEL,
+#define RTM_NEWADDRLABEL RTM_NEWADDRLABEL
+	RTM_GETADDRLABEL,
+#define RTM_GETADDRLABEL RTM_GETADDRLABEL
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 33b593e..bccc2fe 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -84,6 +84,14 @@ extern void			addrconf_leave_solict(struct inet6_dev *idev,
 					struct in6_addr *addr);
 
 /*
+ *	IPv6 Address Label subsystem (addrlabel.c)
+ */
+extern int			ipv6_addr_label_init(void);
+extern void			ipv6_addr_label_rtnl_register(void);
+extern u32			ipv6_addr_label(const struct in6_addr *addr,
+						int type, int ifindex);
+
+/*
  *	multicast prototypes (mcast.c)
  */
 extern int ipv6_sock_mc_join(struct sock *sk, int ifindex, 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 87c23a7..5ffa980 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_IPV6) += ipv6.o
 
 ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
+		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o \
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0076010..80795e1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -874,36 +874,6 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
-/* static matching label */
-static inline int ipv6_addr_label(const struct in6_addr *addr, int type,
-				  int ifindex)
-{
- /*
-  * 	prefix (longest match)	label
-  * 	-----------------------------
-  * 	::1/128			0
-  * 	::/0			1
-  * 	2002::/16		2
-  * 	::/96			3
-  * 	::ffff:0:0/96		4
-  *	fc00::/7		5
-  * 	2001::/32		6
-  */
-	if (type & IPV6_ADDR_LOOPBACK)
-		return 0;
-	else if (type & IPV6_ADDR_COMPATv4)
-		return 3;
-	else if (type & IPV6_ADDR_MAPPED)
-		return 4;
-	else if (addr->s6_addr32[0] == htonl(0x20010000))
-		return 6;
-	else if (addr->s6_addr16[0] == htons(0x2002))
-		return 2;
-	else if ((addr->s6_addr[0] & 0xfe) == 0xfc)
-		return 5;
-	return 1;
-}
-
 int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 		       struct in6_addr *daddr, struct in6_addr *saddr)
 {
@@ -4180,7 +4150,13 @@ EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
 int __init addrconf_init(void)
 {
-	int err = 0;
+	int err;
+
+	if ((err = ipv6_addr_label_init()) < 0) {
+		printk(KERN_CRIT "IPv6 Addrconf: cannot initialize default policy table: %d.\n",
+			err);
+		return err;
+	}
 
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
@@ -4231,6 +4207,8 @@ int __init addrconf_init(void)
 	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL, inet6_dump_ifmcaddr);
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL, inet6_dump_ifacaddr);
 
+	ipv6_addr_label_rtnl_register();
+
 #ifdef CONFIG_SYSCTL
 	addrconf_sysctl.sysctl_header =
 		register_sysctl_table(addrconf_sysctl.addrconf_root_dir);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
new file mode 100644
index 0000000..204d4d6
--- /dev/null
+++ b/net/ipv6/addrlabel.c
@@ -0,0 +1,551 @@
+/*
+ * IPv6 Address Label subsystem
+ * for the IPv6 "Default" Source Address Selection
+ *
+ * Copyright (C)2007 USAGI/WIDE Project
+ */
+/*
+ * Author:
+ * 	YOSHIFUJI Hideaki @ USAGI/WIDE Project <yoshfuji@linux-ipv6.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/rcupdate.h>
+#include <linux/in6.h>
+#include <net/addrconf.h>
+#include <linux/if_addrlabel.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+
+#if 0
+#define ADDRLABEL(x...) printk(x)
+#else
+#define ADDRLABEL(x...) do { ; } while(0)
+#endif
+
+/*
+ * Policy Table
+ */
+struct ip6addrlbl_entry
+{
+	struct in6_addr prefix;
+	int prefixlen;
+	int ifindex;
+	int addrtype;
+	u32 label;
+	struct hlist_node list;
+	atomic_t refcnt;
+	struct rcu_head rcu;
+};
+
+static struct ip6addrlbl_table
+{
+	struct hlist_head head;
+	spinlock_t lock;
+	u32 seq;
+} ip6addrlbl_table;
+
+/*
+ * Default policy table (RFC3484 + extensions)
+ *
+ * prefix		addr_type	label
+ * -------------------------------------------------------------------------
+ * ::1/128		LOOPBACK	0
+ * ::/0			N/A		1
+ * 2002::/16		N/A		2
+ * ::/96		COMPATv4	3
+ * ::ffff:0:0/96	V4MAPPED	4
+ * fc00::/7		N/A		5		ULA (RFC 4193)
+ * 2001::/32		N/A		6		Teredo (RFC 4380)
+ *
+ * Note: 0xffffffff is used if we do not have any policies.
+ */
+
+#define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
+
+static const __initdata struct ip6addrlbl_init_table
+{
+	const struct in6_addr *prefix;
+	int prefixlen;
+	u32 label;
+} ip6addrlbl_init_table[] = {
+	{	/* ::/0 */
+		.prefix = &in6addr_any,
+		.label = 1,
+	},{	/* fc00::/7 */
+		.prefix = &(struct in6_addr){{{ 0xfc }}},
+		.prefixlen = 7,
+		.label = 5,
+	},{	/* 2002::/16 */
+		.prefix = &(struct in6_addr){{{ 0x20, 0x02 }}},
+		.prefixlen = 16,
+		.label = 2,
+	},{	/* 2001::/32 */
+		.prefix = &(struct in6_addr){{{ 0x20, 0x01 }}},
+		.prefixlen = 32,
+		.label = 6,
+	},{	/* ::ffff:0:0 */
+		.prefix = &(struct in6_addr){{{ [10] = 0xff, [11] = 0xff }}},
+		.prefixlen = 96,
+		.label = 4,
+	},{	/* ::/96 */
+		.prefix = &in6addr_any,
+		.prefixlen = 96,
+		.label = 3,
+	},{	/* ::1/128 */
+		.prefix = &in6addr_loopback,
+		.prefixlen = 128,
+		.label = 0,
+	}
+};
+
+/* Object management */
+static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
+{
+	kfree(p);
+}
+
+static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
+{
+	return atomic_inc_not_zero(&p->refcnt);
+}
+
+static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
+{
+	if (atomic_dec_and_test(&p->refcnt))
+		ip6addrlbl_free(p);
+}
+
+static void ip6addrlbl_free_rcu(struct rcu_head *h)
+{
+	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
+}
+
+/* Find label */
+static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
+			      const struct in6_addr *addr,
+			      int addrtype, int ifindex)
+{
+	if (p->ifindex && p->ifindex != ifindex)
+		return 0;
+	if (p->addrtype && p->addrtype != addrtype)
+		return 0;
+	if (!ipv6_prefix_equal(addr, &p->prefix, p->prefixlen))
+		return 0;
+	return 1;
+}
+
+static struct ip6addrlbl_entry *__ipv6_addr_label(const struct in6_addr *addr,
+						  int type, int ifindex)
+{
+	struct hlist_node *pos;
+	struct ip6addrlbl_entry *p;
+	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
+		if (__ip6addrlbl_match(p, addr, type, ifindex))
+			return p;
+	}
+	return NULL;
+}
+
+u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
+{
+	u32 label;
+	struct ip6addrlbl_entry *p;
+
+	type &= IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK;
+
+	rcu_read_lock();
+	p = __ipv6_addr_label(addr, type, ifindex);
+	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
+	rcu_read_unlock();
+
+	ADDRLABEL(KERN_DEBUG "%s(addr=" NIP6_FMT ", type=%d, ifindex=%d) => %08x\n",
+			__FUNCTION__,
+			NIP6(*addr), type, ifindex,
+			label);
+
+	return label;
+}
+
+/* allocate one entry */
+struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
+					  int prefixlen, int ifindex,
+					  u32 label)
+{
+	struct ip6addrlbl_entry *newp;
+	int addrtype;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex,
+			(unsigned int)label);
+
+	addrtype = ipv6_addr_type(prefix) & (IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK);
+
+	switch (addrtype) {
+	case IPV6_ADDR_MAPPED:
+		if (prefixlen > 96)
+			return ERR_PTR(-EINVAL);
+		if (prefixlen < 96)
+			addrtype = 0;
+		break;
+	case IPV6_ADDR_COMPATv4:
+		if (prefixlen != 96)
+			addrtype = 0;
+		break;
+	case IPV6_ADDR_LOOPBACK:
+		if (prefixlen != 128)
+			addrtype = 0;
+		break;
+	}
+
+	newp = kmalloc(sizeof(*newp), GFP_KERNEL);
+	if (!newp)
+		return ERR_PTR(-ENOMEM);
+
+	ipv6_addr_prefix(&newp->prefix, prefix, prefixlen);
+	newp->prefixlen = prefixlen;
+	newp->ifindex = ifindex;
+	newp->addrtype = addrtype;
+	newp->label = label;
+	INIT_HLIST_NODE(&newp->list);
+	atomic_set(&newp->refcnt, 1);
+	return newp;
+}
+
+/* add a label */
+int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
+{
+	int ret = 0;
+
+	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n",
+			__FUNCTION__,
+			newp, replace);
+
+	if (hlist_empty(&ip6addrlbl_table.head)) {
+		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
+	} else {
+		struct hlist_node *pos, *n;
+		struct ip6addrlbl_entry *p = NULL;
+		hlist_for_each_entry_safe(p, pos, n,
+					  &ip6addrlbl_table.head, list) {
+			if (p->prefixlen == newp->prefixlen &&
+			    p->ifindex == newp->ifindex &&
+			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
+				if (!replace) {
+					ret = -EEXIST;
+					goto out;
+				}
+				hlist_replace_rcu(&p->list, &newp->list);
+				ip6addrlbl_put(p);
+				call_rcu(&p->rcu, ip6addrlbl_free_rcu);
+				goto out;
+			} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
+				   (p->prefixlen < newp->prefixlen)) {
+				hlist_add_before_rcu(&newp->list, &p->list);
+				goto out;
+			}
+		}
+		hlist_add_after_rcu(&p->list, &newp->list);
+	}
+out:
+	if (!ret)
+		ip6addrlbl_table.seq++;
+	return ret;
+}
+
+/* add a label */
+int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
+		       int ifindex, u32 label, int replace)
+{
+	struct ip6addrlbl_entry *newp;
+	int ret = 0;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex,
+			(unsigned int)label,
+			replace);
+
+	newp = ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
+	if (IS_ERR(newp))
+		return PTR_ERR(newp);
+	spin_lock(&ip6addrlbl_table.lock);
+	ret = __ip6addrlbl_add(newp, replace);
+	spin_unlock(&ip6addrlbl_table.lock);
+	if (ret)
+		ip6addrlbl_free(newp);
+	return ret;
+}
+
+/* remove a label */
+int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+			  int ifindex)
+{
+	struct ip6addrlbl_entry *p = NULL;
+	struct hlist_node *pos, *n;
+	int ret = -ESRCH;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex);
+
+	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
+		if (p->prefixlen == prefixlen &&
+		    p->ifindex == ifindex &&
+		    ipv6_addr_equal(&p->prefix, prefix)) {
+			hlist_del_rcu(&p->list);
+			ip6addrlbl_put(p);
+			call_rcu(&p->rcu, ip6addrlbl_free_rcu);
+			ret = 0;
+			break;
+		}
+	}
+	return ret;
+}
+
+int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+		       int ifindex)
+{
+	struct in6_addr prefix_buf;
+	int ret;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex);
+
+	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
+	spin_lock(&ip6addrlbl_table.lock);
+	ret = __ip6addrlbl_del(&prefix_buf, prefixlen, ifindex);
+	spin_unlock(&ip6addrlbl_table.lock);
+	return ret;
+}
+
+/* add default label */
+static __init int ip6addrlbl_init(void)
+{
+	int err = 0;
+	int i;
+
+	ADDRLABEL(KERN_DEBUG "%s()\n", __FUNCTION__);
+
+	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
+		int ret = ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
+					 ip6addrlbl_init_table[i].prefixlen,
+					 0,
+					 ip6addrlbl_init_table[i].label, 0);
+		/* XXX: should we free all rules when we catch an error? */
+		if (ret && (!err || err != -ENOMEM))
+			err = ret;
+	}
+	return err;
+}
+
+int __init ipv6_addr_label_init(void)
+{
+	spin_lock_init(&ip6addrlbl_table.lock);
+
+	return ip6addrlbl_init();
+}
+
+static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
+	[IFAL_ADDRESS]		= { .len = sizeof(struct in6_addr), },
+	[IFAL_LABEL]		= { .len = sizeof(u32), },
+};
+
+static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     void *arg)
+{
+	struct ifaddrlblmsg *ifal;
+	struct nlattr *tb[IFAL_MAX+1];
+	struct in6_addr *pfx;
+	u32 label;
+	int err = 0;
+
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
+	if (err < 0)
+		return err;
+
+	ifal = nlmsg_data(nlh);
+
+	if (ifal->ifal_family != AF_INET6 ||
+	    ifal->ifal_prefixlen > 128)
+		return -EINVAL;
+
+	if (ifal->ifal_index &&
+	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+		return -EINVAL;
+
+	if (!tb[IFAL_ADDRESS])
+		return -EINVAL;
+
+	pfx = nla_data(tb[IFAL_ADDRESS]);
+	if (!pfx)
+		return -EINVAL;
+
+	if (!tb[IFAL_LABEL])
+		return -EINVAL;
+	label = nla_get_u32(tb[IFAL_LABEL]);
+	if (label == IPV6_ADDR_LABEL_DEFAULT)
+		return -EINVAL;
+
+	switch(nlh->nlmsg_type) {
+	case RTM_NEWADDRLABEL:
+		err = ip6addrlbl_add(pfx, ifal->ifal_prefixlen,
+				     ifal->ifal_index, label,
+				     nlh->nlmsg_flags & NLM_F_REPLACE);
+		break;
+	case RTM_DELADDRLABEL:
+		err = ip6addrlbl_del(pfx, ifal->ifal_prefixlen,
+				     ifal->ifal_index);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+	}
+	return err;
+}
+
+static inline void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
+				     int prefixlen, int ifindex, u32 lseq)
+{
+	struct ifaddrlblmsg *ifal = nlmsg_data(nlh);
+	ifal->ifal_family = AF_INET6;
+	ifal->ifal_prefixlen = prefixlen;
+	ifal->ifal_flags = 0;
+	ifal->ifal_index = ifindex;
+	ifal->ifal_seq = lseq;
+};
+
+static int ip6addrlbl_fill(struct sk_buff *skb,
+			   struct ip6addrlbl_entry *p,
+			   u32 lseq,
+			   u32 pid, u32 seq, int event,
+			   unsigned int flags)
+{
+	struct nlmsghdr *nlh = nlmsg_put(skb, pid, seq, event,
+					 sizeof(struct ifaddrlblmsg), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	ip6addrlbl_putmsg(nlh, p->prefixlen, p->ifindex, lseq);
+
+	if (nla_put(skb, IFAL_ADDRESS, 16, &p->prefix) < 0 ||
+	    nla_put_u32(skb, IFAL_LABEL, p->label) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
+
+	return nlmsg_end(skb, nlh);
+}
+
+static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ip6addrlbl_entry *p;
+	struct hlist_node *pos;
+	int idx = 0, s_idx = cb->args[0];
+	int err;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
+		if (idx >= s_idx) {
+			if ((err = ip6addrlbl_fill(skb, p,
+						   ip6addrlbl_table.seq,
+						   NETLINK_CB(cb->skb).pid,
+						   cb->nlh->nlmsg_seq,
+						   RTM_NEWADDRLABEL,
+						   NLM_F_MULTI)) <= 0)
+				break;
+		}
+		idx++;
+	}
+	rcu_read_unlock();
+	cb->args[0] = idx;
+	return skb->len;
+}
+
+static inline int ip6addrlbl_msgsize(void)
+{
+	return (NLMSG_ALIGN(sizeof(struct ifaddrlblmsg))
+		+ nla_total_size(16)	/* IFAL_ADDRESS */
+		+ nla_total_size(4)	/* IFAL_LABEL */
+	);
+}
+
+static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
+			  void *arg)
+{
+	struct ifaddrlblmsg *ifal;
+	struct nlattr *tb[IFAL_MAX+1];
+	struct in6_addr *addr;
+	u32 lseq;
+	int err = 0;
+	struct ip6addrlbl_entry *p;
+	struct sk_buff *skb;
+
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
+	if (err < 0)
+		return err;
+
+	ifal = nlmsg_data(nlh);
+
+	if (ifal->ifal_family != AF_INET6 ||
+	    ifal->ifal_prefixlen != 128)
+		return -EINVAL;
+
+	if (ifal->ifal_index &&
+	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+		return -EINVAL;
+
+	if (!tb[IFAL_ADDRESS])
+		return -EINVAL;
+
+	addr = nla_data(tb[IFAL_ADDRESS]);
+	if (!addr)
+		return -EINVAL;
+
+	rcu_read_lock();
+	p = __ipv6_addr_label(addr, ipv6_addr_type(addr), ifal->ifal_index);
+	if (p && ip6addrlbl_hold(p))
+		p = NULL;
+	lseq = ip6addrlbl_table.seq;
+	rcu_read_unlock();
+
+	if (!p) {
+		err = -ESRCH;
+		goto out;
+	}
+
+	if (!(skb = nlmsg_new(ip6addrlbl_msgsize(), GFP_KERNEL))) {
+		ip6addrlbl_put(p);
+		return -ENOBUFS;
+	}
+
+	err = ip6addrlbl_fill(skb, p, lseq,
+			      NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+			      RTM_NEWADDRLABEL, 0);
+
+	ip6addrlbl_put(p);
+
+	if (err < 0) {
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto out;
+	}
+
+	err = rtnl_unicast(skb, NETLINK_CB(in_skb).pid);
+out:
+	return err;
+}
+
+void __init ipv6_addr_label_rtnl_register(void)
+{
+	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel, NULL);
+	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel, NULL);
+	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get, ip6addrlbl_dump);
+}
+

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
