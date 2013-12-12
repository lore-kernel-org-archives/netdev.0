From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/16] sfc: Split PTP multicast filter
 insertion/removal out of efx_ptp_{start,stop}()
Date: Thu, 12 Dec 2013 23:03:23 +0000
Message-ID: <1386889403.1516.352.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29564 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab3LLXD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:03:27 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 56 +++++++++++++++++++++++++++++-------------
 1 file changed, 39 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 24bd2e3040f8..7ae66d900256 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -755,13 +755,27 @@ static inline void efx_ptp_process_rx(struct efx_nic *efx, struct sk_buff *skb)
 	local_bh_enable();
 }
 
-static int efx_ptp_start(struct efx_nic *efx)
+static void efx_ptp_remove_multicast_filters(struct efx_nic *efx)
+{
+	struct efx_ptp_data *ptp = efx->ptp_data;
+
+	if (ptp->rxfilter_installed) {
+		efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
+					  ptp->rxfilter_general);
+		efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
+					  ptp->rxfilter_event);
+		ptp->rxfilter_installed = false;
+	}
+}
+
+static int efx_ptp_insert_multicast_filters(struct efx_nic *efx)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;
 	struct efx_filter_spec rxfilter;
 	int rc;
 
-	ptp->reset_required = false;
+	if (ptp->rxfilter_installed)
+		return 0;
 
 	/* Must filter on both event and general ports to ensure
 	 * that there is no packet re-ordering.
@@ -794,23 +808,37 @@ static int efx_ptp_start(struct efx_nic *efx)
 		goto fail;
 	ptp->rxfilter_general = rc;
 
+	ptp->rxfilter_installed = true;
+	return 0;
+
+fail:
+	efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
+				  ptp->rxfilter_event);
+	return rc;
+}
+
+static int efx_ptp_start(struct efx_nic *efx)
+{
+	struct efx_ptp_data *ptp = efx->ptp_data;
+	int rc;
+
+	ptp->reset_required = false;
+
+	rc = efx_ptp_insert_multicast_filters(efx);
+	if (rc)
+		return rc;
+
 	rc = efx_ptp_enable(efx);
 	if (rc != 0)
-		goto fail2;
+		goto fail;
 
 	ptp->evt_frag_idx = 0;
 	ptp->current_adjfreq = 0;
-	ptp->rxfilter_installed = true;
 
 	return 0;
 
-fail2:
-	efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
-				  ptp->rxfilter_general);
 fail:
-	efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
-				  ptp->rxfilter_event);
-
+	efx_ptp_remove_multicast_filters(efx);
 	return rc;
 }
 
@@ -826,13 +854,7 @@ static int efx_ptp_stop(struct efx_nic *efx)
 
 	rc = efx_ptp_disable(efx);
 
-	if (ptp->rxfilter_installed) {
-		efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
-					  ptp->rxfilter_general);
-		efx_filter_remove_id_safe(efx, EFX_FILTER_PRI_REQUIRED,
-					  ptp->rxfilter_event);
-		ptp->rxfilter_installed = false;
-	}
+	efx_ptp_remove_multicast_filters(efx);
 
 	/* Make sure RX packets are really delivered */
 	efx_ptp_deliver_rx_queue(&efx->ptp_data->rxq);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
