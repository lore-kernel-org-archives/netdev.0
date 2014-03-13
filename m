From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V2 RE-SEND 5/7] net: sxgbe: add WOL(Wakeup-On-Lan)support for
 Samsung sxgbe
Date: Thu, 13 Mar 2014 15:56:09 +0900
Message-ID: <007e01cf3e89$500573d0$f0105b70$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ilho215.lee@samsung.com, ks.giri@samsung.com,
	'Joe Perches' <joe@perches.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Girish K S <ks.giri@samsung.com>

This patch adds support for wake up on magic frame arrival.
Also remote wake up on all other packets (unicast, multicast
broadcast) is supported.

Signed-off-by: Girish K S <ks.giri@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe_common.h   |   15 ++++++
 drivers/net/ethernet/samsung/sxgbe_core.c     |   29 ++++++++++
 drivers/net/ethernet/samsung/sxgbe_ethtool.c  |   47 ++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe_main.c     |   71 +++++++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe_mtl.c      |   43 ++++++++++++++-
 drivers/net/ethernet/samsung/sxgbe_mtl.h      |    4 ++
 drivers/net/ethernet/samsung/sxgbe_platform.c |    4 ++
 drivers/net/ethernet/samsung/sxgbe_reg.h      |    3 ++
 8 files changed, 215 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe_common.h
index 68e8ad4..b029181 100644
--- a/drivers/net/ethernet/samsung/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe_common.h
@@ -121,9 +121,18 @@ struct sxgbe_mtl_ops;
 #define RX_ENTRY_LPI_MODE	0x40
 #define RX_EXIT_LPI_MODE	0x80
 
+/* PMT mode bits */
+#define PMT_PWRDWN		BIT(0)
+#define PMT_MGPKT_EN		BIT(1)
+#define PMT_RWKPKT_EN		BIT(2)
+#define PMT_GUCAST_EN		BIT(9)
+
 /* EEE-LPI Interrupt status flag */
 #define LPI_INT_STATUS		BIT(5)
 
+/* PMT Interrupt status */
+#define PMT_INT_STATUS		BIT(4)
+
 /* EEE-LPI Default timer values */
 #define LPI_LINK_STATUS_TIMER	0x3E8
 #define LPI_MAC_WAIT_TIMER	0x00
