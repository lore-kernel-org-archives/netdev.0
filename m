From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V11 4/7] net: sxgbe: add EEE(Energy Efficient Ethernet) for
 Samsung sxgbe
Date: Fri, 21 Mar 2014 23:23:48 -0700
Message-ID: <007d01cf4597$4dda15b0$e98e4110$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:14911 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaCVGYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 02:24:00 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish K S <ks.giri@samsung.com>

Added support for the EEE(Energy Efficient Ethernet) in 10G ethernet driver.

Signed-off-by: Girish K S <ks.giri@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |   53 +++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |   86 +++++++++-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |   47 ++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |  165 +++++++++++++++++++-
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    4 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |    5 +
 6 files changed, 358 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index ec5271d..58e1ace 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -115,6 +115,33 @@ struct sxgbe_mtl_ops;
 #define RX_PTP_SIGNAL		0x0A
 #define RX_PTP_RESV_MSG		0x0F
 
+/* EEE-LPI mode  flags*/
+#define TX_ENTRY_LPI_MODE	0x10
+#define TX_EXIT_LPI_MODE	0x20
+#define RX_ENTRY_LPI_MODE	0x40
+#define RX_EXIT_LPI_MODE	0x80
+
+/* EEE-LPI Interrupt status flag */
+#define LPI_INT_STATUS		BIT(5)
+
+/* EEE-LPI Default timer values */
+#define LPI_LINK_STATUS_TIMER	0x3E8
+#define LPI_MAC_WAIT_TIMER	0x00
+
+/* EEE-LPI Control and status definitions */
+#define LPI_CTRL_STATUS_TXA	BIT(19)
+#define LPI_CTRL_STATUS_PLSDIS	BIT(18)
+#define LPI_CTRL_STATUS_PLS	BIT(17)
+#define LPI_CTRL_STATUS_LPIEN	BIT(16)
+#define LPI_CTRL_STATUS_TXRSTP	BIT(11)
+#define LPI_CTRL_STATUS_RXRSTP	BIT(10)
+#define LPI_CTRL_STATUS_RLPIST	BIT(9)
+#define LPI_CTRL_STATUS_TLPIST	BIT(8)
+#define LPI_CTRL_STATUS_RLPIEX	BIT(3)
+#define LPI_CTRL_STATUS_RLPIEN	BIT(2)
+#define LPI_CTRL_STATUS_TLPIEX	BIT(1)
+#define LPI_CTRL_STATUS_TLPIEN	BIT(0)
+
 enum dma_irq_status {
 	tx_hard_error	= BIT(0),
 	tx_bump_tc	= BIT(1),
@@ -199,6 +226,13 @@ struct sxgbe_extra_stats {
 	unsigned long rx_buffer_access_err;
 	unsigned long rx_data_transfer_err;
 
+	/* EEE-LPI stats */
+	unsigned long tx_lpi_entry_n;
+	unsigned long tx_lpi_exit_n;
+	unsigned long rx_lpi_entry_n;
+	unsigned long rx_lpi_exit_n;
+	unsigned long eee_wakeup_error_n;
+
 	/* RX specific */
 	/* L2 error */
 	unsigned long rx_code_gmii_err;
@@ -296,6 +330,13 @@ struct sxgbe_core_ops {
 				       unsigned char feature_index);
 	/* adjust SXGBE speed */
 	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
+
+	/* EEE-LPI specific operations */
+	void (*set_eee_mode)(void __iomem *ioaddr);
+	void (*reset_eee_mode)(void __iomem *ioaddr);
+	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
+			      const int tw);
+	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
@@ -352,6 +393,8 @@ struct sxgbe_hw_features {
 	/* IEEE 1588-2008 */
 	unsigned int atime_stamp;
 
+	unsigned int eee;
+
 	unsigned int tx_csum_offload;
 	unsigned int rx_csum_offload;
 	unsigned int multi_macaddr;
@@ -435,6 +478,13 @@ struct sxgbe_priv_data {
 	/* tc control */
 	int tx_tc;
 	int rx_tc;
+	/* EEE-LPI specific members */
+	struct timer_list eee_ctrl_timer;
+	bool tx_path_in_lpi_mode;
+	int lpi_irq;
+	int eee_enabled;
+	int eee_active;
+	int tx_lpi_timer;
 };
 
 /* Function prototypes */
@@ -457,4 +507,7 @@ int sxgbe_restore(struct net_device *ndev);
 
 const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void);
 
+void sxgbe_disable_eee_mode(struct sxgbe_priv_data * const priv);
+bool sxgbe_eee_init(struct sxgbe_priv_data * const priv);
+
 #endif /* __SXGBE_COMMON_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
index 4ad31bb..0164790 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
@@ -48,11 +48,38 @@ static void sxgbe_core_dump_regs(void __iomem *ioaddr)
 {
 }
 
+static int sxgbe_get_lpi_status(void __iomem *ioaddr, const u32 irq_status)
+{
+	int status = 0;
+	int lpi_status;
+
+	/* Reading this register shall clear all the LPI status bits */
+	lpi_status = readl(ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+
+	if (lpi_status & LPI_CTRL_STATUS_TLPIEN)
+		status |= TX_ENTRY_LPI_MODE;
+	if (lpi_status & LPI_CTRL_STATUS_TLPIEX)
+		status |= TX_EXIT_LPI_MODE;
+	if (lpi_status & LPI_CTRL_STATUS_RLPIEN)
+		status |= RX_ENTRY_LPI_MODE;
+	if (lpi_status & LPI_CTRL_STATUS_RLPIEX)
+		status |= RX_EXIT_LPI_MODE;
+
+	return status;
+}
+
 /* Handle extra events on specific interrupts hw dependent */
 static int sxgbe_core_host_irq_status(void __iomem *ioaddr,
 				      struct sxgbe_extra_stats *x)
 {
-	return 0;
+	int irq_status, status = 0;
+
+	irq_status = readl(ioaddr + SXGBE_CORE_INT_STATUS_REG);
+
+	if (unlikely(irq_status & LPI_INT_STATUS))
+		status |= sxgbe_get_lpi_status(ioaddr, irq_status);
+
+	return status;
 }
 
 /* Set power management mode (e.g. magic frame) */
@@ -138,6 +165,59 @@ static void sxgbe_core_set_speed(void __iomem *ioaddr, unsigned char speed)
 	writel(tx_cfg, ioaddr + SXGBE_CORE_TX_CONFIG_REG);
 }
 
+static void  sxgbe_set_eee_mode(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	/* Enable the LPI mode for transmit path with Tx automate bit set.
+	 * When Tx Automate bit is set, MAC internally handles the entry
+	 * to LPI mode after all outstanding and pending packets are
+	 * transmitted.
+	 */
+	ctrl = readl(ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+	ctrl |= LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_TXA;
+	writel(ctrl, ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+}
+
+static void  sxgbe_reset_eee_mode(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+	ctrl &= ~(LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_TXA);
+	writel(ctrl, ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+}
+
+static void  sxgbe_set_eee_pls(void __iomem *ioaddr, const int link)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+
+	/* If the PHY link status is UP then set PLS */
+	if (link)
+		ctrl |= LPI_CTRL_STATUS_PLS;
+	else
+		ctrl &= ~LPI_CTRL_STATUS_PLS;
+
+	writel(ctrl, ioaddr + SXGBE_CORE_LPI_CTRL_STATUS);
+}
+
+static void  sxgbe_set_eee_timer(void __iomem *ioaddr,
+				 const int ls, const int tw)
+{
+	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
+
+	/* Program the timers in the LPI timer control register:
+	 * LS: minimum time (ms) for which the link
+	 *  status from PHY should be ok before transmitting
+	 *  the LPI pattern.
+	 * TW: minimum time (us) for which the core waits
+	 *  after it has stopped transmitting the LPI pattern.
+	 */
+	writel(value, ioaddr + SXGBE_CORE_LPI_TIMER_CTRL);
+}
+
 const struct sxgbe_core_ops core_ops = {
 	.core_init		= sxgbe_core_init,
 	.dump_regs		= sxgbe_core_dump_regs,
@@ -150,6 +230,10 @@ const struct sxgbe_core_ops core_ops = {
 	.get_controller_version	= sxgbe_get_controller_version,
 	.get_hw_feature		= sxgbe_get_hw_feature,
 	.set_speed		= sxgbe_core_set_speed,
+	.set_eee_mode		= sxgbe_set_eee_mode,
+	.reset_eee_mode		= sxgbe_reset_eee_mode,
+	.set_eee_timer		= sxgbe_set_eee_timer,
+	.set_eee_pls		= sxgbe_set_eee_pls,
 };
 
 const struct sxgbe_core_ops *sxgbe_get_core_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
index 1dce2b2..9083300 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
@@ -32,10 +32,57 @@ struct sxgbe_stats {
 }
 
 static const struct sxgbe_stats sxgbe_gstrings_stats[] = {
+	SXGBE_STAT(tx_lpi_entry_n),
+	SXGBE_STAT(tx_lpi_exit_n),
+	SXGBE_STAT(rx_lpi_entry_n),
+	SXGBE_STAT(rx_lpi_exit_n),
+	SXGBE_STAT(eee_wakeup_error_n),
 };
 #define SXGBE_STATS_LEN ARRAY_SIZE(sxgbe_gstrings_stats)
 
+static int sxgbe_ethtool_get_eee(struct net_device *dev,
+				 struct ethtool_eee *edata)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	if (!priv->hw_cap.eee)
+		return -EOPNOTSUPP;
+
+	edata->eee_enabled = priv->eee_enabled;
+	edata->eee_active = priv->eee_active;
+	edata->tx_lpi_timer = priv->tx_lpi_timer;
+
+	return phy_ethtool_get_eee(priv->phydev, edata);
+}
+
+static int sxgbe_ethtool_set_eee(struct net_device *dev,
+				 struct ethtool_eee *edata)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	priv->eee_enabled = edata->eee_enabled;
+
+	if (!priv->eee_enabled) {
+		sxgbe_disable_eee_mode(priv);
+	} else {
+		/* We are asking for enabling the EEE but it is safe
+		 * to verify all by invoking the eee_init function.
+		 * In case of failure it will return an error.
+		 */
+		priv->eee_enabled = sxgbe_eee_init(priv);
+		if (!priv->eee_enabled)
+			return -EOPNOTSUPP;
+
+		/* Do not change tx_lpi_timer in case of failure */
+		priv->tx_lpi_timer = edata->tx_lpi_timer;
+	}
+
+	return phy_ethtool_set_eee(priv->phydev, edata);
+}
+
 static const struct ethtool_ops sxgbe_ethtool_ops = {
+	.get_eee = sxgbe_ethtool_get_eee,
+	.set_eee = sxgbe_ethtool_set_eee,
 };
 
 void sxgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 7b03dc0..b4b7689 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -56,6 +56,9 @@
 #define SXGBE_DEFAULT_LPI_TIMER	1000
 
 static int debug = -1;
+static int eee_timer = SXGBE_DEFAULT_LPI_TIMER;
+
+module_param(eee_timer, int, S_IRUGO | S_IWUSR);
 
 module_param(debug, int, S_IRUGO | S_IWUSR);
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
@@ -68,6 +71,97 @@ static irqreturn_t sxgbe_rx_interrupt(int irq, void *dev_id);
 
 #define SXGBE_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
 
+#define SXGBE_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
+
+/**
+ * sxgbe_verify_args - verify the driver parameters.
+ * Description: it verifies if some wrong parameter is passed to the driver.
+ * Note that wrong parameters are replaced with the default values.
+ */
+static void sxgbe_verify_args(void)
+{
+	if (unlikely(eee_timer < 0))
+		eee_timer = SXGBE_DEFAULT_LPI_TIMER;
+}
+
+static void sxgbe_enable_eee_mode(const struct sxgbe_priv_data *priv)
+{
+	/* Check and enter in LPI mode */
+	if (!priv->tx_path_in_lpi_mode)
+		priv->hw->mac->set_eee_mode(priv->ioaddr);
+}
+
+void sxgbe_disable_eee_mode(struct sxgbe_priv_data * const priv)
+{
+	/* Exit and disable EEE in case of we are are in LPI state. */
+	priv->hw->mac->reset_eee_mode(priv->ioaddr);
+	del_timer_sync(&priv->eee_ctrl_timer);
+	priv->tx_path_in_lpi_mode = false;
+}
+
+/**
+ * sxgbe_eee_ctrl_timer
+ * @arg : data hook
+ * Description:
+ *  If there is no data transfer and if we are not in LPI state,
+ *  then MAC Transmitter can be moved to LPI state.
+ */
+static void sxgbe_eee_ctrl_timer(unsigned long arg)
+{
+	struct sxgbe_priv_data *priv = (struct sxgbe_priv_data *)arg;
+
+	sxgbe_enable_eee_mode(priv);
+	mod_timer(&priv->eee_ctrl_timer, SXGBE_LPI_TIMER(eee_timer));
+}
+
+/**
+ * sxgbe_eee_init
+ * @priv: private device pointer
+ * Description:
+ *  If the EEE support has been enabled while configuring the driver,
+ *  if the GMAC actually supports the EEE (from the HW cap reg) and the
+ *  phy can also manage EEE, so enable the LPI state and start the timer
+ *  to verify if the tx path can enter in LPI state.
+ */
+bool sxgbe_eee_init(struct sxgbe_priv_data * const priv)
+{
+	bool ret = false;
+
+	/* MAC core supports the EEE feature. */
+	if (priv->hw_cap.eee) {
+		/* Check if the PHY supports EEE */
+		if (phy_init_eee(priv->phydev, 1))
+			return false;
+
+		priv->eee_active = 1;
+		init_timer(&priv->eee_ctrl_timer);
+		priv->eee_ctrl_timer.function = sxgbe_eee_ctrl_timer;
+		priv->eee_ctrl_timer.data = (unsigned long)priv;
+		priv->eee_ctrl_timer.expires = SXGBE_LPI_TIMER(eee_timer);
+		add_timer(&priv->eee_ctrl_timer);
+
+		priv->hw->mac->set_eee_timer(priv->ioaddr,
+					     SXGBE_DEFAULT_LPI_TIMER,
+					     priv->tx_lpi_timer);
+
+		pr_info("Energy-Efficient Ethernet initialized\n");
+
+		ret = true;
+	}
+
+	return ret;
+}
+
+static void sxgbe_eee_adjust(const struct sxgbe_priv_data *priv)
+{
+	/* When the EEE has been already initialised we have to
+	 * modify the PLS bit in the LPI ctrl & status reg according
+	 * to the PHY link status. For this reason.
+	 */
+	if (priv->eee_enabled)
+		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
+}
+
 /**
  * sxgbe_clk_csr_set - dynamically set the MDC clock
  * @priv: driver private structure
@@ -157,6 +251,9 @@ static void sxgbe_adjust_link(struct net_device *dev)
 
 	if (new_state & netif_msg_link(priv))
 		phy_print_status(phydev);
+
+	/* Alter the MAC settings for EEE */
+	sxgbe_eee_adjust(priv);
 }
 
 /**
@@ -679,7 +776,7 @@ static void sxgbe_tx_queue_clean(struct sxgbe_tx_queue *tqueue)
  * @priv: driver private structure
  * Description: it reclaims resources after transmission completes.
  */
-static void sxgbe_tx_all_clean(struct sxgbe_priv_data *priv)
+static void sxgbe_tx_all_clean(struct sxgbe_priv_data * const priv)
 {
 	u8 queue_num;
 
@@ -688,6 +785,11 @@ static void sxgbe_tx_all_clean(struct sxgbe_priv_data *priv)
 
 		sxgbe_tx_queue_clean(tqueue);
 	}
+
+	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
+		sxgbe_enable_eee_mode(priv);
+		mod_timer(&priv->eee_ctrl_timer, SXGBE_LPI_TIMER(eee_timer));
+	}
 }
 
 /**
@@ -769,6 +871,7 @@ static int sxgbe_get_hw_features(struct sxgbe_priv_data * const priv)
 		features->multi_macaddr = SXGBE_HW_FEAT_MACADDR_COUNT(rval);
 		features->tstamp_srcselect = SXGBE_HW_FEAT_TSTMAP_SRC(rval);
 		features->sa_vlan_insert = SXGBE_HW_FEAT_SRCADDR_VLAN(rval);
+		features->eee = SXGBE_HW_FEAT_EEE(rval);
 	}
 
 	/* Read First Capability Register CAP[1] */
