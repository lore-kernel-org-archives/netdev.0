From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 3/7] net: xgmac: add EEE(Energy Efficient Ethernet) for Samsung
 xgmac
Date: Wed, 05 Mar 2014 20:28:22 +0900
Message-ID: <007d01cf3866$04478790$0cd696b0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, ilho215.lee@samsung.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:44062 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbaCEL2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:28:24 -0500
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish K S <ks.giri@samsung.com>

Added support for the EEE(Energy Efficient Ethernet)
in 10G ethernet driver.

Signed-off-by: Girish K S <ks.giri@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/xgmac_common.h   |   54 +++++++++
 drivers/net/ethernet/samsung/xgmac_core.c     |   86 +++++++++++++-
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |   47 ++++++++
 drivers/net/ethernet/samsung/xgmac_main.c     |  152 ++++++++++++++++++++++++-
 drivers/net/ethernet/samsung/xgmac_platform.c |    4 +
 drivers/net/ethernet/samsung/xgmac_reg.h      |    5 +
 6 files changed, 346 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
index eb78c84..6b7f1de 100644
--- a/drivers/net/ethernet/samsung/xgmac_common.h
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -118,6 +118,33 @@ struct xgmac_mtl_ops;
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
 	tx_hard_error = BIT(0),
 	tx_bump_tc = BIT(1),
@@ -202,6 +229,13 @@ struct xgmac_extra_stats {
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
@@ -310,6 +344,13 @@ struct xgmac_core_ops {
 						unsigned char feature_index);
 	/* adjust XGMAC speed */
 	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
+
+	/* EEE-LPI specific operations */
+	void (*set_eee_mode)(void __iomem *ioaddr);
+	void (*reset_eee_mode)(void __iomem *ioaddr);
+	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
+			const int tw);
+	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
 };
 
 const struct xgmac_core_ops *xgmac_get_core_ops(void);
