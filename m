From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 08/13] tile: fix panic bug in napi support for tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <7d5cffa369c00feb0fcda0386c6c241ef2e253a3.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code used to call napi_disable() in an interrupt handler
(from smp_call_function), which in turn could call msleep().
Unfortunately you can't sleep in an interrupt context.

Luckily it turns out all the NAPI support functions are
just operating on data structures and not on any deeply
per-cpu data, so we can arrange to set up and tear down all
the NAPI state on the core driving the process, and just
do the IRQ enable/disable as a smp_call_function thing.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 65 +++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index a245858..b34fd2c 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -686,37 +686,13 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	return HRTIMER_NORESTART;
 }
 
-/* Helper function for "tile_net_update()".
- * "dev" (i.e. arg) is the device being brought up or down,
- * or NULL if all devices are now down.
- */
-static void tile_net_update_cpu(void *arg)
+/* Helper function for "tile_net_update()". */
+static void manage_ingress_irq(void *enable)
 {
-	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	struct net_device *dev = arg;
-
-	if (!info->has_iqueue)
-		return;
-
-	if (dev != NULL) {
-		if (!info->napi_added) {
-			netif_napi_add(dev, &info->napi,
-				       tile_net_poll, TILE_NET_WEIGHT);
-			info->napi_added = true;
-		}
-		if (!info->napi_enabled) {
-			napi_enable(&info->napi);
-			info->napi_enabled = true;
-		}
+	if (enable)
 		enable_percpu_irq(ingress_irq, 0);
-	} else {
+	else
 		disable_percpu_irq(ingress_irq);
-		if (info->napi_enabled) {
-			napi_disable(&info->napi);
-			info->napi_enabled = false;
-		}
-		/* FIXME: Drain the iqueue. */
-	}
 }
 
 /* Helper function for tile_net_open() and tile_net_stop().
@@ -753,10 +729,35 @@ static int tile_net_update(struct net_device *dev)
 		return -EIO;
 	}
 
-	/* Update all cpus, sequentially (to protect "netif_napi_add()"). */
-	for_each_online_cpu(cpu)
-		smp_call_function_single(cpu, tile_net_update_cpu,
-					 (saw_channel ? dev : NULL), 1);
+	/* Update all cpus, sequentially (to protect "netif_napi_add()").
+	 * We use on_each_cpu to handle the IPI mask or unmask.
+	 */
+	if (!saw_channel)
+		on_each_cpu(manage_ingress_irq, (void *)0, 1);
+	for_each_online_cpu(cpu) {
+		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
+		if (!info->has_iqueue)
+			continue;
+		if (saw_channel) {
+			if (!info->napi_added) {
+				netif_napi_add(dev, &info->napi,
+					       tile_net_poll, TILE_NET_WEIGHT);
+				info->napi_added = true;
+			}
+			if (!info->napi_enabled) {
+				napi_enable(&info->napi);
+				info->napi_enabled = true;
+			}
+		} else {
+			if (info->napi_enabled) {
+				napi_disable(&info->napi);
+				info->napi_enabled = false;
+			}
+			/* FIXME: Drain the iqueue. */
+		}
+	}
+	if (saw_channel)
+		on_each_cpu(manage_ingress_irq, (void *)1, 1);
 
 	/* HACK: Allow packets to flow in the simulator. */
 	if (saw_channel)
-- 
1.8.3.1
