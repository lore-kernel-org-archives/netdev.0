From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Convert Zilog-based drivers to generic HDLC
Date: Wed, 02 Jul 2008 21:19:30 +0200
Message-ID: <m3k5g43xh9.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52232 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbYGBTXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

WAN: Convert Zilog-based drivers to generic HDLC
    
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index e033366..9624d0f 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -25,7 +25,7 @@ if WAN
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET && HDLC
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -88,7 +88,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET && HDLC
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 9d085e0..5d27a17 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -21,11 +21,11 @@ pc300-y				:= pc300_drv.o
 pc300-$(CONFIG_PC300_MLPPP)	+= pc300_tty.o
 pc300-objs			:= $(pc300-y)
 
-obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	syncppp.o	hostess_sv11.o
-obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	syncppp.o	sealevel.o
+obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	hostess_sv11.o
+obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	sealevel.o
 obj-$(CONFIG_COSA)		+= cosa.o
 obj-$(CONFIG_FARSYNC)		+= farsync.o
-obj-$(CONFIG_DSCC4)             +=				dscc4.o
+obj-$(CONFIG_DSCC4)             += dscc4.o
 obj-$(CONFIG_LANMEDIA)		+=		syncppp.o
 obj-$(CONFIG_X25_ASY)		+= x25_asy.o
 
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index f3065d3..e299313 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -16,6 +16,8 @@
  *	touching control registers.
  *
  *	Port B isnt wired (why - beats me)
+ *
+ *	Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  */
 
 #include <linux/module.h>
@@ -26,6 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <net/arp.h>
 
@@ -33,34 +36,31 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
-#include <net/syncppp.h>
 #include "z85230.h"
 
 static int dma;
 
-struct sv11_device
-{
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
-	struct z8530_dev sync;
-	struct ppp_device netdev;
-};
-
 /*
  *	Network driver support routines
  */
 
+static inline struct z8530_dev* dev_to_sv(struct net_device *dev)
+{
+	return (struct z8530_dev *)dev_to_hdlc(dev)->priv;
+}
+
 /*
- *	Frame receive. Simple for our card as we do sync ppp and there
+ *	Frame receive. Simple for our card as we do HDLC and there
  *	is no funny garbage involved
  */
