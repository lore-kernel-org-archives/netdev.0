From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] X.25 async net_device fixup
Date: Tue, 5 Aug 2003 15:43:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805154335.7abfcb92.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Henner Eisen <eis@baty.hanse.de>, "David S. Miller" <davem@redhat.com>,
   linux-x25@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert X.25 async driver to have dynamic net_device's.
This driver is a lot like SLIP so the code changes were similar.  
	- Added similar locking to SLIP
	- replaced code that snooped for MTU changes with the
 	  net_device change mtu callback.
	- cleaned up the statistics by using the net_device_stats structure.

Patch is against 2.6.0-test2.

Not sure if anyone ever uses this.  I tested by bringing up an x.25 async
line using a modified version of slattach.


diff -urNp -X dontdiff net-2.5/drivers/net/wan/x25_asy.c linux-2.5-net/drivers/net/wan/x25_asy.c
--- net-2.5/drivers/net/wan/x25_asy.c	2003-08-01 11:11:42.000000000 -0700
+++ linux-2.5-net/drivers/net/wan/x25_asy.c	2003-07-31 13:22:41.000000000 -0700
@@ -34,81 +34,67 @@
 #include <linux/init.h>
 #include "x25_asy.h"
 
-typedef struct x25_ctrl {
-	struct x25_asy	ctrl;		/* X.25 things			*/
-	struct net_device	dev;		/* the device			*/
-} x25_asy_ctrl_t;
-
-static x25_asy_ctrl_t	**x25_asy_ctrls = NULL;
-
-int x25_asy_maxdev = SL_NRUNIT;		/* Can be overridden with insmod! */
+static struct net_device **x25_asy_devs;
+static int x25_asy_maxdev = SL_NRUNIT;
 
 MODULE_PARM(x25_asy_maxdev, "i");
 MODULE_LICENSE("GPL");
 
 static int x25_asy_esc(unsigned char *p, unsigned char *d, int len);
 static void x25_asy_unesc(struct x25_asy *sl, unsigned char c);
+static void x25_asy_setup(struct net_device *dev);
 
 /* Find a free X.25 channel, and link in this `tty' line. */
