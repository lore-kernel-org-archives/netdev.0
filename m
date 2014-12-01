From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Subject: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Mon,  1 Dec 2014 23:46:38 +0300
Message-ID: <1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
References: <20141201111125.GA11974@localhost.localdomain>
Cc: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Gary Zambrano <zambrano@broadcom.com>,
	Michael Buesch <m@bues.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141201111125.GA11974@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wake On Lan was not working on laptop DELL Vostro 1500.
If WOL was turned on, BCM4401 was powered up in suspend mode. LEDs blinked.
But the laptop could not be woken up with the Magic Packet. The reason for
that was that PCIE was not enabled as a system wakeup source and
therefore the host PCI bridge was not powered up in suspend mode.
PCIE was not enabled in suspend by PM because no child devices were
registered as wakeup source during suspend process.
On laptop BCM4401 is connected through the SSB bus, that is connected to the
PCI-Express bus. SSB and B44 did not use standard PM wakeup functions
and did not forward wakeup settings to their parents.
To fix that B44 driver enables PM wakeup and registers new wakeup source
using device_set_wakeup_enable(). Wakeup is automatically reported to the parent SSB
bus via power.wakeup_path. SSB bus enables wakeup for the parent PCI bridge, if there is any
child devices with enabled wakeup functionality. All other steps are
done by PM core code.

Signed-off-by: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.c |    2 ++
 drivers/ssb/pcihost_wrapper.c       |   33 ++++++++++++++++++++++-----------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 416620f..ffeaf47 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2104,6 +2104,7 @@ static int b44_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		bp->flags &= ~B44_FLAG_WOL_ENABLE;
 	spin_unlock_irq(&bp->lock);
 
+	device_set_wakeup_enable(bp->sdev->dev, wol->wolopts & WAKE_MAGIC);
 	return 0;
 }
 
@@ -2452,6 +2453,7 @@ static int b44_init_one(struct ssb_device *sdev,
 		}
 	}
 
+	device_set_wakeup_capable(sdev->dev, true);
 	netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
 
 	return 0;
diff --git a/drivers/ssb/pcihost_wrapper.c b/drivers/ssb/pcihost_wrapper.c
index 69161bb..410215c 100644
--- a/drivers/ssb/pcihost_wrapper.c
+++ b/drivers/ssb/pcihost_wrapper.c
@@ -11,15 +11,17 @@
  * Licensed under the GNU/GPL. See COPYING for details.
  */
 
+#include <linux/pm.h>
 #include <linux/pci.h>
 #include <linux/export.h>
 #include <linux/slab.h>
 #include <linux/ssb/ssb.h>
 
 
-#ifdef CONFIG_PM
-static int ssb_pcihost_suspend(struct pci_dev *dev, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+static int ssb_pcihost_suspend(struct device *d)
 {
+	struct pci_dev *dev = to_pci_dev(d);
 	struct ssb_bus *ssb = pci_get_drvdata(dev);
 	int err;
 
@@ -28,17 +30,23 @@ static int ssb_pcihost_suspend(struct pci_dev *dev, pm_message_t state)
 		return err;
 	pci_save_state(dev);
 	pci_disable_device(dev);
-	pci_set_power_state(dev, pci_choose_state(dev, state));
+
+	/* if there is a wakeup enabled child device on ssb bus,
+	   enable pci wakeup posibility. */
+	device_set_wakeup_enable(d, d->power.wakeup_path);
+
+	pci_prepare_to_sleep(dev);
 
 	return 0;
 }
 
-static int ssb_pcihost_resume(struct pci_dev *dev)
+static int ssb_pcihost_resume(struct device *d)
 {
+	struct pci_dev *dev = to_pci_dev(d);
 	struct ssb_bus *ssb = pci_get_drvdata(dev);
 	int err;
 
-	pci_set_power_state(dev, PCI_D0);
+	pci_back_from_sleep(dev);
 	err = pci_enable_device(dev);
 	if (err)
 		return err;
@@ -49,10 +57,12 @@ static int ssb_pcihost_resume(struct pci_dev *dev)
 
 	return 0;
 }
-#else /* CONFIG_PM */
-# define ssb_pcihost_suspend	NULL
-# define ssb_pcihost_resume	NULL
-#endif /* CONFIG_PM */
+
+static const struct dev_pm_ops ssb_pcihost_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(ssb_pcihost_suspend, ssb_pcihost_resume)
+};
+
+#endif /* CONFIG_PM_SLEEP */
 
 static int ssb_pcihost_probe(struct pci_dev *dev,
 			     const struct pci_device_id *id)
@@ -115,8 +125,9 @@ int ssb_pcihost_register(struct pci_driver *driver)
 {
 	driver->probe = ssb_pcihost_probe;
 	driver->remove = ssb_pcihost_remove;
-	driver->suspend = ssb_pcihost_suspend;
-	driver->resume = ssb_pcihost_resume;
+#ifdef CONFIG_PM_SLEEP
+	driver->driver.pm = &ssb_pcihost_pm_ops;
+#endif
 
 	return pci_register_driver(driver);
 }
-- 
1.7.2.5
