From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 7/15] wireless/orinoco: Update card reset/init
	code and add card-specific data structures
Date: Tue, 26 Oct 2004 14:56:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098816980.3663.62.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o Update card reset/init code and add card-specific data structures.
    Also bind to Samsung MagicLAN SWL-2210P cards. 

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco_pci.c.7-card-data	2004-10-26 09:52:07.125216864 -0400
+++ b/drivers/net/wireless/orinoco_pci.c	2004-10-26 10:00:36.855726048 -0400
@@ -129,6 +129,11 @@
 #define HERMES_PCI_COR_OFFT	(500)		/* ms */
 #define HERMES_PCI_COR_BUSYT	(500)		/* ms */
 
+/* Orinoco PCI specific data */
+struct orinoco_pci_card {
+	u32 pci_state[16];	/* PCI suspend/resume state */
+};
+
 /*
  * Do a soft reset of the PCI card using the Configuration Option Register
  * We need this to get going...
@@ -151,25 +156,15 @@
 
 	/* Assert the reset until the card notice */
 	hermes_write_regn(hw, PCI_COR, HERMES_PCI_COR_MASK);
-	printk(KERN_NOTICE "Reset done");
 	timeout = jiffies + (HERMES_PCI_COR_ONT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		printk(".");
+	while(time_before(jiffies, timeout))
 		mdelay(1);
-	}
-	printk(";\n");
-	//mdelay(HERMES_PCI_COR_ONT);
 
 	/* Give time for the card to recover from this hard effort */
 	hermes_write_regn(hw, PCI_COR, 0x0000);
-	printk(KERN_NOTICE "Clear Reset");
 	timeout = jiffies + (HERMES_PCI_COR_OFFT * HZ / 1000);
-	while(time_before(jiffies, timeout)) {
-		printk(".");
+	while(time_before(jiffies, timeout))
 		mdelay(1);
-	}
-	printk(";\n");
-	//mdelay(HERMES_PCI_COR_OFFT);
 
 	/* The card is ready when it's no longer busy */
 	timeout = jiffies + (HERMES_PCI_COR_BUSYT * HZ / 1000);
@@ -178,12 +173,12 @@
 		mdelay(1);
 		reg = hermes_read_regn(hw, CMD);
 	}
-	/* Did we timeout ? */
-	if(time_after_eq(jiffies, timeout)) {
+
+	/* Still busy? */
+	if (reg & HERMES_CMD_BUSY) {
 		printk(KERN_ERR PFX "Busy timeout\n");
 		return -ETIMEDOUT;
 	}
-	printk(KERN_NOTICE "pci_cor : reg = 0x%X - %lX - %lX\n", reg, timeout, jiffies);
 
 	return 0;
 }
@@ -199,61 +194,68 @@
 	u16 *pci_ioaddr = NULL;
 	unsigned long pci_iolen;
 	struct orinoco_private *priv = NULL;
+	struct orinoco_pci_card *card;
 	struct net_device *dev = NULL;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return -err;
+	}
+
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
+	}
 
 	/* Resource 0 is mapped to the hermes registers */
 	pci_iorange = pci_resource_start(pdev, 0);
 	pci_iolen = pci_resource_len(pdev, 0);
 	pci_ioaddr = ioremap(pci_iorange, pci_iolen);
