From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert plip to alloc_netdev
Date: Tue, 8 Jul 2003 15:17:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708151742.715ca49c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This converts the parallel network driver to use alloc_netdev instead
of doing it's own allocation.

Tested (load/unload) on 2.5.74
diff -Nru a/drivers/net/plip.c b/drivers/net/plip.c
--- a/drivers/net/plip.c	Tue Jul  8 15:07:44 2003
+++ b/drivers/net/plip.c	Tue Jul  8 15:07:44 2003
@@ -277,27 +277,10 @@
    then calls us here.
 
    */
-int __init
-plip_init_dev(struct net_device *dev, struct parport *pb)
+static int
+plip_init_netdev(struct net_device *dev)
 {
-	struct net_local *nl;
-	struct pardevice *pardev;
-
-	SET_MODULE_OWNER(dev);
-	dev->irq = pb->irq;
-	dev->base_addr = pb->base;
-
-	if (pb->irq == -1) {
-		printk(KERN_INFO "plip: %s has no IRQ. Using IRQ-less mode,"
-		                 "which is fairly inefficient!\n", pb->name);
-	}
-
-	pardev = parport_register_device(pb, dev->name, plip_preempt,
-					 plip_wakeup, plip_interrupt, 
-					 0, dev);
-
-	if (!pardev)
-		return -ENODEV;
+	struct net_local *nl = dev->priv;
 
 	printk(KERN_INFO "%s", version);
 	if (dev->irq != -1)
@@ -307,9 +290,6 @@
 		printk(KERN_INFO "%s: Parallel port at %#3lx, not using IRQ.\n",
 		       dev->name, dev->base_addr);
 
-	/* Fill in the generic fields of the device structure. */
-	ether_setup(dev);
-
 	/* Then, override parts of it */
 	dev->hard_start_xmit	 = plip_tx_packet;
 	dev->open		 = plip_open;
@@ -322,22 +302,12 @@
 	memset(dev->dev_addr, 0xfc, ETH_ALEN);
 
 	/* Set the private structure */
-	dev->priv = kmalloc(sizeof (struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", dev->name);
-		parport_unregister_device(pardev);
-		return -ENOMEM;
-	}
-	memset(dev->priv, 0, sizeof(struct net_local));
-	nl = (struct net_local *) dev->priv;
-
 	nl->orig_hard_header    = dev->hard_header;
 	dev->hard_header        = plip_hard_header;
 
 	nl->orig_hard_header_cache = dev->hard_header_cache;
 	dev->hard_header_cache     = plip_hard_header_cache;
 
-	nl->pardev = pardev; 
 
 	nl->port_owner = 0;
 
@@ -1299,29 +1269,52 @@
  * available to use. */
 static void plip_attach (struct parport *port)
 {
-	static int i;
+	static int unit;
+	struct net_device *dev;
+	struct net_local *nl;
+	char name[IFNAMSIZ];
 
 	if ((parport[0] == -1 && (!timid || !port->devices)) || 
 	    plip_searchfor(parport, port->number)) {
-		if (i == PLIP_MAX) {
+		if (unit == PLIP_MAX) {
 			printk(KERN_ERR "plip: too many devices\n");
 			return;
 		}
-		dev_plip[i] = kmalloc(sizeof(struct net_device),
-				      GFP_KERNEL);
-		if (!dev_plip[i]) {
+
+		sprintf(name, "plip%d", unit);
+		dev = alloc_netdev(sizeof(struct net_local), name, 
+				   ether_setup);
+		if (!dev) {
 			printk(KERN_ERR "plip: memory squeeze\n");
 			return;
 		}
-		memset(dev_plip[i], 0, sizeof(struct net_device));
-		sprintf(dev_plip[i]->name, "plip%d", i);
-		dev_plip[i]->priv = port;
-		if (plip_init_dev(dev_plip[i],port) ||
-		    register_netdev(dev_plip[i])) {
-			kfree(dev_plip[i]);
-			dev_plip[i] = NULL;
+		
+		dev->init = plip_init_netdev;
+
+		SET_MODULE_OWNER(dev);
+		dev->irq = port->irq;
+		dev->base_addr = port->base;
+		if (port->irq == -1) {
+			printk(KERN_INFO "plip: %s has no IRQ. Using IRQ-less mode,"
+		                 "which is fairly inefficient!\n", port->name);
+		}
+
+		nl = dev->priv;
+		nl->pardev = parport_register_device(port, name, plip_preempt,
+						 plip_wakeup, plip_interrupt, 
+						 0, dev);
+
+		if (!nl->pardev) {
+			printk(KERN_ERR "%s: parport_register failed\n", name);
+			kfree(dev);
+			return;
+		}
+
+		if (register_netdev(dev)) {
+			printk(KERN_ERR "%s: network register failed\n", name);
+			kfree(dev);
 		} else {
-			i++;
+			dev_plip[unit++] = dev;
 		}
 	}
 }
@@ -1341,20 +1334,19 @@
 
 static void __exit plip_cleanup_module (void)
 {
+	struct net_device *dev;
 	int i;
 
 	parport_unregister_driver (&plip_driver);
 
 	for (i=0; i < PLIP_MAX; i++) {
-		if (dev_plip[i]) {
-			struct net_local *nl =
-				(struct net_local *)dev_plip[i]->priv;
-			unregister_netdev(dev_plip[i]);
+		if ((dev = dev_plip[i])) {
+			struct net_local *nl = dev->priv;
+			unregister_netdev(dev);
 			if (nl->port_owner)
 				parport_release(nl->pardev);
 			parport_unregister_device(nl->pardev);
-			kfree(dev_plip[i]->priv);
-			kfree(dev_plip[i]);
+			kfree(dev);
 			dev_plip[i] = NULL;
 		}
 	}
