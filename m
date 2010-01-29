From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/13] tulip/xircom_cb.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:29 -0800
Message-ID: <4ee12108908c92bcbda3d0a78786c721421ffd89.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1587 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754402Ab0A2G7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:33 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove DRV_NAME and xircom_cb from pr_<level>
Convert embedded function names in logging messages to %s, __func__

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/xircom_cb.c |   44 +++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index c84123f..acfeeb9 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -14,6 +14,8 @@
  * 	$Id: xircom_cb.c,v 1.33 2001/03/19 14:02:07 arjanv Exp $
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -234,7 +236,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	pci_write_config_word (pdev, PCI_STATUS,tmp16);
 
 	if (!request_region(pci_resource_start(pdev, 0), 128, "xircom_cb")) {
-		printk(KERN_ERR "xircom_probe: failed to allocate io-region\n");
+		pr_err("%s: failed to allocate io-region\n", __func__);
 		return -ENODEV;
 	}
 
@@ -245,7 +247,7 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	 */
 	dev = alloc_etherdev(sizeof(struct xircom_private));
 	if (!dev) {
-		printk(KERN_ERR "xircom_probe: failed to allocate etherdev\n");
+		pr_err("%s: failed to allocate etherdev\n", __func__);
 		goto device_fail;
 	}
 	private = netdev_priv(dev);
@@ -253,12 +255,12 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	/* Allocate the send/receive buffers */
 	private->rx_buffer = pci_alloc_consistent(pdev,8192,&private->rx_dma_handle);
 	if (private->rx_buffer == NULL) {
- 		printk(KERN_ERR "xircom_probe: no memory for rx buffer \n");
+		pr_err("%s: no memory for rx buffer\n", __func__);
 		goto rx_buf_fail;
 	}
 	private->tx_buffer = pci_alloc_consistent(pdev,8192,&private->tx_dma_handle);
 	if (private->tx_buffer == NULL) {
-		printk(KERN_ERR "xircom_probe: no memory for tx buffer \n");
+		pr_err("%s: no memory for tx buffer\n", __func__);
 		goto tx_buf_fail;
 	}
 
@@ -281,11 +283,12 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	pci_set_drvdata(pdev, dev);
 
 	if (register_netdev(dev)) {
-		printk(KERN_ERR "xircom_probe: netdevice registration failed.\n");
+		pr_err("%s: netdevice registration failed\n", __func__);
 		goto reg_fail;
 	}
 
-	printk(KERN_INFO "%s: Xircom cardbus revision %i at irq %i \n", dev->name, pdev->revision, pdev->irq);
+	dev_info(&dev->dev, "Xircom cardbus revision %i at irq %i\n",
+		 pdev->revision, pdev->irq);
 	/* start the transmitter to get a heartbeat */
 	/* TODO: send 2 dummy packets here */
 	transceiver_voodoo(private);
@@ -347,8 +350,10 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 
 #ifdef DEBUG
 	print_binary(status);
-	printk("tx status 0x%08x 0x%08x \n",card->tx_buffer[0],card->tx_buffer[4]);
-	printk("rx status 0x%08x 0x%08x \n",card->rx_buffer[0],card->rx_buffer[4]);
+	printk("tx status 0x%08x 0x%08x \n",
+	       card->tx_buffer[0], card->tx_buffer[4]);
+	printk("rx status 0x%08x 0x%08x \n",
+	       card->rx_buffer[0], card->rx_buffer[4]);
 #endif
 	/* Handle shared irq and hotplug */
 	if (status == 0 || status == 0xffffffff) {
@@ -358,9 +363,9 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 
 	if (link_status_changed(card)) {
 		int newlink;
-		printk(KERN_DEBUG "xircom_cb: Link status has changed \n");
+		printk(KERN_DEBUG "xircom_cb: Link status has changed\n");
 		newlink = link_status(card);
-		printk(KERN_INFO  "xircom_cb: Link is %i mbit \n",newlink);
+		dev_info(&dev->dev, "Link is %i mbit\n", newlink);
 		if (newlink)
 			netif_carrier_on(dev);
 		else
@@ -457,7 +462,8 @@ static int xircom_open(struct net_device *dev)
 	struct xircom_private *xp = netdev_priv(dev);
 	int retval;
 	enter("xircom_open");
-	printk(KERN_INFO "xircom cardbus adaptor found, registering as %s, using irq %i \n",dev->name,dev->irq);
+	pr_info("xircom cardbus adaptor found, registering as %s, using irq %i \n",
+		dev->name, dev->irq);
 	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		leave("xircom_open - No IRQ");
@@ -770,7 +776,7 @@ static void activate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Receiver failed to deactivate\n");
+			pr_err("Receiver failed to deactivate\n");
 	}
 
 	/* enable the receiver */
@@ -787,7 +793,7 @@ static void activate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Receiver failed to re-activate\n");
+			pr_err("Receiver failed to re-activate\n");
 	}
 
 	leave("activate_receiver");
@@ -818,7 +824,7 @@ static void deactivate_receiver(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Receiver failed to deactivate\n");
+			pr_err("Receiver failed to deactivate\n");
 	}
 
 
@@ -861,7 +867,7 @@ static void activate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Transmitter failed to deactivate\n");
+			pr_err("Transmitter failed to deactivate\n");
 	}
 
 	/* enable the transmitter */
@@ -878,7 +884,7 @@ static void activate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Transmitter failed to re-activate\n");
+			pr_err("Transmitter failed to re-activate\n");
 	}
 
 	leave("activate_transmitter");
@@ -909,7 +915,7 @@ static void deactivate_transmitter(struct xircom_private *card)
 		udelay(50);
 		counter--;
 		if (counter <= 0)
-			printk(KERN_ERR "xircom_cb: Transmitter failed to deactivate\n");
+			pr_err("Transmitter failed to deactivate\n");
 	}
 
 
@@ -1184,7 +1190,7 @@ static void investigate_read_descriptor(struct net_device *dev,struct xircom_pri
 			struct sk_buff *skb;
 
 			if (pkt_len > 1518) {
-				printk(KERN_ERR "xircom_cb: Packet length %i is bogus \n",pkt_len);
+				pr_err("Packet length %i is bogus\n", pkt_len);
 				pkt_len = 1518;
 			}
 
@@ -1222,7 +1228,7 @@ static void investigate_write_descriptor(struct net_device *dev, struct xircom_p
 		status = le32_to_cpu(card->tx_buffer[4*descnr]);
 #if 0
 		if (status & 0x8000) {	/* Major error */
-			printk(KERN_ERR "Major transmit error status %x \n", status);
+			pr_err("Major transmit error status %x\n", status);
 			card->tx_buffer[4*descnr] = 0;
 			netif_wake_queue (dev);
 		}
-- 
1.6.6.rc0.57.gad7a

