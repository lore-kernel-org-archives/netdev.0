From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix up hostess driver
Date: Tue, 16 Sep 2003 16:53:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916165303.3c31c4cb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup several problems that kept this driver from building  in 2.6.0-test5:
	- wrong include file.
	- use alloc_netdev and dev->priv
	- order of ppp_device and dev->priv is required for sppp_of
	- handle non-module initialization properly.

Tested by #ifdef'ing out all the naughty bits that talk to hardware
and doing load/unload.

diff -Nru a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
--- a/drivers/net/wan/hostess_sv11.c	Tue Sep 16 16:49:42 2003
+++ b/drivers/net/wan/hostess_sv11.c	Tue Sep 16 16:49:42 2003
@@ -33,15 +33,14 @@
 #include <asm/dma.h>
 #include <asm/byteorder.h>
 #include <net/syncppp.h>
-#include "z85229.h"
+#include "z85230.h"
 
 static int dma;
 
 struct sv11_device
 {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
+	struct ppp_device netdev;	/* must be first for spp_of()*/
 	struct z8530_dev sync;
-	struct ppp_device netdev;
 };
 
 /*
@@ -55,17 +54,21 @@
  
 static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 {
+	struct sv11_device *sv11 
+		= container_of(c->dev, struct sv11_device, sync);
+	struct net_device *dev = sv11->netdev.dev;
+
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
 	skb_trim(skb, skb->len-2);
 	skb->protocol=__constant_htons(ETH_P_WAN_PPP);
 	skb->mac.raw=skb->data;
-	skb->dev=c->netdevice;
+	skb->dev=dev;
 	/*
 	 *	Send it to the PPP layer. We don't have time to process
 	 *	it right now.
 	 */
 	netif_rx(skb);
-	c->netdevice->last_rx = jiffies;
+	dev->last_rx = jiffies;
 }
  
 /*
@@ -122,7 +125,6 @@
 	 */
 
 	netif_start_queue(d);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -154,7 +156,6 @@
 			z8530_sync_txdma_close(d, &sv11->sync.chanA);
 			break;
 	}
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -206,33 +207,40 @@
 /*
  *	Description block for a Comtrol Hostess SV11 card
  */
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
  
-static struct sv11_device *sv11_init(int iobase, int irq)
+static __init struct sv11_device *sv11_init(int iobase, int irq)
 {
 	struct z8530_dev *dev;
 	struct sv11_device *sv;
+	struct net_device *d;
 	
 	/*
 	 *	Get the needed I/O space
 	 */
-	 
 	if(!request_region(iobase, 8, "Comtrol SV11"))
 	{	
 		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n", iobase);
 		return NULL;
 	}
 	
-	sv=(struct sv11_device *)kmalloc(sizeof(struct sv11_device), GFP_KERNEL);
-	if(!sv)
+	d = alloc_netdev(sizeof(struct sv11_device),
+			 "hdlc%d", sv11_setup);
+	if (!d)
 		goto fail3;
-			
-	memset(sv, 0, sizeof(*sv));
-	sv->if_ptr=&sv->netdev;
-	
-	sv->netdev.dev=(struct net_device *)kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	if(!sv->netdev.dev)
-		goto fail2;
 
+	sv = d->priv;
+	sv->netdev.dev=d;
 	dev=&sv->sync;
 	
 	/*
@@ -310,44 +318,29 @@
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
 		
-		if(register_netdev(d)==-1)
-		{
-			printk(KERN_ERR "%s: unable to register device.\n",
-				d->name);
-			goto fail;
-		}				
+	if(register_netdev(d)) {
+		printk(KERN_ERR "%s: unable to register device.\n",
+		       d->name);
+		goto fail;
+	}				
+
+	z8530_describe(dev, "I/O", iobase);
+	dev->active=1;
+	return sv;	
 
-		z8530_describe(dev, "I/O", iobase);
-		dev->active=1;
-		return sv;	
-	}
 dmafail2:
 	if(dma==1)
 		free_dma(dev->chanA.rxdma);
@@ -356,31 +349,31 @@
 		free_dma(dev->chanA.txdma);
 fail:
 	free_irq(irq, dev);
-fail1:
-	kfree(sv->netdev.dev);
-fail2:
-	kfree(sv);
+
+	kfree(d);
 fail3:
 	release_region(iobase,8);
+fail1:
 	return NULL;
 }
 
-static void sv11_shutdown(struct sv11_device *dev)
+static void __exit sv11_shutdown(struct sv11_device *sv)
 {
-	sppp_detach(dev->netdev.dev);
-	z8530_shutdown(&dev->sync);
-	unregister_netdev(dev->netdev.dev);
-	free_irq(dev->sync.irq, dev);
-	if(dma)
-	{
+	struct net_device *d = sv->netdev.dev;
+	struct z8530_dev *dev = &sv->sync;
+
+	sppp_detach(d);
+	z8530_shutdown(dev);
+	unregister_netdev(d);
+	free_irq(sv->sync.irq, dev);
+	if(dma) {
 		if(dma==1)
-			free_dma(dev->sync.chanA.rxdma);
-		free_dma(dev->sync.chanA.txdma);
+			free_dma(sv->sync.chanA.rxdma);
+		free_dma(sv->sync.chanA.txdma);
 	}
-	release_region(dev->sync.chanA.ctrlio-1, 8);
+	release_region(sv->sync.chanA.ctrlio-1, 8);
 }
 
-#ifdef MODULE
 
 static int io=0x200;
 static int irq=9;
@@ -398,20 +391,22 @@
 
 static struct sv11_device *sv11_unit;
 
-int init_module(void)
+static int __init hostess_init_module(void)
 {
+#ifdef MODULE
 	printk(KERN_INFO "SV-11 Z85230 Synchronous Driver v 0.03.\n");
 	printk(KERN_INFO "(c) Copyright 2001, Red Hat Inc.\n");	
-	if((sv11_unit=sv11_init(io,irq))==NULL)
-		return -ENODEV;
-	return 0;
+#endif
+	sv11_unit =sv11_init(io,irq);
+	return sv11_unit ? 0 : -ENODEV;
 }
 
-void cleanup_module(void)
+static void __exit hostess_cleanup_module(void)
 {
 	if(sv11_unit)
 		sv11_shutdown(sv11_unit);
 }
 
-#endif
+module_init(hostess_init_module);
+module_exit(hostess_cleanup_module);
 
