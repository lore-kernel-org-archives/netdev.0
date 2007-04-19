From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC] [GIT PATCH net-2.6.23] IPV6: Configurable IPv6 address
 selection policy table (RFC3484)
Date: Thu, 19 Apr 2007 16:28:56 +0900 (JST)
Message-ID: <20070419.162856.20840698.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43658 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbXDSH1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 03:27:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This is RFC(*) for supporting configurable IPv6 address selection policy
table, which is described in RFC3484.

Corresponding userspace tool is available at
    <http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=/gitroot/ip6aspctl.git;a=summary>.


We store labels only in kernel, and leave precedence in userspace
(/etc/gai.conf), so far.  The name resolution library (getaddrinfo(3))
is required to be changed to try reading label information from kernel.
On the other hand, on BSDs or on Solaris, full policy table including
precedence seems to be stored in kernel, and the name resolution
libary (getaddrinfo(3)) seems to use that information.
We could choose this approach.

Note: Solaris uses string (up to 15 characters excluding NUL) labels.

At this moment, glibc does not reload /etc/gai.conf promptly by default.
According to getaddrinfo(3) manpage, getaddrinfo(3) does not seem
thread safe if we put "reload yes" in the configuration file (/etc/gai.conf).
We probably need to fix that.

Problems in current approach:

Currently when the getaddrinfo(3) tries to reload /etc/gai.conf,
it performs fstat to check if the file is updated.  However, procfs
always reports current time as modification time, so getaddrinfo(3)
will always need to reload procfs.  To further optimization we should
touch procfs subsystem.

Another issue in procfs is it is not atomic.
To solve this issue, we probably need to support netlink
interface.  However, I am not sure how we can optimize reading 
policy from kernel with this approach.


Another problem.  I put several new ioctls in include/linux/ipv6.h, but
I guess it is very hard to include that file from userspace... sigh...

TODOs: Probably we should use RCUs.


Comments / optimions welcome.


*: We do not expect this will be included in net-2.6.22,
but 2.6.23 or so.

Regrads,

---------
----
HEADLINES
---------

    [IPV6] ADDRCONF: define and export constant for ::.
    [IPV6] ADDRCONF: Prepare supporting source address selection policy with ifindex.
    [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.

DIFFSTAT
--------

 include/linux/in6.h    |    2 
 include/linux/ipv6.h   |   16 ++
 include/net/addrconf.h |    4 
 include/net/ipv6.h     |    5 +
 net/ipv6/Makefile      |    1 
 net/ipv6/addrconf.c    |   50 ++---
 net/ipv6/addrlabel.c   |  454 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/af_inet6.c    |    3 
 8 files changed, 498 insertions(+), 37 deletions(-)

CHANGESETS
----------

commit 27bafd017775cffa86d60eea179b68c4b90c4ae7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 3 00:12:49 2007 +0900

    [IPV6] ADDRCONF: define and export constant for ::.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in6.h b/include/linux/in6.h
index d559fac..2a61c82 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,10 +44,8 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
-#if 0
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
-#endif
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47d3adf..371ee2f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -206,9 +206,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
-#if 0
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
-#endif
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)

---
commit ce50931887ad6bdf951f1b165bd76e1cda9adf97
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 3 00:21:23 2007 +0900

    [IPV6] ADDRCONF: Prepare supporting source address selection policy with ifindex.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 371ee2f..c61fb62 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -831,7 +831,8 @@ static inline int ipv6_saddr_preferred(int type)
 }
 
 /* static matching label */
