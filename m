From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/27] netfilter: add and use nf_ct_set helper
Date: Fri,  3 Feb 2017 13:25:34 +0100
Message-ID: <1486124738-3013-24-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59044 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753348AbdBCM24 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:56 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 0EBC16C23
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:45 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F075CDA817
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:44 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7BAA2DA84B
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:42 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Add a helper to assign a nf_conn entry and the ctinfo bits to an sk_buff.
This avoids changing code in followup patch that merges skb->nfct and
skb->nfctinfo into skb->_nfct.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h                            |  3 +--
 include/net/netfilter/nf_conntrack.h           |  8 ++++++++
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  3 +--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  3 +--
 net/ipv4/netfilter/nf_dup_ipv4.c               |  3 +--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  3 +--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  6 ++----
 net/ipv6/netfilter/nf_dup_ipv6.c               |  3 +--
 net/netfilter/nf_conntrack_core.c              | 11 +++--------
 net/netfilter/nft_ct.c                         |  3 +--
 net/netfilter/xt_CT.c                          |  6 ++----
 net/openvswitch/conntrack.c                    |  6 ++----
 12 files changed, 24 insertions(+), 34 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2a344ebd7ebe..4b46c591b542 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1559,8 +1559,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 		nf_conntrack_put(&ct->ct_general);
 		untracked = nf_ct_untracked_get();
 		nf_conntrack_get(&untracked->ct_general);
-		skb->nfct = &untracked->ct_general;
-		skb->nfctinfo = IP_CT_NEW;
+		nf_ct_set(skb, untracked, IP_CT_NEW);
 	}
 #endif
 }
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 5916aa9ab3f0..d704aed11684 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -34,6 +34,7 @@ union nf_conntrack_proto {
 	struct ip_ct_sctp sctp;
 	struct ip_ct_tcp tcp;
 	struct nf_ct_gre gre;
+	unsigned int tmpl_padto;
 };
 
 union nf_conntrack_expect_proto {
@@ -341,6 +342,13 @@ struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 				 gfp_t flags);
 void nf_ct_tmpl_free(struct nf_conn *tmpl);
 
+static inline void
+nf_ct_set(struct sk_buff *skb, struct nf_conn *ct, enum ip_conntrack_info info)
+{
+	skb->nfct = &ct->ct_general;
+	skb->nfctinfo = info;
+}
+
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_ADD_ATOMIC(net, count, v) this_cpu_add((net)->ct.stat->count, (v))
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index a12d4f0aa674..3240a2614e82 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -57,8 +57,7 @@ synproxy_send_tcp(struct net *net,
 		goto free_nskb;
 
 	if (nfct) {
-		nskb->nfct = nfct;
-		nskb->nfctinfo = ctinfo;
+		nf_ct_set(nskb, (struct nf_conn *)nfct, ctinfo);
 		nf_conntrack_get(nfct);
 	}
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 478a025909fc..73c591d8a9a8 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -172,8 +172,7 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 		ctinfo += IP_CT_IS_REPLY;
 
 	/* Update skb to refer to this connection */
-	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = ctinfo;
+	nf_ct_set(skb, nf_ct_tuplehash_to_ctrack(h), ctinfo);
 	return NF_ACCEPT;
 }
 
diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index 1a5e1f53ceaa..f0dbff05fc28 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -69,8 +69,7 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_reset(skb);
-	skb->nfct     = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
 	nf_conntrack_get(skb_nfct(skb));
 #endif
 	/*
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 2dc01d2c6ec0..4ef1ddd4bbbd 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -71,8 +71,7 @@ synproxy_send_tcp(struct net *net,
 	skb_dst_set(nskb, dst);
 
 	if (nfct) {
-		nskb->nfct = nfct;
-		nskb->nfctinfo = ctinfo;
+		nf_ct_set(nskb, (struct nf_conn *)nfct, ctinfo);
 		nf_conntrack_get(nfct);
 	}
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 09f1661a4e88..d2c2ccbfbe72 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -189,8 +189,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* Update skb to refer to this connection */
-	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-	skb->nfctinfo = ctinfo;
+	nf_ct_set(skb, nf_ct_tuplehash_to_ctrack(h), ctinfo);
 	return NF_ACCEPT;
 }
 
