From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] x25_asy: Code cleanup
Date: Tue, 29 Apr 2008 14:33:09 +0100
Message-ID: <20080429143309.6115fb52@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:49600 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758163AbYD2NlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 09:41:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to tty->ops->
Use the new methods
Pass coding style.

Signed-off-by: Alan Cox <alan@redhat.com>

diff -u --new-file --recursive --exclude-from /usr/src/exclude linux.vanilla-2.6.25-mm1/drivers/net/wan/x25_asy.c linux-2.6.25-mm1/drivers/net/wan/x25_asy.c
--- linux.vanilla-2.6.25-mm1/drivers/net/wan/x25_asy.c	2008-04-28 11:36:43.000000000 +0100
+++ linux-2.6.25-mm1/drivers/net/wan/x25_asy.c	2008-04-18 10:23:27.000000000 +0100
@@ -17,7 +17,7 @@
 #include <linux/module.h>
 
 #include <asm/system.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/string.h>
 #include <linux/mm.h>
@@ -95,7 +95,7 @@
 			x25_asy_devs[i] = dev;
 			return sl;
 		} else {
-			printk("x25_asy_alloc() - register_netdev() failure.\n");
+			printk(KERN_WARNING "x25_asy_alloc() - register_netdev() failure.\n");
 			free_netdev(dev);
 		}
 	}
@@ -112,23 +112,22 @@
 	kfree(sl->xbuff);
 	sl->xbuff = NULL;
 
-	if (!test_and_clear_bit(SLF_INUSE, &sl->flags)) {
-		printk("%s: x25_asy_free for already free unit.\n", sl->dev->name);
-	}
+	if (!test_and_clear_bit(SLF_INUSE, &sl->flags))
+		printk(KERN_ERR "%s: x25_asy_free for already free unit.\n",
+			sl->dev->name);
 }
 
 static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
 	struct x25_asy *sl = dev->priv;
 	unsigned char *xbuff, *rbuff;
-	int len = 2* newmtu;
+	int len = 2 * newmtu;
 
 	xbuff = kmalloc(len + 4, GFP_ATOMIC);
 	rbuff = kmalloc(len + 4, GFP_ATOMIC);
 
