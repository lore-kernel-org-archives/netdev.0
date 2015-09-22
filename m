From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/30] inet netfilter: Prefer state->hook to ops->hooknum
Date: Tue, 22 Sep 2015 11:14:08 +0200
Message-ID: <1442913260-3925-19-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

The values of nf_hook_state.hook and nf_hook_ops.hooknum must be the
same by definition.

We are more likely to access the fields in nf_hook_state over the
fields in nf_hook_ops so with a little luck this results in
fewer cache line misses, and slightly more consistent code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 ++--
 net/ipv4/netfilter/nf_defrag_ipv4.c            |    2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |   14 +++++++-------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |    4 ++--
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |   14 +++++++-------
 6 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 9564684..15749cc 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -147,7 +147,7 @@ static unsigned int ipv4_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(state->net, PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET, state->hook, skb);
 }
 
 static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
@@ -158,7 +158,7 @@ static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	return nf_conntrack_in(state->net, PF_INET, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET, state->hook, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 9306ec4..8aea536 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -83,7 +83,7 @@ static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
 	/* Gather fragments. */
 	if (ip_is_fragment(ip_hdr(skb))) {
 		enum ip_defrag_users user =
-			nf_ct_defrag_user(ops->hooknum, skb);
+			nf_ct_defrag_user(state->hook, skb);
 
 		if (nf_ct_ipv4_gather_frags(skb, user))
 			return NF_STOLEN;
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 22f4579..16da45a 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -266,7 +266,7 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn_nat *nat;
 	/* maniptype == SRC for postrouting. */
-	enum nf_nat_manip_type maniptype = HOOK2MANIP(ops->hooknum);
+	enum nf_nat_manip_type maniptype = HOOK2MANIP(state->hook);
 
 	/* We never see fragments: conntrack defrags on pre-routing
 	 * and local-out, and nf_nat_out protects post-routing.
@@ -295,7 +295,7 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	case IP_CT_RELATED_REPLY:
 		if (ip_hdr(skb)->protocol == IPPROTO_ICMP) {
 			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
-							   ops->hooknum))
+							   state->hook))
 				return NF_DROP;
 			else
 				return NF_ACCEPT;
@@ -312,17 +312,17 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 			if (ret != NF_ACCEPT)
 				return ret;
 
-			if (nf_nat_initialized(ct, HOOK2MANIP(ops->hooknum)))
+			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook)))
 				break;
 
-			ret = nf_nat_alloc_null_binding(ct, ops->hooknum);
+			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
 				return ret;
 		} else {
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
-			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat,
+			if (nf_nat_oif_changed(state->hook, ctinfo, nat,
 					       state->out))
 				goto oif_changed;
 		}
@@ -332,11 +332,11 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
+		if (nf_nat_oif_changed(state->hook, ctinfo, nat, state->out))
 			goto oif_changed;
 	}
 
-	return nf_nat_packet(ct, ctinfo, ops->hooknum, skb);
+	return nf_nat_packet(ct, ctinfo, state->hook, skb);
 
 oif_changed:
 	nf_ct_kill_acct(ct, ctinfo, skb);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 1ef1b79..339be1d 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -169,7 +169,7 @@ static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
-	return nf_conntrack_in(state->net, PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET6, state->hook, skb);
 }
 
 static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
@@ -181,7 +181,7 @@ static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
 		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(state->net, PF_INET6, ops->hooknum, skb);
+	return nf_conntrack_in(state->net, PF_INET6, state->hook, skb);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 6b576be..a9c0852 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -63,7 +63,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 #endif
 
-	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(ops->hooknum, skb));
+	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(state->hook, skb));
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
@@ -74,7 +74,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	nf_ct_frag6_consume_orig(reasm);
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->net, state->sk, reasm,
+	NF_HOOK_THRESH(NFPROTO_IPV6, state->hook, state->net, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 70fbaed..8bc9490 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -272,7 +272,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn_nat *nat;
-	enum nf_nat_manip_type maniptype = HOOK2MANIP(ops->hooknum);
+	enum nf_nat_manip_type maniptype = HOOK2MANIP(state->hook);
 	__be16 frag_off;
 	int hdrlen;
 	u8 nexthdr;
@@ -303,7 +303,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 		if (hdrlen >= 0 && nexthdr == IPPROTO_ICMPV6) {
 			if (!nf_nat_icmpv6_reply_translation(skb, ct, ctinfo,
-							     ops->hooknum,
+							     state->hook,
 							     hdrlen))
 				return NF_DROP;
 			else
@@ -321,17 +321,17 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 			if (ret != NF_ACCEPT)
 				return ret;
 
-			if (nf_nat_initialized(ct, HOOK2MANIP(ops->hooknum)))
+			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook)))
 				break;
 
-			ret = nf_nat_alloc_null_binding(ct, ops->hooknum);
+			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
 				return ret;
 		} else {
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
-			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
+			if (nf_nat_oif_changed(state->hook, ctinfo, nat, state->out))
 				goto oif_changed;
 		}
 		break;
@@ -340,11 +340,11 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
+		if (nf_nat_oif_changed(state->hook, ctinfo, nat, state->out))
 			goto oif_changed;
 	}
 
-	return nf_nat_packet(ct, ctinfo, ops->hooknum, skb);
+	return nf_nat_packet(ct, ctinfo, state->hook, skb);
 
 oif_changed:
 	nf_ct_kill_acct(ct, ctinfo, skb);
-- 
1.7.10.4

