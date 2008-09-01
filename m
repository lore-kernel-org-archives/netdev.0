From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 22/52] sfc: Move CPU counting for RSS into a separate function, efx_wanted_rx_queues()
Date: Mon, 1 Sep 2008 12:47:33 +0100
Message-ID: <20080901114732.GP7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:58219 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751733AbYIALrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:35 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   60 ++++++++++++++++++++++++++++--------------------
 1 files changed, 35 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 9f1ac3a..487df94 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -819,38 +819,48 @@ static void efx_fini_io(struct efx_nic *efx)
 	pci_disable_device(efx->pci_dev);
 }
 
-/* Probe the number and type of interrupts we are able to obtain. */
+/* Get number of RX queues wanted.  Return number of online CPU
+ * packages in the expectation that an IRQ balancer will spread
+ * interrupts across them. */
+static int efx_wanted_rx_queues(void)
+{
+	cpumask_t core_mask;
+	int count;
+	int cpu;
+
+	cpus_clear(core_mask);
+	count = 0;
+	for_each_online_cpu(cpu) {
+		if (!cpu_isset(cpu, core_mask)) {
+			++count;
+			cpus_or(core_mask, core_mask,
+				topology_core_siblings(cpu));
+		}
+	}
+
+	return count;
+}
+
+/* Probe the number and type of interrupts we are able to obtain, and
+ * the resulting numbers of channels and RX queues.
+ */
 static void efx_probe_interrupts(struct efx_nic *efx)
 {
-	int max_channel = efx->type->phys_addr_channels - 1;
-	struct msix_entry xentries[EFX_MAX_CHANNELS];
+	int max_channels =
+		min_t(int, efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
 	int rc, i;
 
 	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
-		BUG_ON(!pci_find_capability(efx->pci_dev, PCI_CAP_ID_MSIX));
-
-		if (rss_cpus == 0) {
-			cpumask_t core_mask;
-			int cpu;
-
-			cpus_clear(core_mask);
-			efx->rss_queues = 0;
-			for_each_online_cpu(cpu) {
-				if (!cpu_isset(cpu, core_mask)) {
-					++efx->rss_queues;
-					cpus_or(core_mask, core_mask,
-						topology_core_siblings(cpu));
-				}
-			}
-		} else {
-			efx->rss_queues = rss_cpus;
-		}
+		struct msix_entry xentries[EFX_MAX_CHANNELS];
+		int wanted_ints;
 
-		efx->rss_queues = min(efx->rss_queues, max_channel + 1);
-		efx->rss_queues = min(efx->rss_queues, EFX_MAX_CHANNELS);
+		/* We want one RX queue and interrupt per CPU package
+		 * (or as specified by the rss_cpus module parameter).
+		 * We will need one channel per interrupt.
+		 */
+		wanted_ints = rss_cpus ? rss_cpus : efx_wanted_rx_queues();
+		efx->rss_queues = min(wanted_ints, max_channels);
 
-		/* Request maximum number of MSI interrupts, and fill out
-		 * the channel interrupt information the allowed allocation */
 		for (i = 0; i < efx->rss_queues; i++)
 			xentries[i].entry = i;
 		rc = pci_enable_msix(efx->pci_dev, xentries, efx->rss_queues);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

