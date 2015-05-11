From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: suppress some MCDI error messages in PTP
Date: Mon, 11 May 2015 13:20:56 +0100
Message-ID: <55509EA8.8080207@solarflare.com>
References: <55509E37.8050706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:45440 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753640AbbEKMYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 08:24:48 -0400
In-Reply-To: <55509E37.8050706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, remove a needless netif_err() from efx_ptp_update_stats() - if the
 MCDI fails it'll print its own error message, we don't need another that
 adds no information.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 8c5c96a..5578c54 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -389,11 +389,8 @@ size_t efx_ptp_update_stats(struct efx_nic *efx,
u64 *stats)
 	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
 			  outbuf, sizeof(outbuf), NULL);
-	if (rc) {
-		netif_err(efx, hw, efx->net_dev,
-			  "MC_CMD_PTP_OP_STATUS failed (%d)\n", rc);
+	if (rc)
 		memset(outbuf, 0, sizeof(outbuf));
-	}
 	efx_nic_update_stats(efx_ptp_stat_desc, PTP_STAT_COUNT,
 			     efx_ptp_stat_mask,
 			     stats, _MCDI_PTR(outbuf, 0), false);
@@ -490,14 +487,20 @@ static int efx_ptp_get_attributes(struct efx_nic *efx)
 	 */
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_GET_ATTRIBUTES);
 	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
-	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
-			  outbuf, sizeof(outbuf), &out_len);
-	if (rc == 0)
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
+				outbuf, sizeof(outbuf), &out_len);
+	if (rc == 0) {
 		fmt = MCDI_DWORD(outbuf, PTP_OUT_GET_ATTRIBUTES_TIME_FORMAT);
-	else if (rc == -EINVAL)
+	} else if (rc == -EINVAL) {
 		fmt = MC_CMD_PTP_OUT_GET_ATTRIBUTES_SECONDS_NANOSECONDS;
-	else
+	} else if (rc == -EPERM) {
+		netif_info(efx, probe, efx->net_dev, "no PTP support\n");
 		return rc;
+	} else {
+		efx_mcdi_display_error(efx, MC_CMD_PTP, sizeof(inbuf),
+				       outbuf, sizeof(outbuf), rc);
+		return rc;
+	}
  	if (fmt == MC_CMD_PTP_OUT_GET_ATTRIBUTES_SECONDS_27FRACTION) {
 		ptp->ns_to_nic_time = efx_ptp_ns_to_s27;
@@ -541,8 +544,8 @@ static int efx_ptp_get_timestamp_corrections(struct
efx_nic *efx)
 		       MC_CMD_PTP_OP_GET_TIMESTAMP_CORRECTIONS);
 	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 -	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
-			  outbuf, sizeof(outbuf), NULL);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
+				outbuf, sizeof(outbuf), NULL);
 	if (rc == 0) {
 		efx->ptp_data->ts_corrections.tx = MCDI_DWORD(outbuf,
 			PTP_OUT_GET_TIMESTAMP_CORRECTIONS_TRANSMIT);
@@ -558,6 +561,8 @@ static int efx_ptp_get_timestamp_corrections(struct
efx_nic *efx)
 		efx->ptp_data->ts_corrections.pps_out = 0;
 		efx->ptp_data->ts_corrections.pps_in = 0;
 	} else {
+		efx_mcdi_display_error(efx, MC_CMD_PTP, sizeof(inbuf), outbuf,
+				       sizeof(outbuf), rc);
 		return rc;
 	}
