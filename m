From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 3/9] net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Fri, 28 Feb 2014 08:00:03 +0200
Message-ID: <1393567209-16358-4-git-send-email-amirv@mellanox.com>
References: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49333 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750746AbaB1GAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 01:00:24 -0500
In-Reply-To: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Hardware can't accept packets smaller than 17 bytes. Therefore need to
pad with zeros.


Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8dc7637..781ebca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -585,7 +585,13 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
 
 	if (skb->len <= spc) {
-		inl->byte_count = cpu_to_be32(1 << 31 | skb->len);
+		if (likely(skb->len >= MIN_PKT_LEN)) {
+			inl->byte_count = cpu_to_be32(1 << 31 | skb->len);
+		} else {
+			inl->byte_count = cpu_to_be32(1 << 31 | MIN_PKT_LEN);
+			memset(((void *)(inl + 1)) + skb->len, 0,
+			       MIN_PKT_LEN - skb->len);
+		}
 		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
 		if (skb_shinfo(skb)->nr_frags)
 			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
-- 
1.8.3.4
