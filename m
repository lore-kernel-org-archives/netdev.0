From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/4] sfc: Create one RX queue and interrupt per CPU package by default
Date: Fri, 18 Jul 2008 19:03:10 +0100
Message-ID: <20080718180309.GI10471@solarflare.com>
References: <20080718175911.GF10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:53352 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753479AbYGRSDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 14:03:12 -0400
Content-Disposition: inline
In-Reply-To: <20080718175911.GF10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using multiple cores in the same package to handle received traffic
does not appear to provide a performance benefit.  Therefore use CPU
topology information to count CPU packages and use that as the default
number of RX queues and interrupts.  We rely on interrupt balancing to
spread the interrupts across packages.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7b2a818..45c72ee 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -19,6 +19,7 @@
 #include <linux/in.h>
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
+#include <linux/topology.h>
 #include "net_driver.h"
 #include "gmii.h"
 #include "ethtool.h"
@@ -832,7 +833,23 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 	if (efx->interrupt_mode == EFX_INT_MODE_MSIX) {
 		BUG_ON(!pci_find_capability(efx->pci_dev, PCI_CAP_ID_MSIX));
 
-		efx->rss_queues = rss_cpus ? rss_cpus : num_online_cpus();
+		if (rss_cpus == 0) {
+			cpumask_t core_mask;
+			int cpu;
+
+			cpus_clear(core_mask);
+			efx->rss_queues = 0;
+			for_each_online_cpu(cpu) {
+				if (!cpu_isset(cpu, core_mask)) {
+					++efx->rss_queues;
+					cpus_or(core_mask, core_mask,
+						topology_core_siblings(cpu));
+				}
+			}
+		} else {
+			efx->rss_queues = rss_cpus;
+		}
+
 		efx->rss_queues = min(efx->rss_queues, max_channel + 1);
 		efx->rss_queues = min(efx->rss_queues, EFX_MAX_CHANNELS);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
