From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 12/17] sfc: Move Falcon global event handling
 to falcon.c
Date: Thu, 02 Dec 2010 23:47:45 +0000
Message-ID: <1291333665.3259.35.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13112 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332Ab0LBXrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:48 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   36 +++++++++++++++++++++++++++++++
 drivers/net/sfc/net_driver.h |    2 +
 drivers/net/sfc/nic.c        |   48 ++++-------------------------------------
 3 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index af62899..fd5bf0b 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -881,6 +881,40 @@ static void falcon_remove_port(struct efx_nic *efx)
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
+/* Global events are basically PHY events */
+static bool
+falcon_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
+{
+	struct efx_nic *efx = channel->efx;
+
+	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
+	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
+	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR))
+		/* Ignored */
+		return true;
+
+	if ((efx_nic_rev(efx) == EFX_REV_FALCON_B0) &&
+	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
+		efx->xmac_poll_required = true;
+		return true;
+	}
+
+	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ?
+	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
+	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
+		netif_err(efx, rx_err, efx->net_dev,
+			  "channel %d seen global RX_RESET event. Resetting.\n",
+			  channel->channel);
+
+		atomic_inc(&efx->rx_reset);
+		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
+				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
+		return true;
+	}
+
+	return false;
+}
+
 /**************************************************************************
  *
  * Falcon test code
@@ -1702,6 +1736,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.reset = falcon_reset_hw,
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
+	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
@@ -1742,6 +1777,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.reset = falcon_reset_hw,
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
+	.handle_global_event = falcon_handle_global_event,
 	.prepare_flush = falcon_prepare_flush,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 2ffc920..f9d53a0 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -819,6 +819,7 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  *	be called while the controller is uninitialised.
  * @probe_port: Probe the MAC and PHY
  * @remove_port: Free resources allocated by probe_port()
+ * @handle_global_event: Handle a "global" event (may be %NULL)
  * @prepare_flush: Prepare the hardware for flushing the DMA queues
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
@@ -863,6 +864,7 @@ struct efx_nic_type {
 	int (*reset)(struct efx_nic *efx, enum reset_type method);
 	int (*probe_port)(struct efx_nic *efx);
 	void (*remove_port)(struct efx_nic *efx);
+	bool (*handle_global_event)(struct efx_channel *channel, efx_qword_t *);
 	void (*prepare_flush)(struct efx_nic *efx);
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 41c36b9..9743cff 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -894,46 +894,6 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 			  channel->channel, EFX_QWORD_VAL(*event));
 }
 
-/* Global events are basically PHY events */
-static void
-efx_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
-{
-	struct efx_nic *efx = channel->efx;
-	bool handled = false;
-
-	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
-	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
-	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR)) {
-		/* Ignored */
-		handled = true;
-	}
-
-	if ((efx_nic_rev(efx) >= EFX_REV_FALCON_B0) &&
-	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_XG_MGT_INTR)) {
-		efx->xmac_poll_required = true;
-		handled = true;
-	}
-
-	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ?
-	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
-	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
-		netif_err(efx, rx_err, efx->net_dev,
-			  "channel %d seen global RX_RESET event. Resetting.\n",
-			  channel->channel);
-
-		atomic_inc(&efx->rx_reset);
-		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
-				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
-		handled = true;
-	}
-
-	if (!handled)
-		netif_err(efx, hw, efx->net_dev,
-			  "channel %d unknown global event "
-			  EFX_QWORD_FMT "\n", channel->channel,
-			  EFX_QWORD_VAL(*event));
-}
-
 static void
 efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 {
@@ -1050,15 +1010,17 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 		case FSE_AZ_EV_CODE_DRV_GEN_EV:
 			efx_handle_generated_event(channel, &event);
 			break;
-		case FSE_AZ_EV_CODE_GLOBAL_EV:
-			efx_handle_global_event(channel, &event);
-			break;
 		case FSE_AZ_EV_CODE_DRIVER_EV:
 			efx_handle_driver_event(channel, &event);
 			break;
 		case FSE_CZ_EV_CODE_MCDI_EV:
 			efx_mcdi_process_event(channel, &event);
 			break;
+		case FSE_AZ_EV_CODE_GLOBAL_EV:
+			if (efx->type->handle_global_event &&
+			    efx->type->handle_global_event(channel, &event))
+				break;
+			/* else fall through */
 		default:
 			netif_err(channel->efx, hw, channel->efx->net_dev,
 				  "channel %d unknown event type %d (data "
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

