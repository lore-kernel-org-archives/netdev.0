From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/5] stmmac: improve/review and fix kernel-doc
Date: Mon,  8 Apr 2013 14:10:00 +0200
Message-ID: <1365423003-23959-3-git-send-email-peppe.cavallaro@st.com>
References: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shiraz.hashim@st.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:36084 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935294Ab3DHMKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:10:25 -0400
In-Reply-To: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch reviews/improves and adds some fixes in the code doc.
Also kernel-doc passes w/o any warnings.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  184 ++++++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c  |    8 +-
 2 files changed, 142 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6b26d31..caee7fd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -81,14 +81,14 @@
 #define JUMBO_LEN	9000
 
 /* Module parameters */
-#define TX_TIMEO 5000 /* default 5 seconds */
+#define TX_TIMEO	5000
 static int watchdog = TX_TIMEO;
 module_param(watchdog, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(watchdog, "Transmit timeout in milliseconds");
+MODULE_PARM_DESC(watchdog, "Transmit timeout in milliseconds (default 5s)");
 
-static int debug = -1;		/* -1: default, 0: no output, 16:  all */
+static int debug = -1;
 module_param(debug, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(debug, "Message Level (0: no output, 16: all)");
+MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
 
 int phyaddr = -1;
 module_param(phyaddr, int, S_IRUGO);
@@ -173,6 +173,18 @@ static void stmmac_verify_args(void)
 		eee_timer = STMMAC_DEFAULT_LPI_TIMER;
 }
 
+/**
+ * stmmac_clk_csr_set - dynamically set the MDC clock
+ * @priv: driver private structure
+ * Description: this is to dynamically set the MDC clock according to the csr
+ * clock input.
+ * Note:
+ *	If a specific clk_csr value is passed from the platform
+ *	this means that the CSR Clock Range selection cannot be
+ *	changed at run-time and it is fixed (as reported in the driver
+ *	documentation). Viceversa the driver will try to set the MDC
+ *	clock dynamically according to the actual clock input.
+ */
 static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 {
 	u32 clk_rate;
@@ -222,8 +234,11 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 	return priv->dirty_tx + priv->dma_tx_size - priv->cur_tx - 1;
 }
 
-/* On some ST platforms, some HW system configuraton registers have to be
- * set according to the link speed negotiated.
+/**
+ * stmmac_hw_fix_mac_speed: callback for speed selection
+ * @priv: driver private structure
+ * Description: on some platforms (e.g. ST), some HW system configuraton
+ * registers have to be set according to the link speed negotiated.
  */
 static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 {
@@ -234,6 +249,11 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 					  phydev->speed);
 }
 
+/**
+ * stmmac_enable_eee_mode: Check and enter in LPI mode
+ * @priv: driver private structure
+ * Description: this function is to verify and enter in LPI mode for EEE.
+ */
 static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
 {
 	/* Check and enter in LPI mode */
@@ -242,19 +262,24 @@ static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
 		priv->hw->mac->set_eee_mode(priv->ioaddr);
 }
 
+/**
+ * stmmac_disable_eee_mode: disable/exit from EEE
+ * @priv: driver private structure
+ * Description: this function is to exit and disable EEE in case of
+ * LPI state is true. This is called by the xmit.
+ */
 void stmmac_disable_eee_mode(struct stmmac_priv *priv)
 {
-	/* Exit and disable EEE in case of we are are in LPI state. */
 	priv->hw->mac->reset_eee_mode(priv->ioaddr);
 	del_timer_sync(&priv->eee_ctrl_timer);
 	priv->tx_path_in_lpi_mode = false;
 }
 
 /**
- * stmmac_eee_ctrl_timer
+ * stmmac_eee_ctrl_timer: EEE TX SW timer.
  * @arg : data hook
  * Description:
- *  If there is no data transfer and if we are not in LPI state,
+ *  if there is no data transfer and if we are not in LPI state,
  *  then MAC Transmitter can be moved to LPI state.
  */
 static void stmmac_eee_ctrl_timer(unsigned long arg)
@@ -266,8 +291,8 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
 }
 
 /**
- * stmmac_eee_init
- * @priv: private device pointer
+ * stmmac_eee_init: init EEE
+ * @priv: driver private structure
  * Description:
  *  If the EEE support has been enabled while configuring the driver,
  *  if the GMAC actually supports the EEE (from the HW cap reg) and the
@@ -303,18 +328,22 @@ out:
 	return ret;
 }
 
+/**
+ * stmmac_eee_adjust: adjust HW EEE according to the speed
+ * @priv: driver private structure
+ * Description:
+ *	When the EEE has been already initialised we have to
+ *	modify the PLS bit in the LPI ctrl & status reg according
+ *	to the PHY link status. For this reason.
+ */
 static void stmmac_eee_adjust(struct stmmac_priv *priv)
 {
-	/* When the EEE has been already initialised we have to
-	 * modify the PLS bit in the LPI ctrl & status reg according
-	 * to the PHY link status. For this reason.
-	 */
 	if (priv->eee_enabled)
 		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
 }
 
