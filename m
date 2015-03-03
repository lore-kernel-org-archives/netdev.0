From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] stmmac: check IRQ availability early on probe
Date: Tue,  3 Mar 2015 13:46:44 +0300
Message-ID: <1425379604-24107-1-git-send-email-abrodkin@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we're getting IRQs after lots of resources are already
allocated:
 * netdev
 * clocks
 * MDIO bus
Also HW gets initialized by the time when checking IRQs as well.

Now there's a possibility for master interrupt controller to be not
probed yet. This will lead to exit from GMAC probe routine with "-
EPROBE_DEFER" and so deferred probe will hapen later on.

But since we exited the first GMAC probe without release of all
allocated resources there could be conflicts on subsequent probes.

For example this is what happens for me:
 --->8---
 stmmaceth e0018000.ethernet: no reset control found
 stmmac - user ID: 0x10, Synopsys ID: 0x37
  Ring mode enabled
  DMA HW capability register supported
  Normal descriptors
  RX Checksum Offload Engine supported (type 2)
  TX Checksum insertion supported
  Enable RX Mitigation via HW Watchdog Timer
 libphy: stmmac: probed
 eth0: PHY ID 20005c7a at 1 IRQ POLL (stmmac-0:01) active
 platform e0018000.ethernet: Driver stmmaceth requests probe deferral
 ...
 ...
 ...
 stmmaceth e0018000.ethernet: no reset control found
 stmmac - user ID: 0x10, Synopsys ID: 0x37
  Ring mode enabled
  DMA HW capability register supported
  Normal descriptors
  RX Checksum Offload Engine supported (type 2)
  TX Checksum insertion supported
  Enable RX Mitigation via HW Watchdog Timer
 ------------[ cut here ]------------
 WARNING: CPU: 0 PID: 6 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x4e/0x68()
 sysfs: cannot create duplicate filename
'/devices/platform/axs10x_mb/e0018000.ethernet/mdio_bus/stmmac-0'
 CPU: 0 PID: 6 Comm: kworker/u2:0 Not tainted 4.0.0-rc1-next-20150303+#8
 Workqueue: deferwq deferred_probe_work_func

 Stack Trace:
  arc_unwind_core+0xb8/0x114
  warn_slowpath_common+0x5a/0x8c
  warn_slowpath_fmt+0x2e/0x38
  sysfs_warn_dup+0x4e/0x68
  sysfs_create_dir_ns+0x98/0xa0
  kobject_add_internal+0x8c/0x2e8
  kobject_add+0x4a/0x8c
  device_add+0xc6/0x448
  mdiobus_register+0x6c/0x164
  stmmac_mdio_register+0x112/0x264
  stmmac_dvr_probe+0x6c0/0x85c
  stmmac_pltfr_probe+0x2e4/0x50c
  platform_drv_probe+0x26/0x5c
  really_probe+0x76/0x1dc
  bus_for_each_drv+0x42/0x7c
  device_attach+0x64/0x6c
  bus_probe_device+0x74/0xa4
  deferred_probe_work_func+0x50/0x84
  process_one_work+0xf8/0x2cc
  worker_thread+0x110/0x478
  kthread+0x8a/0x9c
  ret_from_fork+0x14/0x18
 ---[ end trace a2dfaa7d630c8be1 ]---
 ------------[ cut here ]------------
 WARNING: CPU: 0 PID: 6 at lib/kobject.c:240
kobject_add_internal+0x218/0x2e8()
 kobject_add_internal failed for stmmac-0 with -EEXIST, don't try to
register things with the same name in the same di.
 CPU: 0 PID: 6 Comm: kworker/u2:0 Tainted: G        W
