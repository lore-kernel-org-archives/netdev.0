From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch x25_asy over to initcalls
Date: Fri, 9 May 2003 09:12:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509091219.A1499@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I also had to fix the ldisc initialization because it was so ugly
and the different ioctl + cast mess because I couldn't look at it.


--- 1.7/drivers/net/setup.c	Thu May  8 12:47:20 2003
+++ edited/drivers/net/setup.c	Fri May  9 07:31:44 2003
@@ -9,8 +9,6 @@
 #include <linux/init.h>
 #include <linux/netlink.h>
 
-extern int x25_asy_init_ctrl_dev(void);
-  
 extern int dmascc_init(void);
 
 extern int arcnet_init(void); 
@@ -101,19 +99,6 @@
 	}
 }
 
-
-/*
- *	Initialise the line discipline drivers
- */
- 
-static void __init network_ldisc_init(void)
-{
-#if defined(CONFIG_X25_ASY)
-	x25_asy_init_ctrl_dev();
-#endif
-}
-
-
 static void __init special_device_init(void)
 {
 #ifdef CONFIG_NET_SB1000
@@ -133,11 +118,8 @@
  
 void __init net_device_init(void)
 {
-	/* Devices supporting the new probing API */
+	/* Devices supporting the new^H^H^Hold probing API */
 	network_probe();
-	/* Line disciplines */
-	network_ldisc_init();
 	/* Special devices */
 	special_device_init();
-	/* That kicks off the legacy init functions */
 }
--- 1.5/drivers/net/wan/x25_asy.c	Mon Apr 21 23:58:40 2003
+++ edited/drivers/net/wan/x25_asy.c	Fri May  9 07:45:43 2003
@@ -46,8 +46,6 @@
 MODULE_PARM(x25_asy_maxdev, "i");
 MODULE_LICENSE("GPL");
 
-static struct tty_ldisc	x25_ldisc;
-
 static int x25_asy_esc(unsigned char *p, unsigned char *d, int len);
 static void x25_asy_unesc(struct x25_asy *sl, unsigned char c);
 
@@ -634,8 +632,6 @@
 	if ((err = x25_asy_open(sl->dev)))
 		return err;
 
-	MOD_INC_USE_COUNT;
-
 	/* Done.  We have linked the TTY line to a channel. */
 	return sl->dev->base_addr;
 }
@@ -664,7 +660,6 @@
 	sl->tty = NULL;
 	x25_asy_free(sl);
 	unregister_netdev(sl->dev);
-	MOD_DEC_USE_COUNT;
 }
 
 
@@ -769,32 +764,29 @@
 
 
 /* Perform I/O control on an active X.25 channel. */
-static int x25_asy_ioctl(struct tty_struct *tty, void *file, int cmd, void *arg)
+static int x25_asy_ioctl(struct tty_struct *tty, struct file *file,
+			 unsigned int cmd,  unsigned long arg)
 {
 	struct x25_asy *sl = (struct x25_asy *) tty->disc_data;
 
 	/* First make sure we're connected. */
-	if (!sl || sl->magic != X25_ASY_MAGIC) {
+	if (!sl || sl->magic != X25_ASY_MAGIC)
 		return -EINVAL;
-	}
 
-	switch(cmd) 
-	{
-		case SIOCGIFNAME:
-			if(copy_to_user(arg, sl->dev->name, strlen(sl->dev->name) + 1))
-				return -EFAULT;
-			return 0;
-
-		case SIOCSIFHWADDR:
-			return -EINVAL;
-
-		/* Allow stty to read, but not set, the serial port */
-		case TCGETS:
-		case TCGETA:
-			return n_tty_ioctl(tty, (struct file *) file, cmd, (unsigned long) arg);
-
-		default:
-			return -ENOIOCTLCMD;
+	switch(cmd) {
+	case SIOCGIFNAME:
+		if (copy_to_user((void *)arg, sl->dev->name,
+					strlen(sl->dev->name) + 1))
+			return -EFAULT;
+		return 0;
+	case SIOCSIFHWADDR:
+		return -EINVAL;
+	/* Allow stty to read, but not set, the serial port */
+	case TCGETS:
+	case TCGETA:
+		return n_tty_ioctl(tty, file, cmd, arg);
+	default:
+		return -ENOIOCTLCMD;
 	}
 }
 
@@ -806,51 +798,7 @@
 	return 0;
 }
 