-/* stmmac_get_tx_hwtstamp:
- * @priv : pointer to private device structure.
+/* stmmac_get_tx_hwtstamp: get HW TX timestamps
+ * @priv: driver private structure
  * @entry : descriptor index to be used.
  * @skb : the socket buffer
  * Description :
@@ -356,8 +385,8 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 	return;
 }
 
-/* stmmac_get_rx_hwtstamp:
- * @priv : pointer to private device structure.
+/* stmmac_get_rx_hwtstamp: get HW RX timestamps
+ * @priv: driver private structure
  * @entry : descriptor index to be used.
  * @skb : the socket buffer
  * Description :
@@ -618,6 +647,13 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			    sizeof(struct hwtstamp_config)) ? -EFAULT : 0;
 }
 
+/**
+ * stmmac_init_ptp: init PTP
+ * @priv: driver private structure
+ * Description: this is to verify if the HW supports the PTPv1 or v2.
+ * This is done by looking at the HW cap. register.
+ * Also it registers the ptp driver.
+ */
 static int stmmac_init_ptp(struct stmmac_priv *priv)
 {
 	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
@@ -740,6 +776,13 @@ static void stmmac_adjust_link(struct net_device *dev)
 	DBG(probe, DEBUG, "stmmac_adjust_link: exiting\n");
 }
 
+/**
+ * stmmac_check_pcs_mode: verify if RGMII/SGMII is supported
+ * @priv: driver private structure
+ * Description: this is to verify if the HW supports the PCS.
+ * Physical Coding Sublayer (PCS) interface that can be used when the MAC is
+ * configured for the TBI, RTBI, or SGMII PHY interface.
+ */
 static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
 {
 	int interface = priv->plat->interface;
@@ -821,9 +864,10 @@ static int stmmac_init_phy(struct net_device *dev)
 }
 
 /**
- * stmmac_display_ring
- * @p: pointer to the ring.
+ * stmmac_display_ring: display ring
+ * @head: pointer to the head of the ring passed.
  * @size: size of the ring.
+ * @extend_desc: to verify if extended descriptors are used.
  * Description: display the control/status and buffer descriptors.
  */
 static void stmmac_display_ring(void *head, int size, int extend_desc)
@@ -887,6 +931,12 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 	return ret;
 }
 
+/**
+ * stmmac_clear_descriptors: clear descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx and rx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
 static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 {
 	int i;
@@ -1129,7 +1179,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 
 /**
  *  stmmac_dma_operation_mode - HW DMA operation mode
- *  @priv : pointer to the private device structure.
+ *  @priv: driver private structure
  *  Description: it sets the DMA operation mode: tx/rx DMA thresholds
  *  or Store-And-Forward capability.
  */
@@ -1153,7 +1203,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 
 /**
  * stmmac_tx_clean:
- * @priv: private data pointer
+ * @priv: driver private structure
  * Description: it reclaims resources after transmission completes.
  */
 static void stmmac_tx_clean(struct stmmac_priv *priv)
@@ -1245,8 +1295,8 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
 
 
 /**
- * stmmac_tx_err:
- * @priv: pointer to the private device structure
+ * stmmac_tx_err: irq tx error mng function
+ * @priv: driver private structure
  * Description: it cleans the descriptors and restarts the transmission
  * in case of errors.
  */
@@ -1275,6 +1325,14 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	netif_wake_queue(priv->dev);
 }
 
+/**
+ * stmmac_dma_interrupt: DMA ISR
+ * @priv: driver private structure
+ * Description: this is the DMA ISR. It is called by the main ISR.
+ * It calls the dwmac dma routine to understand which type of interrupt
+ * happened. In case of there is a Normal interrupt and either TX or RX
+ * interrupt happened so the NAPI is scheduled.
+ */
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
 	int status;
@@ -1297,13 +1355,16 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		stmmac_tx_err(priv);
 }
 
