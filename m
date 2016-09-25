From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: bcmgenet: remove unused function in bcmgenet.c
Date: Sun, 25 Sep 2016 14:23:15 +0800
Message-ID: <1474784595-29779-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/broadcom/genet/bcmgenet.c:2763:5: warning: no previous prototype for 'bcmgenet_hfb_add_filter' [-Wmissing-prototypes]

In fact, this function is implemented in
drivers/net/ethernet/broadcom/genet/bcmgenet.c, but be called
by no one, thus can be removed.

So this patch removes the unused functions.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 122 -------------------------
 1 file changed, 122 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 2013474..7f47849 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2664,128 +2664,6 @@ static void bcmgenet_enable_dma(struct bcmgenet_priv *priv, u32 dma_ctrl)
 	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
 }
 
-static bool bcmgenet_hfb_is_filter_enabled(struct bcmgenet_priv *priv,
-					   u32 f_index)
-{
-	u32 offset;
-	u32 reg;
-
-	offset = HFB_FLT_ENABLE_V3PLUS + (f_index < 32) * sizeof(u32);
-	reg = bcmgenet_hfb_reg_readl(priv, offset);
-	return !!(reg & (1 << (f_index % 32)));
-}
-
-static void bcmgenet_hfb_enable_filter(struct bcmgenet_priv *priv, u32 f_index)
-{
-	u32 offset;
-	u32 reg;
-
-	offset = HFB_FLT_ENABLE_V3PLUS + (f_index < 32) * sizeof(u32);
-	reg = bcmgenet_hfb_reg_readl(priv, offset);
-	reg |= (1 << (f_index % 32));
-	bcmgenet_hfb_reg_writel(priv, reg, offset);
-}
-
-static void bcmgenet_hfb_set_filter_rx_queue_mapping(struct bcmgenet_priv *priv,
-						     u32 f_index, u32 rx_queue)
-{
-	u32 offset;
-	u32 reg;
-
-	offset = f_index / 8;
-	reg = bcmgenet_rdma_readl(priv, DMA_INDEX2RING_0 + offset);
-	reg &= ~(0xF << (4 * (f_index % 8)));
-	reg |= ((rx_queue & 0xF) << (4 * (f_index % 8)));
-	bcmgenet_rdma_writel(priv, reg, DMA_INDEX2RING_0 + offset);
-}
-
-static void bcmgenet_hfb_set_filter_length(struct bcmgenet_priv *priv,
-					   u32 f_index, u32 f_length)
-{
-	u32 offset;
-	u32 reg;
-
-	offset = HFB_FLT_LEN_V3PLUS +
-		 ((priv->hw_params->hfb_filter_cnt - 1 - f_index) / 4) *
-		 sizeof(u32);
-	reg = bcmgenet_hfb_reg_readl(priv, offset);
-	reg &= ~(0xFF << (8 * (f_index % 4)));
-	reg |= ((f_length & 0xFF) << (8 * (f_index % 4)));
-	bcmgenet_hfb_reg_writel(priv, reg, offset);
-}
-
-static int bcmgenet_hfb_find_unused_filter(struct bcmgenet_priv *priv)
-{
-	u32 f_index;
-
-	for (f_index = 0; f_index < priv->hw_params->hfb_filter_cnt; f_index++)
-		if (!bcmgenet_hfb_is_filter_enabled(priv, f_index))
-			return f_index;
-
-	return -ENOMEM;
-}
-
-/* bcmgenet_hfb_add_filter
- *
- * Add new filter to Hardware Filter Block to match and direct Rx traffic to
- * desired Rx queue.
- *
- * f_data is an array of unsigned 32-bit integers where each 32-bit integer
- * provides filter data for 2 bytes (4 nibbles) of Rx frame:
- *
- * bits 31:20 - unused
- * bit  19    - nibble 0 match enable
- * bit  18    - nibble 1 match enable
- * bit  17    - nibble 2 match enable
- * bit  16    - nibble 3 match enable
- * bits 15:12 - nibble 0 data
- * bits 11:8  - nibble 1 data
- * bits 7:4   - nibble 2 data
- * bits 3:0   - nibble 3 data
- *
- * Example:
- * In order to match:
- * - Ethernet frame type = 0x0800 (IP)
- * - IP version field = 4
- * - IP protocol field = 0x11 (UDP)
- *
- * The following filter is needed:
- * u32 hfb_filter_ipv4_udp[] = {
- *   Rx frame offset 0x00: 0x00000000, 0x00000000, 0x00000000, 0x00000000,
- *   Rx frame offset 0x08: 0x00000000, 0x00000000, 0x000F0800, 0x00084000,
- *   Rx frame offset 0x10: 0x00000000, 0x00000000, 0x00000000, 0x00030011,
- * };
- *
- * To add the filter to HFB and direct the traffic to Rx queue 0, call:
- * bcmgenet_hfb_add_filter(priv, hfb_filter_ipv4_udp,
- *                         ARRAY_SIZE(hfb_filter_ipv4_udp), 0);
- */
-int bcmgenet_hfb_add_filter(struct bcmgenet_priv *priv, u32 *f_data,
-			    u32 f_length, u32 rx_queue)
-{
-	int f_index;
-	u32 i;
-
-	f_index = bcmgenet_hfb_find_unused_filter(priv);
-	if (f_index < 0)
-		return -ENOMEM;
-
-	if (f_length > priv->hw_params->hfb_filter_size)
-		return -EINVAL;
-
-	for (i = 0; i < f_length; i++)
-		bcmgenet_hfb_writel(priv, f_data[i],
-			(f_index * priv->hw_params->hfb_filter_size + i) *
-			sizeof(u32));
-
-	bcmgenet_hfb_set_filter_length(priv, f_index, 2 * f_length);
-	bcmgenet_hfb_set_filter_rx_queue_mapping(priv, f_index, rx_queue);
-	bcmgenet_hfb_enable_filter(priv, f_index);
-	bcmgenet_hfb_reg_writel(priv, 0x1, HFB_CTRL);
-
-	return 0;
-}
-
 /* bcmgenet_hfb_clear
  *
  * Clear Hardware Filter Block and disable all filtering.
-- 
2.7.4
