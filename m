From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/8) ltpc - convert to new initialization
Date: Wed, 3 Sep 2003 16:49:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903164916.2809d4a5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Originally from Al Viro
NE11-ltpc
	* switched ltpc to dynamic allocation
	* ltpc: embedded ->priv
	* ltpc: fixed bugs in DMA allocation
	* ltpc: fixed resource leaks on failure exits
	* ltpc: fixed part of timer bugs (still a-f**ing-plenty of those)
	* ltpc: fixed order of freeing bugs
Added
	* switch to free_netdev

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Sep  3 15:11:52 2003
+++ b/drivers/net/Space.c	Wed Sep  3 15:11:52 2003
@@ -102,6 +102,9 @@
 #ifdef CONFIG_SDLA
 extern struct net_device *sdla_init(void);
 #endif
+#ifdef CONFIG_LTPC
+extern struct net_device *ltpc_probe(void);
+#endif
   
 /* Detachable devices ("pocket adaptors") */
 extern int de620_probe(struct net_device *);
@@ -392,22 +395,14 @@
 /*  Statically configured drivers -- order matters here. */
 void probe_old_netdevs(void)
 {
+#ifdef CONFIG_LTPC
+	ltpc_probe();
+#endif
 #ifdef CONFIG_SDLA
 	sdla_init();
 #endif
 
 }
-
-#if defined(CONFIG_LTPC)
-extern int ltpc_probe(struct net_device *);
-static struct net_device dev_ltpc = {
-	.name		= "lt0",
-	.next		= NEXT_DEV,
-	.init		= ltpc_probe
-};
-#undef NEXT_DEV
-#define NEXT_DEV	(&dev_ltpc)
-#endif  /* LTPC */
 
 #if defined(CONFIG_COPS)
 extern int cops_probe(struct net_device *);
diff -Nru a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
--- a/drivers/net/appletalk/ltpc.c	Wed Sep  3 15:11:52 2003
+++ b/drivers/net/appletalk/ltpc.c	Wed Sep  3 15:11:52 2003
@@ -879,34 +879,6 @@
 	return 0;
 }
 
-static int ltpc_init(struct net_device *dev)
-{
-	/* Initialize the device structure. */
-  
-	/* Fill in the fields of the device structure with ethernet-generic values. */
-	ltalk_setup(dev);
-	dev->hard_start_xmit = ltpc_xmit;
-	dev->hard_header = ltpc_hard_header;
-
-	dev->priv = kmalloc(sizeof(struct ltpc_private), GFP_KERNEL);
-	if(!dev->priv)
-	{
-		printk(KERN_INFO "%s: could not allocate statistics buffer\n", dev->name);
-		return -ENOMEM;
-	}
-
-	memset(dev->priv, 0, sizeof(struct ltpc_private));
-	dev->get_stats = ltpc_get_stats;
-
-	/* add the ltpc-specific things */
-	dev->do_ioctl = &ltpc_ioctl;
-
-	dev->set_multicast_list = &set_multicast_list;
-	dev->mc_list = NULL;
-
-	return 0;
-}
-
 static int ltpc_poll_counter;
 
 static void ltpc_poll(unsigned long l)
@@ -983,35 +955,40 @@
 
 /* initialization stuff */
   
