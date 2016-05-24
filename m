From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: on MC reset, clear PIO buffer linkage in TXQs
Date: Tue, 24 May 2016 18:53:36 +0100
Message-ID: <57449520.5070205@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:52672 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932813AbcEXRx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 13:53:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, if we fail to allocate new PIO buffers, our TXQs will try to
use the old ones, which aren't there any more.

Fixes: 183233bec810 "sfc: Allocate and link PIO buffers; map them with write-combining"
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1681084..1f30912 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -619,6 +619,17 @@ fail:
 	return rc;
 }
 
+static void efx_ef10_forget_old_piobufs(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+
+	/* All our existing PIO buffers went away */
+	efx_for_each_channel(channel, efx)
+		efx_for_each_channel_tx_queue(tx_queue, channel)
+			tx_queue->piobuf = NULL;
+}
+
 #else /* !EFX_USE_PIO */
 
 static int efx_ef10_alloc_piobufs(struct efx_nic *efx, unsigned int n)
@@ -635,6 +646,10 @@ static void efx_ef10_free_piobufs(struct efx_nic *efx)
 {
 }
 
+static void efx_ef10_forget_old_piobufs(struct efx_nic *efx)
+{
+}
+
 #endif /* EFX_USE_PIO */
 
 static void efx_ef10_remove(struct efx_nic *efx)
@@ -1018,6 +1033,7 @@ static void efx_ef10_reset_mc_allocations(struct efx_nic *efx)
 	nic_data->must_realloc_vis = true;
 	nic_data->must_restore_filters = true;
 	nic_data->must_restore_piobufs = true;
+	efx_ef10_forget_old_piobufs(efx);
 	nic_data->rx_rss_context = EFX_EF10_RSS_CONTEXT_INVALID;
 
 	/* Driver-created vswitches and vports must be re-created */
