From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: Wed, 11 Jun 2003 14:42:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611144249.7cd63c1c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jes Sorenson <jes@trained-monkey.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Updated acenic driver to use alloc_etherdev to hold private data structure.
Uses register_netdev() to get the name right this time ;-)

Tested against 2.5.70 bk latest on Tigon III board.

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	Wed Jun 11 14:36:47 2003
+++ b/drivers/net/acenic.c	Wed Jun 11 14:36:47 2003
@@ -642,8 +642,7 @@
 		      (pdev->device == PCI_DEVICE_ID_SGI_ACENIC)))
 			continue;
 
-		dev = init_etherdev(NULL, sizeof(struct ace_private));
-
+		dev = alloc_etherdev(sizeof(struct ace_private));
 		if (dev == NULL) {
 			printk(KERN_ERR "acenic: Unable to allocate "
 			       "net_device structure!\n");
@@ -653,13 +652,6 @@
 		SET_MODULE_OWNER(dev);
 		SET_NETDEV_DEV(dev, &pdev->dev);
 
-		if (!dev->priv)
-			dev->priv = kmalloc(sizeof(*ap), GFP_KERNEL);
-		if (!dev->priv) {
-			printk(KERN_ERR "acenic: Unable to allocate memory\n");
-			return -ENOMEM;
-		}
-
 		ap = dev->priv;
 		ap->pdev = pdev;
 
@@ -737,6 +729,12 @@
 			       "AceNIC %i will be disabled.\n",
 			       dev->name, boards_found);
 			break;
+		}
+
+		if (register_netdev(dev)) {
+			printk(KERN_ERR "acenic: device registration failed\n");
+			kfree(dev);
+			continue;
 		}
 
 		switch(pdev->vendor) {
