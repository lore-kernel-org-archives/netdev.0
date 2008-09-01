From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 24/52] sfc: Cleanup RX queue information
Date: Mon, 1 Sep 2008 12:47:48 +0100
Message-ID: <20080901114747.GR7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38151 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759271AbYIALrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:51 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename efx_nic::rss_queues to the more obvious n_rx_queues

Remove efx_rx_queue::used and other stuff that's redundant with it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   43 +++++++++++++----------------------------
 drivers/net/sfc/falcon.c     |    4 +-
 drivers/net/sfc/net_driver.h |   16 ++++----------
 drivers/net/sfc/rx.c         |   22 +++++---------------
 4 files changed, 27 insertions(+), 58 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 2deac7b..ba4369c 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -859,20 +859,20 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		 * We will need one channel per interrupt.
 		 */
 		wanted_ints = rss_cpus ? rss_cpus : efx_wanted_rx_queues();
-		efx->rss_queues = min(wanted_ints, max_channels);
+		efx->n_rx_queues = min(wanted_ints, max_channels);
 
-		for (i = 0; i < efx->rss_queues; i++)
+		for (i = 0; i < efx->n_rx_queues; i++)
 			xentries[i].entry = i;
-		rc = pci_enable_msix(efx->pci_dev, xentries, efx->rss_queues);
+		rc = pci_enable_msix(efx->pci_dev, xentries, efx->n_rx_queues);
 		if (rc > 0) {
-			EFX_BUG_ON_PARANOID(rc >= efx->rss_queues);
-			efx->rss_queues = rc;
+			EFX_BUG_ON_PARANOID(rc >= efx->n_rx_queues);
+			efx->n_rx_queues = rc;
 			rc = pci_enable_msix(efx->pci_dev, xentries,
-					     efx->rss_queues);
+					     efx->n_rx_queues);
 		}
 
 		if (rc == 0) {
-			for (i = 0; i < efx->rss_queues; i++)
+			for (i = 0; i < efx->n_rx_queues; i++)
 				efx->channel[i].irq = xentries[i].vector;
 		} else {
 			/* Fall back to single channel MSI */
@@ -883,7 +883,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 	/* Try single interrupt MSI */
 	if (efx->interrupt_mode == EFX_INT_MODE_MSI) {
-		efx->rss_queues = 1;
+		efx->n_rx_queues = 1;
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
@@ -895,7 +895,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 	/* Assume legacy interrupts */
 	if (efx->interrupt_mode == EFX_INT_MODE_LEGACY) {
-		efx->rss_queues = 1;
+		efx->n_rx_queues = 1;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
 }
@@ -914,14 +914,10 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 	efx->legacy_irq = 0;
 }
 
-/* Select number of used resources
- * Should be called after probe_interrupts()
- */
-static void efx_select_used(struct efx_nic *efx)
+static void efx_set_channels(struct efx_nic *efx)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	int i;
 
 	efx_for_each_tx_queue(tx_queue, efx) {
 		if (!EFX_INT_MODE_USE_MSI(efx) && separate_tx_and_rx_channels)
@@ -931,19 +927,9 @@ static void efx_select_used(struct efx_nic *efx)
 		tx_queue->channel->used_flags |= EFX_USED_BY_TX;
 	}
 
-	/* RX queues.  Each has a dedicated channel. */
-	for (i = 0; i < EFX_MAX_RX_QUEUES; i++) {
-		rx_queue = &efx->rx_queue[i];
-
-		if (i < efx->rss_queues) {
-			rx_queue->used = true;
-			/* If we allow multiple RX queues per channel
-			 * we need to decide that here
-			 */
-			rx_queue->channel = &efx->channel[rx_queue->queue];
-			rx_queue->channel->used_flags |= EFX_USED_BY_RX;
-			rx_queue++;
-		}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		rx_queue->channel = &efx->channel[rx_queue->queue];
+		rx_queue->channel->used_flags |= EFX_USED_BY_RX;
 	}
 }
 
@@ -962,8 +948,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 	 * in MSI-X interrupts. */
 	efx_probe_interrupts(efx);
 
