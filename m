From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Port COSA driver to generic HDLC.
Date: Wed, 02 Jul 2008 21:18:19 +0200
Message-ID: <m3lk0k3xj8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:33944 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952AbYGBTXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

WAN: Port COSA driver to generic HDLC.

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index d5140ae..e033366 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -37,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on ISA && m && ISA_DMA_API
+	depends on ISA && m && ISA_DMA_API && HDLC
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index 94c1d47..9d085e0 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -23,7 +23,7 @@ pc300-objs			:= $(pc300-y)
 
 obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	syncppp.o	hostess_sv11.o
 obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	syncppp.o	sealevel.o
-obj-$(CONFIG_COSA)		+=		syncppp.o	cosa.o
+obj-$(CONFIG_COSA)		+= cosa.o
 obj-$(CONFIG_FARSYNC)		+= farsync.o
 obj-$(CONFIG_DSCC4)             +=				dscc4.o
 obj-$(CONFIG_LANMEDIA)		+=		syncppp.o
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b0fce13..5ccc0f2 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -2,6 +2,7 @@
 
 /*
  *  Copyright (C) 1995-1997  Jan "Yenya" Kasprzak <kas@fi.muni.cz>
+ *  Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -54,7 +55,7 @@
  *
  * The Linux driver (unlike the present *BSD drivers :-) can work even
  * for the COSA and SRP in one computer and allows each channel to work
- * in one of the three modes (character device, Cisco HDLC, Sync PPP).
+ * in one of the two modes (character or network device).
  *
  * AUTHOR
  *
@@ -72,12 +73,6 @@
  * The Comtrol Hostess SV11 driver by Alan Cox
  * The Sync PPP/Cisco HDLC layer (syncppp.c) ported to Linux by Alan Cox
  */
-/*
- *     5/25/1999 : Marcelo Tosatti <marcelo@conectiva.com.br>
- *             fixed a deadlock in cosa_sppp_open
- */
-
-/* ---------- Headers, macros, data structures ---------- */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -86,20 +81,19 @@
 #include <linux/fs.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/device.h>
-
-#undef COSA_SLOW_IO	/* for testing purposes only */
-
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
 
-#include <net/syncppp.h>
+#undef COSA_SLOW_IO	/* for testing purposes only */
+
 #include "cosa.h"
 
 /* Maximum length of the identification string. */
@@ -111,7 +105,6 @@
 /* Per-channel data structure */
 
 struct channel_data {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	int usage;	/* Usage count; >0 for chrdev, -1 for netdev */
 	int num;	/* Number of the channel */
 	struct cosa_data *cosa;	/* Pointer to the per-card structure */
@@ -135,10 +128,9 @@ struct channel_data {
 	wait_queue_head_t txwaitq, rxwaitq;
 	int tx_status, rx_status;
 
-	/* SPPP/HDLC device parts */
-	struct ppp_device pppdev;
+	/* generic HDLC device parts */
+	struct net_device *netdev;
 	struct sk_buff *rx_skb, *tx_skb;
-	struct net_device_stats stats;
 };
 
 /* cosa->firmware_status bits */
@@ -280,21 +272,19 @@ static int cosa_start_tx(struct channel_data *channel, char *buf, int size);
 static void cosa_kick(struct cosa_data *cosa);
 static int cosa_dma_able(struct channel_data *chan, char *buf, int data);
 
-/* SPPP/HDLC stuff */
-static void sppp_channel_init(struct channel_data *chan);
-static void sppp_channel_delete(struct channel_data *chan);
-static int cosa_sppp_open(struct net_device *d);
-static int cosa_sppp_close(struct net_device *d);
-static void cosa_sppp_timeout(struct net_device *d);
-static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *d);
-static char *sppp_setup_rx(struct channel_data *channel, int size);
-static int sppp_rx_done(struct channel_data *channel);
-static int sppp_tx_done(struct channel_data *channel, int size);
-static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static struct net_device_stats *cosa_net_stats(struct net_device *dev);
+/* Network device stuff */
+static int cosa_net_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity);
+static int cosa_net_open(struct net_device *d);
+static int cosa_net_close(struct net_device *d);
+static void cosa_net_timeout(struct net_device *d);
+static int cosa_net_tx(struct sk_buff *skb, struct net_device *d);
+static char *cosa_net_setup_rx(struct channel_data *channel, int size);
+static int cosa_net_rx_done(struct channel_data *channel);
+static int cosa_net_tx_done(struct channel_data *channel, int size);
+static int cosa_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 /* Character device */
-static void chardev_channel_init(struct channel_data *chan);
 static char *chrdev_setup_rx(struct channel_data *channel, int size);
 static int chrdev_rx_done(struct channel_data *channel);
 static int chrdev_tx_done(struct channel_data *channel, int size);
