From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] sb1000 driver bugs
Date: Wed, 4 Jun 2003 11:25:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604112509.1e0cc260.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Inspecting the sb1000 driver showed some interesting bugs:
	- net device pointer is used before the device is allocated; gcc
	  does catch this.
	- unregister is called even though device not registered successfully
	- net device is not freed on remove.

Compiles but don't have hardware to test.  Don't know how it ever worked though.

diff -Nru a/drivers/net/sb1000.c b/drivers/net/sb1000.c
--- a/drivers/net/sb1000.c	Wed Jun  4 11:17:47 2003
+++ b/drivers/net/sb1000.c	Wed Jun  4 11:17:47 2003
@@ -162,10 +162,17 @@
 		
 	irq = pnp_irq(pdev, 0);
 
-	if (!request_region(ioaddr[0], 16, dev->name))
+	if (!request_region(ioaddr[0], 16, "sb1000"))
 		goto out_disable;
-	if (!request_region(ioaddr[1], 16, dev->name))
+	if (!request_region(ioaddr[1], 16, "sb1000"))
 		goto out_release_region0;
+
+	dev = alloc_etherdev(sizeof(struct sb1000_private));
+	if (!dev) {
+		error = -ENOMEM;
+		goto out_release_regions;
+	}
+
 		 
 	dev->base_addr = ioaddr[0];
 	/* mem_start holds the second I/O address */
@@ -177,12 +184,6 @@
 			"S/N %#8.8x, IRQ %d.\n", dev->name, dev->base_addr,
 			dev->mem_start, serial_number, dev->irq);
 
-	dev = alloc_etherdev(sizeof(struct sb1000_private));
-	if (!dev) {
-		error = -ENOMEM;
-		goto out_release_regions;
-	}
-
 	/*
 	 * The SB1000 is an rx-only cable modem device.  The uplink is a modem
 	 * and we do not want to arp on it.
@@ -212,11 +213,9 @@
 
 	error = register_netdev(dev);
 	if (error)
-		goto out_unregister;
+		goto out_release_regions;
 	return 0;
 
- out_unregister:
-	unregister_netdev(dev);
  out_release_regions:
 	release_region(ioaddr[1], 16);
  out_release_region0:
@@ -236,6 +235,7 @@
 	unregister_netdev(dev);
 	release_region(dev->base_addr, 16);
 	release_region(dev->mem_start, 16);
+	kfree(dev);
 }
 
 static struct pnp_driver sb1000_driver = {
