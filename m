From: Alan Stern <stern@rowland.harvard.edu>
Subject: [PATCH 4/5] Remove useless get_driver()/put_driver() calls
Date: Tue, 24 Jan 2012 13:35:24 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1201241317120.1200-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Michael Buesch <m@bues.ch>,
	Joerg Roedel <joerg.roedel@amd.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xensource.com>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As part of the removal of get_driver()/put_driver(), this patch
(as1512) gets rid of various useless and unnecessary calls in several
drivers.  In some cases it may be desirable to pin the driver by
calling try_module_get(), but that can be done later.

Signed-off-by: Alan Stern <stern@rowland.harvard.edu>
CC: "David S. Miller" <davem@davemloft.net>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
CC: Michael Buesch <m@bues.ch>
CC: Joerg Roedel <joerg.roedel@amd.com>

---

 drivers/net/phy/phy_device.c |    6 +-----
 drivers/pci/xen-pcifront.c   |    3 +--
 drivers/ssb/main.c           |   20 ++------------------
 lib/dma-debug.c              |    3 +--
 4 files changed, 5 insertions(+), 27 deletions(-)

Index: usb-3.3/drivers/net/phy/phy_device.c
===================================================================
--- usb-3.3.orig/drivers/net/phy/phy_device.c
+++ usb-3.3/drivers/net/phy/phy_device.c
@@ -915,9 +915,7 @@ static int phy_probe(struct device *dev)
 
 	phydev = to_phy_device(dev);
 
-	/* Make sure the driver is held.
-	 * XXX -- Is this correct? */
-	drv = get_driver(phydev->dev.driver);
+	drv = phydev->dev.driver;
 	phydrv = to_phy_driver(drv);
 	phydev->drv = phydrv;
 
@@ -957,8 +955,6 @@ static int phy_remove(struct device *dev
 
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
-
-	put_driver(dev->driver);
 	phydev->drv = NULL;
 
 	return 0;
Index: usb-3.3/drivers/pci/xen-pcifront.c
===================================================================
--- usb-3.3.orig/drivers/pci/xen-pcifront.c
+++ usb-3.3/drivers/pci/xen-pcifront.c
@@ -593,7 +593,7 @@ static pci_ers_result_t pcifront_common_
 	}
 	pdrv = pcidev->driver;
 
-	if (get_driver(&pdrv->driver)) {
+	if (pdrv->driver) {
 		if (pdrv->err_handler && pdrv->err_handler->error_detected) {
 			dev_dbg(&pcidev->dev,
 				"trying to call AER service\n");
@@ -623,7 +623,6 @@ static pci_ers_result_t pcifront_common_
 				}
 			}
 		}
-		put_driver(&pdrv->driver);
 	}
 	if (!flag)
 		result = PCI_ERS_RESULT_NONE;
Index: usb-3.3/drivers/ssb/main.c
===================================================================
--- usb-3.3.orig/drivers/ssb/main.c
+++ usb-3.3/drivers/ssb/main.c
@@ -140,19 +140,6 @@ static void ssb_device_put(struct ssb_de
 		put_device(dev->dev);
 }
 
-static inline struct ssb_driver *ssb_driver_get(struct ssb_driver *drv)
-{
-	if (drv)
-		get_driver(&drv->drv);
-	return drv;
-}
-
-static inline void ssb_driver_put(struct ssb_driver *drv)
-{
-	if (drv)
-		put_driver(&drv->drv);
-}
-
 static int ssb_device_resume(struct device *dev)
 {
 	struct ssb_device *ssb_dev = dev_to_ssb_dev(dev);
@@ -250,11 +237,9 @@ int ssb_devices_freeze(struct ssb_bus *b
 			ssb_device_put(sdev);
 			continue;
 		}
-		sdrv = ssb_driver_get(drv_to_ssb_drv(sdev->dev->driver));
-		if (!sdrv || SSB_WARN_ON(!sdrv->remove)) {
-			ssb_device_put(sdev);
+		sdrv = drv_to_ssb_drv(sdev->dev->driver);
+		if (SSB_WARN_ON(!sdrv->remove))
 			continue;
-		}
 		sdrv->remove(sdev);
 		ctx->device_frozen[i] = 1;
 	}
@@ -293,7 +278,6 @@ int ssb_devices_thaw(struct ssb_freeze_c
 				   dev_name(sdev->dev));
 			result = err;
 		}
-		ssb_driver_put(sdrv);
 		ssb_device_put(sdev);
 	}
 
Index: usb-3.3/lib/dma-debug.c
===================================================================
--- usb-3.3.orig/lib/dma-debug.c
+++ usb-3.3/lib/dma-debug.c
@@ -170,7 +170,7 @@ static bool driver_filter(struct device
 		return false;
 
 	/* driver filter on but not yet initialized */
-	drv = get_driver(dev->driver);
+	drv = dev->driver;
 	if (!drv)
 		return false;
 
@@ -185,7 +185,6 @@ static bool driver_filter(struct device
 	}
 
 	read_unlock_irqrestore(&driver_name_lock, flags);
-	put_driver(drv);
 
 	return ret;
 }
