From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 10/11] net/mlx5e: Fix inline header size for small packets
Date: Thu, 31 Aug 2017 01:21:09 +0300
Message-ID: <20170830222110.15737-11-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Moshe Shemesh <moshe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53264 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751363AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Fix inline header size, make sure it is not greater than skb len.
This bug effects small packets, for example L2 packets with size < 18.

Fixes: ae76715d153e ("net/mlx5e: Check the minimum inline header mode before xmit")
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index aaa0f4ebba9a..31353e5c3c78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -128,10 +128,10 @@ static inline int mlx5e_skb_l3_header_offset(struct sk_buff *skb)
 		return mlx5e_skb_l2_header_offset(skb);
 }
 
-static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
-						 struct sk_buff *skb)
+static inline u16 mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
+					struct sk_buff *skb)
 {
-	int hlen;
+	u16 hlen;
 
 	switch (mode) {
 	case MLX5_INLINE_MODE_NONE:
@@ -140,19 +140,22 @@ static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
 		hlen = eth_get_headlen(skb->data, skb_headlen(skb));
 		if (hlen == ETH_HLEN && !skb_vlan_tag_present(skb))
 			hlen += VLAN_HLEN;
-		return hlen;
+		break;
 	case MLX5_INLINE_MODE_IP:
 		/* When transport header is set to zero, it means no transport
 		 * header. When transport header is set to 0xff's, it means
 		 * transport header wasn't set.
 		 */
-		if (skb_transport_offset(skb))
-			return mlx5e_skb_l3_header_offset(skb);
+		if (skb_transport_offset(skb)) {
+			hlen = mlx5e_skb_l3_header_offset(skb);
+			break;
+		}
 		/* fall through */
 	case MLX5_INLINE_MODE_L2:
 	default:
-		return mlx5e_skb_l2_header_offset(skb);
+		hlen = mlx5e_skb_l2_header_offset(skb);
 	}
+	return min_t(u16, hlen, skb->len);
 }
 
 static inline void mlx5e_tx_skb_pull_inline(unsigned char **skb_data,
-- 
2.13.0
