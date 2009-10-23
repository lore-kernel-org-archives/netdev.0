From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/27] sfc: Remove versioned bitfield macros
Date: Fri, 23 Oct 2009 19:30:06 +0100
Message-ID: <1256322606.2785.15.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8602 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbZJWSaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:30:04 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros are not extensible to more than two NIC types without
repetition of register definitions, and they are only used to deal
with a few fields in RX_CFG_REG and global events which moved between
Falcon rev A1 and B0.

Therefore:
- Move RX_CFG_REG initialisation into its own function which tests the
  NIC revision just once
- Explicitly test the NIC revision when checking the RX_RECOVERY flag in
  global events
- Merge definitions of RX_XOFF_MAC_EN flag, which did not move
- Remove the macro definitions

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/bitfield.h      |   13 -------
 drivers/net/sfc/falcon.c        |   67 +++++++++++++++++++++++++-------------
 drivers/net/sfc/falcon_hwdefs.h |    7 ++--
 3 files changed, 47 insertions(+), 40 deletions(-)

diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index d54d84c..6ad909b 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -520,19 +520,6 @@ typedef union efx_oword {
 #define EFX_SET_QWORD_FIELD EFX_SET_QWORD_FIELD32
 #endif
 
-#define EFX_SET_OWORD_FIELD_VER(efx, oword, field, value) do { \
-	if (falcon_rev(efx) >= FALCON_REV_B0) {			   \
-		EFX_SET_OWORD_FIELD((oword), field##_B0, (value)); \
-	} else { \
-		EFX_SET_OWORD_FIELD((oword), field##_A1, (value)); \
-	} \
-} while (0)
-
-#define EFX_QWORD_FIELD_VER(efx, qword, field)	\
-	(falcon_rev(efx) >= FALCON_REV_B0 ?	\
-	 EFX_QWORD_FIELD((qword), field##_B0) :	\
-	 EFX_QWORD_FIELD((qword), field##_A1))
-
 /* Used to avoid compiler warnings about shift range exceeding width
  * of the data types when dma_addr_t is only 32 bits wide.
  */
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index eed8d1f..4cb98d4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -929,7 +929,9 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 		handled = true;
 	}
 
-	if (EFX_QWORD_FIELD_VER(efx, *event, RX_RECOVERY)) {
+	if (falcon_rev(efx) <= FALCON_REV_A1 ?
+	    EFX_QWORD_FIELD(*event, RX_RECOVERY_A1) :
+	    EFX_QWORD_FIELD(*event, RX_RECOVERY_B0)) {
 		EFX_ERR(efx, "channel %d seen global RX_RESET "
 			"event. Resetting.\n", channel->channel);
 
@@ -2006,7 +2008,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
 	tx_fc = !!(efx->link_fc & EFX_FC_TX);
 	falcon_read(efx, &reg, RX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
+	EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_EN, tx_fc);
 
 	/* Unisolate the MAC -> RX */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
@@ -2910,6 +2912,45 @@ int falcon_probe_nic(struct efx_nic *efx)
 	return rc;
 }
 
+static void falcon_init_rx_cfg(struct efx_nic *efx)
+{
+	/* Prior to Siena the RX DMA engine will split each frame at
+	 * intervals of RX_USR_BUF_SIZE (32-byte units). We set it to
+	 * be so large that that never happens. */
+	const unsigned huge_buf_size = (3 * 4096) >> 5;
+	/* RX control FIFO thresholds (32 entries) */
+	const unsigned ctrl_xon_thr = 20;
+	const unsigned ctrl_xoff_thr = 25;
+	/* RX data FIFO thresholds (256-byte units; size varies) */
+	unsigned data_xon_thr =
+		((rx_xon_thresh_bytes >= 0) ?
+		 rx_xon_thresh_bytes : efx->type->rx_xon_thresh) >> 8;
+	unsigned data_xoff_thr =
+		((rx_xoff_thresh_bytes >= 0) ?
+		 rx_xoff_thresh_bytes : efx->type->rx_xoff_thresh) >> 8;
+	efx_oword_t reg;
+
+	falcon_read(efx, &reg, RX_CFG_REG_KER);
+	if (falcon_rev(efx) <= FALCON_REV_A1) {
+		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_A1, 0);
+		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_A1, huge_buf_size);
+		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_A1, data_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_TH_A1, data_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XON_TX_TH_A1, ctrl_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XOFF_TX_TH_A1, ctrl_xoff_thr);
+	} else {
+		/* Register fields moved */
+		EFX_SET_OWORD_FIELD(reg, RX_DESC_PUSH_EN_B0, 0);
+		EFX_SET_OWORD_FIELD(reg, RX_USR_BUF_SIZE_B0, huge_buf_size);
+		EFX_SET_OWORD_FIELD(reg, RX_XON_MAC_TH_B0, data_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XOFF_MAC_TH_B0, data_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XON_TX_TH_B0, ctrl_xon_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_XOFF_TX_TH_B0, ctrl_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, RX_INGR_EN_B0, 1);
+	}
+	falcon_write(efx, &reg, RX_CFG_REG_KER);
+}
+
 /* This call performs hardware-specific global initialisation, such as
  * defining the descriptor cache sizes and number of RSS channels.
  * It does not set up any buffers, descriptor rings or event queues.
@@ -2917,7 +2958,6 @@ int falcon_probe_nic(struct efx_nic *efx)
 int falcon_init_nic(struct efx_nic *efx)
 {
 	efx_oword_t temp;
-	unsigned thresh;
 	int rc;
 
 	/* Use on-chip SRAM */
@@ -3024,26 +3064,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, TX_NO_EOP_DISC_EN, 0);
 	falcon_write(efx, &temp, TX_CFG_REG_KER);
 
-	/* RX config */
-	falcon_read(efx, &temp, RX_CFG_REG_KER);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_DESC_PUSH_EN, 0);
-	if (EFX_WORKAROUND_7575(efx))
-		EFX_SET_OWORD_FIELD_VER(efx, temp, RX_USR_BUF_SIZE,
-					(3 * 4096) / 32);
-	if (falcon_rev(efx) >= FALCON_REV_B0)
-		EFX_SET_OWORD_FIELD(temp, RX_INGR_EN_B0, 1);
-
-	/* RX FIFO flow control thresholds */
-	thresh = ((rx_xon_thresh_bytes >= 0) ?
-		  rx_xon_thresh_bytes : efx->type->rx_xon_thresh);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_MAC_TH, thresh / 256);
-	thresh = ((rx_xoff_thresh_bytes >= 0) ?
-		  rx_xoff_thresh_bytes : efx->type->rx_xoff_thresh);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_MAC_TH, thresh / 256);
-	/* RX control FIFO thresholds [32 entries] */
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XON_TX_TH, 20);
-	EFX_SET_OWORD_FIELD_VER(efx, temp, RX_XOFF_TX_TH, 25);
-	falcon_write(efx, &temp, RX_CFG_REG_KER);
+	falcon_init_rx_cfg(efx);
 
 	/* Set destination of both TX and RX Flush events */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 2d22611..13f3999 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -313,8 +313,6 @@
 #define RX_XON_MAC_TH_B0_WIDTH 9
 #define RX_XOFF_MAC_TH_B0_LBN 1
 #define RX_XOFF_MAC_TH_B0_WIDTH 9
-#define RX_XOFF_MAC_EN_B0_LBN 0
-#define RX_XOFF_MAC_EN_B0_WIDTH 1
 
 /* A1 */
 #define RX_DESC_PUSH_EN_A1_LBN 35
@@ -329,8 +327,9 @@
 #define RX_XON_MAC_TH_A1_WIDTH 5
 #define RX_XOFF_MAC_TH_A1_LBN 1
 #define RX_XOFF_MAC_TH_A1_WIDTH 5
-#define RX_XOFF_MAC_EN_A1_LBN 0
-#define RX_XOFF_MAC_EN_A1_WIDTH 1
+
+#define RX_XOFF_MAC_EN_LBN 0
+#define RX_XOFF_MAC_EN_WIDTH 1
 
 /* Receive filter control register */
 #define RX_FILTER_CTL_REG 0x810

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

