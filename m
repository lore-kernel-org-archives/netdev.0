From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 12/24] net, diet: Make rtnetlink optional
Date: Mon,  5 May 2014 15:26:01 -0700
Message-ID: <1399328773-6531-13-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58940 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933147AbaEEW0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:25 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Small systems can use ioctl/ifconfig for routing and
interface configuration. Make rtnetlink optional
This saves ~29k without LTO, more with LTO.

   text    data     bss     dec     hex filename
 483545   19371   13480  516396   7e12c net/built-in.o-with-rtnetlink
 454365   19275   12936  486576   76cb0 net/built-in.o-wo-rtnetlink

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/rtnetlink.h | 56 +++++++++++++++++++++++++++++++++++++++++------
 include/net/rtnetlink.h   | 35 +++++++++++++++++++++++++++++
 net/Kconfig               |  8 +++++++
 net/core/Makefile         |  3 ++-
 net/ipv4/fib_frontend.c   |  7 ++++++
 net/ipv4/fib_lookup.h     | 12 ++++++++++
 net/ipv4/fib_semantics.c  |  4 ++++
 7 files changed, 117 insertions(+), 8 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8e3e66a..e876aa2 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -7,15 +7,32 @@
 #include <uapi/linux/rtnetlink.h>
 
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
-extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
-extern void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
-			u32 group, struct nlmsghdr *nlh, gfp_t flags);
-extern void rtnl_set_sk_err(struct net *net, u32 group, int error);
-extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
 			      u32 id, long expires, u32 error);
 
+#ifdef CONFIG_RTNETLINK
+void rtnl_set_sk_err(struct net *net, u32 group, int error);
+int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
+void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
+			u32 group, struct nlmsghdr *nlh, gfp_t flags);
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
+int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
+#else
+static inline int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid)
+{ return -EIO; }
+
+static inline void
+rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags) {}
+
+static inline void
+rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
+	    u32 group, struct nlmsghdr *nlh, gfp_t flags) {}
+
+static inline int
+rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics) { return -EINVAL; }
+
+static inline void rtnl_set_sk_err(struct net *net, u32 group, int error) {}
+#endif
 
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
@@ -59,7 +76,12 @@ static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
 
 extern struct netdev_queue *dev_ingress_queue_create(struct net_device *dev);
 
+#ifdef CONFIG_RTNETLINK
 extern void rtnetlink_init(void);
+#else
+static inline void rtnetlink_init(void) {}
+#endif
+
 extern void __rtnl_unlock(void);
 
 #define ASSERT_RTNL() do { \
@@ -70,6 +92,7 @@ extern void __rtnl_unlock(void);
 	} \
 } while(0)
 
+#ifdef CONFIG_RTNETLINK
 extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
@@ -79,11 +102,30 @@ extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
 			    struct net_device *dev,
 			    const unsigned char *addr,
 			     u16 flags);
+extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				   struct net_device *dev, u16 mode);
 extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
 			    struct nlattr *tb[],
 			    struct net_device *dev,
 			    const unsigned char *addr);
 
-extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				   struct net_device *dev, u16 mode);
+#else
+static inline int ndo_dflt_fdb_dump(struct sk_buff *skb,
+			     struct netlink_callback *cb,
+			     struct net_device *dev,
+			     int idx) { return -EINVAL; }
+static inline int ndo_dflt_fdb_add(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr,
+			     u16 flags) { return -EINVAL; }
+static inline int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				   struct net_device *dev, u16 mode)
+{ return -EINVAL; }
+static inline int ndo_dflt_fdb_del(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr)
+{ return -EINVAL; }
+#endif	/* !CONFIG_RTNETLINK */
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 72240e5..859078b 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -8,12 +8,23 @@ typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
+#ifdef CONFIG_RTNETLINK
 int __rtnl_register(int protocol, int msgtype,
 		    rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
 void rtnl_register(int protocol, int msgtype,
 		   rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
 int rtnl_unregister(int protocol, int msgtype);
 void rtnl_unregister_all(int protocol);
+#else
+static inline int __rtnl_register(int protocol, int msgtype,
+		    rtnl_doit_func d, rtnl_dumpit_func du, rtnl_calcit_func c)
+{ return -EINVAL; }
+static inline void rtnl_register(int protocol, int msgtype,
+		   rtnl_doit_func d, rtnl_dumpit_func du, rtnl_calcit_func c)
+{ }
+static inline int rtnl_unregister(int protocol, int msgtype) { return 0; }
+static inline void rtnl_unregister_all(int protocol) {}
+#endif
 
 static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
 {
@@ -95,11 +106,25 @@ struct rtnl_link_ops {
 						   const struct net_device *slave_dev);
 };
 
+#ifdef CONFIG_RTNETLINK
 int __rtnl_link_register(struct rtnl_link_ops *ops);
 void __rtnl_link_unregister(struct rtnl_link_ops *ops);
 
 int rtnl_link_register(struct rtnl_link_ops *ops);
 void rtnl_link_unregister(struct rtnl_link_ops *ops);
+#else
+/* Return 0 to make the respective init functions not error out.
+ * We assume the subsystems are still somewhat useful even without
+ * rtnetlink.
+ */
+static inline int __rtnl_link_register(struct rtnl_link_ops *ops)
+{ return 0; }
+static inline void __rtnl_link_unregister(struct rtnl_link_ops *ops) {}
+
+static inline int rtnl_link_register(struct rtnl_link_ops *ops)
+{ return 0; }
+static inline void rtnl_link_unregister(struct rtnl_link_ops *ops) {}
+#endif
 
 /**
  * 	struct rtnl_af_ops - rtnetlink address family operations
@@ -129,10 +154,20 @@ struct rtnl_af_ops {
 					       const struct nlattr *attr);
 };
 
+#ifdef CONFIG_RTNETLINK
+int __rtnl_af_register(struct rtnl_af_ops *ops);
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 void rtnl_af_register(struct rtnl_af_ops *ops);
 void rtnl_af_unregister(struct rtnl_af_ops *ops);
+#else
+static inline int __rtnl_af_register(struct rtnl_af_ops *ops)
+{ return -EINVAL; }
+static inline void __rtnl_af_unregister(struct rtnl_af_ops *ops) {}
+
+static inline int rtnl_af_register(struct rtnl_af_ops *ops) { return -EINVAL; }
+static inline void rtnl_af_unregister(struct rtnl_af_ops *ops) {}
+#endif
 
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
 struct net_device *rtnl_create_link(struct net *net, char *ifname,
diff --git a/net/Kconfig b/net/Kconfig
index 82a5764..f5196ba 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -24,6 +24,14 @@ menuconfig NET
 
 if NET
 
+config RTNETLINK
+       bool "rtnetlink"
+       default y
+       help
+         Enable rtnetlink to configure routing and related setups.
+	 This is needed for most modern configuration
+	 tools, but old ifconfig can do without it.
+
 config WANT_COMPAT_NETLINK_MESSAGES
 	bool
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index e05bd9c..50d4850 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,11 +9,12 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o dev_addr_lists.o dst.o netevent.o \
-			neighbour.o rtnetlink.o utils.o link_watch.o \
+			neighbour.o utils.o link_watch.o \
 			sock_diag.o dev_ioctl.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
+obj-$(CONFIG_RTNETLINK) += rtnetlink.o
 obj-$(CONFIG_NET_ETHTOOL) += ethtool.o
 obj-$(CONFIG_PROC_FS) += net-procfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 255aa99..3221b0e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -917,6 +917,9 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 #undef BRD1_OK
 }
 
+#ifdef CONFIG_RTNETLINK
+/* Isn't really rtnetlink, but close enough for this CONFIG. */
+
 static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 {
 
@@ -994,6 +997,10 @@ static void nl_fib_lookup_exit(struct net *net)
 	netlink_kernel_release(net->ipv4.fibnl);
 	net->ipv4.fibnl = NULL;
 }
+#else
+static inline void nl_fib_lookup_exit(struct net *net) {}
+static inline int nl_fib_lookup_init(struct net *net) { return 0; }
+#endif
 
 static void fib_disable_ip(struct net_device *dev, int force)
 {
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 1e4f660..ec29c81 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -27,11 +27,23 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 void fib_release_info(struct fib_info *);
 struct fib_info *fib_create_info(struct fib_config *cfg);
 int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
+#ifdef CONFIG_RTNETLINK
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
 		  unsigned int);
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
 	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
+#else
+static inline int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq,
+		  int event, u32 tb_id,
+		  u8 type, __be32 dst, int dst_len, u8 tos,
+		  struct fib_info *fi,
+		  unsigned int f) { return -EINVAL; }
+static inline void
+rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
+	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags)
+{}
+#endif
 struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
 
 static inline void fib_result_assign(struct fib_result *res,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c3d4e4d..75be44d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -356,6 +356,7 @@ int ip_fib_check_default(__be32 gw, struct net_device *dev)
 	return -1;
 }
 
+#ifdef CONFIG_RTNETLINK
 static inline size_t fib_nlmsg_size(struct fib_info *fi)
 {
 	size_t payload = NLMSG_ALIGN(sizeof(struct rtmsg))
@@ -411,6 +412,7 @@ errout:
 	if (err < 0)
 		rtnl_set_sk_err(info->nl_net, RTNLGRP_IPV4_ROUTE, err);
 }
+#endif
 
 /* Return the first fib alias matching TOS with
  * priority less than or equal to PRIO.
@@ -998,6 +1000,7 @@ failure:
 	return ERR_PTR(err);
 }
 
+#ifdef CONFIG_RTNETLINK
 int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		  u32 tb_id, u8 type, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
@@ -1089,6 +1092,7 @@ nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
+#endif
 
 /*
  * Update FIB if:
-- 
1.9.0
