From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: Added rxqueue enable function
Date: Tue, 29 Apr 2014 13:15:17 +0900
Message-ID: <001c01cf6361$a0df9ae0$e29ed0a0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds rxqueue enable function according to number of rxqueue
and adds rxqueue disable function for removing.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h |    2 ++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c   |   22 +++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c   |    8 ++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h    |    4 ++++
 4 files changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index 6203c7d..4501964 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -358,6 +358,8 @@ struct sxgbe_core_ops {
 	/* Enable disable checksum offload operations */
 	void (*enable_rx_csum)(void __iomem *ioaddr);
 	void (*disable_rx_csum)(void __iomem *ioaddr);
+	void (*enable_rxqueue)(void __iomem *ioaddr, int queue_num);
+	void (*disable_rxqueue)(void __iomem *ioaddr, int queue_num);
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
index c4da7a2..58c3569 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
@@ -165,6 +165,26 @@ static void sxgbe_core_set_speed(void __iomem *ioaddr, unsigned char speed)
 	writel(tx_cfg, ioaddr + SXGBE_CORE_TX_CONFIG_REG);
 }
 
+static void sxgbe_core_enable_rxqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_CORE_RX_CTL0_REG);
+	reg_val &= ~(SXGBE_CORE_RXQ_ENABLE_MASK << queue_num);
+	reg_val |= SXGBE_CORE_RXQ_ENABLE;
+	writel(reg_val, ioaddr + SXGBE_CORE_RX_CTL0_REG);
+}
+
+static void sxgbe_core_disable_rxqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_CORE_RX_CTL0_REG);
+	reg_val &= ~(SXGBE_CORE_RXQ_ENABLE_MASK << queue_num);
+	reg_val |= SXGBE_CORE_RXQ_DISABLE;
+	writel(reg_val, ioaddr + SXGBE_CORE_RX_CTL0_REG);
+}
+
 static void  sxgbe_set_eee_mode(void __iomem *ioaddr)
 {
 	u32 ctrl;
@@ -254,6 +274,8 @@ static const struct sxgbe_core_ops core_ops = {
 	.set_eee_pls		= sxgbe_set_eee_pls,
 	.enable_rx_csum		= sxgbe_enable_rx_csum,
 	.disable_rx_csum	= sxgbe_disable_rx_csum,
+	.enable_rxqueue		= sxgbe_core_enable_rxqueue,
+	.disable_rxqueue	= sxgbe_core_disable_rxqueue,
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 6ad7b3a..fd5c428 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1076,6 +1076,9 @@ static int sxgbe_open(struct net_device *dev)
 
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		priv->hw->mac->enable_rxqueue(priv->ioaddr, queue_num);
+	}
 
 	/* Request the IRQ lines */
 	ret = devm_request_irq(priv->device, priv->irq, sxgbe_common_interrupt,
@@ -2240,9 +2243,14 @@ error_free_netdev:
 int sxgbe_drv_remove(struct net_device *ndev)
 {
 	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+	u8 queue_num;
 
 	netdev_info(ndev, "%s: removing driver\n", __func__);
 
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		priv->hw->mac->disable_rxqueue(priv->ioaddr, queue_num);
+	}
+
 	priv->hw->dma->stop_rx(priv->ioaddr, SXGBE_RX_QUEUES);
 	priv->hw->dma->stop_tx(priv->ioaddr, SXGBE_TX_QUEUES);
 
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
index 5a89acb..56f8bf5 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
@@ -52,6 +52,10 @@
 #define SXGBE_CORE_RX_CTL2_REG		0x00A8
 #define SXGBE_CORE_RX_CTL3_REG		0x00AC
 
+#define SXGBE_CORE_RXQ_ENABLE_MASK	0x0003
+#define SXGBE_CORE_RXQ_ENABLE		0x0002
+#define SXGBE_CORE_RXQ_DISABLE		0x0000
+
 /* Interrupt Registers */
 #define SXGBE_CORE_INT_STATUS_REG	0x00B0
 #define SXGBE_CORE_INT_ENABLE_REG	0x00B4
-- 
1.7.10.4