- 
+
 static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 {
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
-	skb_trim(skb, skb->len-2);
-	skb->protocol=__constant_htons(ETH_P_WAN_PPP);
+	skb_trim(skb, skb->len - 2);
+	skb->protocol = hdlc_type_trans(skb, c->netdevice);
 	skb_reset_mac_header(skb);
-	skb->dev=c->netdevice;
+	skb->dev = c->netdevice;
 	/*
 	 *	Send it to the PPP layer. We don't have time to process
 	 *	it right now.
@@ -68,56 +68,51 @@ static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 	netif_rx(skb);
 	c->netdevice->last_rx = jiffies;
 }
- 
+
 /*
  *	We've been placed in the UP state
- */ 
- 
+ */
+
 static int hostess_open(struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
+	struct z8530_dev *sv11 = dev_to_sv(d);
 	int err = -1;
-	
+
 	/*
 	 *	Link layer up
 	 */
-	switch(dma)
-	{
+	switch (dma) {
 		case 0:
-			err=z8530_sync_open(d, &sv11->sync.chanA);
+			err = z8530_sync_open(d, &sv11->chanA);
 			break;
 		case 1:
-			err=z8530_sync_dma_open(d, &sv11->sync.chanA);
+			err = z8530_sync_dma_open(d, &sv11->chanA);
 			break;
 		case 2:
-			err=z8530_sync_txdma_open(d, &sv11->sync.chanA);
+			err = z8530_sync_txdma_open(d, &sv11->chanA);
 			break;
 	}
-	
-	if(err)
+
+	if (err)
 		return err;
-	/*
-	 *	Begin PPP
-	 */
-	err=sppp_open(d);
-	if(err)
-	{
-		switch(dma)
-		{
+
+	err = hdlc_open(d);
+	if (err) {
+		switch (dma) {
 			case 0:
-				z8530_sync_close(d, &sv11->sync.chanA);
+				z8530_sync_close(d, &sv11->chanA);
 				break;
 			case 1:
-				z8530_sync_dma_close(d, &sv11->sync.chanA);
+				z8530_sync_dma_close(d, &sv11->chanA);
 				break;
 			case 2:
-				z8530_sync_txdma_close(d, &sv11->sync.chanA);
+				z8530_sync_txdma_close(d, &sv11->chanA);
 				break;
-		}				
+		}
 		return err;
 	}
-	sv11->sync.chanA.rx_function=hostess_input;
-	
+	sv11->chanA.rx_function = hostess_input;
+
 	/*
 	 *	Go go go
 	 */
@@ -128,30 +123,24 @@ static int hostess_open(struct net_device *d)
 
 static int hostess_close(struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
+	struct z8530_dev *sv11 = dev_to_sv(d);
 	/*
 	 *	Discard new frames
 	 */
-	sv11->sync.chanA.rx_function=z8530_null_rx;
-	/*
-	 *	PPP off
-	 */
-	sppp_close(d);
-	/*
-	 *	Link layer down
-	 */
+	sv11->chanA.rx_function = z8530_null_rx;
+
+	hdlc_close(d);
 	netif_stop_queue(d);
-		
-	switch(dma)
-	{
+
+	switch (dma) {
 		case 0:
-			z8530_sync_close(d, &sv11->sync.chanA);
+			z8530_sync_close(d, &sv11->chanA);
 			break;
 		case 1:
-			z8530_sync_dma_close(d, &sv11->sync.chanA);
+			z8530_sync_dma_close(d, &sv11->chanA);
 			break;
 		case 2:
-			z8530_sync_txdma_close(d, &sv11->sync.chanA);
+			z8530_sync_txdma_close(d, &sv11->chanA);
 			break;
 	}
 	return 0;
@@ -159,232 +148,174 @@ static int hostess_close(struct net_device *d)
 
 static int hostess_ioctl(struct net_device *d, struct ifreq *ifr, int cmd)
 {
-	/* struct sv11_device *sv11=d->ml_priv;
-	   z8530_ioctl(d,&sv11->sync.chanA,ifr,cmd) */
-	return sppp_do_ioctl(d, ifr,cmd);
-}
-
-static struct net_device_stats *hostess_get_stats(struct net_device *d)
-{
-	struct sv11_device *sv11=d->ml_priv;
-	if(sv11)
-		return z8530_get_stats(&sv11->sync.chanA);
-	else
-		return NULL;
+	/* struct z8530_dev *sv11=dev_to_sv(d);
+	   z8530_ioctl(d,&sv11->chanA,ifr,cmd) */
+	return hdlc_ioctl(d, ifr, cmd);
 }
 
 /*
- *	Passed PPP frames, fire them downwind.
+ *	Passed network frames, fire them downwind.
  */
- 
+
 static int hostess_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
-	return z8530_queue_xmit(&sv11->sync.chanA, skb);
+	return z8530_queue_xmit(&dev_to_sv(d)->chanA, skb);
 }
 
-static int hostess_neigh_setup(struct neighbour *n)
+static int hostess_attach(struct net_device *dev, unsigned short encoding,
+			  unsigned short parity)
 {
-	if (n->nud_state == NUD_NONE) {
-		n->ops = &arp_broken_ops;
-		n->output = n->ops->output;
-	}
-	return 0;
-}
-
-static int hostess_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
-{
-	if (p->tbl->family == AF_INET) {
-		p->neigh_setup = hostess_neigh_setup;
-		p->ucast_probes = 0;
-		p->mcast_probes = 0;
-	}
-	return 0;
-}
-
-static void sv11_setup(struct net_device *dev)
-{	
-	dev->open = hostess_open;
-	dev->stop = hostess_close;
-	dev->hard_start_xmit = hostess_queue_xmit;
-	dev->get_stats = hostess_get_stats;
-	dev->do_ioctl = hostess_ioctl;
-	dev->neigh_setup = hostess_neigh_setup_dev;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
 /*
  *	Description block for a Comtrol Hostess SV11 card
  */
- 
-static struct sv11_device *sv11_init(int iobase, int irq)
+
+static struct z8530_dev *sv11_init(int iobase, int irq)
 {
-	struct z8530_dev *dev;
-	struct sv11_device *sv;
-	
+	struct z8530_dev *sv;
+	struct net_device *netdev;
 	/*
 	 *	Get the needed I/O space
 	 */
-	 
-	if(!request_region(iobase, 8, "Comtrol SV11"))
-	{	
-		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n", iobase);
+
+	if (!request_region(iobase, 8, "Comtrol SV11")) {
+		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n",
+		       iobase);
 		return NULL;
 	}
-	
-	sv = kzalloc(sizeof(struct sv11_device), GFP_KERNEL);
-	if(!sv)
-		goto fail3;
-			
-	sv->if_ptr=&sv->netdev;
-	
-	sv->netdev.dev = alloc_netdev(0, "hdlc%d", sv11_setup);
-	if(!sv->netdev.dev)
-		goto fail2;
-
-	dev=&sv->sync;
-	
+
+	sv = kzalloc(sizeof(struct z8530_dev), GFP_KERNEL);
+	if (!sv)
+		goto err_kzalloc;
+
 	/*
 	 *	Stuff in the I/O addressing
 	 */
-	 
-	dev->active = 0;
-	
-	dev->chanA.ctrlio=iobase+1;
-	dev->chanA.dataio=iobase+3;
-	dev->chanB.ctrlio=-1;
-	dev->chanB.dataio=-1;
-	dev->chanA.irqs=&z8530_nop;
-	dev->chanB.irqs=&z8530_nop;
-	
-	outb(0, iobase+4);		/* DMA off */
-	
+
+	sv->active = 0;
+
+	sv->chanA.ctrlio = iobase + 1;
+	sv->chanA.dataio = iobase + 3;
+	sv->chanB.ctrlio = -1;
+	sv->chanB.dataio = -1;
+	sv->chanA.irqs = &z8530_nop;
+	sv->chanB.irqs = &z8530_nop;
+
+	outb(0, iobase + 4);		/* DMA off */
+
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
-	   
-	if(request_irq(irq, &z8530_interrupt, IRQF_DISABLED, "Hostess SV11", dev)<0)
-	{
+
+	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+			"Hostess SV11", sv) < 0) {
 		printk(KERN_WARNING "hostess: IRQ %d already in use.\n", irq);
-		goto fail1;
+		goto err_irq;
 	}
-	
-	dev->irq=irq;
-	dev->chanA.private=sv;
-	dev->chanA.netdevice=sv->netdev.dev;
-	dev->chanA.dev=dev;
-	dev->chanB.dev=dev;
-	
-	if(dma)
-	{
+
+	sv->irq = irq;
+	sv->chanA.private = sv;
+	sv->chanA.dev = sv;
+	sv->chanB.dev = sv;
+
+	if (dma) {
 		/*
 		 *	You can have DMA off or 1 and 3 thats the lot
 		 *	on the Comtrol.
 		 */
-		dev->chanA.txdma=3;
-		dev->chanA.rxdma=1;
-		outb(0x03|0x08, iobase+4);		/* DMA on */
-		if(request_dma(dev->chanA.txdma, "Hostess SV/11 (TX)")!=0)
-			goto fail;
-			
-		if(dma==1)
-		{
-			if(request_dma(dev->chanA.rxdma, "Hostess SV/11 (RX)")!=0)
-				goto dmafail;
-		}
+		sv->chanA.txdma = 3;
+		sv->chanA.rxdma = 1;
+		outb(0x03 | 0x08, iobase + 4);		/* DMA on */
+		if (request_dma(sv->chanA.txdma, "Hostess SV/11 (TX)"))
+			goto err_txdma;
+
+		if (dma == 1)
+			if (request_dma(sv->chanA.rxdma, "Hostess SV/11 (RX)"))
+				goto err_rxdma;
 	}
 
 	/* Kill our private IRQ line the hostess can end up chattering
 	   until the configuration is set */
 	disable_irq(irq);
-		
+
 	/*
 	 *	Begin normal initialise
 	 */
-	 
-	if(z8530_init(dev)!=0)
-	{
+
+	if (z8530_init(sv)) {
 		printk(KERN_ERR "Z8530 series device not found.\n");
 		enable_irq(irq);
-		goto dmafail2;
+		goto free_dma;
 	}
-	z8530_channel_load(&dev->chanB, z8530_dead_port);
-	if(dev->type==Z85C30)
-		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream);
+	z8530_channel_load(&sv->chanB, z8530_dead_port);
+	if (sv->type == Z85C30)
+		z8530_channel_load(&sv->chanA, z8530_hdlc_kilostream);
 	else
-		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream_85230);
-	
+		z8530_channel_load(&sv->chanA, z8530_hdlc_kilostream_85230);
+
 	enable_irq(irq);
-	
 
 	/*
 	 *	Now we can take the IRQ
 	 */
-	if(dev_alloc_name(dev->chanA.netdevice,"hdlc%d")>=0)
-	{
-		struct net_device *d=dev->chanA.netdevice;
 
-		/* 
-		 *	Initialise the PPP components
-		 */
-		d->ml_priv = sv;
-		sppp_attach(&sv->netdev);
-		
-		/*
-		 *	Local fields
-		 */	
-		
-		d->base_addr = iobase;
-		d->irq = irq;
-		
-		if(register_netdev(d))
-		{
-			printk(KERN_ERR "%s: unable to register device.\n",
-				d->name);
-			sppp_detach(d);
-			goto dmafail2;
-		}
+	sv->chanA.netdevice = netdev = alloc_hdlcdev(sv);
+	if (!netdev)
+		goto free_dma;
 
-		z8530_describe(dev, "I/O", iobase);
-		dev->active=1;
-		return sv;	
+	dev_to_hdlc(netdev)->attach = hostess_attach;
+	dev_to_hdlc(netdev)->xmit = hostess_queue_xmit;
+	netdev->open = hostess_open;
+	netdev->stop = hostess_close;
+	netdev->do_ioctl = hostess_ioctl;
+	netdev->base_addr = iobase;
+	netdev->irq = irq;
+
+	if (register_hdlc_device(netdev)) {
+		printk(KERN_ERR "hostess: unable to register HDLC device.\n");
+		free_netdev(netdev);
+		goto free_dma;
 	}
-dmafail2:
-	if(dma==1)
-		free_dma(dev->chanA.rxdma);
-dmafail:
-	if(dma)
-		free_dma(dev->chanA.txdma);
-fail:
-	free_irq(irq, dev);
-fail1:
-	free_netdev(sv->netdev.dev);
-fail2:
+
+	z8530_describe(sv, "I/O", iobase);
+	sv->active = 1;
+	return sv;
+
+free_dma:
+	if (dma == 1)
+		free_dma(sv->chanA.rxdma);
+err_rxdma:
+	if (dma)
+		free_dma(sv->chanA.txdma);
+err_txdma:
+	free_irq(irq, sv);
+err_irq:
 	kfree(sv);
-fail3:
-	release_region(iobase,8);
+err_kzalloc:
+	release_region(iobase, 8);
 	return NULL;
 }
 
-static void sv11_shutdown(struct sv11_device *dev)
+static void sv11_shutdown(struct z8530_dev *dev)
 {
-	sppp_detach(dev->netdev.dev);
-	unregister_netdev(dev->netdev.dev);
-	z8530_shutdown(&dev->sync);
-	free_irq(dev->sync.irq, dev);
-	if(dma)
-	{
-		if(dma==1)
-			free_dma(dev->sync.chanA.rxdma);
-		free_dma(dev->sync.chanA.txdma);
+	unregister_hdlc_device(dev->chanA.netdevice);
+	z8530_shutdown(dev);
+	free_irq(dev->irq, dev);
+	if (dma) {
+		if (dma == 1)
+			free_dma(dev->chanA.rxdma);
+		free_dma(dev->chanA.txdma);
 	}
-	release_region(dev->sync.chanA.ctrlio-1, 8);
-	free_netdev(dev->netdev.dev);
+	release_region(dev->chanA.ctrlio - 1, 8);
+	free_netdev(dev->chanA.netdevice);
 	kfree(dev);
 }
 
-#ifdef MODULE
-
-static int io=0x200;
-static int irq=9;
+static int io = 0x200;
+static int irq = 9;
 
 module_param(io, int, 0);
 MODULE_PARM_DESC(io, "The I/O base of the Comtrol Hostess SV11 card");
@@ -397,22 +328,17 @@ MODULE_AUTHOR("Alan Cox");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Modular driver for the Comtrol Hostess SV11");
 
-static struct sv11_device *sv11_unit;
+static struct z8530_dev *sv11_unit;
 
 int init_module(void)
 {
-	printk(KERN_INFO "SV-11 Z85230 Synchronous Driver v 0.03.\n");
-	printk(KERN_INFO "(c) Copyright 2001, Red Hat Inc.\n");	
-	if((sv11_unit=sv11_init(io,irq))==NULL)
+	if ((sv11_unit = sv11_init(io, irq)) == NULL)
 		return -ENODEV;
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	if(sv11_unit)
+	if (sv11_unit)
 		sv11_shutdown(sv11_unit);
 }
-
-#endif
-
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 44a89df..c023584 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -8,6 +8,7 @@
  *
  *	(c) Copyright 1999, 2001 Alan Cox
  *	(c) Copyright 2001 Red Hat Inc.
+ *	Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  */
 
@@ -19,6 +20,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <net/arp.h>
@@ -27,22 +29,19 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
-#include <net/syncppp.h>
 #include "z85230.h"
 
 
 struct slvl_device
 {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_channel *chan;
-	struct ppp_device pppdev;
 	int channel;
 };
 
 
 struct slvl_board
 {
-	struct slvl_device *dev[2];
+	struct slvl_device dev[2];
 	struct z8530_dev board;
 	int iobase;
 };
@@ -51,72 +50,69 @@ struct slvl_board
  *	Network driver support routines
  */
 
+static inline struct slvl_device* dev_to_chan(struct net_device *dev)
+{
+	return (struct slvl_device *)dev_to_hdlc(dev)->priv;
+}
+
 /*
- *	Frame receive. Simple for our card as we do sync ppp and there
+ *	Frame receive. Simple for our card as we do HDLC and there
  *	is no funny garbage involved
  */
- 
+
 static void sealevel_input(struct z8530_channel *c, struct sk_buff *skb)
 {
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
-	skb_trim(skb, skb->len-2);
-	skb->protocol=htons(ETH_P_WAN_PPP);
+	skb_trim(skb, skb->len - 2);
+	skb->protocol = hdlc_type_trans(skb, c->netdevice);
 	skb_reset_mac_header(skb);
-	skb->dev=c->netdevice;
-	/*
-	 *	Send it to the PPP layer. We don't have time to process
-	 *	it right now.
-	 */
+	skb->dev = c->netdevice;
 	netif_rx(skb);
 	c->netdevice->last_rx = jiffies;
 }
- 
+
 /*
  *	We've been placed in the UP state
- */ 
- 
+ */
+
 static int sealevel_open(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl = dev_to_chan(d);
 	int err = -1;
 	int unit = slvl->channel;
-	
+
 	/*
-	 *	Link layer up. 
+	 *	Link layer up.
 	 */
 
-	switch(unit)
+	switch (unit)
 	{
 		case 0:
-			err=z8530_sync_dma_open(d, slvl->chan);
+			err = z8530_sync_dma_open(d, slvl->chan);
 			break;
 		case 1:
-			err=z8530_sync_open(d, slvl->chan);
+			err = z8530_sync_open(d, slvl->chan);
 			break;
 	}
-	
-	if(err)
+
+	if (err)
 		return err;
-	/*
-	 *	Begin PPP
-	 */
-	err=sppp_open(d);
-	if(err)
-	{
-		switch(unit)
-		{
+
+	err = hdlc_open(d);
+	if (err) {
+		switch (unit) {
 			case 0:
 				z8530_sync_dma_close(d, slvl->chan);
 				break;
 			case 1:
 				z8530_sync_close(d, slvl->chan);
 				break;
-		}				
+		}
 		return err;
 	}
-	
-	slvl->chan->rx_function=sealevel_input;
-	
+
+	slvl->chan->rx_function = sealevel_input;
+
 	/*
 	 *	Go go go
 	 */
@@ -126,26 +122,19 @@ static int sealevel_open(struct net_device *d)
 
 static int sealevel_close(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl = dev_to_chan(d);
 	int unit = slvl->channel;
-	
+
 	/*
 	 *	Discard new frames
 	 */
-	
-	slvl->chan->rx_function=z8530_null_rx;
-		
-	/*
-	 *	PPP off
-	 */
-	sppp_close(d);
-	/*
-	 *	Link layer down
-	 */
 
+	slvl->chan->rx_function = z8530_null_rx;
+
+	hdlc_close(d);
 	netif_stop_queue(d);
-		
-	switch(unit)
+
+	switch (unit)
 	{
 		case 0:
 			z8530_sync_dma_close(d, slvl->chan);
@@ -159,210 +148,153 @@ static int sealevel_close(struct net_device *d)
 
 static int sealevel_ioctl(struct net_device *d, struct ifreq *ifr, int cmd)
 {
-	/* struct slvl_device *slvl=d->priv;
+	/* struct slvl_device *slvl=dev_to_chan(d);
 	   z8530_ioctl(d,&slvl->sync.chanA,ifr,cmd) */
-	return sppp_do_ioctl(d, ifr,cmd);
-}
-
-static struct net_device_stats *sealevel_get_stats(struct net_device *d)
-{
-	struct slvl_device *slvl=d->priv;
-	if(slvl)
-		return z8530_get_stats(slvl->chan);
-	else
-		return NULL;
+	return hdlc_ioctl(d, ifr, cmd);
 }
 
 /*
- *	Passed PPP frames, fire them downwind.
+ *	Passed network frames, fire them downwind.
  */
- 
+
 static int sealevel_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
-	return z8530_queue_xmit(slvl->chan, skb);
+	return z8530_queue_xmit(dev_to_chan(d)->chan, skb);
 }
 
-static int sealevel_neigh_setup(struct neighbour *n)
+static int sealevel_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity)
 {
-	if (n->nud_state == NUD_NONE) {
-		n->ops = &arp_broken_ops;
-		n->output = n->ops->output;
-	}
-	return 0;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-static int sealevel_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
+static int slvl_setup(struct slvl_device *sv, int iobase, int irq)
 {
-	if (p->tbl->family == AF_INET) {
-		p->neigh_setup = sealevel_neigh_setup;
-		p->ucast_probes = 0;
-		p->mcast_probes = 0;
+	struct net_device *dev = alloc_hdlcdev(sv);
+	if (!dev)
+		return -1;
+
+	dev_to_hdlc(dev)->attach = sealevel_attach;
+	dev_to_hdlc(dev)->xmit = sealevel_queue_xmit;
+	dev->open = sealevel_open;
+	dev->stop = sealevel_close;
+	dev->do_ioctl = sealevel_ioctl;
+	dev->base_addr = iobase;
+	dev->irq = irq;
+
+	if (register_hdlc_device(dev)) {
+		printk(KERN_ERR "sealevel: unable to register HDLC device\n");
+		free_netdev(dev);
+		return -1;
 	}
-	return 0;
-}
 
-static int sealevel_attach(struct net_device *dev)
-{
-	struct slvl_device *sv = dev->priv;
-	sppp_attach(&sv->pppdev);
+	sv->chan->netdevice = dev;
 	return 0;
 }
 
-static void sealevel_detach(struct net_device *dev)
-{
-	sppp_detach(dev);
-}
-		
-static void slvl_setup(struct net_device *d)
-{
-	d->open = sealevel_open;
-	d->stop = sealevel_close;
-	d->init = sealevel_attach;
-	d->uninit = sealevel_detach;
-	d->hard_start_xmit = sealevel_queue_xmit;
-	d->get_stats = sealevel_get_stats;
-	d->set_multicast_list = NULL;
-	d->do_ioctl = sealevel_ioctl;
-	d->neigh_setup = sealevel_neigh_setup_dev;
-	d->set_mac_address = NULL;
-
-}
-
-static inline struct slvl_device *slvl_alloc(int iobase, int irq)
-{
-	struct net_device *d;
-	struct slvl_device *sv;
-
-	d = alloc_netdev(sizeof(struct slvl_device), "hdlc%d",
-			 slvl_setup);
-
-	if (!d) 
-		return NULL;
-
-	sv = d->priv;
-	d->ml_priv = sv;
-	sv->if_ptr = &sv->pppdev;
-	sv->pppdev.dev = d;
-	d->base_addr = iobase;
-	d->irq = irq;
-		
-	return sv;
-}
-
 
 /*
  *	Allocate and setup Sealevel board.
  */
- 
-static __init struct slvl_board *slvl_init(int iobase, int irq, 
+
+static __init struct slvl_board *slvl_init(int iobase, int irq,
 					   int txdma, int rxdma, int slow)
 {
 	struct z8530_dev *dev;
 	struct slvl_board *b;
-	
+
 	/*
 	 *	Get the needed I/O space
 	 */
 
-	if(!request_region(iobase, 8, "Sealevel 4021")) 
-	{	
-		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n", iobase);
+	if (!request_region(iobase, 8, "Sealevel 4021")) {
+		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n",
+		       iobase);
 		return NULL;
 	}
-	
-	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
-	if(!b)
-		goto fail3;
 
-	if (!(b->dev[0]= slvl_alloc(iobase, irq)))
-		goto fail2;
+	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
+	if (!b)
+		goto err_kzalloc;
 
-	b->dev[0]->chan = &b->board.chanA;	
-	b->dev[0]->channel = 0;
-	
-	if (!(b->dev[1] = slvl_alloc(iobase, irq)))
-		goto fail1_0;
+	b->dev[0].chan = &b->board.chanA;
+	b->dev[0].channel = 0;
 
-	b->dev[1]->chan = &b->board.chanB;
-	b->dev[1]->channel = 1;
+	b->dev[1].chan = &b->board.chanB;
+	b->dev[1].channel = 1;
 
 	dev = &b->board;
-	
+
 	/*
 	 *	Stuff in the I/O addressing
 	 */
-	 
+
 	dev->active = 0;
 
 	b->iobase = iobase;
-	
+
 	/*
 	 *	Select 8530 delays for the old board
 	 */
-	 
-	if(slow)
+
+	if (slow)
 		iobase |= Z8530_PORT_SLEEP;
-		
-	dev->chanA.ctrlio=iobase+1;
-	dev->chanA.dataio=iobase;
-	dev->chanB.ctrlio=iobase+3;
-	dev->chanB.dataio=iobase+2;
-	
-	dev->chanA.irqs=&z8530_nop;
-	dev->chanB.irqs=&z8530_nop;
-	
+
+	dev->chanA.ctrlio = iobase + 1;
+	dev->chanA.dataio = iobase;
+	dev->chanB.ctrlio = iobase + 3;
+	dev->chanB.dataio = iobase + 2;
+
+	dev->chanA.irqs = &z8530_nop;
+	dev->chanB.irqs = &z8530_nop;
+
 	/*
 	 *	Assert DTR enable DMA
 	 */
-	 
-	outb(3|(1<<7), b->iobase+4);	
-	
+
+	outb(3 | (1 << 7), b->iobase + 4);
+
 
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
-   
-	if(request_irq(irq, &z8530_interrupt, IRQF_DISABLED, "SeaLevel", dev)<0)
-	{
+
+	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+			"SeaLevel", dev) < 0) {
 		printk(KERN_WARNING "sealevel: IRQ %d already in use.\n", irq);
-		goto fail1_1;
+		goto err_request_irq;
 	}
-	
-	dev->irq=irq;
-	dev->chanA.private=&b->dev[0];
-	dev->chanB.private=&b->dev[1];
-	dev->chanA.netdevice=b->dev[0]->pppdev.dev;
-	dev->chanB.netdevice=b->dev[1]->pppdev.dev;
-	dev->chanA.dev=dev;
-	dev->chanB.dev=dev;
-
-	dev->chanA.txdma=3;
-	dev->chanA.rxdma=1;
-	if(request_dma(dev->chanA.txdma, "SeaLevel (TX)")!=0)
-		goto fail;
-		
-	if(request_dma(dev->chanA.rxdma, "SeaLevel (RX)")!=0)
-		goto dmafail;
-	
+
+	dev->irq = irq;
+	dev->chanA.private = &b->dev[0];
+	dev->chanB.private = &b->dev[1];
+	dev->chanA.dev = dev;
+	dev->chanB.dev = dev;
+
+	dev->chanA.txdma = 3;
+	dev->chanA.rxdma = 1;
+	if (request_dma(dev->chanA.txdma, "SeaLevel (TX)"))
+		goto err_dma_tx;
+
+	if (request_dma(dev->chanA.rxdma, "SeaLevel (RX)"))
+		goto err_dma_rx;
+
 	disable_irq(irq);
-		
+
 	/*
 	 *	Begin normal initialise
 	 */
-	 
-	if(z8530_init(dev)!=0)
-	{
+
+	if (z8530_init(dev) != 0) {
 		printk(KERN_ERR "Z8530 series device not found.\n");
 		enable_irq(irq);
-		goto dmafail2;
+		goto free_hw;
 	}
-	if(dev->type==Z85C30)
-	{
+	if (dev->type == Z85C30) {
 		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream);
 		z8530_channel_load(&dev->chanB, z8530_hdlc_kilostream);
-	}
-	else
-	{
+	} else {
 		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream_85230);
 		z8530_channel_load(&dev->chanB, z8530_hdlc_kilostream_85230);
 	}
@@ -370,36 +302,31 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/*
 	 *	Now we can take the IRQ
 	 */
-	
+
 	enable_irq(irq);
 
-	if (register_netdev(b->dev[0]->pppdev.dev)) 
-		goto dmafail2;
-		
-	if (register_netdev(b->dev[1]->pppdev.dev)) 
-		goto fail_unit;
+	if (slvl_setup(&b->dev[0], iobase, irq))
+		goto free_hw;
+	if (slvl_setup(&b->dev[1], iobase, irq))
+		goto free_netdev0;
 
 	z8530_describe(dev, "I/O", iobase);
-	dev->active=1;
+	dev->active = 1;
 	return b;
 
-fail_unit:
-	unregister_netdev(b->dev[0]->pppdev.dev);
-	
-dmafail2:
+free_netdev0:
+	unregister_hdlc_device(b->dev[0].chan->netdevice);
+	free_netdev(b->dev[0].chan->netdevice);
+free_hw:
 	free_dma(dev->chanA.rxdma);
-dmafail:
+err_dma_rx:
 	free_dma(dev->chanA.txdma);
-fail:
+err_dma_tx:
 	free_irq(irq, dev);
-fail1_1:
-	free_netdev(b->dev[1]->pppdev.dev);
-fail1_0:
-	free_netdev(b->dev[0]->pppdev.dev);
-fail2:
+err_request_irq:
 	kfree(b);
-fail3:
-	release_region(iobase,8);
+err_kzalloc:
+	release_region(iobase, 8);
 	return NULL;
 }
 
@@ -408,14 +335,14 @@ static void __exit slvl_shutdown(struct slvl_board *b)
 	int u;
 
 	z8530_shutdown(&b->board);
-	
-	for(u=0; u<2; u++)
+
+	for (u = 0; u < 2; u++)
 	{
-		struct net_device *d = b->dev[u]->pppdev.dev;
-		unregister_netdev(d);
+		struct net_device *d = b->dev[u].chan->netdevice;
+		unregister_hdlc_device(d);
 		free_netdev(d);
 	}
-	
+
 	free_irq(b->board.irq, &b->board);
 	free_dma(b->board.chanA.rxdma);
 	free_dma(b->board.chanA.txdma);
@@ -451,10 +378,6 @@ static struct slvl_board *slvl_unit;
 
 static int __init slvl_init_module(void)
 {
-#ifdef MODULE
-	printk(KERN_INFO "SeaLevel Z85230 Synchronous Driver v 0.02.\n");
-	printk(KERN_INFO "(c) Copyright 1998, Building Number Three Ltd.\n");
-#endif
 	slvl_unit = slvl_init(io, irq, txdma, rxdma, slow);
 
 	return slvl_unit ? 0 : -ENODEV;
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 98ef400..243bd8d 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -43,6 +43,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <asm/dma.h>
@@ -51,7 +52,6 @@
 #define RT_UNLOCK
 #include <linux/spinlock.h>
 
-#include <net/syncppp.h>
 #include "z85230.h"
 
 
@@ -440,51 +440,46 @@ static void z8530_tx(struct z8530_channel *c)
  *	A status event occurred in PIO synchronous mode. There are several
  *	reasons the chip will bother us here. A transmit underrun means we
  *	failed to feed the chip fast enough and just broke a packet. A DCD
- *	change is a line up or down. We communicate that back to the protocol
- *	layer for synchronous PPP to renegotiate.
+ *	change is a line up or down.
  */
 
 static void z8530_status(struct z8530_channel *chan)
 {
 	u8 status, altered;
 
-	status=read_zsreg(chan, R0);
-	altered=chan->status^status;
-	
-	chan->status=status;
-	
-	if(status&TxEOM)
-	{
+	status = read_zsreg(chan, R0);
+	altered = chan->status ^ status;
+
+	chan->status = status;
+
+	if (status & TxEOM) {
 /*		printk("%s: Tx underrun.\n", chan->dev->name); */
-		chan->stats.tx_fifo_errors++;
+		chan->netdevice->stats.tx_fifo_errors++;
 		write_zsctrl(chan, ERR_RES);
 		z8530_tx_done(chan);
 	}
-		
-	if(altered&chan->dcdcheck)
+
+	if (altered & chan->dcdcheck)
 	{
-		if(status&chan->dcdcheck)
-		{
+		if (status & chan->dcdcheck) {
 			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]|RxENABLE);
-			if(chan->netdevice &&
-			    ((chan->netdevice->type == ARPHRD_HDLC) ||
-			    (chan->netdevice->type == ARPHRD_PPP)))
-				sppp_reopen(chan->netdevice);
-		}
-		else
-		{
+			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
+			if (chan->netdevice)
+				netif_carrier_on(chan->netdevice);
+		} else {
 			printk(KERN_INFO "%s: DCD lost\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]&~RxENABLE);
+			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
+			if (chan->netdevice)
+				netif_carrier_off(chan->netdevice);
 		}
-		
-	}	
+
+	}
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
 }
 
-struct z8530_irqhandler z8530_sync=
+struct z8530_irqhandler z8530_sync =
 {
 	z8530_rx,
 	z8530_tx,
@@ -556,8 +551,7 @@ static void z8530_dma_tx(struct z8530_channel *chan)
  *	
  *	A status event occurred on the Z8530. We receive these for two reasons
  *	when in DMA mode. Firstly if we finished a packet transfer we get one
- *	and kick the next packet out. Secondly we may see a DCD change and
- *	have to poke the protocol layer.
+ *	and kick the next packet out. Secondly we may see a DCD change.
  *
  */
  
@@ -586,24 +580,21 @@ static void z8530_dma_status(struct z8530_channel *chan)
 		}
 	}
 
-	if(altered&chan->dcdcheck)
+	if (altered & chan->dcdcheck)
 	{
-		if(status&chan->dcdcheck)
-		{
+		if (status & chan->dcdcheck) {
 			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]|RxENABLE);
-			if(chan->netdevice &&
-			    ((chan->netdevice->type == ARPHRD_HDLC) ||
-			    (chan->netdevice->type == ARPHRD_PPP)))
-				sppp_reopen(chan->netdevice);
-		}
-		else
-		{
+			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
+			if (chan->netdevice)
+				netif_carrier_on(chan->netdevice);
+		} else {
 			printk(KERN_INFO "%s:DCD lost\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]&~RxENABLE);
+			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
+			if (chan->netdevice)
+				netif_carrier_off(chan->netdevice);
 		}
-	}	
+	}
 
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
@@ -1459,10 +1450,10 @@ static void z8530_tx_begin(struct z8530_channel *c)
 			/*
 			 *	Check if we crapped out.
 			 */
-			if(get_dma_residue(c->txdma))
+			if (get_dma_residue(c->txdma))
 			{
-				c->stats.tx_dropped++;
-				c->stats.tx_fifo_errors++;
+				c->netdevice->stats.tx_dropped++;
+				c->netdevice->stats.tx_fifo_errors++;
 			}
 			release_dma_lock(flags);
 		}
@@ -1534,21 +1525,21 @@ static void z8530_tx_begin(struct z8530_channel *c)
  *	packet. This code is fairly timing sensitive.
  *
  *	Called with the register lock held.
- */ 
- 
+ */
+
 static void z8530_tx_done(struct z8530_channel *c)
 {
 	struct sk_buff *skb;
 
 	/* Actually this can happen.*/
-	if(c->tx_skb==NULL)
+	if (c->tx_skb == NULL)
 		return;
 
-	skb=c->tx_skb;
-	c->tx_skb=NULL;
+	skb = c->tx_skb;
+	c->tx_skb = NULL;
 	z8530_tx_begin(c);
-	c->stats.tx_packets++;
-	c->stats.tx_bytes+=skb->len;
+	c->netdevice->stats.tx_packets++;
+	c->netdevice->stats.tx_bytes += skb->len;
 	dev_kfree_skb_irq(skb);
 }
 
@@ -1558,7 +1549,7 @@ static void z8530_tx_done(struct z8530_channel *c)
  *	@skb: The buffer
  *
  *	We point the receive handler at this function when idle. Instead
- *	of syncppp processing the frames we get to throw them away.
+ *	of processing the frames we get to throw them away.
  */
  
 void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb)
@@ -1635,10 +1626,11 @@ static void z8530_rx_done(struct z8530_channel *c)
 		else
 			/* Can't occur as we dont reenable the DMA irq until
 			   after the flip is done */
-			printk(KERN_WARNING "%s: DMA flip overrun!\n", c->netdevice->name);
-			
+			printk(KERN_WARNING "%s: DMA flip overrun!\n",
+			       c->netdevice->name);
+
 		release_dma_lock(flags);
-		
+
 		/*
 		 *	Shove the old buffer into an sk_buff. We can't DMA
 		 *	directly into one on a PC - it might be above the 16Mb
@@ -1646,27 +1638,23 @@ static void z8530_rx_done(struct z8530_channel *c)
 		 *	can avoid the copy. Optimisation 2 - make the memcpy
 		 *	a copychecksum.
 		 */
-		 
-		skb=dev_alloc_skb(ct);
-		if(skb==NULL)
-		{
-			c->stats.rx_dropped++;
-			printk(KERN_WARNING "%s: Memory squeeze.\n", c->netdevice->name);
-		}
-		else
-		{
+
+		skb = dev_alloc_skb(ct);
+		if (skb == NULL) {
+			c->netdevice->stats.rx_dropped++;
+			printk(KERN_WARNING "%s: Memory squeeze.\n",
+			       c->netdevice->name);
+		} else {
 			skb_put(skb, ct);
 			skb_copy_to_linear_data(skb, rxb, ct);
-			c->stats.rx_packets++;
-			c->stats.rx_bytes+=ct;
+			c->netdevice->stats.rx_packets++;
+			c->netdevice->stats.rx_bytes += ct;
 		}
-		c->dma_ready=1;
-	}
-	else
-	{
-		RT_LOCK;	
-		skb=c->skb;
-		
+		c->dma_ready = 1;
+	} else {
+		RT_LOCK;
+		skb = c->skb;
+
 		/*
 		 *	The game we play for non DMA is similar. We want to
 		 *	get the controller set up for the next packet as fast
@@ -1677,48 +1665,39 @@ static void z8530_rx_done(struct z8530_channel *c)
 		 *	if you build a system where the sync irq isnt blocked
 		 *	by the kernel IRQ disable then you need only block the
 		 *	sync IRQ for the RT_LOCK area.
-		 *	
+		 *
 		 */
 		ct=c->count;
-		
+
 		c->skb = c->skb2;
 		c->count = 0;
 		c->max = c->mtu;
-		if(c->skb)
-		{
+		if (c->skb) {
 			c->dptr = c->skb->data;
 			c->max = c->mtu;
-		}
-		else
-		{
-			c->count= 0;
+		} else {
+			c->count = 0;
 			c->max = 0;
 		}
 		RT_UNLOCK;
 
 		c->skb2 = dev_alloc_skb(c->mtu);
-		if(c->skb2==NULL)
+		if (c->skb2 == NULL)
 			printk(KERN_WARNING "%s: memory squeeze.\n",
-				c->netdevice->name);
+			       c->netdevice->name);
 		else
-		{
-			skb_put(c->skb2,c->mtu);
-		}
-		c->stats.rx_packets++;
-		c->stats.rx_bytes+=ct;
-		
+			skb_put(c->skb2, c->mtu);
+		c->netdevice->stats.rx_packets++;
+		c->netdevice->stats.rx_bytes += ct;
 	}
 	/*
 	 *	If we received a frame we must now process it.
 	 */
-	if(skb)
-	{
+	if (skb) {
 		skb_trim(skb, ct);
-		c->rx_function(c,skb);
-	}
-	else
-	{
-		c->stats.rx_dropped++;
+		c->rx_function(c, skb);
+	} else {
+		c->netdevice->stats.rx_dropped++;
 		printk(KERN_ERR "%s: Lost a frame\n", c->netdevice->name);
 	}
 }
@@ -1730,7 +1709,7 @@ static void z8530_rx_done(struct z8530_channel *c)
  *	Returns true if the buffer cross a DMA boundary on a PC. The poor
  *	thing can only DMA within a 64K block not across the edges of it.
  */
- 
+
 static inline int spans_boundary(struct sk_buff *skb)
 {
 	unsigned long a=(unsigned long)skb->data;
@@ -1799,24 +1778,6 @@ int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb)
 
 EXPORT_SYMBOL(z8530_queue_xmit);
 
-/**
- *	z8530_get_stats - Get network statistics
- *	@c: The channel to use
- *
- *	Get the statistics block. We keep the statistics in software as
- *	the chip doesn't do it for us.
- *
- *	Locking is ignored here - we could lock for a copy but its
- *	not likely to be that big an issue
- */
- 
-struct net_device_stats *z8530_get_stats(struct z8530_channel *c)
-{
-	return &c->stats;
-}
-
-EXPORT_SYMBOL(z8530_get_stats);
-
 /*
  *	Module support
  */
diff --git a/drivers/net/wan/z85230.h b/drivers/net/wan/z85230.h
index 158aea7..4f37239 100644
--- a/drivers/net/wan/z85230.h
+++ b/drivers/net/wan/z85230.h
@@ -325,7 +325,6 @@ struct z8530_channel
 
 	void		*private;	/* For our owner */
 	struct net_device	*netdevice;	/* Network layer device */
-	struct net_device_stats stats;	/* Network layer statistics */
 
 	/*
 	 *	Async features
@@ -366,13 +365,13 @@ struct z8530_channel
 	unsigned char		tx_active; /* character is being xmitted */
 	unsigned char		tx_stopped; /* output is suspended */
 
-	spinlock_t		*lock;	  /* Devicr lock */
-};	
+	spinlock_t		*lock;	  /* Device lock */
+};
 
 /*
  *	Each Z853x0 device.
- */	
- 
+ */
+
 struct z8530_dev
 {
 	char *name;	/* Device instance name */
@@ -408,7 +407,6 @@ extern int z8530_sync_txdma_open(struct net_device *, struct z8530_channel *);
 extern int z8530_sync_txdma_close(struct net_device *, struct z8530_channel *);
 extern int z8530_channel_load(struct z8530_channel *, u8 *);
 extern int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb);
-extern struct net_device_stats *z8530_get_stats(struct z8530_channel *c);
 extern void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb);
 
 
-- 
Krzysztof Halasa
