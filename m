From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 43/50] netfilter: rpfilter: bypass ipv4 lbcast packets with zeronet source
Date: Wed,  7 Dec 2016 22:52:49 +0100
Message-ID: <1481147576-5690-44-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Otherwise, DHCP Discover packets(0.0.0.0->255.255.255.255) may be
dropped incorrectly.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_rpfilter.c |  8 +++++---
 net/ipv4/netfilter/nft_fib_ipv4.c | 13 +++++++------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 59b49945b481..f273098e48fd 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -83,10 +83,12 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return true ^ invert;
 
 	iph = ip_hdr(skb);
-	if (ipv4_is_multicast(iph->daddr)) {
-		if (ipv4_is_zeronet(iph->saddr))
-			return ipv4_is_local_multicast(iph->daddr) ^ invert;
+	if (ipv4_is_zeronet(iph->saddr)) {
+		if (ipv4_is_lbcast(iph->daddr) ||
+		    ipv4_is_local_multicast(iph->daddr))
+			return true ^ invert;
 	}
+
 	flow.flowi4_iif = LOOPBACK_IFINDEX;
 	flow.daddr = iph->saddr;
 	flow.saddr = rpfilter_get_saddr(iph->daddr);
diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 258136364f5e..965b1a161369 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -101,12 +101,13 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	}
 
 	iph = ip_hdr(pkt->skb);
-	if (ipv4_is_multicast(iph->daddr) &&
-	    ipv4_is_zeronet(iph->saddr) &&
-	    ipv4_is_local_multicast(iph->daddr)) {
-		nft_fib_store_result(dest, priv->result, pkt,
-				     get_ifindex(pkt->skb->dev));
-		return;
+	if (ipv4_is_zeronet(iph->saddr)) {
+		if (ipv4_is_lbcast(iph->daddr) ||
+		    ipv4_is_local_multicast(iph->daddr)) {
+			nft_fib_store_result(dest, priv->result, pkt,
+					     get_ifindex(pkt->skb->dev));
+			return;
+		}
 	}
 
 	if (priv->flags & NFTA_FIB_F_MARK)
-- 
2.1.4

