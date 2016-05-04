From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: Support setting rss_cpus to 'cores',
 'packages' or 'hyperthreads'
Date: Wed, 4 May 2016 18:01:52 +0100
Message-ID: <572A2B00.7060301@solarflare.com>
References: <572A29AF.1040607@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:31359 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754392AbcEDRCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:02:38 -0400
In-Reply-To: <572A29AF.1040607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These settings autoconfigure the number of RSS channels to match the number of
CPUs present.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 143 ++++++++++++++++++++++++++++++++---------
 1 file changed, 113 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0705ec86..e6fdf35 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -22,6 +22,7 @@
 #include <linux/gfp.h>
 #include <linux/aer.h>
 #include <linux/interrupt.h>
+#include <xen/xen.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "nic.h"
@@ -161,16 +162,19 @@ static unsigned int tx_irq_mod_usec = 150;
  */
 static unsigned int interrupt_mode;
 
-/* This is the requested number of CPUs to use for Receive-Side Scaling (RSS),
- * i.e. the number of CPUs among which we may distribute simultaneous
- * interrupt handling.
+/* This is the requested number of CPUs to use for Receive-Side Scaling
+ * (RSS), i.e. the number of CPUs among which we may distribute
+ * simultaneous interrupt handling.  Or alternatively it may be set to
+ * "packages", "cores" or "hyperthreads" to get one receive channel per
+ * package, core or hyperthread.  The default is "cores".
  *
- * Cards without MSI-X will only target one CPU via legacy or MSI interrupt.
- * The default (0) means to assign an interrupt to each core.
+ * Systems without MSI-X will only target one CPU via legacy or MSI
+ * interrupt.
  */
-static unsigned int rss_cpus;
-module_param(rss_cpus, uint, 0444);
-MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling");
+static char *rss_cpus;
+module_param(rss_cpus, charp, 0444);
+MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling, "
+		 "or 'packages', 'cores' or 'hyperthreads'");
 
 static bool phy_flash_cfg;
 module_param(phy_flash_cfg, bool, 0644);
@@ -1324,51 +1328,130 @@ void efx_set_default_rx_indir_table(struct efx_nic *efx)
 			ethtool_rxfh_indir_default(i, efx->rss_spread);
 }
 
