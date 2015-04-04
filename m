From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/9] netfilter: Pass nf_hook_state through
 nf_nat_ipv4_{in,out,fn,local_fn}().
Date: Fri, 03 Apr 2015 22:07:57 -0400 (EDT)
Message-ID: <20150403.220757.456995575501486517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbbDDCH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 22:07:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/netfilter/nf_nat_l3proto.h   | 24 ++++++++---------------
 net/ipv4/netfilter/iptable_nat.c         | 18 +++++++----------
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 33 +++++++++++++++-----------------
 net/ipv4/netfilter/nft_chain_nat_ipv4.c  | 14 ++++++--------
 4 files changed, 36 insertions(+), 53 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
index 340c013..e596f35 100644
--- a/include/net/netfilter/nf_nat_l3proto.h
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -44,40 +44,32 @@ int nf_nat_icmp_reply_translation(struct sk_buff *skb, struct nf_conn *ct,
 				  unsigned int hooknum);
 
 unsigned int nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			    const struct net_device *in,
-			    const struct net_device *out,
+			    const struct nf_hook_state *state,
 			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						     struct sk_buff *skb,
-						     const struct net_device *in,
-						     const struct net_device *out,
+						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
 unsigned int nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			     const struct net_device *in,
-			     const struct net_device *out,
+			     const struct nf_hook_state *state,
 			     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						      struct sk_buff *skb,
-						      const struct net_device *in,
-						      const struct net_device *out,
+						      const struct nf_hook_state *state,
 						      struct nf_conn *ct));
 
 unsigned int nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
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
 
 unsigned int nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
-			    const struct net_device *in,
-			    const struct net_device *out,
+			    const struct nf_hook_state *state,
 			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 						     struct sk_buff *skb,
-						     const struct net_device *in,
-						     const struct net_device *out,
+						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
 int nf_nat_icmpv6_reply_translation(struct sk_buff *skb, struct nf_conn *ct,
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 7a7fea4..086e231 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -30,45 +30,41 @@ static const struct xt_table nf_nat_ipv4_table = {
 
 static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
+					 const struct nf_hook_state *state,
 					 struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 
-	return ipt_do_table(skb, ops->hooknum, in, out, net->ipv4.nat_table);
+	return ipt_do_table(skb, ops->hooknum, state->in, state->out,
+			    net->ipv4.nat_table);
 }
 
 static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, state->in, state->out,
-			      iptable_nat_do_chain);
+	return nf_nat_ipv4_fn(ops, skb, state, iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_in(const struct nf_hook_ops *ops,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, state->in, state->out,
-			      iptable_nat_do_chain);
+	return nf_nat_ipv4_in(ops, skb, state, iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_out(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, state->in, state->out,
-			       iptable_nat_do_chain);
+	return nf_nat_ipv4_out(ops, skb, state, iptable_nat_do_chain);
 }
 
 static unsigned int iptable_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
 					      struct sk_buff *skb,
 					      const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, state->in, state->out,
-				    iptable_nat_do_chain);
+	return nf_nat_ipv4_local_fn(ops, skb, state, iptable_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index fc37711..e59cc05 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -256,11 +256,10 @@ EXPORT_SYMBOL_GPL(nf_nat_icmp_reply_translation);
 
 unsigned int
 nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
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
@@ -309,7 +308,7 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
-			ret = do_chain(ops, skb, in, out, ct);
+			ret = do_chain(ops, skb, state, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
 
@@ -323,7 +322,8 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 			pr_debug("Already setup manip %s for ct %p\n",
 				 maniptype == NF_NAT_MANIP_SRC ? "SRC" : "DST",
 				 ct);
-			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, out))
+			if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat,
+					       state->out))
 				goto oif_changed;
 		}
 		break;
@@ -332,7 +332,7 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo == IP_CT_ESTABLISHED ||
 			     ctinfo == IP_CT_ESTABLISHED_REPLY);
-		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, out))
+		if (nf_nat_oif_changed(ops->hooknum, ctinfo, nat, state->out))
 			goto oif_changed;
 	}
 
@@ -346,17 +346,16 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv4_fn);
 
 unsigned int
 nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
-	       const struct net_device *in, const struct net_device *out,
+	       const struct nf_hook_state *state,
 	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
+					 const struct nf_hook_state *state,
 					 struct nf_conn *ct))
 {
 	unsigned int ret;
 	__be32 daddr = ip_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    daddr != ip_hdr(skb)->daddr)
 		skb_dst_drop(skb);
@@ -367,11 +366,10 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv4_in);
 
 unsigned int
 nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		const struct net_device *in, const struct net_device *out,
+		const struct nf_hook_state *state,
 		unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
+					  const struct nf_hook_state *state,
 					  struct nf_conn *ct))
 {
 #ifdef CONFIG_XFRM
@@ -386,7 +384,7 @@ nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
@@ -410,11 +408,10 @@ EXPORT_SYMBOL_GPL(nf_nat_ipv4_out);
 
 unsigned int
 nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		     const struct net_device *in, const struct net_device *out,
+		     const struct nf_hook_state *state,
 		     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
 					       struct sk_buff *skb,
-					       const struct net_device *in,
-					       const struct net_device *out,
+					       const struct nf_hook_state *state,
 					       struct nf_conn *ct))
 {
 	const struct nf_conn *ct;
@@ -427,7 +424,7 @@ nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, do_chain);
+	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index d08db6b..f56bbb1 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -28,13 +28,12 @@
 
 static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
+				      const struct nf_hook_state *state,
 				      struct nf_conn *ct)
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
 
 	return nft_do_chain(&pkt, ops);
 }
@@ -43,29 +42,28 @@ static unsigned int nft_nat_ipv4_fn(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv4_fn(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_in(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv4_in(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_out(const struct nf_hook_ops *ops,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, state->in, state->out, nft_nat_do_chain);
+	return nf_nat_ipv4_out(ops, skb, state, nft_nat_do_chain);
 }
 
 static unsigned int nft_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, state->in, state->out,
-				    nft_nat_do_chain);
+	return nf_nat_ipv4_local_fn(ops, skb, state, nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv4 = {
-- 
2.1.0
