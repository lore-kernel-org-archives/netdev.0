From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] enabling netdev boot options (2.6.0-t9)
Date: Sat, 8 Nov 2003 16:04:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108160441.3a0a5505.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: saw@saw.sw.com.sg, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


description:      enable eepro100 and 3c59x drivers to recognize
		  'netdev=' boot options:
		  use dev_alloc_name() to assign an interface name,
		  then use netdev_boot_setup_check() to check for boot
		  options for that interface (name);

maintainer:       Andrey V. Savochkin (saw@saw.sw.com.sg);
		  Andrew Morton (akpm@osdl.org) et al

product_versions: Linux 2.6.0-test9

diffstat:=
 drivers/net/3c59x.c    |   15 ++++++++++++++-
 drivers/net/eepro100.c |   12 +++++++-----
 2 files changed, 21 insertions(+), 6 deletions(-)

diff -Naurp ./drivers/net/eepro100.c~netdev ./drivers/net/eepro100.c
--- ./drivers/net/eepro100.c~netdev	2003-10-25 11:44:01.000000000 -0700
+++ ./drivers/net/eepro100.c	2003-11-08 15:32:36.000000000 -0800
@@ -681,17 +681,19 @@ static int __devinit speedo_found1(struc
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (dev->mem_start > 0)
+	rtnl_lock();
+
+	if (dev_alloc_name(dev, dev->name) < 0) 
+		goto err_free_unlock;
+
+	if (netdev_boot_setup_check(dev) && dev->mem_start > 0) {
 		option = dev->mem_start;
+	}
 	else if (card_idx >= 0  &&  options[card_idx] >= 0)
 		option = options[card_idx];
 	else
 		option = 0;
 
-	rtnl_lock();
-	if (dev_alloc_name(dev, dev->name) < 0) 
-		goto err_free_unlock;
-
 	/* Read the station address EEPROM before doing the reset.
 	   Nominally his should even be done before accepting the device, but
 	   then we wouldn't have a device name with which to report the error.
diff -Naurp ./drivers/net/3c59x.c~netdev ./drivers/net/3c59x.c
--- ./drivers/net/3c59x.c~netdev	2003-10-25 11:42:42.000000000 -0700
+++ ./drivers/net/3c59x.c	2003-11-08 15:29:50.000000000 -0800
@@ -259,6 +259,7 @@ static int vortex_debug = 1;
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/highmem.h>
@@ -1110,6 +1111,16 @@ static int __devinit vortex_probe1(struc
 	SET_NETDEV_DEV(dev, gendev);
 	vp = dev->priv;
 
+	rtnl_lock();
+
+	retval = dev_alloc_name(dev, dev->name);
+	if (retval < 0)
+		goto err_free_unlock;
+
+	rtnl_unlock();
+
+	netdev_boot_setup_check(dev);
+
 	option = global_options;
 
 	/* The lower four bits are the media type. */
@@ -1468,8 +1479,10 @@ free_ring:
 free_region:
 	if (vp->must_free_region)
 		release_region(ioaddr, vci->io_size);
-	free_netdev(dev);
+err_free_unlock:
 	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
+	rtnl_unlock();
+	free_netdev(dev);
 out:
 	return retval;
 }
