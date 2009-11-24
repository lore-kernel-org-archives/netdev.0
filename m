From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/17] sfc: Remove redundant efx_xmit() function
Date: Tue, 24 Nov 2009 02:07:05 +0000
Message-ID: <1259028425.14645.33.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34882 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932131AbZKXCHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:07:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h      |    5 ++---
 drivers/net/sfc/selftest.c |    2 +-
 drivers/net/sfc/tx.c       |   26 +++++---------------------
 3 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 6f46394..9d83322 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -23,9 +23,8 @@
 #define EFX_MEM_BAR 2
 
 /* TX */
-extern netdev_tx_t efx_xmit(struct efx_nic *efx,
-				  struct efx_tx_queue *tx_queue,
-				  struct sk_buff *skb);
+extern netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
+				   struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_stop_queue(struct efx_nic *efx);
 extern void efx_wake_queue(struct efx_nic *efx);
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 70eb5f1..eab8c2e 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -425,7 +425,7 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 
 		if (efx_dev_registered(efx))
 			netif_tx_lock_bh(efx->net_dev);
-		rc = efx_xmit(efx, tx_queue, skb);
+		rc = efx_enqueue_skb(tx_queue, skb);
 		if (efx_dev_registered(efx))
 			netif_tx_unlock_bh(efx->net_dev);
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index e11632b..a5e541d 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -152,11 +152,13 @@ efx_max_tx_len(struct efx_nic *efx, dma_addr_t dma_addr)
  * If any DMA mapping fails, any mapped fragments will be unmapped,
  * the queue's insert pointer will be restored to its original value.
  *
+ * This function is split out from efx_hard_start_xmit to allow the
+ * loopback test to direct packets via specific TX queues.
+ *
  * Returns NETDEV_TX_OK or NETDEV_TX_BUSY
  * You must hold netif_tx_lock() to call this function.
  */
-static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
-					 struct sk_buff *skb)
+netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	struct pci_dev *pci_dev = efx->pci_dev;
@@ -352,24 +354,6 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 	}
 }
 
-/* Initiate a packet transmission on the specified TX queue.
- * Note that returning anything other than NETDEV_TX_OK will cause the
- * OS to free the skb.
- *
- * This function is split out from efx_hard_start_xmit to allow the
- * loopback test to direct packets via specific TX queues.  It is
- * therefore a non-static inline, so as not to penalise performance
- * for non-loopback transmissions.
- *
- * Context: netif_tx_lock held
- */
-inline netdev_tx_t efx_xmit(struct efx_nic *efx,
-			   struct efx_tx_queue *tx_queue, struct sk_buff *skb)
-{
-	/* Map fragments for DMA and add to TX queue */
-	return efx_enqueue_skb(tx_queue, skb);
-}
-
 /* Initiate a packet transmission.  We use one channel per CPU
  * (sharing when we have more CPUs than channels).  On Falcon, the TX
  * completion events will be directed back to the CPU that transmitted
@@ -393,7 +377,7 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 	else
 		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_NO_CSUM];
 
-	return efx_xmit(efx, tx_queue, skb);
+	return efx_enqueue_skb(tx_queue, skb);
 }
 
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