@@ -371,6 +412,8 @@ struct xgmac_hw_features {
 	/* IEEE 1588-2008 */
 	unsigned int atime_stamp;
 
+	unsigned int eee;
+
 	unsigned int tx_csum_offload;
 	unsigned int rx_csum_offload;
 	unsigned int multi_macaddr;
@@ -451,6 +494,14 @@ struct xgmac_priv_data {
 	u32 adv_ts;
 	int use_riwt;
 	spinlock_t ptp_lock;
+
+	/* EEE-LPI specific members */
+	struct timer_list eee_ctrl_timer;
+	bool tx_path_in_lpi_mode;
+	int lpi_irq;
+	int eee_enabled;
+	int eee_active;
+	int tx_lpi_timer;
 };
 
 /* Function prototypes */
@@ -473,4 +524,7 @@ extern int xgmac_restore(struct net_device *ndev);
 
 extern const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
 
+void xgmac_disable_eee_mode(struct xgmac_priv_data * const priv);
+bool xgmac_eee_init(struct xgmac_priv_data * const priv);
+
 #endif /* __XGMAC_COMMON_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index 931d05b..ed475fa 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -46,11 +46,38 @@ static void xgmac_core_dump_regs(void __iomem *ioaddr)
 {
 }
 
+static int xgmac_get_lpi_status(void __iomem *ioaddr, const u32 irq_status)
+{
+	int status = 0;
+	int lpi_status;
+
+	/* Reading this register shall clear all the LPI status bits */
+	lpi_status = readl(ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
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
 static int xgmac_core_host_irq_status(void __iomem *ioaddr,
 				struct xgmac_extra_stats *x)
 {
-	return 0;
+	int irq_status, status = 0;
+
+	irq_status = readl(ioaddr + XGMAC_CORE_INT_STATUS_REG);
+
+	if (unlikely(irq_status & LPI_INT_STATUS))
+		status |= xgmac_get_lpi_status(ioaddr, irq_status);
+
+	return status;
 }
 
 /* Set power management mode (e.g. magic frame) */
@@ -137,6 +164,59 @@ static void xgmac_core_set_speed(void __iomem *ioaddr,
 	writel(tx_cfg, ioaddr + XGMAC_CORE_TX_CONFIG_REG);
 }
 
+static void  xgmac_set_eee_mode(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	/* Enable the LPI mode for transmit path with Tx automate bit set.
+	 * When Tx Automate bit is set, MAC internally handles the entry
+	 * to LPI mode after all outstanding and pending packets are
+	 * transmitted.
+	 */
+	ctrl = readl(ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+	ctrl |= LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_TXA;
+	writel(ctrl, ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+}
+
+static void  xgmac_reset_eee_mode(void __iomem *ioaddr)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+	ctrl &= ~(LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_TXA);
+	writel(ctrl, ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+}
+
+static void  xgmac_set_eee_pls(void __iomem *ioaddr, const int link)
+{
+	u32 ctrl;
+
+	ctrl = readl(ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+
+	/* If the PHY link status is UP then set PLS */
+	if (link)
+		ctrl |= LPI_CTRL_STATUS_PLS;
+	else
+		ctrl &= ~LPI_CTRL_STATUS_PLS;
+
+	writel(ctrl, ioaddr + XGMAC_CORE_LPI_CTRL_STATUS);
+}
+
+static void  xgmac_set_eee_timer(void __iomem *ioaddr,
+					const int ls, const int tw)
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
+	writel(value, ioaddr + XGMAC_CORE_LPI_TIMER_CTRL);
+}
+
 const struct xgmac_core_ops core_ops = {
 	.core_init = xgmac_core_init,
 	.dump_regs = xgmac_core_dump_regs,
@@ -149,6 +229,10 @@ const struct xgmac_core_ops core_ops = {
 	.get_controller_version = xgmac_get_controller_version,
 	.get_hw_feature = xgmac_get_hw_feature,
 	.set_speed = xgmac_core_set_speed,
+	.set_eee_mode =  xgmac_set_eee_mode,
+	.reset_eee_mode = xgmac_reset_eee_mode,
+	.set_eee_timer = xgmac_set_eee_timer,
+	.set_eee_pls = xgmac_set_eee_pls,
 };
 
 const struct xgmac_core_ops *xgmac_get_core_ops(void)
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 684b260..48ef13e 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -26,10 +26,57 @@ struct xgmac_stats {
 	offsetof(struct xgmac_priv_data, xstats.m)}
 
 static const struct xgmac_stats xgmac_gstrings_stats[] = {
+	XGMAC_STAT(tx_lpi_entry_n),
+	XGMAC_STAT(tx_lpi_exit_n),
+	XGMAC_STAT(rx_lpi_entry_n),
+	XGMAC_STAT(rx_lpi_exit_n),
+	XGMAC_STAT(eee_wakeup_error_n),
 };
 #define XGMAC_STATS_LEN ARRAY_SIZE(xgmac_gstrings_stats)
 
+static int xgmac_ethtool_get_eee(struct net_device *dev,
+				     struct ethtool_eee *edata)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
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
+static int xgmac_ethtool_set_eee(struct net_device *dev,
+				     struct ethtool_eee *edata)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+
+	priv->eee_enabled = edata->eee_enabled;
+
+	if (!priv->eee_enabled)
+		xgmac_disable_eee_mode(priv);
+	else {
+		/* We are asking for enabling the EEE but it is safe
+		 * to verify all by invoking the eee_init function.
+		 * In case of failure it will return an error.
+		 */
+		priv->eee_enabled = xgmac_eee_init(priv);
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
 static const struct ethtool_ops xgmac_ethtool_ops = {
+	.get_eee = xgmac_ethtool_get_eee,
+	.set_eee = xgmac_ethtool_set_eee,
 };
 
 void xgmac_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index ef7f55b..6d14c81 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -61,6 +61,7 @@ static int pause = XGMAC_PAUSE_TIME;
 static int tx_tc = TC_DEFAULT;
 static int rx_tc = TC_DEFAULT;
 static int buf_sz = DMA_BUFFER_SIZE;
+static int eee_timer = XGMAC_DEFAULT_LPI_TIMER;
 
 module_param(watchdog, int, S_IRUGO | S_IWUSR);
 module_param(debug, int, S_IRUGO | S_IWUSR);
@@ -72,6 +73,7 @@ module_param(pause, int, S_IRUGO | S_IWUSR);
 module_param(tx_tc, int, S_IRUGO | S_IWUSR);
 module_param(rx_tc, int, S_IRUGO | S_IWUSR);
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
+module_param(eee_timer, int, S_IRUGO | S_IWUSR);
 
 static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
@@ -83,6 +85,8 @@ static irqreturn_t xgmac_rx_interrupt(int irq, void *dev_id);
 
 #define XGMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
 
+#define XGMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
+
 /**
  * xgmac_verify_args - verify the driver parameters.
  * Description: it verifies if some wrong parameter is passed to the driver.
@@ -104,6 +108,86 @@ static void xgmac_verify_args(void)
 		flow_ctrl = XGMAC_FLOW_OFF;
 	if (unlikely((pause < 0) || (pause > 0xffff)))
 		pause = XGMAC_PAUSE_TIME;
+	if (unlikely(eee_timer < 0))
+		eee_timer = XGMAC_DEFAULT_LPI_TIMER;
+}
+
+static void xgmac_enable_eee_mode(const struct xgmac_priv_data *priv)
+{
+	/* Check and enter in LPI mode */
+	if (!priv->tx_path_in_lpi_mode)
+		priv->hw->mac->set_eee_mode(priv->ioaddr);
+}
+
+void xgmac_disable_eee_mode(struct xgmac_priv_data * const priv)
+{
+	/* Exit and disable EEE in case of we are are in LPI state. */
+	priv->hw->mac->reset_eee_mode(priv->ioaddr);
+	del_timer_sync(&priv->eee_ctrl_timer);
+	priv->tx_path_in_lpi_mode = false;
+}
+
+/**
+ * xgmac_eee_ctrl_timer
+ * @arg : data hook
+ * Description:
+ *  If there is no data transfer and if we are not in LPI state,
+ *  then MAC Transmitter can be moved to LPI state.
+ */
+static void xgmac_eee_ctrl_timer(unsigned long arg)
+{
+	struct xgmac_priv_data *priv = (struct xgmac_priv_data *)arg;
+
+	xgmac_enable_eee_mode(priv);
+	mod_timer(&priv->eee_ctrl_timer, XGMAC_LPI_TIMER(eee_timer));
+}
+
+/**
+ * xgmac_eee_init
+ * @priv: private device pointer
+ * Description:
+ *  If the EEE support has been enabled while configuring the driver,
+ *  if the GMAC actually supports the EEE (from the HW cap reg) and the
+ *  phy can also manage EEE, so enable the LPI state and start the timer
+ *  to verify if the tx path can enter in LPI state.
+ */
+bool xgmac_eee_init(struct xgmac_priv_data * const priv)
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
+		priv->eee_ctrl_timer.function = xgmac_eee_ctrl_timer;
+		priv->eee_ctrl_timer.data = (unsigned long)priv;
+		priv->eee_ctrl_timer.expires = XGMAC_LPI_TIMER(eee_timer);
+		add_timer(&priv->eee_ctrl_timer);
+
+		priv->hw->mac->set_eee_timer(priv->ioaddr,
+					     XGMAC_DEFAULT_LPI_TIMER,
+					     priv->tx_lpi_timer);
+
+		pr_info("xgmac: Energy-Efficient Ethernet initialized\n");
+
+		ret = true;
+	}
+
+	return ret;
+}
+
+static void xgmac_eee_adjust(const struct xgmac_priv_data *priv)
+{
+	/* When the EEE has been already initialised we have to
+	 * modify the PLS bit in the LPI ctrl & status reg according
+	 * to the PHY link status. For this reason.
+	 */
+	if (priv->eee_enabled)
+		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
 }
 
 /**
@@ -213,6 +297,9 @@ static void xgmac_adjust_link(struct net_device *dev)
 
 	if (new_state & netif_msg_link(priv))
 		phy_print_status(phydev);
+
+	/* Alter the MAC settings for EEE */
+	xgmac_eee_adjust(priv);
 }
 
 /**
@@ -756,7 +843,7 @@ static void xgmac_tx_queue_clean(struct xgmac_tx_queue *tqueue)
  * @priv: driver private structure
  * Description: it reclaims resources after transmission completes.
  */
-static void xgmac_tx_all_clean(struct xgmac_priv_data *priv)
+static void xgmac_tx_all_clean(struct xgmac_priv_data * const priv)
 {
 	u8 queue_num;
 
@@ -764,6 +851,11 @@ static void xgmac_tx_all_clean(struct xgmac_priv_data *priv)
 		struct xgmac_tx_queue *tqueue = priv->txq[queue_num];
 		xgmac_tx_queue_clean(tqueue);
 	}
+
+	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
+		xgmac_enable_eee_mode(priv);
+		mod_timer(&priv->eee_ctrl_timer, XGMAC_LPI_TIMER(eee_timer));
+	}
 }
 
 /**
@@ -850,6 +942,7 @@ static int xgmac_get_hw_features(struct xgmac_priv_data * const priv)
 		features->multi_macaddr = XGMAC_HW_FEAT_MACADDR_COUNT(rval);
 		features->tstamp_srcselect = XGMAC_HW_FEAT_TSTMAP_SRC(rval);
 		features->sa_vlan_insert = XGMAC_HW_FEAT_SRCADDR_VLAN(rval);
+		features->eee = XGMAC_HW_FEAT_EEE(rval);
 	}
 	/* Read First Capability Register CAP[1] */
 	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 1);
