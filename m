From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030 PHY
Date: Wed, 23 Mar 2016 11:49:09 +0100
Message-ID: <56F274A5.6030502@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net> <20160322194224.GF6191@pengutronix.de> <56F26BF7.3090201@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz28.laposte.net ([194.117.213.103]:42951 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751611AbcCWKtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 06:49:13 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout016 (Postfix) with ESMTP id CAE49111082
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 11:49:10 +0100 (CET)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.prosodie [10.128.63.4])
	by lpn-prd-vrout016 (Postfix) with ESMTP id C8A32110E09
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 11:49:10 +0100 (CET)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
	by lpn-prd-vrin003 (Postfix) with ESMTP id B183D48C41F
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 11:49:10 +0100 (CET)
In-Reply-To: <56F26BF7.3090201@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the dependency on GPIOLIB for non faulty PHYs.

Indeed, without this patch, if GPIOLIB is not selected
devm_gpiod_get_optional() will return -ENOSYS and the driver probe
call will fail, regardless of the actual PHY hardware.

Out of the 3 PHYs supported by this driver (AT8030, AT8031, AT8035),
only AT8030 presents the issues that commit 13a56b449325 ("net: phy:
at803x: Add support for hardware reset") attempts to work-around by
using a 'reset' GPIO line.

Hence, only AT8030 should depend on GPIOLIB operating properly.

Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
 drivers/net/phy/at803x.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2174ec9..dcecf25 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -251,12 +251,16 @@ static int at803x_probe(struct phy_device *phydev)
 	if (!priv)
 		return -ENOMEM;

+	if (phydev->drv->phy_id != ATH8030_PHY_ID)
+		goto does_not_require_reset_workaround;
+
 	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
 	if (IS_ERR(gpiod_reset))
 		return PTR_ERR(gpiod_reset);

 	priv->gpiod_reset = gpiod_reset;

+does_not_require_reset_workaround:
 	phydev->priv = priv;

 	return 0;
-- 
2.1.4
