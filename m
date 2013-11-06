From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] netfilter: push reasm skb through instead of original frag skbs
Date: Wed,  6 Nov 2013 17:52:20 +0100
Message-ID: <1383756740-7392-3-git-send-email-jiri@resnulli.us>
References: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:55696 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab3KFQwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 11:52:32 -0500
Received: by mail-ea0-f180.google.com with SMTP id b11so1154835eae.25
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 08:52:31 -0800 (PST)
In-Reply-To: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pushing original fragments through causes several problems. For example
for matching, frags may not be matched correctly. Take following
example:

<example>
On HOSTA do:
ip6tables -I INPUT -p icmpv6 -j DROP
ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT

and on HOSTB you do:
ping6 HOSTA -s2000    (MTU is 1500)

Incoming echo requests will be filtered out on HOSTA. This issue does
not occur with smaller packets than MTU (where fragmentation does not happen)
</example>

As was discussed previously, the only correct solution seems to be to use
reassembled skb instead of separete frags. Doing this has positive side
effects in reducing sk_buff by one pointer (nfct_reasm) and also the reams
dances in ipvs and conntrack can be removed.

Future plan is to remove net/ipv6/netfilter/nf_conntrack_reasm.c
entirely and use code in net/ipv6/reassembly.c instead.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/skbuff.h                         | 32 ---------------
 include/net/ip_vs.h                            | 32 +--------------
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |  4 +-
 net/core/skbuff.c                              |  3 --
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 56 +-------------------------
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 19 +--------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  7 +++-
 net/netfilter/ipvs/ip_vs_core.c                | 55 +------------------------
 net/netfilter/ipvs/ip_vs_pe_sip.c              |  8 +---
 9 files changed, 13 insertions(+), 203 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e153b6..8351614 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -337,11 +337,6 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
 
-#if defined(CONFIG_NF_DEFRAG_IPV4) || defined(CONFIG_NF_DEFRAG_IPV4_MODULE) || \
-    defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
-#define NET_SKBUFF_NF_DEFRAG_NEEDED 1
-#endif
-
 /** 
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -374,7 +369,6 @@ typedef unsigned char *sk_buff_data_t;
  *	@protocol: Packet protocol from driver
  *	@destructor: Destruct function
  *	@nfct: Associated connection, if any
- *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
@@ -463,9 +457,6 @@ struct sk_buff {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct nf_conntrack	*nfct;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	struct sk_buff		*nfct_reasm;
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct nf_bridge_info	*nf_bridge;
 #endif
@@ -2594,18 +2585,6 @@ static inline void nf_conntrack_get(struct nf_conntrack *nfct)
 		atomic_inc(&nfct->use);
 }
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
-{
-	if (skb)
-		atomic_inc(&skb->users);
-}
-static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
-{
-	if (skb)
-		kfree_skb(skb);
-}
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
 {
@@ -2624,10 +2603,6 @@ static inline void nf_reset(struct sk_buff *skb)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(skb->nfct_reasm);
-	skb->nfct_reasm = NULL;
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(skb->nf_bridge);
 	skb->nf_bridge = NULL;
@@ -2649,10 +2624,6 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	nf_conntrack_get(src->nfct);
 	dst->nfctinfo = src->nfctinfo;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	dst->nfct_reasm = src->nfct_reasm;
-	nf_conntrack_get_reasm(src->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	dst->nf_bridge  = src->nf_bridge;
 	nf_bridge_get(src->nf_bridge);
@@ -2664,9 +2635,6 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	nf_conntrack_put(dst->nfct);
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(dst->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(dst->nf_bridge);
 #endif
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cd7275f..5679d92 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -109,7 +109,6 @@ extern int ip_vs_conn_tab_size;
 struct ip_vs_iphdr {
 	__u32 len;	/* IPv4 simply where L4 starts
 			   IPv6 where L4 Transport Header starts */
-	__u32 thoff_reasm; /* Transport Header Offset in nfct_reasm skb */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag)*/
 	__s16 protocol;
 	__s32 flags;
@@ -117,34 +116,12 @@ struct ip_vs_iphdr {
 	union nf_inet_addr daddr;
 };
 