@@ -225,6 +234,7 @@ struct sxgbe_extra_stats {
 	unsigned long rx_desc_access_err;
 	unsigned long rx_buffer_access_err;
 	unsigned long rx_data_transfer_err;
+	unsigned long pmt_irq_event_n;
 
 	/* EEE-LPI stats */
 	unsigned long tx_lpi_entry_n;
@@ -502,6 +512,11 @@ struct sxgbe_priv_data {
 	int eee_enabled;
 	int eee_active;
 	int tx_lpi_timer;
+
+	/* PM-WOL specific members */
+	int wolopts;
+	int wolenabled;
+	int wol_irq;
 };
 
 /* Function prototypes */
diff --git a/drivers/net/ethernet/samsung/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe_core.c
index 5885fd6..334d196 100644
--- a/drivers/net/ethernet/samsung/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe_core.c
@@ -78,12 +78,41 @@ static int sxgbe_core_host_irq_status(void __iomem *ioaddr,
 	if (unlikely(irq_status & LPI_INT_STATUS))
 		status |= sxgbe_get_lpi_status(ioaddr, irq_status);
 
+	if (unlikely(irq_status & PMT_INT_STATUS)) {
+		/* clear the PMT bits 5 and 6 by reading the PMT status reg */
+		readl(ioaddr + SXGBE_CORE_PMT_CTL_STATUS_REG);
+		x->pmt_irq_event_n++;
+	}
+
 	return status;
 }
 
 /* Set power management mode (e.g. magic frame) */
 static void sxgbe_core_pmt(void __iomem *ioaddr, unsigned long mode)
 {
+	unsigned int pmt = 0;
+
+	if (mode & WAKE_MAGIC) {
+		pr_debug("WOL Magic frame\n");
+		pmt |= PMT_MGPKT_EN;
+	}
+	if (mode & WAKE_UCAST) {
+		pr_debug("WOL on global unicast\n");
+		pmt |= PMT_GUCAST_EN;
+	}
+	if (mode & (WAKE_MCAST | WAKE_BCAST)) {
+		pr_debug("WOL on any other packet\n");
+		pmt |= PMT_RWKPKT_EN;
+	}
+
+	writel(pmt, ioaddr + SXGBE_CORE_PMT_CTL_STATUS_REG);
+
+	/* Enable power down bit if any of the requested mode is enabled */
+	if (pmt) {
+		writel(SXGBE_RX_ENABLE, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+		pmt |= PMT_PWRDWN;
+		writel(pmt, ioaddr + SXGBE_CORE_PMT_CTL_STATUS_REG);
+	}
 }
 
 /* Set/Get Unicast MAC addresses */
diff --git a/drivers/net/ethernet/samsung/sxgbe_ethtool.c b/drivers/net/ethernet/samsung/sxgbe_ethtool.c
index 9083300..89b1450 100644
--- a/drivers/net/ethernet/samsung/sxgbe_ethtool.c
+++ b/drivers/net/ethernet/samsung/sxgbe_ethtool.c
@@ -12,6 +12,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -37,6 +38,7 @@ static const struct sxgbe_stats sxgbe_gstrings_stats[] = {
 	SXGBE_STAT(rx_lpi_entry_n),
 	SXGBE_STAT(rx_lpi_exit_n),
 	SXGBE_STAT(eee_wakeup_error_n),
+	SXGBE_STAT(pmt_irq_event_n),
 };
 #define SXGBE_STATS_LEN ARRAY_SIZE(sxgbe_gstrings_stats)
 
@@ -80,9 +82,54 @@ static int sxgbe_ethtool_set_eee(struct net_device *dev,
 	return phy_ethtool_set_eee(priv->phydev, edata);
 }
 
+static void sxgbe_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	wol->wolopts = 0;
+	if (!device_can_wakeup(priv->device)) {
+		dev_err(priv->device, "cannot wakeup device\n");
+		return;
+	}
+
+	if (priv->hw_cap.pmt_magic_frame)
+		wol->supported |= WAKE_MAGIC;
+
+	if (priv->hw_cap.pmt_remote_wake_up)
+		wol->supported |= (WAKE_UCAST | WAKE_MCAST | WAKE_BCAST);
+
+	wol->wolopts = priv->wolopts;
+}
+
+static int sxgbe_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+
+	if (!device_can_wakeup(priv->device))
+		return -EOPNOTSUPP;
+
+	if (wol->wolopts) {
+		netdev_info(dev, "wakeup enable\n");
+		device_set_wakeup_enable(priv->device, true);
+		enable_irq_wake(priv->wol_irq);
+	} else {
+		device_set_wakeup_enable(priv->device, false);
+		disable_irq_wake(priv->wol_irq);
+	}
+
+	priv->wolopts = wol->wolopts;
+
+	return 0;
+}
+
 static const struct ethtool_ops sxgbe_ethtool_ops = {
 	.get_eee = sxgbe_ethtool_get_eee,
 	.set_eee = sxgbe_ethtool_set_eee,
+	.get_wol = sxgbe_get_wol,
+	.set_wol = sxgbe_set_wol,
 };
 
 void sxgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/samsung/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe_main.c
index e6b4406..21a06ae 100644
--- a/drivers/net/ethernet/samsung/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe_main.c
@@ -1146,6 +1146,18 @@ static int sxgbe_open(struct net_device *dev)
 		goto init_error;
 	}
 
