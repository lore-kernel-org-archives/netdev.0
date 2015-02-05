From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 15/29] net: vrf: Add vrf to net_ctx struct
Date: Wed,  4 Feb 2015 18:34:16 -0700
Message-ID: <1423100070-31848-16-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:58072 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966137AbbBEBgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:06 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so6720818iec.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:06 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf macros for accessing vrf in net_ctx references similar to what
exists for net, update helper functions and macros to set vrf context,
and handle initialization of vrf context for all existing net_ctx uses.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h        | 9 ++++++++-
 include/net/fib_rules.h          | 2 ++
 include/net/inet_sock.h          | 1 +
 include/net/inet_timewait_sock.h | 1 +
 include/net/ip_fib.h             | 1 +
 include/net/ipv6.h               | 1 +
 include/net/neighbour.h          | 9 +++++++++
 include/net/net_namespace.h      | 4 +++-
 include/net/netlink.h            | 1 +
 include/net/sock.h               | 4 +++-
 net/core/neighbour.c             | 2 +-
 11 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 43bb40260bfa..b6de06eda683 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1699,6 +1699,7 @@ struct net_device {
 
 	struct net_ctx		net_ctx;
 #define nd_net net_ctx.net
+#define nd_vrf net_ctx.vrf
 
 	/* mid-layer private */
 	union {
@@ -1845,7 +1846,13 @@ void dev_net_set(struct net_device *dev, struct net *net)
 }
 
 /* get net_ctx from device */
-#define DEV_NET_CTX(dev)  { .net = dev_net((dev)) }
+#define DEV_NET_CTX(dev)  { .net = dev_net((dev)), .vrf = (dev)->nd_vrf }
+
+static inline
+__u32 dev_vrf(const struct net_device *dev)
+{
+	return dev->nd_vrf;
+}
 
 static inline
 int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ctx)
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 1a545b23494e..0af67c3122f3 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -22,6 +22,7 @@ struct fib_rule {
 	struct fib_rule __rcu	*ctarget;
 	struct net_ctx		fr_net_ctx;
 #define fr_net  fr_net_ctx.net
+#define fr_vrf  fr_net_ctx.vrf
 
 	atomic_t		refcnt;
 	u32			pref;
@@ -78,6 +79,7 @@ struct fib_rules_ops {
 	struct module		*owner;
 	struct net_ctx		fro_net_ctx;
 #define fro_net  fro_net_ctx.net
+#define fro_vrf  fro_net_ctx.vrf
 	struct rcu_head		rcu;
 };
 
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index eb16c7beed1e..de59174d3124 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -77,6 +77,7 @@ struct inet_request_sock {
 #define ir_v6_rmt_addr		req.__req_common.skc_v6_daddr
 #define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
 #define ir_iif			req.__req_common.skc_bound_dev_if
+#define ir_vrf			req.__req_common.skc_net_ctx.vrf
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 6c566034e26d..c9f3bf6f8b24 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -116,6 +116,7 @@ struct inet_timewait_sock {
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
+#define tw_vrf			__tw_common.skc_vrf
 #define tw_daddr        	__tw_common.skc_daddr
 #define tw_v6_daddr		__tw_common.skc_v6_daddr
 #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 85f5ddacba8d..577479d7f268 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -100,6 +100,7 @@ struct fib_info {
 	struct hlist_node	fib_lhash;
 	struct net_ctx		fib_net_ctx;
 #define fib_net  fib_net_ctx.net
+#define fib_vrf  fib_net_ctx.vrf
 	int			fib_treeref;
 	atomic_t		fib_clntref;
 	unsigned int		fib_flags;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2d025ed7a183..61f8b6df8bb9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -240,6 +240,7 @@ struct ip6_flowlabel {
 	unsigned long		expires;
 	struct net_ctx		fl_net_ctx;
 #define fl_net  fl_net_ctx.net
+#define fl_vrf  fl_net_ctx.vrf
 };
 
 static inline
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 8cf9bc2236da..73d0938b085c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -281,6 +281,15 @@ struct net *neigh_parms_net(const struct neigh_parms *parms)
 }
 
 static inline
+__u32 neigh_parms_vrf(const struct neigh_parms *parms)
+{
+	return parms->net_ctx.vrf;
+}
+
+#define NEIGH_PARMS_NET_CTX(p) \
+		{ .net = neigh_parms_net((p)), .vrf = neigh_parms_vrf((p)) }
+
+static inline
 int neigh_parms_net_ctx_eq(const struct neigh_parms *parms,
 			   const struct net_ctx *net_ctx)
 {
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index e7060b43570d..7cc7b0a1a20b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -27,6 +27,7 @@
 #include <net/netns/nftables.h>
 #include <net/netns/xfrm.h>
 #include <linux/ns_common.h>
+#include <net/vrf.h>
 
 struct user_namespace;
 struct proc_dir_entry;
@@ -138,6 +139,7 @@ struct net_ctx {
 #ifdef CONFIG_NET_NS
 	struct net *net;
 #endif
+	__u32 vrf;
 };
 
 #include <linux/seq_file_net.h>
@@ -145,7 +147,7 @@ struct net_ctx {
 /* Init's network namespace */
 extern struct net init_net;
 
-#define INIT_NET_CTX  { .net = &init_net }
+#define INIT_NET_CTX  { .net = &init_net, .vrf = VRF_DEFAULT }
 
 #ifdef CONFIG_NET_NS
 struct net *copy_net_ns(unsigned long flags, struct user_namespace *user_ns,
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 587a6ef973e5..82c4a2628106 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -224,6 +224,7 @@ struct nl_info {
 	struct nlmsghdr		*nlh;
 	struct net_ctx		nl_net_ctx;
 #define nl_net  nl_net_ctx.net
+#define nl_vrf nl_net_ctx.vrf
 	u32			portid;
 };
 
diff --git a/include/net/sock.h b/include/net/sock.h
index e67347ed1555..a7cd250e9daf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -192,6 +192,7 @@ struct sock_common {
 	struct proto		*skc_prot;
 	struct net_ctx		skc_net_ctx;
 #define skc_net  skc_net_ctx.net
+#define skc_vrf  skc_net_ctx.vrf
 
 #if IS_ENABLED(CONFIG_IPV6)
 	struct in6_addr		skc_v6_daddr;
@@ -326,6 +327,7 @@ struct sock {
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net_ctx.net
+#define sk_vrf			__sk_common.skc_net_ctx.vrf
 #define sk_v6_daddr		__sk_common.skc_v6_daddr
 #define sk_v6_rcv_saddr	__sk_common.skc_v6_rcv_saddr
 
@@ -2196,7 +2198,7 @@ void sock_net_set(struct sock *sk, struct net *net)
 	write_pnet(&sk->sk_net, net);
 }
 
-#define SOCK_NET_CTX(sk)  { .net = sock_net((sk)) }
+#define SOCK_NET_CTX(sk)  { .net = sock_net((sk)), .vrf = (sk)->sk_vrf }
 
 static inline
 int sock_net_ctx_eq(struct sock *sk, struct net_ctx *ctx)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 93a7701a7ae7..d872ada6720a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2855,7 +2855,7 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 {
 	struct net_device *dev = ctl->extra1;
 	struct neigh_parms *p = ctl->extra2;
-	struct net_ctx ctx = { .net = neigh_parms_net(p) };
+	struct net_ctx ctx = NEIGH_PARMS_NET_CTX(p);
 	int index = (int *) ctl->data - p->data;
 
 	if (!write)
-- 
1.9.3 (Apple Git-50)
