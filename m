From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (30/42) jazzsonic
Date: Wed, 12 Nov 2003 16:45:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0jIu31152@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE55-jazzsonic
	* switched jazzsonic to dynamic allocation
	* jazzsonic: fixed resource leaks on failure exits

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:15:38 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:15:38 2003
@@ -70,7 +70,7 @@
 extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
-extern int sonic_probe(struct net_device *);
+extern struct net_device *sonic_probe(int unit);
 extern struct net_device *SK_init(int unit);
 extern struct net_device *seeq8005_probe(int unit);
 extern struct net_device *smc_init(int unit);
@@ -335,14 +335,10 @@
 	{NULL, 0},
 };
 
-static struct devprobe mips_probes[] __initdata = {
+static struct devprobe2 mips_probes[] __initdata = {
 #ifdef CONFIG_MIPS_JAZZ_SONIC
 	{sonic_probe, 0},
 #endif
-	{NULL, 0},
-};
-
-static struct devprobe2 mips_probes2[] __initdata = {
 #ifdef CONFIG_BAGETLANCE        /* Lance-based Baget ethernet boards */
         {bagetlance_probe, 0},
 #endif
@@ -379,8 +375,7 @@
 	 * The arch specific probes are 1st so that any on-board ethernet
 	 * will be probed before other ISA/EISA/MCA/PCI bus cards.
 	 */
-	if (probe_list(dev, m68k_probes) == 0 ||
-	    probe_list(dev, mips_probes) == 0)
+	if (probe_list(dev, m68k_probes) == 0)
 		err = register_netdev(dev);
 
 	if (err)
@@ -396,7 +391,7 @@
 	if (base_addr == 1)
 		return;
 
-	probe_list2(unit, mips_probes2, base_addr == 0) &&
+	probe_list2(unit, mips_probes, base_addr == 0) &&
 	probe_list2(unit, eisa_probes, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
 	probe_list2(unit, isa_probes, base_addr == 0) &&
diff -Nru a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
--- a/drivers/net/jazzsonic.c	Tue Nov 11 14:15:38 2003
+++ b/drivers/net/jazzsonic.c	Tue Nov 11 14:15:38 2003
@@ -80,7 +80,6 @@
 
 /* Index to functions, as function prototypes. */
 
-extern int sonic_probe(struct net_device *dev);
 static int sonic_probe1(struct net_device *dev, unsigned int base_addr,
                         unsigned int irq);
 
@@ -89,29 +88,57 @@
  * Probe for a SONIC ethernet controller on a Mips Jazz board.
  * Actually probing is superfluous but we're paranoid.
  */
-int __init sonic_probe(struct net_device *dev)
+struct net_device * __init sonic_probe(int unit)
 {
-	unsigned int base_addr = dev ? dev->base_addr : 0;
+	struct net_device *dev;
+	struct sonic_local *lp;
+	unsigned int base_addr;
+	int err = 0;
 	int i;
 
 	/*
 	 * Don't probe if we're not running on a Jazz board.
 	 */
 	if (mips_machgroup != MACH_GROUP_JAZZ)
-		return -ENODEV;
-	if (base_addr >= KSEG0)	/* Check a single specified location. */
-		return sonic_probe1(dev, base_addr, dev->irq);
-	else if (base_addr != 0)	/* Don't probe at all. */
-		return -ENXIO;
-
-	for (i = 0; sonic_portlist[i].port; i++) {
-		int base_addr = sonic_portlist[i].port;
-		if (check_region(base_addr, 0x100))
-			continue;
-		if (sonic_probe1(dev, base_addr, sonic_portlist[i].irq) == 0)
-			return 0;
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(0);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
+	base_addr = dev->base_addr;
+
+	if (base_addr >= KSEG0)	{ /* Check a single specified location. */
+		err = sonic_probe1(dev, base_addr, dev->irq);
+	} else if (base_addr != 0) { /* Don't probe at all. */
+		err = -ENXIO;
+	} else {
+		for (i = 0; sonic_portlist[i].port; i++) {
+			int io = sonic_portlist[i].port;
+			if (sonic_probe1(dev, io, sonic_portlist[i].irq) == 0)
+				break;
+		}
+		if (!sonic_portlist[i].port)
+			err = -ENODEV;
 	}
-	return -ENODEV;
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	lp = dev->priv;
+	vdma_free(lp->rba_laddr);
+	kfree(lp->rba);
+	vdma_free(lp->cda_laddr);
+	kfree(lp);
+	release_region(dev->base_addr, 0x100);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 static int __init sonic_probe1(struct net_device *dev, unsigned int base_addr,
@@ -121,8 +148,11 @@
 	unsigned int silicon_revision;
 	unsigned int val;
 	struct sonic_local *lp;
+	int err = -ENODEV;
 	int i;
 
+	if (!request_region(base_addr, 0x100, dev->name))
+		return -EBUSY;
 	/*
 	 * get the Silicon Revision ID. If this is one of the known
 	 * one assume that we found a SONIC ethernet controller at
@@ -140,12 +170,9 @@
 	if (known_revisions[i] == 0xffff) {
 		printk("SONIC ethernet controller not found (0x%4x)\n",
 		       silicon_revision);
-		return -ENODEV;
+		goto out;
 	}
     
-	if (!request_region(base_addr, 0x100, dev->name))
-		return -EBUSY;
-
 	if (sonic_debug  &&  version_printed++ == 0)
 		printk(version);
 
@@ -175,6 +202,8 @@
 	}
 
 	printk(" IRQ %d\n", irq);
+
+	err = -ENOMEM;
     
 	/* Initialize the device structure. */
 	if (dev->priv == NULL) {
@@ -196,7 +225,7 @@
 		if (lp == NULL) {
 			printk("%s: couldn't allocate memory for descriptors\n",
 			       dev->name);
-			return -ENOMEM;
+			goto out;
 		}
 
 		memset(lp, 0, sizeof(struct sonic_local));
@@ -206,7 +235,7 @@
 		if (lp->cda_laddr == ~0UL) {
 			printk("%s: couldn't get DMA page entry for "
 			       "descriptors\n", dev->name);
-			return -ENOMEM;
+			goto out1;
 		}
 
 		lp->tda_laddr = lp->cda_laddr + sizeof (lp->cda);
@@ -219,7 +248,7 @@
 		if (!lp->rba) {
 			printk("%s: couldn't allocate receive buffers\n",
 			       dev->name);
-			return -ENOMEM;
+			goto out2;
 		}
 
 		/* get virtual dma address */
@@ -228,7 +257,7 @@
 		if (lp->rba_laddr == ~0UL) {
 			printk("%s: couldn't get DMA page entry for receive "
 			       "buffers\n",dev->name);
-			return -ENOMEM;
+			goto out3;
 		}
 
 		/* now convert pointer to KSEG1 pointer */
@@ -252,9 +281,16 @@
 	SONIC_WRITE(SONIC_FAET,0xffff);
 	SONIC_WRITE(SONIC_MPT,0xffff);
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
 	return 0;
+out3:
+	kfree(lp->rba);
+out2:
+	vdma_free(lp->cda_laddr);
+out1:
+	kfree(lp);
+out:
+	release_region(base_addr, 0x100);
+	return err;
 }
 
 /*
