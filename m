From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 4/5] sfc: handle failure to allocate TSOv2 contexts
Date: Thu, 17 Nov 2016 10:52:07 +0000
Message-ID: <bd65dcab-5f79-5fb1-35ec-c4e2ae844f84@solarflare.com>
References: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:62673 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1945967AbcKQKwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:52:14 -0500
In-Reply-To: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to init the TXQ because of insufficient TSOv2 contexts,
try again with TSOv2 disabled.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4b69ed9..9cbe573 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2178,9 +2178,6 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	/* TSOv2 is a limited resource that can only be configured on a limited
 	 * number of queues. TSO without checksum offload is not really a thing,
 	 * so we only enable it for those queues.
-	 *
-	 * TODO: handle failure to allocate this in the case where we've used
-	 * all the queues.
 	 */
 	if (csum_offload && (nic_data->datapath_caps2 &
 			(1 << MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_LBN))) {
@@ -2193,15 +2190,6 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_TARGET_EVQ, channel->channel);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_LABEL, tx_queue->queue);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_INSTANCE, tx_queue->queue);
-	MCDI_POPULATE_DWORD_3(inbuf, INIT_TXQ_IN_FLAGS,
-			      /* This flag was removed from mcdi_pcol.h for
-			       * the non-_EXT version of INIT_TXQ.  However,
-			       * firmware still honours it.
-			       */
-			      INIT_TXQ_EXT_IN_FLAG_TSOV2_EN, tso_v2,
-			      INIT_TXQ_IN_FLAG_IP_CSUM_DIS, !csum_offload,
-			      INIT_TXQ_IN_FLAG_TCP_CSUM_DIS, !csum_offload);
-
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_OWNER_ID, 0);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_PORT_ID, nic_data->vport_id);
 
@@ -2217,10 +2205,30 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 
 	inlen = MC_CMD_INIT_TXQ_IN_LEN(entries);
 
-	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_TXQ, inbuf, inlen,
-			  NULL, 0, NULL);
-	if (rc)
-		goto fail;
+	do {
+		MCDI_POPULATE_DWORD_3(inbuf, INIT_TXQ_IN_FLAGS,
+				/* This flag was removed from mcdi_pcol.h for
+				 * the non-_EXT version of INIT_TXQ.  However,
+				 * firmware still honours it.
+				 */
+				INIT_TXQ_EXT_IN_FLAG_TSOV2_EN, tso_v2,
+				INIT_TXQ_IN_FLAG_IP_CSUM_DIS, !csum_offload,
+				INIT_TXQ_IN_FLAG_TCP_CSUM_DIS, !csum_offload);
+
+		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_INIT_TXQ, inbuf, inlen,
+					NULL, 0, NULL);
+		if (rc == -ENOSPC && tso_v2) {
+			/* Retry without TSOv2 if we're short on contexts. */
+			tso_v2 = false;
+			netif_warn(efx, probe, efx->net_dev,
+				   "TSOv2 context not available to segment in hardware. TCP performance may be reduced.\n");
+		} else if (rc) {
+			efx_mcdi_display_error(efx, MC_CMD_INIT_TXQ,
+					       MC_CMD_INIT_TXQ_EXT_IN_LEN,
+					       NULL, 0, rc);
+			goto fail;
+		}
+	} while (rc);
 
 	/* A previous user of this TX queue might have set us up the
 	 * bomb by writing a descriptor to the TX push collector but
