From: kaber@trash.net
Subject: [PATCH 33/79] netfilter: fix compilation when conntrack is disabled but tproxy is enabled
Date: Wed, 19 Jan 2011 20:14:33 +0100
Message-ID: <1295464519-21763-34-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@balabit.hu>

The IPv6 tproxy patches split IPv6 defragmentation off of conntrack, but
failed to update the #ifdef stanzas guarding the defragmentation related
fields and code in skbuff and conntrack related code in nf_defrag_ipv6.c.

This patch adds the required #ifdefs so that IPv6 tproxy can truly be used
without connection tracking.

Original report:
http://marc.info/?l=linux-netdev&m=129010118516341&w=2

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/skbuff.h                         |   15 +++++++++++++++
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |   10 ----------
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |   10 ++++++++++
 net/core/skbuff.c                              |    2 ++
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |    8 +++++++-
 5 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..4f2db79 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -255,6 +255,11 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
 
+#if defined(CONFIG_NF_DEFRAG_IPV4) || defined(CONFIG_NF_DEFRAG_IPV4_MODULE) || \
+    defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
+#define NET_SKBUFF_NF_DEFRAG_NEEDED 1
+#endif
+
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -362,6 +367,8 @@ struct sk_buff {
 	void			(*destructor)(struct sk_buff *skb);
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct nf_conntrack	*nfct;
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 	struct sk_buff		*nfct_reasm;
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -2051,6 +2058,8 @@ static inline void nf_conntrack_get(struct nf_conntrack *nfct)
 	if (nfct)
 		atomic_inc(&nfct->use);
 }
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
 {
 	if (skb)
@@ -2079,6 +2088,8 @@ static inline void nf_reset(struct sk_buff *skb)
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 	nf_conntrack_put_reasm(skb->nfct_reasm);
 	skb->nfct_reasm = NULL;
 #endif
@@ -2095,6 +2106,8 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	dst->nfct = src->nfct;
 	nf_conntrack_get(src->nfct);
 	dst->nfctinfo = src->nfctinfo;
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 	dst->nfct_reasm = src->nfct_reasm;
 	nf_conntrack_get_reasm(src->nfct_reasm);
 #endif
@@ -2108,6 +2121,8 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	nf_conntrack_put(dst->nfct);
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 	nf_conntrack_put_reasm(dst->nfct_reasm);
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
diff --git a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
index 1ee717e..a4c9936 100644
--- a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
@@ -7,16 +7,6 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6;
 
-extern int nf_ct_frag6_init(void);
-extern void nf_ct_frag6_cleanup(void);
-extern struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
-extern void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
-			       struct net_device *in,
-			       struct net_device *out,
-			       int (*okfn)(struct sk_buff *));
-
-struct inet_frags_ctl;
-
 #include <linux/sysctl.h>
 extern struct ctl_table nf_ct_ipv6_sysctl_table[];
 
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index 94dd54d..fd79c9a 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -3,4 +3,14 @@
 
 extern void nf_defrag_ipv6_enable(void);
 
+extern int nf_ct_frag6_init(void);
+extern void nf_ct_frag6_cleanup(void);
+extern struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
+extern void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
+			       struct net_device *in,
+			       struct net_device *out,
+			       int (*okfn)(struct sk_buff *));
+
+struct inet_frags_ctl;
+
 #endif /* _NF_DEFRAG_IPV6_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 104f844..74ebf4b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -380,6 +380,8 @@ static void skb_release_head_state(struct sk_buff *skb)
 	}
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	nf_conntrack_put(skb->nfct);
+#endif
+#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
 	nf_conntrack_put_reasm(skb->nfct_reasm);
 #endif
 #ifdef CONFIG_BRIDGE_NETFILTER
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 99abfb5..97c5b21 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -19,13 +19,15 @@
 
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_bridge.h>
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
-#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#endif
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
 static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
@@ -33,8 +35,10 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+#endif
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&
@@ -56,9 +60,11 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 {
 	struct sk_buff *reasm;
 
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	/* Previously seen (loopback)?	*/
 	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
+#endif
 
 	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
 	/* queued */
-- 
1.7.2.3

