From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/9] netfilter: Pass nf_hook_state through
 nf_nat_ipv6_{in,out,fn,local_fn}().
Date: Fri, 03 Apr 2015 22:08:08 -0400 (EDT)
Message-ID: <20150403.220808.908770641345903536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netfilter/nf_nat_l3proto.h   | 24 ++++++++----------------
 net/ipv6/netfilter/ip6table_nat.c        | 18 +++++++-----------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 32 ++++++++++++++------------------
 net/ipv6/netfilter/nft_chain_nat_ipv6.c  | 13 ++++++-------
 4 files changed, 35 insertions(+), 52 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
index e596f35..a312732 100644
--- a/include/net/netfilter/nf_nat_l3proto.h
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -77,40 +77,32 @@ int nf_nat_icmpv6_reply_translation(struct sk_buff *skb, struct nf_conn *ct,
 				    unsigned int hooknum, unsigned int hdrlen);
 
 unsigned int nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			    const struct net_device *in,
-			    const struct net_device *out,
+			    const struct nf_hook_state *state,
 			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						     struct sk_buff *skb,
-						     const struct net_device *in,
-						     const struct net_device *out,
+						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
 unsigned int nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			     const struct net_device *in,
-			     const struct net_device *out,
+			     const struct nf_hook_state *state,
 			     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						      struct sk_buff *skb,
-						      const struct net_device *in,
-						      const struct net_device *out,
+						      const struct nf_hook_state *state,
 						      struct nf_conn *ct));
 
 unsigned int nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
 				  struct sk_buff *skb,
-				  const struct net_device *in,
-				  const struct net_device *out,
+				  const struct nf_hook_state *state,
 				  unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 							   struct sk_buff *skb,
-							   const struct net_device *in,
-							   const struct net_device *out,
+							   const struct nf_hook_state *state,
 							   struct nf_conn *ct));
 
 unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			    const struct net_device *in,
-			    const struct net_device *out,
+			    const struct nf_hook_state *state,
 			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						     struct sk_buff *skb,
-						     const struct net_device *in,
-						     const struct net_device *out,
+						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
 #endif /* _NF_NAT_L3PROTO_H */
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index e32b0d0..d78f69c 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -32,45 +32,41 @@ static const struct xt_table nf_nat_ipv6_table = {
 
 static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
+					  const struct nf_hook_state *state,
 					  struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 
-	return ip6t_do_table(skb, ops->hooknum, in, out, net->ipv6.ip6table_nat);
+	return ip6t_do_table(skb, ops->hooknum, state->in, state->out,
+			     net->ipv6.ip6table_nat);
 }
 
 static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, state->in, state->out,
-			      ip6table_nat_do_chain);
+	return nf_nat_ipv6_fn(ops, skb, state, ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, state->in, state->out,
-			      ip6table_nat_do_chain);
+	return nf_nat_ipv6_in(ops, skb, state, ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, state->in, state->out,
-			       ip6table_nat_do_chain);
+	return nf_nat_ipv6_out(ops, skb, state, ip6table_nat_do_chain);
 }
 
 static unsigned int ip6table_nat_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, state->in, state->out,
-				    ip6table_nat_do_chain);
+	return nf_nat_ipv6_local_fn(ops, skb, state, ip6table_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index c5812e1..e76900e 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -263,11 +263,10 @@ EXPORT_SYMBOL_GPL(nf_nat_icmpv6_reply_translation);
 
 unsigned int
 nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	       const struct net_device *in, const struct net_device *out,
+	       const struct nf_hook_state *state,
 	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
+					const struct nf_hook_state *state,
 					struct nf_conn *ct))
 {
 	struct nf_conn *ct;
@@ -318,7 +317,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
-			ret = do_chain(ops, skb, in, out, ct);
+			ret = do_chain(ops, skb, state, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
 
@@ -332,7 +331,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
-			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, out))
+			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
 				goto oif_changed;
 		}
 		break;
@@ -341,7 +340,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, out))
+		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
 			goto oif_changed;
 	}
 
@@ -355,17 +354,16 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv6_fn);
 
 unsigned int
 nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	       const struct net_device *in, const struct net_device *out,
+	       const struct nf_hook_state *state,
 	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
+					const struct nf_hook_state *state,
 					struct nf_conn *ct))
 {
 	unsigned int ret;
 	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
 		skb_dst_drop(skb);
@@ -376,11 +374,10 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv6_in);
 
 unsigned int
 nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		const struct net_device *in, const struct net_device *out,
+		const struct nf_hook_state *state,
 		unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
+					 const struct nf_hook_state *state,
 					 struct nf_conn *ct))
 {
 #ifdef CONFIG_XFRM
@@ -394,7 +391,7 @@ nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -418,11 +415,10 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv6_out);
 
 unsigned int
 nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
+		     const struct nf_hook_state *state,
 		     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					      struct sk_buff *skb,
-					      const struct net_device *in,
-					      const struct net_device *out,
+					      const struct nf_hook_state *state,
 					      struct nf_conn *ct))
 {
 	const struct nf_conn *ct;
@@ -434,7 +430,7 @@ nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index f73f4ae..11c6f75 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -26,13 +26,12 @@
 
 static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
+				     const struct nf_hook_state *state,
 				     struct nf_conn *ct)
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out);
+	nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out);
 
 	return nft_do_chain(&pkt, ops);
 }
@@ -41,28 +40,28 @@ static unsigned int nft_nat_ipv6_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv6_fn(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv6_in(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv6_out(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv6_local_fn(ops, skb, state, nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv6 = {
-- 
2.1.0

