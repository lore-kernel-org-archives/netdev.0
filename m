From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) wan/cosa - use alloc_netdev
Date: Tue, 25 Nov 2003 11:54:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125115448.33fb623b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert this driver:
	* use alloc_netdev to create the network device
	* use space from alloc_netdev for local channel data structure

diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Mon Nov 24 15:38:43 2003
+++ b/drivers/net/wan/cosa.c	Mon Nov 24 15:38:43 2003
@@ -166,7 +166,7 @@
 	struct channel_data *rxchan;
 	char *bouncebuf;
 	char *txbuf, *rxbuf;
-	struct channel_data *chan;
+	struct channel_data **chan;
 	spinlock_t lock;	/* For exclusive operations on this structure */
 	char id_string[COSA_MAX_ID_STRING];	/* ROM monitor ID string */
 	char *type;				/* card type */
@@ -280,7 +280,7 @@
 static int cosa_dma_able(struct channel_data *chan, char *buf, int data);
 
 /* SPPP/HDLC stuff */
-static void sppp_channel_init(struct channel_data *chan);
+static struct channel_data *sppp_channel_alloc(struct cosa_data *cosa, int n);
 static void sppp_channel_delete(struct channel_data *chan);
 static int cosa_sppp_open(struct net_device *d);
 static int cosa_sppp_close(struct net_device *d);
@@ -293,7 +293,6 @@
 static struct net_device_stats *cosa_net_stats(struct net_device *dev);
 
 /* Character device */
-static void chardev_channel_init(struct channel_data *chan);
 static char *chrdev_setup_rx(struct channel_data *channel, int size);
 static int chrdev_rx_done(struct channel_data *channel);
 static int chrdev_tx_done(struct channel_data *channel, int size);
@@ -410,7 +409,7 @@
 		/* Clean up the per-channel data */
 		for (i=0; i<cosa->nchannels; i++) {
 			/* Chardev driver has no alloc'd per-channel data */
-			sppp_channel_delete(cosa->chan+i);
+			sppp_channel_delete(cosa->chan[i]);
 		}
 		/* Clean up the per-card data */
 		kfree(cosa->chan);
@@ -422,19 +421,6 @@
 	unregister_chrdev(cosa_major, "cosa");
 }
 module_exit(cosa_exit);
