From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH v2] net: phy: at803x: simplify using devm_gpiod_get_optional and its 4th argument
Date: Tue, 31 Mar 2015 22:08:45 +0200
Message-ID: <1427832525-6949-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>, kernel@pengutronix.de
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55349 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbbCaUIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 16:08:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 39b2bbe3d715 (gpio: add flags argument to gpiod_get*() functions)
which appeared in v3.17-rc1, the gpiod_get* functions take an additiona=
l
parameter that allows to specify direction and initial value for output=
=2E
Moreover use devm_gpiod_get_optional instead of ignoring all errors
returned by devm_gpiod_get and simplify accordingly.

The result is more strict error handling which is good.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

with the local variable introduced to not keep an error value in the
driver struct this doesn't have a positive diffstat anymore. I still
think assigning directly to priv->gpiod_reset would fine because having
the priv->gpiod_reset NULL is neither more nor less right that
ERR_PTR(-ESOMETHING).

Note that my motivation for this change is to get all drivers use the
currently optional fourth parameter to stop it being optional which
needs hard to understand cpp trickery.

Best regards
Uwe

 drivers/net/phy/at803x.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f80e19ac6704..fabf11d32d27 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -192,16 +192,17 @@ static int at803x_probe(struct phy_device *phydev=
)
 {
 	struct device *dev =3D &phydev->dev;
 	struct at803x_priv *priv;
+	struct gpio_desc *gpiod_reset;
=20
 	priv =3D devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
=20
-	priv->gpiod_reset =3D devm_gpiod_get(dev, "reset");
-	if (IS_ERR(priv->gpiod_reset))
-		priv->gpiod_reset =3D NULL;
-	else
-		gpiod_direction_output(priv->gpiod_reset, 1);
+	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH)=
;
+	if (IS_ERR(gpiod_reset))
+		return PTR_ERR(gpiod_reset);
+
+	priv->gpiod_reset =3D gpiod_reset;
=20
 	phydev->priv =3D priv;
=20
--=20
2.1.4
