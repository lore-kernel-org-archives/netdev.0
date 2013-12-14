From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/15] sfc: Tidy up PTP synchronization code
Date: Sat, 14 Dec 2013 23:02:39 +0000
Message-ID: <1387062159.12172.64.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17323 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:02:43 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   44 +++++++++++++++++++++------------------
 1 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 82d8e27e8a58..361d7cedd897 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -435,7 +435,6 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 		MCDI_VAR_ARRAY_LEN(response_length,
 				   PTP_OUT_SYNCHRONIZE_TIMESET);
 	unsigned i;
-	unsigned total;
 	unsigned ngood = 0;
 	unsigned last_good = 0;
 	struct efx_ptp_data *ptp = efx->ptp_data;
@@ -446,33 +445,38 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 	if (number_readings == 0)
 		return -EAGAIN;
 
-	/* Read the set of results and increment stats for any results that
-	 * appera to be erroneous.
+	/* Read the set of results and find the last good host-MC
+	 * synchronization result. The MC times when it finishes reading the
+	 * host time so the corrected window time should be fairly constant
+	 * for a given platform.
 	 */
 	for (i = 0; i < number_readings; i++) {
+		s32 window, corrected;
+
 		efx_ptp_read_timeset(
 			MCDI_ARRAY_STRUCT_PTR(synch_buf,
 					      PTP_OUT_SYNCHRONIZE_TIMESET, i),
 			&ptp->timeset[i]);
-	}
 
-	/* Find the last good host-MC synchronization result. The MC times
-	 * when it finishes reading the host time so the corrected window time
-	 * should be fairly constant for a given platform.
-	 */
-	total = 0;
-	for (i = 0; i < number_readings; i++)
-		if (ptp->timeset[i].window > ptp->timeset[i].waitns) {
-			unsigned win;
-
-			win = ptp->timeset[i].window - ptp->timeset[i].waitns;
-			if (win >= MIN_SYNCHRONISATION_NS &&
-			    win < MAX_SYNCHRONISATION_NS) {
-				total += ptp->timeset[i].window;
-				ngood++;
-				last_good = i;
-			}
+		window = ptp->timeset[i].window;
+		corrected = window - ptp->timeset[i].waitns;
+
+		/* We expect the uncorrected synchronization window to be at
+		 * least as large as the interval between host start and end
+		 * times. If it is smaller than this then this is mostly likely
+		 * to be a consequence of the host's time being adjusted.
+		 * Check that the corrected sync window is in a reasonable
+		 * range. If it is out of range it is likely to be because an
+		 * interrupt or other delay occurred between reading the system
+		 * time and writing it to MC memory.
+		 */
+		if (window >= SYNCHRONISATION_GRANULARITY_NS &&
+		    corrected < MAX_SYNCHRONISATION_NS &&
+		    corrected >= MIN_SYNCHRONISATION_NS) {
+			ngood++;
+			last_good = i;
 		}
+	}
 
 	if (ngood == 0) {
 		netif_warn(efx, drv, efx->net_dev,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
