From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 10/14] net/mlx4_en: Use local var for skb_headlen(skb)
Date: Mon,  6 Oct 2014 09:15:59 +0300
Message-ID: <1412576163-7224-11-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37939 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751355AbaJFGQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:16:33 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Access skb_headlen() once in tx flow

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index aa05b09..e00841a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -612,6 +612,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 {
 	struct mlx4_wqe_inline_seg *inl = &tx_desc->inl;
 	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
+	unsigned int hlen = skb_headlen(skb);
 
 	if (skb->len <= spc) {
 		if (likely(skb->len >= MIN_PKT_LEN)) {
@@ -621,19 +622,19 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			memset(((void *)(inl + 1)) + skb->len, 0,
 			       MIN_PKT_LEN - skb->len);
 		}
-		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
+		skb_copy_from_linear_data(skb, inl + 1, hlen);
 		if (shinfo->nr_frags)
-			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
+			memcpy(((void *)(inl + 1)) + hlen, fragptr,
 			       skb_frag_size(&shinfo->frags[0]));
 
 	} else {
 		inl->byte_count = cpu_to_be32(1 << 31 | spc);
-		if (skb_headlen(skb) <= spc) {
-			skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
-			if (skb_headlen(skb) < spc) {
-				memcpy(((void *)(inl + 1)) + skb_headlen(skb),
-					fragptr, spc - skb_headlen(skb));
-				fragptr +=  spc - skb_headlen(skb);
+		if (hlen <= spc) {
+			skb_copy_from_linear_data(skb, inl + 1, hlen);
+			if (hlen < spc) {
+				memcpy(((void *)(inl + 1)) + hlen,
+				       fragptr, spc - hlen);
+				fragptr +=  spc - hlen;
 			}
 			inl = (void *) (inl + 1) + spc;
 			memcpy(((void *)(inl + 1)), fragptr, skb->len - spc);
@@ -641,9 +642,9 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			skb_copy_from_linear_data(skb, inl + 1, spc);
 			inl = (void *) (inl + 1) + spc;
 			skb_copy_from_linear_data_offset(skb, spc, inl + 1,
-					skb_headlen(skb) - spc);
+							 hlen - spc);
 			if (shinfo->nr_frags)
-				memcpy(((void *)(inl + 1)) + skb_headlen(skb) - spc,
+				memcpy(((void *)(inl + 1)) + hlen - spc,
 				       fragptr,
 				       skb_frag_size(&shinfo->frags[0]));
 		}
-- 
1.8.3.1