-	if (xbuff == NULL || rbuff == NULL)  
-	{
-		printk("%s: unable to grow X.25 buffers, MTU change cancelled.\n",
+	if (xbuff == NULL || rbuff == NULL) {
+		printk(KERN_WARNING "%s: unable to grow X.25 buffers, MTU change cancelled.\n",
 		       dev->name);
 		kfree(xbuff);
 		kfree(rbuff);
@@ -193,25 +192,23 @@
 	int err;
 
 	count = sl->rcount;
-	sl->stats.rx_bytes+=count;
-	
+	sl->stats.rx_bytes += count;
+
 	skb = dev_alloc_skb(count+1);
-	if (skb == NULL)  
-	{
-		printk("%s: memory squeeze, dropping packet.\n", sl->dev->name);
+	if (skb == NULL) {
+		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n",
+			sl->dev->name);
 		sl->stats.rx_dropped++;
 		return;
 	}
-	skb_push(skb,1);	/* LAPB internal control */
-	memcpy(skb_put(skb,count), sl->rbuff, count);
+	skb_push(skb, 1);	/* LAPB internal control */
+	memcpy(skb_put(skb, count), sl->rbuff, count);
 	skb->protocol = x25_type_trans(skb, sl->dev);
-	if((err=lapb_data_received(skb->dev, skb))!=LAPB_OK)
-	{
+	err = lapb_data_received(skb->dev, skb);
+	if (err != LAPB_OK) {
 		kfree_skb(skb);
-		printk(KERN_DEBUG "x25_asy: data received err - %d\n",err);
-	}
-	else
-	{
+		printk(KERN_DEBUG "x25_asy: data received err - %d\n", err);
+	} else {
 		netif_rx(skb);
 		sl->dev->last_rx = jiffies;
 		sl->stats.rx_packets++;
@@ -224,10 +221,11 @@
 	unsigned char *p;
 	int actual, count, mtu = sl->dev->mtu;
 
-	if (len > mtu) 
-	{		/* Sigh, shouldn't occur BUT ... */
+	if (len > mtu) {
+		/* Sigh, shouldn't occur BUT ... */
 		len = mtu;
-		printk ("%s: truncating oversized transmit packet!\n", sl->dev->name);
+		printk(KERN_DEBUG "%s: truncating oversized transmit packet!\n",
+					sl->dev->name);
 		sl->stats.tx_dropped++;
 		x25_asy_unlock(sl);
 		return;
@@ -245,7 +243,7 @@
 	 *       14 Oct 1994  Dmitry Gorodchanin.
 	 */
 	sl->tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
-	actual = sl->tty->driver->write(sl->tty, sl->xbuff, count);
+	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
 	sl->xleft = count - actual;
 	sl->xhead = sl->xbuff + actual;
 	/* VSV */
@@ -265,8 +263,7 @@
 	if (!sl || sl->magic != X25_ASY_MAGIC || !netif_running(sl->dev))
 		return;
 
-	if (sl->xleft <= 0)  
-	{
+	if (sl->xleft <= 0) {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
 		sl->stats.tx_packets++;
@@ -275,14 +272,14 @@
 		return;
 	}
 
-	actual = tty->driver->write(tty, sl->xhead, sl->xleft);
+	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
 	sl->xleft -= actual;
 	sl->xhead += actual;
 }
 
 static void x25_asy_timeout(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = dev->priv;
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(dev)) {
@@ -290,7 +287,7 @@
 		 *      14 Oct 1994 Dmitry Gorodchanin.
 		 */
 		printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
-		       (sl->tty->driver->chars_in_buffer(sl->tty) || sl->xleft) ?
+		       (tty_chars_in_buffer(sl->tty) || sl->xleft) ?
 		       "bad line quality" : "driver error");
 		sl->xleft = 0;
 		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
@@ -303,31 +300,34 @@
 
 static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = dev->priv;
 	int err;
 
 	if (!netif_running(sl->dev)) {
-		printk("%s: xmit call when iface is down\n", dev->name);
+		printk(KERN_ERR "%s: xmit call when iface is down\n",
+			dev->name);
 		kfree_skb(skb);
 		return 0;
 	}
-	
-	switch(skb->data[0])
-	{
-		case 0x00:break;
-		case 0x01: /* Connection request .. do nothing */
-			if((err=lapb_connect_request(dev))!=LAPB_OK)
-				printk(KERN_ERR "x25_asy: lapb_connect_request error - %d\n", err);
-			kfree_skb(skb);
-			return 0;
-		case 0x02: /* Disconnect request .. do nothing - hang up ?? */
-			if((err=lapb_disconnect_request(dev))!=LAPB_OK)
-				printk(KERN_ERR "x25_asy: lapb_disconnect_request error - %d\n", err);
-		default:
-			kfree_skb(skb);
-			return  0;
+
+	switch (skb->data[0]) {
+	case 0x00:
+		break;
+	case 0x01: /* Connection request .. do nothing */
+		err = lapb_connect_request(dev);
+		if (err != LAPB_OK)
+			printk(KERN_ERR "x25_asy: lapb_connect_request error - %d\n", err);
+		kfree_skb(skb);
+		return 0;
+	case 0x02: /* Disconnect request .. do nothing - hang up ?? */
+		err = lapb_disconnect_request(dev);
+		if (err != LAPB_OK)
+			printk(KERN_ERR "x25_asy: lapb_disconnect_request error - %d\n", err);
+	default:
+		kfree_skb(skb);
+		return  0;
 	}
-	skb_pull(skb,1);	/* Remove control byte */
+	skb_pull(skb, 1);	/* Remove control byte */
 	/*
 	 * If we are busy already- too bad.  We ought to be able
 	 * to queue things at this point, to allow for a little
@@ -338,10 +338,10 @@
 	 * So, no queues !
 	 *        14 Oct 1994  Dmitry Gorodchanin.
 	 */
-	
-	if((err=lapb_data_request(dev,skb))!=LAPB_OK)
-	{
-		printk(KERN_ERR "lapbeth: lapb_data_request error - %d\n", err);
+
+	err = lapb_data_request(dev, skb);
+	if (err != LAPB_OK) {
+		printk(KERN_ERR "x25_asy: lapb_data_request error - %d\n", err);
 		kfree_skb(skb);
 		return 0;
 	}
@@ -357,7 +357,7 @@
  *	Called when I frame data arrives. We did the work above - throw it
  *	at the net layer.
  */
-  
+
 static int x25_asy_data_indication(struct net_device *dev, struct sk_buff *skb)
 {
 	skb->dev->last_rx = jiffies;
@@ -369,24 +369,22 @@
  *	busy cases too well. Its tricky to see how to do this nicely -
  *	perhaps lapb should allow us to bounce this ?
  */
- 
+
 static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 {
-	struct x25_asy *sl=dev->priv;
-	
+	struct x25_asy *sl = dev->priv;
+
 	spin_lock(&sl->lock);
-	if (netif_queue_stopped(sl->dev) || sl->tty == NULL)
-	{
+	if (netif_queue_stopped(sl->dev) || sl->tty == NULL) {
 		spin_unlock(&sl->lock);
 		printk(KERN_ERR "x25_asy: tbusy drop\n");
 		kfree_skb(skb);
 		return;
 	}
 	/* We were not busy, so we are now... :-) */
-	if (skb != NULL) 
-	{
+	if (skb != NULL) {
 		x25_asy_lock(sl);
-		sl->stats.tx_bytes+=skb->len;
+		sl->stats.tx_bytes += skb->len;
 		x25_asy_encaps(sl, skb->data, skb->len);
 		dev_kfree_skb(skb);
 	}
@@ -396,15 +394,16 @@
 /*
  *	LAPB connection establish/down information.
  */
- 
+
 static void x25_asy_connected(struct net_device *dev, int reason)
 {
 	struct x25_asy *sl = dev->priv;
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
-	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "lapbeth: out of memory\n");
+	skb = dev_alloc_skb(1);
+	if (skb == NULL) {
+		printk(KERN_ERR "x25_asy: out of memory\n");
 		return;
 	}
 
@@ -422,7 +421,8 @@
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
-	if ((skb = dev_alloc_skb(1)) == NULL) {
+	skb = dev_alloc_skb(1);
+	if (skb == NULL) {
 		printk(KERN_ERR "x25_asy: out of memory\n");
 		return;
 	}
@@ -449,7 +449,7 @@
 /* Open the low-level part of the X.25 channel. Easy! */
 static int x25_asy_open(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = dev->priv;
 	unsigned long len;
 	int err;
 
@@ -466,13 +466,11 @@
 	len = dev->mtu * 2;
 
 	sl->rbuff = kmalloc(len + 4, GFP_KERNEL);
-	if (sl->rbuff == NULL)   {
+	if (sl->rbuff == NULL)
 		goto norbuff;
-	}
 	sl->xbuff = kmalloc(len + 4, GFP_KERNEL);
-	if (sl->xbuff == NULL)   {
+	if (sl->xbuff == NULL)
 		goto noxbuff;
-	}
 
 	sl->buffsize = len;
 	sl->rcount   = 0;
@@ -480,11 +478,12 @@
 	sl->flags   &= (1 << SLF_INUSE);      /* Clear ESCAPE & ERROR flags */
 
 	netif_start_queue(dev);
-			
+
 	/*
 	 *	Now attach LAPB
 	 */
-	if((err=lapb_register(dev, &x25_asy_callbacks))==LAPB_OK)
+	err = lapb_register(dev, &x25_asy_callbacks);
+	if (err == LAPB_OK)
 		return 0;
 
 	/* Cleanup */
@@ -499,18 +498,20 @@
 /* Close the low-level part of the X.25 channel. Easy! */
 static int x25_asy_close(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
+	struct x25_asy *sl = dev->priv;
 	int err;
 
 	spin_lock(&sl->lock);
-	if (sl->tty) 
+	if (sl->tty)
 		sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
 
 	netif_stop_queue(dev);
 	sl->rcount = 0;
 	sl->xleft  = 0;
-	if((err=lapb_unregister(dev))!=LAPB_OK)
-		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",err);
+	err = lapb_unregister(dev);
+	if (err != LAPB_OK)
+		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",
+			err);
 	spin_unlock(&sl->lock);
 	return 0;
 }
@@ -521,8 +522,9 @@
  * a block of X.25 data has been received, which can now be decapsulated
  * and sent on to some IP layer for further processing.
  */
- 
-static void x25_asy_receive_buf(struct tty_struct *tty, const unsigned char *cp, char *fp, int count)
+
+static void x25_asy_receive_buf(struct tty_struct *tty,
+				const unsigned char *cp, char *fp, int count)
 {
 	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
 
@@ -533,9 +535,8 @@
 	/* Read the characters out of the buffer */
 	while (count--) {
 		if (fp && *fp++) {
-			if (!test_and_set_bit(SLF_ERROR, &sl->flags))  {
+			if (!test_and_set_bit(SLF_ERROR, &sl->flags))
 				sl->stats.rx_errors++;
-			}
 			cp++;
 			continue;
 		}
@@ -556,31 +557,31 @@
 	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
 	int err;
 
+	if (tty->ops->write == NULL)
+		return -EOPNOTSUPP;
+
 	/* First make sure we're not already connected. */
-	if (sl && sl->magic == X25_ASY_MAGIC) {
+	if (sl && sl->magic == X25_ASY_MAGIC)
 		return -EEXIST;
-	}
 
 	/* OK.  Find a free X.25 channel to use. */
-	if ((sl = x25_asy_alloc()) == NULL) {
+	sl = x25_asy_alloc();
+	if (sl == NULL)
 		return -ENFILE;
-	}
 
 	sl->tty = tty;
 	tty->disc_data = sl;
 	tty->receive_room = 65536;
-	if (tty->driver->flush_buffer)  {
-		tty->driver->flush_buffer(tty);
-	}
+	tty_driver_flush_buffer(tty);
 	tty_ldisc_flush(tty);
 
 	/* Restore default settings */
 	sl->dev->type = ARPHRD_X25;
-	
+
 	/* Perform the low-level X.25 async init */
-	if ((err = x25_asy_open(sl->dev)))
+	err = x25_asy_open(sl->dev);
+	if (err)
 		return err;
-
 	/* Done.  We have linked the TTY line to a channel. */
 	return sl->dev->base_addr;
 }
@@ -601,9 +602,7 @@
 		return;
 
 	if (sl->dev->flags & IFF_UP)
-	{
-		(void) dev_close(sl->dev);
-	}
+		dev_close(sl->dev);
 
 	tty->disc_data = NULL;
 	sl->tty = NULL;
@@ -613,8 +612,7 @@
 
 static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
-
+	struct x25_asy *sl = dev->priv;
 	return &sl->stats;
 }
 
@@ -641,21 +639,19 @@
 	 * character sequence, according to the X.25 protocol.
 	 */
 
-	while (len-- > 0) 
-	{
-		switch(c = *s++) 
-		{
-			case X25_END:
-				*ptr++ = X25_ESC;
-				*ptr++ = X25_ESCAPE(X25_END);
-				break;
-			case X25_ESC:
-				*ptr++ = X25_ESC;
-				*ptr++ = X25_ESCAPE(X25_ESC);
-				break;
-			 default:
-				*ptr++ = c;
-				break;
+	while (len-- > 0) {
+		switch (c = *s++) {
+		case X25_END:
+			*ptr++ = X25_ESC;
+			*ptr++ = X25_ESCAPE(X25_END);
+			break;
+		case X25_ESC:
+			*ptr++ = X25_ESC;
+			*ptr++ = X25_ESCAPE(X25_ESC);
+			break;
+		default:
+			*ptr++ = c;
+			break;
 		}
 	}
 	*ptr++ = X25_END;
@@ -665,31 +661,25 @@
 static void x25_asy_unesc(struct x25_asy *sl, unsigned char s)
 {
 
-	switch(s) 
-	{
-		case X25_END:
-			if (!test_and_clear_bit(SLF_ERROR, &sl->flags) && (sl->rcount > 2))  
-			{
-				x25_asy_bump(sl);
-			}
-			clear_bit(SLF_ESCAPE, &sl->flags);
-			sl->rcount = 0;
-			return;
-
-		case X25_ESC:
-			set_bit(SLF_ESCAPE, &sl->flags);
-			return;
-			
-		case X25_ESCAPE(X25_ESC):
-		case X25_ESCAPE(X25_END):
-			if (test_and_clear_bit(SLF_ESCAPE, &sl->flags))
-				s = X25_UNESCAPE(s);
-			break;
+	switch (s) {
+	case X25_END:
+		if (!test_and_clear_bit(SLF_ERROR, &sl->flags)
+			&& sl->rcount > 2)
+			x25_asy_bump(sl);
+		clear_bit(SLF_ESCAPE, &sl->flags);
+		sl->rcount = 0;
+		return;
+	case X25_ESC:
+		set_bit(SLF_ESCAPE, &sl->flags);
+		return;
+	case X25_ESCAPE(X25_ESC):
+	case X25_ESCAPE(X25_END):
+		if (test_and_clear_bit(SLF_ESCAPE, &sl->flags))
+			s = X25_UNESCAPE(s);
+		break;
 	}
-	if (!test_bit(SLF_ERROR, &sl->flags))  
-	{
-		if (sl->rcount < sl->buffsize)  
-		{
+	if (!test_bit(SLF_ERROR, &sl->flags)) {
+		if (sl->rcount < sl->buffsize) {
 			sl->rbuff[sl->rcount++] = s;
 			return;
 		}
@@ -709,7 +699,7 @@
 	if (!sl || sl->magic != X25_ASY_MAGIC)
 		return -EINVAL;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGIFNAME:
 		if (copy_to_user((void __user *)arg, sl->dev->name,
 					strlen(sl->dev->name) + 1))
@@ -724,8 +714,8 @@
 
 static int x25_asy_open_dev(struct net_device *dev)
 {
-	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
-	if(sl->tty==NULL)
+	struct x25_asy *sl = dev->priv;
+	if (sl->tty == NULL)
 		return -ENODEV;
 	return 0;
 }
@@ -741,9 +731,9 @@
 	set_bit(SLF_INUSE, &sl->flags);
 
 	/*
-	 *	Finish setting up the DEVICE info. 
+	 *	Finish setting up the DEVICE info.
 	 */
-	 
+
 	dev->mtu		= SL_MTU;
 	dev->hard_start_xmit	= x25_asy_xmit;
 	dev->tx_timeout		= x25_asy_timeout;
@@ -778,9 +768,10 @@
 		x25_asy_maxdev = 4; /* Sanity */
 
 	printk(KERN_INFO "X.25 async: version 0.00 ALPHA "
-			"(dynamic channels, max=%d).\n", x25_asy_maxdev );
+			"(dynamic channels, max=%d).\n", x25_asy_maxdev);
 
-	x25_asy_devs = kcalloc(x25_asy_maxdev, sizeof(struct net_device*), GFP_KERNEL);
+	x25_asy_devs = kcalloc(x25_asy_maxdev, sizeof(struct net_device *),
+				GFP_KERNEL);
 	if (!x25_asy_devs) {
 		printk(KERN_WARNING "X25 async: Can't allocate x25_asy_ctrls[] "
 				"array! Uaargh! (-> No X.25 available)\n");
@@ -802,7 +793,7 @@
 			struct x25_asy *sl = dev->priv;
 
 			spin_lock_bh(&sl->lock);
-			if (sl->tty) 
+			if (sl->tty)
 				tty_hangup(sl->tty);
 
 			spin_unlock_bh(&sl->lock);