+/**
+ * stmmac_mmc_setup: setup the Mac Management Counters (MMC)
+ * @priv: driver private structure
+ * Description: this masks the MMC irq, in fact, the counters are managed in SW.
+ */
 static void stmmac_mmc_setup(struct stmmac_priv *priv)
 {
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
 			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
-	/* Mask MMC irq, counters are managed in SW and registers
-	 * are cleared on each READ eventually. */
 	dwmac_mmc_intr_all_mask(priv->ioaddr);
 
 	if (priv->dma_cap.rmon) {
@@ -1332,9 +1393,11 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_selec_desc_mode
- * @priv : private structure
- * Description: select the Enhanced/Alternate or Normal descriptors
+ * stmmac_selec_desc_mode: to select among: normal/alternate/extend descriptors
+ * @priv: driver private structure
+ * Description: select the Enhanced/Alternate or Normal descriptors.
+ * In case of Enhanced/Alternate, it looks at the extended descriptors are
+ * supported by the HW cap. register.
  */
 static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
 {
@@ -1356,8 +1419,8 @@ static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_get_hw_features
- * @priv : private device pointer
+ * stmmac_get_hw_features: get MAC capabilities from the HW cap. register.
+ * @priv: driver private structure
  * Description:
  *  new GMAC chip generations have a new register to indicate the
  *  presence of the optional feature/functions.
@@ -1415,10 +1478,15 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 	return hw_cap;
 }
 
+/**
+ * stmmac_check_ether_addr: check if the MAC addr is valid
+ * @priv: driver private structure
+ * Description:
+ * it is to verify if the MAC address is valid, in case of failures it
+ * generates a random MAC address
+ */
 static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 {
-	/* verify if the MAC address is valid, in case of failures it
-	 * generates a random MAC address */
 	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
 		priv->hw->mac->get_umac_addr((void __iomem *)
 					     priv->dev->base_addr,
@@ -1430,15 +1498,20 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 						   priv->dev->dev_addr);
 }
 
+/**
+ * stmmac_init_dma_engine: DMA init.
+ * @priv: driver private structure
+ * Description:
+ * It inits the DMA invoking the specific MAC/GMAC callback.
+ * Some DMA parameters can be passed from the platform;
+ * in case of these are not passed a default is kept for the MAC or GMAC.
+ */
 static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
 	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_len = 0;
 	int mixed_burst = 0;
 	int atds = 0;
 
-	/* Some DMA parameters can be passed from the platform;
-	 * in case of these are not passed we keep a default
-	 * (good for all the chips) and init the DMA! */
 	if (priv->plat->dma_cfg) {
 		pbl = priv->plat->dma_cfg->pbl;
 		fixed_burst = priv->plat->dma_cfg->fixed_burst;
@@ -1455,7 +1528,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_tx_timer:
+ * stmmac_tx_timer: mitigation sw timer for tx.
  * @data: data pointer
  * Description:
  * This is the timer handler to directly invoke the stmmac_tx_clean.
@@ -1468,8 +1541,8 @@ static void stmmac_tx_timer(unsigned long data)
 }
 
 /**
- * stmmac_tx_timer:
- * @priv: private data structure
+ * stmmac_init_tx_coalesce: init tx mitigation options.
+ * @priv: driver private structure
  * Description:
  * This inits the transmit coalesce parameters: i.e. timer rate,
  * timer handler and default threshold used for enabling the
@@ -1697,10 +1770,12 @@ static int stmmac_release(struct net_device *dev)
 }
 
 /**
- *  stmmac_xmit:
+ *  stmmac_xmit: Tx entry point of the driver
  *  @skb : the socket buffer
  *  @dev : device pointer
- *  Description : Tx entry point of the driver.
+ *  Description : this is the tx entry point of the driver.
+ *  It programs the chain or the ring and supports oversized frames
+ *  and SG feature.
  */
 static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1866,6 +1941,12 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+/**
+ * stmmac_rx_refill: refill used skb preallocated buffers
+ * @priv: driver private structure
+ * Description : this is to reallocate the skb for the reception process
+ * that is based on zero-copy.
+ */
 static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 {
 	unsigned int rxsize = priv->dma_rx_size;
@@ -1905,6 +1986,13 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 	}
 }
 
+/**
+ * stmmac_rx_refill: refill used skb preallocated buffers
+ * @priv: driver private structure
+ * @limit: napi bugget.
+ * Description :  this the function called by the napi poll method.
+ * It gets all the frames inside the ring.
+ */
 static int stmmac_rx(struct stmmac_priv *priv, int limit)
 {
 	unsigned int rxsize = priv->dma_rx_size;
@@ -2168,6 +2256,14 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	return features;
 }
 
+/**
+ *  stmmac_interrupt - main ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the main driver interrupt service routine.
+ *  It calls the DMA ISR and also the core ISR to manage PMT, MMC, LPI
+ *  interrupts.
+ */
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
@@ -2216,7 +2312,7 @@ static void stmmac_poll_controller(struct net_device *dev)
  *  a proprietary structure used to pass information to the driver.
  *  @cmd: IOCTL command
  *  Description:
- *  Currently it supports just the phy_mii_ioctl(...) and HW time stamping.
+ *  Currently it supports the phy_mii_ioctl(...) and HW time stamping.
  */
 static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
@@ -2449,7 +2545,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
 
 /**
  *  stmmac_hw_init - Init the MAC device
- *  @priv : pointer to the private device structure.
+ *  @priv: driver private structure
  *  Description: this function detects which MAC device
  *  (GMAC/MAC10-100) has to attached, checks the HW capability
  *  (if supported) and sets the driver's features (for example
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 93d4bef..b8b0eee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -174,9 +174,7 @@ static struct ptp_clock_info stmmac_ptp_clock_ops = {
 
 /**
  * stmmac_ptp_register
- *
- * @ndev: net device pointer
- *
+ * @priv: driver private structure
  * Description: this function will register the ptp clock driver
  * to kernel. It also does some house keeping work.
  */
@@ -199,9 +197,7 @@ int stmmac_ptp_register(struct stmmac_priv *priv)
 
 /**
  * stmmac_ptp_unregister
- *
- * @ndev: net device pointer
- *
+ * @priv: driver private structure
  * Description: this function will remove/unregister the ptp clock driver
  * from the kernel.
  */
-- 
1.7.4.4
