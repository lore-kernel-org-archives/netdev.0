From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 3/3] net: fec: Reset ethernet PHY whenever the enet_out clock is being enabled
Date: Mon, 30 Nov 2015 12:32:48 +0100
Message-ID: <1448883168-30742-4-git-send-email-LW@KARO-electronics.de>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
 <1448883168-30742-2-git-send-email-LW@KARO-electronics.de>
 <1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
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
In-Reply-To: <1448883168-30742-3-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a PHY uses ENET_OUT as reference clock, it may need a RESET to get
functional after the clock had been disabled.

=46ailure to do this results in the link state constantly toggling
between up and down:
fec 02188000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx=
/tx
fec 02188000.ethernet eth0: Link is Down
fec 02188000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx=
/tx
fec 02188000.ethernet eth0: Link is Down
[...]

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h      |  1 +
 drivers/net/ethernet/freescale/fec_main.c | 46 +++++++++++++++++++++++=
+-------
 2 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 99d33e2..8ab4f7f 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -519,6 +519,7 @@ struct fec_enet_private {
 	int	pause_flag;
 	int	wol_flag;
 	u32	quirks;
+	struct gpio_desc *phy_reset;
=20
 	struct	napi_struct napi;
 	int	csum_flags;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 1a983fc..7ba2bbb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -66,6 +66,7 @@
=20
 static void set_multicast_list(struct net_device *ndev);
 static void fec_enet_itr_coal_init(struct net_device *ndev);
+static void fec_reset_phy(struct platform_device *pdev);
=20
 #define DRIVER_NAME	"fec"
=20
@@ -1861,6 +1862,8 @@ static int fec_enet_clk_enable(struct net_device =
*ndev, bool enable)
 			ret =3D clk_prepare_enable(fep->clk_enet_out);
 			if (ret)
 				goto failed_clk_enet_out;
+
+			fec_reset_phy(fep->pdev);
 		}
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
@@ -3231,13 +3234,32 @@ static int fec_enet_init(struct net_device *nde=
v)
 }
=20
 #ifdef CONFIG_OF
-static void fec_reset_phy(struct platform_device *pdev)
+static struct gpio_desc *fec_get_reset_gpio(struct platform_device *pd=
ev)
 {
 	struct gpio_desc *phy_reset;
-	int msec =3D 1;
 	struct device_node *np =3D pdev->dev.of_node;
=20
 	if (!np)
+		return ERR_PTR(-ENODEV);
+
+	phy_reset =3D devm_gpiod_get_optional(&pdev->dev, "phy-reset",
+					    GPIOD_OUT_LOW);
+	if (IS_ERR(phy_reset))
+		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %ld\n",
+			PTR_ERR(phy_reset));
+	return phy_reset;
+}
+
+static void fec_reset_phy(struct platform_device *pdev)
+{
+	struct device_node *np =3D pdev->dev.of_node;
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	int msec =3D 1;
+
+	if (!fep->phy_reset)
+		return;
+	if (!np)
 		return;
=20
 	of_property_read_u32(np, "phy-reset-duration", &msec);
@@ -3245,17 +3267,16 @@ static void fec_reset_phy(struct platform_devic=
e *pdev)
 	if (msec > 1000)
 		msec =3D 1;
=20
-	phy_reset =3D devm_gpiod_get_optional(&pdev->dev, "phy-reset",
-					    GPIOD_OUT_LOW);
-	if (IS_ERR(phy_reset)) {
-		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %ld\n",
-			PTR_ERR(phy_reset));
-		return;
-	}
+	gpiod_set_value_cansleep(fep->phy_reset, 0);
 	msleep(msec);
-	gpiod_set_value_cansleep(phy_reset, 1);
+	gpiod_set_value_cansleep(fep->phy_reset, 1);
 }
 #else /* CONFIG_OF */
+static void fec_get_reset_gpio(struct platform_device *pdev)
+{
+	return -EINVAL;
+}
+
 static void fec_reset_phy(struct platform_device *pdev)
 {
 	/*
@@ -3309,8 +3330,12 @@ fec_probe(struct platform_device *pdev)
 	struct device_node *np =3D pdev->dev.of_node, *phy_node;
 	int num_tx_qs;
 	int num_rx_qs;
+	struct gpio_desc *phy_reset;
=20
 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
+	phy_reset =3D fec_get_reset_gpio(pdev);
+	if (IS_ERR(phy_reset) && PTR_ERR(phy_reset) =3D=3D -EPROBE_DEFER)
+		return -EPROBE_DEFER;
=20
 	/* Init network device */
 	ndev =3D alloc_etherdev_mqs(sizeof(struct fec_enet_private),
@@ -3331,6 +3356,7 @@ fec_probe(struct platform_device *pdev)
 	fep->netdev =3D ndev;
 	fep->num_rx_queues =3D num_rx_qs;
 	fep->num_tx_queues =3D num_tx_qs;
+	fep->phy_reset =3D phy_reset;
=20
 #if !defined(CONFIG_M5272)
 	/* default enable pause frame auto negotiation */
--=20
2.1.4
