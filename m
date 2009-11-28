From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] ep93xx-eth: check for zero MAC address on probe, not on device open
Date: Sun, 29 Nov 2009 00:43:19 +0100
Message-ID: <200911290043.20273.florian@openwrt.org>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f215.google.com ([209.85.219.215]:35297 "EHLO
	mail-ew0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbZK1XnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 18:43:17 -0500
Received: by ewy7 with SMTP id 7so3076655ewy.28
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 15:43:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we happen to have registered the driver without passing
a MAC address, we will print a zero MAC address and register
the interface with this invalid address, this is confusin. This
patch moves the checking of a valid ethernet address and the
generation of a random one down from the open function to
the probe function.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 2be49c8..47e0d9f 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -628,15 +628,6 @@ static int ep93xx_open(struct net_device *dev)
 	if (ep93xx_alloc_buffers(ep))
 		return -ENOMEM;
 
-	if (is_zero_ether_addr(dev->dev_addr)) {
-		random_ether_addr(dev->dev_addr);
-		printk(KERN_INFO "%s: generated random MAC address "
-			"%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n", dev->name,
-			dev->dev_addr[0], dev->dev_addr[1],
-			dev->dev_addr[2], dev->dev_addr[3],
-			dev->dev_addr[4], dev->dev_addr[5]);
-	}
-
 	napi_enable(&ep->napi);
 
 	if (ep93xx_start_hw(dev)) {
@@ -876,13 +867,16 @@ static int ep93xx_eth_probe(struct platform_device *pdev)
 	ep->mii.mdio_read = ep93xx_mdio_read;
 	ep->mii.mdio_write = ep93xx_mdio_write;
 	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  */
+	
+	if (is_zero_ether_addr(dev->dev_addr))
+		random_ether_addr(dev->dev_addr);
 
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to register netdev\n");
 		goto err_out;
 	}
-
+	
 	printk(KERN_INFO "%s: ep93xx on-chip ethernet, IRQ %d, "
 			 "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n", dev->name,
 			ep->irq, data->dev_addr[0], data->dev_addr[1],