-static inline struct x25_asy *x25_asy_alloc(void)
+static struct x25_asy *x25_asy_alloc(void)
 {
-	x25_asy_ctrl_t *slp = NULL;
+	struct net_device *dev = NULL;
+	struct x25_asy *sl;
 	int i;
 
-	if (x25_asy_ctrls == NULL)
+	if (x25_asy_devs == NULL)
 		return NULL;	/* Master array missing ! */
 
-	for (i = 0; i < x25_asy_maxdev; i++) 
-	{
-		slp = x25_asy_ctrls[i];
+	for (i = 0; i < x25_asy_maxdev; i++) {
+		dev = x25_asy_devs[i];
+
 		/* Not allocated ? */
-		if (slp == NULL)
+		if (dev == NULL)
 			break;
+
+		sl = dev->priv;
 		/* Not in use ? */
-		if (!test_and_set_bit(SLF_INUSE, &slp->ctrl.flags))
-			break;
+		if (!test_and_set_bit(SLF_INUSE, &sl->flags))
+			return sl;
 	}
-	/* SLP is set.. */
+
 
 	/* Sorry, too many, all slots in use */
 	if (i >= x25_asy_maxdev)
 		return NULL;
 
 	/* If no channels are available, allocate one */
-	if (!slp &&
-	    (x25_asy_ctrls[i] = (x25_asy_ctrl_t *)kmalloc(sizeof(x25_asy_ctrl_t),
-						    GFP_KERNEL)) != NULL) {
-		slp = x25_asy_ctrls[i];
-		memset(slp, 0, sizeof(x25_asy_ctrl_t));
+	if (!dev) {
+		char name[IFNAMSIZ];
+		sprintf(name, "x25asy%d", i);
+
+		dev = alloc_netdev(sizeof(struct x25_asy),
+				   name, x25_asy_setup);
+		if (!dev)
+			return NULL;
 
 		/* Initialize channel control data */
-		set_bit(SLF_INUSE, &slp->ctrl.flags);
-		slp->ctrl.tty         = NULL;
-		sprintf(slp->dev.name, "x25asy%d", i);
-		slp->dev.base_addr    = i;
-		slp->dev.priv         = (void*)&(slp->ctrl);
-		slp->dev.next         = NULL;
-		slp->dev.init         = x25_asy_init;
-	}
-	if (slp != NULL) 
-	{
+		sl = dev->priv;
+		dev->base_addr    = i;
 
 		/* register device so that it can be ifconfig'ed       */
-		/* x25_asy_init() will be called as a side-effect      */
-		/* SIDE-EFFECT WARNING: x25_asy_init() CLEARS slp->ctrl ! */
-
-		if (register_netdev(&(slp->dev)) == 0) 
-		{
+		if (register_netdev(dev) == 0) {
 			/* (Re-)Set the INUSE bit.   Very Important! */
-			set_bit(SLF_INUSE, &slp->ctrl.flags);
-			slp->ctrl.dev = &(slp->dev);
-			slp->dev.priv = (void*)&(slp->ctrl);
-			return (&(slp->ctrl));
-		}
-		else
-		{
-			clear_bit(SLF_INUSE,&(slp->ctrl.flags));
+			set_bit(SLF_INUSE, &sl->flags);
+			x25_asy_devs[i] = dev;
+			return sl;
+		} else {
 			printk("x25_asy_alloc() - register_netdev() failure.\n");
+			kfree(dev);
 		}
 	}
 	return NULL;
@@ -116,8 +102,7 @@ static inline struct x25_asy *x25_asy_al
 
 
 /* Free an X.25 channel. */
-
-static inline void x25_asy_free(struct x25_asy *sl)
+static void x25_asy_free(struct x25_asy *sl)
 {
 	/* Free all X.25 frame buffers. */
 	if (sl->rbuff)  {
@@ -134,18 +119,11 @@ static inline void x25_asy_free(struct x
 	}
 }
 
-/* MTU has been changed by the IP layer. Unfortunately we are not told
-   about this, but we spot it ourselves and fix things up. We could be
-   in an upcall from the tty driver, or in an ip packet queue. */
-
-static void x25_asy_changed_mtu(struct x25_asy *sl)
-{
-	struct net_device *dev = sl->dev;
-	unsigned char *xbuff, *rbuff, *oxbuff, *orbuff;
-	int len;
-	unsigned long flags;
-
-	len = dev->mtu * 2;
+static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
+{
+	struct x25_asy *sl = dev->priv;
+	unsigned char *xbuff, *rbuff;
+	int len = 2* newmtu;
 
 	xbuff = (unsigned char *) kmalloc (len + 4, GFP_ATOMIC);
 	rbuff = (unsigned char *) kmalloc (len + 4, GFP_ATOMIC);
@@ -153,52 +131,47 @@ static void x25_asy_changed_mtu(struct x
 	if (xbuff == NULL || rbuff == NULL)  
 	{
 		printk("%s: unable to grow X.25 buffers, MTU change cancelled.\n",
-		       sl->dev->name);
-		dev->mtu = sl->mtu;
+		       dev->name);
 		if (xbuff != NULL)  
 			kfree(xbuff);
 		if (rbuff != NULL)  
 			kfree(rbuff);
-		return;
+		return -ENOMEM;
 	}
 
-	save_flags(flags); 
-	cli();
-
-	oxbuff    = sl->xbuff;
-	sl->xbuff = xbuff;
-	orbuff    = sl->rbuff;
-	sl->rbuff = rbuff;
-
+	spin_lock_bh(&sl->lock);
+	xbuff    = xchg(&sl->xbuff, xbuff);
 	if (sl->xleft)  {
 		if (sl->xleft <= len)  {
 			memcpy(sl->xbuff, sl->xhead, sl->xleft);
 		} else  {
 			sl->xleft = 0;
-			sl->tx_dropped++;
+			sl->stats.tx_dropped++;
 		}
 	}
 	sl->xhead = sl->xbuff;
 
+	rbuff	 = xchg(&sl->rbuff, rbuff);
 	if (sl->rcount)  {
 		if (sl->rcount <= len) {
-			memcpy(sl->rbuff, orbuff, sl->rcount);
+			memcpy(sl->rbuff, rbuff, sl->rcount);
 		} else  {
 			sl->rcount = 0;
-			sl->rx_over_errors++;
+			sl->stats.rx_over_errors++;
 			set_bit(SLF_ERROR, &sl->flags);
 		}
 	}
-	sl->mtu      = dev->mtu;
 
+	dev->mtu    = newmtu;
 	sl->buffsize = len;
 
-	restore_flags(flags);
+	spin_unlock_bh(&sl->lock);
 
-	if (oxbuff != NULL) 
-		kfree(oxbuff);
-	if (orbuff != NULL)
-		kfree(orbuff);
+	if (xbuff != NULL) 
+		kfree(xbuff);
+	if (rbuff != NULL)
+		kfree(rbuff);
+	return 0;
 }
 
 
@@ -226,13 +199,13 @@ static void x25_asy_bump(struct x25_asy 
 	int err;
 
 	count = sl->rcount;
-	sl->rx_bytes+=count;
+	sl->stats.rx_bytes+=count;
 	
 	skb = dev_alloc_skb(count+1);
 	if (skb == NULL)  
 	{
 		printk("%s: memory squeeze, dropping packet.\n", sl->dev->name);
-		sl->rx_dropped++;
+		sl->stats.rx_dropped++;
 		return;
 	}
 	skb_push(skb,1);	/* LAPB internal control */
@@ -249,7 +222,7 @@ static void x25_asy_bump(struct x25_asy 
 	{
 		netif_rx(skb);
 		sl->dev->last_rx = jiffies;
-		sl->rx_packets++;
+		sl->stats.rx_packets++;
 	}
 }
 
@@ -257,19 +230,13 @@ static void x25_asy_bump(struct x25_asy 
 static void x25_asy_encaps(struct x25_asy *sl, unsigned char *icp, int len)
 {
 	unsigned char *p;
-	int actual, count;
-
+	int actual, count, mtu = sl->dev->mtu;
 
-	if (sl->mtu != sl->dev->mtu) {	/* Someone has been ifconfigging */
-
-		x25_asy_changed_mtu(sl);
-	}
-
-	if (len > sl->mtu) 
+	if (len > mtu) 
 	{		/* Sigh, shouldn't occur BUT ... */
-		len = sl->mtu;
+		len = mtu;
 		printk ("%s: truncating oversized transmit packet!\n", sl->dev->name);
-		sl->tx_dropped++;
+		sl->stats.tx_dropped++;
 		x25_asy_unlock(sl);
 		return;
 	}
@@ -310,7 +277,7 @@ static void x25_asy_write_wakeup(struct 
 	{
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
-		sl->tx_packets++;
+		sl->stats.tx_packets++;
 		tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
 		x25_asy_unlock(sl);
 		return;
@@ -324,15 +291,20 @@ static void x25_asy_write_wakeup(struct 
 static void x25_asy_timeout(struct net_device *dev)
 {
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
-	/* May be we must check transmitter timeout here ?
-	 *      14 Oct 1994 Dmitry Gorodchanin.
-	 */
-	printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
-	       (sl->tty->driver->chars_in_buffer(sl->tty) || sl->xleft) ?
-	       "bad line quality" : "driver error");
-	sl->xleft = 0;
-	sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
-	x25_asy_unlock(sl);
+
+	spin_lock(&sl->lock);
+	if (netif_queue_stopped(dev)) {
+		/* May be we must check transmitter timeout here ?
+		 *      14 Oct 1994 Dmitry Gorodchanin.
+		 */
+		printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
+		       (sl->tty->driver->chars_in_buffer(sl->tty) || sl->xleft) ?
+		       "bad line quality" : "driver error");
+		sl->xleft = 0;
+		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
+		x25_asy_unlock(sl);
+	}
+	spin_unlock(&sl->lock);
 }
 
 /* Encapsulate an IP datagram and kick it into a TTY queue. */
@@ -342,10 +314,10 @@ static int x25_asy_xmit(struct sk_buff *
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
 	int err;
 
-	if (!netif_running(sl->dev))
-	{
+	if (!netif_running(sl->dev)) {
 		printk("%s: xmit call when iface is down\n", dev->name);
-		return 1;
+		kfree_skb(skb);
+		return 0;
 	}
 	
 	switch(skb->data[0])
@@ -409,8 +381,11 @@ static int x25_asy_data_indication(void 
 static void x25_asy_data_transmit(void *token, struct sk_buff *skb)
 {
 	struct x25_asy *sl=token;
-	if (netif_queue_stopped(sl->dev))
+	
+	spin_lock(&sl->lock);
+	if (netif_queue_stopped(sl->dev) || sl->tty == NULL)
 	{
+		spin_unlock(&sl->lock);
 		printk(KERN_ERR "x25_asy: tbusy drop\n");
 		kfree_skb(skb);
 		return;
@@ -419,10 +394,11 @@ static void x25_asy_data_transmit(void *
 	if (skb != NULL) 
 	{
 		x25_asy_lock(sl);
-		sl->tx_bytes+=skb->len;
+		sl->stats.tx_bytes+=skb->len;
 		x25_asy_encaps(sl, skb->data, skb->len);
 		dev_kfree_skb(skb);
 	}
+	spin_unlock(&sl->lock);
 }
 
 /*
@@ -475,12 +451,20 @@ static void x25_asy_disconnected(void *t
 	sl->dev->last_rx = jiffies;
 }
 
+static struct lapb_register_struct x25_asy_callbacks = {
+	.connect_confirmation = x25_asy_connected,
+	.connect_indication = x25_asy_connected,
+	.disconnect_confirmation = x25_asy_disconnected,
+	.disconnect_indication = x25_asy_disconnected,
+	.data_indication = x25_asy_data_indication,
+	.data_transmit = x25_asy_data_transmit,
+
+};
 
-/* Open the low-level part of the X.25 channel. Easy! */
 
+/* Open the low-level part of the X.25 channel. Easy! */
 static int x25_asy_open(struct net_device *dev)
 {
-	struct lapb_register_struct x25_asy_callbacks;
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
 	unsigned long len;
 	int err;
@@ -505,7 +489,7 @@ static int x25_asy_open(struct net_devic
 	if (sl->xbuff == NULL)   {
 		goto noxbuff;
 	}
-	sl->mtu	     = dev->mtu;
+
 	sl->buffsize = len;
 	sl->rcount   = 0;
 	sl->xleft    = 0;
@@ -516,14 +500,6 @@ static int x25_asy_open(struct net_devic
 	/*
 	 *	Now attach LAPB
 	 */
-	 
-	x25_asy_callbacks.connect_confirmation=x25_asy_connected;
-	x25_asy_callbacks.connect_indication=x25_asy_connected;
-	x25_asy_callbacks.disconnect_confirmation=x25_asy_disconnected;
-	x25_asy_callbacks.disconnect_indication=x25_asy_disconnected;
-	x25_asy_callbacks.data_indication=x25_asy_data_indication;
-	x25_asy_callbacks.data_transmit=x25_asy_data_transmit;
-
 	if((err=lapb_register(sl, &x25_asy_callbacks))==LAPB_OK)
 		return 0;
 
@@ -542,13 +518,16 @@ static int x25_asy_close(struct net_devi
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
 	int err;
 
-	if (sl->tty == NULL)
-		return -EBUSY;
+	spin_lock(&sl->lock);
+	if (sl->tty) 
+		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
 
-	sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
 	netif_stop_queue(dev);
+	sl->rcount = 0;
+	sl->xleft  = 0;
 	if((err=lapb_unregister(sl))!=LAPB_OK)
 		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",err);
+	spin_unlock(&sl->lock);
 	return 0;
 }
 
@@ -571,20 +550,12 @@ static void x25_asy_receive_buf(struct t
 	if (!sl || sl->magic != X25_ASY_MAGIC || !netif_running(sl->dev))
 		return;
 
-	/*
-	 * Argh! mtu change time! - costs us the packet part received
-	 * at the change
-	 */
-	if (sl->mtu != sl->dev->mtu)  {
-
-		x25_asy_changed_mtu(sl);
-	}
 
 	/* Read the characters out of the buffer */
 	while (count--) {
 		if (fp && *fp++) {
 			if (!test_and_set_bit(SLF_ERROR, &sl->flags))  {
-				sl->rx_errors++;
+				sl->stats.rx_errors++;
 			}
 			cp++;
 			continue;
@@ -659,27 +630,14 @@ static void x25_asy_close_tty(struct tty
 	tty->disc_data = 0;
 	sl->tty = NULL;
 	x25_asy_free(sl);
-	unregister_netdev(sl->dev);
 }
 
 
 static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
 {
-	static struct net_device_stats stats;
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
 
-	memset(&stats, 0, sizeof(struct net_device_stats));
-
-	stats.rx_packets     = sl->rx_packets;
-	stats.tx_packets     = sl->tx_packets;
-	stats.rx_bytes	     = sl->rx_bytes;
-	stats.tx_bytes	     = sl->tx_bytes;
-	stats.rx_dropped     = sl->rx_dropped;
-	stats.tx_dropped     = sl->tx_dropped;
-	stats.tx_errors      = sl->tx_errors;
-	stats.rx_errors      = sl->rx_errors;
-	stats.rx_over_errors = sl->rx_over_errors;
-	return (&stats);
+	return &sl->stats;
 }
 
 
@@ -757,7 +715,7 @@ static void x25_asy_unesc(struct x25_asy
 			sl->rbuff[sl->rcount++] = s;
 			return;
 		}
-		sl->rx_over_errors++;
+		sl->stats.rx_over_errors++;
 		set_bit(SLF_ERROR, &sl->flags);
 	}
 }
@@ -799,18 +757,14 @@ static int x25_asy_open_dev(struct net_d
 }
 
 /* Initialise the X.25 driver.  Called by the device init code */
-int x25_asy_init(struct net_device *dev)
+static void x25_asy_setup(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
-
-	if (sl == NULL)		/* Allocation failed ?? */
-		return -ENODEV;
-
-	/* Set up the control block. (And clear statistics) */
+	struct x25_asy *sl = dev->priv;
 
-	memset(sl, 0, sizeof (struct x25_asy));
 	sl->magic  = X25_ASY_MAGIC;
 	sl->dev	   = dev;
+	spin_lock_init(&sl->lock);
+	set_bit(SLF_INUSE, &sl->flags);
 
 	/*
 	 *	Finish setting up the DEVICE info. 
@@ -823,6 +777,7 @@ int x25_asy_init(struct net_device *dev)
 	dev->open		= x25_asy_open_dev;
 	dev->stop		= x25_asy_close;
 	dev->get_stats	        = x25_asy_get_stats;
+	dev->change_mtu		= x25_asy_change_mtu;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->type		= ARPHRD_X25;
@@ -830,8 +785,6 @@ int x25_asy_init(struct net_device *dev)
 
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP;
-
-	return 0;
 }
 
 static struct tty_ldisc x25_ldisc = {
@@ -853,13 +806,15 @@ static int __init init_x25_asy(void)
 
 	printk(KERN_INFO "X.25 async: version 0.00 ALPHA "
 			"(dynamic channels, max=%d).\n", x25_asy_maxdev );
-	x25_asy_ctrls = kmalloc(sizeof(void*)*x25_asy_maxdev, GFP_KERNEL);
-	if (!x25_asy_ctrls) {
+
+	x25_asy_devs = kmalloc(sizeof(struct net_device *)*x25_asy_maxdev, 
+			       GFP_KERNEL);
+	if (!x25_asy_devs) {
 		printk(KERN_WARNING "X25 async: Can't allocate x25_asy_ctrls[] "
 				"array! Uaargh! (-> No X.25 available)\n");
 		return -ENOMEM;
 	}
-	memset(x25_asy_ctrls, 0, sizeof(void*)*x25_asy_maxdev); /* Pointers */
+	memset(x25_asy_devs, 0, sizeof(struct net_device *)*x25_asy_maxdev); 
 
 	return tty_register_ldisc(N_X25, &x25_ldisc);
 }
@@ -867,22 +822,29 @@ static int __init init_x25_asy(void)
 
 static void __exit exit_x25_asy(void)
 {
+	struct net_device *dev;
 	int i;
 
 	for (i = 0; i < x25_asy_maxdev; i++) {
-		if (x25_asy_ctrls[i]) {
+		dev = x25_asy_devs[i];
+		if (dev) {
+			struct x25_asy *sl = dev->priv;
+
+			spin_lock_bh(&sl->lock);
+			if (sl->tty) 
+				tty_hangup(sl->tty);
+
+			spin_unlock_bh(&sl->lock);
 			/*
 			 * VSV = if dev->start==0, then device
 			 * unregistered while close proc.
 			 */
-			if (netif_running(&(x25_asy_ctrls[i]->dev)))
-				unregister_netdev(&(x25_asy_ctrls[i]->dev));
-
-			kfree(x25_asy_ctrls[i]);
+			unregister_netdev(dev);
+			kfree(dev);
 		}
 	}
 
-	kfree(x25_asy_ctrls);
+	kfree(x25_asy_devs);
 	tty_register_ldisc(N_X25, NULL);
 }
 
diff -urNp -X dontdiff net-2.5/drivers/net/wan/x25_asy.h linux-2.5-net/drivers/net/wan/x25_asy.h
--- net-2.5/drivers/net/wan/x25_asy.h	2003-08-01 11:11:42.000000000 -0700
+++ linux-2.5-net/drivers/net/wan/x25_asy.h	2003-07-30 14:29:19.000000000 -0700
@@ -18,8 +18,9 @@ struct x25_asy {
   int			magic;
 
   /* Various fields. */
+  spinlock_t		lock;
   struct tty_struct	*tty;		/* ptr to TTY structure		*/
-  struct net_device		*dev;		/* easy for intr handling	*/
+  struct net_device	*dev;		/* easy for intr handling	*/
 
   /* These are pointers to the malloc()ed frame buffers. */
   unsigned char		*rbuff;		/* receiver buffer		*/
@@ -29,17 +30,8 @@ struct x25_asy {
   int                   xleft;          /* bytes left in XMIT queue     */
 
   /* X.25 interface statistics. */
-  unsigned long		rx_packets;	/* inbound frames counter	*/
-  unsigned long         tx_packets;     /* outbound frames counter      */
-  unsigned long		rx_bytes;	/* inbound byte counte		*/
-  unsigned long         tx_bytes;       /* outbound byte counter	*/
-  unsigned long         rx_errors;      /* Parity, etc. errors          */
-  unsigned long         tx_errors;      /* Planned stuff                */
-  unsigned long         rx_dropped;     /* No memory for skb            */
-  unsigned long         tx_dropped;     /* When MTU change              */
-  unsigned long         rx_over_errors; /* Frame bigger then X.25 buf.  */
+  struct net_device_stats stats;
 
-  int			mtu;		/* Our mtu (to spot changes!)   */
   int                   buffsize;       /* Max buffers sizes            */
 
   unsigned long		flags;		/* Flag values/ mode etc	*/