+	/* Request the Wake IRQ in case of another line is used for WoL */
+	if (priv->wol_irq != dev->irq) {
+		ret = devm_request_irq(priv->device, priv->wol_irq,
+				       sxgbe_common_interrupt, IRQF_SHARED,
+				       dev->name, dev);
+		if (unlikely(ret < 0)) {
+			netdev_err(dev, "%s: ERROR: allocating the WoL IRQ %d (%d)\n",
+				   __func__, priv->wol_irq, ret);
+			goto init_error;
+		}
+	}
+
 	/* If the LPI irq is different from the mac irq
 	 * register a dedicated handler
 	 */
@@ -2100,6 +2112,27 @@ static int sxgbe_hw_init(struct sxgbe_priv_data * const priv)
 	return 0;
 }
 
+static void sxgbe_set_pmt_capabilities(struct sxgbe_priv_data *priv)
+{
+	u32 ctrl;
+
+	priv->wolopts = 0;
+
+	ctrl = readl(priv->ioaddr + SXGBE_CORE_PMT_CTL_STATUS_REG);
+	/* Enable maagic packet reception */
+	if (priv->hw_cap.pmt_magic_frame) {
+		priv->wolopts |= WAKE_MAGIC;
+		ctrl |= PMT_MGPKT_EN;
+	}
+	if (priv->hw_cap.pmt_remote_wake_up) {
+		priv->wolopts |= WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;
+		ctrl |= (PMT_RWKPKT_EN | PMT_GUCAST_EN);
+	}
+	writel(ctrl, priv->ioaddr + SXGBE_CORE_PMT_CTL_STATUS_REG);
+
+	device_init_wakeup(priv->device, true);
+}
+
 /**
  * sxgbe_dvr_probe
  * @device: device pointer
@@ -2229,6 +2262,7 @@ struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
 		goto error_mdio_register;
 	}
 
+	sxgbe_set_pmt_capabilities(priv);
 	sxgbe_check_ether_addr(priv);
 
 	return priv;
@@ -2277,11 +2311,48 @@ int sxgbe_dvr_remove(struct net_device *ndev)
 #ifdef CONFIG_PM
 int sxgbe_suspend(struct net_device *ndev)
 {
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+	struct netdev_hw_addr *ha;
+	int queue_num = 0, reg = 0;
+
+	/* Disable TX and wait till all frames flushed out */
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	sxgbe_tx_all_clean(priv);
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_flush_txqueue(priv->ioaddr, queue_num);
+
+	/* Disable RX and wait till all frames read into memory */
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_readout_rxqueue(priv->ioaddr, queue_num);
+
+	/* Enable Power down mode by programming the PMT regs */
+	if (device_may_wakeup(priv->device)) {
+		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
+	} else {
+		netdev_for_each_uc_addr(ha, ndev)
+			priv->hw->mac->set_umac_addr(priv->ioaddr, ha->addr,
+						     reg++);
+		/* Disable clock in case of PWM is off */
+		clk_disable_unprepare(priv->sxgbe_clk);
+	}
+
 	return 0;
 }
 
 int sxgbe_resume(struct net_device *ndev)
 {
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	if (device_may_wakeup(priv->device))
+		priv->hw->mac->pmt(priv->ioaddr, 0);
+	else
+		/* enable the clk prevously disabled */
+		clk_prepare_enable(priv->sxgbe_clk);
+
+	priv->hw->mac->enable_rx(priv->ioaddr, true);
+	priv->hw->mac->enable_tx(priv->ioaddr, true);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/samsung/sxgbe_mtl.c b/drivers/net/ethernet/samsung/sxgbe_mtl.c
index 3a1a3bb..8f687a8 100644
--- a/drivers/net/ethernet/samsung/sxgbe_mtl.c
+++ b/drivers/net/ethernet/samsung/sxgbe_mtl.c
@@ -164,6 +164,45 @@ static void sxgbe_mtl_fup_disable(void __iomem *ioaddr, int queue_num)
 	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
 }
 
