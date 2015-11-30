From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 2/3] net: fec: convert to using gpiod framework
Date: Mon, 30 Nov 2015 12:32:47 +0100
Message-ID: <1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
 <1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use gpiod_get_optional() instead of checking for a valid GPIO number
and calling devm_gpio_request_one() conditionally.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index e17d74f..1a983fc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3233,7 +3233,7 @@ static int fec_enet_init(struct net_device *ndev)
 #ifdef CONFIG_OF
 static void fec_reset_phy(struct platform_device *pdev)
 {
-	int err, phy_reset;
+	struct gpio_desc *phy_reset;
 	int msec =3D 1;
 	struct device_node *np =3D pdev->dev.of_node;
=20
@@ -3245,18 +3245,15 @@ static void fec_reset_phy(struct platform_devic=
e *pdev)
 	if (msec > 1000)
 		msec =3D 1;
=20
-	phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (!gpio_is_valid(phy_reset))
-		return;
-
-	err =3D devm_gpio_request_one(&pdev->dev, phy_reset,
-				    GPIOF_OUT_INIT_LOW, "phy-reset");
-	if (err) {
-		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
+	phy_reset =3D devm_gpiod_get_optional(&pdev->dev, "phy-reset",
+					    GPIOD_OUT_LOW);
+	if (IS_ERR(phy_reset)) {
+		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %ld\n",
+			PTR_ERR(phy_reset));
 		return;
 	}
 	msleep(msec);
-	gpio_set_value_cansleep(phy_reset, 1);
+	gpiod_set_value_cansleep(phy_reset, 1);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
--=20
2.1.4
