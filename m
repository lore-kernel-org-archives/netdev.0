From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v2 3/8] forcedeth: allow to silence tx_timeout debug messages
Date: Thu,  3 Nov 2011 18:41:18 -0700
Message-ID: <3e485056876fa0d0511d43d0c1349a20b947ab8d.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Sameer Nanda <snanda@google.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
In-Reply-To: <cover.1320369398.git.david.decotigny@google.com>
References: <cover.1320369398.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sameer Nanda <snanda@google.com>

This adds a new module parameter "debug_tx_timeout" to silence most
debug messages in case of TX timeout. These messages don't provide a
signal/noise ratio high enough for production systems and, with ~30kB
logged each time, they tend to add to a cascade effect if the system
is already under stress (memory pressure, disk, etc.).

By default, the parameter is clear, meaning the debug messages are not
displayed.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   98 ++++++++++++++++++-------------
 1 files changed, 57 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index c82a3c7..375b03b 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -894,6 +894,11 @@ enum {
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
@@ -2481,56 +2486,64 @@ static void nv_tx_timeout(struct net_device *dev)
 	u32 status;
 	union ring_type put_tx;
 	int saved_tx_limit;
-	int i;
 
 	if (np->msi_flags & NV_MSI_X_ENABLED)
 		status = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
 	else
 		status = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
 
-	netdev_info(dev, "Got tx_timeout. irq: %08x\n", status);
+	netdev_warn(dev, "Got tx_timeout. irq status: %08x\n", status);
 
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
+				    "%3x: %08x %08x %08x %08x "
+				    "%08x %08x %08x %08x\n",
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
+					    "%03x: %08x %08x // %08x %08x "
+					    "// %08x %08x // %08x %08x\n",
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
+					    "%03x: %08x %08x %08x "
+					    "// %08x %08x %08x "
+					    "// %08x %08x %08x "
+					    "// %08x %08x %08x\n",
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
 
@@ -6016,6 +6029,9 @@ module_param(phy_cross, int, 0);
 MODULE_PARM_DESC(phy_cross, "Phy crossover detection for Realtek 8201 phy is enabled by setting to 1 and disabled by setting to 0.");
 module_param(phy_power_down, int, 0);
 MODULE_PARM_DESC(phy_power_down, "Power down phy and disable link when interface is down (1), or leave phy powered up (0).");
+module_param(debug_tx_timeout, bool, 0);
+MODULE_PARM_DESC(debug_tx_timeout,
+		 "Dump tx related registers and ring when tx_timeout happens");
 
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");
-- 
1.7.3.1
