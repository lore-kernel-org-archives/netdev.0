From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (29/42) bagetlance
Date: Wed, 12 Nov 2003 16:45:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130045.hAD0j8s31144@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE54-bagetlance
	* switched bagetlance to dynamic allocation
	* bagetlance: embedded ->priv
	* bagetlance: fixed resource leaks on failure exits
	* bagetlance: fixed resource leaks on rmmod

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 14:15:23 2003
+++ b/drivers/net/Space.c	Tue Nov 11 14:15:23 2003
@@ -82,7 +82,7 @@
 extern int pamsnet_probe(struct net_device *);
 extern struct net_device *cs89x0_probe(int unit);
 extern int hplance_probe(struct net_device *dev);
-extern int bagetlance_probe(struct net_device *);
+extern struct net_device *bagetlance_probe(int unit);
 extern int mvme147lance_probe(struct net_device *dev);
 extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
@@ -339,6 +339,10 @@
 #ifdef CONFIG_MIPS_JAZZ_SONIC
 	{sonic_probe, 0},
 #endif
+	{NULL, 0},
+};
+
+static struct devprobe2 mips_probes2[] __initdata = {
 #ifdef CONFIG_BAGETLANCE        /* Lance-based Baget ethernet boards */
         {bagetlance_probe, 0},
 #endif
@@ -392,6 +396,7 @@
 	if (base_addr == 1)
 		return;
 
+	probe_list2(unit, mips_probes2, base_addr == 0) &&
 	probe_list2(unit, eisa_probes, base_addr == 0) &&
 	probe_list2(unit, mca_probes, base_addr == 0) &&
 	probe_list2(unit, isa_probes, base_addr == 0) &&
diff -Nru a/drivers/net/bagetlance.c b/drivers/net/bagetlance.c
--- a/drivers/net/bagetlance.c	Tue Nov 11 14:15:23 2003
+++ b/drivers/net/bagetlance.c	Tue Nov 11 14:15:23 2003
@@ -465,30 +465,43 @@
 }
 
 
-int __init bagetlance_probe( struct net_device *dev )
-
-{	int i;
+struct net_device * __init bagetlance_probe(int unit)
+{
+	struct net_device *dev;
+	int i;
 	static int found;
-
-	SET_MODULE_OWNER(dev);
+	int err = -ENODEV;
 
 	if (found)
 		/* Assume there's only one board possible... That seems true, since
 		 * the Riebl/PAM board's address cannot be changed. */
-		return( -ENODEV );
+		return ERR_PTR(-ENODEV);
+
+	dev = alloc_etherdev(sizeof(struct lance_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	SET_MODULE_OWNER(dev);
 
 	for( i = 0; i < N_LANCE_ADDR; ++i ) {
 		if (lance_probe1( dev, &lance_addr_list[i] )) {
 			found = 1;
-			return( 0 );
+			break;
 		}
 	}
-
-	return( -ENODEV );
+	if (!found)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
+	free_irq(dev->irq, dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
-
-
 /* Derived from hwreg_present() in vme/config.c: */
 
 static int __init addr_accessible( volatile void *regp, 
@@ -527,6 +540,7 @@
 	if (!addr_accessible( memaddr, 1, 1 )) goto probe_fail;
 
 	if ((unsigned long)memaddr >= KSEG2) {
+			/* FIXME: do we need to undo that on cleanup paths? */
 			extern int kseg2_alloc_io (unsigned long addr, unsigned long size);
 			if (kseg2_alloc_io((unsigned long)memaddr, BAGET_LANCE_MEM_SIZE)) {
 					printk("bagetlance: unable map lance memory\n");
@@ -580,12 +594,6 @@
 	return( 0 );
 
   probe_ok:
-	init_etherdev( dev, sizeof(struct lance_private) );
-	if (!dev->priv) {
-		dev->priv = kmalloc( sizeof(struct lance_private), GFP_KERNEL );
-		if (!dev->priv)
-			return 0;
-	}
 	lp = (struct lance_private *)dev->priv;
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
@@ -617,8 +625,9 @@
 	if (lp->cardtype == PAM_CARD ||
 		memaddr == (unsigned short *)0xffe00000) {
 		/* PAMs card and Riebl on ST use level 5 autovector */
-		request_irq(BAGET_LANCE_IRQ, lance_interrupt, IRQ_TYPE_PRIO,
-		            "PAM/Riebl-ST Ethernet", dev);
+		if (request_irq(BAGET_LANCE_IRQ, lance_interrupt, IRQ_TYPE_PRIO,
+		            "PAM/Riebl-ST Ethernet", dev))
+			goto probe_fail;
 		dev->irq = (unsigned short)BAGET_LANCE_IRQ;
 	}
 	else {
@@ -629,10 +638,11 @@
 		unsigned long irq = BAGET_LANCE_IRQ; 
 		if (!irq) {
 			printk( "Lance: request for VME interrupt failed\n" );
-			return( 0 );
+			goto probe_fail;
 		}
-		request_irq(irq, lance_interrupt, IRQ_TYPE_PRIO,
-		            "Riebl-VME Ethernet", dev);
+		if (request_irq(irq, lance_interrupt, IRQ_TYPE_PRIO,
+		            "Riebl-VME Ethernet", dev))
+			goto probe_fail;
 		dev->irq = irq;
 	}
 
@@ -1331,26 +1341,21 @@
 
 
 #ifdef MODULE
-static struct net_device bagetlance_dev;
+static struct net_device *bagetlance_dev;
 
 int init_module(void)
-
-{	int err;
-
-	bagetlance_dev.init = bagetlance_probe;
-	if ((err = register_netdev( &bagetlance_dev ))) {
-		if (err == -EIO)  {
-			printk( "No Vme Lance board found. Module not loaded.\n");
-		}
-		return( err );
-	}
-	return( 0 );
+{
+	bagetlance_dev = bagetlance_probe(-1);
+	if (IS_ERR(bagetlance_dev))
+		return PTR_ERR(bagetlance_dev);
+	return 0;
 }
 
 void cleanup_module(void)
-
 {
-	unregister_netdev( &bagetlance_dev );
+	unregister_netdev(bagetlance_dev);
+	free_irq(bagetlance_dev->irq, bagetlance_dev);
+	free_netdev(bagetlance_dev);
 }
 
 #endif /* MODULE */
