From: Dan Noe <dpn@isomerica.net>
Subject: [PATCH] Arcnet: Don't use interface name in log prints until it is known.
Date: Sat, 12 Apr 2008 22:28:20 -0400
Message-ID: <12080537002047-git-send-email-dpn@isomerica.net>
Cc: Dan Noe <dpn@isomerica.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:44397 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbYDMCay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 22:30:54 -0400
In-Reply-To: 20080412181721.34d50f0b@extreme
References: 20080412181721.34d50f0b@extreme
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The arcnet drivers were calling the BUGMSG() macro from arcnet.h before
calling register_netdev.  The BUGMSG() macro was using the name field
from struct net_device, but this isn't filled out yet, yielding kernel
log prints starting with "arc%d".  This changes the drivers to use dev_warn
and dev_info before register_netdev is called to fill out the net_device
name.  For what it is worth, I've retained the old log levels.

Signed-off-by: Dan Noe <dpn@isomerica.net>
---
 drivers/net/arcnet/arc-rimi.c     |   18 +++++++++---------
 drivers/net/arcnet/com20020-isa.c |   12 ++++++------
 drivers/net/arcnet/com20020-pci.c |    8 ++++----
 drivers/net/arcnet/com20020.c     |   10 +++++-----
 drivers/net/arcnet/com90io.c      |   20 ++++++++++----------
 drivers/net/arcnet/com90xx.c      |    6 +++---
 6 files changed, 37 insertions(+), 37 deletions(-)

Can the original poster please try this and report back?
I don't have any ARCnet hardware.  If it works to your satisfaction
I will submit it.

Cheers,
Dan

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 8c8d6c4..29f8dd9 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -89,16 +89,16 @@ static int __init arcrimi_probe(struct net_device *dev)
 	BUGLVL(D_NORMAL) printk(VERSION);
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test the RIM I driver, please!\n");
 