+static int sxgbe_mtl_flush_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	unsigned long timeout;
+	u32 reg_val;
+
+	timeout = jiffies + msecs_to_jiffies(5);
+
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	while ((reg_val &
+		(SXGBE_MTL_TXQ_EMPTY_STAT | SXGBE_MTL_TXQ_WRITE_STAT))) {
+		if (time_after(jiffies, timeout)) {
+			pr_err("cannot flush tx queue - timeout\n");
+			return -ETIMEDOUT;
+		}
+		reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	}
+
+	return 0;
+}
+
+static int sxgbe_mtl_readout_rxqueue(void __iomem *ioaddr, int queue_num)
+{
+	unsigned long timeout;
+	u32 reg_val;
+
+	timeout = jiffies + msecs_to_jiffies(5);
+
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	while ((reg_val &
+		(SXGBE_MTL_TXQ_EMPTY_STAT | SXGBE_MTL_TXQ_WRITE_STAT))) {
+		if (time_after(jiffies, timeout)) {
+			pr_err("cannot flush tx queue - timeout\n");
+			return -ETIMEDOUT;
+		}
+		reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	}
+
+	return 0;
+}
 
 static void sxgbe_set_tx_mtl_mode(void __iomem *ioaddr, int queue_num,
 				  int tx_mode)
@@ -232,7 +271,9 @@ static const struct sxgbe_mtl_ops mtl_ops = {
 	.mtl_fep_enable = sxgbe_mtl_fep_enable,
 	.mtl_fep_disable = sxgbe_mtl_fep_disable,
 	.mtl_fup_enable = sxgbe_mtl_fup_enable,
-	.mtl_fup_disable = sxgbe_mtl_fup_disable
+	.mtl_fup_disable = sxgbe_mtl_fup_disable,
+	.mtl_flush_txqueue = sxgbe_mtl_flush_txqueue,
+	.mtl_readout_rxqueue = sxgbe_mtl_readout_rxqueue
 };
 
 const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe_mtl.h b/drivers/net/ethernet/samsung/sxgbe_mtl.h
index 7e4810c..b2f3f10 100644
--- a/drivers/net/ethernet/samsung/sxgbe_mtl.h
+++ b/drivers/net/ethernet/samsung/sxgbe_mtl.h
@@ -97,6 +97,10 @@ struct sxgbe_mtl_ops {
 	void (*mtl_fup_enable)(void __iomem *ioaddr, int queue_num);
 
 	void (*mtl_fup_disable)(void __iomem *ioaddr, int queue_num);
+
+	int (*mtl_flush_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	int (*mtl_readout_rxqueue)(void __iomem *ioaddr, int queue_num);
 };
 
 const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe_platform.c
index 2e2cb46..d8c1789 100644
--- a/drivers/net/ethernet/samsung/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe_platform.c
@@ -171,6 +171,10 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 	if (priv->lpi_irq == -ENXIO)
 		priv->lpi_irq = priv->dev->irq;
 
+	priv->wol_irq = irq_of_parse_and_map(dev->of_node, loop++);
+	if (priv->wol_irq == -ENXIO)
+		priv->wol_irq = priv->dev->irq;
+
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("platform driver registration completed\n");
diff --git a/drivers/net/ethernet/samsung/sxgbe_reg.h b/drivers/net/ethernet/samsung/sxgbe_reg.h
index 85a7b31..bd85923 100644
--- a/drivers/net/ethernet/samsung/sxgbe_reg.h
+++ b/drivers/net/ethernet/samsung/sxgbe_reg.h
@@ -257,6 +257,9 @@
 #define SXGBE_MTL_SFMODE		BIT(1)
 #define SXGBE_MTL_FIFO_LSHIFT		16
 #define SXGBE_MTL_ENABLE_QUEUE		0x00000008
+#define SXGBE_MTL_TXQ_EMPTY_STAT	BIT(4)
+#define SXGBE_MTL_TXQ_WRITE_STAT	BIT(3)
+
 #define SXGBE_MTL_TXQ_UNDERFLOW_REG(qnum)			\
 	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
 #define SXGBE_MTL_TXQ_DEBUG_REG(qnum)				\
-- 
1.7.10.4
