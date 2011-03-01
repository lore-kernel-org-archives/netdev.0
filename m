From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 7/8] sfc: Remove configurable FIFO thresholds
 for pause frame generation
Date: Tue, 01 Mar 2011 01:23:36 +0000
Message-ID: <1298942616.3069.186.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1CABXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:23:39 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Falcon we can configure the fill levels of the RX data FIFO which
trigger the generation of pause frames (if enabled), and we have
module parameters for this.

Siena does not allow the levels to be configured (or, if it does, this
is done by the MC firmware and is not configurable by drivers).

So far as I can tell, the module parameters are not used by our
internal scripts and have not been documented (with the exception of
the short parameter descriptions).  Therefore, remove them and always
initialise Falcon with the default values.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   20 +++++---------------
 drivers/net/sfc/nic.c    |   20 --------------------
 drivers/net/sfc/nic.h    |    1 -
 drivers/net/sfc/siena.c  |    5 -----
 4 files changed, 5 insertions(+), 41 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 87481a6..734fcfb 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1478,36 +1478,26 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	/* RX control FIFO thresholds (32 entries) */
 	const unsigned ctrl_xon_thr = 20;
 	const unsigned ctrl_xoff_thr = 25;
-	/* RX data FIFO thresholds (256-byte units; size varies) */
-	int data_xon_thr = efx_nic_rx_xon_thresh >> 8;
-	int data_xoff_thr = efx_nic_rx_xoff_thresh >> 8;
 	efx_oword_t reg;
 
 	efx_reado(efx, &reg, FR_AZ_RX_CFG);
 	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1) {
 		/* Data FIFO size is 5.5K */
-		if (data_xon_thr < 0)
-			data_xon_thr = 512 >> 8;
-		if (data_xoff_thr < 0)
-			data_xoff_thr = 2048 >> 8;
 		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_DESC_PUSH_EN, 0);
 		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_USR_BUF_SIZE,
 				    huge_buf_size);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_MAC_TH, data_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_MAC_TH, data_xoff_thr);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_MAC_TH, 512 >> 8);
+		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_MAC_TH, 2048 >> 8);
 		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XON_TX_TH, ctrl_xon_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_AA_RX_XOFF_TX_TH, ctrl_xoff_thr);
 	} else {
 		/* Data FIFO size is 80K; register fields moved */
-		if (data_xon_thr < 0)
-			data_xon_thr = 27648 >> 8; /* ~3*max MTU */
-		if (data_xoff_thr < 0)
-			data_xoff_thr = 54272 >> 8; /* ~80Kb - 3*max MTU */
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_DESC_PUSH_EN, 0);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_USR_BUF_SIZE,
 				    huge_buf_size);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_MAC_TH, data_xon_thr);
-		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, data_xoff_thr);
+		/* Send XON and XOFF at ~3 * max MTU away from empty/full */
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_MAC_TH, 27648 >> 8);
+		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_MAC_TH, 54272 >> 8);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XON_TX_TH, ctrl_xon_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_XOFF_TX_TH, ctrl_xoff_thr);
 		EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 1);
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index fb25b87..e839661 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -41,26 +41,6 @@
 #define RX_DC_ENTRIES 64
 #define RX_DC_ENTRIES_ORDER 3
 
-/* RX FIFO XOFF watermark
- *
- * When the amount of the RX FIFO increases used increases past this
- * watermark send XOFF. Only used if RX flow control is enabled (ethtool -A)
- * This also has an effect on RX/TX arbitration
- */
-int efx_nic_rx_xoff_thresh = -1;
-module_param_named(rx_xoff_thresh_bytes, efx_nic_rx_xoff_thresh, int, 0644);
-MODULE_PARM_DESC(rx_xoff_thresh_bytes, "RX fifo XOFF threshold");
-
-/* RX FIFO XON watermark
- *
- * When the amount of the RX FIFO used decreases below this
- * watermark send XON. Only used if TX flow control is enabled (ethtool -A)
- * This also has an effect on RX/TX arbitration
- */
-int efx_nic_rx_xon_thresh = -1;
-module_param_named(rx_xon_thresh_bytes, efx_nic_rx_xon_thresh, int, 0644);
-MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
-
 /* If EFX_MAX_INT_ERRORS internal errors occur within
  * EFX_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
  * disable it.
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 1daaee6..d9de1b6 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -188,7 +188,6 @@ extern void efx_nic_eventq_read_ack(struct efx_channel *channel);
 /* MAC/PHY */
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
 extern void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
-extern int efx_nic_rx_xoff_thresh, efx_nic_rx_xon_thresh;
 
 /* Interrupts and test events */
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 8bd537e..e4dd898 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -341,11 +341,6 @@ static int siena_init_nic(struct efx_nic *efx)
 	       FRF_CZ_RX_RSS_IPV6_TKEY_HI_WIDTH / 8);
 	efx_writeo(efx, &temp, FR_CZ_RX_RSS_IPV6_REG3);
 
-	if (efx_nic_rx_xoff_thresh >= 0 || efx_nic_rx_xon_thresh >= 0)
-		/* No MCDI operation has been defined to set thresholds */
-		netif_err(efx, hw, efx->net_dev,
-			  "ignoring RX flow control thresholds\n");
-
 	/* Enable event logging */
 	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
 	if (rc)
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