@@ -222,8 +221,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type = icmp6h->icmp6_type - 130;
 	if (type >= 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		skb->nfct = &nf_ct_untracked_get()->ct_general;
-		skb->nfctinfo = IP_CT_NEW;
+		nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
 		nf_conntrack_get(skb_nfct(skb));
 		return NF_ACCEPT;
 	}
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_dup_ipv6.c
index 5f52e5f90e7e..ff04f6a7f45b 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -58,8 +58,7 @@ void nf_dup_ipv6(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_reset(skb);
-	skb->nfct     = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
 	nf_conntrack_get(skb->nfct);
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING ||
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 78aebf0ee6e3..c9bd10747864 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -691,10 +691,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 
 		nf_ct_acct_merge(ct, ctinfo, loser_ct);
 		nf_conntrack_put(&loser_ct->ct_general);
-		/* Assign conntrack already in hashes to this skbuff. Don't
-		 * modify skb->nfctinfo to ensure consistent stateful filtering.
-		 */
-		skb->nfct = &ct->ct_general;
+		nf_ct_set(skb, ct, oldinfo);
 		return NF_ACCEPT;
 	}
 	NF_CT_STAT_INC(net, drop);
@@ -1282,8 +1279,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		}
 		*set_reply = 0;
 	}
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = *ctinfo;
+	nf_ct_set(skb, ct, *ctinfo);
 	return ct;
 }
 
@@ -1526,8 +1522,7 @@ static void nf_conntrack_attach(struct sk_buff *nskb, const struct sk_buff *skb)
 		ctinfo = IP_CT_RELATED;
 
 	/* Attach to new skbuff, and increment count */
-	nskb->nfct = &ct->ct_general;
-	nskb->nfctinfo = ctinfo;
+	nf_ct_set(nskb, ct, ctinfo);
 	nf_conntrack_get(skb_nfct(nskb));
 }
 
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index d774d7823688..66a2377510e1 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -554,8 +554,7 @@ static void nft_notrack_eval(const struct nft_expr *expr,
 
 	ct = nf_ct_untracked_get();
 	atomic_inc(&ct->ct_general.use);
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	nf_ct_set(skb, ct, IP_CT_NEW);
 }
 
 static struct nft_expr_type nft_notrack_type;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index cd7e29910ae1..51f00e1e1208 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -30,8 +30,7 @@ static inline int xt_ct_target(struct sk_buff *skb, struct nf_conn *ct)
 	if (!ct)
 		ct = nf_ct_untracked_get();
 	atomic_inc(&ct->ct_general.use);
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	nf_ct_set(skb, ct, IP_CT_NEW);
 
 	return XT_CONTINUE;
 }
@@ -413,8 +412,7 @@ notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (skb->nfct != NULL)
 		return XT_CONTINUE;
 
-	skb->nfct = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
+	nf_ct_set(skb, nf_ct_untracked_get(), IP_CT_NEW);
 	nf_conntrack_get(skb_nfct(skb));
 
 	return XT_CONTINUE;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 452557946147..d1fbfcaa009a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -460,8 +460,7 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
-	skb->nfct = &ct->ct_general;
-	skb->nfctinfo = ovs_ct_get_info(h);
+	nf_ct_set(skb, ct, ovs_ct_get_info(h));
 	return ct;
 }
 
@@ -724,8 +723,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			if (skb_nfct(skb))
 				nf_conntrack_put(skb_nfct(skb));
 			nf_conntrack_get(&tmpl->ct_general);
-			skb->nfct = &tmpl->ct_general;
-			skb->nfctinfo = IP_CT_NEW;
+			nf_ct_set(skb, tmpl, IP_CT_NEW);
 		}
 
 		err = nf_conntrack_in(net, info->family,
-- 
2.1.4