@@ -1069,6 +1162,20 @@ static int xgmac_open(struct net_device *dev)
 		goto init_error;
 	}
 
+	/* If the LPI irq is different from the mac irq
+	 * register a dedicated handler
+	 */
+	if (priv->lpi_irq != dev->irq) {
+		ret = devm_request_irq(priv->device, priv->lpi_irq,
+				       xgmac_common_interrupt,
+				       IRQF_SHARED, dev->name, dev);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating the LPI IRQ %d (%d)\n",
+			       __func__, priv->lpi_irq, ret);
+			goto init_error;
+		}
+	}
+
 	/* Request TX DMA irq lines */
 	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
 		ret = devm_request_irq(priv->device,
@@ -1124,6 +1231,9 @@ static int xgmac_open(struct net_device *dev)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, XGMAC_MAX_DMA_RIWT);
 	}
 
+	priv->tx_lpi_timer = XGMAC_DEFAULT_LPI_TIMER;
+	priv->eee_enabled = xgmac_eee_init(priv);
+
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
@@ -1149,6 +1259,9 @@ static int xgmac_release(struct net_device *dev)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
+	if (priv->eee_enabled)
+		del_timer_sync(&priv->eee_ctrl_timer);
+
 	/* Stop and disconnect the PHY */
 	if (priv->phydev) {
 		phy_stop(priv->phydev);
@@ -1244,6 +1357,9 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* get the spinlock */
 	spin_lock(&tqueue->tx_lock);
 
+	if (priv->tx_path_in_lpi_mode)
+		xgmac_disable_eee_mode(priv);
+
 	if (unlikely(xgmac_tx_avail(tqueue, tx_rsize) < nr_frags + 1)) {
 		if (!netif_tx_queue_stopped(dev_txq)) {
 			netif_tx_stop_queue(dev_txq);
@@ -1523,6 +1639,25 @@ static void xgmac_tx_timeout(struct net_device *dev)
  */
 static irqreturn_t xgmac_common_interrupt(int irq, void *dev_id)
 {
+	struct net_device *netdev = (struct net_device *)dev_id;
+	struct xgmac_priv_data *priv = netdev_priv(netdev);
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
 
@@ -2177,7 +2312,21 @@ module_exit(xgmac_exit);
 #ifndef MODULE
 static int __init xgmac_cmdline_opt(char *str)
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
+	pr_err("%s: ERROR broken module parameter conversion", __func__);
+	return -EINVAL;
 }
 
 __setup("xgmaceth=", xgmac_cmdline_opt);
@@ -2197,6 +2346,7 @@ MODULE_PARM_DESC(pause, "Flow Control Pause Time");
 MODULE_PARM_DESC(tx_tc, "TX MTL threshold control value");
 MODULE_PARM_DESC(rx_tc, "RX MTL threshold control value");
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
+MODULE_PARM_DESC(eee_timer, "EEE-LPI Default LS timer value");
 
 MODULE_AUTHOR("Siva Reddy Kallam <siva.kallam@samsung.com>");
 MODULE_AUTHOR("ByungHo An <bh74.an@samsung.com>");
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
index 1bb327a2..e988e38 100644
--- a/drivers/net/ethernet/samsung/xgmac_platform.c
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -166,6 +166,10 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 		}
 	}
 
+	priv->lpi_irq = irq_of_parse_and_map(dev->of_node, loop++);
+	if (priv->lpi_irq == -ENXIO)
+		priv->lpi_irq = priv->dev->irq;
+
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("XGMAC platform driver registration completed");
diff --git a/drivers/net/ethernet/samsung/xgmac_reg.h b/drivers/net/ethernet/samsung/xgmac_reg.h
index 11ae281..87fbff0 100644
--- a/drivers/net/ethernet/samsung/xgmac_reg.h
+++ b/drivers/net/ethernet/samsung/xgmac_reg.h
@@ -25,6 +25,11 @@
 #define XGMAC_CORE_HASH_TABLE_REG5	0x0024
 #define XGMAC_CORE_HASH_TABLE_REG6	0x0028
 #define XGMAC_CORE_HASH_TABLE_REG7	0x002C
+
+/* EEE-LPI Registers */
+#define XGMAC_CORE_LPI_CTRL_STATUS	0x00D0
+#define XGMAC_CORE_LPI_TIMER_CTRL	0x00D4
+
 /* VLAN Specific Registers */
 #define XGMAC_CORE_VLAN_TAG_REG		0x0050
 #define XGMAC_CORE_VLAN_HASHTAB_REG	0x0058
-- 
1.7.10.4