-	/* Determine number of RX queues and TX queues */
-	efx_select_used(efx);
+	efx_set_channels(efx);
 
 	/* Initialise the interrupt moderation settings */
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 40dd643..03194d6 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1535,7 +1535,7 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 	     offset < RX_RSS_INDIR_TBL_B0 + 0x800;
 	     offset += 0x10) {
 		EFX_POPULATE_DWORD_1(dword, RX_RSS_INDIR_ENT_B0,
-				     i % efx->rss_queues);
+				     i % efx->n_rx_queues);
 		falcon_writel(efx, &dword, offset);
 		i++;
 	}
@@ -2785,7 +2785,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, NUM_KER, 0);
 	else
-		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->rss_queues - 1);
+		EFX_SET_OWORD_FIELD(temp, NUM_KER, efx->n_rx_queues - 1);
 	if (EFX_WORKAROUND_7244(efx)) {
 		EFX_SET_OWORD_FIELD(temp, UDP_FULL_SRCH_LIMIT, 8);
 		EFX_SET_OWORD_FIELD(temp, UDP_WILD_SRCH_LIMIT, 8);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 1fa134a..b5649b1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -231,7 +231,6 @@ struct efx_rx_buffer {
  * struct efx_rx_queue - An Efx RX queue
  * @efx: The associated Efx NIC
  * @queue: DMA queue number
- * @used: Queue is used by net driver
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
@@ -265,7 +264,6 @@ struct efx_rx_buffer {
 struct efx_rx_queue {
 	struct efx_nic *efx;
 	int queue;
-	bool used;
 	struct efx_channel *channel;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
@@ -628,7 +626,7 @@ union efx_multicast_hash {
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
- * @rss_queues: Number of RSS queues
+ * @n_rx_queues: Number of RX queues
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @irq_status: Interrupt status buffer
@@ -704,7 +702,7 @@ struct efx_nic {
 	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
 	struct efx_channel channel[EFX_MAX_CHANNELS];
 
-	int rss_queues;
+	int n_rx_queues;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
 
@@ -850,19 +848,15 @@ struct efx_nic_type {
 /* Iterate over all used RX queues */
 #define efx_for_each_rx_queue(_rx_queue, _efx)				\
 	for (_rx_queue = &_efx->rx_queue[0];				\
-	     _rx_queue < &_efx->rx_queue[EFX_MAX_RX_QUEUES];		\
-	     _rx_queue++)						\
-		if (!_rx_queue->used)					\
-			continue;					\
-		else
+	     _rx_queue < &_efx->rx_queue[_efx->n_rx_queues];		\
+	     _rx_queue++)
 
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
 	for (_rx_queue = &_channel->efx->rx_queue[0];			\
 	     _rx_queue < &_channel->efx->rx_queue[EFX_MAX_RX_QUEUES];	\
 	     _rx_queue++)						\
-		if ((!_rx_queue->used) ||				\
-		    (_rx_queue->channel != _channel))			\
+		if (_rx_queue->channel != _channel)			\
 			continue;					\
 		else
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index fa1a62a..7d2dc20 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -789,23 +789,14 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	/* Allocate RX buffers */
 	rxq_size = (efx->type->rxd_ring_mask + 1) * sizeof(*rx_queue->buffer);
 	rx_queue->buffer = kzalloc(rxq_size, GFP_KERNEL);
-	if (!rx_queue->buffer) {
-		rc = -ENOMEM;
-		goto fail1;
-	}
+	if (!rx_queue->buffer)
+		return -ENOMEM;
 
 	rc = falcon_probe_rx(rx_queue);
-	if (rc)
-		goto fail2;
-
-	return 0;
-
- fail2:
-	kfree(rx_queue->buffer);
-	rx_queue->buffer = NULL;
- fail1:
-	rx_queue->used = 0;
-
+	if (rc) {
+		kfree(rx_queue->buffer);
+		rx_queue->buffer = NULL;
+	}
 	return rc;
 }
 
@@ -872,7 +863,6 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 
 	kfree(rx_queue->buffer);
 	rx_queue->buffer = NULL;
-	rx_queue->used = 0;
 }
 
 void efx_flush_lro(struct efx_channel *channel)
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

