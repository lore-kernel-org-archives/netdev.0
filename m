From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 09/14] net/mlx4_en: Use local var in tx flow for skb_shinfo(skb)
Date: Sun,  5 Oct 2014 12:35:17 +0300
Message-ID: <1412501722-25092-10-git-send-email-amirv@mellanox.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59533 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751069AbaJEJfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:39 -0400
In-Reply-To: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Acces skb_shinfo(skb) once in tx flow.
Also, rename @i variable to @i_frag to avoid confusion, as the "goto
tx_drop_unmap;" relied on this @i variable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 58 +++++++++++++++++-------------
 1 file changed, 34 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 99875c8..aa05b09 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -532,13 +532,14 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 }
 
 static bool is_inline(int inline_thold, const struct sk_buff *skb,
+		      const struct skb_shared_info *shinfo,
 		      void **pfrag)
 {
 	void *ptr;
 
 	if (inline_thold && !skb_is_gso(skb) && skb->len <= inline_thold) {
-		if (skb_shinfo(skb)->nr_frags == 1) {
-			ptr = skb_frag_address_safe(&skb_shinfo(skb)->frags[0]);
+		if (shinfo->nr_frags == 1) {
+			ptr = skb_frag_address_safe(&shinfo->frags[0]);
 			if (unlikely(!ptr))
 				return 0;
 
@@ -546,7 +547,7 @@ static bool is_inline(int inline_thold, const struct sk_buff *skb,
 				*pfrag = ptr;
 
 			return 1;
-		} else if (unlikely(skb_shinfo(skb)->nr_frags))
+		} else if (unlikely(shinfo->nr_frags))
 			return 0;
 		else
 			return 1;
@@ -567,18 +568,19 @@ static int inline_size(const struct sk_buff *skb)
 }
 
 static int get_real_size(const struct sk_buff *skb,
+			 const struct skb_shared_info *shinfo,
 			 struct net_device *dev,
 			 int *lso_header_size)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int real_size;
 
-	if (skb_is_gso(skb)) {
+	if (shinfo->gso_size) {
 		if (skb->encapsulation)
 			*lso_header_size = (skb_inner_transport_header(skb) - skb->data) + inner_tcp_hdrlen(skb);
 		else
 			*lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		real_size = CTRL_SIZE + skb_shinfo(skb)->nr_frags * DS_SIZE +
+		real_size = CTRL_SIZE + shinfo->nr_frags * DS_SIZE +
 			ALIGN(*lso_header_size + 4, DS_SIZE);
 		if (unlikely(*lso_header_size != skb_headlen(skb))) {
 			/* We add a segment for the skb linear buffer only if
@@ -593,8 +595,8 @@ static int get_real_size(const struct sk_buff *skb,
 		}
 	} else {
 		*lso_header_size = 0;
-		if (!is_inline(priv->prof->inline_thold, skb, NULL))
-			real_size = CTRL_SIZE + (skb_shinfo(skb)->nr_frags + 1) * DS_SIZE;
+		if (!is_inline(priv->prof->inline_thold, skb, shinfo, NULL))
+			real_size = CTRL_SIZE + (shinfo->nr_frags + 1) * DS_SIZE;
 		else
 			real_size = inline_size(skb);
 	}
@@ -604,6 +606,7 @@ static int get_real_size(const struct sk_buff *skb,
 
 static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			     const struct sk_buff *skb,
+			     const struct skb_shared_info *shinfo,
 			     int real_size, u16 *vlan_tag,
 			     int tx_ind, void *fragptr)
 {
@@ -619,9 +622,9 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			       MIN_PKT_LEN - skb->len);
 		}
 		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
-		if (skb_shinfo(skb)->nr_frags)
+		if (shinfo->nr_frags)
 			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
-			       skb_frag_size(&skb_shinfo(skb)->frags[0]));
+			       skb_frag_size(&shinfo->frags[0]));
 
 	} else {
 		inl->byte_count = cpu_to_be32(1 << 31 | spc);
@@ -639,9 +642,10 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
 			inl = (void *) (inl + 1) + spc;
 			skb_copy_from_linear_data_offset(skb, spc, inl + 1,
 					skb_headlen(skb) - spc);
-			if (skb_shinfo(skb)->nr_frags)
+			if (shinfo->nr_frags)
 				memcpy(((void *)(inl + 1)) + skb_headlen(skb) - spc,
-					fragptr, skb_frag_size(&skb_shinfo(skb)->frags[0]));
+				       fragptr,
+				       skb_frag_size(&shinfo->frags[0]));
 		}
 
 		wmb();
@@ -673,6 +677,7 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct device *ddev = priv->ddev;
 	struct mlx4_en_tx_ring *ring;
@@ -686,7 +691,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 index, bf_index;
 	__be32 op_own;
 	u16 vlan_tag = 0;
-	int i;
+	int i_frag;
 	int lso_header_size;
 	void *fragptr;
 	bool bounce = false;
@@ -702,7 +707,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* fetch ring->cons far ahead before needing it to avoid stall */
 	ring_cons = ACCESS_ONCE(ring->cons);
 
-	real_size = get_real_size(skb, dev, &lso_header_size);
+	real_size = get_real_size(skb, shinfo, dev, &lso_header_size);
 	if (unlikely(!real_size))
 		goto tx_drop;
 
@@ -776,21 +781,22 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_info->data_offset = (void *)data - (void *)tx_desc;
 
 	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
-			   !is_inline(ring->inline_thold, skb, NULL)) ? 1 : 0;
+			   !is_inline(ring->inline_thold, skb, shinfo, NULL)) ? 1 : 0;
 
-	tx_info->nr_maps = skb_shinfo(skb)->nr_frags + tx_info->linear;
+	tx_info->nr_maps = shinfo->nr_frags + tx_info->linear;
 	data += tx_info->nr_maps - 1;
 
-	if (is_inline(ring->inline_thold, skb, &fragptr)) {
+	if (is_inline(ring->inline_thold, skb, shinfo, &fragptr)) {
 		tx_info->inl = 1;
 	} else {
 		dma_addr_t dma = 0;
 		u32 byte_count = 0;
 
 		/* Map fragments if any */
-		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
+		for (i_frag = shinfo->nr_frags - 1; i_frag >= 0; i_frag--) {
 			const struct skb_frag_struct *frag;
-			frag = &skb_shinfo(skb)->frags[i];
+
+			frag = &shinfo->frags[i_frag];
 			byte_count = skb_frag_size(frag);
 			dma = skb_frag_dma_map(ddev, frag,
 					       0, byte_count,
@@ -858,6 +864,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
+		int i;
+
 		/* Mark opcode as LSO */
 		op_own = cpu_to_be32(MLX4_OPCODE_LSO | (1 << 6)) |
 			((ring->prod & ring->size) ?
@@ -865,15 +873,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* Fill in the LSO prefix */
 		tx_desc->lso.mss_hdr_size = cpu_to_be32(
-			skb_shinfo(skb)->gso_size << 16 | lso_header_size);
+			shinfo->gso_size << 16 | lso_header_size);
 
 		/* Copy headers;
 		 * note that we already verified that it is linear */
 		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
 
 		ring->tso_packets++;
-		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
-			!!((skb->len - lso_header_size) % skb_shinfo(skb)->gso_size);
+
+		i = ((skb->len - lso_header_size) / shinfo->gso_size) +
+			!!((skb->len - lso_header_size) % shinfo->gso_size);
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
 		ring->packets += i;
 	} else {
@@ -889,7 +898,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, skb->len);
 
 	if (tx_info->inl) {
-		build_inline_wqe(tx_desc, skb, real_size, &vlan_tag, tx_ind, fragptr);
+		build_inline_wqe(tx_desc, skb, shinfo, real_size, &vlan_tag,
+				 tx_ind, fragptr);
 		tx_info->inl = 1;
 	}
 
@@ -958,8 +968,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 tx_drop_unmap:
 	en_err(priv, "DMA mapping error\n");
 
-	for (i++; i < skb_shinfo(skb)->nr_frags; i++) {
-		data++;
+	while (++i_frag < shinfo->nr_frags) {
+		++data;
 		dma_unmap_page(ddev, (dma_addr_t) be64_to_cpu(data->addr),
 			       be32_to_cpu(data->byte_count),
 			       PCI_DMA_TODEVICE);
-- 
1.8.3.4
