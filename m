From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.74] convert apne to dynamic allocation
Date: Tue, 8 Jul 2003 15:12:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708151245.179cac2b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert apne driver away from static net_device structure.

Builds, but not tested with real hardware.

diff -Nru a/drivers/net/apne.c b/drivers/net/apne.c
--- a/drivers/net/apne.c	Mon Jul  7 14:46:31 2003
+++ b/drivers/net/apne.c	Mon Jul  7 14:46:31 2003
@@ -534,16 +534,21 @@
 }
 
 #ifdef MODULE
-static struct net_device apne_dev;
+static struct net_device *apne_dev;
 
 int init_module(void)
 {
 	int err;
 
+	apne_dev = kmalloc(sizeof(*apne_dev));
+	if (!apne_dev)
+		return -ENOMEM;
+
 	apne_dev.init = apne_probe;
 	if ((err = register_netdev(&apne_dev))) {
 		if (err == -EIO)
 			printk("No PCMCIA NEx000 ethernet card found.\n");
+		kfree(apne_dev);
 		return (err);
 	}
 	return (0);
@@ -551,11 +556,13 @@
 
 void cleanup_module(void)
 {
-	unregister_netdev(&apne_dev);
+	unregister_netdev(apne_dev);
 
 	pcmcia_disable_irq();
 
-	free_irq(IRQ_AMIGA_PORTS, &apne_dev);
+	free_irq(IRQ_AMIGA_PORTS, apne_dev);
+
+	kfree(apne_dev);
 
 	pcmcia_reset();
 
