From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH]
Date: Tue, 8 Jul 2003 15:16:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708151606.483604ad.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Digi RigtSwitch to use alloc_etherdev.

Builds (on 2.5.74) but once again, do not have real hardware to test.

diff -Nru a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c	Mon Jul  7 14:50:36 2003
+++ b/drivers/net/dgrs.c	Mon Jul  7 14:50:36 2003
@@ -1252,18 +1252,12 @@
 {
 	DGRS_PRIV	*priv;
 	struct net_device *dev, *aux;
-
-	/* Allocate and fill new device structure. */
-	int dev_size = sizeof(struct net_device) + sizeof(DGRS_PRIV);
 	int i, ret;
 
-	dev = (struct net_device *) kmalloc(dev_size, GFP_KERNEL);
-
+	dev = alloc_etherdev(sizeof(DGRS_PRIV));
 	if (!dev)
 		return -ENOMEM;
 
-	memset(dev, 0, dev_size);
-	dev->priv = ((void *)dev) + sizeof(struct net_device);
 	priv = (DGRS_PRIV *)dev->priv;
 
 	dev->base_addr = io;
@@ -1279,7 +1273,7 @@
 
 	dev->init = dgrs_probe1;
 	SET_MODULE_OWNER(dev);
-	ether_setup(dev);
+
 	if (register_netdev(dev) != 0) {
 		kfree(dev);
 		return -EIO;
@@ -1302,15 +1296,18 @@
 		struct net_device	*devN;
 		DGRS_PRIV	*privN;
 			/* Allocate new dev and priv structures */
-		devN = (struct net_device *) kmalloc(dev_size, GFP_KERNEL);
-			/* Make it an exact copy of dev[0]... */
+		devN = alloc_etherdev(sizeof(DGRS_PRIV));
 		ret = -ENOMEM;
 		if (!devN) 
 			goto fail;
-		memcpy(devN, dev, dev_size);
-		memset(devN->name, 0, sizeof(devN->name));
-		devN->priv = ((void *)devN) + sizeof(struct net_device);
+
+		/* Make it an exact copy of dev[0]... */
+		*devN = *dev;
+
+		/* copy the priv structure of dev[0] */
 		privN = (DGRS_PRIV *)devN->priv;
+		*privN = *priv;
+
 			/* ... and zero out VM areas */
 		privN->vmem = 0;
 		privN->vplxdma = 0;
@@ -1318,9 +1315,11 @@
 		devN->irq = 0;
 			/* ... and base MAC address off address of 1st port */
 		devN->dev_addr[5] += i;
+			/* ... choose a new name */
+		strncpy(devN->name, "eth%d", IFNAMSIZ);
 		devN->init = dgrs_initclone;
 		SET_MODULE_OWNER(devN);
-		ether_setup(devN);
+
 		ret = -EIO;
 		if (register_netdev(devN)) {
 			kfree(devN);