-/* Dependency to module: nf_defrag_ipv6 */
-#if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
-static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
-{
-	return skb->nfct_reasm;
-}
-static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
-				      int len, void *buffer,
-				      const struct ip_vs_iphdr *ipvsh)
-{
-	if (unlikely(ipvsh->fragoffs && skb_nfct_reasm(skb)))
-		return skb_header_pointer(skb_nfct_reasm(skb),
-					  ipvsh->thoff_reasm, len, buffer);
-
-	return skb_header_pointer(skb, offset, len, buffer);
-}
-#else
-static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
-{
-	return NULL;
-}
 static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int offset,
 				      int len, void *buffer,
 				      const struct ip_vs_iphdr *ipvsh)
 {
 	return skb_header_pointer(skb, offset, len, buffer);
 }
-#endif
 
 static inline void
 ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
@@ -171,19 +148,12 @@ ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *iphdr)
 			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
-		/* ipv6_find_hdr() updates len, flags, thoff_reasm */
-		iphdr->thoff_reasm = 0;
+		/* ipv6_find_hdr() updates len, flags */
 		iphdr->len	 = 0;
 		iphdr->flags	 = 0;
 		iphdr->protocol  = ipv6_find_hdr(skb, &iphdr->len, -1,
 						 &iphdr->fragoffs,
 						 &iphdr->flags);
-		/* get proto from re-assembled packet and it's offset */
-		if (skb_nfct_reasm(skb))
-			iphdr->protocol = ipv6_find_hdr(skb_nfct_reasm(skb),
-							&iphdr->thoff_reasm,
-							-1, NULL, NULL);
-
 	} else
 #endif
 	{
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index 5613412..27666d8 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -6,9 +6,7 @@ void nf_defrag_ipv6_enable(void);
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
 struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
-void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
-			struct net_device *in, struct net_device *out,
-			int (*okfn)(struct sk_buff *));
+void nf_ct_frag6_consume_orig(struct sk_buff *skb);
 
 struct inet_frags_ctl;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3735fad..e55e10a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -592,9 +592,6 @@ static void skb_release_head_state(struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(skb->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(skb->nf_bridge);
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 486545e..4cbc6b2 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -169,64 +169,13 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int __ipv6_conntrack_in(struct net *net,
-					unsigned int hooknum,
-					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm = skb->nfct_reasm;
-	const struct nf_conn_help *help;
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-
-	/* This packet is fragmented and has reassembled packet. */
-	if (reasm) {
-		/* Reassembled packet isn't parsed yet ? */
-		if (!reasm->nfct) {
-			unsigned int ret;
-
-			ret = nf_conntrack_in(net, PF_INET6, hooknum, reasm);
-			if (ret != NF_ACCEPT)
-				return ret;
-		}
-
-		/* Conntrack helpers need the entire reassembled packet in the
-		 * POST_ROUTING hook. In case of unconfirmed connections NAT
-		 * might reassign a helper, so the entire packet is also
-		 * required.
-		 */
-		ct = nf_ct_get(reasm, &ctinfo);
-		if (ct != NULL && !nf_ct_is_untracked(ct)) {
-			help = nfct_help(ct);
-			if ((help && help->helper) || !nf_ct_is_confirmed(ct)) {
-				nf_conntrack_get_reasm(reasm);
-				NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
-					       (struct net_device *)in,
-					       (struct net_device *)out,
-					       okfn, NF_IP6_PRI_CONNTRACK + 1);
-				return NF_DROP_ERR(-ECANCELED);
-			}
-		}
-
-		nf_conntrack_get(reasm->nfct);
-		skb->nfct = reasm->nfct;
-		skb->nfctinfo = reasm->nfctinfo;
-		return NF_ACCEPT;
-	}
-
-	return nf_conntrack_in(net, PF_INET6, hooknum, skb);
-}
-
 static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return __ipv6_conntrack_in(dev_net(in), ops->hooknum, skb, in, out,
-				   okfn);
+	return nf_conntrack_in(dev_net(in), PF_INET6, ops->hooknum, skb);
 }
 
 static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
@@ -240,8 +189,7 @@ static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
 		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return __ipv6_conntrack_in(dev_net(out), ops->hooknum, skb, in, out,
-				   okfn);
+	return nf_conntrack_in(dev_net(out), PF_INET6, ops->hooknum, skb);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 4a25826..767ab8d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -633,31 +633,16 @@ ret_orig:
 	return skb;
 }
 
-void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
-			struct net_device *in, struct net_device *out,
-			int (*okfn)(struct sk_buff *))
+void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 {
 	struct sk_buff *s, *s2;
-	unsigned int ret = 0;
 
 	for (s = NFCT_FRAG6_CB(skb)->orig; s;) {
-		nf_conntrack_put_reasm(s->nfct_reasm);
-		nf_conntrack_get_reasm(skb);
-		s->nfct_reasm = skb;
-
 		s2 = s->next;
 		s->next = NULL;
-
-		if (ret != -ECANCELED)
-			ret = NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s,
-					     in, out, okfn,
-					     NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
-		else
-			kfree_skb(s);
-
+		consume_skb(s);
 		s = s2;
 	}
-	nf_conntrack_put_reasm(skb);
 }
 
 static int nf_ct_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index ec483aa..7b9a748 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -75,8 +75,11 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 	if (reasm == skb)
 		return NF_ACCEPT;
 
