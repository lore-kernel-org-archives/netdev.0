From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] macb: fix PHY reset
Date: Tue, 22 Mar 2016 22:27:38 +0300
Message-ID: <3349780.3Prc3uV314@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:33777 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbcCVT1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:27:43 -0400
Received: by mail-lb0-f173.google.com with SMTP id oe12so172485025lbc.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 12:27:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver calls gpiod_set_value() with GPIOD_OUT_* instead of 0 and 1, as
a result the PHY isn't really  put back into reset state in macb_remove().
Moreover, the driver assumes that something else has set the GPIO direction
to output, so if  it has not, the PHY wouldn't be taken out of reset in
macb_probe() either...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against David Miller's 'net.git' repo.

 drivers/net/ethernet/cadence/macb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/cadence/macb.c
===================================================================
--- net.orig/drivers/net/ethernet/cadence/macb.c
+++ net/drivers/net/ethernet/cadence/macb.c
@@ -2959,7 +2959,7 @@ static int macb_probe(struct platform_de
 		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
 		if (gpio_is_valid(gpio))
 			bp->reset_gpio = gpio_to_desc(gpio);
-		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
+		gpiod_direction_output(bp->reset_gpio, 1);
 	}
 	of_node_put(phy_node);
 
@@ -3029,7 +3029,7 @@ static int macb_remove(struct platform_d
 		mdiobus_free(bp->mii_bus);
 
 		/* Shutdown the PHY if there is a GPIO reset */
-		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_LOW);
+		gpiod_set_value(bp->reset_gpio, 0);
 
 		unregister_netdev(dev);
 		clk_disable_unprepare(bp->tx_clk);
