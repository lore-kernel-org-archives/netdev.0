From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] depca - error patch memory leaks
Date: Tue, 11 Nov 2003 14:45:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111144521.58a1f495.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix leaks on error unwinds. Found by viro.

diff -Nru a/drivers/net/depca.c b/drivers/net/depca.c
--- a/drivers/net/depca.c	Tue Nov 11 09:36:20 2003
+++ b/drivers/net/depca.c	Tue Nov 11 09:36:20 2003
@@ -681,8 +681,7 @@
 	lp->sh_mem = ioremap(mem_start, mem_len);
 	if (lp->sh_mem == NULL) {
 		printk(KERN_ERR "depca: cannot remap ISA memory, aborting\n");
-		release_mem_region (mem_start, mem_len);
-		goto out_priv;
+		goto out1;
 	}
 
 	lp->mem_start = mem_start;
@@ -771,7 +770,7 @@
 		status = -ENXIO;
 		if (!irqnum) {
 			printk(" and failed to detect IRQ line.\n");
-			goto out_priv;
+			goto out2;
 		} else {
 			for (dev->irq = 0, i = 0; (depca_irq[i]) && (!dev->irq); i++)
 				if (irqnum == depca_irq[i]) {
@@ -781,7 +780,7 @@
 
 			if (!dev->irq) {
 				printk(" but incorrect IRQ line detected.\n");
-				return -ENXIO;
+				goto out2;
 			}
 		}
 	} else {
@@ -807,11 +806,14 @@
 	device->driver_data = dev;
 	SET_NETDEV_DEV (dev, device);
 	
-	register_netdev (dev);
-	return 0;
-
- out_priv:
-	
+	status = register_netdev(dev);
+	if (status == 0)
+		return 0;
+out2:
+	iounmap(lp->sh_mem);
+out1:
+	release_mem_region (mem_start, mem_len);
+out_priv:
 	return status;
 }
 
