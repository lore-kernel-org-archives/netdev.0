From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ibmtr -- convert to new probeing
Date: Thu, 13 Nov 2003 11:24:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113112440.2fe0e12c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Mike_Phillips@URSCorp.com" <Mike_Phillips@URSCorp.com>,
        Jeff Garzik
 <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch applies against net-drivers-2.5-exp.  The line number offsets assume
the earlier patchset, but this change doesn't overlap all those ether changes.

	* convert ibmtr driver to using the new probe interface -- ibmtr_probe2
	* keep old ibmtr_probe for use as init handle because ibmtr_cs uses it
	* cleanup error paths in ibmtr_probe1 and module init
	* make only used locally functions static
	* do request_region before doing i/o
	* irq and mem were not really settable as module parameters so removed

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Thu Nov 13 11:22:59 2003
+++ b/drivers/net/Space.c	Thu Nov 13 11:22:59 2003
@@ -336,12 +336,15 @@
 
 #ifdef CONFIG_TR
 /* Token-ring device probe */
-extern int ibmtr_probe(struct net_device *);
+extern struct net_device *ibmtr_probe2(int unit);
 extern struct net_device *sk_isa_probe(int unit);
 extern struct net_device *proteon_probe(int unit);
 extern struct net_device *smctr_probe(int unit);
 
