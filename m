From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 5/7] net: xgmac: add WOL(Wakeup-On-Lan)support for Samsung xgmac
Date: Wed, 05 Mar 2014 20:28:27 +0900
Message-ID: <007f01cf3866$076a2450$163e6cf0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Girish K S <ks.giri@samsung.com>

This patch adds support for wake up on magic frame arrival.
Also remote wake up on all other packets (unicast, multicast
broadcast) is supported.

Signed-off-by: Girish K S <ks.giri@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/xgmac_common.h   |   15 ++++++
 drivers/net/ethernet/samsung/xgmac_core.c     |   29 ++++++++++
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |   47 ++++++++++++++++
 drivers/net/ethernet/samsung/xgmac_main.c     |   71 +++++++++++++++++++++++++
 drivers/net/ethernet/samsung/xgmac_mtl.c      |   43 ++++++++++++++-
 drivers/net/ethernet/samsung/xgmac_mtl.h      |    4 ++
 drivers/net/ethernet/samsung/xgmac_platform.c |    4 ++
 drivers/net/ethernet/samsung/xgmac_reg.h      |    3 ++
 8 files changed, 215 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
index 349cddc..b7764aa 100644
--- a/drivers/net/ethernet/samsung/xgmac_common.h
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -124,9 +124,18 @@ struct xgmac_mtl_ops;
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
@@ -228,6 +237,7 @@ struct xgmac_extra_stats {
 	unsigned long rx_desc_access_err;
 	unsigned long rx_buffer_access_err;
 	unsigned long rx_data_transfer_err;
+	unsigned long pmt_irq_event_n;
 
 	/* EEE-LPI stats */
 	unsigned long tx_lpi_entry_n;
@@ -506,6 +516,11 @@ struct xgmac_priv_data {
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
diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index 43d093c..8fa2241 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -77,12 +77,41 @@ static int xgmac_core_host_irq_status(void __iomem *ioaddr,
 	if (unlikely(irq_status & LPI_INT_STATUS))
 		status |= xgmac_get_lpi_status(ioaddr, irq_status);
 
+	if (unlikely(irq_status & PMT_INT_STATUS)) {
+		/* clear the PMT bits 5 and 6 by reading the PMT status reg */
+		readl(ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
+		x->pmt_irq_event_n++;
+	}
+
 	return status;
 }
 
 /* Set power management mode (e.g. magic frame) */
 static void xgmac_core_pmt(void __iomem *ioaddr, unsigned long mode)
 {
+	unsigned int pmt = 0;
+
+	if (mode & WAKE_MAGIC) {
+		pr_debug("GMAC: WOL Magic frame\n");
+		pmt |= PMT_MGPKT_EN;
+	}
+	if (mode & WAKE_UCAST) {
+		pr_debug("GMAC: WOL on global unicast\n");
+		pmt |= PMT_GUCAST_EN;
+	}
+	if (mode & (WAKE_MCAST | WAKE_BCAST)) {
+		pr_debug("GMAC: WOL on any other packet\n");
+		pmt |= PMT_RWKPKT_EN;
+	}
+
+	writel(pmt, ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
+
+	/* Enable power down bit if any of the requested mode is enabled */
+	if (pmt) {
+		writel(XGMAC_RX_ENABLE, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+		 pmt |= PMT_PWRDWN;
+		writel(pmt, ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
+	}
 }
 
 /* Set/Get Unicast MAC addresses */
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 48ef13e..08d0b17 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -9,6 +9,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
@@ -31,6 +32,7 @@ static const struct xgmac_stats xgmac_gstrings_stats[] = {
 	XGMAC_STAT(rx_lpi_entry_n),
 	XGMAC_STAT(rx_lpi_exit_n),
 	XGMAC_STAT(eee_wakeup_error_n),
+	XGMAC_STAT(pmt_irq_event_n),
 };
 #define XGMAC_STATS_LEN ARRAY_SIZE(xgmac_gstrings_stats)
 
@@ -74,9 +76,54 @@ static int xgmac_ethtool_set_eee(struct net_device *dev,
 	return phy_ethtool_set_eee(priv->phydev, edata);
 }
 
+static void xgmac_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
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
+static int xgmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+
+	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+
+	if (!device_can_wakeup(priv->device))
+		return -EOPNOTSUPP;
+
+	if (wol->wolopts) {
+		pr_info("stmmac: wakeup enable\n");
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
 static const struct ethtool_ops xgmac_ethtool_ops = {
 	.get_eee = xgmac_ethtool_get_eee,
 	.set_eee = xgmac_ethtool_set_eee,
+	.get_wol = xgmac_get_wol,
+	.set_wol = xgmac_set_wol,
 };
 
 void xgmac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index d1f746a..bc6f879 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -1162,6 +1162,18 @@ static int xgmac_open(struct net_device *dev)
 		goto init_error;
 	}
 
+	/* Request the Wake IRQ in case of another line is used for WoL */
+	if (priv->wol_irq != dev->irq) {
+		ret = devm_request_irq(priv->device, priv->wol_irq,
+				xgmac_common_interrupt, IRQF_SHARED,
+				dev->name, dev);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating the WoL IRQ %d (%d)\n",
+			       __func__, priv->wol_irq, ret);
+			goto init_error;
+		}
+	}
+
 	/* If the LPI irq is different from the mac irq
 	 * register a dedicated handler
 	 */
@@ -2115,6 +2127,27 @@ static int xgmac_hw_init(struct xgmac_priv_data * const priv)
 	return 0;
 }
 
+static void xgmac_set_pmt_capabilities(struct xgmac_priv_data *priv)
+{
+	u32 ctrl;
+
+	priv->wolopts = 0;
+
+	ctrl = readl(priv->ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
+	/* Enable maagic packet reception */
+	if (priv->hw_cap.pmt_magic_frame) {
+		priv->wolopts |= WAKE_MAGIC;
+		ctrl |= PMT_MGPKT_EN;
+	}
+	if (priv->hw_cap.pmt_remote_wake_up) {
+		priv->wolopts |= WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;
+		ctrl |= (PMT_RWKPKT_EN | PMT_GUCAST_EN);
+	}
+	writel(ctrl, priv->ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
+
+	device_init_wakeup(priv->device, true);
+}
+
 /**
  * xgmac_dvr_probe
  * @device: device pointer
@@ -2243,6 +2276,7 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 		goto error_mdio_register;
 	}
 
+	xgmac_set_pmt_capabilities(priv);
 	xgmac_check_ether_addr(priv);
 
 	return priv;
@@ -2291,11 +2325,48 @@ int xgmac_dvr_remove(struct net_device *ndev)
 #ifdef CONFIG_PM
 int xgmac_suspend(struct net_device *ndev)
 {
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+	struct netdev_hw_addr *ha;
+	int queue_num = 0, reg = 0;
+
+	/* Disable TX and wait till all frames flushed out */
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	xgmac_tx_all_clean(priv);
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_flush_txqueue(priv->ioaddr, queue_num);
+
+	/* Disable RX and wait till all frames read into memory */
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_readout_rxqueue(priv->ioaddr, queue_num);
+
+	/* Enable Power down mode by programming the PMT regs */
+	if (device_may_wakeup(priv->device))
+		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
+	else {
+		netdev_for_each_uc_addr(ha, ndev)
+			priv->hw->mac->set_umac_addr(priv->ioaddr, ha->addr,
+						     reg++);
+		/* Disable clock in case of PWM is off */
+		clk_disable_unprepare(priv->xgmac_clk);
+	}
+
 	return 0;
 }
 
 int xgmac_resume(struct net_device *ndev)
 {
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+
+	if (device_may_wakeup(priv->device))
+		priv->hw->mac->pmt(priv->ioaddr, 0);
+	else
+		/* enable the clk prevously disabled */
+		clk_prepare_enable(priv->xgmac_clk);
+
+	priv->hw->mac->enable_rx(priv->ioaddr, true);
+	priv->hw->mac->enable_tx(priv->ioaddr, true);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.c b/drivers/net/ethernet/samsung/xgmac_mtl.c
index c842aa0..85e0132 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.c
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.c
@@ -161,6 +161,45 @@ static void xgmac_mtl_fup_disable(void __iomem *ioaddr, int queue_num)
 	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
 }
 
+static int xgmac_mtl_flush_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	unsigned long timeout;
+	u32 reg_val;
+
+	timeout = jiffies + msecs_to_jiffies(5);
+
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	while ((reg_val &
+		(XGMAC_MTL_TXQ_EMPTY_STAT | XGMAC_MTL_TXQ_WRITE_STAT))) {
+		if (time_after(jiffies, timeout)) {
+			pr_err("cannot flush tx queue - timeout");
+			return -ETIMEDOUT;
+		}
+		reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	}
+
+	return 0;
+}
+
+static int xgmac_mtl_readout_rxqueue(void __iomem *ioaddr, int queue_num)
+{
+	unsigned long timeout;
+	u32 reg_val;
+
+	timeout = jiffies + msecs_to_jiffies(5);
+
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	while ((reg_val &
+		(XGMAC_MTL_TXQ_EMPTY_STAT | XGMAC_MTL_TXQ_WRITE_STAT))) {
+		if (time_after(jiffies, timeout)) {
+			pr_err("cannot flush tx queue - timeout");
+			return -ETIMEDOUT;
+		}
+		reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	}
+
+	return 0;
+}
 
 static void xgmac_set_tx_mtl_mode(void __iomem *ioaddr, int queue_num,
 				  int tx_mode)
@@ -229,7 +268,9 @@ static const struct xgmac_mtl_ops mtl_ops = {
 	.mtl_fep_enable = xgmac_mtl_fep_enable,
 	.mtl_fep_disable = xgmac_mtl_fep_disable,
 	.mtl_fup_enable = xgmac_mtl_fup_enable,
-	.mtl_fup_disable = xgmac_mtl_fup_disable
+	.mtl_fup_disable = xgmac_mtl_fup_disable,
+	.mtl_flush_txqueue = xgmac_mtl_flush_txqueue,
+	.mtl_readout_rxqueue = xgmac_mtl_readout_rxqueue
 };
 
 const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void)
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.h b/drivers/net/ethernet/samsung/xgmac_mtl.h
index 888fa8f..bacd5e3 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.h
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.h
@@ -97,6 +97,10 @@ struct xgmac_mtl_ops {
 	void (*mtl_fup_enable)(void __iomem *ioaddr, int queue_num);
 
 	void (*mtl_fup_disable)(void __iomem *ioaddr, int queue_num);
+
+	int (*mtl_flush_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	int (*mtl_readout_rxqueue)(void __iomem *ioaddr, int queue_num);
 };
 
 const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
index e988e38..d0cf6cf 100644
--- a/drivers/net/ethernet/samsung/xgmac_platform.c
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -170,6 +170,10 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 	if (priv->lpi_irq == -ENXIO)
 		priv->lpi_irq = priv->dev->irq;
 
+	priv->wol_irq = irq_of_parse_and_map(dev->of_node, loop++);
+	if (priv->wol_irq == -ENXIO)
+		priv->wol_irq = priv->dev->irq;
+
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("XGMAC platform driver registration completed");
diff --git a/drivers/net/ethernet/samsung/xgmac_reg.h b/drivers/net/ethernet/samsung/xgmac_reg.h
index 87fbff0..0b0d927 100644
--- a/drivers/net/ethernet/samsung/xgmac_reg.h
+++ b/drivers/net/ethernet/samsung/xgmac_reg.h
@@ -257,6 +257,9 @@
 #define XGMAC_MTL_SFMODE		BIT(1)
 #define XGMAC_MTL_FIFO_LSHIFT		16
 #define XGMAC_MTL_ENABLE_QUEUE		0x00000008
+#define XGMAC_MTL_TXQ_EMPTY_STAT	BIT(4)
+#define XGMAC_MTL_TXQ_WRITE_STAT	BIT(3)
+
 #define XGMAC_MTL_TXQ_UNDERFLOW_REG(qnum) \
 		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
 #define XGMAC_MTL_TXQ_DEBUG_REG(qnum) \
-- 
1.7.10.4
