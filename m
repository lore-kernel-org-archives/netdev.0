From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/6) ibmtr -- probe2
Date: Wed, 15 Oct 2003 13:48:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152048.h9FKmF811928@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert IBM ISA tokenring driver to new probing.
Also, need to deal with the fact that the PCMCIA ibmtr_cs
driver was calling the same probe routine.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Oct 15 13:34:56 2003
+++ b/drivers/net/Space.c	Wed Oct 15 13:34:56 2003
@@ -409,12 +409,15 @@
 
 #ifdef CONFIG_TR
 /* Token-ring device probe */
-extern int ibmtr_probe(struct net_device *);
+extern struct net_device *ibmtr_probe(int unit);
 extern struct net_device *sk_isa_probe(int unit);
 extern struct net_device *proteon_probe(int unit);
 extern struct net_device *smctr_probe(int unit);
 
 static struct devprobe2 tr_probes2[] __initdata = {
+#ifdef CONFIG_IBMTR
+	{ibmtr_probe, 0},
+#endif
 #ifdef CONFIG_SKISA
 	{sk_isa_probe, 0},
 #endif
@@ -439,9 +442,6 @@
 	sprintf(dev->name, "tr%d", unit);
 	netdev_boot_setup_check(dev);
 	if (
-#ifdef CONFIG_IBMTR
-	    ibmtr_probe(dev) == 0  ||
-#endif
 	    0 ) 
 		err = register_netdev(dev);
 		
diff -Nru a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
--- a/drivers/net/pcmcia/ibmtr_cs.c	Wed Oct 15 13:34:56 2003
+++ b/drivers/net/pcmcia/ibmtr_cs.c	Wed Oct 15 13:34:56 2003
@@ -125,18 +125,17 @@
 
 static dev_link_t *dev_list;
 
-extern int ibmtr_probe(struct net_device *dev);
 extern int trdev_init(struct net_device *dev);
 extern irqreturn_t tok_interrupt (int irq, void *dev_id, struct pt_regs *regs);
 
 /*====================================================================*/
 
 typedef struct ibmtr_dev_t {
+    struct tok_info	ti;	/* must be first! */
     dev_link_t		link;
     struct net_device	*dev;
     dev_node_t          node;
     window_handle_t     sram_win_handle;
-    struct tok_info	ti;
 } ibmtr_dev_t;
 
 static void netdev_get_drvinfo(struct net_device *dev,
@@ -149,6 +148,13 @@
 	.get_drvinfo		= netdev_get_drvinfo,
 };
 
+static int ibmtr_init(struct net_device *dev)
+{
+    extern int ibmtr_probe1(struct net_device *, int);
+
+    return ibmtr_probe1(dev, dev->base_addr);
+}
+
 /*======================================================================
 
     ibmtr_attach() creates an "instance" of the driver, allocating
@@ -194,7 +200,8 @@
 
     link->irq.Instance = info->dev = dev;
     
-    dev->init = &ibmtr_probe;
+    dev->init = ibmtr_init;
+
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
     /* Register with Card Services */
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	Wed Oct 15 13:34:56 2003
+++ b/drivers/net/tokenring/ibmtr.c	Wed Oct 15 13:34:56 2003
@@ -187,8 +187,7 @@
 #define TRC_INITV 0x02		/*  verbose init trace points     */
 unsigned char ibmtr_debug_trace = 0;
 
-int 		ibmtr_probe(struct net_device *dev);
-static int	ibmtr_probe1(struct net_device *dev, int ioaddr);
+int	ibmtr_probe1(struct net_device *dev, int ioaddr);
 static unsigned char get_sram_size(struct tok_info *adapt_info);
 static int 	trdev_init(struct net_device *dev);
 static int 	tok_open(struct net_device *dev);
@@ -325,29 +324,57 @@
  *	which references it.
  ****************************************************************************/
 
-int __devinit ibmtr_probe(struct net_device *dev)
+struct net_device * __devinit ibmtr_probe(int unit)
 {
-	int i;
-	int base_addr = dev->base_addr;
+	struct net_device *dev = alloc_trdev(sizeof(struct tok_info));
+	const int *port;
+	int err = 0;
 
-	if (base_addr && base_addr <= 0x1ff) /* Don't probe at all. */
-		return -ENXIO;
-	if (base_addr > 0x1ff) { /* Check a single specified location.  */
-		if (!ibmtr_probe1(dev, base_addr)) return 0;
-		return -ENODEV;
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "tr%d", unit);
+		netdev_boot_setup_check(dev);
 	}
-	find_turbo_adapters(ibmtr_portlist);
-	for (i = 0; ibmtr_portlist[i]; i++) {
-		int ioaddr = ibmtr_portlist[i];
 
-		if (!ibmtr_probe1(dev, ioaddr)) return 0;
+	if (dev->base_addr > 0x1ff) /* Check a single specified location.  */
+		err = ibmtr_probe1(dev, dev->base_addr);
+	else if (dev->base_addr != 0) /* Don't probe at all. */
+		err = -ENXIO;
+	else {
+		find_turbo_adapters(ibmtr_portlist);
+		for (port = ibmtr_portlist; *port; port++) {
+			err = ibmtr_probe1(dev, *port);
+			if (!err)
+				break;
+		}
+	}
+	if (err)
+		goto out;
+	
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	
+	return 0;
+ out1:
+	release_region(dev->base_addr, IBMTR_IO_EXTENT);
+#ifndef PCMCIA
+	{ 
+		struct tok_info *ti = dev->priv;
+		iounmap((u32 *)ti->mmio);
+		iounmap((u32 *)ti->sram_virt);
 	}
-	return -ENODEV;
+#endif		
+ out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
 /*****************************************************************************/
 
-static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
+int ibmtr_probe1(struct net_device *dev, int PIOaddr)
 {
 
 	unsigned char segment, intr=0, irq=0, i, j, cardpresent=NOTOK, temp=0;
@@ -1918,7 +1945,8 @@
 
 static int __init ibmtr_init(void)
 {
-	int i;
+	struct net_device *dev;
+	int i, err;
 	int count=0;
 
 	find_turbo_adapters(io);
@@ -1926,26 +1954,29 @@
 	for (i = 0; io[i] && (i < IBMTR_MAX_ADAPTERS); i++) {
 		irq[i] = 0;
 		mem[i] = 0;
-		dev_ibmtr[i] = alloc_trdev(sizeof(struct tok_info));
-		if (dev_ibmtr[i] == NULL) { 
-			if (i == 0)
-				return -ENOMEM;
-			break;
-		}
-		dev_ibmtr[i]->base_addr = io[i];
-		dev_ibmtr[i]->irq = irq[i];
-		dev_ibmtr[i]->mem_start = mem[i];
-		dev_ibmtr[i]->init = &ibmtr_probe;
-		if (register_netdev(dev_ibmtr[i]) != 0) {
-			kfree(dev_ibmtr[i]);
-			dev_ibmtr[i] = NULL;
+		
+		dev = alloc_trdev(sizeof(struct tok_info));
+		if (!dev)
 			continue;
+		SET_MODULE_OWNER(dev);
+
+		dev->irq = irq[i];
+		dev->mem_start = mem[i];
+		err = ibmtr_probe1(dev, io[i]);
+		if (err) {
+			free_netdev(dev);
+			continue;
+		}			
+		err = register_netdev(dev);
+		if (err) {
+			printk("ibmtr: register_netdev() returned %d.\n", err);
+			break;
 		}
 		count++;
+		dev_ibmtr[i] = dev;
 	}
-	if (count) return 0;
-	printk("ibmtr: register_netdev() returned non-zero.\n");
-	return -EIO;
+
+	return count ? 0 : -ENODEV;
 }
 module_init(ibmtr_init);
 
@@ -1954,29 +1985,30 @@
 	int i;
 
 	for (i = 0; i < IBMTR_MAX_ADAPTERS; i++){
-		if (!dev_ibmtr[i])
+		struct net_device *dev = dev_ibmtr[i];
+
+		if (!dev)
 			continue;
-		if (dev_ibmtr[i]->base_addr) {
-			outb(0,dev_ibmtr[i]->base_addr+ADAPTRESET);
+		if (dev->base_addr) {
+			outb(0,dev->base_addr+ADAPTRESET);
 			
 			schedule_timeout(TR_RST_TIME); /* wait 50ms */
 
-                        outb(0,dev_ibmtr[i]->base_addr+ADAPTRESETREL);
+                        outb(0,dev->base_addr+ADAPTRESETREL);
                 }
 
-		unregister_netdev(dev_ibmtr[i]);
-		free_irq(dev_ibmtr[i]->irq, dev_ibmtr[i]);
-		release_region(dev_ibmtr[i]->base_addr, IBMTR_IO_EXTENT);
+		unregister_netdev(dev);
+		free_irq(dev->irq, dev);
+		release_region(dev->base_addr, IBMTR_IO_EXTENT);
 #ifndef PCMCIA
 		{ 
-			struct tok_info *ti = (struct tok_info *)
-				dev_ibmtr[i]->priv;
+			struct tok_info *ti = dev->priv;
 			iounmap((u32 *)ti->mmio);
 			iounmap((u32 *)ti->sram_virt);
 		}
 #endif		
-		free_netdev(dev_ibmtr[i]);
-		dev_ibmtr[i] = NULL;
+		free_netdev(dev);
+		dev_ibmtr[i] = 0;
 	}
 }
 module_exit(ibmtr_cleanup);
