From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 01:38:50 +0100
Message-ID: <200901310138.51214.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310059.17746.rjw@sisk.pl> <alpine.DEB.2.00.0901301924550.5056@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51036 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391AbZAaAjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 19:39:12 -0500
In-Reply-To: <alpine.DEB.2.00.0901301924550.5056@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Parag Warudkar wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> 
> > >  00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
> > > -	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > > +	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > >  	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >  	Latency: 0, Cache Line Size: 64 bytes
> > >  	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
> > 
> > and the PCIe port driver may be at fault.
> > 
> > Can you try to remove the pci_save_state(dev) from pcie_port_suspend_late()
> > and see if that helps?
> > 
> 
> I assume you meant pcie_portdrv_suspend_late in 
> drivers/pci/pcie/portdrv_pci.c - that one did not go well.

Yes.

> With that change machine refuses to suspend (comes back after attempting) 
> and my keyboard goes dead.

This gets more and more interesting.

Can you test the patch below, please?

Rafael

---
Subject: PCI PCIe portdrv: Implement pm object
From: Rafael J. Wysocki <rjw@sisk.pl>

Implement pm object for the PCI Express port driver in order to use
the new power management framework.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/pci/hotplug/pciehp_core.c |    4 +--
 drivers/pci/pcie/aer/aerdrv.c     |    6 -----
 drivers/pci/pcie/portdrv.h        |    4 +--
 drivers/pci/pcie/portdrv_core.c   |   14 +++++-------
 drivers/pci/pcie/portdrv_pci.c    |   43 ++++++++++++--------------------------
 include/linux/pcieport_if.h       |    2 -
 6 files changed, 25 insertions(+), 48 deletions(-)

Index: linux-2.6/drivers/pci/pcie/portdrv_pci.c
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/portdrv_pci.c
+++ linux-2.6/drivers/pci/pcie/portdrv_pci.c
@@ -49,33 +49,21 @@ static int pcie_portdrv_restore_config(s
 }
 
 #ifdef CONFIG_PM
-static int pcie_portdrv_suspend(struct pci_dev *dev, pm_message_t state)
-{
-	return pcie_port_device_suspend(dev, state);
-
-}
+static struct dev_pm_ops pcie_portdrv_pm_ops = {
+	.suspend = pcie_port_device_suspend,
+	.resume = pcie_port_device_resume,
+	.freeze = pcie_port_device_suspend,
+	.thaw = pcie_port_device_resume,
+	.poweroff = pcie_port_device_suspend,
+	.restore = pcie_port_device_resume,
+};
 
-static int pcie_portdrv_suspend_late(struct pci_dev *dev, pm_message_t state)
-{
-	return pci_save_state(dev);
-}
+#define PCIE_PORTDRV_PM_OPS	(&pcie_portdrv_pm_ops)
 
-static int pcie_portdrv_resume_early(struct pci_dev *dev)
-{
-	return pci_restore_state(dev);
-}
+#else /* !PM */
 
-static int pcie_portdrv_resume(struct pci_dev *dev)
-{
-	pcie_portdrv_restore_config(dev);
-	return pcie_port_device_resume(dev);
-}
-#else
-#define pcie_portdrv_suspend NULL
-#define pcie_portdrv_suspend_late NULL
-#define pcie_portdrv_resume_early NULL
-#define pcie_portdrv_resume NULL
-#endif
+#define PCIE_PORTDRV_PM_OPS	NULL
+#endif /* !PM */
 
 /*
  * pcie_portdrv_probe - Probe PCI-Express port devices
@@ -291,12 +279,9 @@ static struct pci_driver pcie_portdriver
 	.probe		= pcie_portdrv_probe,
 	.remove		= pcie_portdrv_remove,
 
-	.suspend	= pcie_portdrv_suspend,
-	.suspend_late	= pcie_portdrv_suspend_late,
-	.resume_early	= pcie_portdrv_resume_early,
-	.resume		= pcie_portdrv_resume,
-
 	.err_handler 	= &pcie_portdrv_err_handler,
+
+	.driver.pm 	= PCIE_PORTDRV_PM_OPS,
 };
 
 static int __init pcie_portdrv_init(void)
Index: linux-2.6/drivers/pci/pcie/portdrv.h
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/portdrv.h
+++ linux-2.6/drivers/pci/pcie/portdrv.h
@@ -36,8 +36,8 @@ extern struct bus_type pcie_port_bus_typ
 extern int pcie_port_device_probe(struct pci_dev *dev);
 extern int pcie_port_device_register(struct pci_dev *dev);
 #ifdef CONFIG_PM
-extern int pcie_port_device_suspend(struct pci_dev *dev, pm_message_t state);
-extern int pcie_port_device_resume(struct pci_dev *dev);
+extern int pcie_port_device_suspend(struct device *dev);
+extern int pcie_port_device_resume(struct device *dev);
 #endif
 extern void pcie_port_device_remove(struct pci_dev *dev);
 extern int __must_check pcie_port_bus_register(void);
Index: linux-2.6/drivers/pci/pcie/portdrv_core.c
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/portdrv_core.c
+++ linux-2.6/drivers/pci/pcie/portdrv_core.c
@@ -280,13 +280,12 @@ int pcie_port_device_register(struct pci
 static int suspend_iter(struct device *dev, void *data)
 {
 	struct pcie_port_service_driver *service_driver;
-	pm_message_t state = * (pm_message_t *) data;
 
  	if ((dev->bus == &pcie_port_bus_type) &&
  	    (dev->driver)) {
  		service_driver = to_service_driver(dev->driver);
  		if (service_driver->suspend)
- 			service_driver->suspend(to_pcie_device(dev), state);
+ 			service_driver->suspend(to_pcie_device(dev));
   	}
 	return 0;
 }
@@ -294,11 +293,10 @@ static int suspend_iter(struct device *d
 /**
  * pcie_port_device_suspend - suspend port services associated with a PCIe port
  * @dev: PCI Express port to handle
- * @state: Representation of system power management transition in progress
  */
