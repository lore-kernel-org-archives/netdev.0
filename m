From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sealevel wan driver
Date: Mon, 15 Sep 2003 11:31:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915113101.544264af.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update sealevel driver to match current net_device interface:
	- dynamically allocate netdevice and private data.
	- get rid of MOD_INC/DEC
	- if_ptr not used 
	- bugfix: not all of board structure was being zeroed.

Note: this driver still doesn't probe() correctly since it just assumes that
if loaded the hardware is there!  

Since I don't have one of these boards...
tested it by #ifdef'ing out all the bits that touch actual hardware.

--- linux-2.5/drivers/net/wan/sealevel.c	2003-06-05 10:04:38.000000000 -0700
+++ linux-2.5-net/drivers/net/wan/sealevel.c	2003-09-15 11:28:36.031889622 -0700
@@ -31,7 +31,6 @@
 
 struct slvl_device
 {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_channel *chan;
 	struct ppp_device netdev;
 	int channel;
@@ -40,7 +39,7 @@ struct slvl_device
 
 struct slvl_board
 {
-	struct slvl_device dev[2];
+	struct slvl_device *dev[2];
 	struct z8530_dev board;
 	int iobase;
 };
@@ -119,7 +118,6 @@ static int sealevel_open(struct net_devi
 	 *	Go go go
 	 */
 	netif_start_queue(d);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -153,7 +151,6 @@ static int sealevel_close(struct net_dev
 			z8530_sync_close(d, slvl->chan);
 			break;
 	}
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -202,48 +199,79 @@ static int sealevel_neigh_setup_dev(stru
 	return 0;
 }
 
+		
+static void slvl_setup(struct net_device *d)
+{
+	d->open = sealevel_open;
+	d->stop = sealevel_close;
+	d->hard_start_xmit = sealevel_queue_xmit;
+	d->get_stats = sealevel_get_stats;
+	d->set_multicast_list = NULL;
+	d->do_ioctl = sealevel_ioctl;
+	d->neigh_setup = sealevel_neigh_setup_dev;
+	d->set_mac_address = NULL;
+
+}
+
+static inline struct slvl_device *slvl_alloc(int iobase, int irq)
+{
+	struct net_device *d;
+	struct slvl_device *sv;
+
+	d = alloc_netdev(sizeof(struct slvl_device), "hdlc%d",
+			 slvl_setup);
+
+	if (!d) 
+		return NULL;
+
+	sv = d->priv;
+	sv->netdev.dev = d;
+	d->base_addr = iobase;
+	d->irq = irq;
+		
+	sppp_attach(&sv->netdev);
+	return sv;
+}
+
+
 /*
- *	Description block for a Comtrol Hostess SV11 card
+ *	Allocate and setup Sealevel board.
  */
  
-static struct slvl_board *slvl_init(int iobase, int irq, int txdma, int rxdma, int slow)
+static __init struct slvl_board *slvl_init(int iobase, int irq, 
+					   int txdma, int rxdma, int slow)
 {
 	struct z8530_dev *dev;
-	struct slvl_device *sv;
 	struct slvl_board *b;
-	int u;
 	
 	/*
 	 *	Get the needed I/O space
 	 */
-	 
+
 	if(!request_region(iobase, 8, "Sealevel 4021")) 
 	{	
 		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n", iobase);
 		return NULL;
 	}
 	
-	b=(struct slvl_board *)kmalloc(sizeof(struct slvl_board), GFP_KERNEL);
+	b = kmalloc(sizeof(struct slvl_board), GFP_KERNEL);
 	if(!b)
 		goto fail3;
-			
-	memset(b, 0, sizeof(*sv));
 
-	b->dev[0].chan = &b->board.chanA;	
-	b->dev[0].if_ptr = &b->dev[0].netdev;
-	b->dev[0].netdev.dev=(struct net_device *)
-		kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if(!b->dev[0].netdev.dev)
+	memset(b, 0, sizeof(*b));
+	if (!(b->dev[0]= slvl_alloc(iobase, irq)))
 		goto fail2;
 
-	b->dev[1].chan = &b->board.chanB;
-	b->dev[1].if_ptr = &b->dev[1].netdev;
-	b->dev[1].netdev.dev=(struct net_device *)
-		kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if(!b->dev[1].netdev.dev)
+	b->dev[0]->chan = &b->board.chanA;	
+	b->dev[0]->channel = 0;
+	
+	if (!(b->dev[1] = slvl_alloc(iobase, irq)))
 		goto fail1_0;
 
-	dev=&b->board;
+	b->dev[1]->chan = &b->board.chanB;
+	b->dev[1]->channel = 1;
+
+	dev = &b->board;
 	
 	/*
 	 *	Stuff in the I/O addressing
@@ -287,8 +315,8 @@ static struct slvl_board *slvl_init(int 
 	dev->irq=irq;
 	dev->chanA.private=&b->dev[0];
 	dev->chanB.private=&b->dev[1];
-	dev->chanA.netdevice=b->dev[0].netdev.dev;
-	dev->chanB.netdevice=b->dev[1].netdev.dev;
+	dev->chanA.netdevice=b->dev[0]->netdev.dev;
+	dev->chanB.netdevice=b->dev[1]->netdev.dev;
 	dev->chanA.dev=dev;
 	dev->chanB.dev=dev;
 
@@ -329,55 +357,18 @@ static struct slvl_board *slvl_init(int 
 	
 	enable_irq(irq);
 
-	for(u=0; u<2; u++)
-	{
-		sv=&b->dev[u];
-		sv->channel = u;
-	
-		if(dev_alloc_name(sv->chan->netdevice,"hdlc%d")>=0)
-		{
-			struct net_device *d=sv->chan->netdevice;
-
-			/* 
-			 *	Initialise the PPP components
-			 */
-			sppp_attach(&sv->netdev);
-		
-			/*
-			 *	Local fields
-			 */	
-			
-			d->base_addr = iobase;
-			d->irq = irq;
-			d->priv = sv;
-			d->init = NULL;
-		
-			d->open = sealevel_open;
-			d->stop = sealevel_close;
-			d->hard_start_xmit = sealevel_queue_xmit;
-			d->get_stats = sealevel_get_stats;
-			d->set_multicast_list = NULL;
-			d->do_ioctl = sealevel_ioctl;
-			d->neigh_setup = sealevel_neigh_setup_dev;
-			d->set_mac_address = NULL;
+	if (register_netdev(b->dev[0]->netdev.dev)) 
+		goto dmafail2;
 		
-			if(register_netdev(d)==-1)
-			{
-				printk(KERN_ERR "%s: unable to register device.\n",
-					d->name);
-				goto fail_unit;
-			}				
+	if (register_netdev(b->dev[1]->netdev.dev)) 
+		goto fail_unit;
 
-			break;
-		}
-	}
 	z8530_describe(dev, "I/O", iobase);
 	dev->active=1;
 	return b;
 
 fail_unit:
-	if(u==1)
-		unregister_netdev(b->dev[0].chan->netdevice);
+	unregister_netdev(b->dev[0]->netdev.dev);
 	
 dmafail2:
 	free_dma(dev->chanA.rxdma);
@@ -386,9 +377,9 @@ dmafail:
 fail:
 	free_irq(irq, dev);
 fail1_1:
-	kfree(b->dev[1].netdev.dev);
+	free_netdev(b->dev[1]->netdev.dev);
 fail1_0:
-	kfree(b->dev[0].netdev.dev);
+	free_netdev(b->dev[0]->netdev.dev);
 fail2:
 	kfree(b);
 fail3:
@@ -396,7 +387,7 @@ fail3:
 	return NULL;
 }
 
