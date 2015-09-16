From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 2/3] netfilter: nft_meta: mark skbs for postponed filter processing
Date: Wed, 16 Sep 2015 17:42:59 +0200
Message-ID: <1442418180-14322-3-git-send-email-daniel@zonque.org>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1442418180-14322-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the cgroup matching code in nft_meta is called without a socket to
look at, it currently bails out and lets the packet pass. This is bad,
because the reason for skb->sk being NULL is simply that the packet was
directed to a socket that hasn't been looked up yet by early demux.

This patch does two things:

 a) it uses the newly introduced pkt->sk pointer rather than skb->sk
    to check for the net class ID. This allows us to look at the socket
    the user passed into nf_hook().

 b) in case the socket can't be accessed, it marks the skb as
    'nf_postponed', so that later dispatchers have a chance to
    re-iterate the chain for such packets, after a full demux was
    conducted.

Note that the added flag in 'struct skb' does not increase the size
of the struct, as it fits in the 'flags1' bitfield.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/linux/skbuff.h   | 3 ++-
 net/netfilter/nft_meta.c | 9 ++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2738d35..3590101 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -584,7 +584,8 @@ struct sk_buff {
 				fclone:2,
 				peeked:1,
 				head_frag:1,
-				xmit_more:1;
+				xmit_more:1,
+				nf_postponed:1;
 	/* one bit hole */
 	kmemcheck_bitfield_end(flags1);
 
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index cb2f13e..33b8d23 100644
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
@@ -168,9 +169,11 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		break;
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
-		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+		if (sk == NULL || !sk_fullsock(sk)) {
+			skb->nf_postponed = 1;
 			goto err;
-		*dest = skb->sk->sk_classid;
+		}
+		*dest = sk->sk_classid;
 		break;
 #endif
 	default:
-- 
2.5.0

