From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/22] sfc: tidy up PTP synchronize function
 efx_ptp_process_times()
Date: Mon, 11 Mar 2013 19:53:54 +0000
Message-ID: <1363031634.2608.40.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>,
	Laurence Evans <levans@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16707 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab3CKTx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:53:57 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From:  Laurence Evans <levans@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 2b40cbd..d1858c0 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -432,13 +432,10 @@ static int efx_ptp_process_times(struct efx_nic *efx, u8 *synch_buf,
 	unsigned number_readings = (response_length /
 			       MC_CMD_PTP_OUT_SYNCHRONIZE_TIMESET_LEN);
 	unsigned i;
-	unsigned min;
-	unsigned min_set = 0;
 	unsigned total;
 	unsigned ngood = 0;
 	unsigned last_good = 0;
 	struct efx_ptp_data *ptp = efx->ptp_data;
-	bool min_valid = false;
 	u32 last_sec;
 	u32 start_sec;
 	struct timespec delta;
@@ -446,35 +443,17 @@ static int efx_ptp_process_times(struct efx_nic *efx, u8 *synch_buf,
 	if (number_readings == 0)
 		return -EAGAIN;
 
-	/* Find minimum value in this set of results, discarding clearly
-	 * erroneous results.
+	/* Read the set of results and increment stats for any results that
+	 * appera to be erroneous.
 	 */
 	for (i = 0; i < number_readings; i++) {
 		efx_ptp_read_timeset(synch_buf, &ptp->timeset[i]);
 		synch_buf += MC_CMD_PTP_OUT_SYNCHRONIZE_TIMESET_LEN;
-		if (ptp->timeset[i].window > SYNCHRONISATION_GRANULARITY_NS) {
-			if (min_valid) {
-				if (ptp->timeset[i].window < min_set)
-					min_set = ptp->timeset[i].window;
-			} else {
-				min_valid = true;
-				min_set = ptp->timeset[i].window;
-			}
-		}
-	}
-
-	if (min_valid) {
-		if (ptp->base_sync_valid && (min_set > ptp->base_sync_ns))
-			min = ptp->base_sync_ns;
-		else
-			min = min_set;
-	} else {
-		min = SYNCHRONISATION_GRANULARITY_NS;
 	}
 
-	/* Discard excessively long synchronise durations.  The MC times
-	 * when it finishes reading the host time so the corrected window
-	 * time should be fairly constant for a given platform.
+	/* Find the last good host-MC synchronization result. The MC times
+	 * when it finishes reading the host time so the corrected window time
+	 * should be fairly constant for a given platform.
 	 */
 	total = 0;
 	for (i = 0; i < number_readings; i++)
@@ -492,8 +471,8 @@ static int efx_ptp_process_times(struct efx_nic *efx, u8 *synch_buf,
 
 	if (ngood == 0) {
 		netif_warn(efx, drv, efx->net_dev,
-			   "PTP no suitable synchronisations %dns %dns\n",
-			   ptp->base_sync_ns, min_set);
+			   "PTP no suitable synchronisations %dns\n",
+			   ptp->base_sync_ns);
 		return -EAGAIN;
 	}
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
