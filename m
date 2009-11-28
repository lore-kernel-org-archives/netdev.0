From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/12] sfc: Decouple NIC revision number from Falcon PCI
 revision number
Date: Sat, 28 Nov 2009 15:36:04 +0000
Message-ID: <1259422564.3709.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59163 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbZK1PgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:36:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |    4 +-
 drivers/net/sfc/ethtool.c     |    2 +-
 drivers/net/sfc/falcon.c      |   68 ++++++++++++++++++----------------------
 drivers/net/sfc/falcon.h      |   16 +++++-----
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/net_driver.h  |    2 +
 drivers/net/sfc/selftest.c    |    2 +-
 drivers/net/sfc/workarounds.h |    4 +-
 8 files changed, 48 insertions(+), 52 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index bed45a5..f5e8111 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1863,9 +1863,9 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 /* PCI device ID table */
 static struct pci_device_id efx_pci_table[] __devinitdata = {
 	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_A_P_DEVID),
-	 .driver_data = (unsigned long) &falcon_a_nic_type},
+	 .driver_data = (unsigned long) &falcon_a1_nic_type},
 	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_B_P_DEVID),
-	 .driver_data = (unsigned long) &falcon_b_nic_type},
+	 .driver_data = (unsigned long) &falcon_b0_nic_type},
 	{0}			/* end of list */
 };
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 6515b8a..5d2e186 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -683,7 +683,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	 * and fix it be cycling transmit flow control on this end. */
 	reset = (wanted_fc & EFX_FC_TX) && !(efx->wanted_fc & EFX_FC_TX);
 	if (EFX_WORKAROUND_11482(efx) && reset) {
-		if (falcon_rev(efx) == FALCON_REV_B0) {
+		if (efx_nic_rev(efx) == EFX_REV_FALCON_B0) {
 			/* Recover by resetting the EM block */
 			if (efx->link_state.up)
 				falcon_drain_tx_fifo(efx);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b186fd2..7c9c9c9 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -111,7 +111,7 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 #define FALCON_RX_FLUSH_COUNT 4
 
 #define FALCON_IS_DUAL_FUNC(efx)		\
-	(falcon_rev(efx) < FALCON_REV_B0)
+	(efx_nic_rev(efx) < EFX_REV_FALCON_B0)
 
 /**************************************************************************
  *
@@ -447,7 +447,7 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      FRF_AZ_TX_DESCQ_TYPE, 0,
 			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
 
-	if (falcon_rev(efx) >= FALCON_REV_B0) {
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		int csum = tx_queue->queue == EFX_TX_QUEUE_OFFLOAD_CSUM;
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_IP_CHKSM_DIS, !csum);
 		EFX_SET_OWORD_FIELD(tx_desc_ptr, FRF_BZ_TX_TCP_CHKSM_DIS,
@@ -457,7 +457,7 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	efx_writeo_table(efx, &tx_desc_ptr, efx->type->txd_ptr_tbl_base,
 			 tx_queue->queue);
 
-	if (falcon_rev(efx) < FALCON_REV_B0) {
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
 		efx_oword_t reg;
 
 		/* Only 128 bits in this register */
@@ -574,7 +574,7 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
-	bool is_b0 = falcon_rev(efx) >= FALCON_REV_B0;
+	bool is_b0 = efx_nic_rev(efx) >= EFX_REV_FALCON_B0;
 	bool iscsi_digest_en = is_b0;
 
 	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
@@ -752,7 +752,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 						   FSF_AZ_RX_EV_TCP_UDP_CHKSUM_ERR);
 	rx_ev_eth_crc_err = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_ETH_CRC_ERR);
 	rx_ev_frm_trunc = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_FRM_TRUNC);
-	rx_ev_drib_nib = ((falcon_rev(efx) >= FALCON_REV_B0) ?
+	rx_ev_drib_nib = ((efx_nic_rev(efx) >= EFX_REV_FALCON_B0) ?
 			  0 : EFX_QWORD_FIELD(*event, FSF_AA_RX_EV_DRIB_NIB));
 	rx_ev_pause_frm = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PAUSE_FRM_ERR);
 
@@ -897,13 +897,13 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 		handled = true;
 	}
 
-	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
+	if ((efx_nic_rev(efx) >= EFX_REV_FALCON_B0) &&
 	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
 		efx->xmac_poll_required = true;
 		handled = true;
 	}
 
