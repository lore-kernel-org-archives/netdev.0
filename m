From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/11] sfc: Add more information to many warnings
 using WARN() and netdev_WARN()
Date: Mon, 16 Dec 2013 21:31:03 +0000
Message-ID: <1387229463.1799.44.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8566 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab3LPVbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:31:07 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of certain hardware and firmware errors it can be useful to
have more context than just the file and line number.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index dfff8e7a55e2..9ec6072896c2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1252,7 +1252,8 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	return;
 
 fail:
-	WARN_ON(true);
+	netdev_WARN(efx->net_dev, "failed to initialise TXQ %d\n",
+		    tx_queue->queue);
 }
 
 static void efx_ef10_tx_fini(struct efx_tx_queue *tx_queue)
@@ -1492,9 +1493,9 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_RXQ, inbuf, inlen,
 			  outbuf, sizeof(outbuf), &outlen);
-	WARN_ON(rc);
-
-	return;
+	if (rc)
+		netdev_WARN(efx->net_dev, "failed to initialise RXQ %d\n",
+			    efx_rx_queue_index(rx_queue));
 }
 
 static void efx_ef10_rx_fini(struct efx_rx_queue *rx_queue)
@@ -1718,8 +1719,6 @@ static void efx_ef10_handle_rx_abort(struct efx_rx_queue *rx_queue)
 {
 	unsigned int rx_desc_ptr;
 
-	WARN_ON(rx_queue->scatter_n == 0);
-
 	netif_dbg(rx_queue->efx, hw, rx_queue->efx->net_dev,
 		  "scattered RX aborted (dropping %u buffers)\n",
 		  rx_queue->scatter_n);
@@ -1755,7 +1754,10 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 	rx_l4_class = EFX_QWORD_FIELD(*event, ESF_DZ_RX_L4_CLASS);
 	rx_cont = EFX_QWORD_FIELD(*event, ESF_DZ_RX_CONT);
 
-	WARN_ON(EFX_QWORD_FIELD(*event, ESF_DZ_RX_DROP_EVENT));
+	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_DROP_EVENT))
+		netdev_WARN(efx->net_dev, "saw RX_DROP_EVENT: event="
+			    EFX_QWORD_FMT "\n",
+			    EFX_QWORD_VAL(*event));
 
 	rx_queue = efx_channel_get_rx_queue(channel);
 
@@ -1770,7 +1772,12 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 
 		/* detect rx abort */
 		if (unlikely(n_descs == rx_queue->scatter_n)) {
-			WARN_ON(rx_bytes != 0);
+			if (rx_queue->scatter_n == 0 || rx_bytes != 0)
+				netdev_WARN(efx->net_dev,
+					    "invalid RX abort: scatter_n=%u event="
+					    EFX_QWORD_FMT "\n",
+					    rx_queue->scatter_n,
+					    EFX_QWORD_VAL(*event));
 			efx_ef10_handle_rx_abort(rx_queue);
 			return 0;
 		}
@@ -3035,8 +3042,11 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 			       table->entry[filter_idx].handle);
 		rc = efx_mcdi_rpc(efx, MC_CMD_FILTER_OP, inbuf, sizeof(inbuf),
 				  NULL, 0, NULL);
-
-		WARN_ON(rc != 0);
+		if (rc)
+			netdev_WARN(efx->net_dev,
+				    "filter_idx=%#x handle=%#llx\n",
+				    filter_idx,
+				    table->entry[filter_idx].handle);
 		kfree(spec);
 	}
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
