From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/33] sfc: Add option to use a separate channel for TX completions
Date: Fri, 12 Dec 2008 12:52:16 +0000
Message-ID: <20081212125216.GJ10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35377 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757104AbYLLMwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:52:19 -0500
Content-Disposition: inline
In-Reply-To: <cover.1229085672.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Turton <nturton@solarflare.com>

In a bidirectional forwarding test, we find that the best performance
is achieved by sending the TX completion interrupts from one NIC to a
CPU which shares an L2 cache with RX completion interrupts from the
other NIC.  To facilitate this, add an option (through a module
parameter) to create separate channels for RX and TX completion with
separate IRQs when MSI-X is available.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   41 ++++++++++++++++++++++++++---------------
 drivers/net/sfc/net_driver.h |    2 ++
 2 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 15ae2fc..58cbbd5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -64,13 +64,15 @@ MODULE_PARM_DESC(lro, "Large receive offload acceleration");
 /*
  * Use separate channels for TX and RX events
  *
- * Set this to 1 to use separate channels for TX and RX. It allows us to
- * apply a higher level of interrupt moderation to TX events.
+ * Set this to 1 to use separate channels for TX and RX. It allows us
+ * to control interrupt affinity separately for TX and RX.
  *
- * This is forced to 0 for MSI interrupt mode as the interrupt vector
- * is not written
+ * This is only used in MSI-X interrupt mode
  */
-static unsigned int separate_tx_and_rx_channels = true;
+static unsigned int separate_tx_channels;
+module_param(separate_tx_channels, uint, 0644);
+MODULE_PARM_DESC(separate_tx_channels,
+		 "Use separate channels for TX and RX");
 
 /* This is the weight assigned to each of the (per-channel) virtual
  * NAPI devices.
@@ -846,26 +848,33 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
 		struct msix_entry xentries[EFX_MAX_CHANNELS];
 		int wanted_ints;
+		int rx_queues;
 
 		/* We want one RX queue and interrupt per CPU package
 		 * (or as specified by the rss_cpus module parameter).
 		 * We will need one channel per interrupt.
 		 */
-		wanted_ints = rss_cpus ? rss_cpus : efx_wanted_rx_queues();
-		efx->n_rx_queues = min(wanted_ints, max_channels);
+		rx_queues = rss_cpus ? rss_cpus : efx_wanted_rx_queues();
+		wanted_ints = rx_queues + (separate_tx_channels ? 1 : 0);
+		wanted_ints = min(wanted_ints, max_channels);
 
-		for (i = 0; i < efx->n_rx_queues; i++)
+		for (i = 0; i < wanted_ints; i++)
 			xentries[i].entry = i;
-		rc = pci_enable_msix(efx->pci_dev, xentries, efx->n_rx_queues);
+		rc = pci_enable_msix(efx->pci_dev, xentries, wanted_ints);
 		if (rc > 0) {
-			EFX_BUG_ON_PARANOID(rc >= efx->n_rx_queues);
-			efx->n_rx_queues = rc;
+			EFX_ERR(efx, "WARNING: Insufficient MSI-X vectors"
+				" available (%d < %d).\n", wanted_ints, rc);
+			EFX_ERR(efx, "WARNING: Performance may be reduced.\n");
+			EFX_BUG_ON_PARANOID(rc >= wanted_ints);
+			wanted_ints = rc;
 			rc = pci_enable_msix(efx->pci_dev, xentries,
-					     efx->n_rx_queues);
+					     wanted_ints);
 		}
 
 		if (rc == 0) {
-			for (i = 0; i < efx->n_rx_queues; i++)
+			efx->n_rx_queues = min(rx_queues, wanted_ints);
+			efx->n_channels = wanted_ints;
+			for (i = 0; i < wanted_ints; i++)
 				efx->channel[i].irq = xentries[i].vector;
 		} else {
 			/* Fall back to single channel MSI */
@@ -877,6 +886,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 	/* Try single interrupt MSI */
 	if (efx->interrupt_mode == EFX_INT_MODE_MSI) {
 		efx->n_rx_queues = 1;
+		efx->n_channels = 1;
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
@@ -889,6 +899,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 	/* Assume legacy interrupts */
 	if (efx->interrupt_mode == EFX_INT_MODE_LEGACY) {
 		efx->n_rx_queues = 1;
+		efx->n_channels = 1 + (separate_tx_channels ? 1 : 0);
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
 }
@@ -913,8 +924,8 @@ static void efx_set_channels(struct efx_nic *efx)
 	struct efx_rx_queue *rx_queue;
 
 	efx_for_each_tx_queue(tx_queue, efx) {
-		if (!EFX_INT_MODE_USE_MSI(efx) && separate_tx_and_rx_channels)
-			tx_queue->channel = &efx->channel[1];
+		if (separate_tx_channels)
+			tx_queue->channel = &efx->channel[efx->n_channels-1];
 		else
 			tx_queue->channel = &efx->channel[0];
 		tx_queue->channel->used_flags |= EFX_USED_BY_TX;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index f910609..2c5b5fa 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -649,6 +649,7 @@ union efx_multicast_hash {
  * @rx_queue: RX DMA queues
  * @channel: Channels
  * @n_rx_queues: Number of RX queues
+ * @n_channels: Number of channels in use
  * @rx_buffer_len: RX buffer length
  * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
  * @irq_status: Interrupt status buffer
@@ -728,6 +729,7 @@ struct efx_nic {
 	struct efx_channel channel[EFX_MAX_CHANNELS];
 
 	int n_rx_queues;
+	int n_channels;
 	unsigned int rx_buffer_len;
 	unsigned int rx_buffer_order;
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
