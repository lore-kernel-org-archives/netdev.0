From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/11] sfc: Fix IRQ cleanup in case of a probe
 failure
Date: Wed, 19 Jun 2013 23:21:17 +0100
Message-ID: <1371680477.1956.117.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10499 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934895Ab3FSWVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:21:21 -0400
In-Reply-To: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lifetime of an irq_cpu_rmap is odd: we have to allocate it before
installing IRQ handlers and free it before removing the IRQ handlers.
As a result of this asymmetry, it was omitted from some failure paths.

On another failure path, we could try to remove IRQ handlers we
had not yet installed.

Move the irq_cpu_rmap allocation and freeing alongside IRQ handler
installation and removal, in efx_nic_{init,fini}_interrupts().
Count the number of IRQ handlers successfully installed and only
remove those on the failure path.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 33 -------------------------------
 drivers/net/ethernet/sfc/nic.c | 45 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 787c9eb..e7284a2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -21,7 +21,6 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include <linux/gfp.h>
-#include <linux/cpu_rmap.h>
 #include <linux/aer.h>
 #include <linux/interrupt.h>
 #include "net_driver.h"
@@ -1284,29 +1283,6 @@ static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
 	return count;
 }
 
-static int
-efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
-{
-#ifdef CONFIG_RFS_ACCEL
-	unsigned int i;
-	int rc;
-
-	efx->net_dev->rx_cpu_rmap = alloc_irq_cpu_rmap(efx->n_rx_channels);
-	if (!efx->net_dev->rx_cpu_rmap)
-		return -ENOMEM;
-	for (i = 0; i < efx->n_rx_channels; i++) {
-		rc = irq_cpu_rmap_add(efx->net_dev->rx_cpu_rmap,
-				      xentries[i].vector);
-		if (rc) {
-			free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
-			efx->net_dev->rx_cpu_rmap = NULL;
-			return rc;
-		}
-	}
-#endif
-	return 0;
-}
-
 /* Probe the number and type of interrupts we are able to obtain, and
  * the resulting numbers of channels and RX queues.
  */
@@ -1360,11 +1336,6 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 				efx->n_tx_channels = n_channels;
 				efx->n_rx_channels = n_channels;
 			}
-			rc = efx_init_rx_cpu_rmap(efx, xentries);
-			if (rc) {
-				pci_disable_msix(efx->pci_dev);
-				return rc;
-			}
 			for (i = 0; i < efx->n_channels; i++)
 				efx_get_channel(efx, i)->irq =
 					xentries[i].vector;
@@ -2608,10 +2579,6 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	BUG_ON(efx->state == STATE_READY);
 	cancel_work_sync(&efx->reset_work);
 
-#ifdef CONFIG_RFS_ACCEL
-	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
-	efx->net_dev->rx_cpu_rmap = NULL;
-#endif
 	efx_stop_interrupts(efx, false);
 	efx_nic_fini_interrupt(efx);
 	efx_fini_port(efx);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index f2b864c..56ed3bc 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -14,6 +14,7 @@
 #include <linux/pci.h>
 #include <linux/module.h>
 #include <linux/seq_file.h>
+#include <linux/cpu_rmap.h>
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
@@ -1706,6 +1707,7 @@ void efx_nic_push_rx_indir_table(struct efx_nic *efx)
 int efx_nic_init_interrupt(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
+	unsigned int n_irqs;
 	int rc;
 
 	if (!EFX_INT_MODE_USE_MSI(efx)) {
@@ -1726,7 +1728,19 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 		return 0;
 	}
 
+#ifdef CONFIG_RFS_ACCEL
+	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
+		efx->net_dev->rx_cpu_rmap =
+			alloc_irq_cpu_rmap(efx->n_rx_channels);
+		if (!efx->net_dev->rx_cpu_rmap) {
+			rc = -ENOMEM;
+			goto fail1;
+		}
+	}
+#endif
+
 	/* Hook MSI or MSI-X interrupt */
+	n_irqs = 0;
 	efx_for_each_channel(channel, efx) {
 		rc = request_irq(channel->irq, efx_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
@@ -1737,13 +1751,31 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 				  "failed to hook IRQ %d\n", channel->irq);
 			goto fail2;
 		}
+		++n_irqs;
+
+#ifdef CONFIG_RFS_ACCEL
+		if (efx->interrupt_mode == EFX_INT_MODE_MSIX &&
+		    channel->channel < efx->n_rx_channels) {
+			rc = irq_cpu_rmap_add(efx->net_dev->rx_cpu_rmap,
+					      channel->irq);
+			if (rc)
+				goto fail2;
+		}
+#endif
 	}
 
 	return 0;
 
  fail2:
-	efx_for_each_channel(channel, efx)
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
+	efx_for_each_channel(channel, efx) {
+		if (n_irqs-- == 0)
+			break;
 		free_irq(channel->irq, &efx->channel[channel->channel]);
+	}
  fail1:
 	return rc;
 }
@@ -1753,11 +1785,14 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 	struct efx_channel *channel;
 	efx_oword_t reg;
 
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
+
 	/* Disable MSI/MSI-X interrupts */
-	efx_for_each_channel(channel, efx) {
-		if (channel->irq)
-			free_irq(channel->irq, &efx->channel[channel->channel]);
-	}
+	efx_for_each_channel(channel, efx)
+		free_irq(channel->irq, &efx->channel[channel->channel]);
 
 	/* ACK legacy interrupt */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
