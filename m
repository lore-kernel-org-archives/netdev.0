From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] remove superfluous diverter printk'ing
Date: Fri, 14 Jan 2005 13:47:00 +0100
Message-ID: <20050114124700.GA4079@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: benwa@club-internet.fr
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Benoit,

You're not listed as diverter maintainer but I'm sending this via
you anyway.  This patch removes some printk'ing from the diverter
driver (and cleans up the code a bit), because after a while it gets
really annoying to have log messages like this one for every single
tunnel you create or tear down.

	divert: not allocating divert_blk for non-ethernet device tunl0

Please consider sending upstream.


cheers,
Lennert


--- linux-2.6.10/net/core/dv.c.orig	2005-01-14 13:36:44.507808269 +0100
+++ linux-2.6.10/net/core/dv.c	2005-01-14 13:38:18.808399830 +0100
@@ -52,26 +52,20 @@
 {
 	int alloc_size = (sizeof(struct divert_blk) + 3) & ~3;
 
+	dev->divert = NULL;
 	if (dev->type == ARPHRD_ETHER) {
-		printk(KERN_DEBUG "divert: allocating divert_blk for %s\n",
-		       dev->name);
-
 		dev->divert = (struct divert_blk *)
 			kmalloc(alloc_size, GFP_KERNEL);
 		if (dev->divert == NULL) {
-			printk(KERN_DEBUG "divert: unable to allocate divert_blk for %s\n",
+			printk(KERN_INFO "divert: unable to allocate divert_blk for %s\n",
 			       dev->name);
 			return -ENOMEM;
-		} else {
-			memset(dev->divert, 0, sizeof(struct divert_blk));
 		}
-		dev_hold(dev);
-	} else {
-		printk(KERN_DEBUG "divert: not allocating divert_blk for non-ethernet device %s\n",
-		       dev->name);
 
-		dev->divert = NULL;
+		memset(dev->divert, 0, sizeof(struct divert_blk));
+		dev_hold(dev);
 	}
+
 	return 0;
 } 
 
@@ -85,11 +79,6 @@
 		kfree(dev->divert);
 		dev->divert=NULL;
 		dev_put(dev);
-		printk(KERN_DEBUG "divert: freeing divert_blk for %s\n",
-		       dev->name);
-	} else {
-		printk(KERN_DEBUG "divert: no divert_blk to free, %s not ethernet\n",
-		       dev->name);
 	}
 }
 
@@ -192,8 +181,12 @@
 /*
  * control function of the diverter
  */
+#if 0
 #define	DVDBG(a)	\
 	printk(KERN_DEBUG "divert_ioctl() line %d %s\n", __LINE__, (a))
+#else
+#define	DVDBG(a)
+#endif
 
 int divert_ioctl(unsigned int cmd, struct divert_cf __user *arg)
 {
