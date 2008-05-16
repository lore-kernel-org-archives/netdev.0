From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/16] sfc: Replaced various macros with inline functions
Date: Fri, 16 May 2008 21:16:10 +0100
Message-ID: <20080516201610.GY28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53535 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754257AbYEPURp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:17:45 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h    |    4 +-
 drivers/net/sfc/efx.c         |    8 +++---
 drivers/net/sfc/falcon.c      |   46 ++++++++++++++++++++--------------------
 drivers/net/sfc/falcon.h      |    5 +++-
 drivers/net/sfc/falcon_io.h   |   29 ++++++++++++++++++-------
 drivers/net/sfc/falcon_xmac.c |    6 ++--
 drivers/net/sfc/net_driver.h  |   31 ++++++++++++++++-----------
 drivers/net/sfc/rx.c          |   39 +++++++++++++++++++++-------------
 drivers/net/sfc/selftest.c    |    8 +++---
 drivers/net/sfc/tx.c          |    2 +-
 drivers/net/sfc/workarounds.h |    2 +-
 11 files changed, 105 insertions(+), 75 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index 2806201..c98a591 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -483,7 +483,7 @@ typedef union efx_oword {
 #endif
 
 #define EFX_SET_OWORD_FIELD_VER(efx, oword, field, value) do { \
-	if (FALCON_REV(efx) >= FALCON_REV_B0) {			   \
+	if (falcon_rev(efx) >= FALCON_REV_B0) {			   \
 		EFX_SET_OWORD_FIELD((oword), field##_B0, (value)); \
 	} else { \
 		EFX_SET_OWORD_FIELD((oword), field##_A1, (value)); \
@@ -491,7 +491,7 @@ typedef union efx_oword {
 } while (0)
 
 #define EFX_QWORD_FIELD_VER(efx, qword, field)	\
-	(FALCON_REV(efx) >= FALCON_REV_B0 ?	\
+	(falcon_rev(efx) >= FALCON_REV_B0 ?	\
 	 EFX_QWORD_FIELD((qword), field##_B0) :	\
 	 EFX_QWORD_FIELD((qword), field##_A1))
 
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index df19e86..86d4029 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -691,7 +691,7 @@ static void efx_stop_port(struct efx_nic *efx)
 	mutex_unlock(&efx->mac_lock);
 
 	/* Serialise against efx_set_multicast_list() */
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1030,7 +1030,7 @@ static void efx_start_all(struct efx_nic *efx)
 		return;
 	if ((efx->state != STATE_RUNNING) && (efx->state != STATE_INIT))
 		return;
-	if (NET_DEV_REGISTERED(efx) && !netif_running(efx->net_dev))
+	if (efx_dev_registered(efx) && !netif_running(efx->net_dev))
 		return;
 
 	/* Mark the port as enabled so port reconfigurations can start, then
@@ -1112,7 +1112,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
 	efx_stop_queue(efx);
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		netif_tx_lock_bh(efx->net_dev);
 		netif_tx_unlock_bh(efx->net_dev);
 	}
@@ -1550,7 +1550,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 	efx_for_each_tx_queue(tx_queue, efx)
 		efx_release_tx_buffers(tx_queue);
 
-	if (NET_DEV_REGISTERED(efx)) {
+	if (efx_dev_registered(efx)) {
 		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
 		unregister_netdev(efx->net_dev);
 	}
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 4f96ce4..e02f1d1 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -145,7 +145,7 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 #define PCI_EXP_LNKSTA_LNK_WID_LBN	4
 
 #define FALCON_IS_DUAL_FUNC(efx)		\
-	(FALCON_REV(efx) < FALCON_REV_B0)
+	(falcon_rev(efx) < FALCON_REV_B0)
 
 /**************************************************************************
  *
@@ -465,7 +465,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      TX_DESCQ_TYPE, 0,
 			      TX_NON_IP_DROP_DIS_B0, 1);
 
-	if (FALCON_REV(efx) >= FALCON_REV_B0) {
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		int csum = !(efx->net_dev->features & NETIF_F_IP_CSUM);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_IP_CHKSM_DIS_B0, csum);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, TX_TCP_CHKSM_DIS_B0, csum);
@@ -474,7 +474,7 @@ int falcon_init_tx(struct efx_tx_queue *tx_queue)
 	falcon_write_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
 			   tx_queue->queue);
 
-	if (FALCON_REV(efx) < FALCON_REV_B0) {
+	if (falcon_rev(efx) < FALCON_REV_B0) {
 		efx_oword_t reg;
 
 		BUG_ON(tx_queue->queue >= 128); /* HW limit */
@@ -635,7 +635,7 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
 	int rc;
-	int is_b0 = FALCON_REV(efx) >= FALCON_REV_B0;
+	int is_b0 = falcon_rev(efx) >= FALCON_REV_B0;
 	int iscsi_digest_en = is_b0;
 
 	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
@@ -822,10 +822,10 @@ static inline void falcon_handle_tx_event(struct efx_channel *channel,
 		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
 
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_lock(efx->net_dev);
 		falcon_notify_tx_desc(tx_queue);
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_unlock(efx->net_dev);
 	} else if (EFX_QWORD_FIELD(*event, TX_EV_PKT_ERR) &&
 		   EFX_WORKAROUND_10727(efx)) {
@@ -884,7 +884,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 						   RX_EV_TCP_UDP_CHKSUM_ERR);
 	rx_ev_eth_crc_err = EFX_QWORD_FIELD(*event, RX_EV_ETH_CRC_ERR);
 	rx_ev_frm_trunc = EFX_QWORD_FIELD(*event, RX_EV_FRM_TRUNC);
-	rx_ev_drib_nib = ((FALCON_REV(efx) >= FALCON_REV_B0) ?
+	rx_ev_drib_nib = ((falcon_rev(efx) >= FALCON_REV_B0) ?
 			  0 : EFX_QWORD_FIELD(*event, RX_EV_DRIB_NIB));
 	rx_ev_pause_frm = EFX_QWORD_FIELD(*event, RX_EV_PAUSE_FRM_ERR);
 
@@ -1065,7 +1065,7 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 	    EFX_QWORD_FIELD(*event, XG_PHY_INTR))
 		is_phy_event = 1;
 
-	if ((FALCON_REV(efx) >= FALCON_REV_B0) &&
+	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
 	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
 		is_phy_event = 1;
 
@@ -1572,7 +1572,7 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 	unsigned long offset;
 	efx_dword_t dword;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
 
 	for (offset = RX_RSS_INDIR_TBL_B0;
@@ -1595,7 +1595,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 
 	if (!EFX_INT_MODE_USE_MSI(efx)) {
 		irq_handler_t handler;
-		if (FALCON_REV(efx) >= FALCON_REV_B0)
+		if (falcon_rev(efx) >= FALCON_REV_B0)
 			handler = falcon_legacy_interrupt_b0;
 		else
 			handler = falcon_legacy_interrupt_a1;
@@ -1642,7 +1642,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	}
 
 	/* ACK legacy interrupt */
-	if (FALCON_REV(efx) >= FALCON_REV_B0)
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		falcon_read(efx, &reg, INT_ISR0_B0);
 	else
 		falcon_irq_ack_a1(efx);
@@ -1733,7 +1733,7 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	efx_oword_t temp;
 	int count;
 
-	if ((FALCON_REV(efx) < FALCON_REV_B0) ||
+	if ((falcon_rev(efx) < FALCON_REV_B0) ||
 	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
@@ -1786,7 +1786,7 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 {
 	efx_oword_t temp;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return;
 
 	/* Isolate the MAC -> RX */
@@ -1824,7 +1824,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 			     MAC_SPEED, link_speed);
 	/* On B0, MAC backpressure can be disabled and packets get
 	 * discarded. */
-	if (FALCON_REV(efx) >= FALCON_REV_B0) {
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0,
 				    !efx->link_up);
 	}
@@ -1842,7 +1842,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
 
 	/* Unisolate the MAC -> RX */
-	if (FALCON_REV(efx) >= FALCON_REV_B0)
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 1);
 	falcon_write(efx, &reg, RX_CFG_REG_KER);
 }
@@ -1857,7 +1857,7 @@ int falcon_dma_stats(struct efx_nic *efx, unsigned int done_offset)
 		return 0;
 
 	/* Statistics fetch will fail if the MAC is in TX drain */
-	if (FALCON_REV(efx) >= FALCON_REV_B0) {
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		efx_oword_t temp;
 		falcon_read(efx, &temp, MAC0_CTRL_REG_KER);
 		if (EFX_OWORD_FIELD(temp, TXFIFO_DRAIN_EN_B0))
@@ -2114,7 +2114,7 @@ int falcon_probe_port(struct efx_nic *efx)
 	falcon_init_mdio(&efx->mii);
 
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
-	if (FALCON_REV(efx) >= FALCON_REV_B0)
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		efx->flow_control = EFX_FC_RX | EFX_FC_TX;
 	else
 		efx->flow_control = EFX_FC_RX;
@@ -2374,7 +2374,7 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		return -ENODEV;
 	}
 
-	switch (FALCON_REV(efx)) {
+	switch (falcon_rev(efx)) {
 	case FALCON_REV_A0:
 	case 0xff:
 		EFX_ERR(efx, "Falcon rev A0 not supported\n");
@@ -2400,7 +2400,7 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 		break;
 
 	default:
-		EFX_ERR(efx, "Unknown Falcon rev %d\n", FALCON_REV(efx));
+		EFX_ERR(efx, "Unknown Falcon rev %d\n", falcon_rev(efx));
 		return -ENODEV;
 	}
 
@@ -2563,7 +2563,7 @@ int falcon_init_nic(struct efx_nic *efx)
 
 	/* Set number of RSS queues for receive path. */
 	falcon_read(efx, &temp, RX_FILTER_CTL_REG);
-	if (FALCON_REV(efx) >= FALCON_REV_B0)
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, NUM_KER, 0);
 	else
 		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->rss_queues - 1);
@@ -2601,7 +2601,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
 	EFX_SET_OWORD_FIELD(temp, TX_PREF_THRESHOLD, 2);
 	/* Squash TX of packets of 16 bytes or less */
-	if (FALCON_REV(efx) >= FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
+	if (falcon_rev(efx) >= FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
 		EFX_SET_OWORD_FIELD(temp, TX_FLUSH_MIN_LEN_EN_B0, 1);
 	falcon_write(efx, &temp, TX_CFG2_REG_KER);
 
@@ -2618,7 +2618,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	if (EFX_WORKAROUND_7575(efx))
 		EFX_SET_OWORD_FIELD_VER(efx, temp, RX_USR_BUF_SIZE,
 					(3 * 4096) / 32);
-	if (FALCON_REV(efx) >= FALCON_REV_B0)
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, RX_INGR_EN_B0, 1);
 
 	/* RX FIFO flow control thresholds */
@@ -2634,7 +2634,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	falcon_write(efx, &temp, RX_CFG_REG_KER);
 
 	/* Set destination of both TX and RX Flush events */
-	if (FALCON_REV(efx) >= FALCON_REV_B0) {
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		EFX_POPULATE_OWORD_1(temp, FLS_EVQ_ID, 0);
 		falcon_write(efx, &temp, DP_CTRL_REG);
 	}
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 6117403..492f9bc 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -23,7 +23,10 @@ enum falcon_revision {
 	FALCON_REV_B0 = 2,
 };
 
-#define FALCON_REV(efx) ((efx)->pci_dev->revision)
+static inline int falcon_rev(struct efx_nic *efx)
+{
+	return efx->pci_dev->revision;
+}
 
 extern struct efx_nic_type falcon_a_nic_type;
 extern struct efx_nic_type falcon_b_nic_type;
diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
index ea08184..6670cdf 100644
--- a/drivers/net/sfc/falcon_io.h
+++ b/drivers/net/sfc/falcon_io.h
@@ -56,14 +56,27 @@
 #define FALCON_USE_QWORD_IO 1
 #endif
 
-#define _falcon_writeq(efx, value, reg) \
-	__raw_writeq((__force u64) (value), (efx)->membase + (reg))
-#define _falcon_writel(efx, value, reg) \
-	__raw_writel((__force u32) (value), (efx)->membase + (reg))
-#define _falcon_readq(efx, reg) \
-	((__force __le64) __raw_readq((efx)->membase + (reg)))
-#define _falcon_readl(efx, reg) \
-	((__force __le32) __raw_readl((efx)->membase + (reg)))
+#ifdef FALCON_USE_QWORD_IO
+static inline void _falcon_writeq(struct efx_nic *efx, __le64 value,
+				  unsigned int reg)
+{
+	__raw_writeq((__force u64)value, efx->membase + reg);
+}
+static inline __le64 _falcon_readq(struct efx_nic *efx, unsigned int reg)
+{
+	return (__force __le64)__raw_readq(efx->membase + reg);
+}
+#endif
+
+static inline void _falcon_writel(struct efx_nic *efx, __le32 value,
+				  unsigned int reg)
+{
+	__raw_writel((__force u32)value, efx->membase + reg);
+}
+static inline __le32 _falcon_readl(struct efx_nic *efx, unsigned int reg)
+{
+	return (__force __le32)__raw_readl(efx->membase + reg);
+}
 
 /* Writes to a normal 16-byte Falcon register, locking as appropriate. */
 static inline void falcon_write(struct efx_nic *efx, efx_oword_t *value,
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index d2978d4..dbdcee4 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -221,7 +221,7 @@ static int falcon_xgmii_status(struct efx_nic *efx)
 {
 	efx_dword_t reg;
 
-	if (FALCON_REV(efx) < FALCON_REV_B0)
+	if (falcon_rev(efx) < FALCON_REV_B0)
 		return 1;
 
 	/* The ISR latches, so clear it and re-read */
@@ -241,7 +241,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, int enable)
 {
 	efx_dword_t reg;
 
-	if ((FALCON_REV(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
+	if ((falcon_rev(efx) < FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
 	/* Flush the ISR */
@@ -639,7 +639,7 @@ int falcon_xmac_set_pause(struct efx_nic *efx, enum efx_fc_type flow_control)
 	reset = ((flow_control & EFX_FC_TX) &&
 		 !(efx->flow_control & EFX_FC_TX));
 	if (EFX_WORKAROUND_11482(efx) && reset) {
-		if (FALCON_REV(efx) >= FALCON_REV_B0) {
+		if (falcon_rev(efx) >= FALCON_REV_B0) {
 			/* Recover by resetting the EM block */
 			if (efx->link_up)
 				falcon_drain_tx_fifo(efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 59f261b..18b21ef 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -52,28 +52,19 @@
 #define EFX_WARN_ON_PARANOID(x) do {} while (0)
 #endif
 
-#define NET_DEV_REGISTERED(efx)					\
-	((efx)->net_dev->reg_state == NETREG_REGISTERED)
-
-/* Include net device name in log messages if it has been registered.
- * Use efx->name not efx->net_dev->name so that races with (un)registration
- * are harmless.
- */
-#define NET_DEV_NAME(efx) (NET_DEV_REGISTERED(efx) ? (efx)->name : "")
-
 /* Un-rate-limited logging */
 #define EFX_ERR(efx, fmt, args...) \
-dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, NET_DEV_NAME(efx), ##args)
+dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, efx_dev_name(efx), ##args)
 
 #define EFX_INFO(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, NET_DEV_NAME(efx), ##args)
+dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, efx_dev_name(efx), ##args)
 
 #ifdef EFX_ENABLE_DEBUG
 #define EFX_LOG(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##args)
+dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##args)
 #else
 #define EFX_LOG(efx, fmt, args...) \
-dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##args)
+dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##args)
 #endif
 
 #define EFX_TRACE(efx, fmt, args...) do {} while (0)
@@ -760,6 +751,20 @@ struct efx_nic {
 	void *loopback_selftest;
 };
 
+static inline int efx_dev_registered(struct efx_nic *efx)
+{
+	return efx->net_dev->reg_state == NETREG_REGISTERED;
+}
+
+/* Net device name, for inclusion in log messages if it has been registered.
+ * Use efx->name not efx->net_dev->name so that races with (un)registration
+ * are harmless.
+ */
+static inline const char *efx_dev_name(struct efx_nic *efx)
+{
+	return efx_dev_registered(efx) ? efx->name : "";
+}
+
 /**
  * struct efx_nic_type - Efx device type definition
  * @mem_bar: Memory BAR number
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index a641330..f15d332 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -86,14 +86,21 @@ static unsigned int rx_refill_limit = 95;
  */
 #define EFX_RXD_HEAD_ROOM 2
 
-/* Macros for zero-order pages (potentially) containing multiple RX buffers */
-#define RX_DATA_OFFSET(_data)				\
-	(((unsigned long) (_data)) & (PAGE_SIZE-1))
-#define RX_BUF_OFFSET(_rx_buf)				\
-	RX_DATA_OFFSET((_rx_buf)->data)
-
-#define RX_PAGE_SIZE(_efx)				\
-	(PAGE_SIZE * (1u << (_efx)->rx_buffer_order))
+static inline unsigned int efx_page_offset(void *p)
+{
+	return (__force unsigned int)p & (PAGE_SIZE - 1);
+}
+static inline unsigned int efx_rx_buf_offset(struct efx_rx_buffer *buf)
+{
+	/* Offset is always within one page, so we don't need to consider
+	 * the page order.
+	 */
+	return efx_page_offset(buf->data);
+}
+static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
+{
+	return PAGE_SIZE << efx->rx_buffer_order;
+}
 
 
 /**************************************************************************
@@ -269,7 +276,7 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
 			return -ENOMEM;
 
 		dma_addr = pci_map_page(efx->pci_dev, rx_buf->page,
-					0, RX_PAGE_SIZE(efx),
+					0, efx_rx_buf_size(efx),
 					PCI_DMA_FROMDEVICE);
 
 		if (unlikely(pci_dma_mapping_error(dma_addr))) {
@@ -284,7 +291,7 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
 				      EFX_PAGE_IP_ALIGN);
 	}
 
-	offset = RX_DATA_OFFSET(rx_queue->buf_data);
+	offset = efx_page_offset(rx_queue->buf_data);
 	rx_buf->len = bytes;
 	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
 	rx_buf->data = rx_queue->buf_data;
@@ -295,7 +302,7 @@ static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
 		rx_queue->buf_data += ((bytes + 0x1ff) & ~0x1ff);
 		offset += ((bytes + 0x1ff) & ~0x1ff);
 
-		space = RX_PAGE_SIZE(efx) - offset;
+		space = efx_rx_buf_size(efx) - offset;
 		if (space >= bytes) {
 			/* Refs dropped on kernel releasing each skb */
 			get_page(rx_queue->buf_page);
@@ -344,7 +351,8 @@ static inline void efx_unmap_rx_buffer(struct efx_nic *efx,
 		EFX_BUG_ON_PARANOID(rx_buf->skb);
 		if (rx_buf->unmap_addr) {
 			pci_unmap_page(efx->pci_dev, rx_buf->unmap_addr,
-				       RX_PAGE_SIZE(efx), PCI_DMA_FROMDEVICE);
+				       efx_rx_buf_size(efx),
+				       PCI_DMA_FROMDEVICE);
 			rx_buf->unmap_addr = 0;
 		}
 	} else if (likely(rx_buf->skb)) {
@@ -553,7 +561,7 @@ static inline void efx_rx_packet_lro(struct efx_channel *channel,
 		struct skb_frag_struct frags;
 
 		frags.page = rx_buf->page;
-		frags.page_offset = RX_BUF_OFFSET(rx_buf);
+		frags.page_offset = efx_rx_buf_offset(rx_buf);
 		frags.size = rx_buf->len;
 
 		lro_receive_frags(lro_mgr, &frags, rx_buf->len,
@@ -598,7 +606,7 @@ static inline struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
 	if (unlikely(rx_buf->len > hdr_len)) {
 		struct skb_frag_struct *frag = skb_shinfo(skb)->frags;
 		frag->page = rx_buf->page;
-		frag->page_offset = RX_BUF_OFFSET(rx_buf) + hdr_len;
+		frag->page_offset = efx_rx_buf_offset(rx_buf) + hdr_len;
 		frag->size = skb->len - hdr_len;
 		skb_shinfo(skb)->nr_frags = 1;
 		skb->data_len = frag->size;
@@ -852,7 +860,8 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 	/* For a page that is part-way through splitting into RX buffers */
 	if (rx_queue->buf_page != NULL) {
 		pci_unmap_page(rx_queue->efx->pci_dev, rx_queue->buf_dma_addr,
-			       RX_PAGE_SIZE(rx_queue->efx), PCI_DMA_FROMDEVICE);
+			       efx_rx_buf_size(rx_queue->efx),
+			       PCI_DMA_FROMDEVICE);
 		__free_pages(rx_queue->buf_page,
 			     rx_queue->efx->rx_buffer_order);
 		rx_queue->buf_page = NULL;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index cbda159..2fb69d8 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -424,10 +424,10 @@ static int efx_tx_loopback(struct efx_tx_queue *tx_queue)
 		 * interrupt handler. */
 		smp_wmb();
 
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_lock_bh(efx->net_dev);
 		rc = efx_xmit(efx, tx_queue, skb);
-		if (NET_DEV_REGISTERED(efx))
+		if (efx_dev_registered(efx))
 			netif_tx_unlock_bh(efx->net_dev);
 
 		if (rc != NETDEV_TX_OK) {
@@ -453,7 +453,7 @@ static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
 	int tx_done = 0, rx_good, rx_bad;
 	int i, rc = 0;
 
-	if (NET_DEV_REGISTERED(efx))
+	if (efx_dev_registered(efx))
 		netif_tx_lock_bh(efx->net_dev);
 
 	/* Count the number of tx completions, and decrement the refcnt. Any
@@ -465,7 +465,7 @@ static int efx_rx_loopback(struct efx_tx_queue *tx_queue,
 		dev_kfree_skb_any(skb);
 	}
 
-	if (NET_DEV_REGISTERED(efx))
+	if (efx_dev_registered(efx))
 		netif_tx_unlock_bh(efx->net_dev);
 
 	/* Check TX completion and received packet counts */
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 75eb0fd..5cdd082 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -387,7 +387,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	if (unlikely(tx_queue->stopped)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_NETDEV_TX_THRESHOLD(tx_queue)) {
-			EFX_BUG_ON_PARANOID(!NET_DEV_REGISTERED(efx));
+			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
 
 			/* Do this under netif_tx_lock(), to avoid racing
 			 * with efx_xmit(). */
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index dca62f1..35ab19c 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -16,7 +16,7 @@
  */
 
 #define EFX_WORKAROUND_ALWAYS(efx) 1
-#define EFX_WORKAROUND_FALCON_A(efx) (FALCON_REV(efx) <= FALCON_REV_A1)
+#define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
 
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
