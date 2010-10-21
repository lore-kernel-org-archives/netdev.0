From: kaber@trash.net
Subject: [PATCH 45/72] ipvs: switch to notrack mode
Date: Thu, 21 Oct 2010 17:19:32 +0200
Message-ID: <1287674399-31455-46-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab0JUPUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:13 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	Change skb->ipvs_property semantic. This is preparation
to support ip_vs_out processing in LOCAL_OUT. ipvs_property=1
will be used to avoid expensive lookups for traffic sent by
transmitters. Now when conntrack support is not used we call
ip_vs_notrack method to avoid problems in OUTPUT and
POST_ROUTING hooks instead of exiting POST_ROUTING as before.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   20 +++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_core.c |   39 ++++-----------------------------------
 net/netfilter/ipvs/ip_vs_xmit.c |    7 +++++--
 3 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index adcdba9..0e46184 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -25,7 +25,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>			/* for ipv6_addr_copy */
-#ifdef CONFIG_IP_VS_NFCT
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
@@ -1021,6 +1021,24 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
+/*
+ * Forget current conntrack (unconfirmed) and attach notrack entry
+ */
+static inline void ip_vs_notrack(struct sk_buff *skb)
+{
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+
+	if (!ct || !nf_ct_is_untracked(ct)) {
+		nf_reset(skb);
+		skb->nfct = &nf_ct_untracked_get()->ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+	}
+#endif
+}
+
 #ifdef CONFIG_IP_VS_NFCT
 /*
  *      Netfilter connection tracking
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e5fef7a..2224530 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -507,23 +507,6 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	return NF_DROP;
 }
 
-/*
- * It is hooked before NF_IP_PRI_NAT_SRC at the NF_INET_POST_ROUTING
- * chain and is used to avoid double NAT and confirmation when we do
- * not want to keep the conntrack structure
- */
-static unsigned int ip_vs_post_routing(unsigned int hooknum,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
-{
-	if (!skb->ipvs_property)
-		return NF_ACCEPT;
-	/* The packet was sent from IPVS, exit this chain */
-	return NF_STOP;
-}
-
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -682,8 +665,9 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	/* do the statistics and put it back */
 	ip_vs_out_stats(cp, skb);
 
+	skb->ipvs_property = 1;
 	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
 	verdict = NF_ACCEPT;
@@ -929,8 +913,9 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
+	skb->ipvs_property = 1;
 	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		skb->ipvs_property = 1;
+		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
 	ip_vs_conn_put(cp);
@@ -1496,14 +1481,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_FORWARD,
 		.priority       = 99,
 	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP_PRI_NAT_SRC-1,
-	},
 #ifdef CONFIG_IP_VS_IPV6
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
@@ -1532,14 +1509,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_FORWARD,
 		.priority       = 99,
 	},
-	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
-		.hook		= ip_vs_post_routing,
-		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
-		.hooknum        = NF_INET_POST_ROUTING,
-		.priority       = NF_IP6_PRI_NAT_SRC-1,
-	},
 #endif
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b0bd8af..94b53b4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -217,6 +217,7 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 ({								\
 	int __ret = NF_ACCEPT;					\
 								\
+	(skb)->ipvs_property = 1;				\
 	if (unlikely((cp)->flags & IP_VS_CONN_F_NFCT))		\
 		__ret = ip_vs_confirm_conntrack(skb, cp);	\
 	if (__ret == NF_ACCEPT) {				\
@@ -228,8 +229,9 @@ ip_vs_dst_reset(struct ip_vs_dest *dest)
 
 #define IP_VS_XMIT_NAT(pf, skb, cp)				\
 do {							\
+	(skb)->ipvs_property = 1;			\
 	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
 	else						\
 		ip_vs_update_conntrack(skb, cp, 1);	\
 	skb_forward_csum(skb);				\
@@ -239,8 +241,9 @@ do {							\
 
 #define IP_VS_XMIT(pf, skb, cp)				\
 do {							\
+	(skb)->ipvs_property = 1;			\
 	if (likely(!((cp)->flags & IP_VS_CONN_F_NFCT)))	\
-		(skb)->ipvs_property = 1;		\
+		ip_vs_notrack(skb);			\
 	skb_forward_csum(skb);				\
 	NF_HOOK(pf, NF_INET_LOCAL_OUT, (skb), NULL,	\
 		skb_dst(skb)->dev, dst_output);		\
-- 
1.7.1

