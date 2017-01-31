From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 5/8] net/mlx5e: Calc vlan_tag_present only once on xmit
Date: Tue, 31 Jan 2017 22:58:40 +0200
Message-ID: <20170131205843.23235-6-saeedm@mellanox.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60064 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751218AbdAaVFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:39 -0500
In-Reply-To: <20170131205843.23235-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cache skb_vlan_tag_present(skb) and pass it wherever needed in xmit
routines.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 678c07c8fbb0..ac76fb4f5510 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -148,15 +148,16 @@ static inline int mlx5e_skb_l3_header_offset(struct sk_buff *skb)
 		return mlx5e_skb_l2_header_offset(skb);
 }
 
-static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
-						 struct sk_buff *skb)
+static inline unsigned int
+mlx5e_calc_min_inline(enum mlx5_inline_modes mode, struct sk_buff *skb,
+		      bool vlan_present)
 {
 	int hlen;
 
 	switch (mode) {
 	case MLX5_INLINE_MODE_TCP_UDP:
 		hlen = eth_get_headlen(skb->data, skb_headlen(skb));
-		if (hlen == ETH_HLEN && !skb_vlan_tag_present(skb))
+		if (hlen == ETH_HLEN && !vlan_present)
 			hlen += VLAN_HLEN;
 		return hlen;
 	case MLX5_INLINE_MODE_IP:
@@ -174,7 +175,8 @@ static inline unsigned int mlx5e_calc_min_inline(enum mlx5_inline_modes mode,
 }
 
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
-					    struct sk_buff *skb, bool bf)
+					    struct sk_buff *skb,
+					    bool vlan_present, bool bf)
 {
 	/* Some NIC TX decisions, e.g loopback, are based on the packet
 	 * headers and occur before the data gather.
@@ -183,13 +185,13 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	if (bf) {
 		u16 ihs = skb_headlen(skb);
 
-		if (skb_vlan_tag_present(skb))
+		if (vlan_present)
 			ihs += VLAN_HLEN;
 
 		if (ihs <= sq->max_inline)
 			return skb_headlen(skb);
 	}
-	return mlx5e_calc_min_inline(sq->min_inline_mode, skb);
+	return mlx5e_calc_min_inline(sq->min_inline_mode, skb, vlan_present);
 }
 
 static inline void mlx5e_tx_skb_pull_inline(unsigned char **skb_data,
@@ -228,6 +230,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
 	struct mlx5_wqe_data_seg *dseg;
 
+	bool vlan_present = skb_vlan_tag_present(skb);
 	unsigned char *skb_data = skb->data;
 	unsigned int skb_len = skb->len;
 	u8  opcode = MLX5_OPCODE_SEND;
@@ -277,15 +280,14 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		bf = sq->bf_budget &&
 		     !skb->xmit_more &&
 		     !skb_shinfo(skb)->nr_frags;
-		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
+		ihs = mlx5e_get_inline_hdr_size(sq, skb, vlan_present, bf);
 		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 	}
 
 	wi->num_bytes = num_bytes;
 
-	if (skb_vlan_tag_present(skb)) {
-		mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data,
-				  &skb_len);
+	if (vlan_present) {
+		mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data, &skb_len);
 		ihs += VLAN_HLEN;
 	} else {
 		memcpy(eseg->inline_hdr.start, skb_data, ihs);
-- 
2.11.0