-	BUGMSG(D_NORMAL, "Given: node %02Xh, shmem %lXh, irq %d\n",
+	dev_warn(&dev->dev, "Given: node %02Xh, shmem %lXh, irq %d\n",
 	       dev->dev_addr[0], dev->mem_start, dev->irq);
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
-		BUGMSG(D_NORMAL, "No autoprobe for RIM I; you "
+		dev_warn(&dev->dev, "No autoprobe for RIM I; you "
 		       "must specify the shmem and irq!\n");
 		return -ENODEV;
 	}
 	if (dev->dev_addr[0] == 0) {
-		BUGMSG(D_NORMAL, "You need to specify your card's station "
+		dev_warn(&dev->dev, "You need to specify your card's station "
 		       "ID!\n");
 		return -ENODEV;
 	}
@@ -109,7 +109,7 @@ static int __init arcrimi_probe(struct net_device *dev)
 	 * will be taken.
 	 */
 	if (!request_mem_region(dev->mem_start, MIRROR_SIZE, "arcnet (90xx)")) {
-		BUGMSG(D_NORMAL, "Card memory already allocated\n");
+		dev_warn(&dev->dev, "Card memory already allocated\n");
 		return -ENODEV;
 	}
 	return arcrimi_found(dev);
@@ -151,7 +151,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	p = ioremap(dev->mem_start, MIRROR_SIZE);
 	if (!p) {
 		release_mem_region(dev->mem_start, MIRROR_SIZE);
-		BUGMSG(D_NORMAL, "Can't ioremap\n");
+		dev_warn(&dev->dev, "Can't ioremap\n");
 		return -ENODEV;
 	}
 
@@ -159,7 +159,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	if (request_irq(dev->irq, &arcnet_interrupt, 0, "arcnet (RIM I)", dev)) {
 		iounmap(p);
 		release_mem_region(dev->mem_start, MIRROR_SIZE);
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		dev_warn(&dev->dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 
@@ -215,20 +215,20 @@ static int __init arcrimi_found(struct net_device *dev)
 	if (!request_mem_region(dev->mem_start,
 				dev->mem_end - dev->mem_start + 1,
 				"arcnet (90xx)")) {
-		BUGMSG(D_NORMAL, "Card memory already allocated\n");
+		dev_warn(&dev->dev, "Card memory already allocated\n");
 		goto err_free_irq;
 	}
 
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
-		BUGMSG(D_NORMAL, "Can't remap device memory!\n");
+		dev_warn(&dev->dev, "Can't remap device memory!\n");
 		goto err_release_mem;
 	}
 
 	/* get and check the station ID from offset 1 in shmem */
 	dev->dev_addr[0] = readb(lp->mem_start + 1);
 
-	BUGMSG(D_NORMAL, "ARCnet RIM I: station %02Xh found at IRQ %d, "
+	dev_warn(&dev->dev, "ARCnet RIM I: station %02Xh found at IRQ %d, "
 	       "ShMem %lXh (%ld*%d bytes).\n",
 	       dev->dev_addr[0],
 	       dev->irq, dev->mem_start,
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 9289e61..0577ae7 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -59,17 +59,17 @@ static int __init com20020isa_probe(struct net_device *dev)
 
 	ioaddr = dev->base_addr;
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe (yet) for IO mapped cards; you "
+		dev_warn(&dev-dev, "No autoprobe (yet) for IO mapped cards; you "
 		       "must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "arcnet (COM20020)")) {
-		BUGMSG(D_NORMAL, "IO region %xh-%xh already allocated.\n",
+		dev_warn(&dev->dev, "IO region %xh-%xh already allocated.\n",
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
 	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_NORMAL, "IO address %x empty\n", ioaddr);
+		dev_warn(&dev-dev, "IO address %x empty\n", ioaddr);
 		err = -ENODEV;
 		goto out;
 	}
@@ -83,7 +83,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 		 * card has just reset and the NORXflag is on until
 		 * we tell it to start receiving.
 		 */
-		BUGMSG(D_INIT_REASONS, "intmask was %02Xh\n", inb(_INTMASK));
+		dev_info(&dev->dev, "intmask was %02Xh\n", inb(_INTMASK));
 		outb(0, _INTMASK);
 		airqmask = probe_irq_on();
 		outb(NORXflag, _INTMASK);
@@ -92,14 +92,14 @@ static int __init com20020isa_probe(struct net_device *dev)
 		dev->irq = probe_irq_off(airqmask);
 
 		if (dev->irq <= 0) {
-			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed first time\n");
+			dev_info(&dev->dev, "Autoprobe IRQ failed first time\n");
 			airqmask = probe_irq_on();
 			outb(NORXflag, _INTMASK);
 			udelay(5);
 			outb(0, _INTMASK);
 			dev->irq = probe_irq_off(airqmask);
 			if (dev->irq <= 0) {
-				BUGMSG(D_NORMAL, "Autoprobe IRQ failed.\n");
+				dev_info(&dev->dev, "Autoprobe IRQ failed.\n");
 				err = -ENODEV;
 				goto out;
 			}
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index b8c0fa6..9a820fa 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -78,16 +78,16 @@ static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_de
 
 	// SOHARD needs PCI base addr 4
 	if (pdev->vendor==0x10B5) {
-		BUGMSG(D_NORMAL, "SOHARD\n");
+		dev_warn(&dev->dev, "SOHARD\n");
 		ioaddr = pci_resource_start(pdev, 4);
 	}
 	else {
-		BUGMSG(D_NORMAL, "Contemporary Controls\n");
+		dev_warn(&dev->dev, "Contemporary Controls\n");
 		ioaddr = pci_resource_start(pdev, 2);
 	}
 
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com20020-pci")) {
-		BUGMSG(D_INIT, "IO region %xh-%xh already allocated.\n",
+		dev_warn(&dev->dev, "IO region %xh-%xh already allocated.\n",
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		err = -EBUSY;
 		goto out_dev;
@@ -110,7 +110,7 @@ static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_de
 	lp->hw.owner = THIS_MODULE;
 
 	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_NORMAL, "IO address %Xh was reported by PCI BIOS, "
+		dev_warn(&dev->dev, "IO address %Xh was reported by PCI BIOS, "
 		       "but seems empty!\n", ioaddr);
 		err = -EIO;
 		goto out_port;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 7cf0a25..ab7f80a 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -196,22 +196,22 @@ int com20020_found(struct net_device *dev, int shared)
 	/* reserve the irq */
 	if (request_irq(dev->irq, &arcnet_interrupt, shared,
 			"arcnet (COM20020)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		dev_warn(&dev->dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 
 	dev->base_addr = ioaddr;
 
-	BUGMSG(D_NORMAL, "%s: station %02Xh found at %03lXh, IRQ %d.\n",
+	dev_warn(&dev->dev, "%s: station %02Xh found at %03lXh, IRQ %d.\n",
 	       lp->card_name, dev->dev_addr[0], dev->base_addr, dev->irq);
 
 	if (lp->backplane)
-		BUGMSG(D_NORMAL, "Using backplane mode.\n");
+		dev_warn(&dev->dev, "Using backplane mode.\n");
 
 	if (lp->timeout != 3)
-		BUGMSG(D_NORMAL, "Using extended timeout value of %d.\n", lp->timeout);
+		dev_warn(&dev->dev, "Using extended timeout value of %d.\n", lp->timeout);
 
-	BUGMSG(D_NORMAL, "Using CKP %d - data rate %s.\n",
+	dev_warn(&dev->dev, "Using CKP %d - data rate %s.\n",
 	       lp->setup >> 1, 
 	       clockrates[3 - ((lp->setup2 & 0xF0) >> 4) + ((lp->setup & 0x0F) >> 1)]);
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 6599f10..3405c68 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -155,17 +155,17 @@ static int __init com90io_probe(struct net_device *dev)
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test this driver, please!\n");
 
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe for IO mapped cards; you "
+		dev_warn(&dev->dev, "No autoprobe for IO mapped cards; you "
 		       "must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com90io probe")) {
-		BUGMSG(D_INIT_REASONS, "IO request_region %x-%x failed.\n",
+		dev_info(&dev->dev, "IO request_region %x-%x failed.\n",
 		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
 		return -ENXIO;
 	}
 	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_INIT_REASONS, "IO address %x empty\n", ioaddr);
+		dev_info(&dev->dev, "IO address %x empty\n", ioaddr);
 		goto err_out;
 	}
 	inb(_RESET);
@@ -174,19 +174,19 @@ static int __init com90io_probe(struct net_device *dev)
 	status = ASTATUS();
 
 	if ((status & 0x9D) != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
-		BUGMSG(D_INIT_REASONS, "Status invalid (%Xh).\n", status);
+		dev_info(&dev->dev, "Status invalid (%Xh).\n", status);
 		goto err_out;
 	}
-	BUGMSG(D_INIT_REASONS, "Status after reset: %X\n", status);
+	dev_info(&dev->dev, "Status after reset: %X\n", status);
 
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
-	BUGMSG(D_INIT_REASONS, "Status after reset acknowledged: %X\n", status);
+	dev_info(&dev->dev, "Status after reset acknowledged: %X\n", status);
 
 	status = ASTATUS();
 
 	if (status & RESETflag) {
-		BUGMSG(D_INIT_REASONS, "Eternal reset (status=%Xh)\n", status);
+		dev_info(&dev->dev, "Eternal reset (status=%Xh)\n", status);
 		goto err_out;
 	}
 	outb((0x16 | IOMAPflag) & ~ENABLE16flag, _CONFIG);
@@ -197,7 +197,7 @@ static int __init com90io_probe(struct net_device *dev)
 	outb(0, _ADDR_LO);
 
 	if ((status = inb(_MEMDATA)) != 0xd1) {
-		BUGMSG(D_INIT_REASONS, "Signature byte not found"
+		dev_info(&dev->dev, "Signature byte not found"
 		       " (%Xh instead).\n", status);
 		goto err_out;
 	}
@@ -215,7 +215,7 @@ static int __init com90io_probe(struct net_device *dev)
 		dev->irq = probe_irq_off(airqmask);
 
 		if (dev->irq <= 0) {
-			BUGMSG(D_INIT_REASONS, "Autoprobe IRQ failed\n");
+			dev_info(&dev->dev, "Autoprobe IRQ failed\n");
 			goto err_out;
 		}
 	}
@@ -239,7 +239,7 @@ static int __init com90io_found(struct net_device *dev)
 
 	/* Reserve the irq */
 	if (request_irq(dev->irq, &arcnet_interrupt, 0, "arcnet (COM90xx-IO)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
+		dev_warn(&dev->dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 	/* Reserve the I/O region */
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 0d45553..5a48013 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -502,7 +502,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 
 	/* reserve the irq */
 	if (request_irq(airq, &arcnet_interrupt, 0, "arcnet (90xx)", dev)) {
-		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", airq);
+		dev_warn(&dev->dev, "Can't get IRQ %d!\n", airq);
 		goto err_release_mem;
 	}
 	dev->irq = airq;
@@ -518,7 +518,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	lp->hw.copy_from_card = com90xx_copy_from_card;
 	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
-		BUGMSG(D_NORMAL, "Can't remap device memory!\n");
+		dev_warn(&dev->dev, "Can't remap device memory!\n");
 		goto err_free_irq;
 	}
 
@@ -527,7 +527,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 
 	dev->base_addr = ioaddr;
 
-	BUGMSG(D_NORMAL, "COM90xx station %02Xh found at %03lXh, IRQ %d, "
+	dev_warn(&dev->dev, "COM90xx station %02Xh found at %03lXh, IRQ %d, "
 	       "ShMem %lXh (%ld*%xh).\n",
 	       dev->dev_addr[0],
 	       dev->base_addr, dev->irq, dev->mem_start,
-- 
1.5.2.5