-	nf_ct_frag6_output(ops->hooknum, reasm, (struct net_device *)in,
-			   (struct net_device *)out, okfn);
+	nf_ct_frag6_consume_orig(reasm);
+
+	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, reasm,
+		       (struct net_device *) in, (struct net_device *) out,
+		       okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
 	return NF_STOLEN;
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 34fda62..4f26ee4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1139,12 +1139,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
-			struct sk_buff *reasm = skb_nfct_reasm(skb);
-			/* Save fw mark for coming frags */
-			reasm->ipvs_property = 1;
-			reasm->mark = skb->mark;
-		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_out_icmp_v6(skb, &related,
@@ -1614,12 +1608,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6) {
-		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
-			struct sk_buff *reasm = skb_nfct_reasm(skb);
-			/* Save fw mark for coming frags. */
-			reasm->ipvs_property = 1;
-			reasm->mark = skb->mark;
-		}
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related;
 			int verdict = ip_vs_in_icmp_v6(skb, &related, hooknum,
@@ -1671,9 +1659,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		/* sorry, all this trouble for a no-hit :) */
 		IP_VS_DBG_PKT(12, af, pp, skb, 0,
 			      "ip_vs_in: packet continues traversal as normal");
-		if (iph.fragoffs && !skb_nfct_reasm(skb)) {
+		if (iph.fragoffs) {
 			/* Fragment that couldn't be mapped to a conn entry
-			 * and don't have any pointer to a reasm skb
 			 * is missing module nf_defrag_ipv6
 			 */
 			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
@@ -1756,38 +1743,6 @@ ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
 
 /*
- * AF_INET6 fragment handling
- * Copy info from first fragment, to the rest of them.
- */
-static unsigned int
-ip_vs_preroute_frag6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm = skb_nfct_reasm(skb);
-	struct net *net;
-
-	/* Skip if not a "replay" from nf_ct_frag6_output or first fragment.
-	 * ipvs_property is set when checking first fragment
-	 * in ip_vs_in() and ip_vs_out().
-	 */
-	if (reasm)
-		IP_VS_DBG(2, "Fragment recv prop:%d\n", reasm->ipvs_property);
-	if (!reasm || !reasm->ipvs_property)
-		return NF_ACCEPT;
-
-	net = skb_net(skb);
-	if (!net_ipvs(net)->enable)
-		return NF_ACCEPT;
-
-	/* Copy stored fw mark, saved in ip_vs_{in,out} */
-	skb->mark = reasm->mark;
-
-	return NF_ACCEPT;
-}
-
-/*
  *	AF_INET6 handler in NF_INET_LOCAL_IN chain
  *	Schedule and forward packets from remote clients
  */
@@ -1924,14 +1879,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.priority	= 100,
 	},
 #ifdef CONFIG_IP_VS_IPV6
-	/* After mangle & nat fetch 2:nd fragment and following */
-	{
-		.hook		= ip_vs_preroute_frag6,
-		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_PRE_ROUTING,
-		.priority	= NF_IP6_PRI_NAT_DST + 1,
-	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 9ef22bd..bed5f70 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -65,7 +65,6 @@ static int get_callid(const char *dptr, unsigned int dataoff,
 static int
 ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 {
-	struct sk_buff *reasm = skb_nfct_reasm(skb);
 	struct ip_vs_iphdr iph;
 	unsigned int dataoff, datalen, matchoff, matchlen;
 	const char *dptr;
@@ -79,15 +78,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	/* todo: IPv6 fragments:
 	 *       I think this only should be done for the first fragment. /HS
 	 */
-	if (reasm) {
-		skb = reasm;
-		dataoff = iph.thoff_reasm + sizeof(struct udphdr);
-	} else
-		dataoff = iph.len + sizeof(struct udphdr);
+	dataoff = iph.len + sizeof(struct udphdr);
 
 	if (dataoff >= skb->len)
 		return -EINVAL;
-	/* todo: Check if this will mess-up the reasm skb !!! /HS */
 	retc = skb_linearize(skb);
 	if (retc < 0)
 		return retc;
-- 
1.8.3.1
