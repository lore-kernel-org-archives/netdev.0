From: David Decotigny <decot@google.com>
Subject: [PATCH 3/6] forcedeth: allow to silence tx_timeout debug messages
Date: Wed, 18 May 2011 17:14:37 -0700
Message-ID: <1305764080-24853-3-git-send-email-decot@google.com>
References: <1305764080-24853-1-git-send-email-decot@google.com>
Cc: kernel-net-upstream@google.com, Sameer Nanda <snanda@google.com>,
	David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:40128 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab1ESAPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 20:15:12 -0400
In-Reply-To: <1305764080-24853-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sameer Nanda <snanda@google.com>

This adds a new module parameter "debug_tx_timeout" to silence most
debug messages in case of TX timeout. These messages don't provide a
signal/noise ratio high enough for production systems and, with ~30kB
logged each time, they tend to add to a cascade effect if the system
is already under stress (memory pressure, disk, etc.).

By default, the parameter is clear, meaning the debug messages are not
displayed.


Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/forcedeth.c |   91 ++++++++++++++++++++++++++--------------------
 1 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 112dc0b..7a6aa08 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -896,6 +896,11 @@ enum {
 static int dma_64bit = NV_DMA_64BIT_ENABLED;
 
 /*
+ * Debug output control for tx_timeout
+ */
+static bool debug_tx_timeout = false;
+
+/*
  * Crossover Detection
  * Realtek 8201 phy + some OEM boards do not work properly.
  */
@@ -2473,7 +2478,6 @@ static void nv_tx_timeout(struct net_device *dev)
 	u32 status;
 	union ring_type put_tx;
 	int saved_tx_limit;
-	int i;
 
 	if (np->msi_flags & NV_MSI_X_ENABLED)
 		status = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
@@ -2482,47 +2486,51 @@ static void nv_tx_timeout(struct net_device *dev)
 
 	netdev_info(dev, "Got tx_timeout. irq: %08x\n", status);
 
-	netdev_info(dev, "Ring at %lx\n", (unsigned long)np->ring_addr);
-	netdev_info(dev, "Dumping tx registers\n");
-	for (i = 0; i <= np->register_size; i += 32) {
-		netdev_info(dev,
-			    "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
-			    i,
-			    readl(base + i + 0), readl(base + i + 4),
-			    readl(base + i + 8), readl(base + i + 12),
-			    readl(base + i + 16), readl(base + i + 20),
-			    readl(base + i + 24), readl(base + i + 28));
-	}
-	netdev_info(dev, "Dumping tx ring\n");
-	for (i = 0; i < np->tx_ring_size; i += 4) {
-		if (!nv_optimized(np)) {
-			netdev_info(dev,
-				    "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
-				    i,
-				    le32_to_cpu(np->tx_ring.orig[i].buf),
-				    le32_to_cpu(np->tx_ring.orig[i].flaglen),
-				    le32_to_cpu(np->tx_ring.orig[i+1].buf),
-				    le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
-				    le32_to_cpu(np->tx_ring.orig[i+2].buf),
-				    le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
-				    le32_to_cpu(np->tx_ring.orig[i+3].buf),
-				    le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
-		} else {
+	if (unlikely(debug_tx_timeout)) {
+		int i;
+
+		netdev_info(dev, "Ring at %lx\n", (unsigned long)np->ring_addr);
+		netdev_info(dev, "Dumping tx registers\n");
+		for (i = 0; i <= np->register_size; i += 32) {
 			netdev_info(dev,
-				    "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
+				    "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
 				    i,
-				    le32_to_cpu(np->tx_ring.ex[i].bufhigh),
-				    le32_to_cpu(np->tx_ring.ex[i].buflow),
-				    le32_to_cpu(np->tx_ring.ex[i].flaglen),
-				    le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
-				    le32_to_cpu(np->tx_ring.ex[i+1].buflow),
-				    le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
-				    le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
-				    le32_to_cpu(np->tx_ring.ex[i+2].buflow),
-				    le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
-				    le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
-				    le32_to_cpu(np->tx_ring.ex[i+3].buflow),
-				    le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
+				    readl(base + i + 0), readl(base + i + 4),
+				    readl(base + i + 8), readl(base + i + 12),
+				    readl(base + i + 16), readl(base + i + 20),
+				    readl(base + i + 24), readl(base + i + 28));
+		}
+		netdev_info(dev, "Dumping tx ring\n");
+		for (i = 0; i < np->tx_ring_size; i += 4) {
+			if (!nv_optimized(np)) {
+				netdev_info(dev,
+					    "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
+					    i,
+					    le32_to_cpu(np->tx_ring.orig[i].buf),
+					    le32_to_cpu(np->tx_ring.orig[i].flaglen),
+					    le32_to_cpu(np->tx_ring.orig[i+1].buf),
+					    le32_to_cpu(np->tx_ring.orig[i+1].flaglen),
+					    le32_to_cpu(np->tx_ring.orig[i+2].buf),
+					    le32_to_cpu(np->tx_ring.orig[i+2].flaglen),
+					    le32_to_cpu(np->tx_ring.orig[i+3].buf),
+					    le32_to_cpu(np->tx_ring.orig[i+3].flaglen));
+			} else {
+				netdev_info(dev,
+					    "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
+					    i,
+					    le32_to_cpu(np->tx_ring.ex[i].bufhigh),
+					    le32_to_cpu(np->tx_ring.ex[i].buflow),
+					    le32_to_cpu(np->tx_ring.ex[i].flaglen),
+					    le32_to_cpu(np->tx_ring.ex[i+1].bufhigh),
+					    le32_to_cpu(np->tx_ring.ex[i+1].buflow),
+					    le32_to_cpu(np->tx_ring.ex[i+1].flaglen),
+					    le32_to_cpu(np->tx_ring.ex[i+2].bufhigh),
+					    le32_to_cpu(np->tx_ring.ex[i+2].buflow),
+					    le32_to_cpu(np->tx_ring.ex[i+2].flaglen),
+					    le32_to_cpu(np->tx_ring.ex[i+3].bufhigh),
+					    le32_to_cpu(np->tx_ring.ex[i+3].buflow),
+					    le32_to_cpu(np->tx_ring.ex[i+3].flaglen));
+			}
 		}
 	}
 
@@ -6006,6 +6014,9 @@ module_param(phy_cross, int, 0);
 MODULE_PARM_DESC(phy_cross, "Phy crossover detection for Realtek 8201 phy is enabled by setting to 1 and disabled by setting to 0.");
 module_param(phy_power_down, int, 0);
 MODULE_PARM_DESC(phy_power_down, "Power down phy and disable link when interface is down (1), or leave phy powered up (0).");
+module_param(debug_tx_timeout, bool, false);
+MODULE_PARM_DESC(debug_tx_timeout,
+		 "Dump tx related registers and ring when tx_timeout happens");
 
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");
-- 
1.7.3.1

