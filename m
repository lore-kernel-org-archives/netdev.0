From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) Update baycom drivers for 2.6
Date: Fri, 19 Sep 2003 13:37:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919133750.4053f72c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Sailer <t.sailer@alumni.ethz.ch>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update baycom drivers for 2.6.0-test5
	- get rid of MOD_INC/DEC
	    (looked into hdlcdrv_ops and don't need to have owner field because
	     baycom drivers unregister on  unload).
	- use alloc_netdev instead of static device structures.
	- hdlcdrv_register returns device instead of getting passed one.
	- put private data in space allocated at dev->priv in alloc_netdev
	- shorten name of hdlcdrv_register_hdlcdrv to hdlcdrv_register

I don't have actual baycom hardware, but driver builds and loads/unloads.
Real hardware initialization doesn't happen until open.

The first one is the important patch, the other three are just code review
type cleanups.

diff -urNp -X dontdiff net-2.5/drivers/net/hamradio/baycom_epp.c linux-2.5-net/drivers/net/hamradio/baycom_epp.c
--- net-2.5/drivers/net/hamradio/baycom_epp.c	2003-09-19 10:20:48.000000000 -0700
+++ linux-2.5-net/drivers/net/hamradio/baycom_epp.c	2003-09-09 16:36:16.000000000 -0700
@@ -98,7 +98,7 @@ KERN_INFO "baycom_epp: version 0.7 compi
 
 #define NR_PORTS 4
 
-static struct net_device baycom_device[NR_PORTS];
+static struct net_device *baycom_device[NR_PORTS];
 
 /* --------------------------------------------------------------------- */
 
