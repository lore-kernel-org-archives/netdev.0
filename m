From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx-d80211: use pci_iomap() for convenience.
Date: Mon, 10 Apr 2006 02:05:42 +0200
Message-ID: <200604100205.42982.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

This reduces codesize.

--- a/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h
@@ -639,7 +639,6 @@ struct bcm43xx_private {
 	unsigned int irq;
 
 	void __iomem *mmio_addr;
-	unsigned int mmio_len;
 
 	/* Do not use the lock directly. Use the bcm43xx_lock* helper
 	 * functions, to be MMIO-safe. */
--- a/drivers/net/wireless/bcm43xx-d80211/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx-d80211/bcm43xx_debugfs.c
@@ -92,7 +92,7 @@ static ssize_t devinfo_read_file(struct 
 	fappend("subsystem_vendor: 0x%04x   subsystem_device: 0x%04x\n",
 		pci_dev->subsystem_vendor, pci_dev->subsystem_device);
 	fappend("IRQ: %d\n", bcm->irq);
-	fappend("mmio_addr: 0x%p   mmio_len: %u\n", bcm->mmio_addr, bcm->mmio_len);
+	fappend("mmio_addr: 0x%p\n", bcm->mmio_addr);
 	fappend("chip_id: 0x%04x   chip_rev: 0x%02x\n", bcm->chip_id, bcm->chip_rev);
 	if ((bcm->core_80211[0].rev >= 3) && (bcm43xx_read32(bcm, 0x0158) & (1 << 16)))
 		fappend("Radio disabled by hardware!\n");
--- a/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
@@ -3770,8 +3770,7 @@ static void bcm43xx_detach_board(struct 
 
 	bcm43xx_chipset_detach(bcm);
 	/* Do _not_ access the chip, after it is detached. */
-	iounmap(bcm->mmio_addr);
-
+	pci_iounmap(pci_dev, bcm->mmio_addr);
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
 
@@ -3845,40 +3844,26 @@ static int bcm43xx_attach_board(struct b
 	struct net_device *net_dev = bcm->net_dev;
 	int err;
 	int i;
-	unsigned long mmio_start, mmio_flags, mmio_len;
 	u32 coremask;
 
 	err = pci_enable_device(pci_dev);
 	if (err) {
-		printk(KERN_ERR PFX "unable to wake up pci device (%i)\n", err);
+		printk(KERN_ERR PFX "pci_enable_device() failed\n");
 		goto out;
 	}
-	mmio_start = pci_resource_start(pci_dev, 0);
-	mmio_flags = pci_resource_flags(pci_dev, 0);
-	mmio_len = pci_resource_len(pci_dev, 0);
-	if (!(mmio_flags & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX
-		       "%s, region #0 not an MMIO resource, aborting\n",
-		       pci_name(pci_dev));
-		err = -ENODEV;
-		goto err_pci_disable;
-	}
 	err = pci_request_regions(pci_dev, KBUILD_MODNAME);
 	if (err) {
-		printk(KERN_ERR PFX
-		       "could not access PCI resources (%i)\n", err);
+		printk(KERN_ERR PFX "pci_request_regions() failed\n");
 		goto err_pci_disable;
 	}
 	/* enable PCI bus-mastering */
 	pci_set_master(pci_dev);
-	bcm->mmio_addr = ioremap(mmio_start, mmio_len);
+	bcm->mmio_addr = pci_iomap(pci_dev, 0, ~0UL);
 	if (!bcm->mmio_addr) {
-		printk(KERN_ERR PFX "%s: cannot remap MMIO, aborting\n",
-		       pci_name(pci_dev));
+		printk(KERN_ERR PFX "pci_iomap() failed\n");
 		err = -EIO;
 		goto err_pci_release;
 	}
-	bcm->mmio_len = mmio_len;
 	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
 
 	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
@@ -3969,7 +3954,7 @@ err_80211_unwind:
 err_chipset_detach:
 	bcm43xx_chipset_detach(bcm);
 err_iounmap:
-	iounmap(bcm->mmio_addr);
+	pci_iounmap(pci_dev, bcm->mmio_addr);
 err_pci_release:
 	pci_release_regions(pci_dev);
 err_pci_disable:

-- 
Greetings Michael.
