From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/1] sfc: Allow driver to cope with a lower number
 of VIs than it needs for RSS
Date: Fri, 21 Aug 2015 10:43:51 +0100
Message-ID: <55D6F2D7.4070707@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29906 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbbHUJn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 05:43:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, the driver would refuse to load if it couldn't secure
enough VIs from the MC to fulfill its RSS requirements.
This was causing probe to fail on later functions in configuration
where we'd run out of VIs, such as having many VFs.

This change allows the driver to load with fewer VIs, down to a
minimum of 2. A warning will be printed saying that RSS
requirements were not met, possibly affecting performance.

efx->max_tx_channels needs to be set to avoid going down the
failure path in efx_probe_nic() immediately in the loop after the
probe() NIC-type function.
Also, Set rc=ENOSPC when bombing out of efx_probe_nic due to lack
of VIs.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 38 ++++++++++++++++++++++--------
 drivers/net/ethernet/sfc/efx.c        | 44 +++++++++++++++++++++++++----------
 drivers/net/ethernet/sfc/efx.h        |  1 +
 drivers/net/ethernet/sfc/falcon.c     |  1 +
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/siena.c      |  1 +
 6 files changed, 64 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 06b8061..99e3510 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -295,11 +295,11 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	/* We can have one VI for each 8K region.  However, until we
 	 * use TX option descriptors we need two TX queues per channel.
 	 */
-	efx->max_channels =
-		min_t(unsigned int,
-		      EFX_MAX_CHANNELS,
-		      efx_ef10_mem_map_size(efx) /
-		      (EFX_VI_PAGE_SIZE * EFX_TXQ_TYPES));
+	efx->max_channels = min_t(unsigned int,
+				  EFX_MAX_CHANNELS,
+				  efx_ef10_mem_map_size(efx) /
+				  (EFX_VI_PAGE_SIZE * EFX_TXQ_TYPES));
+	efx->max_tx_channels = efx->max_channels;
 	if (WARN_ON(efx->max_channels == 0))
 		return -EIO;
 
@@ -824,11 +824,12 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	unsigned int uc_mem_map_size, wc_mem_map_size;
-	unsigned int min_vis, pio_write_vi_base, max_vis;
+	unsigned int min_vis = max(EFX_TXQ_TYPES, separate_tx_channels ? 2 : 1);
+	unsigned int channel_vis, pio_write_vi_base, max_vis;
 	void __iomem *membase;
 	int rc;
 
-	min_vis = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
+	channel_vis = max(efx->n_channels, efx->n_tx_channels * EFX_TXQ_TYPES);
 
 #ifdef EFX_USE_PIO
 	/* Try to allocate PIO buffers if wanted and if the full
@@ -862,11 +863,11 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 	 * page size is >4K).  So we may allocate some extra VIs just
 	 * for writing PIO buffers through.
 	 *
-	 * The UC mapping contains (min_vis - 1) complete VIs and the
+	 * The UC mapping contains (channel_vis - 1) complete VIs and the
 	 * first half of the next VI.  Then the WC mapping begins with
 	 * the second half of this last VI.
 	 */