-static void slvl_shutdown(struct slvl_board *b)
+static void __exit slvl_shutdown(struct slvl_board *b)
 {
 	int u;
 
@@ -404,8 +395,11 @@ static void slvl_shutdown(struct slvl_bo
 	
 	for(u=0; u<2; u++)
 	{
-		sppp_detach(b->dev[u].netdev.dev);
-		unregister_netdev(b->dev[u].netdev.dev);
+		struct net_device *d = b->dev[u]->netdev.dev;
+		sppp_detach(d);
+
+		unregister_netdev(d);
+		free_netdev(d);
 	}
 	
 	free_irq(b->board.irq, &b->board);
@@ -416,7 +410,6 @@ static void slvl_shutdown(struct slvl_bo
 	release_region(b->iobase, 8);
 }
 
-#ifdef MODULE
 
 static int io=0x238;
 static int txdma=1;
@@ -441,20 +434,22 @@ MODULE_DESCRIPTION("Modular driver for t
 
 static struct slvl_board *slvl_unit;
 
-int init_module(void)
+static int __init slvl_init_module(void)
 {
+#ifdef MODULE
 	printk(KERN_INFO "SeaLevel Z85230 Synchronous Driver v 0.02.\n");
-	printk(KERN_INFO "(c) Copyright 1998, Building Number Three Ltd.\n");	
-	if((slvl_unit=slvl_init(io,irq, txdma, rxdma, slow))==NULL)
-		return -ENODEV;
-	return 0;
+	printk(KERN_INFO "(c) Copyright 1998, Building Number Three Ltd.\n");
+#endif
+	slvl_unit = slvl_init(io, irq, txdma, rxdma, slow);
+
+	return slvl_unit ? 0 : -ENODEV;
 }
 
-void cleanup_module(void)
+static void __exit slvl_cleanup_module(void)
 {
 	if(slvl_unit)
 		slvl_shutdown(slvl_unit);
 }
 
-#endif
-
+module_init(slvl_init_module);
+module_exit(slvl_cleanup_module);
