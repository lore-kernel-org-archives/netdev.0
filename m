From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 4/8] sfc: Stop/re-start PTP when stopping/starting the
 datapath.
Date: Wed, 11 Dec 2013 01:56:13 +0000
Message-ID: <1386726973.1516.242.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40983 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab3LKB4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:56:17 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

This disables PTP when we bring the interface down to avoid getting
unmatched RX timestamp events, and tries to re-enable it when bringing
the interface up.

[bwh: Make efx_ptp_stop() safe on Falcon. Introduce
 efx_ptp_{start,stop}_datapath() functions; we'll expand them later.]

Fixes: 7c236c43b838 ('sfc: Add support for IEEE-1588 PTP')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |  4 ++++
 drivers/net/ethernet/sfc/nic.h |  2 ++
 drivers/net/ethernet/sfc/ptp.c | 30 +++++++++++++++++++++++++++---
 3 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2e27837ce6a2..8bd5b485f1bc 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -645,6 +645,8 @@ static void efx_start_datapath(struct efx_nic *efx)
 		WARN_ON(channel->rx_pkt_n_frags);
 	}
 
+	efx_ptp_start_datapath(efx);
+
 	if (netif_device_present(efx->net_dev))
 		netif_tx_wake_all_queues(efx->net_dev);
 }
@@ -659,6 +661,8 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
+	efx_ptp_stop_datapath(efx);
+
 	/* Stop RX refill */
 	efx_for_each_channel(channel, efx) {
 		efx_for_each_channel_rx_queue(rx_queue, channel)
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 11b6112d9249..91c63ec79c5f 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -560,6 +560,8 @@ void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info);
 bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
+void efx_ptp_start_datapath(struct efx_nic *efx);
+void efx_ptp_stop_datapath(struct efx_nic *efx);
 
 extern const struct efx_nic_type falcon_a1_nic_type;
 extern const struct efx_nic_type falcon_b0_nic_type;
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 8c665f1b5480..9bd99edf3f95 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -801,9 +801,14 @@ fail:
 static int efx_ptp_stop(struct efx_nic *efx)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;
-	int rc = efx_ptp_disable(efx);
 	struct list_head *cursor;
 	struct list_head *next;
+	int rc;
+
+	if (ptp == NULL)
+		return 0;
+
+	rc = efx_ptp_disable(efx);
 
 	if (ptp->rxfilter_installed) {
 		efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
@@ -828,6 +833,13 @@ static int efx_ptp_stop(struct efx_nic *efx)
 	return rc;
 }
 
+static int efx_ptp_restart(struct efx_nic *efx)
+{
+	if (efx->ptp_data && efx->ptp_data->enabled)
+		return efx_ptp_start(efx);
+	return 0;
+}
+
 static void efx_ptp_pps_worker(struct work_struct *work)
 {
 	struct efx_ptp_data *ptp =
@@ -1125,7 +1137,7 @@ static int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
 {
 	if ((enable_wanted != efx->ptp_data->enabled) ||
 	    (enable_wanted && (efx->ptp_data->mode != new_mode))) {
-		int rc;
+		int rc = 0;
 
 		if (enable_wanted) {
 			/* Change of mode requires disable */
@@ -1142,7 +1154,8 @@ static int efx_ptp_change_mode(struct efx_nic *efx, bool enable_wanted,
 			 * succeed.
 			 */
 			efx->ptp_data->mode = new_mode;
-			rc = efx_ptp_start(efx);
+			if (netif_running(efx->net_dev))
+				rc = efx_ptp_start(efx);
 			if (rc == 0) {
 				rc = efx_ptp_synchronize(efx,
 							 PTP_SYNC_ATTEMPTS * 2);
@@ -1515,3 +1528,14 @@ void efx_ptp_probe(struct efx_nic *efx)
 		efx->extra_channel_type[EFX_EXTRA_CHANNEL_PTP] =
 			&efx_ptp_channel_type;
 }
+
+void efx_ptp_start_datapath(struct efx_nic *efx)
+{
+	if (efx_ptp_restart(efx))
+		netif_err(efx, drv, efx->net_dev, "Failed to restart PTP.\n");
+}
+
+void efx_ptp_stop_datapath(struct efx_nic *efx)
+{
+	efx_ptp_stop(efx);
+}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