-	uc_mem_map_size = PAGE_ALIGN((min_vis - 1) * EFX_VI_PAGE_SIZE +
+	uc_mem_map_size = PAGE_ALIGN((channel_vis - 1) * EFX_VI_PAGE_SIZE +
 				     ER_DZ_TX_PIOBUF);
 	if (nic_data->n_piobufs) {
 		/* pio_write_vi_base rounds down to give the number of complete
@@ -881,7 +882,7 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 	} else {
 		pio_write_vi_base = 0;
 		wc_mem_map_size = 0;
-		max_vis = min_vis;
+		max_vis = channel_vis;
 	}
 
 	/* In case the last attached driver failed to free VIs, do it now */
@@ -893,6 +894,23 @@ static int efx_ef10_dimension_resources(struct efx_nic *efx)
 	if (rc != 0)
 		return rc;
 
+	if (nic_data->n_allocated_vis < channel_vis) {
+		netif_info(efx, drv, efx->net_dev,
+			   "Could not allocate enough VIs to satisfy RSS"
+			   " requirements. Performance may not be optimal.\n");
+		/* We didn't get the VIs to populate our channels.
+		 * We could keep what we got but then we'd have more
+		 * interrupts than we need.
+		 * Instead calculate new max_channels and restart
+		 */
+		efx->max_channels = nic_data->n_allocated_vis;
+		efx->max_tx_channels =
+			nic_data->n_allocated_vis / EFX_TXQ_TYPES;
+
+		efx_ef10_free_vis(efx);
+		return -EAGAIN;
+	}
+
 	/* If we didn't get enough VIs to map all the PIO buffers, free the
 	 * PIO buffers
 	 */
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 03bc03b..aa52c9a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -115,7 +115,7 @@ static struct workqueue_struct *reset_workqueue;
  *
  * This is only used in MSI-X interrupt mode
  */
-static bool separate_tx_channels;
+bool separate_tx_channels;
 module_param(separate_tx_channels, bool, 0444);
 MODULE_PARM_DESC(separate_tx_channels,
 		 "Use separate channels for TX and RX");
@@ -1419,12 +1419,15 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 			if (n_channels > extra_channels)
 				n_channels -= extra_channels;
 			if (separate_tx_channels) {
-				efx->n_tx_channels = max(n_channels / 2, 1U);
+				efx->n_tx_channels = min(max(n_channels / 2,
+							     1U),
+							 efx->max_tx_channels);
 				efx->n_rx_channels = max(n_channels -
 							 efx->n_tx_channels,
 							 1U);
 			} else {
-				efx->n_tx_channels = n_channels;
+				efx->n_tx_channels = min(n_channels,
+							 efx->max_tx_channels);
 				efx->n_rx_channels = n_channels;
 			}
 			for (i = 0; i < efx->n_channels; i++)
@@ -1653,17 +1656,34 @@ static int efx_probe_nic(struct efx_nic *efx)
 	if (rc)
 		return rc;
 
-	/* Determine the number of channels and queues by trying to hook
-	 * in MSI-X interrupts. */
-	rc = efx_probe_interrupts(efx);
-	if (rc)
-		goto fail1;
+	do {
+		if (!efx->max_channels || !efx->max_tx_channels) {
+			netif_err(efx, drv, efx->net_dev,
+				  "Insufficient resources to allocate"
+				  " any channels\n");
+			rc = -ENOSPC;
+			goto fail1;
+		}
 
-	efx_set_channels(efx);
+		/* Determine the number of channels and queues by trying
+		 * to hook in MSI-X interrupts.
+		 */
+		rc = efx_probe_interrupts(efx);
+		if (rc)
+			goto fail1;
 
-	rc = efx->type->dimension_resources(efx);
-	if (rc)
-		goto fail2;
+		efx_set_channels(efx);
+
+		/* dimension_resources can fail with EAGAIN */
+		rc = efx->type->dimension_resources(efx);
+		if (rc != 0 && rc != -EAGAIN)
+			goto fail2;
+
+		if (rc == -EAGAIN)
+			/* try again with new max_channels */
+			efx_remove_interrupts(efx);
+
+	} while (rc == -EAGAIN);
 
 	if (efx->n_channels > 1)
 		netdev_rss_key_fill(&efx->rx_hash_key,
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index acb1e07..6a5b84f 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -35,6 +35,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 int efx_setup_tc(struct net_device *net_dev, u8 num_tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
+extern bool separate_tx_channels;
 
 /* RX */
 void efx_set_default_rx_indir_table(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 80e69af..d790cb8 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2371,6 +2371,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 
 	efx->max_channels = (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ? 4 :
 			     EFX_MAX_CHANNELS);
+	efx->max_tx_channels = efx->max_channels;
 	efx->timer_quantum_ns = 4968; /* 621 cycles */
 
 	/* Initialise I2C adapter */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 4d35313..c530e1c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -972,6 +972,7 @@ struct efx_nic {
 	unsigned next_buffer_table;
 
 	unsigned int max_channels;
+	unsigned int max_tx_channels;
 	unsigned n_channels;
 	unsigned n_rx_channels;
 	unsigned rss_spread;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index b2f886d..2219b54 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -262,6 +262,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	}
 
 	efx->max_channels = EFX_MAX_CHANNELS;
+	efx->max_tx_channels = EFX_MAX_CHANNELS;
 
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
 	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
