From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] meth driver renovation
Date: Wed, 23 May 2007 09:43:30 +0100
Message-ID: <20070523084330.GA4966@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:43671 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756729AbXEWInq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 04:43:46 -0400
Received: from localhost.localdomain ([127.0.0.1]:26823 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021517AbXEWInp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 09:43:45 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The meth ethernet driver for the SGI IP32 aka O2 is so far still an old
style driver which does not use the device driver model.  This is now
causing issues with some udev based gadgetry in debian-stable.  Fixed by
converting the meth driver to a platform device.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/arch/mips/sgi-ip32/Makefile b/arch/mips/sgi-ip32/Makefile
index 7e14167..60f0227 100644
--- a/arch/mips/sgi-ip32/Makefile
+++ b/arch/mips/sgi-ip32/Makefile
@@ -3,5 +3,5 @@
 # under Linux.
 #
 
-obj-y	+= ip32-berr.o ip32-irq.o ip32-setup.o ip32-reset.o \
+obj-y	+= ip32-berr.o ip32-irq.o ip32-platform.o ip32-setup.o ip32-reset.o \
 	   crime.o ip32-memory.o
diff --git a/arch/mips/sgi-ip32/ip32-platform.c b/arch/mips/sgi-ip32/ip32-platform.c
new file mode 100644
index 0000000..120b159
--- /dev/null
+++ b/arch/mips/sgi-ip32/ip32-platform.c
@@ -0,0 +1,20 @@
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+static __init int meth_devinit(void)
+{
+	struct platform_device *pd;
+	int ret;
+
+	pd = platform_device_alloc("meth", -1);
+	if (!pd)
+		return -ENOMEM;
+
+	ret = platform_device_add(pd);
+	if (ret)
+		platform_device_put(pd);
+
+	return ret;
+}
+
+device_initcall(meth_devinit);
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 0343ea1..f300d3f 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -8,15 +8,16 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  */
-#include <linux/module.h>
-#include <linux/init.h>
-
-#include <linux/kernel.h> /* printk() */
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
 #include <linux/slab.h>
-#include <linux/errno.h>  /* error codes */
-#include <linux/types.h>  /* size_t */
-#include <linux/interrupt.h> /* mark_bh */
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
 
 #include <linux/in.h>
 #include <linux/in6.h>
@@ -33,7 +34,6 @@
 
 #include <asm/io.h>
 #include <asm/scatterlist.h>
-#include <linux/dma-mapping.h>
 
 #include "meth.h"
 
@@ -51,8 +51,6 @@
 
 
 static const char *meth_str="SGI O2 Fast Ethernet";
-MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
-MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
 
 #define HAVE_TX_TIMEOUT
 /* The maximum time waited (in jiffies) before assuming a Tx failed. (400ms) */
@@ -784,15 +782,15 @@ static struct net_device_stats *meth_stats(struct net_device *dev)
 /*
  * The init function.
  */
-static struct net_device *meth_init(void)
+static int __init meth_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct meth_private *priv;
-	int ret;
+	int err;
 
 	dev = alloc_etherdev(sizeof(struct meth_private));
 	if (!dev)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	dev->open            = meth_open;
 	dev->stop            = meth_release;
@@ -808,11 +806,12 @@ static struct net_device *meth_init(void)
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->meth_lock);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	ret = register_netdev(dev);
-	if (ret) {
+	err = register_netdev(dev);
+	if (err) {
 		free_netdev(dev);
-		return ERR_PTR(ret);
+		return err;
 	}
 
 	printk(KERN_INFO "%s: SGI MACE Ethernet rev. %d\n",
@@ -820,21 +819,44 @@ static struct net_device *meth_init(void)
 	return 0;
 }
 
-static struct net_device *meth_dev;
+static int __exit meth_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	free_netdev(dev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver meth_driver = {
+	.probe	= meth_probe,
+	.remove	= __devexit_p(meth_remove),
+	.driver = {
+		.name	= "meth",
+	}
+};
 
 static int __init meth_init_module(void)
 {
-	meth_dev = meth_init();
-	if (IS_ERR(meth_dev))
-		return PTR_ERR(meth_dev);
-	return 0;
+	int err;
+
+	err = platform_driver_register(&meth_driver);
+	if (err)
+		printk(KERN_ERR "Driver registration failed\n");
+
+	return err;
 }
 
 static void __exit meth_exit_module(void)
 {
-	unregister_netdev(meth_dev);
-	free_netdev(meth_dev);
+	platform_driver_register(&meth_driver);
 }
 
 module_init(meth_init_module);
 module_exit(meth_exit_module);
+
+MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
+MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
+MODULE_LICENSE("GPL");