-
-/*
- * This function should register all the net devices needed for the
- * single channel.
- */
-static __inline__ void channel_init(struct channel_data *chan)
-{
-	/* Initialize the chardev data structures */
-	chardev_channel_init(chan);
-
-	/* Register the sppp interface */
-	sppp_channel_init(chan);
-}
 	
 static int cosa_probe(int base, int irq, int dma)
 {
@@ -559,17 +545,20 @@
 	sprintf(cosa->name, "cosa%d", cosa->num);
 
 	/* Initialize the per-channel data */
-	cosa->chan = kmalloc(sizeof(struct channel_data)*cosa->nchannels,
+	cosa->chan = kmalloc(sizeof(struct channel_data *)*cosa->nchannels,
 			     GFP_KERNEL);
 	if (!cosa->chan) {
 	        err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(cosa->chan, 0, sizeof(struct channel_data)*cosa->nchannels);
+	memset(cosa->chan, 0, sizeof(struct channel_data *)*cosa->nchannels);
 	for (i=0; i<cosa->nchannels; i++) {
-		cosa->chan[i].cosa = cosa;
-		cosa->chan[i].num = i;
-		channel_init(cosa->chan+i);
+		struct channel_data *chan = sppp_channel_alloc(cosa, i);
+		if (IS_ERR(chan)) {
+			err = PTR_ERR(chan);
+			goto err_out4;
+		}
+		cosa->chan[i] = chan;
 	}
 
 	printk (KERN_INFO "cosa%d: %s (%s at 0x%x irq %d dma %d), %d channels\n",
@@ -577,6 +566,11 @@
 		cosa->datareg, cosa->irq, cosa->dma, cosa->nchannels);
 
 	return nr_cards++;
+err_out4:
+	for (i=0; i<cosa->nchannels; i++) 
+		if (cosa->chan[i])
+			sppp_channel_delete(cosa->chan[i]);
+	kfree(cosa->chan);
 err_out3:
 	kfree(cosa->bouncebuf);
 err_out2:
@@ -592,22 +586,8 @@
 
 
 /*---------- SPPP/HDLC netdevice ---------- */
-
-static void sppp_channel_init(struct channel_data *chan)
+static __init void sppp_channel_setup(struct net_device *d)
 {
-	struct net_device *d;
-	chan->if_ptr = &chan->pppdev;
-	chan->pppdev.dev = kmalloc(sizeof(struct net_device), GFP_KERNEL);
-	memset(chan->pppdev.dev, 0, sizeof(struct net_device));
-	sppp_attach(&chan->pppdev);
-	d=chan->pppdev.dev;
-	sprintf(d->name, "cosa%dc%d", chan->cosa->num, chan->num);
-	chan->name = d->name;
-	d->base_addr = chan->cosa->datareg;
-	d->irq = chan->cosa->irq;
-	d->dma = chan->cosa->dma;
-	d->priv = chan;
-	d->init = NULL;
 	d->open = cosa_sppp_open;
 	d->stop = cosa_sppp_close;
 	d->hard_start_xmit = cosa_sppp_tx;
@@ -615,12 +595,43 @@
 	d->get_stats = cosa_net_stats;
 	d->tx_timeout = cosa_sppp_timeout;
 	d->watchdog_timeo = TX_TIMEOUT;
-	if (register_netdev(d)) {
+}
+
+static __init struct channel_data *sppp_channel_alloc(struct cosa_data *cosa, 
+						      int num)
+{
+	struct net_device *d;
+	struct channel_data *chan;
+	int err;
+
+	d = alloc_netdev(sizeof(*chan), "cosa", sppp_channel_setup);
+	if (!d)
+		return ERR_PTR(-ENOMEM);
+	
+	chan = d->priv;
+	chan->if_ptr = &chan->pppdev;
+	chan->pppdev.dev = d;
+	chan->name = d->name;
+	chan->cosa = cosa;
+	chan->num = num;
+	sprintf(d->name, "cosa%dc%d", cosa->num, num);
+	init_MUTEX(&chan->rsem);
+	init_MUTEX(&chan->wsem);
+
+	sppp_attach(&chan->pppdev);
+
+	d->base_addr = cosa->datareg;
+	d->irq = cosa->irq;
+	d->dma = cosa->dma;
+
+	err = register_netdev(d);
+	if (err) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(chan->pppdev.dev);
-		free_netdev(chan->pppdev.dev);
-		return;
+		free_netdev(d);
+		return ERR_PTR(err);
 	}
+	return chan;
 }
 
 static void sppp_channel_delete(struct channel_data *chan)
@@ -788,13 +799,6 @@
 
 
 /*---------- Character device ---------- */
-
-static void chardev_channel_init(struct channel_data *chan)
-{
-	init_MUTEX(&chan->rsem);
-	init_MUTEX(&chan->wsem);
-}
-
 static ssize_t cosa_read(struct file *file,
 	char *buf, size_t count, loff_t *ppos)
 {
@@ -961,7 +965,7 @@
 	if ((n=iminor(file->f_dentry->d_inode)
 		& ((1<<CARD_MINOR_BITS)-1)) >= cosa->nchannels)
 		return -ENODEV;
-	chan = cosa->chan + n;
+	chan = cosa->chan[n];
 	
 	file->private_data = chan;
 
@@ -1684,6 +1688,7 @@
 static inline void tx_interrupt(struct cosa_data *cosa, int status)
 {
 	unsigned long flags, flags1;
+	struct channel_data *chan;
 #ifdef DEBUG_IRQS
 	printk(KERN_INFO "cosa%d: SR_DOWN_REQUEST status=0x%04x\n",
 		cosa->num, status);
@@ -1723,13 +1728,12 @@
 			}
 		}
 
-		cosa->txsize = cosa->chan[cosa->txchan].txsize;
-		if (cosa_dma_able(cosa->chan+cosa->txchan,
-			cosa->chan[cosa->txchan].txbuf, cosa->txsize)) {
-			cosa->txbuf = cosa->chan[cosa->txchan].txbuf;
+		chan = cosa->chan[cosa->txchan];
+		cosa->txsize = chan->txsize;
+		if (cosa_dma_able(chan, chan->txbuf, cosa->txsize)) {
+			cosa->txbuf = chan->txbuf;
 		} else {
-			memcpy(cosa->bouncebuf, cosa->chan[cosa->txchan].txbuf,
-				cosa->txsize);
+			memcpy(cosa->bouncebuf, chan->txbuf, cosa->txsize);
 			cosa->txbuf = cosa->bouncebuf;
 		}
 	}
@@ -1865,7 +1869,7 @@
 		spin_unlock_irqrestore(&cosa->lock, flags);
 		goto reject;
 	}
-	cosa->rxchan = cosa->chan + ((cosa->rxsize & 0xe000) >> 13);
+	cosa->rxchan = cosa->chan[(cosa->rxsize & 0xe000) >> 13];
 	cosa->rxsize &= 0x1fff;
 	spin_unlock_irqrestore(&cosa->lock, flags);
 
@@ -1914,7 +1918,7 @@
 	clear_dma_ff(cosa->dma);
 	release_dma_lock(flags1);
 	if (test_bit(TXBIT, &cosa->rxtx)) {
-		struct channel_data *chan = cosa->chan+cosa->txchan;
+		struct channel_data *chan = cosa->chan[cosa->txchan];
 		if (chan->tx_done)
 			if (chan->tx_done(chan, cosa->txsize))
 				clear_bit(chan->num, &cosa->txbitmap);
