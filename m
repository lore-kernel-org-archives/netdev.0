From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/6] net/mlx5e: Fix inline header size calculation
Date: Thu, 12 Nov 2015 19:35:25 +0200
Message-ID: <1447349730-19832-2-git-send-email-ogerlitz@mellanox.com>
References: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46730 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752966AbbKLRf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:57 -0500
In-Reply-To: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

mlx5e_get_inline_hdr_size didn't take into account the vlan insertion
into the inline WQE segment.
This could lead to max inline violation in cases where
skb_headlen(skb) + VLAN_HLEN >= sq->max_inline.

Fixes: 3ea4891db8d0 ("net/mlx5e: Fix LSO vlan insertion")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index cd8f85a..f687ebf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -118,8 +118,15 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	 */
 #define MLX5E_MIN_INLINE ETH_HLEN
 
-	if (bf && (skb_headlen(skb) <= sq->max_inline))
-		return skb_headlen(skb);
+	if (bf) {
+		u16 ihs = skb_headlen(skb);
+
+		if (skb_vlan_tag_present(skb))
+			ihs += VLAN_HLEN;
+
+		if (ihs <= sq->max_inline)
+			return skb_headlen(skb);
+	}
 
 	return MLX5E_MIN_INLINE;
 }
-- 
2.3.7
