From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx5e: Check the minimum inline header mode before xmit
Date: Thu, 21 Jul 2016 01:20:01 +0300
Message-ID: <1469053202-30649-2-git-send-email-saeedm@mellanox.com>
References: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47750 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755317AbcGTWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:20:07 -0400
In-Reply-To: <1469053202-30649-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Each send queue (SQ) has inline mode that defines the minimal required
inline headers in the SQ WQE.
Before sending each packet check that the minimum required headers
on the WQE are copied.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 49 +++++++++++++++++++++++--
 include/linux/mlx5/device.h                     |  7 ++++
 3 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 4cbd452..2c20c7b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -398,6 +398,7 @@ struct mlx5e_sq {
 	u32                        sqn;
 	u16                        bf_buf_size;
 	u16                        max_inline;
+	u8                         min_inline_mode;
 	u16                        edge;
 	struct device             *pdev;
 	struct mlx5e_tstamp       *tstamp;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 5740b46..e073bf59 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -128,6 +128,50 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return priv->channeltc_to_txq_map[channel_ix][up];
 }
 
+static inline int mlx5e_skb_l2_header_offset(struct sk_buff *skb)
+{
+#define MLX5E_MIN_INLINE (ETH_HLEN + VLAN_HLEN)
+
+	return max(skb_network_offset(skb), MLX5E_MIN_INLINE);
+}
+
+static inline int mlx5e_skb_l3_header_offset(struct sk_buff *skb)
+{
+	struct flow_keys keys;
+
+	if (skb_transport_header_was_set(skb))
+		return skb_transport_offset(skb);
+	else if (skb_flow_dissect_flow_keys(skb, &keys, 0))
+		return keys.control.thoff;
+	else
+		return mlx5e_skb_l2_header_offset(skb);
+}
+
+static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
+						 struct sk_buff *skb)
+{
+	int hlen;
+
+	switch (mode) {
+	case MLX5_INLINE_MODE_TCP_UDP:
+		hlen = eth_get_headlen(skb->data, skb_headlen(skb));
+		if (hlen == ETH_HLEN && !skb_vlan_tag_present(skb))
+			hlen += VLAN_HLEN;
+		return hlen;
+	case MLX5_INLINE_MODE_IP:
+		/* When transport header is set to zero, it means no transport
+		 * header. When transport header is set to 0xff's, it means
+		 * transport header wasn't set.
+		 */
+		if (skb_transport_offset(skb))
+			return mlx5e_skb_l3_header_offset(skb);
+		/* fall through */
+	case MLX5_INLINE_MODE_L2:
+	default:
+		return mlx5e_skb_l2_header_offset(skb);
+	}
+}
+
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 					    struct sk_buff *skb, bool bf)
 {
@@ -135,8 +179,6 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	 * headers and occur before the data gather.
 	 * Therefore these headers must be copied into the WQE
 	 */
-#define MLX5E_MIN_INLINE (ETH_HLEN + VLAN_HLEN)
-
 	if (bf) {
 		u16 ihs = skb_headlen(skb);
 
@@ -146,8 +188,7 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 		if (ihs <= sq->max_inline)
 			return skb_headlen(skb);
 	}
-
-	return max(skb_network_offset(skb), MLX5E_MIN_INLINE);
+	return mlx5e_calc_min_inline(sq->min_inline_mode, skb);
 }
 
 static inline void mlx5e_tx_skb_pull_inline(unsigned char **skb_data,
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index e0a3ed7..0b6d15c 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -129,6 +129,13 @@ __mlx5_mask(typ, fld))
 		tmp;							  \
 		})
 
+enum mlx5_inline_modes {
+	MLX5_INLINE_MODE_NONE,
+	MLX5_INLINE_MODE_L2,
+	MLX5_INLINE_MODE_IP,
+	MLX5_INLINE_MODE_TCP_UDP,
+};
+
 enum {
 	MLX5_MAX_COMMANDS		= 32,
 	MLX5_CMD_DATA_BLOCK_SIZE	= 512,
-- 
2.8.0
