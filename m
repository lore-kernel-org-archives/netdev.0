From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] sfc: Add EF10 support for TX/RX DMA error
 events handling.
Date: Wed, 28 Aug 2013 16:19:25 +0100
Message-ID: <1377703165.2264.30.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17233 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754Ab3H1PT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:19:29 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

Also, since we handle all DMA errors in the same way, merge
RESET_TYPE_(RX|TX)_DESC_FETCH into RESET_TYPE_DMA_ERROR.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c    | 3 +--
 drivers/net/ethernet/sfc/enum.h   | 6 ++----
 drivers/net/ethernet/sfc/falcon.c | 3 +--
 drivers/net/ethernet/sfc/farch.c  | 6 +++---
 drivers/net/ethernet/sfc/mcdi.c   | 8 ++++++++
 5 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 9fe375f..efad5f7 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -80,8 +80,7 @@ const char *const efx_reset_type_names[] = {
 	[RESET_TYPE_TX_WATCHDOG]        = "TX_WATCHDOG",
 	[RESET_TYPE_INT_ERROR]          = "INT_ERROR",
 	[RESET_TYPE_RX_RECOVERY]        = "RX_RECOVERY",
-	[RESET_TYPE_RX_DESC_FETCH]      = "RX_DESC_FETCH",
-	[RESET_TYPE_TX_DESC_FETCH]      = "TX_DESC_FETCH",
+	[RESET_TYPE_DMA_ERROR]          = "DMA_ERROR",
 	[RESET_TYPE_TX_SKIP]            = "TX_SKIP",
 	[RESET_TYPE_MC_FAILURE]         = "MC_FAILURE",
 };
diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index ab8fb58..8665921 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -147,8 +147,7 @@ enum efx_loopback_mode {
  * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
  * @RESET_TYPE_INT_ERROR: reset due to internal error
  * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
- * @RESET_TYPE_RX_DESC_FETCH: pcie error during rx descriptor fetch
- * @RESET_TYPE_TX_DESC_FETCH: pcie error during tx descriptor fetch
+ * @RESET_TYPE_DMA_ERROR: DMA error
  * @RESET_TYPE_TX_SKIP: hardware completed empty tx descriptors
  * @RESET_TYPE_MC_FAILURE: MC reboot/assertion
  */
@@ -163,8 +162,7 @@ enum reset_type {
 	RESET_TYPE_TX_WATCHDOG,
 	RESET_TYPE_INT_ERROR,
 	RESET_TYPE_RX_RECOVERY,
-	RESET_TYPE_RX_DESC_FETCH,
-	RESET_TYPE_TX_DESC_FETCH,
+	RESET_TYPE_DMA_ERROR,
 	RESET_TYPE_TX_SKIP,
 	RESET_TYPE_MC_FAILURE,
 	RESET_TYPE_MAX,
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 0be1f37..1140b83 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1893,8 +1893,7 @@ static enum reset_type falcon_map_reset_reason(enum reset_type reason)
 {
 	switch (reason) {
 	case RESET_TYPE_RX_RECOVERY:
-	case RESET_TYPE_RX_DESC_FETCH:
-	case RESET_TYPE_TX_DESC_FETCH:
+	case RESET_TYPE_DMA_ERROR:
 	case RESET_TYPE_TX_SKIP:
 		/* These can occasionally occur due to hardware bugs.
 		 * We try to reset without disrupting the link.
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index b6af8f4..d21483d 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -832,7 +832,7 @@ efx_farch_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 		efx_farch_notify_tx_desc(tx_queue);
 		netif_tx_unlock(efx->net_dev);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR)) {
-		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
+		efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 	} else {
 		netif_err(efx, tx_err, efx->net_dev,
 			  "channel %d unexpected TX event "
@@ -1217,7 +1217,7 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 				  "RX DMA Q %d reports descriptor fetch error."
 				  " RX Q %d is disabled.\n", ev_sub_data,
 				  ev_sub_data);
-			efx_schedule_reset(efx, RESET_TYPE_RX_DESC_FETCH);
+			efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 		} else
 			efx_sriov_desc_fetch_err(efx, ev_sub_data);
 		break;
@@ -1227,7 +1227,7 @@ efx_farch_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 				  "TX DMA Q %d reports descriptor fetch error."
 				  " TX Q %d is disabled.\n", ev_sub_data,
 				  ev_sub_data);
-			efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
+			efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 		} else
 			efx_sriov_desc_fetch_err(efx, ev_sub_data);
 		break;
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index ff90ebf..3810634 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -587,6 +587,14 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		efx_ptp_event(efx, event);
 		break;
 
+	case MCDI_EVENT_CODE_TX_ERR:
+	case MCDI_EVENT_CODE_RX_ERR:
+		netif_err(efx, hw, efx->net_dev,
+			  "%s DMA error (event: "EFX_QWORD_FMT")\n",
+			  code == MCDI_EVENT_CODE_TX_ERR ? "TX" : "RX",
+			  EFX_QWORD_VAL(*event));
+		efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
+		break;
 	default:
 		netif_err(efx, hw, efx->net_dev, "Unknown MCDI event 0x%x\n",
 			  code);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