@@ -356,17 +346,17 @@ static void debug_status_in(struct cosa_data *cosa, int status);
 static void debug_status_out(struct cosa_data *cosa, int status);
 #endif
 
-
+static inline struct channel_data* dev_to_chan(struct net_device *dev)
+{
+	return (struct channel_data *)dev_to_hdlc(dev)->priv;
+}
+
 /* ---------- Initialization stuff ---------- */
 
 static int __init cosa_init(void)
 {
 	int i, err = 0;
 
-	printk(KERN_INFO "cosa v1.08 (c) 1997-2000 Jan Kasprzak <kas@fi.muni.cz>\n");
-#ifdef CONFIG_SMP
-	printk(KERN_INFO "cosa: SMP found. Please mail any success/failure reports to the author.\n");
-#endif
 	if (cosa_major > 0) {
 		if (register_chrdev(cosa_major, "cosa", &cosa_fops)) {
 			printk(KERN_WARNING "cosa: unable to get major %d\n",
@@ -401,7 +391,7 @@ static int __init cosa_init(void)
 	}
 	err = 0;
 	goto out;
-	
+
 out_chrdev:
 	unregister_chrdev(cosa_major, "cosa");
 out:
@@ -413,43 +403,29 @@ static void __exit cosa_exit(void)
 {
 	struct cosa_data *cosa;
 	int i;
-	printk(KERN_INFO "Unloading the cosa module\n");
 
-	for (i=0; i<nr_cards; i++)
+	for (i = 0; i < nr_cards; i++)
 		device_destroy(cosa_class, MKDEV(cosa_major, i));
 	class_destroy(cosa_class);
-	for (cosa=cosa_cards; nr_cards--; cosa++) {
+
+	for (cosa = cosa_cards; nr_cards--; cosa++) {
 		/* Clean up the per-channel data */
-		for (i=0; i<cosa->nchannels; i++) {
+		for (i = 0; i < cosa->nchannels; i++) {
 			/* Chardev driver has no alloc'd per-channel data */
-			sppp_channel_delete(cosa->chan+i);
+			unregister_hdlc_device(cosa->chan[i].netdev);
+			free_netdev(cosa->chan[i].netdev);
 		}
 		/* Clean up the per-card data */
 		kfree(cosa->chan);
 		kfree(cosa->bouncebuf);
 		free_irq(cosa->irq, cosa);
 		free_dma(cosa->dma);
-		release_region(cosa->datareg,is_8bit(cosa)?2:4);
+		release_region(cosa->datareg, is_8bit(cosa) ? 2 : 4);
 	}
 	unregister_chrdev(cosa_major, "cosa");
 }
 module_exit(cosa_exit);
 
-/*
- * This function should register all the net devices needed for the
- * single channel.
- */
-static __inline__ void channel_init(struct channel_data *chan)
-{
-	sprintf(chan->name, "cosa%dc%d", chan->cosa->num, chan->num);
-
-	/* Initialize the chardev data structures */
-	chardev_channel_init(chan);
-
-	/* Register the sppp interface */
-	sppp_channel_init(chan);
-}
-	
 static int cosa_probe(int base, int irq, int dma)
 {
 	struct cosa_data *cosa = cosa_cards+nr_cards;
@@ -575,13 +551,43 @@ static int cosa_probe(int base, int irq, int dma)
 	/* Initialize the per-channel data */
 	cosa->chan = kcalloc(cosa->nchannels, sizeof(struct channel_data), GFP_KERNEL);
 	if (!cosa->chan) {
-	        err = -ENOMEM;
+		err = -ENOMEM;
 		goto err_out3;
 	}
-	for (i=0; i<cosa->nchannels; i++) {
-		cosa->chan[i].cosa = cosa;
-		cosa->chan[i].num = i;
-		channel_init(cosa->chan+i);
+
+	for (i = 0; i < cosa->nchannels; i++) {
+		struct channel_data *chan = &cosa->chan[i];
+
+		chan->cosa = cosa;
+		chan->num = i;
+		sprintf(chan->name, "cosa%dc%d", chan->cosa->num, i);
+
+		/* Initialize the chardev data structures */
+		mutex_init(&chan->rlock);
+		init_MUTEX(&chan->wsem);
+
+		/* Register the network interface */
+		if (!(chan->netdev = alloc_hdlcdev(chan))) {
+			printk(KERN_WARNING "%s: alloc_hdlcdev failed.\n",
+			       chan->name);
+			goto err_hdlcdev;
+		}
+		dev_to_hdlc(chan->netdev)->attach = cosa_net_attach;
+		dev_to_hdlc(chan->netdev)->xmit = cosa_net_tx;
+		chan->netdev->open = cosa_net_open;
+		chan->netdev->stop = cosa_net_close;
+		chan->netdev->do_ioctl = cosa_net_ioctl;
+		chan->netdev->tx_timeout = cosa_net_timeout;
+		chan->netdev->watchdog_timeo = TX_TIMEOUT;
+		chan->netdev->base_addr = chan->cosa->datareg;
+		chan->netdev->irq = chan->cosa->irq;
+		chan->netdev->dma = chan->cosa->dma;
+		if (register_hdlc_device(chan->netdev)) {
+			printk(KERN_WARNING "%s: register_hdlc_device()"
+			       " failed.\n", chan->netdev->name);
+			free_netdev(chan->netdev);
+			goto err_hdlcdev;
+		}
 	}
 
 	printk (KERN_INFO "cosa%d: %s (%s at 0x%x irq %d dma %d), %d channels\n",
@@ -589,13 +595,20 @@ static int cosa_probe(int base, int irq, int dma)
 		cosa->datareg, cosa->irq, cosa->dma, cosa->nchannels);
 
 	return nr_cards++;
+
+err_hdlcdev:
+	while (i-- > 0) {
+		unregister_hdlc_device(cosa->chan[i].netdev);
+		free_netdev(cosa->chan[i].netdev);
+	}
+	kfree(cosa->chan);
 err_out3:
 	kfree(cosa->bouncebuf);
 err_out2:
 	free_dma(cosa->dma);
 err_out1:
 	free_irq(cosa->irq, cosa);
-err_out:	
+err_out:
 	release_region(cosa->datareg,is_8bit(cosa)?2:4);
 	printk(KERN_NOTICE "cosa%d: allocating resources failed\n",
 	       cosa->num);
@@ -603,54 +616,19 @@ err_out:
 }
 
 
-/*---------- SPPP/HDLC netdevice ---------- */
+/*---------- network device ---------- */
 
-static void cosa_setup(struct net_device *d)
+static int cosa_net_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity)
 {
-	d->open = cosa_sppp_open;
-	d->stop = cosa_sppp_close;
-	d->hard_start_xmit = cosa_sppp_tx;
-	d->do_ioctl = cosa_sppp_ioctl;
-	d->get_stats = cosa_net_stats;
-	d->tx_timeout = cosa_sppp_timeout;
-	d->watchdog_timeo = TX_TIMEOUT;
-}
-
-static void sppp_channel_init(struct channel_data *chan)
-{
-	struct net_device *d;
-	chan->if_ptr = &chan->pppdev;
-	d = alloc_netdev(0, chan->name, cosa_setup);
-	if (!d) {
-		printk(KERN_WARNING "%s: alloc_netdev failed.\n", chan->name);
-		return;
-	}
-	chan->pppdev.dev = d;
-	d->base_addr = chan->cosa->datareg;
-	d->irq = chan->cosa->irq;
-	d->dma = chan->cosa->dma;
-	d->ml_priv = chan;
-	sppp_attach(&chan->pppdev);
-	if (register_netdev(d)) {
-		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
-		sppp_detach(d);
-		free_netdev(d);
-		chan->pppdev.dev = NULL;
-		return;
-	}
-}
-
-static void sppp_channel_delete(struct channel_data *chan)
-{
-	unregister_netdev(chan->pppdev.dev);
-	sppp_detach(chan->pppdev.dev);
-	free_netdev(chan->pppdev.dev);
-	chan->pppdev.dev = NULL;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-static int cosa_sppp_open(struct net_device *d)
+static int cosa_net_open(struct net_device *dev)
 {
-	struct channel_data *chan = d->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 	int err;
 	unsigned long flags;
 
@@ -661,36 +639,35 @@ static int cosa_sppp_open(struct net_device *d)
 	}
 	spin_lock_irqsave(&chan->cosa->lock, flags);
 	if (chan->usage != 0) {
-		printk(KERN_WARNING "%s: sppp_open called with usage count %d\n",
-			chan->name, chan->usage);
+		printk(KERN_WARNING "%s: cosa_net_open called with usage count"
+		       " %d\n", chan->name, chan->usage);
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return -EBUSY;
 	}
-	chan->setup_rx = sppp_setup_rx;
-	chan->tx_done = sppp_tx_done;
-	chan->rx_done = sppp_rx_done;
-	chan->usage=-1;
+	chan->setup_rx = cosa_net_setup_rx;
+	chan->tx_done = cosa_net_tx_done;
+	chan->rx_done = cosa_net_rx_done;
+	chan->usage = -1;
 	chan->cosa->usage++;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 
-	err = sppp_open(d);
+	err = hdlc_open(dev);
 	if (err) {
 		spin_lock_irqsave(&chan->cosa->lock, flags);
-		chan->usage=0;
+		chan->usage = 0;
 		chan->cosa->usage--;
-		
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return err;
 	}
 
-	netif_start_queue(d);
+	netif_start_queue(dev);
 	cosa_enable_rx(chan);
 	return 0;
 }
 
-static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
+static int cosa_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct channel_data *chan = dev->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 
 	netif_stop_queue(dev);
 
@@ -699,16 +676,16 @@ static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static void cosa_sppp_timeout(struct net_device *dev)
+static void cosa_net_timeout(struct net_device *dev)
 {
-	struct channel_data *chan = dev->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 
 	if (test_bit(RXBIT, &chan->cosa->rxtx)) {
-		chan->stats.rx_errors++;
-		chan->stats.rx_missed_errors++;
+		chan->netdev->stats.rx_errors++;
+		chan->netdev->stats.rx_missed_errors++;
 	} else {
-		chan->stats.tx_errors++;
-		chan->stats.tx_aborted_errors++;
+		chan->netdev->stats.tx_errors++;
+		chan->netdev->stats.tx_aborted_errors++;
 	}
 	cosa_kick(chan->cosa);
 	if (chan->tx_skb) {
@@ -718,13 +695,13 @@ static void cosa_sppp_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int cosa_sppp_close(struct net_device *d)
+static int cosa_net_close(struct net_device *dev)
 {
-	struct channel_data *chan = d->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 	unsigned long flags;
 
-	netif_stop_queue(d);
-	sppp_close(d);
+	netif_stop_queue(dev);
+	hdlc_close(dev);
 	cosa_disable_rx(chan);
 	spin_lock_irqsave(&chan->cosa->lock, flags);
 	if (chan->rx_skb) {
@@ -735,13 +712,13 @@ static int cosa_sppp_close(struct net_device *d)
 		kfree_skb(chan->tx_skb);
 		chan->tx_skb = NULL;
 	}
-	chan->usage=0;
+	chan->usage = 0;
 	chan->cosa->usage--;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 	return 0;
 }
 
-static char *sppp_setup_rx(struct channel_data *chan, int size)
+static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 {
 	/*
 	 * We can safely fall back to non-dma-able memory, because we have
@@ -753,66 +730,53 @@ static char *sppp_setup_rx(struct channel_data *chan, int size)
 	if (chan->rx_skb == NULL) {
 		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet\n",
 			chan->name);
-		chan->stats.rx_dropped++;
+		chan->netdev->stats.rx_dropped++;
 		return NULL;
 	}
-	chan->pppdev.dev->trans_start = jiffies;
+	chan->netdev->trans_start = jiffies;
 	return skb_put(chan->rx_skb, size);
 }
 
-static int sppp_rx_done(struct channel_data *chan)
+static int cosa_net_rx_done(struct channel_data *chan)
 {
 	if (!chan->rx_skb) {
 		printk(KERN_WARNING "%s: rx_done with empty skb!\n",
 			chan->name);
-		chan->stats.rx_errors++;
-		chan->stats.rx_frame_errors++;
+		chan->netdev->stats.rx_errors++;
+		chan->netdev->stats.rx_frame_errors++;
 		return 0;
 	}
-	chan->rx_skb->protocol = htons(ETH_P_WAN_PPP);
-	chan->rx_skb->dev = chan->pppdev.dev;
+	chan->rx_skb->protocol = hdlc_type_trans(chan->rx_skb, chan->netdev);
+	chan->rx_skb->dev = chan->netdev;
 	skb_reset_mac_header(chan->rx_skb);
-	chan->stats.rx_packets++;
-	chan->stats.rx_bytes += chan->cosa->rxsize;
+	chan->netdev->stats.rx_packets++;
+	chan->netdev->stats.rx_bytes += chan->cosa->rxsize;
 	netif_rx(chan->rx_skb);
 	chan->rx_skb = NULL;
-	chan->pppdev.dev->last_rx = jiffies;
+	chan->netdev->last_rx = jiffies;
 	return 0;
 }
 
 /* ARGSUSED */
-static int sppp_tx_done(struct channel_data *chan, int size)
+static int cosa_net_tx_done(struct channel_data *chan, int size)
 {
 	if (!chan->tx_skb) {
 		printk(KERN_WARNING "%s: tx_done with empty skb!\n",
 			chan->name);
-		chan->stats.tx_errors++;
-		chan->stats.tx_aborted_errors++;
+		chan->netdev->stats.tx_errors++;
+		chan->netdev->stats.tx_aborted_errors++;
 		return 1;
 	}
 	dev_kfree_skb_irq(chan->tx_skb);
 	chan->tx_skb = NULL;
-	chan->stats.tx_packets++;
-	chan->stats.tx_bytes += size;
-	netif_wake_queue(chan->pppdev.dev);
+	chan->netdev->stats.tx_packets++;
+	chan->netdev->stats.tx_bytes += size;
+	netif_wake_queue(chan->netdev);
 	return 1;
 }
 
-static struct net_device_stats *cosa_net_stats(struct net_device *dev)
-{
-	struct channel_data *chan = dev->ml_priv;
-	return &chan->stats;
-}
-
-
 /*---------- Character device ---------- */
 
-static void chardev_channel_init(struct channel_data *chan)
-{
-	mutex_init(&chan->rlock);
-	init_MUTEX(&chan->wsem);
-}
-
 static ssize_t cosa_read(struct file *file,
 	char __user *buf, size_t count, loff_t *ppos)
 {
@@ -1213,16 +1177,15 @@ static int cosa_ioctl_common(struct cosa_data *cosa,
 	return -ENOIOCTLCMD;
 }
 
-static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr,
-	int cmd)
+static int cosa_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int rv;
-	struct channel_data *chan = dev->ml_priv;
-	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
-	if (rv == -ENOIOCTLCMD) {
-		return sppp_do_ioctl(dev, ifr, cmd);
-	}
-	return rv;
+	struct channel_data *chan = dev_to_chan(dev);
+	rv = cosa_ioctl_common(chan->cosa, chan, cmd,
+			       (unsigned long)ifr->ifr_data);
+	if (rv != -ENOIOCTLCMD)
+		return rv;
+	return hdlc_ioctl(dev, ifr, cmd);
 }
 
 static int cosa_chardev_ioctl(struct inode *inode, struct file *file,

-- 
Krzysztof Halasa
