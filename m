From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) wan/hostess_sv11 - use alloc_netdev instead of
 kmalloc
Date: Tue, 25 Nov 2003 11:48:19 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125114819.19f8dda6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert this driver from doing explicit kmalloc() for net_device to using
alloc_netdev().
Jeff, please apply to net-drivers-2.5-exp

diff -Nru a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
--- a/drivers/net/wan/hostess_sv11.c	Mon Nov 24 15:37:10 2003
+++ b/drivers/net/wan/hostess_sv11.c	Mon Nov 24 15:37:10 2003
@@ -201,6 +201,18 @@
 	return 0;
 }
 
+static __init void sv11_setup(struct net_device *d)
+{
+	d->open = hostess_open;
+	d->stop = hostess_close;
+	d->hard_start_xmit = hostess_queue_xmit;
+	d->get_stats = hostess_get_stats;
+	d->set_multicast_list = NULL;
+	d->do_ioctl = hostess_ioctl;
+	d->neigh_setup = hostess_neigh_setup_dev;
+	d->set_mac_address = NULL;
+}
+
 /*
  *	Description block for a Comtrol Hostess SV11 card
  */
@@ -209,6 +221,7 @@
 {
 	struct z8530_dev *dev;
 	struct sv11_device *sv;
+	struct net_device *d;
 	
 	/*
 	 *	Get the needed I/O space
@@ -220,17 +233,14 @@
 		return NULL;
 	}
 	
-	sv=(struct sv11_device *)kmalloc(sizeof(struct sv11_device), GFP_KERNEL);
-	if(!sv)
-		goto fail3;
-			
-	memset(sv, 0, sizeof(*sv));
-	sv->if_ptr=&sv->netdev;
-	
-	sv->netdev.dev=(struct net_device *)kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if(!sv->netdev.dev)
-		goto fail2;
+	d = alloc_netdev(sizeof(struct sv11_device),
+			 "hdlc%d", sv11_setup);
+	if (!d)
+		goto fail1;
 
+	sv = d->priv;
+	sv->if_ptr = &sv->netdev;
+	sv->netdev.dev=d;
 	dev=&sv->sync;
 	
 	/*
@@ -254,7 +264,7 @@
 	if(request_irq(irq, &z8530_interrupt, SA_INTERRUPT, "Hostess SV/11", dev)<0)
 	{
 		printk(KERN_WARNING "hostess: IRQ %d already in use.\n", irq);
-		goto fail1;
+		goto fail2;
 	}
 	
 	dev->irq=irq;
@@ -273,7 +283,7 @@
 		dev->chanA.rxdma=1;
 		outb(0x03|0x08, iobase+4);		/* DMA on */
 		if(request_dma(dev->chanA.txdma, "Hostess SV/11 (TX)")!=0)
-			goto fail;
+			goto fail3;
 			
 		if(dma==1)
 		{
@@ -308,66 +318,53 @@
 	/*
 	 *	Now we can take the IRQ
 	 */
-	if(dev_alloc_name(dev->chanA.netdevice,"hdlc%d")>=0)
-	{
-		struct net_device *d=dev->chanA.netdevice;
 
-		/* 
-		 *	Initialise the PPP components
-		 */
-		sppp_attach(&sv->netdev);
-		
-		/*
-		 *	Local fields
-		 */	
+	/* 
+	 *	Initialise the PPP components
+	 */
+	sppp_attach(&sv->netdev);
 		
-		d->base_addr = iobase;
-		d->irq = irq;
-		d->priv = sv;
-		d->init = NULL;
+	/*
+	 *	Local fields
+	 */	
 		
-		d->open = hostess_open;
-		d->stop = hostess_close;
-		d->hard_start_xmit = hostess_queue_xmit;
-		d->get_stats = hostess_get_stats;
-		d->set_multicast_list = NULL;
-		d->do_ioctl = hostess_ioctl;
-		d->neigh_setup = hostess_neigh_setup_dev;
-		d->set_mac_address = NULL;
+	d->base_addr = iobase;
+	d->irq = irq;
 		
-		if(register_netdev(d))
-		{
-			printk(KERN_ERR "%s: unable to register device.\n",
-				d->name);
-			goto fail;
-		}				
-
-		z8530_describe(dev, "I/O", iobase);
-		dev->active=1;
-		return sv;	
-	}
+	if(register_netdev(d)) {
+		printk(KERN_ERR "%s: unable to register device.\n",
+		       d->name);
+		goto regfail;
+	}				
+ 
+	z8530_describe(dev, "I/O", iobase);
+	dev->active=1;
+	return sv;	
+regfail:
+	sppp_detach(sv->netdev.dev);
+
 dmafail2:
 	if(dma==1)
 		free_dma(dev->chanA.rxdma);
 dmafail:
 	if(dma)
 		free_dma(dev->chanA.txdma);
-fail:
+fail3:
 	free_irq(irq, dev);
-fail1:
-	kfree(sv->netdev.dev);
 fail2:
-	kfree(sv);
-fail3:
+	free_netdev(d);
+fail1:
 	release_region(iobase,8);
 	return NULL;
 }
 
-static void sv11_shutdown(struct sv11_device *dev)
+static void __exit sv11_shutdown(struct sv11_device *dev)
 {
-	sppp_detach(dev->netdev.dev);
+	struct net_device *d = dev->netdev.dev;
+
+	sppp_detach(d);
 	z8530_shutdown(&dev->sync);
-	unregister_netdev(dev->netdev.dev);
+	unregister_netdev(d);
 	free_irq(dev->sync.irq, dev);
 	if(dma)
 	{
@@ -376,6 +373,7 @@
 		free_dma(dev->sync.chanA.txdma);
 	}
 	release_region(dev->sync.chanA.ctrlio-1, 8);
+	free_netdev(d);
 }
 
 #ifdef MODULE