@@ -986,6 +1089,20 @@ static int sxgbe_open(struct net_device *dev)
 		goto init_error;
 	}
 
+	/* If the LPI irq is different from the mac irq
+	 * register a dedicated handler
+	 */
+	if (priv->lpi_irq != dev->irq) {
+		ret = devm_request_irq(priv->device, priv->lpi_irq,
+				       sxgbe_common_interrupt,
+				       IRQF_SHARED, dev->name, dev);
+		if (unlikely(ret < 0)) {
+			netdev_err(dev, "%s: ERROR: allocating the LPI IRQ %d (%d)\n",
+				   __func__, priv->lpi_irq, ret);
+			goto init_error;
+		}
+	}
+
 	/* Request TX DMA irq lines */
 	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
 		ret = devm_request_irq(priv->device,
@@ -1041,6 +1158,9 @@ static int sxgbe_open(struct net_device *dev)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, SXGBE_MAX_DMA_RIWT);
 	}
 
+	priv->tx_lpi_timer = SXGBE_DEFAULT_LPI_TIMER;
+	priv->eee_enabled = sxgbe_eee_init(priv);
+
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
@@ -1066,6 +1186,9 @@ static int sxgbe_release(struct net_device *dev)
 {
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
 
+	if (priv->eee_enabled)
+		del_timer_sync(&priv->eee_ctrl_timer);
+
 	/* Stop and disconnect the PHY */
 	if (priv->phydev) {
 		phy_stop(priv->phydev);
@@ -1159,6 +1282,9 @@ static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* get the spinlock */
 	spin_lock(&tqueue->tx_lock);
 
+	if (priv->tx_path_in_lpi_mode)
+		sxgbe_disable_eee_mode(priv);
+
 	if (unlikely(sxgbe_tx_avail(tqueue, tx_rsize) < nr_frags + 1)) {
 		if (!netif_tx_queue_stopped(dev_txq)) {
 			netif_tx_stop_queue(dev_txq);
@@ -1441,6 +1567,25 @@ static void sxgbe_tx_timeout(struct net_device *dev)
  */
 static irqreturn_t sxgbe_common_interrupt(int irq, void *dev_id)
 {
+	struct net_device *netdev = (struct net_device *)dev_id;
+	struct sxgbe_priv_data *priv = netdev_priv(netdev);
+	int status;
+
+	status = priv->hw->mac->host_irq_status(priv->ioaddr, &priv->xstats);
+	/* For LPI we need to save the tx status */
+	if (status & TX_ENTRY_LPI_MODE) {
+		priv->xstats.tx_lpi_entry_n++;
+		priv->tx_path_in_lpi_mode = true;
+	}
+	if (status & TX_EXIT_LPI_MODE) {
+		priv->xstats.tx_lpi_exit_n++;
+		priv->tx_path_in_lpi_mode = false;
+	}
+	if (status & RX_ENTRY_LPI_MODE)
+		priv->xstats.rx_lpi_entry_n++;
+	if (status & RX_EXIT_LPI_MODE)
+		priv->xstats.rx_lpi_exit_n++;
+
 	return IRQ_HANDLED;
 }
 
@@ -1936,6 +2081,9 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	priv->plat = plat_dat;
 	priv->ioaddr = addr;
 
+	/* Verify driver arguments */
+	sxgbe_verify_args();
+
 	/* Init MAC and get the capabilities */
 	sxgbe_hw_init(priv);
 
@@ -2107,7 +2255,21 @@ module_exit(sxgbe_exit);
 #ifndef MODULE
 static int __init sxgbe_cmdline_opt(char *str)
 {
+	char *opt;
+
+	if (!str || !*str)
+		return -EINVAL;
+	while ((opt = strsep(&str, ",")) != NULL) {
+		if (!strncmp(opt, "eee_timer:", 6)) {
+			if (kstrtoint(opt + 10, 0, &eee_timer))
+				goto err;
+		}
+	}
 	return 0;
+
+err:
+	pr_err("%s: ERROR broken module parameter conversion\n", __func__);
+	return -EINVAL;
 }
 
 __setup("sxgbeeth=", sxgbe_cmdline_opt);
@@ -2118,6 +2280,7 @@ __setup("sxgbeeth=", sxgbe_cmdline_opt);
 MODULE_DESCRIPTION("SAMSUNG 10G/2.5G/1G Ethernet PLATFORM driver");
 
 MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
+MODULE_PARM_DESC(eee_timer, "EEE-LPI Default LS timer value");
 
 MODULE_AUTHOR("Siva Reddy Kallam <siva.kallam@samsung.com>");
 MODULE_AUTHOR("ByungHo An <bh74.an@samsung.com>");
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
index 95e0977..3b58459 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -147,6 +147,10 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 		}
 	}
 
+	priv->lpi_irq = platform_get_irq(pdev, loop++);
+	if (priv->lpi_irq == -ENXIO)
+		priv->lpi_irq = priv->dev->irq;
+
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("platform driver registration completed\n");
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
index d1cd9ac..85a7b31 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
@@ -25,6 +25,11 @@
 #define SXGBE_CORE_HASH_TABLE_REG5	0x0024
 #define SXGBE_CORE_HASH_TABLE_REG6	0x0028
 #define SXGBE_CORE_HASH_TABLE_REG7	0x002C
+
+/* EEE-LPI Registers */
+#define SXGBE_CORE_LPI_CTRL_STATUS	0x00D0
+#define SXGBE_CORE_LPI_TIMER_CTRL	0x00D4
+
 /* VLAN Specific Registers */
 #define SXGBE_CORE_VLAN_TAG_REG		0x0050
 #define SXGBE_CORE_VLAN_HASHTAB_REG	0x0058
-- 
1.7.10.4
