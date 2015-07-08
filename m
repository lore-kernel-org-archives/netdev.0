From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/1] sfc: Report TX completions to BQL after all TX events
 in interrupt
Date: Wed, 8 Jul 2015 10:05:10 +0100
Message-ID: <559CE7C6.7040701@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:7841 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934163AbbGHJFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 05:05:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Dunning <pdunning@solarflare.com>

The limit for BQL is updated each time we call
netdev_tx_completed_queue.
Without this patch the BQL limit was updated for every TX event we
see.
The issue was that this only updated the limit to handle the data
we complete in two events as the first event wouldn't show that
enough traffic had been processed between them.

This was OK when interrupt moderation was off but not when it was
on as more data had to be completed in a single interrupt.

The patch changes this so that we do report the completion to BQL
only when all the TX events in the interrupt have been processed.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 14 ++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/tx.c         |  3 ++-
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 804b9ad..abbeff2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -245,11 +245,17 @@ static int efx_check_disabled(struct efx_nic *efx)
  */
 static int efx_process_channel(struct efx_channel *channel, int budget)
 {
+	struct efx_tx_queue *tx_queue; 
 	int spent;
 
 	if (unlikely(!channel->enabled))
 		return 0;
 
+	efx_for_each_channel_tx_queue(tx_queue, channel) {
+		tx_queue->pkts_compl = 0;
+		tx_queue->bytes_compl = 0;
+	}
+
 	spent = efx_nic_process_eventq(channel, budget);
 	if (spent && efx_channel_has_rx_queue(channel)) {
 		struct efx_rx_queue *rx_queue =
@@ -259,6 +265,14 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 		efx_fast_push_rx_descriptors(rx_queue, true);
 	}
 
+	/* Update BQL */
+	efx_for_each_channel_tx_queue(tx_queue, channel) {
+		if (tx_queue->bytes_compl) {
+			netdev_tx_completed_queue(tx_queue->core_txq,
+				tx_queue->pkts_compl, tx_queue->bytes_compl);
+		}
+	}
+
 	return spent;
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index d72f522..47d1e3a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -241,6 +241,8 @@ struct efx_tx_queue {
 	unsigned int read_count ____cacheline_aligned_in_smp;
 	unsigned int old_write_count;
 	unsigned int merge_events;
+	unsigned int bytes_compl;
+	unsigned int pkts_compl;
 
 	/* Members used only on the xmit path */
 	unsigned int insert_count ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index aaf2987..1833a01 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -617,7 +617,8 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
 
 	efx_dequeue_buffers(tx_queue, index, &pkts_compl, &bytes_compl);
-	netdev_tx_completed_queue(tx_queue->core_txq, pkts_compl, bytes_compl);
+	tx_queue->pkts_compl += pkts_compl;
+	tx_queue->bytes_compl += bytes_compl;
 
 	if (pkts_compl > 1)
 		++tx_queue->merge_events;
