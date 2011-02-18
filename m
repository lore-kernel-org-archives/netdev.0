From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH net-next-2.6 2/2] sfc: Add CPU queue mapping for XPS
Date: Fri, 18 Feb 2011 16:15:42 +0000
Message-ID: <1298045742.2570.19.camel@bwh-desktop>
References: <1298045607.2570.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40117 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757507Ab1BRQPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:15:44 -0500
In-Reply-To: <1298045607.2570.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   59 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 41 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 35b7bc5..6d698c3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1179,9 +1179,11 @@ static int efx_wanted_channels(void)
 }
 
 static int
-efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
+efx_init_cpu_rmaps(struct efx_nic *efx, struct msix_entry *xentries)
 {
-#ifdef CONFIG_RFS_ACCEL
+#ifndef CONFIG_NET_IRQ_CPU_RMAP
+	return 0;
+#else
 	int i, rc;
 
 	efx->net_dev->rx_cpu_rmap = alloc_irq_cpu_rmap(efx->n_rx_channels);
@@ -1190,14 +1192,38 @@ efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
 	for (i = 0; i < efx->n_rx_channels; i++) {
 		rc = irq_cpu_rmap_add(efx->net_dev->rx_cpu_rmap,
 				      xentries[i].vector);
-		if (rc) {
-			free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
-			efx->net_dev->rx_cpu_rmap = NULL;
-			return rc;
+		if (rc)
+			goto fail_rx;
+	}
+
+	if (efx->tx_channel_offset == 0) {
+		efx->net_dev->tx_cpu_rmap = efx->net_dev->rx_cpu_rmap;
+	} else {
+		efx->net_dev->tx_cpu_rmap =
+			alloc_irq_cpu_rmap(efx->n_tx_channels);
+		if (!efx->net_dev->tx_cpu_rmap) {
+			rc = -ENOMEM;
+			goto fail_rx;
+		}
+		for (i = 0; i < efx->n_tx_channels; i++) {
+			rc = irq_cpu_rmap_add(
+				efx->net_dev->tx_cpu_rmap,
+				xentries[efx->tx_channel_offset + i].vector);
+			if (rc)
+				goto fail_tx;
 		}
 	}
-#endif
+
 	return 0;
+
+fail_tx:
+	free_irq_cpu_rmap(efx->net_dev->tx_cpu_rmap);
+	efx->net_dev->tx_cpu_rmap = NULL;
+fail_rx:
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+	return rc;
+#endif
 }
 
 /* Probe the number and type of interrupts we are able to obtain, and
@@ -1238,14 +1264,15 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 			if (separate_tx_channels) {
 				efx->n_tx_channels =
 					max(efx->n_channels / 2, 1U);
+				efx->tx_channel_offset =
+					efx->n_channels - efx->n_tx_channels;
 				efx->n_rx_channels =
-					max(efx->n_channels -
-					    efx->n_tx_channels, 1U);
+					max(efx->tx_channel_offset, 1U);
 			} else {
 				efx->n_tx_channels = efx->n_channels;
 				efx->n_rx_channels = efx->n_channels;
 			}
-			rc = efx_init_rx_cpu_rmap(efx, xentries);
+			rc = efx_init_cpu_rmaps(efx, xentries);
 			if (rc) {
 				pci_disable_msix(efx->pci_dev);
 				return rc;
@@ -1301,12 +1328,6 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 	efx->legacy_irq = 0;
 }
 
-static void efx_set_channels(struct efx_nic *efx)
-{
-	efx->tx_channel_offset =
-		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
-}
-
 static int efx_probe_nic(struct efx_nic *efx)
 {
 	size_t i;
@@ -1330,7 +1351,6 @@ static int efx_probe_nic(struct efx_nic *efx)
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
 		efx->rx_indir_table[i] = i % efx->n_rx_channels;
 
-	efx_set_channels(efx);
 	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
 	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
 
@@ -2315,7 +2335,10 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
-#ifdef CONFIG_RFS_ACCEL
+#ifdef CONFIG_NET_IRQ_CPU_RMAP
+	if (efx->net_dev->tx_cpu_rmap != efx->net_dev->rx_cpu_rmap)
+		free_irq_cpu_rmap(efx->net_dev->tx_cpu_rmap);
+	efx->net_dev->tx_cpu_rmap = NULL;
 	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
 	efx->net_dev->rx_cpu_rmap = NULL;
 #endif
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

