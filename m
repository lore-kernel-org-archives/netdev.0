From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] move slip over to initcalls
Date: Wed, 7 May 2003 23:55:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507235547.A15805@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Time to get rid of a few entries in setup.c :)


--- 1.6/drivers/net/setup.c	Mon Feb 17 18:39:52 2003
+++ edited/drivers/net/setup.c	Wed May  7 22:15:22 2003
@@ -9,7 +9,6 @@
 #include <linux/init.h>
 #include <linux/netlink.h>
 
-extern int slip_init_ctrl_dev(void);
 extern int x25_asy_init_ctrl_dev(void);
   
 extern int dmascc_init(void);
@@ -109,9 +108,6 @@
  
 static void __init network_ldisc_init(void)
 {
-#if defined(CONFIG_SLIP)
-	slip_init_ctrl_dev();
-#endif
 #if defined(CONFIG_X25_ASY)
 	x25_asy_init_ctrl_dev();
 #endif
--- 1.13/drivers/net/slip.c	Mon Apr 21 23:58:43 2003
+++ edited/drivers/net/slip.c	Wed May  7 22:06:59 2003
@@ -81,11 +81,7 @@
 #include <net/slhc_vj.h>
 #endif
 
-#ifdef MODULE
-#define SLIP_VERSION    "0.8.4-NET3.019-NEWTTY-MODULAR"
-#else
-#define	SLIP_VERSION	"0.8.4-NET3.019-NEWTTY"
+#define SLIP_VERSION	"0.8.4-NET3.019-NEWTTY"
-#endif
 
 
 typedef struct slip_ctrl {
@@ -98,8 +94,6 @@
 MODULE_PARM(slip_maxdev, "i");
 MODULE_PARM_DESC(slip_maxdev, "Maximum number of slip devices");
 
-static struct tty_ldisc	sl_ldisc;
-
 static int slip_esc(unsigned char *p, unsigned char *d, int len);
 static void slip_unesc(struct slip *sl, unsigned char c);
 #ifdef CONFIG_SLIP_MODE_SLIP6
@@ -1309,13 +1303,24 @@
 #endif
 /* VSV changes end */
 
-/* Initialize SLIP control device -- register SLIP line discipline */
+static struct tty_ldisc	sl_ldisc = {
+	.owner 		= THIS_MODULE,
+	.magic 		= TTY_LDISC_MAGIC,
+	.name 		= "slip",
+	.open 		= slip_open,
+	.close	 	= slip_close,
+	.ioctl		= slip_ioctl,
+	.receive_buf	= slip_receive_buf,
+	.receive_room	= slip_receive_room,
+	.write_wakeup	= slip_write_wakeup,
+};
 
-int __init slip_init_ctrl_dev(void)
+static int __init slip_init(void)
 {
 	int status;
 
-	if (slip_maxdev < 4) slip_maxdev = 4; /* Sanity */
+	if (slip_maxdev < 4)
+		slip_maxdev = 4; /* Sanity */
 
 	printk(KERN_INFO "SLIP: version %s (dynamic channels, max=%d)"
 #ifdef CONFIG_SLIP_MODE_SLIP6
@@ -1323,16 +1328,15 @@
 #endif
 	       ".\n",
 	       SLIP_VERSION, slip_maxdev );
-#if defined(SL_INCLUDE_CSLIP) && !defined(MODULE)
+#if defined(SL_INCLUDE_CSLIP)
 	printk(KERN_INFO "CSLIP: code copyright 1989 Regents of the University of California.\n");
 #endif
 #ifdef CONFIG_SLIP_SMART
 	printk(KERN_INFO "SLIP linefill/keepalive option.\n");
 #endif
 
-	slip_ctrls = (slip_ctrl_t **) kmalloc(sizeof(void*)*slip_maxdev, GFP_KERNEL);
-	if (slip_ctrls == NULL)
-	{
+	slip_ctrls = kmalloc(sizeof(void*)*slip_maxdev, GFP_KERNEL);
+	if (!slip_ctrls) {
 		printk(KERN_ERR "SLIP: Can't allocate slip_ctrls[] array!  Uaargh! (-> No SLIP available)\n");
 		return -ENOMEM;
 	}
@@ -1347,28 +1351,7 @@
 	return status;
 }
 
-static struct tty_ldisc	sl_ldisc =
-{
-	.owner 		=	THIS_MODULE,
-	.magic 		= 	TTY_LDISC_MAGIC,
-	.name 		= 	"slip",
-	.open 		= 	slip_open,
-	.close	 	= 	slip_close,
-	.ioctl		=	slip_ioctl,
-	.receive_buf	=	slip_receive_buf,
-	.receive_room	=	slip_receive_room,
-	.write_wakeup	=	slip_write_wakeup,
-};
-
-#ifdef MODULE
-
-int init_module(void)
-{
-	return slip_init_ctrl_dev();
-}
-
-void
-cleanup_module(void)
+static void __exit slip_exit(void)
 {
 	int i;
 
@@ -1425,7 +1408,9 @@
 		printk(KERN_ERR "SLIP: can't unregister line discipline (err = %d)\n", i);
 	}
 }
-#endif /* MODULE */
+
+module_init(slip_init);
+module_exit(slip_exit);
 
 #ifdef CONFIG_SLIP_SMART
 /*
--- 1.2/drivers/net/slip.h	Mon Apr 21 23:58:43 2003
+++ edited/drivers/net/slip.h	Wed May  7 21:51:30 2003
@@ -116,10 +116,6 @@
 #endif  
 };
 
-
-
 #define SLIP_MAGIC 0x5302
-
-extern int slip_init(struct net_device *dev);
 
 #endif	/* _LINUX_SLIP.H */
