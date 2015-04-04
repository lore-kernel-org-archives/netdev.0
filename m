From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/9] netfilter: Pass nf_hook_state through
 nft_set_pktinfo*().
Date: Fri, 03 Apr 2015 22:08:18 -0400 (EDT)
Message-ID: <20150403.220818.2170078705464459092.davem@davemloft.net>
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
 include/net/netfilter/nf_tables.h         |  7 +++----
 include/net/netfilter/nf_tables_ipv4.h    |  5 ++---
 include/net/netfilter/nf_tables_ipv6.h    |  5 ++---
 net/bridge/netfilter/nf_tables_bridge.c   | 24 +++++++++++-------------
 net/ipv4/netfilter/nf_tables_arp.c        |  2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c       |  2 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |  2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |  2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c       |  2 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |  2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |  2 +-
 11 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index b8cd60d..8049819 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -26,12 +26,11 @@ struct nft_pktinfo {
 static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
 				   const struct nf_hook_ops *ops,
 				   struct sk_buff *skb,
-				   const struct net_device *in,
-				   const struct net_device *out)
+				   const struct nf_hook_state *state)
 {
 	pkt->skb = skb;
-	pkt->in = pkt->xt.in = in;
-	pkt->out = pkt->xt.out = out;
+	pkt->in = pkt->xt.in = state->in;
+	pkt->out = pkt->xt.out = state->out;
 	pkt->ops = ops;
 	pkt->xt.hooknum = ops->hooknum;
 	pkt->xt.family = ops->pf;
diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index cba143f..2df7f96 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -8,12 +8,11 @@ static inline void
 nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 		     const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out)
+		     const struct nf_hook_state *state)
 {
 	struct iphdr *ip;
 
-	nft_set_pktinfo(pkt, ops, skb, in, out);
+	nft_set_pktinfo(pkt, ops, skb, state);
 
 	ip = ip_hdr(pkt->skb);
 	pkt->tprot = ip->protocol;
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 74d9761..97db2e3 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -8,13 +8,12 @@ static inline int
 nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 		     const struct nf_hook_ops *ops,
 		     struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out)
+		     const struct nf_hook_state *state)
 {
 	int protohdr, thoff = 0;
 	unsigned short frag_off;
 
-	nft_set_pktinfo(pkt, ops, skb, in, out);
+	nft_set_pktinfo(pkt, ops, skb, state);
 
 	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
 	/* If malformed, drop it */
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 2c46a47..a343e62 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -67,27 +67,25 @@ EXPORT_SYMBOL_GPL(nft_bridge_ip6hdr_validate);
 static inline void nft_bridge_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 					       const struct nf_hook_ops *ops,
 					       struct sk_buff *skb,
-					       const struct net_device *in,
-					       const struct net_device *out)
+					       const struct nf_hook_state *state)
 {
 	if (nft_bridge_iphdr_validate(skb))
-		nft_set_pktinfo_ipv4(pkt, ops, skb, in, out);
+		nft_set_pktinfo_ipv4(pkt, ops, skb, state);
 	else
-		nft_set_pktinfo(pkt, ops, skb, in, out);
+		nft_set_pktinfo(pkt, ops, skb, state);
 }
 
 static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-					      const struct nf_hook_ops *ops,
-					      struct sk_buff *skb,
-					      const struct net_device *in,
-					      const struct net_device *out)
+					       const struct nf_hook_ops *ops,
+					       struct sk_buff *skb,
+					       const struct nf_hook_state *state)
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (nft_bridge_ip6hdr_validate(skb) &&
-	    nft_set_pktinfo_ipv6(pkt, ops, skb, in, out) == 0)
+	    nft_set_pktinfo_ipv6(pkt, ops, skb, state) == 0)
 		return;
 #endif
-	nft_set_pktinfo(pkt, ops, skb, in, out);
+	nft_set_pktinfo(pkt, ops, skb, state);
 }
 
 static unsigned int
@@ -99,13 +97,13 @@ nft_do_chain_bridge(const struct nf_hook_ops *ops,
 
 	switch (eth_hdr(skb)->h_proto) {
 	case htons(ETH_P_IP):
-		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
+		nft_bridge_set_pktinfo_ipv4(&pkt, ops, skb, state);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out);
+		nft_bridge_set_pktinfo_ipv6(&pkt, ops, skb, state);
 		break;
 	default:
-		nft_set_pktinfo(&pkt, ops, skb, state->in, state->out);
+		nft_set_pktinfo(&pkt, ops, skb, state);
 		break;
 	}
 
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index fceb50e..8412268 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -21,7 +21,7 @@ nft_do_chain_arp(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo(&pkt, ops, skb, state->in, state->out);
+	nft_set_pktinfo(&pkt, ops, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 708e388..aa180d3 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -24,7 +24,7 @@ static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index f56bbb1..bf5c30a 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -33,7 +33,7 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 073d077..e335b0a 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -37,7 +37,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	nft_set_pktinfo_ipv4(&pkt, ops, skb, state->in, state->out);
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, state);
 
 	mark = skb->mark;
 	iph = ip_hdr(skb);
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 224bc89..c8148ba 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -23,7 +23,7 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 	struct nft_pktinfo pkt;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state) < 0)
 		return NF_DROP;
 
 	return nft_do_chain(&pkt, ops);
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index 11c6f75..951bb45 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -31,7 +31,7 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 {
 	struct nft_pktinfo pkt;
 
-	nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out);
+	nft_set_pktinfo_ipv6(&pkt, ops, skb, state);
 
 	return nft_do_chain(&pkt, ops);
 }
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index c826c3c..0dafdaa 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -33,7 +33,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	u32 mark, flowlabel;
 
 	/* malformed packet, drop it */
-	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state->in, state->out) < 0)
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, state) < 0)
 		return NF_DROP;
 
 	/* save source/dest address, mark, hoplimit, flowlabel, priority */
-- 
2.1.0

