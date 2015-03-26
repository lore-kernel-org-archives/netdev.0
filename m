From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: smc91x: make use of 4th parameter to devm_gpiod_get_index
Date: Thu, 26 Mar 2015 22:26:08 +0100
Message-ID: <1427405168-28578-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, Alexandre Courbot <acourbot@nvidia.com>
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55333 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbbCZV0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:26:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 39b2bbe3d715 (gpio: add flags argument to gpiod_get*() functions)
which appeared in v3.17-rc1, the gpiod_get* functions take an additiona=
l
parameter that allows to specify direction and initial value for output=
=2E
Simplify accordingly.

Moreover use devm_gpiod_get_index_optional for still simpler handling.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/smsc/smc91x.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/=
smsc/smc91x.c
index 8678e39aba08..5a1a3e7c93e7 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2204,27 +2204,18 @@ static int try_toggle_control_gpio(struct devic=
e *dev,
 				   int value, unsigned int nsdelay)
 {
 	struct gpio_desc *gpio =3D *desc;
+	enum gpiod_flags flags =3D value ? GPIOD_OUT_LOW : GPIOD_OUT_HIGH;
 	int res;
=20
-	gpio =3D devm_gpiod_get_index(dev, name, index);
-	if (IS_ERR(gpio)) {
-		if (PTR_ERR(gpio) =3D=3D -ENOENT) {
-			*desc =3D NULL;
-			return 0;
-		}
-
+	gpio =3D devm_gpiod_get_index_optional(dev, name, index, flags);
+	if (IS_ERR(gpio))
 		return PTR_ERR(gpio);
+
+	if (gpio) {
+		if (nsdelay)
+			usleep_range(nsdelay, 2 * nsdelay);
+		gpiod_set_value_cansleep(gpio, value);
 	}
-	res =3D gpiod_direction_output(gpio, !value);
-	if (res) {
-		dev_err(dev, "unable to toggle gpio %s: %i\n", name, res);
-		devm_gpiod_put(dev, gpio);
-		gpio =3D NULL;
-		return res;
-	}
-	if (nsdelay)
-		usleep_range(nsdelay, 2 * nsdelay);
-	gpiod_set_value_cansleep(gpio, value);
 	*desc =3D gpio;
=20
 	return 0;
--=20
2.1.4
