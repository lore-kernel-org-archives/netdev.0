From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: add support for Hardware Filter Block
Date: Fri, 13 Mar 2015 14:45:00 -0700 (PDT)
Message-ID: <20150313214500.DD4C42211CA@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34567 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbbCMVpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 17:45:03 -0400
Received: by igqa13 with SMTP id a13so47408igq.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 14:45:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Hardware Filter Block (HFB) so that incoming Rx traffic
can be matched and directed to desired Rx queues.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 175 +++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   1 +
 2 files changed, 176 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index e74ae62..12956b1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -197,6 +197,14 @@ enum dma_reg {
 	DMA_PRIORITY_0,
 	DMA_PRIORITY_1,
 	DMA_PRIORITY_2,
+	DMA_INDEX2RING_0,
+	DMA_INDEX2RING_1,
+	DMA_INDEX2RING_2,
+	DMA_INDEX2RING_3,
+	DMA_INDEX2RING_4,
+	DMA_INDEX2RING_5,
+	DMA_INDEX2RING_6,
+	DMA_INDEX2RING_7,
 };
 
 static const u8 bcmgenet_dma_regs_v3plus[] = {
@@ -208,6 +216,14 @@ static const u8 bcmgenet_dma_regs_v3plus[] = {
 	[DMA_PRIORITY_0]	= 0x30,
 	[DMA_PRIORITY_1]	= 0x34,
 	[DMA_PRIORITY_2]	= 0x38,
+	[DMA_INDEX2RING_0]	= 0x70,
+	[DMA_INDEX2RING_1]	= 0x74,
+	[DMA_INDEX2RING_2]	= 0x78,
+	[DMA_INDEX2RING_3]	= 0x7C,
+	[DMA_INDEX2RING_4]	= 0x80,
+	[DMA_INDEX2RING_5]	= 0x84,
+	[DMA_INDEX2RING_6]	= 0x88,
+	[DMA_INDEX2RING_7]	= 0x8C,
 };
 
 static const u8 bcmgenet_dma_regs_v2[] = {
@@ -2283,6 +2299,160 @@ static void bcmgenet_enable_dma(struct bcmgenet_priv *priv, u32 dma_ctrl)
 	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
 }
 
+static bool bcmgenet_hfb_is_filter_enabled(struct bcmgenet_priv *priv,
+					   u32 f_index)
+{
+	u32 offset;
+	u32 reg;
+
+	offset = HFB_FLT_ENABLE_V3PLUS + (f_index < 32) * sizeof(u32);
+	reg = bcmgenet_hfb_reg_readl(priv, offset);
+	return !!(reg & (1 << (f_index % 32)));
+}
+
+static void bcmgenet_hfb_enable_filter(struct bcmgenet_priv *priv, u32 f_index)
+{
+	u32 offset;
+	u32 reg;
+
+	offset = HFB_FLT_ENABLE_V3PLUS + (f_index < 32) * sizeof(u32);
+	reg = bcmgenet_hfb_reg_readl(priv, offset);
+	reg |= (1 << (f_index % 32));
+	bcmgenet_hfb_reg_writel(priv, reg, offset);
+}
+
+static void bcmgenet_hfb_set_filter_rx_queue_mapping(struct bcmgenet_priv *priv,
+						     u32 f_index, u32 rx_queue)
+{
+	u32 offset;
+	u32 reg;
+
+	offset = f_index / 8;
+	reg = bcmgenet_rdma_readl(priv, DMA_INDEX2RING_0 + offset);
+	reg &= ~(0xF << (4 * (f_index % 8)));
+	reg |= ((rx_queue & 0xF) << (4 * (f_index % 8)));
+	bcmgenet_rdma_writel(priv, reg, DMA_INDEX2RING_0 + offset);
+}
+
+static void bcmgenet_hfb_set_filter_length(struct bcmgenet_priv *priv,
+					   u32 f_index, u32 f_length)
+{
+	u32 offset;
+	u32 reg;
+
+	offset = HFB_FLT_LEN_V3PLUS +
+		 ((priv->hw_params->hfb_filter_cnt - 1 - f_index) / 4) *
+		 sizeof(u32);
+	reg = bcmgenet_hfb_reg_readl(priv, offset);
+	reg &= ~(0xFF << (8 * (f_index % 4)));
+	reg |= ((f_length & 0xFF) << (8 * (f_index % 4)));
+	bcmgenet_hfb_reg_writel(priv, reg, offset);
+}
+
+static int bcmgenet_hfb_find_unused_filter(struct bcmgenet_priv *priv)
+{
+	u32 f_index;
+
+	for (f_index = 0; f_index < priv->hw_params->hfb_filter_cnt; f_index++)
+		if (!bcmgenet_hfb_is_filter_enabled(priv, f_index))
+			return f_index;
+
+	return -ENOMEM;
+}
+
+/* bcmgenet_hfb_add_filter
+ *
+ * Add new filter to Hardware Filter Block to match and direct Rx traffic to
+ * desired Rx queue.
+ *
+ * f_data is an array of unsigned 32-bit integers where each 32-bit integer
+ * provides filter data for 2 bytes (4 nibbles) of Rx frame:
+ *
+ * bits 31:20 - unused
+ * bit  19    - nibble 0 match enable
+ * bit  18    - nibble 1 match enable
+ * bit  17    - nibble 2 match enable
+ * bit  16    - nibble 3 match enable
+ * bits 15:12 - nibble 0 data
+ * bits 11:8  - nibble 1 data
+ * bits 7:4   - nibble 2 data
+ * bits 3:0   - nibble 3 data
+ *
+ * Example:
+ * In order to match:
+ * - Ethernet frame type = 0x0800 (IP)
+ * - IP version field = 4
+ * - IP protocol field = 0x11 (UDP)
+ *
+ * The following filter is needed:
+ * u32 hfb_filter_ipv4_udp[] = {
+ *   Rx frame offset 0x00: 0x00000000, 0x00000000, 0x00000000, 0x00000000,
+ *   Rx frame offset 0x08: 0x00000000, 0x00000000, 0x000F0800, 0x00084000,
+ *   Rx frame offset 0x10: 0x00000000, 0x00000000, 0x00000000, 0x00030011,
+ * };
+ *
+ * To add the filter to HFB and direct the traffic to Rx queue 0, call:
+ * bcmgenet_hfb_add_filter(priv, hfb_filter_ipv4_udp,
+ *                         ARRAY_SIZE(hfb_filter_ipv4_udp), 0);
+ */
+int bcmgenet_hfb_add_filter(struct bcmgenet_priv *priv, u32 *f_data,
+			    u32 f_length, u32 rx_queue)
+{
+	int f_index;
+	u32 i;
+
+	f_index = bcmgenet_hfb_find_unused_filter(priv);
+	if (f_index < 0)
+		return -ENOMEM;
+
+	if (f_length > priv->hw_params->hfb_filter_size)
+		return -EINVAL;
+
+	for (i = 0; i < f_length; i++)
+		bcmgenet_hfb_writel(priv, f_data[i],
+			(f_index * priv->hw_params->hfb_filter_size + i) *
+			sizeof(u32));
+
+	bcmgenet_hfb_set_filter_length(priv, f_index, 2 * f_length);
+	bcmgenet_hfb_set_filter_rx_queue_mapping(priv, f_index, rx_queue);
+	bcmgenet_hfb_enable_filter(priv, f_index);
+	bcmgenet_hfb_reg_writel(priv, 0x1, HFB_CTRL);
+
+	return 0;
+}
+
+/* bcmgenet_hfb_clear
+ *
+ * Clear Hardware Filter Block and disable all filtering.
+ */
+static void bcmgenet_hfb_clear(struct bcmgenet_priv *priv)
+{
+	u32 i;
+
+	bcmgenet_hfb_reg_writel(priv, 0x0, HFB_CTRL);
+	bcmgenet_hfb_reg_writel(priv, 0x0, HFB_FLT_ENABLE_V3PLUS);
+	bcmgenet_hfb_reg_writel(priv, 0x0, HFB_FLT_ENABLE_V3PLUS + 4);
+
+	for (i = DMA_INDEX2RING_0; i <= DMA_INDEX2RING_7; i++)
+		bcmgenet_rdma_writel(priv, 0x0, i);
+
+	for (i = 0; i < (priv->hw_params->hfb_filter_cnt / 4); i++)
+		bcmgenet_hfb_reg_writel(priv, 0x0,
+					HFB_FLT_LEN_V3PLUS + i * sizeof(u32));
+
+	for (i = 0; i < priv->hw_params->hfb_filter_cnt *
+			priv->hw_params->hfb_filter_size; i++)
+		bcmgenet_hfb_writel(priv, 0x0, i * sizeof(u32));
+}
+
+static void bcmgenet_hfb_init(struct bcmgenet_priv *priv)
+{
+	if (GENET_IS_V1(priv) || GENET_IS_V2(priv))
+		return;
+
+	bcmgenet_hfb_clear(priv);
+}
+
 static void bcmgenet_netif_start(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -2348,6 +2518,9 @@ static int bcmgenet_open(struct net_device *dev)
 	/* Always enable ring 16 - descriptor ring */
 	bcmgenet_enable_dma(priv, dma_ctrl);
 
+	/* HFB init */
+	bcmgenet_hfb_init(priv);
+
 	ret = request_irq(priv->irq0, bcmgenet_isr0, IRQF_SHARED,
 			  dev->name, priv);
 	if (ret < 0) {
@@ -2592,6 +2765,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
+		.hfb_filter_size = 128,
 		.qtag_mask = 0x3F,
 		.tbuf_offset = 0x0600,
 		.hfb_offset = 0x8000,
@@ -2609,6 +2783,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
+		.hfb_filter_size = 128,
 		.qtag_mask = 0x3F,
 		.tbuf_offset = 0x0600,
 		.hfb_offset = 0x8000,
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 2a81138..1ea8389 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -509,6 +509,7 @@ struct bcmgenet_hw_params {
 	u8		bp_in_en_shift;
 	u32		bp_in_mask;
 	u8		hfb_filter_cnt;
+	u8		hfb_filter_size;
 	u8		qtag_mask;
 	u16		tbuf_offset;
 	u32		hfb_offset;
-- 
2.2.0.rc0.207.ga3a616c
