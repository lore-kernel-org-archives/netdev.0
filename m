From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] Red Creek VPN update
Date: Tue, 17 Jun 2003 16:31:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617163116.1f7b6d78.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some cleanup's to Red Creek VPN driver.  
	- use alloc_etherdev instead of init_etherdev
	- don't decrement module ref count negative in case of error.

Don't have the hardware to actually test the real thing. But the driver builds
and loads fine.


diff -Nru a/drivers/net/rcpci45.c b/drivers/net/rcpci45.c
--- a/drivers/net/rcpci45.c	Tue Jun 17 15:25:17 2003
+++ b/drivers/net/rcpci45.c	Tue Jun 17 15:25:17 2003
@@ -171,13 +171,14 @@
 	 * will be assigned to the LAN API layer.
 	 */
 
-	dev = init_etherdev (NULL, sizeof (*pDpa));
+	dev = alloc_etherdev(sizeof(*pDpa));
 	if (!dev) {
 		printk (KERN_ERR
-			"(rcpci45 driver:) init_etherdev alloc failed\n");
+			"(rcpci45 driver:) alloc_etherdev alloc failed\n");
 		error = -ENOMEM;
 		goto err_out;
 	}
+
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -257,6 +258,9 @@
 	dev->do_ioctl = &RCioctl;
 	dev->set_config = &RCconfig;
 
+	if ((error = register_netdev(dev)))
+		goto err_out_free_region;
+
 	return 0;		/* success */
 
 err_out_free_region:
@@ -265,7 +269,6 @@
 	pci_free_consistent (pdev, MSG_BUF_SIZE, pDpa->msgbuf,
 			     pDpa->msgbuf_dma);
 err_out_free_dev:
-	unregister_netdev (dev);
 	kfree (dev);
 err_out:
 	card_idx--;
@@ -717,11 +720,9 @@
 
 		if (retry > REBOOT_REINIT_RETRY_LIMIT) {
 			printk (KERN_WARNING "%s unable to reinitialize adapter after reboot\n", dev->name);
-			printk (KERN_WARNING "%s decrementing driver and closing interface\n", dev->name);
+			printk (KERN_WARNING "%s shutting down interface\n", dev->name);
 			RCDisableI2OInterrupts (dev);
 			dev->flags &= ~IFF_UP;
-			MOD_DEC_USE_COUNT;
-			/* FIXME: kill MOD_DEC_USE_COUNT, use dev_put */
 		} else {
 			printk (KERN_INFO "%s: rescheduling timer...\n",
 					dev->name);
