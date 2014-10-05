From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 01/14] net/mlx4_en: Code cleanups in tx path
Date: Sun,  5 Oct 2014 12:35:09 +0300
Message-ID: <1412501722-25092-2-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59491 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751127AbaJEJfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:34 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

- Remove unused variable ring->poll_cnt
- No need to set some fields if using blueflame
- Add missing const's
- Use unlikely
- Remove unneeded new line
- Make some comments more precise
- struct mlx4_bf @offset field reduced to unsigned int to save space

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 49 +++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 -
 include/linux/mlx4/device.h                  |  2 +-
 3 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 0c50125..eaf23eb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -191,7 +191,6 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->prod = 0;
 	ring->cons = 0xffffffff;
 	ring->last_nr_txbb = 1;
-	ring->poll_cnt = 0;
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
 
@@ -512,7 +511,8 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 	return ring->buf + index * TXBB_SIZE;
 }
 
-static int is_inline(int inline_thold, struct sk_buff *skb, void **pfrag)
+static bool is_inline(int inline_thold, const struct sk_buff *skb,
+		      void **pfrag)
 {
 	void *ptr;
 
@@ -535,7 +535,7 @@ static int is_inline(int inline_thold, struct sk_buff *skb, void **pfrag)
 	return 0;
 }
 
-static int inline_size(struct sk_buff *skb)
+static int inline_size(const struct sk_buff *skb)
 {
 	if (skb->len + CTRL_SIZE + sizeof(struct mlx4_wqe_inline_seg)
 	    <= MLX4_INLINE_ALIGN)
@@ -546,7 +546,8 @@ static int inline_size(struct sk_buff *skb)
 			     sizeof(struct mlx4_wqe_inline_seg), 16);
 }
 
-static int get_real_size(struct sk_buff *skb, struct net_device *dev,
+static int get_real_size(const struct sk_buff *skb,
+			 struct net_device *dev,
 			 int *lso_header_size)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -581,8 +582,10 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 	return real_size;
 }
 
-static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *skb,
-			     int real_size, u16 *vlan_tag, int tx_ind, void *fragptr)
+static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
+			     const struct sk_buff *skb,
+			     int real_size, u16 *vlan_tag,
+			     int tx_ind, void *fragptr)
 {
 	struct mlx4_wqe_inline_seg *inl = &tx_desc->inl;
 	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
@@ -642,7 +645,8 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return fallback(dev, skb) % rings_p_up + up * rings_p_up;
 }
 
-static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
+static void mlx4_bf_copy(void __iomem *dst, const void *src,
+			 unsigned int bytecnt)
 {
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
@@ -736,11 +740,10 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_info->skb = skb;
 	tx_info->nr_txbb = nr_txbb;
 
+	data = &tx_desc->data;
 	if (lso_header_size)
 		data = ((void *)&tx_desc->lso + ALIGN(lso_header_size + 4,
 						      DS_SIZE));
-	else
-		data = &tx_desc->data;
 
 	/* valid only for none inline segments */
 	tx_info->data_offset = (void *)data - (void *)tx_desc;
@@ -753,9 +756,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (is_inline(ring->inline_thold, skb, &fragptr)) {
 		tx_info->inl = 1;
 	} else {
-		/* Map fragments */
+		/* Map fragments if any */
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
-			struct skb_frag_struct *frag;
+			const struct skb_frag_struct *frag;
 			dma_addr_t dma;
 
 			frag = &skb_shinfo(skb)->frags[i];
@@ -772,7 +775,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			--data;
 		}
 
-		/* Map linear part */
+		/* Map linear part if needed */
 		if (tx_info->linear) {
 			u32 byte_count = skb_headlen(skb) - lso_header_size;
 			dma_addr_t dma;
@@ -795,18 +798,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * For timestamping add flag to skb_shinfo and
 	 * set flag for further reference
 	 */
-	if (ring->hwtstamp_tx_type == HWTSTAMP_TX_ON &&
-	    skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	if (unlikely(ring->hwtstamp_tx_type == HWTSTAMP_TX_ON &&
+		     shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
+		shinfo->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_info->ts_requested = 1;
 	}
 
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
-	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
-		!!vlan_tx_tag_present(skb);
-	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
@@ -852,7 +851,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
 		tx_info->nr_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 		ring->packets++;
-
 	}
 	ring->bytes += tx_info->nr_bytes;
 	netdev_tx_sent_queue(ring->tx_queue, tx_info->nr_bytes);
@@ -874,7 +872,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod += nr_txbb;
 
 	/* If we used a bounce buffer then copy descriptor back into place */
-	if (bounce)
+	if (unlikely(bounce))
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
 	skb_tx_timestamp(skb);
@@ -894,13 +892,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		wmb();
 
-		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned long *) &tx_desc->ctrl,
-		     desc_size);
+		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
+			     desc_size);
 
 		wmb();
 
 		ring->bf.offset ^= ring->bf.buf_size;
 	} else {
+		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
+		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
+			!!vlan_tx_tag_present(skb);
+		tx_desc->ctrl.fence_size = real_size;
+
 		/* Ensure new descriptor hits memory
 		 * before setting ownership of this descriptor to HW
 		 */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 84c9d5d..e54b653 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -263,7 +263,6 @@ struct mlx4_en_tx_ring {
 	u32 buf_size;
 	u32 doorbell_qpn;
 	void *buf;
-	u16 poll_cnt;
 	struct mlx4_en_tx_info *tx_info;
 	u8 *bounce_buf;
 	u8 queue_index;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b2f8ab9..37e4404 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -583,7 +583,7 @@ struct mlx4_uar {
 };
 
 struct mlx4_bf {
-	unsigned long		offset;
+	unsigned int		offset;
 	int			buf_size;
 	struct mlx4_uar	       *uar;
 	void __iomem	       *reg;
-- 
1.8.3.4