-/* Initialize X.25 control device -- register X.25 line discipline */
-
-int __init x25_asy_init_ctrl_dev(void)
-{
-	int status;
-
-	if (x25_asy_maxdev < 4) x25_asy_maxdev = 4; /* Sanity */
-
-	printk(KERN_INFO "X.25 async: version 0.00 ALPHA (dynamic channels, max=%d).\n",
-		x25_asy_maxdev );
-	x25_asy_ctrls = (x25_asy_ctrl_t **) kmalloc(sizeof(void*)*x25_asy_maxdev, GFP_KERNEL);
-	if (x25_asy_ctrls == NULL)
-	{
-		printk("X25 async: Can't allocate x25_asy_ctrls[] array!  Uaargh! (-> No X.25 available)\n");
-		return -ENOMEM;
-	}
-
-	/* Clear the pointer array, we allocate devices when we need them */
-	memset(x25_asy_ctrls, 0, sizeof(void*)*x25_asy_maxdev); /* Pointers */
-
-	/* Fill in our line protocol discipline, and register it */
-	memset(&x25_ldisc, 0, sizeof(x25_ldisc));
-	x25_ldisc.magic  = TTY_LDISC_MAGIC;
-	x25_ldisc.name   = "X.25";
-	x25_ldisc.flags  = 0;
-	x25_ldisc.open   = x25_asy_open_tty;
-	x25_ldisc.close  = x25_asy_close_tty;
-	x25_ldisc.read   = NULL;
-	x25_ldisc.write  = NULL;
-	x25_ldisc.ioctl  = (int (*)(struct tty_struct *, struct file *,
-				   unsigned int, unsigned long)) x25_asy_ioctl;
-	x25_ldisc.poll   = NULL;
-	x25_ldisc.receive_buf = x25_asy_receive_buf;
-	x25_ldisc.receive_room = x25_asy_receive_room;
-	x25_ldisc.write_wakeup = x25_asy_write_wakeup;
-	if ((status = tty_register_ldisc(N_X25, &x25_ldisc)) != 0)  {
-		printk("X.25 async: can't register line discipline (err = %d)\n", status);
-	}
-
-	return status;
-}
-
-
 /* Initialise the X.25 driver.  Called by the device init code */
-
 int x25_asy_init(struct net_device *dev)
 {
 	struct x25_asy *sl = (struct x25_asy*)(dev->priv);
@@ -885,43 +833,58 @@
 
 	return 0;
 }
-#ifdef MODULE
 
-int
-init_module(void)
-{
-	return x25_asy_init_ctrl_dev();
+static struct tty_ldisc x25_ldisc = {
+	.owner		= THIS_MODULE,
+	.magic		= TTY_LDISC_MAGIC,
+	.name		= "X.25",
+	.open		= x25_asy_open_tty,
+	.close		= x25_asy_close_tty,
+	.ioctl		= x25_asy_ioctl,
+	.receive_buf	= x25_asy_receive_buf,
+	.receive_room	= x25_asy_receive_room,
+	.write_wakeup	= x25_asy_write_wakeup,
+};
+
+static int __init init_x25_asy(void)
+{
+	if (x25_asy_maxdev < 4)
+		x25_asy_maxdev = 4; /* Sanity */
+
+	printk(KERN_INFO "X.25 async: version 0.00 ALPHA "
+			"(dynamic channels, max=%d).\n", x25_asy_maxdev );
+	x25_asy_ctrls = kmalloc(sizeof(void*)*x25_asy_maxdev, GFP_KERNEL);
+	if (!x25_asy_ctrls) {
+		printk(KERN_WARNING "X25 async: Can't allocate x25_asy_ctrls[] "
+				"array! Uaargh! (-> No X.25 available)\n");
+		return -ENOMEM;
+	}
+	memset(x25_asy_ctrls, 0, sizeof(void*)*x25_asy_maxdev); /* Pointers */
+
+	return tty_register_ldisc(N_X25, &x25_ldisc);
 }
 
-void
-cleanup_module(void)
+
+static void __exit exit_x25_asy(void)
 {
 	int i;
 
-	if (x25_asy_ctrls != NULL)
-	{
-		for (i = 0; i < x25_asy_maxdev; i++)
-		{
-			if (x25_asy_ctrls[i])
-			{
-				/*
-				 * VSV = if dev->start==0, then device
-				 * unregistered while close proc.
-				 */
-				if (netif_running(&(x25_asy_ctrls[i]->dev)))
-					unregister_netdev(&(x25_asy_ctrls[i]->dev));
+	for (i = 0; i < x25_asy_maxdev; i++) {
+		if (x25_asy_ctrls[i]) {
+			/*
+			 * VSV = if dev->start==0, then device
+			 * unregistered while close proc.
+			 */
+			if (netif_running(&(x25_asy_ctrls[i]->dev)))
+				unregister_netdev(&(x25_asy_ctrls[i]->dev));
 
-				kfree(x25_asy_ctrls[i]);
-				x25_asy_ctrls[i] = NULL;
-			}
+			kfree(x25_asy_ctrls[i]);
 		}
-		kfree(x25_asy_ctrls);
-		x25_asy_ctrls = NULL;
-	}
-	if ((i = tty_register_ldisc(N_X25, NULL)))
-	{
-		printk("X.25 async: can't unregister line discipline (err = %d)\n", i);
 	}
+
+	kfree(x25_asy_ctrls);
+	tty_register_ldisc(N_X25, NULL);
 }
-#endif /* MODULE */
 
+module_init(init_x25_asy);
+module_exit(exit_x25_asy);
