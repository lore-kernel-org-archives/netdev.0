From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/15] sfc: Enable PTP clock and timestamping for
 all functions on EF10
Date: Sat, 14 Dec 2013 23:06:55 +0000
Message-ID: <1387062415.12172.71.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17435 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab3LNXHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:07:01 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC9100 family has only one clock per controller, shared by all
functions.  Therefore only create a clock device under the primary
function, and make all other functions refer to the primary's clock
device.

Since PTP functionality is limited to port 0 and PF 0 on the earlier
SFN[56]322F boards, and we also set the primary flag for that
function, we can make the creation of a clock device conditional only
on this flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c |    5 +++-
 drivers/net/ethernet/sfc/ptp.c  |   42 ++++++++++++++++++++++++--------------
 2 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a3d891764030..dfff8e7a55e2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -264,6 +264,8 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
+	efx_ptp_probe(efx, NULL);
+
 	return 0;
 
 fail3:
@@ -472,9 +474,10 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
 
+	efx_ptp_remove(efx);
+
 	efx_mcdi_mon_remove(efx);
 
-	/* This needs to be after efx_ptp_remove_channel() with no filters */
 	efx_ef10_rx_free_indir_table(efx);
 
 	if (nic_data->wc_membase)
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 843e98dfb1b2..fe3c6d04fce8 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -248,7 +248,7 @@ struct efx_ptp_timeset {
  * @start: Address at which MC indicates ready for synchronisation
  * @host_time_pps: Host time at last PPS
  * @current_adjfreq: Current ppb adjustment.
- * @phc_clock: Pointer to registered phc device
+ * @phc_clock: Pointer to registered phc device (if primary function)
  * @phc_clock_info: Registration structure for phc device
  * @pps_work: pps work task for handling pps events
  * @pps_workwq: pps work queue
@@ -1163,19 +1163,22 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 	if (rc < 0)
 		goto fail3;
 
-	ptp->phc_clock_info = efx_phc_clock_info;
-	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
-					    &efx->pci_dev->dev);
-	if (IS_ERR(ptp->phc_clock)) {
-		rc = PTR_ERR(ptp->phc_clock);
-		goto fail3;
-	}
+	if (efx->mcdi->fn_flags &
+	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY)) {
+		ptp->phc_clock_info = efx_phc_clock_info;
+		ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
+						    &efx->pci_dev->dev);
+		if (IS_ERR(ptp->phc_clock)) {
+			rc = PTR_ERR(ptp->phc_clock);
+			goto fail3;
+		}
 
-	INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
-	ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
-	if (!ptp->pps_workwq) {
-		rc = -ENOMEM;
-		goto fail4;
+		INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
+		ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
+		if (!ptp->pps_workwq) {
+			rc = -ENOMEM;
+			goto fail4;
+		}
 	}
 	ptp->nic_ts_enabled = false;
 
@@ -1224,10 +1227,12 @@ void efx_ptp_remove(struct efx_nic *efx)
 	skb_queue_purge(&efx->ptp_data->rxq);
 	skb_queue_purge(&efx->ptp_data->txq);
 
-	ptp_clock_unregister(efx->ptp_data->phc_clock);
+	if (efx->ptp_data->phc_clock) {
+		destroy_workqueue(efx->ptp_data->pps_workwq);
+		ptp_clock_unregister(efx->ptp_data->phc_clock);
+	}
 
 	destroy_workqueue(efx->ptp_data->workwq);
-	destroy_workqueue(efx->ptp_data->pps_workwq);
 
 	efx_nic_free_buffer(efx, &efx->ptp_data->start);
 	kfree(efx->ptp_data);
@@ -1440,6 +1445,9 @@ static int efx_ptp_ts_init(struct efx_nic *efx, struct hwtstamp_config *init)
 void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;
+	struct efx_nic *primary = efx->primary;
+
+	ASSERT_RTNL();
 
 	if (!ptp)
 		return;
@@ -1447,7 +1455,9 @@ void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info)
 	ts_info->so_timestamping |= (SOF_TIMESTAMPING_TX_HARDWARE |
 				     SOF_TIMESTAMPING_RX_HARDWARE |
 				     SOF_TIMESTAMPING_RAW_HARDWARE);
-	ts_info->phc_index = ptp_clock_index(ptp->phc_clock);
+	if (primary && primary->ptp_data && primary->ptp_data->phc_clock)
+		ts_info->phc_index =
+			ptp_clock_index(primary->ptp_data->phc_clock);
 	ts_info->tx_types = 1 << HWTSTAMP_TX_OFF | 1 << HWTSTAMP_TX_ON;
 	ts_info->rx_filters = ptp->efx->type->hwtstamp_filters;
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
