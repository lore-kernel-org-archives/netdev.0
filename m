From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/32] sfc: Set default parallelism to per-core by
 default
Date: Fri, 27 Jan 2012 20:44:35 +0000
Message-ID: <1327697075.2503.15.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63535 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753954Ab2A0Uoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:44:38 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous default of per-package can be more CPU-efficient, but
users generally seem to prefer per-core.  It should also allow
accelerated RFS to direct packets more precisely, if IRQ affinity
is properly spread out.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5fcc42f..d7301d2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -162,7 +162,7 @@ static unsigned int interrupt_mode;
  * interrupt handling.
  *
  * Cards without MSI-X will only target one CPU via legacy or MSI interrupt.
- * The default (0) means to assign an interrupt to each package (level II cache)
+ * The default (0) means to assign an interrupt to each core.
  */
 static unsigned int rss_cpus;
 module_param(rss_cpus, uint, 0444);
@@ -1148,14 +1148,14 @@ static void efx_fini_io(struct efx_nic *efx)
 
 static int efx_wanted_parallelism(void)
 {
-	cpumask_var_t core_mask;
+	cpumask_var_t thread_mask;
 	int count;
 	int cpu;
 
 	if (rss_cpus)
 		return rss_cpus;
 
-	if (unlikely(!zalloc_cpumask_var(&core_mask, GFP_KERNEL))) {
+	if (unlikely(!zalloc_cpumask_var(&thread_mask, GFP_KERNEL))) {
 		printk(KERN_WARNING
 		       "sfc: RSS disabled due to allocation failure\n");
 		return 1;
@@ -1163,14 +1163,14 @@ static int efx_wanted_parallelism(void)
 
 	count = 0;
 	for_each_online_cpu(cpu) {
-		if (!cpumask_test_cpu(cpu, core_mask)) {
+		if (!cpumask_test_cpu(cpu, thread_mask)) {
 			++count;
-			cpumask_or(core_mask, core_mask,
-				   topology_core_cpumask(cpu));
+			cpumask_or(thread_mask, thread_mask,
+				   topology_thread_cpumask(cpu));
 		}
 	}
 
-	free_cpumask_var(core_mask);
+	free_cpumask_var(thread_mask);
 	return count;
 }
 
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
