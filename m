From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert slip driver to alloc_netdev
Date: Fri, 13 Jun 2003 16:09:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613160942.384ca2c3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Slightly more complicated than earlier patches.  Convert slip from having an array of control block
pointers that containing net_device's to an array of net_device pointers.  The slip private data is
allocated with alloc_netdev.  

Also changed the exit loop to use a schedule_timeout instead of yield.  That should work
better on 2.5 and we can sleep there.

This patch is against 2.5.70 with all the earlier net patches applied.

Tested with dedicated serial cable between 2.4 and SUT.

diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	Fri Jun 13 16:03:27 2003
+++ b/drivers/net/slip.c	Fri Jun 13 16:03:27 2003
@@ -83,12 +83,7 @@
 
 #define SLIP_VERSION	"0.8.4-NET3.019-NEWTTY"
 
-
-typedef struct slip_ctrl {
-	struct slip	ctrl;		/* SLIP things			*/
-	struct net_device	dev;		/* the device			*/
-} slip_ctrl_t;
-static slip_ctrl_t	**slip_ctrls;
+static struct net_device **slip_devs;
 
 int slip_maxdev = SL_NRUNIT;		/* Can be overridden with insmod! */
 MODULE_PARM(slip_maxdev, "i");
@@ -624,32 +619,45 @@
 	 */
 
 	dev->mtu		= sl->mtu;
-	dev->hard_start_xmit	= sl_xmit;
+	dev->type		= ARPHRD_SLIP + sl->mode;
 #ifdef SL_CHECK_TRANSMIT
 	dev->tx_timeout		= sl_tx_timeout;
 	dev->watchdog_timeo	= 20*HZ;
 #endif
+	return 0;
+}
+
+
+static void sl_uninit(struct net_device *dev)
+{
+	struct slip *sl = (struct slip*)(dev->priv);
+
+	sl_free_bufs(sl);
+}
+
+static void sl_setup(struct net_device *dev)
+{
+	dev->init		= sl_init;
+	dev->uninit	  	= sl_uninit;
 	dev->open		= sl_open;
+	dev->destructor		= (void (*)(struct net_device *))kfree;
 	dev->stop		= sl_close;
 	dev->get_stats	        = sl_get_stats;
 	dev->change_mtu		= sl_change_mtu;
+	dev->hard_start_xmit	= sl_xmit;
 #ifdef CONFIG_SLIP_SMART
 	dev->do_ioctl		= sl_ioctl;
 #endif
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
-	dev->type		= ARPHRD_SLIP + sl->mode;
 	dev->tx_queue_len	= 10;
 
 	SET_MODULE_OWNER(dev);
 
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP|IFF_POINTOPOINT|IFF_MULTICAST;
-
-	return 0;
 }
 
-
 /******************************************
   Routines looking at TTY side.
  ******************************************/
@@ -702,52 +710,57 @@
 static void sl_sync(void)
 {
 	int i;
+	struct net_device *dev;
+	struct slip	  *sl;
 
 	for (i = 0; i < slip_maxdev; i++) {
-		slip_ctrl_t *slp = slip_ctrls[i];
-		if (slp == NULL)
+		if ((dev = slip_devs[i]) == NULL)
 			break;
-		if (slp->ctrl.tty || slp->ctrl.leased)
+
+		sl = dev->priv;
+		if (sl->tty || sl->leased)
 			continue;
-		if (slp->dev.flags&IFF_UP)
-			dev_close(&slp->dev);
+		if (dev->flags&IFF_UP)
+			dev_close(dev);
 	}
 }
 