-	if (falcon_rev(efx) <= FALCON_REV_A1 ?
+	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ?
 	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
 	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
 		EFX_ERR(efx, "channel %d seen global RX_RESET "
@@ -1531,7 +1531,7 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 	unsigned long offset;
 	efx_dword_t dword;
 
-	if (falcon_rev(efx) < FALCON_REV_B0)
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
 		return;
 
 	for (offset = FR_BZ_RX_INDIRECTION_TBL;
@@ -1554,7 +1554,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 
 	if (!EFX_INT_MODE_USE_MSI(efx)) {
 		irq_handler_t handler;
-		if (falcon_rev(efx) >= FALCON_REV_B0)
+		if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 			handler = falcon_legacy_interrupt_b0;
 		else
 			handler = falcon_legacy_interrupt_a1;
@@ -1601,7 +1601,7 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 	}
 
 	/* ACK legacy interrupt */
-	if (falcon_rev(efx) >= FALCON_REV_B0)
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		efx_reado(efx, &reg, FR_BZ_INT_ISR0);
 	else
 		falcon_irq_ack_a1(efx);
@@ -1841,7 +1841,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
 	efx_oword_t reg;
 	int count;
 
-	if (falcon_rev(efx) < FALCON_REV_B0) {
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
 		/* It's not safe to use GLB_CTL_REG to reset the
 		 * macs, so instead use the internal MAC resets
 		 */
@@ -1917,7 +1917,7 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 
-	if ((falcon_rev(efx) < FALCON_REV_B0) ||
+	if ((efx_nic_rev(efx) < EFX_REV_FALCON_B0) ||
 	    (efx->loopback_mode != LOOPBACK_NONE))
 		return;
 
@@ -1933,7 +1933,7 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 
-	if (falcon_rev(efx) < FALCON_REV_B0)
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
 		return;
 
 	/* Isolate the MAC -> RX */
@@ -1970,7 +1970,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 			     FRF_AB_MAC_SPEED, link_speed);
 	/* On B0, MAC backpressure can be disabled and packets get
 	 * discarded. */
-	if (falcon_rev(efx) >= FALCON_REV_B0) {
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
 				    !link_state->up);
 	}
@@ -1988,7 +1988,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, tx_fc);
 
 	/* Unisolate the MAC -> RX */
-	if (falcon_rev(efx) >= FALCON_REV_B0)
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
@@ -2207,7 +2207,7 @@ static void falcon_clock_mac(struct efx_nic *efx)
 	/* Configure the NIC generated MAC clock correctly */
 	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
 	strap_val = EFX_IS10G(efx) ? 5 : 3;
-	if (falcon_rev(efx) >= FALCON_REV_B0) {
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
 		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
 		efx_writeo(efx, &nic_stat, FR_AB_NIC_STAT);
@@ -2296,7 +2296,7 @@ int falcon_probe_port(struct efx_nic *efx)
 	efx->link_state.fd = true;
 
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
-	if (falcon_rev(efx) >= FALCON_REV_B0)
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
 	else
 		efx->wanted_fc = EFX_FC_RX;
@@ -2806,13 +2806,13 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 
 	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
 
-	switch (falcon_rev(efx)) {
-	case FALCON_REV_A0:
-	case 0xff:
-		EFX_ERR(efx, "Falcon rev A0 not supported\n");
-		return -ENODEV;
+	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
+		u8 pci_rev = efx->pci_dev->revision;
 
-	case FALCON_REV_A1:
+		if ((pci_rev == 0xff) || (pci_rev == 0)) {
+			EFX_ERR(efx, "Falcon rev A0 not supported\n");
+			return -ENODEV;
+		}
 		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
 			EFX_ERR(efx, "Falcon rev A1 1G not supported\n");
 			return -ENODEV;
@@ -2821,14 +2821,6 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
 			return -ENODEV;
 		}
-		break;
-
-	case FALCON_REV_B0:
-		break;
-
-	default:
-		EFX_ERR(efx, "Unknown Falcon rev %d\n", falcon_rev(efx));
-		return -ENODEV;
 	}
 
 	return 0;
@@ -2991,7 +2983,7 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	efx_oword_t reg;
 
 	efx_reado(efx, &reg, FR_AZ_RX_CFG);
-	if (falcon_rev(efx) <= FALCON_REV_A1) {
+	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
 		/* Data FIFO size is 5.5K */
 		if (data_xon_thr < 0)
 			data_xon_thr = 512 >> 8;
@@ -3037,7 +3029,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
 
 	/* Set the source of the GMAC clock */
-	if (falcon_rev(efx) == FALCON_REV_B0) {
+	if (efx_nic_rev(efx) == EFX_REV_FALCON_B0) {
 		efx_reado(efx, &temp, FR_AB_GPIO_CTL);
 		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
 		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
@@ -3128,7 +3120,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
 	/* Squash TX of packets of 16 bytes or less */
-	if (falcon_rev(efx) >= FALCON_REV_B0)
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
 
@@ -3142,7 +3134,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	falcon_init_rx_cfg(efx);
 
 	/* Set destination of both TX and RX Flush events */
-	if (falcon_rev(efx) >= FALCON_REV_B0) {
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		EFX_POPULATE_OWORD_1(temp, FRF_BZ_FLS_EVQ_ID, 0);
 		efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
 	}
@@ -3242,9 +3234,10 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
  **************************************************************************
  */
 
-struct efx_nic_type falcon_a_nic_type = {
+struct efx_nic_type falcon_a1_nic_type = {
 	.default_mac_ops = &falcon_xmac_operations,
 
+	.revision = EFX_REV_FALCON_A1,
 	.mem_map_size = 0x20000,
 	.txd_ptr_tbl_base = FR_AA_TX_DESC_PTR_TBL_KER,
 	.rxd_ptr_tbl_base = FR_AA_RX_DESC_PTR_TBL_KER,
@@ -3257,9 +3250,10 @@ struct efx_nic_type falcon_a_nic_type = {
 	.phys_addr_channels = 4,
 };
 
-struct efx_nic_type falcon_b_nic_type = {
+struct efx_nic_type falcon_b0_nic_type = {
 	.default_mac_ops = &falcon_xmac_operations,
 
+	.revision = EFX_REV_FALCON_B0,
 	/* Map everything up to and including the RSS indirection
 	 * table.  Don't map MSI-X table, MSI-X PBA since Linux
 	 * requires that they not be mapped.  */
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index a561f67..81196a0 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -19,15 +19,15 @@
  * Falcon hardware control
  */
 
-enum falcon_revision {
-	FALCON_REV_A0 = 0,
-	FALCON_REV_A1 = 1,
-	FALCON_REV_B0 = 2,
+enum {
+	EFX_REV_FALCON_A0 = 0,
+	EFX_REV_FALCON_A1 = 1,
+	EFX_REV_FALCON_B0 = 2,
 };
 
-static inline int falcon_rev(struct efx_nic *efx)
+static inline int efx_nic_rev(struct efx_nic *efx)
 {
-	return efx->pci_dev->revision;
+	return efx->type->revision;
 }
 
 /**
@@ -95,8 +95,8 @@ static inline struct falcon_board *falcon_board(struct efx_nic *efx)
 	return &data->board;
 }
 
-extern struct efx_nic_type falcon_a_nic_type;
-extern struct efx_nic_type falcon_b_nic_type;
+extern struct efx_nic_type falcon_a1_nic_type;
+extern struct efx_nic_type falcon_b0_nic_type;
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 784260f..1523efd 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -89,7 +89,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 {
 	efx_oword_t reg;
 
-	if ((falcon_rev(efx) != FALCON_REV_B0) || LOOPBACK_INTERNAL(efx))
+	if ((efx_nic_rev(efx) != EFX_REV_FALCON_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
 	/* We expect xgmii faults if the wireside link is up */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ca7dff2..a42a051 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -844,6 +844,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 /**
  * struct efx_nic_type - Efx device type definition
  * @default_mac_ops: efx_mac_operations to set at startup
+ * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -860,6 +861,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 struct efx_nic_type {
 	struct efx_mac_operations *default_mac_ops;
 
+	int revision;
 	unsigned int mem_map_size;
 	unsigned int txd_ptr_tbl_base;
 	unsigned int rxd_ptr_tbl_base;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 1580607..74e84af 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -125,7 +125,7 @@ static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 	int rc;
 
 	/* Not supported on A-series silicon */
-	if (falcon_rev(efx) < FALCON_REV_B0)
+	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
 		return 0;
 
 	rc = falcon_test_registers(efx);
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 209ee1e..021d0d2 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -16,8 +16,8 @@
  */
 
 #define EFX_WORKAROUND_ALWAYS(efx) 1
-#define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
-#define EFX_WORKAROUND_FALCON_AB(efx) (falcon_rev(efx) <= FALCON_REV_B0)
+#define EFX_WORKAROUND_FALCON_A(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_A1)
+#define EFX_WORKAROUND_FALCON_AB(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_B0)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
 #define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A || \
 				     (efx)->phy_type == PHY_TYPE_SFT9001B)
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