-int pcie_port_device_suspend(struct pci_dev *dev, pm_message_t state)
+int pcie_port_device_suspend(struct device *dev)
 {
-	return device_for_each_child(&dev->dev, &state, suspend_iter);
+	return device_for_each_child(dev, NULL, suspend_iter);
 }
 
 static int resume_iter(struct device *dev, void *data)
@@ -318,11 +316,11 @@ static int resume_iter(struct device *de
  * pcie_port_device_suspend - resume port services associated with a PCIe port
  * @dev: PCI Express port to handle
  */
-int pcie_port_device_resume(struct pci_dev *dev)
+int pcie_port_device_resume(struct device *dev)
 {
-	return device_for_each_child(&dev->dev, NULL, resume_iter);
+	return device_for_each_child(dev, NULL, resume_iter);
 }
-#endif
+#endif /* PM */
 
 static int remove_iter(struct device *dev, void *data)
 {
Index: linux-2.6/include/linux/pcieport_if.h
===================================================================
--- linux-2.6.orig/include/linux/pcieport_if.h
+++ linux-2.6/include/linux/pcieport_if.h
@@ -59,7 +59,7 @@ struct pcie_port_service_driver {
 	int (*probe) (struct pcie_device *dev, 
 		const struct pcie_port_service_id *id);
 	void (*remove) (struct pcie_device *dev);
-	int (*suspend) (struct pcie_device *dev, pm_message_t state);
+	int (*suspend) (struct pcie_device *dev);
 	int (*resume) (struct pcie_device *dev);
 
 	/* Service Error Recovery Handler */
Index: linux-2.6/drivers/pci/pcie/aer/aerdrv.c
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/aer/aerdrv.c
+++ linux-2.6/drivers/pci/pcie/aer/aerdrv.c
@@ -41,9 +41,6 @@ MODULE_LICENSE("GPL");
 static int __devinit aer_probe (struct pcie_device *dev,
 	const struct pcie_port_service_id *id );
 static void aer_remove(struct pcie_device *dev);
-static int aer_suspend(struct pcie_device *dev, pm_message_t state)
-{return 0;}
-static int aer_resume(struct pcie_device *dev) {return 0;}
 static pci_ers_result_t aer_error_detected(struct pci_dev *dev,
 	enum pci_channel_state error);
 static void aer_error_resume(struct pci_dev *dev);
@@ -74,9 +71,6 @@ static struct pcie_port_service_driver a
 	.probe		= aer_probe,
 	.remove		= aer_remove,
 
-	.suspend	= aer_suspend,
-	.resume		= aer_resume,
-
 	.err_handler	= &aer_error_handlers,
 
 	.reset_link	= aer_root_reset,
Index: linux-2.6/drivers/pci/hotplug/pciehp_core.c
===================================================================
--- linux-2.6.orig/drivers/pci/hotplug/pciehp_core.c
+++ linux-2.6/drivers/pci/hotplug/pciehp_core.c
@@ -468,7 +468,7 @@ static void pciehp_remove (struct pcie_d
 }
 
 #ifdef CONFIG_PM
-static int pciehp_suspend (struct pcie_device *dev, pm_message_t state)
+static int pciehp_suspend (struct pcie_device *dev)
 {
 	dev_info(&dev->device, "%s ENTRY\n", __func__);
 	return 0;
@@ -496,7 +496,7 @@ static int pciehp_resume (struct pcie_de
 	}
 	return 0;
 }
-#endif
+#endif /* PM */
 
 static struct pcie_port_service_id port_pci_ids[] = { {
 	.vendor = PCI_ANY_ID,

