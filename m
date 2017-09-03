From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 40/47] netfilter: fix a few (harmless) sparse warnings
Date: Mon,  4 Sep 2017 00:42:47 +0200
Message-ID: <1504478574-13281-5-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

net/netfilter/nft_payload.c:187:18: warning: incorrect type in return expression (expected bool got restricted __sum16 [usertype] check)
net/netfilter/nft_exthdr.c:222:14: warning: cast to restricted __be32
net/netfilter/nft_rt.c:49:23: warning: incorrect type in assignment (different base types expected unsigned int got restricted __be32)
net/netfilter/nft_rt.c:70:25: warning: symbol 'nft_rt_policy' was not declared. Should it be static?

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_exthdr.c  | 2 +-
 net/netfilter/nft_payload.c | 2 +-
 net/netfilter/nft_rt.c      | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index f5a0bf5e3bdd..a0a93d987a3b 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -388,7 +388,7 @@ nft_exthdr_select_ops(const struct nft_ctx *ctx,
 	if (tb[NFTA_EXTHDR_SREG] && tb[NFTA_EXTHDR_DREG])
 		return ERR_PTR(-EOPNOTSUPP);
 
-	op = ntohl(nla_get_u32(tb[NFTA_EXTHDR_OP]));
+	op = ntohl(nla_get_be32(tb[NFTA_EXTHDR_OP]));
 	switch (op) {
 	case NFT_EXTHDR_OP_TCPOPT:
 		if (tb[NFTA_EXTHDR_SREG])
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 7d699bbd45b0..e110b0ebbf58 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -184,7 +184,7 @@ static bool nft_payload_udp_checksum(struct sk_buff *skb, unsigned int thoff)
 	if (!uh)
 		return false;
 
-	return uh->check;
+	return (__force bool)uh->check;
 }
 
 static int nft_payload_l4csum_offset(const struct nft_pktinfo *pkt,
diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
index e142e65d3176..61fd3acaa3c9 100644
--- a/net/netfilter/nft_rt.c
+++ b/net/netfilter/nft_rt.c
@@ -82,8 +82,8 @@ static void nft_rt_get_eval(const struct nft_expr *expr,
 		if (nft_pf(pkt) != NFPROTO_IPV4)
 			goto err;
 
-		*dest = rt_nexthop((const struct rtable *)dst,
-				   ip_hdr(skb)->daddr);
+		*dest = (__force u32)rt_nexthop((const struct rtable *)dst,
+						ip_hdr(skb)->daddr);
 		break;
 	case NFT_RT_NEXTHOP6:
 		if (nft_pf(pkt) != NFPROTO_IPV6)
@@ -106,7 +106,7 @@ static void nft_rt_get_eval(const struct nft_expr *expr,
 	regs->verdict.code = NFT_BREAK;
 }
 
-const struct nla_policy nft_rt_policy[NFTA_RT_MAX + 1] = {
+static const struct nla_policy nft_rt_policy[NFTA_RT_MAX + 1] = {
 	[NFTA_RT_DREG]		= { .type = NLA_U32 },
 	[NFTA_RT_KEY]		= { .type = NLA_U32 },
 };
-- 
2.1.4


