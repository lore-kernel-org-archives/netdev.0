From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 00:44:40 +0300
Message-ID: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: u.kleine-koenig@pengutronix.de
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34523 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbcCVVoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 17:44:44 -0400
Received: by mail-lb0-f179.google.com with SMTP id k12so174034458lbb.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 14:44:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver of course "knows" that the chip's reset signal is active low,
so  it drives the GPIO to 0  to reset the PHY and to 1 otherwise; however
all this will only work iff the GPIO  is  specified as active-high in the
device tree!  I think both the driver and the device trees (if there are
any -- I was unable to find them) need to be fixed in this case...

Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/phy/at803x.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net/drivers/net/phy/at803x.c
===================================================================
--- net.orig/drivers/net/phy/at803x.c
+++ net/drivers/net/phy/at803x.c
@@ -277,7 +277,7 @@ static int at803x_probe(struct phy_devic
 	if (!priv)
 		return -ENOMEM;
 
-	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
+	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
 	if (IS_ERR(gpiod_reset))
 		return PTR_ERR(gpiod_reset);
 
@@ -362,10 +362,10 @@ static void at803x_link_change_notify(st
 
 				at803x_context_save(phydev, &context);
 
-				gpiod_set_value(priv->gpiod_reset, 0);
-				msleep(1);
 				gpiod_set_value(priv->gpiod_reset, 1);
 				msleep(1);
+				gpiod_set_value(priv->gpiod_reset, 0);
+				msleep(1);
 
 				at803x_context_restore(phydev, &context);
 