-static struct devprobe2 tr_probes2[] __initdata = {
+static struct devprobe2 tr_probes[] __initdata = {
+#ifdef CONFIG_IBMTR
+	{ibmtr_probe2, 0},
+#endif
 #ifdef CONFIG_SKISA
 	{sk_isa_probe, 0},
 #endif
@@ -354,37 +357,13 @@
 	{NULL, 0},
 };
 
-static __init int trif_probe(int unit)
-{
-	struct net_device *dev;
-	int err = -ENODEV;
-	
-	dev = alloc_trdev(0);
-	if (!dev)
-		return -ENOMEM;
-
-	sprintf(dev->name, "tr%d", unit);
-	netdev_boot_setup_check(dev);
-	if (
-#ifdef CONFIG_IBMTR
-	    ibmtr_probe(dev) == 0  ||
-#endif
-	    0 ) 
-		err = register_netdev(dev);
-		
-	if (err)
-		free_netdev(dev);
-	return err;
-
-}
-
 static void __init trif_probe2(int unit)
 {
 	unsigned long base_addr = netdev_boot_base("tr", unit);
 
 	if (base_addr == 1)
 		return;
-	probe_list2(unit, tr_probes2, base_addr == 0);
+	probe_list2(unit, tr_probes, base_addr == 0);
 }
 #endif
 
@@ -411,8 +390,7 @@
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (!trif_probe(num))
-			trif_probe2(num);
+		trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
 		ethif_probe2(num);
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	Thu Nov 13 11:22:59 2003
+++ b/drivers/net/tokenring/ibmtr.c	Thu Nov 13 11:22:59 2003
@@ -193,7 +193,7 @@
 static int 	trdev_init(struct net_device *dev);
 static int 	tok_open(struct net_device *dev);
 static int 	tok_init_card(struct net_device *dev);
-void 		tok_open_adapter(unsigned long dev_addr);
+static void 	tok_open_adapter(unsigned long dev_addr);
 static void 	open_sap(unsigned char type, struct net_device *dev);
 static void 	tok_set_multicast_list(struct net_device *dev);
 static int 	tok_send_packet(struct sk_buff *skb, struct net_device *dev);
@@ -202,11 +202,11 @@
 static void 	initial_tok_int(struct net_device *dev);
 static void 	tr_tx(struct net_device *dev);
 static void 	tr_rx(struct net_device *dev);
-void 		ibmtr_reset_timer(struct timer_list*tmr,struct net_device *dev);
+static void 	ibmtr_reset_timer(struct timer_list*tmr,struct net_device *dev);
 static void	tok_rerun(unsigned long dev_addr);
-void 		ibmtr_readlog(struct net_device *dev);
+static void 	ibmtr_readlog(struct net_device *dev);
 static struct 	net_device_stats *tok_get_stats(struct net_device *dev);
-int 		ibmtr_change_mtu(struct net_device *dev, int mtu);
+static int 	ibmtr_change_mtu(struct net_device *dev, int mtu);
 static void	find_turbo_adapters(int *iolist);
 
 static int ibmtr_portlist[IBMTR_MAX_ADAPTERS+1] __devinitdata = {
@@ -332,19 +332,45 @@
 
 	if (base_addr && base_addr <= 0x1ff) /* Don't probe at all. */
 		return -ENXIO;
-	if (base_addr > 0x1ff) { /* Check a single specified location.  */
-		if (!ibmtr_probe1(dev, base_addr)) return 0;
-		return -ENODEV;
-	}
+	if (base_addr > 0x1ff) /* Check a single specified location.  */
+		return ibmtr_probe1(dev, base_addr);
 	find_turbo_adapters(ibmtr_portlist);
 	for (i = 0; ibmtr_portlist[i]; i++) {
-		int ioaddr = ibmtr_portlist[i];
-
-		if (!ibmtr_probe1(dev, ioaddr)) return 0;
+		if (!ibmtr_probe1(dev, ibmtr_portlist[i]))
+			return 0;
 	}
 	return -ENODEV;
 }
 
+#ifndef MODULE
+/*
+ * Called from Space.c to probe for token ring devices at boot
+ * time.
+ */
+struct net_device * __devinit ibmtr_probe2(int unit)
+{
+	struct net_device *dev = alloc_trdev(sizeof(struct tok_info));
+	int err = 0;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0) {
+		sprintf(dev->name, "tr%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+
+	dev->init = &ibmtr_probe;
+
+	err = register_netdev(dev);
+	if (!err)
+		return dev;
+
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+#endif
+
 /*****************************************************************************/
 
 static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
@@ -360,6 +386,15 @@
         unsigned long timeout;
 	static int version_printed;
 #endif
+	int err = -ENODEV;
+
+	/*?? Now, allocate some of the PIO PORTs for this driver.. */
+	/* record PIOaddr range as busy */
+	if (!request_region(PIOaddr, IBMTR_IO_EXTENT, "ibmtr")) {
+		DPRINTK("Could not grab PIO range. Halting driver.\n");
+		err = -EBUSY;
+		goto out1;
+	}
 
 	/*    Query the adapter PIO base port which will return
 	 *    indication of where MMIO was placed. We also have a
@@ -374,7 +409,7 @@
 		DPRINTK("ibmtr_probe1(): unhappy that inb(0x%X) == 0x%X, "
 			"Hardware Problem?\n",PIOaddr,segment);
 #endif
-		return -ENODEV;
+		goto out2;
 	}
 	/*
 	 *    Compute the linear base address of the MMIO area
@@ -383,7 +418,7 @@
 	t_mmio = ioremap(((__u32) (segment & 0xfc) << 11) + 0x80000,2048);
 	if (!t_mmio) { 
 		DPRINTK("Cannot remap mmiobase memory area") ; 
-		return -ENODEV ; 
+		goto out2;
 	} 
 	intr = segment & 0x03;	/* low bits is coded interrupt # */
 	if (ibmtr_debug_trace & TRC_INIT)
@@ -427,12 +462,9 @@
 	if (cardpresent == TR_ISA && (readb(AIPFID + t_mmio) == 0x0e))
 		cardpresent = TR_ISAPNP;
 	if (cardpresent == NOTOK) {	/* "channel_id" did not match, report */
-		if (!(ibmtr_debug_trace & TRC_INIT)) {
-#ifndef PCMCIA
-			iounmap(t_mmio);
-#endif
-			return -ENODEV;
-		}
+		if (!(ibmtr_debug_trace & TRC_INIT)) 
+			goto out3;
+
 		DPRINTK( "Channel ID string not found for PIOaddr: %4hx\n",
 								PIOaddr);
 		DPRINTK("Expected for ISA: ");
@@ -497,9 +529,7 @@
 		while (!readb(ti->mmio + ACA_OFFSET + ACA_RW + RRR_EVEN)){
 			if (!time_after(jiffies, timeout)) continue;
 			DPRINTK( "Hardware timeout during initialization.\n");
-			iounmap(t_mmio);
-			kfree(ti);
-			return -ENODEV;
+			goto out3;
 		}
 		ti->sram_virt =
 		     ((__u32)readb(ti->mmio+ACA_OFFSET+ACA_RW+RRR_EVEN)<<12);
@@ -611,10 +641,7 @@
 		default:
 			DPRINTK("Unknown shared ram paging info %01X\n",
 							ti->shared_ram_paging);
-			iounmap(t_mmio); 
-			kfree(ti);
-			return -ENODEV;
-			break;
+			goto out3;
 		} /*end switch shared_ram_paging */
 
 		if (ibmtr_debug_trace & TRC_INIT)
@@ -641,9 +668,7 @@
 			DPRINTK("Shared RAM for this adapter (%05x) exceeds "
 			"driver limit (%05x), adapter not started.\n",
 			chk_base, ibmtr_mem_base + IBMTR_SHARED_RAM_SIZE);
-			iounmap(t_mmio);
-			kfree(ti);
-			return -ENODEV;
+			goto out3;
 		} else { /* seems cool, record what we have figured out */
 			ti->sram_base = new_base >> 12;
 			ibmtr_mem_base = chk_base;
@@ -656,18 +681,7 @@
 	if (request_irq(dev->irq = irq, &tok_interrupt, 0, "ibmtr", dev) != 0) {
 		DPRINTK("Could not grab irq %d.  Halting Token Ring driver.\n",
 					irq);
-		iounmap(t_mmio);
-		kfree(ti);
-		return -ENODEV;
-	}
-	/*?? Now, allocate some of the PIO PORTs for this driver.. */
-	/* record PIOaddr range as busy */
-	if (!request_region(PIOaddr, IBMTR_IO_EXTENT, "ibmtr")) {
-		DPRINTK("Could not grab PIO range. Halting driver.\n");
-		free_irq(dev->irq, dev);
-		iounmap(t_mmio);
-		kfree(ti);
-		return -EBUSY;
+		goto out3;
 	}
 
 	if (!version_printed++) {
@@ -767,6 +781,15 @@
 	dev->mem_end = dev->mem_start + (ti->mapped_ram_size << 9) - 1;
 	trdev_init(dev);
 	return 0;   /* Return 0 to indicate we have found a Token Ring card. */
+
+ out3:
+#ifndef PCMCIA
+	iounmap(t_mmio);
+#endif
+ out2:
+	release_region(PIOaddr, IBMTR_IO_EXTENT);
+ out1:
+	return err;
 }				/*ibmtr_probe1() */
 
 /*****************************************************************************/
@@ -900,7 +923,7 @@
 #define DLC_MAX_SAP_OFST        32
 #define DLC_MAX_STA_OFST        33
 
-void tok_open_adapter(unsigned long dev_addr)
+static void tok_open_adapter(unsigned long dev_addr)
 {
 	struct net_device *dev = (struct net_device *) dev_addr;
 	struct tok_info *ti;
@@ -1825,7 +1848,7 @@
 
 /*****************************************************************************/
 
-void ibmtr_reset_timer(struct timer_list *tmr, struct net_device *dev)
+static void ibmtr_reset_timer(struct timer_list *tmr, struct net_device *dev)
 {
 	tmr->expires = jiffies + TR_RETRY_INTERVAL;
 	tmr->data = (unsigned long) dev;
@@ -1836,7 +1859,7 @@
 
 /*****************************************************************************/
 
-void tok_rerun(unsigned long dev_addr){
+static void tok_rerun(unsigned long dev_addr){
 
 	struct net_device *dev = (struct net_device *)dev_addr;
 	struct tok_info *ti = (struct tok_info *) dev->priv;
@@ -1857,7 +1880,7 @@
 
 /*****************************************************************************/
 
-void ibmtr_readlog(struct net_device *dev)
+static void ibmtr_readlog(struct net_device *dev)
 {
 	struct tok_info *ti;
 
@@ -1890,7 +1913,7 @@
 
 /*****************************************************************************/
 
-int ibmtr_change_mtu(struct net_device *dev, int mtu)
+static int ibmtr_change_mtu(struct net_device *dev, int mtu)
 {
 	struct tok_info *ti = (struct tok_info *) dev->priv;
 
@@ -1908,40 +1931,38 @@
 /* 3COM 3C619C supports 8 interrupts, 32 I/O ports */
 static struct net_device *dev_ibmtr[IBMTR_MAX_ADAPTERS];
 static int io[IBMTR_MAX_ADAPTERS] = { 0xa20, 0xa24 };
-static int irq[IBMTR_MAX_ADAPTERS];
-static int mem[IBMTR_MAX_ADAPTERS];
 
 MODULE_LICENSE("GPL");
 
 MODULE_PARM(io, "1-" __MODULE_STRING(IBMTR_MAX_ADAPTERS) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(IBMTR_MAX_ADAPTERS) "i");
-MODULE_PARM(mem, "1-" __MODULE_STRING(IBMTR_MAX_ADAPTERS) "i");
+
 
 static int __init ibmtr_init(void)
 {
 	int i;
 	int count=0;
+	int err = -EIO;
 
 	find_turbo_adapters(io);
 
 	for (i = 0; io[i] && (i < IBMTR_MAX_ADAPTERS); i++) {
-		irq[i] = 0;
-		mem[i] = 0;
-		dev_ibmtr[i] = alloc_trdev(sizeof(struct tok_info));
-		if (dev_ibmtr[i] == NULL) { 
-			if (i == 0)
-				return -ENOMEM;
+		struct net_device *dev = alloc_trdev(sizeof(struct tok_info));
+
+		if (!dev) {
+			err = -ENOMEM;
 			break;
 		}
-		dev_ibmtr[i]->base_addr = io[i];
-		dev_ibmtr[i]->irq = irq[i];
-		dev_ibmtr[i]->mem_start = mem[i];
-		dev_ibmtr[i]->init = &ibmtr_probe;
-		if (register_netdev(dev_ibmtr[i]) != 0) {
-			kfree(dev_ibmtr[i]);
-			dev_ibmtr[i] = NULL;
+
+		SET_MODULE_OWNER(dev);
+		dev->init = &ibmtr_probe;
+		dev->base_addr = io[i];
+
+		err = register_netdev(dev);
+		if (err) {
+			free_netdev(dev);
 			continue;
 		}
+		dev_ibmtr[i] = dev;
 		count++;
 	}
 	if (count) return 0;