4.0.0-rc1-next-20150303+ #8
 Workqueue: deferwq deferred_probe_work_func

 Stack Trace:
  arc_unwind_core+0xb8/0x114
  warn_slowpath_common+0x5a/0x8c
  warn_slowpath_fmt+0x2e/0x38
  kobject_add_internal+0x218/0x2e8
  kobject_add+0x4a/0x8c
  device_add+0xc6/0x448
  mdiobus_register+0x6c/0x164
  stmmac_mdio_register+0x112/0x264
  stmmac_dvr_probe+0x6c0/0x85c
  stmmac_pltfr_probe+0x2e4/0x50c
  platform_drv_probe+0x26/0x5c
  really_probe+0x76/0x1dc
  bus_for_each_drv+0x42/0x7c
  device_attach+0x64/0x6c
  bus_probe_device+0x74/0xa4
  deferred_probe_work_func+0x50/0x84
  process_one_work+0xf8/0x2cc
  worker_thread+0x110/0x478
  kthread+0x8a/0x9c
  ret_from_fork+0x14/0x18
 ---[ end trace a2dfaa7d630c8be2 ]---
 libphy: mii_bus stmmac-0 failed to register
 : Cannot register as MDIO bus
 stmmac_pltfr_probe: main driver probe failed
 stmmaceth: probe of e0018000.ethernet failed with error -22
 --->8---

Essential fix is to check for IRQs availability as early as possible and
then safely go to deferred probe if IRQs are not there yet.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Sonic Zhang <sonic.zhang@analog.com>
Cc: David S. Miller <davem@davemloft.net>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 65 ++++++++++++----------
 1 file changed, 36 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index fb846eb..f9b42f1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -272,6 +272,37 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	struct stmmac_priv *priv = NULL;
 	struct plat_stmmacenet_data *plat_dat = NULL;
 	const char *mac = NULL;
+	int irq, wol_irq, lpi_irq;
+
+	/* Get IRQ information early to have an ability to ask for deferred
+	 * probe if needed before we went too far with resource allocation.
+	 */
+	irq = platform_get_irq_byname(pdev, "macirq");
+	if (irq < 0) {
+		if (irq != -EPROBE_DEFER) {
+			dev_err(dev,
+				"MAC IRQ configuration information not found\n");
+		}
+		return irq;
+	}
+
+	/* On some platforms e.g. SPEAr the wake up irq differs from the mac irq
+	 * The external wake up irq can be passed through the platform code
+	 * named as "eth_wake_irq"
+	 *
+	 * In case the wake up interrupt is not passed from the platform
+	 * so the driver will continue to use the mac irq (ndev->irq)
+	 */
+	wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
+	if (wol_irq < 0) {
+		if (wol_irq == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		wol_irq = irq;
+	}
+
+	lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
+	if (lpi_irq == -EPROBE_DEFER)
+		return -EPROBE_DEFER;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	addr = devm_ioremap_resource(dev, res);
@@ -323,39 +354,15 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		return PTR_ERR(priv);
 	}
 
+	/* Copy IRQ values to priv structure which is now avaialble */
+	priv->dev->irq = irq;
+	priv->wol_irq = wol_irq;
+	priv->lpi_irq = lpi_irq;
+
 	/* Get MAC address if available (DT) */
 	if (mac)
 		memcpy(priv->dev->dev_addr, mac, ETH_ALEN);
 
-	/* Get the MAC information */
-	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
-	if (priv->dev->irq < 0) {
-		if (priv->dev->irq != -EPROBE_DEFER) {
-			netdev_err(priv->dev,
-				   "MAC IRQ configuration information not found\n");
-		}
-		return priv->dev->irq;
-	}
-
-	/*
-	 * On some platforms e.g. SPEAr the wake up irq differs from the mac irq
-	 * The external wake up irq can be passed through the platform code
-	 * named as "eth_wake_irq"
-	 *
-	 * In case the wake up interrupt is not passed from the platform
-	 * so the driver will continue to use the mac irq (ndev->irq)
-	 */
-	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
-	if (priv->wol_irq < 0) {
-		if (priv->wol_irq == -EPROBE_DEFER)
-			return -EPROBE_DEFER;
-		priv->wol_irq = priv->dev->irq;
-	}
-
-	priv->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
-	if (priv->lpi_irq == -EPROBE_DEFER)
-		return -EPROBE_DEFER;
-
 	platform_set_drvdata(pdev, priv->dev);
 
 	pr_debug("STMMAC platform driver registration completed");
-- 
2.1.0