-	if (! pci_iorange)
-		goto fail;
+	if (!pci_iorange) {
+		printk(KERN_ERR PFX "Cannot remap hardware registers\n");
+		goto fail_map;
+	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
+	dev = alloc_orinocodev(sizeof(*card), orinoco_pci_cor_reset);
 	if (! dev) {
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
-	dev->base_addr = (unsigned long) pci_ioaddr;
+	card = priv->card;
 	dev->mem_start = pci_iorange;
 	dev->mem_end = pci_iorange + pci_iolen - 1;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	printk(KERN_DEBUG PFX
-	       "Detected Orinoco/Prism2 PCI device at %s, mem:0x%lX to 0x%lX -> 0x%p, irq:%d\n",
-	       pci_name(pdev), dev->mem_start, dev->mem_end, pci_ioaddr, pdev->irq);
-
-	hermes_struct_init(&priv->hw, dev->base_addr,
+	hermes_struct_init(&priv->hw, (unsigned long) pci_ioaddr,
 			   HERMES_MEM, HERMES_32BIT_REGSPACING);
 	pci_set_drvdata(pdev, dev);
 
+	printk(KERN_DEBUG PFX "Detected PCI device %s, memory 0x%lx-0x%lx, "
+	       "irq %d\n", pci_name(pdev), dev->mem_start, dev->mem_end,
+	       pdev->irq);
+
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
 	/* Perform a COR reset to start the card */
-	if(orinoco_pci_cor_reset(priv) != 0) {
-		printk(KERN_ERR "%s: Failed to start the card\n", dev->name);
-		err = -ETIMEDOUT;
+	err = orinoco_pci_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
 		goto fail;
 	}
 
-	/* Override the normal firmware detection - the Prism 2.5 PCI
-	 * cards look like Lucent firmware but are actually Intersil */
-	priv->firmware_type = FIRMWARE_TYPE_INTERSIL;
-
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Failed to register net device\n");
@@ -263,16 +265,19 @@
 	return 0;
 
  fail:
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
-		free_orinocodev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
 
-	if (pci_ioaddr)
-		iounmap(pci_ioaddr);
+ fail_alloc:
+	iounmap(pci_ioaddr);
 
+ fail_map:
+	pci_release_regions(pdev);
+
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -282,18 +287,14 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct orinoco_private *priv = netdev_priv(dev);
+	void *pci_ioaddr = (void *) priv->hw.iobase;
 
 	unregister_netdev(dev);
-
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-
-	if (priv->hw.iobase)
-		iounmap((unsigned char *) priv->hw.iobase);
-
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-
 	free_orinocodev(dev);
+	iounmap(pci_ioaddr);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -301,6 +302,7 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct orinoco_private *priv = netdev_priv(dev);
+	struct orinoco_pci_card *card = priv->card;
 	unsigned long flags;
 	int err;
 	
@@ -325,6 +327,9 @@
 	
 	orinoco_unlock(priv, &flags);
 
+	pci_save_state(pdev, card->pci_state);
+	pci_set_power_state(pdev, 3);
+
 	return 0;
 }
 
@@ -332,11 +337,15 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct orinoco_private *priv = netdev_priv(dev);
+	struct orinoco_pci_card *card = priv->card;
 	unsigned long flags;
 	int err;
 
 	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
 
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev, card->pci_state);
+
 	err = orinoco_reinit_firmware(dev);
 	if (err) {
 		printk(KERN_ERR "%s: Error %d re-initializing firmware on orinoco_pci_resume()\n",
@@ -367,6 +376,8 @@
 	{0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Intersil Prism 2.5 */
 	{0x1260, 0x3873, PCI_ANY_ID, PCI_ANY_ID,},
+	/* Samsung MagicLAN SWL-2210P */
+	{0x167d, 0xa000, PCI_ANY_ID, PCI_ANY_ID,},
 	{0,},
 };
 
--- a/drivers/net/wireless/orinoco_plx.c.7-card-data	2004-10-26 09:52:13.354269904 -0400
+++ b/drivers/net/wireless/orinoco_plx.c	2004-10-26 10:07:51.854596168 -0400
@@ -142,146 +142,189 @@
 #include "hermes.h"
 #include "orinoco.h"
 
-#define COR_OFFSET	(0x3e0/2) /* COR attribute offset of Prism2 PC card */
+#define COR_OFFSET	(0x3e0)	/* COR attribute offset of Prism2 PC card */
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
+#define COR_RESET     (0x80)	/* reset bit in the COR register */
+#define PLX_RESET_TIME	(500)	/* milliseconds */
 
 #define PLX_INTCSR		0x4c /* Interrupt Control & Status Register */
 #define PLX_INTCSR_INTEN	(1<<6) /* Interrupt Enable bit */
 
-static const u16 cis_magic[] = {
-	0x0001, 0x0003, 0x0000, 0x0000, 0x00ff, 0x0017, 0x0004, 0x0067
+static const u8 cis_magic[] = {
+	0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
 };
 
+/* Orinoco PLX specific data */
+struct orinoco_plx_card {
+	u8 *attr_mem;
+};
+
+/*
+ * Do a soft reset of the card using the Configuration Option Register
+ */
+static int orinoco_plx_cor_reset(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	struct orinoco_plx_card *card = priv->card;
+	u8 *attr_mem = card->attr_mem;
+	unsigned long timeout;
+	u16 reg;
+
+	attr_mem[COR_OFFSET] = COR_VALUE | COR_RESET;
+	mdelay(1);
+
+	attr_mem[COR_OFFSET] = COR_VALUE;
+	mdelay(1);
+
+	/* Just in case, wait more until the card is no longer busy */
+	timeout = jiffies + (PLX_RESET_TIME * HZ / 1000);
+	reg = hermes_read_regn(hw, CMD);
+	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
+		mdelay(1);
+		reg = hermes_read_regn(hw, CMD);
+	}
+
+	/* Did we timeout ? */
+	if (reg & HERMES_CMD_BUSY) {
+		printk(KERN_ERR PFX "Busy timeout\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+
 static int orinoco_plx_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	int err = 0;
-	u16 *attr_mem = NULL;
-	u32 reg, addr;
+	u8 *attr_mem = NULL;
+	u32 csr_reg, plx_addr;
 	struct orinoco_private *priv = NULL;
+	struct orinoco_plx_card *card;
 	unsigned long pccard_ioaddr = 0;
 	unsigned long pccard_iolen = 0;
 	struct net_device *dev = NULL;
 	int i;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
-
-	/* Resource 2 is mapped to the PCMCIA space */
-	attr_mem = ioremap(pci_resource_start(pdev, 2), PAGE_SIZE);
-	if (! attr_mem)
-		goto fail;
-
-	printk(KERN_DEBUG "orinoco_plx: CIS: ");
-	for (i = 0; i < 16; i++) {
-		printk("%02X:", (int)attr_mem[i]);
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return -err;
 	}
-	printk("\n");
 
-	/* Verify whether PC card is present */
-	/* FIXME: we probably need to be smarted about this */
-	if (memcmp(attr_mem, cis_magic, sizeof(cis_magic)) != 0) {
-		printk(KERN_ERR "orinoco_plx: The CIS value of Prism2 PC card is invalid.\n");
-		err = -EIO;
-		goto fail;
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
 	}
 
-	/* PCMCIA COR is the first byte following CIS: this write should
-	 * enable I/O mode and select level-triggered interrupts */
-	attr_mem[COR_OFFSET] = COR_VALUE;
-	mdelay(1);
-	reg = attr_mem[COR_OFFSET];
-	if (reg != COR_VALUE) {
-		printk(KERN_ERR "orinoco_plx: Error setting COR value (reg=%x)\n", reg);
-		goto fail;
-	}			
+	/* Resource 1 is mapped to PLX-specific registers */
+	plx_addr = pci_resource_start(pdev, 1);
 
-	iounmap(attr_mem);
-	attr_mem = NULL; /* done with this now, it seems */
-
-	/* bjoern: We need to tell the card to enable interrupts, in
-	   case the serial eprom didn't do this already. See the
-	   PLX9052 data book, p8-1 and 8-24 for reference. */
-	addr = pci_resource_start(pdev, 1);
-	reg = 0;
-	reg = inl(addr+PLX_INTCSR);
-	if (reg & PLX_INTCSR_INTEN)
-		printk(KERN_DEBUG "orinoco_plx: "
-		       "Local Interrupt already enabled\n");
-	else {
-		reg |= PLX_INTCSR_INTEN;
-		outl(reg, addr+PLX_INTCSR);
-		reg = inl(addr+PLX_INTCSR);
-		if(!(reg & PLX_INTCSR_INTEN)) {
-			printk(KERN_ERR "orinoco_plx: "
-			       "Couldn't enable Local Interrupts\n");
-			goto fail;
-		}
+	/* Resource 2 is mapped to the PCMCIA attribute memory */
+	attr_mem = ioremap(pci_resource_start(pdev, 2),
+			   pci_resource_len(pdev, 2));
+	if (!attr_mem) {
+		printk(KERN_ERR PFX "Cannot remap PCMCIA space\n");
+		goto fail_map;
 	}
 
-	/* and 3 to the PCMCIA slot I/O address space */
+	/* Resource 3 is mapped to the PCMCIA I/O address space */
 	pccard_ioaddr = pci_resource_start(pdev, 3);
 	pccard_iolen = pci_resource_len(pdev, 3);
-	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
-		printk(KERN_ERR "orinoco_plx: I/O resource 0x%lx @ 0x%lx busy\n",
-		       pccard_iolen, pccard_ioaddr);
-		pccard_ioaddr = 0;
-		err = -EBUSY;
-		goto fail;
-	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
-	if (! dev) {
+	dev = alloc_orinocodev(sizeof(*card), orinoco_plx_cor_reset);
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
+	card = priv->card;
+	card->attr_mem = attr_mem;
 	dev->base_addr = pccard_ioaddr;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 PLX device "
-	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
-	       pccard_ioaddr);
-
 	hermes_struct_init(&(priv->hw), dev->base_addr, HERMES_IO,
 			   HERMES_16BIT_REGSPACING);
 	pci_set_drvdata(pdev, dev);
 
+	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 PLX device "
+	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
+	       pccard_ioaddr);
+
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n", pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
+	/* bjoern: We need to tell the card to enable interrupts, in
+	   case the serial eprom didn't do this already.  See the
+	   PLX9052 data book, p8-1 and 8-24 for reference. */
+	csr_reg = inl(plx_addr + PLX_INTCSR);
+	if (!(csr_reg & PLX_INTCSR_INTEN)) {
+		csr_reg |= PLX_INTCSR_INTEN;
+		outl(csr_reg, plx_addr + PLX_INTCSR);
+		csr_reg = inl(plx_addr + PLX_INTCSR);
+		if (!(csr_reg & PLX_INTCSR_INTEN)) {
+			printk(KERN_ERR PFX "Cannot enable interrupts\n");
+			goto fail;
+		}
+	}
+
+	err = orinoco_plx_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
+		goto fail;
+	}
+
+	printk(KERN_DEBUG PFX "CIS: ");
+	for (i = 0; i < 16; i++) {
+		printk("%02X:", attr_mem[2 * i]);
+	}
+	printk("\n");
+
+	/* Verify whether a supported PC card is present */
+	/* FIXME: we probably need to be smarted about this */
+	for (i = 0; i < sizeof(cis_magic); i++) {
+		if (cis_magic[i] != attr_mem[2 * i]) {
+			printk(KERN_ERR PFX "The CIS value of Prism2 PC "
+			       "card is unexpected\n");
+			err = -EIO;
+			goto fail;
+		}
+	}
+
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
+	}
 
 	return 0;
 
  fail:
-	printk(KERN_DEBUG PFX "init_one(), FAIL!\n");
+	free_irq(pdev->irq, dev);
 
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
-		
-		free_orinocodev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
 
-	if (pccard_ioaddr)
-		release_region(pccard_ioaddr, pccard_iolen);
+ fail_alloc:
+	iounmap(attr_mem);
 
-	if (attr_mem)
-		iounmap(attr_mem);
+ fail_map:
+	pci_release_regions(pdev);
 
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -290,19 +333,18 @@
 static void __devexit orinoco_plx_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct orinoco_plx_card *card = priv->card;
+	u8 *attr_mem = card->attr_mem;
 
 	BUG_ON(! dev);
 
 	unregister_netdev(dev);
-		
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-		
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-
-	release_region(pci_resource_start(pdev, 3), pci_resource_len(pdev, 3));
-
 	free_orinocodev(dev);
+	iounmap(attr_mem);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -332,6 +374,8 @@
 	.id_table	= orinoco_plx_pci_id_table,
 	.probe		= orinoco_plx_init_one,
 	.remove		= __devexit_p(orinoco_plx_remove_one),
+	.suspend	= 0,
+	.resume		= 0,
 };
 
 static char version[] __initdata = DRIVER_NAME " " DRIVER_VERSION
--- a/drivers/net/wireless/orinoco_tmd.c.7-card-data	2004-10-26 09:52:19.009410192 -0400
+++ b/drivers/net/wireless/orinoco_tmd.c	2004-10-26 10:15:59.469467440 -0400
@@ -79,90 +79,127 @@
 #include "orinoco.h"
 
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
+#define COR_RESET     (0x80)	/* reset bit in the COR register */
+#define TMD_RESET_TIME	(500)	/* milliseconds */
+
+/* Orinoco TMD specific data */
+struct orinoco_tmd_card {
+	u32 tmd_io;
+};
+
+
+/*
+ * Do a soft reset of the card using the Configuration Option Register
+ */
+static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
+{
+	hermes_t *hw = &priv->hw;
+	struct orinoco_tmd_card *card = priv->card;
+	u32 addr = card->tmd_io;
+	unsigned long timeout;
+	u16 reg;
+
+	outb(COR_VALUE | COR_RESET, addr);
+	mdelay(1);
+
+	outb(COR_VALUE, addr);
+	mdelay(1);
+
+	/* Just in case, wait more until the card is no longer busy */
+	timeout = jiffies + (TMD_RESET_TIME * HZ / 1000);
+	reg = hermes_read_regn(hw, CMD);
+	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
+		mdelay(1);
+		reg = hermes_read_regn(hw, CMD);
+	}
+
+	/* Did we timeout ? */
+	if (reg & HERMES_CMD_BUSY) {
+		printk(KERN_ERR PFX "Busy timeout\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
 
 static int orinoco_tmd_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	int err = 0;
-	u32 reg, addr;
 	struct orinoco_private *priv = NULL;
-	unsigned long pccard_ioaddr = 0;
-	unsigned long pccard_iolen = 0;
+	struct orinoco_tmd_card *card;
 	struct net_device *dev = NULL;
 
 	err = pci_enable_device(pdev);
-	if (err)
-		return -EIO;
-
-	printk(KERN_DEBUG PFX "TMD setup\n");
-	pccard_ioaddr = pci_resource_start(pdev, 2);
-	pccard_iolen = pci_resource_len(pdev, 2);
-	if (! request_region(pccard_ioaddr, pccard_iolen, DRIVER_NAME)) {
-		printk(KERN_ERR PFX "I/O resource at 0x%lx len 0x%lx busy\n",
-			pccard_ioaddr, pccard_iolen);
-		pccard_ioaddr = 0;
-		err = -EBUSY;
-		goto fail;
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return -err;
 	}
-	addr = pci_resource_start(pdev, 1);
-	outb(COR_VALUE, addr);
-	mdelay(1);
-	reg = inb(addr);
-	if (reg != COR_VALUE) {
-		printk(KERN_ERR PFX "Error setting TMD COR values %x should be %x\n", reg, COR_VALUE);
-		err = -EIO;
-		goto fail;
+
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
 	}
 
 	/* Allocate network device */
-	dev = alloc_orinocodev(0, NULL);
+	dev = alloc_orinocodev(sizeof(*card), orinoco_tmd_cor_reset);
 	if (! dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err = -ENOMEM;
-		goto fail;
+		goto fail_alloc;
 	}
 
 	priv = netdev_priv(dev);
-	dev->base_addr = pccard_ioaddr;
+	card = priv->card;
+	card->tmd_io = pci_resource_start(pdev, 1);
+	dev->base_addr = pci_resource_start(pdev, 2);
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 TMD device "
-	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
-	       pccard_ioaddr);
-
 	hermes_struct_init(&(priv->hw), dev->base_addr,
 			HERMES_IO, HERMES_16BIT_REGSPACING);
 	pci_set_drvdata(pdev, dev);
 
+	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 TMD device "
+	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
+	       dev->base_addr);
+
 	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
-		printk(KERN_ERR PFX "Error allocating IRQ %d.\n",
-		       pdev->irq);
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
 		err = -EBUSY;
-		goto fail;
+		goto fail_irq;
 	}
 	dev->irq = pdev->irq;
 
+	err = orinoco_tmd_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
+		goto fail;
+	}
+
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
+	}
 
 	return 0;
 
  fail:
-	printk(KERN_DEBUG PFX "init_one(), FAIL!\n");
+	free_irq(pdev->irq, dev);
 
-	if (dev) {
-		if (dev->irq)
-			free_irq(dev->irq, dev);
-		
-		free_orinocodev(dev);
-	}
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
 
-	if (pccard_ioaddr)
-		release_region(pccard_ioaddr, pccard_iolen);
+ fail_alloc:
+	pci_release_regions(pdev);
 
+ fail_resources:
 	pci_disable_device(pdev);
 
 	return err;
@@ -175,15 +212,10 @@
 	BUG_ON(! dev);
 
 	unregister_netdev(dev);
-		
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-		
+	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
-
-	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
-
 	free_orinocodev(dev);
+	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 }
 
@@ -200,6 +232,8 @@
 	.id_table	= orinoco_tmd_pci_id_table,
 	.probe		= orinoco_tmd_init_one,
 	.remove		= __devexit_p(orinoco_tmd_remove_one),
+	.suspend	= 0,
+	.resume		= 0,
 };
 
 static char version[] __initdata = DRIVER_NAME " " DRIVER_VERSION
