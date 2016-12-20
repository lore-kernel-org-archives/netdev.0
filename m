From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2] stmmac: enable rx queues
Date: Tue, 20 Dec 2016 16:27:05 +0000
Message-ID: <a72c10dc007210d93c5e8f17ac5fed2242bde5d4.1482250750.git.jpinto@synopsys.com>
Cc: hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: peppe.cavallaro@st.com, davem@davemloft.net,
        seraphin.bonnaffe@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the hardware is synthesized with multiple queues, all queues are
disabled for default. This patch adds the rx queues configuration.
This patch was successfully tested in a Synopsys QoS Reference design.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1 -> v2 (Niklas Cassel and Seraphin Bonnaffe):
- Instead of using number of DMA channels, lets use number of queues
- Create 2 flavors of RX queue enable Macros: AV and DCB (AV by default)
- Make sure that the RX queue related bits are cleared before setting
- Check if rx_queue_enable is available before executing
stmmac_mac_enable_rx_queues()

 drivers/net/ethernet/stmicro/stmmac/common.h      |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  9 +++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 12 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 22 ++++++++++++++++++++++
 5 files changed, 53 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index b13a144..6c96291 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -323,6 +323,9 @@ struct dma_features {
 	/* TX and RX number of channels */
 	unsigned int number_rx_channel;
 	unsigned int number_tx_channel;
+	/* TX and RX number of queues */
+	unsigned int number_rx_queues;
+	unsigned int number_tx_queues;
 	/* Alternate (enhanced) DESC mode */
 	unsigned int enh_desc;
 };
@@ -454,6 +457,8 @@ struct stmmac_ops {
 	void (*core_init)(struct mac_device_info *hw, int mtu);
 	/* Enable and verify that the IPC module is supported */
 	int (*rx_ipc)(struct mac_device_info *hw);
+	/* Enable RX Queues */
+	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 3e8d4fe..7d88517 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -22,6 +22,7 @@
 #define GMAC_HASH_TAB_32_63		0x00000014
 #define GMAC_RX_FLOW_CTRL		0x00000090
 #define GMAC_QX_TX_FLOW_CTRL(x)		(0x70 + x * 4)
+#define GMAC_RXQ_CTRL0			0x000000a0
 #define GMAC_INT_STATUS			0x000000b0
 #define GMAC_INT_EN			0x000000b4
 #define GMAC_PCS_BASE			0x000000e0
@@ -44,6 +45,12 @@
 
 #define GMAC_MAX_PERFECT_ADDRESSES	128
 
+/* MAC RX Queue Enable */
+#define GMAC_RX_QUEUE_CLEAR(queue)	~(BIT((queue) * 2) \
+					| BIT(((queue) * 2) + 1))
+#define GMAC_RX_AV_QUEUE_ENABLE(queue)	BIT((queue) * 2)
+#define GMAC_RX_DCB_QUEUE_ENABLE(queue)	BIT(((queue) * 2) + 1)
+
 /* MAC Flow Control RX */
 #define GMAC_RX_FLOW_CTRL_RFE		BIT(0)
 
@@ -133,6 +140,8 @@ enum power_event {
 /* MAC HW features2 bitmap */
 #define GMAC_HW_FEAT_TXCHCNT		GENMASK(21, 18)
 #define GMAC_HW_FEAT_RXCHCNT		GENMASK(15, 12)
+#define GMAC_HW_FEAT_TXQCNT		GENMASK(9, 6)
+#define GMAC_HW_FEAT_RXQCNT		GENMASK(3, 0)
 
 /* MAC HW ADDR regs */
 #define GMAC_HI_DCS			GENMASK(18, 16)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index eaed7cb..ecfbf57 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -59,6 +59,17 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	writel(value, ioaddr + GMAC_INT_EN);
 }
 
+static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
+
+	value &= GMAC_RX_QUEUE_CLEAR(queue);
+	value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
+
+	writel(value, ioaddr + GMAC_RXQ_CTRL0);
+}
+
 static void dwmac4_dump_regs(struct mac_device_info *hw)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -392,6 +403,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 static const struct stmmac_ops dwmac4_ops = {
 	.core_init = dwmac4_core_init,
 	.rx_ipc = dwmac4_rx_ipc_enable,
+	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 8196ab5..377d1b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -303,6 +303,11 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 		((hw_cap & GMAC_HW_FEAT_RXCHCNT) >> 12) + 1;
 	dma_cap->number_tx_channel =
 		((hw_cap & GMAC_HW_FEAT_TXCHCNT) >> 18) + 1;
+	/* TX and RX number of queues */
+	dma_cap->number_rx_queues =
+		((hw_cap & GMAC_HW_FEAT_RXQCNT) >> 0) + 1;
+	dma_cap->number_tx_queues =
+		((hw_cap & GMAC_HW_FEAT_TXQCNT) >> 6) + 1;
 
 	/* IEEE 1588-2002 */
 	dma_cap->time_stamp = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3e40578..20f0e80 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1271,6 +1271,24 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mac_enable_rx_queues - Enable MAC rx queues
+ *  @priv: driver private structure
+ *  Description: It is used for enabling the rx queues in the MAC
+ */
+static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
+{
+	int rx_count = priv->dma_cap.number_rx_queues;
+	int queue = 0;
+
+	/* If GMAC does not have multiqueues, then this is not necessary*/
+	if (rx_count == 1)
+		return;
+
+	for (queue = 0; queue < rx_count; queue++)
+		priv->hw->mac->rx_queue_enable(priv->hw, queue);
+}
+
+/**
  *  stmmac_dma_operation_mode - HW DMA operation mode
  *  @priv: driver private structure
  *  Description: it is used for configuring the DMA operation mode register in
@@ -1691,6 +1709,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->hw, dev->mtu);
 
+	/* Initialize MAC RX Queues */
+	if (priv->hw->mac->rx_queue_enable)
+		stmmac_mac_enable_rx_queues(priv);
+
 	ret = priv->hw->mac->rx_ipc(priv->hw);
 	if (!ret) {
 		netdev_warn(priv->dev, "RX IPC Checksum Offload disabled\n");
-- 
2.9.3