-static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
+/* Count the number of unique packages in the given cpumask */
+static unsigned int efx_num_packages(const cpumask_t *in)
 {
-	cpumask_var_t thread_mask;
+	cpumask_var_t core_mask;
+	unsigned int count;
+	int cpu, cpu2;
+
+	if (unlikely(!zalloc_cpumask_var(&core_mask, GFP_KERNEL))) {
+		pr_warn("sfc: RSS disabled due to allocation failure\n");
+		return 1;
+	}
+
+	count = 0;
+	for_each_cpu(cpu, in) {
+		if (!cpumask_test_cpu(cpu, core_mask)) {
+			++count;
+
+			/* Treat each numa node as a seperate package */
+			for_each_cpu(cpu2, topology_core_cpumask(cpu)) {
+				if (cpu_to_node(cpu) == cpu_to_node(cpu2))
+					cpumask_set_cpu(cpu2, core_mask);
+			}
+		}
+	}
+
+	free_cpumask_var(core_mask);
+
+	return count;
+}
+
+/* Count the number of unique cores in the given cpumask */
+static unsigned int efx_num_cores(const cpumask_t *in)
+{
+	cpumask_var_t core_mask;
 	unsigned int count;
 	int cpu;
 
-	if (rss_cpus) {
-		count = rss_cpus;
-	} else {
-		if (unlikely(!zalloc_cpumask_var(&thread_mask, GFP_KERNEL))) {
-			netif_warn(efx, probe, efx->net_dev,
-				   "RSS disabled due to allocation failure\n");
-			return 1;
+	if (unlikely(!zalloc_cpumask_var(&core_mask, GFP_KERNEL))) {
+		pr_warn("sfc: RSS disabled due to allocation failure\n");
+		return 1;
+	}
+
+	count = 0;
+	for_each_cpu(cpu, in) {
+		if (!cpumask_test_cpu(cpu, core_mask)) {
+			++count;
+			cpumask_or(core_mask, core_mask,
+				   topology_sibling_cpumask(cpu));
 		}
+	}
 
-		count = 0;
-		for_each_online_cpu(cpu) {
-			if (!cpumask_test_cpu(cpu, thread_mask)) {
-				++count;
-				cpumask_or(thread_mask, thread_mask,
-					   topology_sibling_cpumask(cpu));
-			}
+	free_cpumask_var(core_mask);
+	return count;
+}
+
+static unsigned int efx_wanted_parallelism(struct efx_nic *efx)
+{
+	struct net_device *net_dev = efx->net_dev;
+	unsigned int n_rxq;
+
+	if (rss_cpus == NULL) {
+		/* default to 'cores' */
+		goto cores;
+	} else if (strcmp(rss_cpus, "packages") == 0) {
+		if (xen_domain()) {
+			netif_warn(efx, drv, net_dev,
+				   "Unable to determine CPU topology on Xen reliably. Using 4 rss channels.\n");
+			n_rxq = 4;
+		} else {
+			netif_dbg(efx,  drv, net_dev,
+				  "using efx_num_packages()\n");
+			n_rxq = efx_num_packages(cpu_online_mask);
+			/* Create two RSS queues even with a single package */
+			if (n_rxq == 1)
+				n_rxq = 2;
 		}
+	} else if (strcmp(rss_cpus, "cores") == 0) {
+cores:
+		if (xen_domain()) {
+			netif_warn(efx, drv, net_dev,
+				   "Unable to determine CPU topology on Xen reliably. Assuming hyperthreading enabled.\n");
+			n_rxq = max_t(int, 1, num_online_cpus() / 2);
+		} else {
+			netif_dbg(efx, drv, net_dev,
+				  "using efx_num_cores()\n");
+			n_rxq = efx_num_cores(cpu_online_mask);
+		}
+	} else if (strcmp(rss_cpus, "hyperthreads") == 0) {
+		n_rxq = num_online_cpus();
+	} else if (sscanf(rss_cpus, "%u", &n_rxq) == 1 && n_rxq > 0) {
+		/* nothing to do */
+	} else {
+		netif_err(efx, drv, net_dev,
+			  "Bad value for module parameter rss_cpus='%s'\n",
+			  rss_cpus);
+		/* default to 'cores' */
+		goto cores;
+	}
 
-		free_cpumask_var(thread_mask);
+	if (n_rxq > EFX_MAX_RX_QUEUES) {
+		netif_warn(efx, drv, net_dev,
+			   "Reducing number of rss channels from %u to %u.\n",
+			   n_rxq, EFX_MAX_RX_QUEUES);
+		n_rxq = EFX_MAX_RX_QUEUES;
 	}
 
+#ifdef CONFIG_SFC_SRIOV
 	/* If RSS is requested for the PF *and* VFs then we can't write RSS
 	 * table entries that are inaccessible to VFs
 	 */
-#ifdef CONFIG_SFC_SRIOV
 	if (efx->type->sriov_wanted) {
 		if (efx->type->sriov_wanted(efx) && efx_vf_size(efx) > 1 &&
-		    count > efx_vf_size(efx)) {
+		    n_rxq > efx_vf_size(efx)) {
 			netif_warn(efx, probe, efx->net_dev,
 				   "Reducing number of RSS channels from %u to %u for "
 				   "VF support. Increase vf-msix-limit to use more "
 				   "channels on the PF.\n",
-				   count, efx_vf_size(efx));
-			count = efx_vf_size(efx);
+				   n_rxq, efx_vf_size(efx));
+			n_rxq = efx_vf_size(efx);
 		}
 	}
 #endif
 
-	return count;
+	return n_rxq;
 }
 
 /* Probe the number and type of interrupts we are able to obtain, and