@@ -1084,7 +1084,6 @@ static int epp_open(struct net_device *d
 	/* start the bottom half stuff */
 	schedule_delayed_work(&bc->run_work, 1);
 	netif_start_queue(dev);
-	MOD_INC_USE_COUNT;
 	return 0;
 
  epptimeout:
@@ -1119,7 +1118,6 @@ static int epp_close(struct net_device *
 	bc->skb = NULL;
 	printk(KERN_INFO "%s: close epp at iobase 0x%lx irq %u\n",
 	       bc_drvname, dev->base_addr, dev->irq);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -1357,69 +1355,76 @@ MODULE_LICENSE("GPL");
 
 /* --------------------------------------------------------------------- */
 
+static void __init baycom_epp_setup(struct net_device *dev)
+{
+	struct baycom_state *bc = dev->priv;
+
+	/*
+	 * initialize part of the baycom_state struct
+	 */
+	bc->magic = BAYCOM_MAGIC;
+	bc->cfg.fclk = 19666600;
+	bc->cfg.bps = 9600;
+	/*
+	 * initialize part of the device struct
+	 */
+	dev->init = baycom_probe;
+}
+
 static int __init init_baycomepp(void)
 {
-	struct net_device *dev;
 	int i, found = 0;
 	char set_hw = 1;
-	struct baycom_state *bc;
 
 	printk(bc_drvinfo);
 	/*
 	 * register net devices
 	 */
 	for (i = 0; i < NR_PORTS; i++) {
-		dev = baycom_device+i;
+		struct net_device *dev;
+		
+		dev = alloc_netdev(sizeof(struct baycom_state), "bce%d",
+				   baycom_epp_setup);
+
+		if (!dev) {
+			printk(KERN_WARNING "bce%d : out of memory\n", i);
+			return found ? 0 : -ENOMEM;
+		}
+			
+		sprintf(dev->name, "bce%d", i);
+		dev->base_addr = iobase[i];
+
 		if (!mode[i])
 			set_hw = 0;
 		if (!set_hw)
 			iobase[i] = 0;
-		memset(dev, 0, sizeof(struct net_device));
-		if (!(bc = dev->priv = kmalloc(sizeof(struct baycom_state), GFP_KERNEL)))
-			return -ENOMEM;
-		/*
-		 * initialize part of the baycom_state struct
-		 */
-		memset(bc, 0, sizeof(struct baycom_state));
-		bc->magic = BAYCOM_MAGIC;
-		sprintf(dev->name, "bce%d", i);
-		bc->cfg.fclk = 19666600;
-		bc->cfg.bps = 9600;
-		/*
-		 * initialize part of the device struct
-		 */
-		dev->if_port = 0;
-		dev->init = baycom_probe;
-		dev->base_addr = iobase[i];
-		dev->irq = 0;
-		dev->dma = 0;
+
 		if (register_netdev(dev)) {
 			printk(KERN_WARNING "%s: cannot register net device %s\n", bc_drvname, dev->name);
-			kfree(dev->priv);
-			return -ENXIO;
+			kfree(dev);
+			break;
 		}
-		if (set_hw && baycom_setmode(bc, mode[i]))
+		if (set_hw && baycom_setmode(dev->priv, mode[i]))
 			set_hw = 0;
+		baycom_device[i] = dev;
 		found++;
 	}
-	if (!found)
-		return -ENXIO;
-	return 0;
+
+	return found ? 0 : -ENXIO;
 }
 
 static void __exit cleanup_baycomepp(void)
 {
-	struct net_device *dev;
-	struct baycom_state *bc;
 	int i;
 
 	for(i = 0; i < NR_PORTS; i++) {
-		dev = baycom_device+i;
-		bc = (struct baycom_state *)dev->priv;
-		if (bc) {
+		struct net_device *dev = baycom_device[i];
+
+		if (dev) {
+			struct baycom_state *bc = dev->priv;
 			if (bc->magic == BAYCOM_MAGIC) {
 				unregister_netdev(dev);
-				kfree(dev->priv);
+				free_netdev(dev);
 			} else
 				printk(paranoia_str, "cleanup_module");
 		}
diff -urNp -X dontdiff net-2.5/drivers/net/hamradio/baycom_par.c linux-2.5-net/drivers/net/hamradio/baycom_par.c
--- net-2.5/drivers/net/hamradio/baycom_par.c	2003-09-19 10:20:48.000000000 -0700
+++ linux-2.5-net/drivers/net/hamradio/baycom_par.c	2003-09-09 16:36:16.000000000 -0700
@@ -108,7 +108,7 @@ KERN_INFO "baycom_par: version 0.9 compi
 
 #define NR_PORTS 4
 
-static struct net_device baycom_device[NR_PORTS];
+static struct net_device *baycom_device[NR_PORTS];
 
 /* --------------------------------------------------------------------- */
 
@@ -353,7 +353,6 @@ static int par96_open(struct net_device 
 	pp->ops->enable_irq(pp);
 	printk(KERN_INFO "%s: par96 at iobase 0x%lx irq %u options 0x%x\n",
 	       bc_drvname, dev->base_addr, dev->irq, bc->options);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -375,7 +374,6 @@ static int par96_close(struct net_device
 	parport_unregister_device(bc->pdev);
 	printk(KERN_INFO "%s: close par96 at iobase 0x%lx irq %u\n",
 	       bc_drvname, dev->base_addr, dev->irq);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -499,35 +497,38 @@ MODULE_LICENSE("GPL");
 
 static int __init init_baycompar(void)
 {
-	int i, j, found = 0;
+	int i, found = 0;
 	char set_hw = 1;
-	struct baycom_state *bc;
 
 	printk(bc_drvinfo);
 	/*
 	 * register net devices
 	 */
 	for (i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
+		struct net_device *dev;
+		struct baycom_state *bc;
 		char ifname[IFNAMSIZ];
 
 		sprintf(ifname, "bcp%d", i);
+
 		if (!mode[i])
 			set_hw = 0;
 		if (!set_hw)
 			iobase[i] = 0;
-		j = hdlcdrv_register_hdlcdrv(dev, &par96_ops, sizeof(struct baycom_state),
-					     ifname, iobase[i], 0, 0);
-		if (!j) {
-			bc = (struct baycom_state *)dev->priv;
-			if (set_hw && baycom_setmode(bc, mode[i]))
-				set_hw = 0;
-			found++;
-		} else {
-			printk(KERN_WARNING "%s: cannot register net device\n",
-			       bc_drvname);
-		}
+
+		dev = hdlcdrv_register(&par96_ops,
+				       sizeof(struct baycom_state),
+				       ifname, iobase[i], 0, 0);
+		if (IS_ERR(dev)) 
+			break;
+
+		bc = (struct baycom_state *)dev->priv;
+		if (set_hw && baycom_setmode(bc, mode[i]))
+			set_hw = 0;
+		found++;
+		baycom_device[i] = dev;
 	}
+
 	if (!found)
 		return -ENXIO;
 	return 0;
@@ -538,16 +539,10 @@ static void __exit cleanup_baycompar(voi
 	int i;
 
 	for(i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
-		struct baycom_state *bc = (struct baycom_state *)dev->priv;
+		struct net_device *dev = baycom_device[i];
 
-		if (bc) {
-			if (bc->hdrv.magic != HDLCDRV_MAGIC)
-				printk(KERN_ERR "baycom: invalid magic in "
-				       "cleanup_module\n");
-			else
-				hdlcdrv_unregister_hdlcdrv(dev);
-		}
+		if (dev)
+			hdlcdrv_unregister(dev);
 	}
 }
 
diff -urNp -X dontdiff net-2.5/drivers/net/hamradio/baycom_ser_fdx.c linux-2.5-net/drivers/net/hamradio/baycom_ser_fdx.c
--- net-2.5/drivers/net/hamradio/baycom_ser_fdx.c	2003-09-19 10:20:48.000000000 -0700
+++ linux-2.5-net/drivers/net/hamradio/baycom_ser_fdx.c	2003-09-09 16:36:16.000000000 -0700
@@ -95,7 +95,7 @@ KERN_INFO "baycom_ser_fdx: version 0.10 
 
 #define NR_PORTS 4
 
-static struct net_device baycom_device[NR_PORTS];
+static struct net_device *baycom_device[NR_PORTS];
 
 /* --------------------------------------------------------------------- */
 
@@ -460,7 +460,6 @@ static int ser12_open(struct net_device 
 	hdlcdrv_setdcd(&bc->hdrv, 0);
 	printk(KERN_INFO "%s: ser_fdx at iobase 0x%lx irq %u baud %u uart %s\n",
 	       bc_drvname, dev->base_addr, dev->irq, bc->baud, uart_str[u]);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -481,7 +480,6 @@ static int ser12_close(struct net_device
 	release_region(dev->base_addr, SER12_EXTENT);
 	printk(KERN_INFO "%s: close ser_fdx at iobase 0x%lx irq %u\n",
 	       bc_drvname, dev->base_addr, dev->irq);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -622,36 +620,39 @@ MODULE_LICENSE("GPL");
 
 static int __init init_baycomserfdx(void)
 {
-	int i, j, found = 0;
+	int i, found = 0;
 	char set_hw = 1;
-	struct baycom_state *bc;
 
 	printk(bc_drvinfo);
 	/*
 	 * register net devices
 	 */
 	for (i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
+		struct net_device *dev;
+		struct baycom_state *bc;
 		char ifname[IFNAMSIZ];
 
 		sprintf(ifname, "bcsf%d", i);
+
 		if (!mode[i])
 			set_hw = 0;
 		if (!set_hw)
 			iobase[i] = irq[i] = 0;
-		j = hdlcdrv_register_hdlcdrv(dev, &ser12_ops, sizeof(struct baycom_state),
-					     ifname, iobase[i], irq[i], 0);
-		if (!j) {
-			bc = (struct baycom_state *)dev->priv;
-			if (set_hw && baycom_setmode(bc, mode[i]))
-				set_hw = 0;
-			bc->baud = baud[i];
-			found++;
-		} else {
-			printk(KERN_WARNING "%s: cannot register net device\n",
-			       bc_drvname);
-		}
+
+		dev = hdlcdrv_register(&ser12_ops, 
+				       sizeof(struct baycom_state),
+				       ifname, iobase[i], irq[i], 0);
+		if (IS_ERR(dev)) 
+			break;
+
+		bc = (struct baycom_state *)dev->priv;
+		if (set_hw && baycom_setmode(bc, mode[i]))
+			set_hw = 0;
+		bc->baud = baud[i];
+		found++;
+		baycom_device[i] = dev;
 	}
+
 	if (!found)
 		return -ENXIO;
 	return 0;
@@ -662,16 +663,9 @@ static void __exit cleanup_baycomserfdx(
 	int i;
 
 	for(i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
-		struct baycom_state *bc = (struct baycom_state *)dev->priv;
-
-		if (bc) {
-			if (bc->hdrv.magic != HDLCDRV_MAGIC)
-				printk(KERN_ERR "baycom: invalid magic in "
-				       "cleanup_module\n");
-			else
-				hdlcdrv_unregister_hdlcdrv(dev);
-		}
+		struct net_device *dev = baycom_device[i];
+		if (dev) 
+			hdlcdrv_unregister(dev);
 	}
 }
 
diff -urNp -X dontdiff net-2.5/drivers/net/hamradio/baycom_ser_hdx.c linux-2.5-net/drivers/net/hamradio/baycom_ser_hdx.c
--- net-2.5/drivers/net/hamradio/baycom_ser_hdx.c	2003-09-19 10:20:48.000000000 -0700
+++ linux-2.5-net/drivers/net/hamradio/baycom_ser_hdx.c	2003-09-09 16:36:16.000000000 -0700
@@ -85,7 +85,7 @@ KERN_INFO "baycom_ser_hdx: version 0.10 
 
 #define NR_PORTS 4
 
-static struct net_device baycom_device[NR_PORTS];
+static struct net_device *baycom_device[NR_PORTS];
 
 /* --------------------------------------------------------------------- */
 
@@ -505,7 +505,6 @@ static int ser12_open(struct net_device 
 	ser12_set_divisor(dev, bc->opt_dcd ? 6 : 4);
 	printk(KERN_INFO "%s: ser12 at iobase 0x%lx irq %u uart %s\n", 
 	       bc_drvname, dev->base_addr, dev->irq, uart_str[u]);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -526,7 +525,6 @@ static int ser12_close(struct net_device
 	release_region(dev->base_addr, SER12_EXTENT);
 	printk(KERN_INFO "%s: close ser12 at iobase 0x%lx irq %u\n",
 	       bc_drvname, dev->base_addr, dev->irq);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -659,35 +657,38 @@ MODULE_LICENSE("GPL");
 
 static int __init init_baycomserhdx(void)
 {
-	int i, j, found = 0;
+	int i, found = 0;
 	char set_hw = 1;
-	struct baycom_state *bc;
 
 	printk(bc_drvinfo);
 	/*
 	 * register net devices
 	 */
 	for (i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
+		struct net_device *dev;
+		struct baycom_state *bc;
 		char ifname[IFNAMSIZ];
 
 		sprintf(ifname, "bcsh%d", i);
+
 		if (!mode[i])
 			set_hw = 0;
 		if (!set_hw)
 			iobase[i] = irq[i] = 0;
-		j = hdlcdrv_register_hdlcdrv(dev, &ser12_ops, sizeof(struct baycom_state),
-					     ifname, iobase[i], irq[i], 0);
-		if (!j) {
-			bc = (struct baycom_state *)dev->priv;
-			if (set_hw && baycom_setmode(bc, mode[i]))
-				set_hw = 0;
-			found++;
-		} else {
-			printk(KERN_WARNING "%s: cannot register net device\n",
-			       bc_drvname);
-		}
+
+		dev = hdlcdrv_register(&ser12_ops, 
+				       sizeof(struct baycom_state),
+				       ifname, iobase[i], irq[i], 0);
+		if (IS_ERR(dev)) 
+			break;
+
+		bc = (struct baycom_state *)dev->priv;
+		if (set_hw && baycom_setmode(bc, mode[i]))
+			set_hw = 0;
+		found++;
+		baycom_device[i] = dev;
 	}
+
 	if (!found)
 		return -ENXIO;
 	return 0;
@@ -698,16 +699,10 @@ static void __exit cleanup_baycomserhdx(
 	int i;
 
 	for(i = 0; i < NR_PORTS; i++) {
-		struct net_device *dev = baycom_device+i;
-		struct baycom_state *bc = (struct baycom_state *)dev->priv;
+		struct net_device *dev = baycom_device[i];
 
-		if (bc) {
-			if (bc->hdrv.magic != HDLCDRV_MAGIC)
-				printk(KERN_ERR "baycom: invalid magic in "
-				       "cleanup_module\n");
-			else
-				hdlcdrv_unregister_hdlcdrv(dev);
-		}
+		if (dev)
+			hdlcdrv_unregister(dev);
 	}
 }
 
diff -urNp -X dontdiff net-2.5/drivers/net/hamradio/hdlcdrv.c linux-2.5-net/drivers/net/hamradio/hdlcdrv.c
--- net-2.5/drivers/net/hamradio/hdlcdrv.c	2003-09-19 10:20:48.000000000 -0700
+++ linux-2.5-net/drivers/net/hamradio/hdlcdrv.c	2003-09-09 16:36:16.000000000 -0700
@@ -729,25 +729,15 @@ static int hdlcdrv_ioctl(struct net_devi
 /* --------------------------------------------------------------------- */
 
 /*
- * Check for a network adaptor of this type, and return '0' if one exists.
- * If dev->base_addr == 0, probe all likely locations.
- * If dev->base_addr == 1, always return failure.
- * If dev->base_addr == 2, allocate space for the device and return success
- * (detachable devices only).
+ * Initialize fields in hdlcdrv
  */
-static int hdlcdrv_probe(struct net_device *dev)
+static void hdlcdrv_setup(struct net_device *dev)
 {
-	const struct hdlcdrv_channel_params dflt_ch_params = { 
+	static const struct hdlcdrv_channel_params dflt_ch_params = { 
 		20, 2, 10, 40, 0 
 	};
-	struct hdlcdrv_state *s;
+	struct hdlcdrv_state *s = dev->priv;;
 
-	if (!dev)
-		return -ENXIO;
-	/*
-	 * not a real probe! only initialize data structures
-	 */
-	s = (struct hdlcdrv_state *)dev->priv;
 	/*
 	 * initialize the hdlcdrv_state struct
 	 */
@@ -806,72 +796,60 @@ static int hdlcdrv_probe(struct net_devi
 	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
 	memcpy(dev->dev_addr, ax25_nocall, AX25_ADDR_LEN);
 	dev->tx_queue_len = 16;
-
-	/* New style flags */
-	dev->flags = 0;
-
-	return 0;
 }
 
 /* --------------------------------------------------------------------- */
-
-int hdlcdrv_register_hdlcdrv(struct net_device *dev, const struct hdlcdrv_ops *ops,
-			     unsigned int privsize, char *ifname,
-			     unsigned int baseaddr, unsigned int irq, 
-			     unsigned int dma) 
+struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
+				    unsigned int privsize, const char *ifname,
+				    unsigned int baseaddr, unsigned int irq, 
+				    unsigned int dma) 
 {
+	struct net_device *dev;
 	struct hdlcdrv_state *s;
+	int err;
+
+	BUG_ON(ops == NULL);
 
-	if (!dev || !ops)
-		return -EACCES;
 	if (privsize < sizeof(struct hdlcdrv_state))
 		privsize = sizeof(struct hdlcdrv_state);
-	memset(dev, 0, sizeof(struct net_device));
-	if (!(s = dev->priv = kmalloc(privsize, GFP_KERNEL)))
-		return -ENOMEM;
+
+	dev = alloc_netdev(privsize, ifname, hdlcdrv_setup);
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
 	/*
 	 * initialize part of the hdlcdrv_state struct
 	 */
-	memset(s, 0, privsize);
+	s = dev->priv;
 	s->magic = HDLCDRV_MAGIC;
-	strncpy(dev->name, ifname, sizeof(dev->name));
 	s->ops = ops;
-	/*
-	 * initialize part of the device struct
-	 */
-	dev->if_port = 0;
-	dev->init = hdlcdrv_probe;
 	dev->base_addr = baseaddr;
 	dev->irq = irq;
 	dev->dma = dma;
-	if (register_netdev(dev)) {
+
+	err = register_netdev(dev);
+	if (err < 0) {
 		printk(KERN_WARNING "hdlcdrv: cannot register net "
 		       "device %s\n", dev->name);
-		kfree(dev->priv);
-		return -ENXIO;
+		kfree(dev);
+		dev = ERR_PTR(err);
 	}
-	MOD_INC_USE_COUNT;
-	return 0;
+	return dev;
 }
 
 /* --------------------------------------------------------------------- */
 
-int hdlcdrv_unregister_hdlcdrv(struct net_device *dev) 
+void hdlcdrv_unregister(struct net_device *dev) 
 {
-	struct hdlcdrv_state *s;
+	struct hdlcdrv_state *s = dev->priv;
+
+	BUG_ON(s->magic != HDLCDRV_MAGIC);
 
-	if (!dev)
-		return -EINVAL;
-	if (!(s = (struct hdlcdrv_state *)dev->priv))
-		return -EINVAL;
-	if (s->magic != HDLCDRV_MAGIC)
-		return -EINVAL;
 	if (s->ops->close)
 		s->ops->close(dev);
 	unregister_netdev(dev);
-	kfree(s);
-	MOD_DEC_USE_COUNT;
-	return 0;
+	
+	free_netdev(dev);
 }
 
 /* --------------------------------------------------------------------- */
@@ -879,8 +857,8 @@ int hdlcdrv_unregister_hdlcdrv(struct ne
 EXPORT_SYMBOL(hdlcdrv_receiver);
 EXPORT_SYMBOL(hdlcdrv_transmitter);
 EXPORT_SYMBOL(hdlcdrv_arbitrate);
-EXPORT_SYMBOL(hdlcdrv_register_hdlcdrv);
-EXPORT_SYMBOL(hdlcdrv_unregister_hdlcdrv);
+EXPORT_SYMBOL(hdlcdrv_register);
+EXPORT_SYMBOL(hdlcdrv_unregister);
 
 /* --------------------------------------------------------------------- */
 
