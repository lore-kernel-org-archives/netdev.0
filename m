From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/9] net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 14:27:00 +0200
Message-ID: <1393504026-13384-4-git-send-email-amirv@mellanox.com>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53561 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750904AbaB0M1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 07:27:19 -0500
In-Reply-To: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Hardware can't accept packets smaller than 17 bytes. Therefore need to pad with
zeros.


Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8dc7637..268cc4a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -585,12 +585,19 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
 
 	if (skb->len <= spc) {
-		inl->byte_count = cpu_to_be32(1 << 31 | skb->len);
+		inl->byte_count = cpu_to_be32(1 << 31 |
+					      max_t(typeof(skb->len),
+						    skb->len,
+						    MIN_PKT_LEN));
 		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
 		if (skb_shinfo(skb)->nr_frags)
 			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
 			       skb_frag_size(&skb_shinfo(skb)->frags[0]));
 
+		if (skb->len < MIN_PKT_LEN)
+			memset(((void *)(inl + 1)) + skb->len, 0,
+			       MIN_PKT_LEN - skb->len);
+
 	} else {
 		inl->byte_count = cpu_to_be32(1 << 31 | spc);
 		if (skb_headlen(skb) <= spc) {
-- 
1.8.3.4