+
 /* Find a free SLIP channel, and link in this `tty' line. */
 static struct slip *
 sl_alloc(dev_t line)
 {
-	struct slip *sl;
-	slip_ctrl_t *slp = NULL;
 	int i;
 	int sel = -1;
 	int score = -1;
+	struct net_device *dev = NULL;
+	struct slip       *sl;
 
-	if (slip_ctrls == NULL)
+	if (slip_devs == NULL) 
 		return NULL;	/* Master array missing ! */
 
 	for (i = 0; i < slip_maxdev; i++) {
-		slp = slip_ctrls[i];
-		if (slp == NULL)
+		dev = slip_devs[i];
+		if (dev == NULL)
 			break;
 
-		if (slp->ctrl.leased) {
-			if (slp->ctrl.line != line)
+		sl = dev->priv;
+		if (sl->leased) {
+			if (sl->line != line)
 				continue;
-			if (slp->ctrl.tty)
+			if (sl->tty)
 				return NULL;
 
 			/* Clear ESCAPE & ERROR flags */
-			slp->ctrl.flags &= (1 << SLF_INUSE);
-			return &slp->ctrl;
+			sl->flags &= (1 << SLF_INUSE);
+			return sl;
 		}
 
-		if (slp->ctrl.tty)
+		if (sl->tty)
 			continue;
 
-		if (current->pid == slp->ctrl.pid) {
-			if (slp->ctrl.line == line && score < 3) {
+		if (current->pid == sl->pid) {
+			if (sl->line == line && score < 3) {
 				sel = i;
 				score = 3;
 				continue;
@@ -758,7 +771,7 @@
 			}
 			continue;
 		}
-		if (slp->ctrl.line == line && score < 1) {
+		if (sl->line == line && score < 1) {
 			sel = i;
 			score = 1;
 			continue;
@@ -771,10 +784,11 @@
 
 	if (sel >= 0) {
 		i = sel;
-		slp = slip_ctrls[i];
+		dev = slip_devs[i];
 		if (score > 1) {
-			slp->ctrl.flags &= (1 << SLF_INUSE);
-			return &slp->ctrl;
+			sl = dev->priv;
+			sl->flags &= (1 << SLF_INUSE);
+			return sl;
 		}
 	}
 
@@ -782,26 +796,32 @@
 	if (i >= slip_maxdev)
 		return NULL;
 
-	if (slp) {
-		if (test_bit(SLF_INUSE, &slp->ctrl.flags)) {
-			unregister_netdevice(&slp->dev);
-			sl_free_bufs(&slp->ctrl);
+	if (dev) {
+		sl = dev->priv;
+		if (test_bit(SLF_INUSE, &sl->flags)) {
+			unregister_netdevice(dev);
+			dev = NULL;
+			slip_devs[i] = NULL;
 		}
-	} else if ((slp = (slip_ctrl_t *)kmalloc(sizeof(slip_ctrl_t),GFP_KERNEL)) == NULL)
-		return NULL;
+	}
+	
+	if (!dev) {
+		char name[IFNAMSIZ];
+		sprintf(name, "sl%d", i);
 
-	memset(slp, 0, sizeof(slip_ctrl_t));
+		dev = alloc_netdev(sizeof(*sl), name, sl_setup);
+		if (!dev)
+			return NULL;
+		dev->base_addr  = i;
+	}
+
+	sl = dev->priv;
 
-	sl = &slp->ctrl;
 	/* Initialize channel control data */
 	sl->magic       = SLIP_MAGIC;
-	sl->dev	      	= &slp->dev;
+	sl->dev	      	= dev;
 	spin_lock_init(&sl->lock);
 	sl->mode        = SL_MODE_DEFAULT;
-	sprintf(slp->dev.name, "sl%d", i);
-	slp->dev.base_addr    = i;
-	slp->dev.priv         = (void*)sl;
-	slp->dev.init         = sl_init;
 #ifdef CONFIG_SLIP_SMART
 	init_timer(&sl->keepalive_timer);	/* initialize timer_list struct */
 	sl->keepalive_timer.data=(unsigned long)sl;
@@ -810,8 +830,9 @@
 	sl->outfill_timer.data=(unsigned long)sl;
 	sl->outfill_timer.function=sl_outfill;
 #endif
-	slip_ctrls[i] 	      = slp;
-	return &slp->ctrl;
+	slip_devs[i] = dev;
+				   
+	return sl;
 }
 
 /*
@@ -865,12 +886,10 @@
 		if ((err = sl_alloc_bufs(sl, SL_MTU)) != 0)
 			goto err_free_chan;
 
-		if (register_netdevice(sl->dev)) {
-			sl_free_bufs(sl);
-			goto err_free_chan;
-		}
-
 		set_bit(SLF_INUSE, &sl->flags);
+
+		if ((err = register_netdevice(sl->dev)))
+			goto err_free_bufs;
 	}
 
 #ifdef CONFIG_SLIP_SMART
@@ -888,6 +907,9 @@
 	rtnl_unlock();
 	return sl->dev->base_addr;
 
+err_free_bufs:
+	sl_free_bufs(sl);
+
 err_free_chan:
 	sl->tty = NULL;
 	tty->disc_data = NULL;
@@ -1335,14 +1357,14 @@
 	printk(KERN_INFO "SLIP linefill/keepalive option.\n");
 #endif
 
-	slip_ctrls = kmalloc(sizeof(void*)*slip_maxdev, GFP_KERNEL);
-	if (!slip_ctrls) {
-		printk(KERN_ERR "SLIP: Can't allocate slip_ctrls[] array!  Uaargh! (-> No SLIP available)\n");
+	slip_devs = kmalloc(sizeof(struct net_device *)*slip_maxdev, GFP_KERNEL);
+	if (!slip_devs) {
+		printk(KERN_ERR "SLIP: Can't allocate slip devices array!  Uaargh! (-> No SLIP available)\n");
 		return -ENOMEM;
 	}
 
 	/* Clear the pointer array, we allocate devices when we need them */
-	memset(slip_ctrls, 0, sizeof(void*)*slip_maxdev); /* Pointers */
+	memset(slip_devs, 0, sizeof(struct net_device *)*slip_maxdev); 
 
 	/* Fill in our line protocol discipline, and register it */
 	if ((status = tty_register_ldisc(N_SLIP, &sl_ldisc)) != 0)  {
@@ -1354,51 +1376,59 @@
 static void __exit slip_exit(void)
 {
 	int i;
+	struct net_device *dev;
+	struct slip *sl;
+	unsigned long timeout = jiffies + HZ;
+	int busy = 0;
 
-	if (slip_ctrls != NULL) {
-		unsigned long timeout = jiffies + HZ;
-		int busy = 0;
+	if (slip_devs == NULL) 
+		return;
 
-		/* First of all: check for active disciplines and hangup them.
-		 */
-		do {
-			if (busy)
-				yield();
-
-			busy = 0;
-			local_bh_disable();
-			for (i = 0; i < slip_maxdev; i++) {
-				struct slip_ctrl *slc = slip_ctrls[i];
-				if (!slc)
-					continue;
-				spin_lock(&slc->ctrl.lock);
-				if (slc->ctrl.tty) {
-					busy++;
-					tty_hangup(slc->ctrl.tty);
-				}
-				spin_unlock(&slc->ctrl.lock);
-			}
-			local_bh_enable();
-		} while (busy && time_before(jiffies, timeout));
+	/* First of all: check for active disciplines and hangup them.
+	 */
+	do {
+		if (busy) {
+			current->state = TASK_INTERRUPTIBLE;
+			schedule_timeout(HZ / 10);
+			current->state = TASK_RUNNING;
+		}
 
+		busy = 0;
 		for (i = 0; i < slip_maxdev; i++) {
-			struct slip_ctrl *slc = slip_ctrls[i];
-			if (slc) {
-				unregister_netdev(&slc->dev);
-				if (slc->ctrl.tty) {
-					printk(KERN_ERR "%s: tty discipline is still running\n", slc->dev.name);
-					/* Intentionally leak the control block. */
-				} else {
-					sl_free_bufs(&slc->ctrl);
-					kfree(slc);
-				}
-				slip_ctrls[i] = NULL;
+			dev = slip_devs[i];
+			if (!dev)
+				continue;
+			sl = dev->priv;
+			spin_lock_bh(&sl->lock);
+			if (sl->tty) {
+				busy++;
+				tty_hangup(sl->tty);
 			}
+			spin_unlock_bh(&sl->lock);
 		}
+	} while (busy && time_before(jiffies, timeout));
+
+
+	for (i = 0; i < slip_maxdev; i++) {
+		dev = slip_devs[i];
+		if (!dev)
+			continue;
+		slip_devs[i] = NULL;
+
+		sl = dev->priv;
+		if (sl->tty) {
+			printk(KERN_ERR "%s: tty discipline still running\n",
+			       dev->name);
+			/* Intentionally leak the control block. */
+			dev->destructor = NULL;
+		} 
 
-		kfree(slip_ctrls);
-		slip_ctrls = NULL;
+		unregister_netdev(dev);
 	}
+
+	kfree(slip_devs);
+	slip_devs = NULL;
+
 	if ((i = tty_register_ldisc(N_SLIP, NULL)))
 	{
 		printk(KERN_ERR "SLIP: can't unregister line discipline (err = %d)\n", i);
