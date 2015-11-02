From: Martin Habets <mhabets@solarflare.com>
Subject: [PATCH net] sfc: push partner queue for skb->xmit_more
Date: Mon, 2 Nov 2015 12:51:31 +0000
Message-ID: <56375C53.6010006@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:54093 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754003AbbKBM6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 07:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the IP stack passes SKBs the sfc driver puts them in 2 different TX
queues (called partners), one for checksummed and one for not checksummed.
If the SKB has xmit_more set the driver will delay pushing the work to the
NIC.

When later it does decide to push the buffers this patch ensures it also
pushes the partner queue, if that also has any delayed work. Before this
fix the work in the partner queue would be left for a long time and cause
a netdev watchdog.

Fixes: 70b33fb ("sfc: add support for skb->xmit_more")

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Martin Habets <mhabets@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  4 +++-
 drivers/net/ethernet/sfc/farch.c      |  4 +++-
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/tx.c         | 30 ++++++++++++++++++++++++++++--
 4 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ff649ebef637..286cc6b69d57 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1849,7 +1849,9 @@ static void efx_ef10_tx_write(struct efx_tx_queue *tx_queue)
 	unsigned int write_ptr;
 	efx_qword_t *txd;
 
-	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
+	tx_queue->xmit_more_available = false;
+	if (unlikely(tx_queue->write_count == tx_queue->insert_count))
+		return;
 
 	do {
 		write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index f08266f0eca2..5a1c5a8f278a 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -321,7 +321,9 @@ void efx_farch_tx_write(struct efx_tx_queue *tx_queue)
 	unsigned write_ptr;
 	unsigned old_write_count = tx_queue->write_count;
 
-	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
+	tx_queue->xmit_more_available = false;
+	if (unlikely(tx_queue->write_count == tx_queue->insert_count))
+		return;
 
 	do {
 		write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c530e1c4cb4f..24038ef96d9f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -219,6 +219,7 @@ struct efx_tx_buffer {
  * @tso_packets: Number of packets via the TSO xmit path
  * @pushes: Number of times the TX push feature has been used
  * @pio_packets: Number of times the TX PIO feature has been used
+ * @xmit_more_available: Are any packets waiting to be pushed to the NIC
  * @empty_read_count: If the completion path has seen the queue as empty
  *	and the transmission path has not yet checked this, the value of
  *	@read_count bitwise-added to %EFX_EMPTY_COUNT_VALID; otherwise 0.
@@ -253,6 +254,7 @@ struct efx_tx_queue {
 	unsigned int tso_packets;
 	unsigned int pushes;
 	unsigned int pio_packets;
+	bool xmit_more_available;
 	/* Statistics to supplement MAC stats */
 	unsigned long tx_packets;
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 1833a0146571..67f6afaa022f 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -431,8 +431,20 @@ finish_packet:
 	efx_tx_maybe_stop_queue(tx_queue);
 
 	/* Pass off to hardware */
-	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq)) {
+		struct efx_tx_queue *txq2 = efx_tx_queue_partner(tx_queue);
+
+		/* There could be packets left on the partner queue if those
+		 * SKBs had skb->xmit_more set. If we do not push those they
+		 * could be left for a long time and cause a netdev watchdog.
+		 */
+		if (txq2->xmit_more_available)
+			efx_nic_push_buffers(txq2);
+
 		efx_nic_push_buffers(tx_queue);
+	} else {
+		tx_queue->xmit_more_available = skb->xmit_more;
+	}
 
 	tx_queue->tx_packets++;
 
@@ -722,6 +734,7 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	tx_queue->read_count = 0;
 	tx_queue->old_read_count = 0;
 	tx_queue->empty_read_count = 0 | EFX_EMPTY_COUNT_VALID;
+	tx_queue->xmit_more_available = false;
 
 	/* Set up TX descriptor ring */
 	efx_nic_init_tx(tx_queue);
@@ -747,6 +760,7 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 		++tx_queue->read_count;
 	}
+	tx_queue->xmit_more_available = false;
 	netdev_tx_reset_queue(tx_queue->core_txq);
 }
 
@@ -1302,8 +1316,20 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	efx_tx_maybe_stop_queue(tx_queue);
 
 	/* Pass off to hardware */
-	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
+	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq)) {
+		struct efx_tx_queue *txq2 = efx_tx_queue_partner(tx_queue);
+
+		/* There could be packets left on the partner queue if those
+		 * SKBs had skb->xmit_more set. If we do not push those they
+		 * could be left for a long time and cause a netdev watchdog.
+		 */
+		if (txq2->xmit_more_available)
+			efx_nic_push_buffers(txq2);
+
 		efx_nic_push_buffers(tx_queue);
+	} else {
+		tx_queue->xmit_more_available = skb->xmit_more;
+	}
 
 	tx_queue->tso_bursts++;
 	return NETDEV_TX_OK;
