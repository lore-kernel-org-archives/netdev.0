From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 2/7] netfilter: nft_meta: look at pkt->sk rather than skb->sk
Date: Tue, 29 Sep 2015 13:12:15 +0200
Message-ID: <1443525140-13493-3-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pkt->sk is set to whatever was passed to nh_hook() by the caller,
and for post demux chains, this is the one that should be looked
at, as skb->sk is still NULL at this point in time.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/netfilter/nft_meta.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index cb2f13e..f195bee 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -29,8 +29,9 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		       const struct nft_pktinfo *pkt)
 {
 	const struct nft_meta *priv = nft_expr_priv(expr);
-	const struct sk_buff *skb = pkt->skb;
 	const struct net_device *in = pkt->in, *out = pkt->out;
+	struct sk_buff *skb = pkt->skb;
+	struct sock *sk = pkt->sk;
 	u32 *dest = &regs->data[priv->dreg];
 
 	switch (priv->key) {
@@ -168,9 +169,9 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		break;
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
-		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+		if (sk == NULL || !sk_fullsock(sk))
 			goto err;
-		*dest = skb->sk->sk_classid;
+		*dest = sk->sk_classid;
 		break;
 #endif
 	default:
-- 
2.5.0