-static int __init ltpc_probe_dma(int base)
+static int __init ltpc_probe_dma(int base, int dma)
 {
-	int dma = 0;
+	int want = (dma == 3) ? 2 : (dma == 1) ? 1 : 3;
   	unsigned long timeout;
   	unsigned long f;
   
-  	if (!request_dma(1,"ltpc")) {
-  		f=claim_dma_lock();
-  		disable_dma(1);
-  		clear_dma_ff(1);
-		set_dma_mode(1,DMA_MODE_WRITE);
-		set_dma_addr(1,virt_to_bus(ltdmabuf));
-		set_dma_count(1,sizeof(struct lt_mem));
-		enable_dma(1);
-		release_dma_lock(f);
-		dma|=1;
-	}
-	if (!request_dma(3,"ltpc")) {
-		f=claim_dma_lock();
-		disable_dma(3);
-		clear_dma_ff(3);
-		set_dma_mode(3,DMA_MODE_WRITE);
-		set_dma_addr(3,virt_to_bus(ltdmabuf));
-		set_dma_count(3,sizeof(struct lt_mem));
-		enable_dma(3);
-		release_dma_lock(f);
-		dma|=2;
+  	if (want & 1) {
+		if (request_dma(1,"ltpc")) {
+			want &= ~1;
+		} else {
+			f=claim_dma_lock();
+			disable_dma(1);
+			clear_dma_ff(1);
+			set_dma_mode(1,DMA_MODE_WRITE);
+			set_dma_addr(1,virt_to_bus(ltdmabuf));
+			set_dma_count(1,sizeof(struct lt_mem));
+			enable_dma(1);
+			release_dma_lock(f);
+		}
+	}
+	if (want & 2) {
+		if (request_dma(3,"ltpc")) {
+			want &= ~2;
+		} else {
+			f=claim_dma_lock();
+			disable_dma(3);
+			clear_dma_ff(3);
+			set_dma_mode(3,DMA_MODE_WRITE);
+			set_dma_addr(3,virt_to_bus(ltdmabuf));
+			set_dma_count(3,sizeof(struct lt_mem));
+			enable_dma(3);
+			release_dma_lock(f);
+		}
 	}
-
 	/* set up request */
 
 	/* FIXME -- do timings better! */
@@ -1037,65 +1014,62 @@
 
 	/* release the other dma channel (if we opened both of them) */
 
-	if ( (dma&0x2) && (get_dma_residue(3)==sizeof(struct lt_mem)) ){
-		dma&=1;
+	if ((want & 2) && (get_dma_residue(3)==sizeof(struct lt_mem))) {
+		want &= ~2;
 		free_dma(3);
 	}
-  
-	if ( (dma&0x1) && (get_dma_residue(1)==sizeof(struct lt_mem)) ){
-		dma&=0x2;
+
+	if ((want & 1) && (get_dma_residue(1)==sizeof(struct lt_mem))) {
+		want &= ~1;
 		free_dma(1);
 	}
 
-	/* fix up dma number */
-	dma|=1;
+	if (!want)
+		return 0;
 
-	return dma;
+	return (want & 2) ? 3 : 1;
 }
 
-int __init ltpc_probe(struct net_device *dev)
+struct net_device * __init ltpc_probe(void)
 {
-	int err;
+	struct net_device *dev;
+	int err = -ENOMEM;
 	int x=0,y=0;
 	int autoirq;
 	unsigned long f;
-	int portfound=0;
 	unsigned long timeout;
 
+	dev = alloc_netdev(sizeof(struct ltpc_private), "lt%d", ltalk_setup);
+	if (!dev)
+		goto out;
+
 	SET_MODULE_OWNER(dev);
 
 	/* probe for the I/O port address */
-	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
-		x = inb_p(0x220+6);
-		if ( (x!=0xff) && (x>=0xf0) ) {
-			io = 0x220;
-			portfound=1;
-		}
-		else {
-			release_region(0x220,8);
-		}
-	}
 	
 	if (io != 0x220 && request_region(0x240,8,"ltpc")) {
 		y = inb_p(0x240+6);
 		if ( (y!=0xff) && (y>=0xf0) ){ 
 			io = 0x240;
-			portfound=1;
-		}
-		else {
-			release_region(0x240,8);
+			goto got_port;
 		}
+		release_region(0x240,8);
 	} 
-
-	if(io && !portfound && request_region(io,8,"ltpc")){
-		portfound = 1;
-	}
-	if(!portfound) {
-		/* give up in despair */
-		printk(KERN_ERR "LocalTalk card not found; 220 = %02x, 240 = %02x.\n", x,y);
-		return -1;
+	if (io != 0x240 && request_region(0x220,8,"ltpc")) {
+		x = inb_p(0x220+6);
+		if ( (x!=0xff) && (x>=0xf0) ) {
+			io = 0x220;
+			goto got_port;
+		}
+		release_region(0x220,8);
 	}
 
+	/* give up in despair */
+	printk(KERN_ERR "LocalTalk card not found; 220 = %02x, 240 = %02x.\n", x,y);
+	err = -ENODEV;
+	goto out1;
+
+ got_port:
 	/* probe for the IRQ line */
 	if (irq < 2) {
 		unsigned long irq_mask;
@@ -1111,22 +1085,21 @@
 
 		if (autoirq == 0) {
 			printk(KERN_ERR "ltpc: probe at %#x failed to detect IRQ line.\n", io);
-		}
-		else {
+		} else {
 			irq = autoirq;
 		}
 	}
 
 	/* allocate a DMA buffer */
 	ltdmabuf = (unsigned char *) dma_mem_alloc(1000);
-
-	if (ltdmabuf) ltdmacbuf = &ltdmabuf[800];
-
 	if (!ltdmabuf) {
 		printk(KERN_ERR "ltpc: mem alloc failed\n");
-		return -1;
+		err = -ENOMEM;
+		goto out2;
 	}
 
+	ltdmacbuf = &ltdmabuf[800];
+
 	if(debug & DEBUG_VERBOSE) {
 		printk("ltdmabuf pointer %08lx\n",(unsigned long) ltdmabuf);
 	}
@@ -1154,25 +1127,29 @@
 	   already been specified */
 	/* well, 0 is a legal DMA channel, but the LTPC card doesn't
 	   use it... */
-	if (dma == 0) {
-		dma = ltpc_probe_dma(io);
-		if (!dma) {  /* no dma channel */
-			printk(KERN_ERR "No DMA channel found on ltpc card.\n");
-			return -1;
-		}
+	dma = ltpc_probe_dma(io, dma);
+	if (!dma) {  /* no dma channel */
+		printk(KERN_ERR "No DMA channel found on ltpc card.\n");
+		err = -ENODEV;
+		goto out3;
 	}
 
 	/* print out friendly message */
-
 	if(irq)
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, IR%d, DMA%d.\n",io,irq,dma);
 	else
 		printk(KERN_INFO "Apple/Farallon LocalTalk-PC card at %03x, DMA%d.  Using polled mode.\n",io,dma);
 
-	/* seems more logical to do this *after* probing the card... */
-	err = ltpc_init(dev);
-	if (err) return err;
+	/* Fill in the fields of the device structure with ethernet-generic values. */
+	dev->hard_start_xmit = ltpc_xmit;
+	dev->hard_header = ltpc_hard_header;
+	dev->get_stats = ltpc_get_stats;
+
+	/* add the ltpc-specific things */
+	dev->do_ioctl = &ltpc_ioctl;
 
+	dev->set_multicast_list = &set_multicast_list;
+	dev->mc_list = NULL;
 	dev->base_addr = io;
 	dev->irq = irq;
 	dev->dma = dma;
@@ -1212,6 +1189,7 @@
 	} else {
 		if( irq )
 			printk(KERN_ERR "ltpc: IRQ already in use, using polled mode.\n");
+		dev->irq = 0;
 		/* polled mode -- 20 times per second */
 		/* this is really, really slow... should it poll more often? */
 		init_timer(&ltpc_timer);
@@ -1221,8 +1199,23 @@
 		ltpc_timer.expires = jiffies + HZ/20;
 		add_timer(&ltpc_timer);
 	}
+	err = register_netdev(dev);
+	if (err)
+		goto out4;
 
 	return 0;
+out4:
+	del_timer_sync(&ltpc_timer);
+	if (dev->irq)
+		free_irq(dev->irq, dev);
+out3:
+	free_pages((unsigned long)ltdmabuf, get_order(1000));
+out2:
+	release_region(io, 8);
+out1:
+	kfree(dev);
+out:
+	return ERR_PTR(err);
 }
 
 #ifndef MODULE
@@ -1259,7 +1252,7 @@
 __setup("ltpc=", ltpc_setup);
 #endif /* MODULE */
 
-static struct net_device dev_ltpc;
+static struct net_device *dev_ltpc;
 
 #ifdef MODULE
 
@@ -1272,79 +1265,47 @@
 
 int __init init_module(void)
 {
-	int err, result;
-	
         if(io == 0)
 		printk(KERN_NOTICE
 		       "ltpc: Autoprobing is not recommended for modules\n");
 
-	/* Find a name for this unit */
-	dev_ltpc.init = ltpc_probe;
-	err=dev_alloc_name(&dev_ltpc,"lt%d");
-	
-	if(err<0)
-		return err;
-
-	if ((result = register_netdev(&dev_ltpc)) != 0) {
-		printk(KERN_DEBUG "could not register Localtalk-PC device\n");
-		return result;
-	} else {
-		if(debug & DEBUG_VERBOSE) printk("0 from register_netdev\n");
-		return 0;
-	}
+	dev_ltpc = ltpc_probe();
+	if (IS_ERR(dev_ltpc))
+		return PTR_ERR(dev_ltpc);
+	return 0;
 }
 #endif
 
 static void __exit ltpc_cleanup(void)
 {
-	unsigned long timeout;
+
+	if(debug & DEBUG_VERBOSE) printk("unregister_netdev\n");
+	unregister_netdev(dev_ltpc);
 
 	ltpc_timer.data = 0;  /* signal the poll routine that we're done */
 
+	del_timer_sync(&ltpc_timer);
+
 	if(debug & DEBUG_VERBOSE) printk("freeing irq\n");
 
-	if(dev_ltpc.irq) {
-		free_irq(dev_ltpc.irq,&dev_ltpc);
-		dev_ltpc.irq = 0;
-	}
-
-	if(del_timer(&ltpc_timer)) 
-	{
-		/* either the poll was never started, or a poll is in process */
-		if(debug & DEBUG_VERBOSE) printk("waiting\n");
-		/* if it's in process, wait a bit for it to finish */
-		timeout = jiffies+HZ; 
-		add_timer(&ltpc_timer);
-		while(del_timer(&ltpc_timer) && time_after(timeout, jiffies))
-		{
-			add_timer(&ltpc_timer);
-			schedule();
-		}
-	}
+	if (dev_ltpc->irq)
+		free_irq(dev_ltpc->irq, dev_ltpc);
 
 	if(debug & DEBUG_VERBOSE) printk("freeing dma\n");
 
-	if(dev_ltpc.dma) {
-		free_dma(dev_ltpc.dma);
-		dev_ltpc.dma = 0;
-	}
+	if (dev_ltpc->dma)
+		free_dma(dev_ltpc->dma);
 
 	if(debug & DEBUG_VERBOSE) printk("freeing ioaddr\n");
 
-	if(dev_ltpc.base_addr) {
-		release_region(dev_ltpc.base_addr,8);
-		dev_ltpc.base_addr = 0;
-	}
+	if (dev_ltpc->base_addr)
+		release_region(dev_ltpc->base_addr,8);
+
+	free_netdev(dev_ltpc);
 
 	if(debug & DEBUG_VERBOSE) printk("free_pages\n");
 
 	free_pages( (unsigned long) ltdmabuf, get_order(1000));
-	ltdmabuf=NULL;
-	ltdmacbuf=NULL;
-
-	if(debug & DEBUG_VERBOSE) printk("unregister_netdev\n");
-
-	unregister_netdev(&dev_ltpc);
 
 	if(debug & DEBUG_VERBOSE) printk("returning from cleanup_module\n");
 }