-static inline int ipv6_saddr_label(const struct in6_addr *addr, int type)
+static inline int ipv6_saddr_label(const struct in6_addr *addr, int type,
+				   int ifindex)
 {
  /*
   * 	prefix (longest match)	label
@@ -866,7 +867,8 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 	struct inet6_ifaddr *ifa_result = NULL;
 	int daddr_type = __ipv6_addr_type(daddr);
 	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
-	u32 daddr_label = ipv6_saddr_label(daddr, daddr_type);
+	int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;
+	u32 daddr_label = ipv6_saddr_label(daddr, daddr_type, daddr_ifindex);
 	struct net_device *dev;
 
 	memset(&hiscore, 0, sizeof(hiscore));
@@ -1039,11 +1041,15 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 
 			/* Rule 6: Prefer matching label */
 			if (hiscore.rule < 6) {
-				if (ipv6_saddr_label(&ifa_result->addr, hiscore.addr_type) == daddr_label)
+				if (ipv6_saddr_label(&ifa_result->addr,
+						     hiscore.addr_type,
+						     ifa_result->idev->dev->ifindex) == daddr_label)
 					hiscore.attrs |= IPV6_SADDR_SCORE_LABEL;
 				hiscore.rule++;
 			}
-			if (ipv6_saddr_label(&ifa->addr, score.addr_type) == daddr_label) {
+			if (ipv6_saddr_label(&ifa->addr,
+					     score.addr_type,
+					     ifa->idev->dev->ifindex) == daddr_label) {
 				score.attrs |= IPV6_SADDR_SCORE_LABEL;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LABEL)) {
 					score.rule = 6;

---
commit 97f194b6bfc52d312f01bed644df3a8d31f47101
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 16 11:12:30 2007 +0900

    [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 88ead9b..621ffbf 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -212,6 +212,22 @@ enum {
 	DEVCONF_MAX
 };
 
+/*
+ * IOCTLs
+ */
+#define SIOCAADDRLABEL_IN6	(SIOCPROTOPRIVATE + 8)
+#define SIOCDADDRLABEL_IN6	(SIOCPROTOPRIVATE + 9)
+
+struct in6_addrpolicy {
+	struct in6_addr		ip6ap_prefix;
+	__u32			ip6ap_prefixlen;
+	int			ip6ap_ifindex;
+	__u32			ip6ap_label;
+	__u32			ip6ap_reserved;
+};
+
+#define IPV6_ADDRLABEL_NOTAPP	0xFFFFFFFF
+
 #ifdef __KERNEL__
 #include <linux/icmpv6.h>
 #include <linux/tcp.h>
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f3531d0..222209f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -54,6 +54,8 @@ struct prefix_info {
 extern int			addrconf_init(void);
 extern void			addrconf_cleanup(void);
 
+extern int			addrlabel_init(void);
+
 extern int			addrconf_add_ifaddr(void __user *arg);
 extern int			addrconf_del_ifaddr(void __user *arg);
 extern int			addrconf_set_dstaddr(void __user *arg);
@@ -73,6 +75,8 @@ extern int			ipv6_get_saddr(struct dst_entry *dst,
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
+extern int			ipv6_saddr_label(const struct in6_addr *addr,
+						 int type, int ifindex);
 extern int			ipv6_get_lladdr(struct net_device *dev,
 						struct in6_addr *addr,
 						unsigned char banned_flags);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 00328b7..ba4bc01 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -592,6 +592,11 @@ extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
 
+/*
+ * addrlabel.c
+ */
+extern int addrlabel_ioctl(int cmd, void __user *arg);
+
 #ifdef CONFIG_PROC_FS
 extern int  ac6_proc_init(void);
 extern void ac6_proc_exit(void);
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index e947868..6b500d1 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_IPV6) += ipv6.o
 
 ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
+		addrlabel.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c61fb62..7b82a4f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -830,36 +830,6 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
-/* static matching label */
-static inline int ipv6_saddr_label(const struct in6_addr *addr, int type,
-				   int ifindex)
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
@@ -4090,7 +4060,13 @@ EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
 int __init addrconf_init(void)
 {
-	int err = 0;
+	int err;
+
+	if ((err = addrlabel_init()) < 0)
+		printk(KERN_CRIT "IPv6 Addrconf: cannot initialize default policy table: %d.\n",
+			err);
+
+	err = 0;
 
 	/* The addrconf netdev notifier requires that loopback_dev
 	 * has it's ipv6 private information allocated and setup
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
new file mode 100644
index 0000000..8c0b49c
--- /dev/null
+++ b/net/ipv6/addrlabel.c
@@ -0,0 +1,454 @@
+/*
+ * IPv6 "Default" Source Address Selection
+ *
+ * Copyright (C)2007 USAGI/WIDE Project
+ *
+ * Author:
+ * 	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ */
+
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/in6.h>
+#include <net/addrconf.h>
+#include <linux/proc_fs.h>
+
+#if 0
+#define ADDRLABEL(x...) printk(x)
+#else
+#define ADDRLABEL(x...) do { ; } while(0)
+#endif
+/*
+ * Default policy table
+ *
+ * prefix (longest match)	addr_type	label	note
+ * -------------------------------------------------------------------------
+ * ::1/128			LOOPBACK	0
+ * ::/0				N/A		1
+ * 2002::/16			N/A		2
+ * ::/96			COMPATv4	3
+ * ::ffff:0:0/96		V4MAPPED	4
+ * fc00::/7			N/A		5	ULA (RFC 4193)
+ * 2001::/32			N/A		6	Teredo (RFC 4380)
+ *
+ * Note: 0xffffffff is used if we do not have any policies.
+ */
+
+#define IPV6_SADDR_DEFAULT_LABEL	0xffffffffUL
+
+static const struct in6_addr in6addr_6to4 = { { { 0x20, 0x02 } } };
+static const struct in6_addr in6addr_teredo = { { { 0x20, 0x01 } } };
+static const struct in6_addr in6addr_ula  = { { { 0xfc } } };
+static const struct in6_addr in6addr_v4mapped = { { { [10] = 0xff, [11] = 0xff } } };
+
+struct ipv6_addrselect_rule
+{
+	struct in6_addr prefix;
+	int prefixlen;
+	int ifindex;
+	int addrtype;
+	uint32_t label;
+	struct hlist_node list;
+};
+
+static struct hlist_head ipv6_addrselect_rule;
+
+static DEFINE_RWLOCK(ipv6_addrselect_rule_lock);
+
+/* default label */
+static const struct ipv6_saddr_default_rule
+{
+	const struct in6_addr *prefix;
+	int prefixlen;
+	int ifindex;
+	uint32_t label;
+} ipv6_saddr_default_rule[] = {
+	{
+		.prefix = &in6addr_any,
+		.label = 1,
+	},{
+		.prefix = &in6addr_ula,
+		.prefixlen = 7,
+		.label = 5,
+	},{
+		.prefix = &in6addr_6to4,
+		.prefixlen = 16,
+		.label = 2,
+	},{
+		.prefix = &in6addr_teredo,
+		.prefixlen = 32,
+		.label = 6,
+	},{
+		.prefix = &in6addr_v4mapped,
+		.prefixlen = 96,
+		.label = 4,
+	},{
+		.prefix = &in6addr_any,
+		.prefixlen = 96,
+		.label = 3,
+	},{
+		.prefix = &in6addr_loopback,
+		.prefixlen = 128,
+		.label = 0,
+	},{	/* sentinel */
+		.label = IPV6_SADDR_DEFAULT_LABEL,
+	}
+};
+
+/* RCU */
+
+/* Find label */
+static int __ipv6_saddr_label_match(struct ipv6_addrselect_rule *p,
+				    const struct in6_addr *addr,
+				    int addrtype, int ifindex)
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
+int ipv6_saddr_label(const struct in6_addr *addr, int type, int ifindex)
+{
+	uint32_t label = IPV6_SADDR_DEFAULT_LABEL;
+	struct ipv6_addrselect_rule *p;
+	struct hlist_node *pos;
+
+	type &= IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK;
+
+	read_lock_bh(&ipv6_addrselect_rule_lock);
+	hlist_for_each_entry(p, pos, &ipv6_addrselect_rule, list) {
+		if (__ipv6_saddr_label_match(p, addr, type, ifindex)) {
+			label = p->label;
+			break;
+		}
+	}
+	read_unlock_bh(&ipv6_addrselect_rule_lock);
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
+struct ipv6_addrselect_rule *ipv6_addr_label_alloc(const struct in6_addr *prefix,
+						   int prefixlen,
+						   int ifindex, uint32_t label)
+{
+	struct ipv6_addrselect_rule *newp;
+	int addrtype;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex,
+			(unsigned int)label);
+
+	newp = kmalloc(sizeof(*newp), GFP_KERNEL);
+	if (!newp)
+		return NULL;
+
+	addrtype = ipv6_addr_type(prefix) & (IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK);
+
+	switch (addrtype) {
+	case IPV6_ADDR_MAPPED:
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
+	ipv6_addr_prefix(&newp->prefix, prefix, prefixlen);
+	newp->prefixlen = prefixlen;
+	newp->ifindex = ifindex;
+	newp->addrtype = addrtype;
+	newp->label = label;
+	INIT_HLIST_NODE(&newp->list);
+	return newp;
+}
+
+/* free one entry */
+void ipv6_addr_label_free(struct ipv6_addrselect_rule *p)
+{
+	kfree(p);
+}
+
+/* add a label */
+int __ipv6_addr_label_add(struct ipv6_addrselect_rule *newp,
+			  int replace)
+{
+	int ret = 0;
+
+	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n",
+			__FUNCTION__,
+			newp, replace);
+
+	if (hlist_empty(&ipv6_addrselect_rule)) {
+		hlist_add_head(&newp->list, &ipv6_addrselect_rule);
+	} else {
+		struct hlist_node *pos, *n;
+		struct ipv6_addrselect_rule *p = NULL;
+		hlist_for_each_entry_safe(p, pos, n,
+					  &ipv6_addrselect_rule, list) {
+			if (p->prefixlen == newp->prefixlen &&
+			    p->ifindex == newp->ifindex &&
+			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
+				if (!replace) {
+					ret = -EEXIST;
+					goto out;
+				}
+				hlist_del(&p->list);
+				ipv6_addr_label_free(p);
+			} else if ((p->prefixlen == newp->prefixlen && !p->ifindex) ||
+				   (p->prefixlen < newp->prefixlen)) {
+				hlist_add_before(&newp->list, &p->list);
+				goto out;
+			}
+		}
+		hlist_add_after(&p->list, &newp->list);
+	}
+out:
+	return ret;
+}
+
+/* add a label */
+int ipv6_addr_label_add(const struct in6_addr *prefix, int prefixlen,
+			int ifindex, uint32_t label,
+			int replace)
+{
+	struct ipv6_addrselect_rule *newp;
+	int ret = 0;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u, replace=%d)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex,
+			(unsigned int)label,
+			replace);
+
+	newp = ipv6_addr_label_alloc(prefix, prefixlen, ifindex, label);
+	if (!newp)
+		return -ENOMEM;
+	write_lock_bh(&ipv6_addrselect_rule_lock);
+	ret = __ipv6_addr_label_add(newp, replace);
+	write_unlock_bh(&ipv6_addrselect_rule_lock);
+	if (ret)
+		ipv6_addr_label_free(newp);
+	return ret;
+}
+
+/* remove a label */
+int __ipv6_addr_label_del(const struct in6_addr *prefix, int prefixlen,
+			  int ifindex, uint32_t label)
+{
+	struct ipv6_addrselect_rule *p = NULL;
+	struct hlist_node *pos, *n;
+	int ret = -ESRCH;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex, (unsigned int)label
+			);
+
+	hlist_for_each_entry_safe(p, pos, n, &ipv6_addrselect_rule, list) {
+		if (p->prefixlen == prefixlen &&
+		    p->ifindex == ifindex &&
+		    ipv6_addr_equal(&p->prefix, prefix)) {
+			hlist_del(&p->list);
+			ipv6_addr_label_free(p);
+			ret = 0;
+			break;
+		}
+	}
+	return ret;
+}
+
+int ipv6_addr_label_del(const struct in6_addr *prefix, int prefixlen,
+			int ifindex, uint32_t label)
+{
+	struct in6_addr prefix_buf;
+	int ret;
+
+	ADDRLABEL(KERN_DEBUG "%s(prefix=" NIP6_FMT ", prefixlen=%d, ifindex=%d, label=%u)\n",
+			__FUNCTION__,
+			NIP6(*prefix), prefixlen,
+			ifindex, (unsigned int)label
+			);
+
+	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
+	write_lock_bh(&ipv6_addrselect_rule_lock);
+	ret = __ipv6_addr_label_del(&prefix_buf, prefixlen, ifindex, label);
+	write_unlock_bh(&ipv6_addrselect_rule_lock);
+	return ret;
+}
+
+int addrlabel_ioctl(int cmd, void __user *arg)
+{
+	struct in6_addrpolicy p;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	if (copy_from_user(&p, arg, sizeof(p)) < 0)
+		return -EFAULT;
+	if (p.ip6ap_label == IPV6_ADDRLABEL_NOTAPP)
+		return -EINVAL;
+	if (p.ip6ap_prefixlen > 128)
+		return -EINVAL;
+	if (p.ip6ap_ifindex) {
+		struct net_device *dev;
+		dev = dev_get_by_index(p.ip6ap_ifindex);
+		if (!dev)
+			return -EINVAL;
+		dev_put(dev);
+	}
+
+	switch(cmd) {
+	case SIOCAADDRLABEL_IN6:
+		return ipv6_addr_label_add(&p.ip6ap_prefix,
+					   p.ip6ap_prefixlen,
+					   p.ip6ap_ifindex,
+					   p.ip6ap_label, 0);
+	case SIOCDADDRLABEL_IN6:
+		return ipv6_addr_label_del(&p.ip6ap_prefix,
+					   p.ip6ap_prefixlen,
+					   p.ip6ap_ifindex,
+					   p.ip6ap_label);
+	}
+	return -EOPNOTSUPP;
+}
+
+/* add default label */
+static int ipv6_saddr_label_init(void)
+{
+	int err = 0;
+	const struct ipv6_saddr_default_rule *p;
+
+	ADDRLABEL(KERN_DEBUG "%s()\n", __FUNCTION__);
+
+	for (p = ipv6_saddr_default_rule;
+	     p->label != IPV6_SADDR_DEFAULT_LABEL;
+	     p++) {
+		int ret = ipv6_addr_label_add(p->prefix, p->prefixlen,
+					      p->ifindex, p->label, 0);
+		/* XXX: should we free all rules when we catch an error? */
+		if (ret && (!err || err != -ENOMEM))
+			err = ret;
+	}
+	return err;
+}
+
+#ifdef CONFIG_PROC_FS
+static inline struct ipv6_addrselect_rule *addrlabel_get_idx(loff_t off)
+{
+	struct hlist_node *pos;
+	struct ipv6_addrselect_rule *p = NULL;
+	loff_t i = 0;
+
+	ADDRLABEL("%s(off=%llu)\n",
+		__FUNCTION__, (unsigned long long)off);
+
+	hlist_for_each_entry(p, pos, &ipv6_addrselect_rule, list) {
+		if (i >= off)
+			goto out;
+		i++;
+	}
+	p = NULL;
+out:
+	return i == off ? p : NULL;
+}
+
+void *addrlabel_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	ADDRLABEL("%s(seq=%p, pos=%p(%llu))\n",
+		__FUNCTION__, seq, pos, (unsigned long long)(pos ? *pos : 0ULL));
+	read_lock_bh(&ipv6_addrselect_rule_lock);
+	return (*pos ? addrlabel_get_idx(*pos - 1) : SEQ_START_TOKEN);
+}
+
+void *addrlabel_seq_next(struct seq_file *seq, void *v, loff_t *off)
+{
+	struct ipv6_addrselect_rule *p = v;
+	struct hlist_node *pos = &p->list;
+
+	ADDRLABEL("%s(seq=%p, v=%p, off=%p(%llu))\n",
+		__FUNCTION__, seq, v, off, (unsigned long long)(off ? *off : 0ULL));
+
+	++*off;
+	if (v == SEQ_START_TOKEN) {
+		hlist_for_each_entry(p, pos, &ipv6_addrselect_rule, list)
+			goto out;
+		p = NULL;
+	} else {
+		hlist_for_each_entry_continue(p, pos, list)
+			goto out;
+		p = NULL;
+	}
+out:
+	return p;
+}
+
+static void addrlabel_seq_stop(struct seq_file *seq, void *v)
+{
+	ADDRLABEL("%s(seq=%p, v=%p)\n",
+		__FUNCTION__, seq, v);
+	read_unlock_bh(&ipv6_addrselect_rule_lock);
+}
+
+static int addrlabel_seq_show(struct seq_file *seq, void *v)
+{
+	ADDRLABEL("%s(seq=%p, v=%p)\n",
+		__FUNCTION__, seq, v);
+
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%-39s %4s %10s %10s\n",
+			   "prefix", "plen", "ifindex", "label");
+	else {
+		struct ipv6_addrselect_rule *p = v;
+		seq_printf(seq,
+			   NIP6_FMT " %4d %10d %10u\n",
+			   NIP6(p->prefix), p->prefixlen,
+			   p->ifindex, (unsigned int)p->label);
+	}
+	return 0;
+}
+
+static struct seq_operations addrlabel_seq_ops = {
+	.start	=	addrlabel_seq_start,
+	.next	=	addrlabel_seq_next,
+	.stop	=	addrlabel_seq_stop,
+	.show	=	addrlabel_seq_show,
+};
+
+static int addrlabel_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &addrlabel_seq_ops);
+}
+
+static struct file_operations addrlabel_seq_fops = {
+	.owner		=	THIS_MODULE,
+	.open		=	addrlabel_seq_open,
+	.read		=	seq_read,
+	.llseek		=	seq_lseek,
+	.release	=	seq_release,
+};
+#endif
+
+int addrlabel_init(void)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_fops_create("ip6_addrlabel", S_IRUGO, &addrlabel_seq_fops);
+#endif
+	return ipv6_saddr_label_init();
+}
+
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index df31cdd..7168fd4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -462,6 +462,9 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return addrconf_del_ifaddr((void __user *) arg);
 	case SIOCSIFDSTADDR:
 		return addrconf_set_dstaddr((void __user *) arg);
+	case SIOCAADDRLABEL_IN6:
+	case SIOCDADDRLABEL_IN6:
+		return addrlabel_ioctl(cmd, (void __user *) arg);
 	default:
 		if (!sk->sk_prot->ioctl)
 			return -ENOIOCTLCMD;

---
