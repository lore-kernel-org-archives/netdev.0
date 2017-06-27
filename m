From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/6] net: stmmac: support future possible
 different internal phy mode
Date: Tue, 27 Jun 2017 11:28:01 +0200
Message-ID: <20170627092806.28181-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	andre.przywara-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBJ6LZDFAKGQEPZC5MUI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

The current way to find if the phy is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the internal one.

By using phy-mode =3D "internal" we permit to have an external PHY with
the same mode than the internal one.

Reported-by: Andr=C3=A9 Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/ne=
t/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..6c2d1da05588 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -638,7 +638,7 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *p=
riv)
 {
 	struct sunxi_priv_data *gmac =3D priv->plat->bsp_priv;
 	struct device_node *node =3D priv->device->of_node;
-	int ret;
+	int ret, phy_interface;
 	u32 reg, val;
=20
 	regmap_read(gmac->regmap, SYSCON_EMAC_REG, &val);
@@ -718,7 +718,11 @@ static int sun8i_dwmac_set_syscon(struct stmmac_priv *=
priv)
 	if (gmac->variant->support_rmii)
 		reg &=3D ~SYSCON_RMII_EN;
=20
-	switch (priv->plat->interface) {
+	phy_interface =3D priv->plat->interface;
+	/* if PHY is internal, select the mode (xMII) used by the SoC */
+	if (gmac->use_internal_phy)
+		phy_interface =3D gmac->variant->internal_phy;
+	switch (phy_interface) {
 	case PHY_INTERFACE_MODE_MII:
 		/* default */
 		break;
@@ -932,7 +936,7 @@ static int sun8i_dwmac_probe(struct platform_device *pd=
ev)
 	}
=20
 	plat_dat->interface =3D of_get_phy_mode(dev->of_node);
-	if (plat_dat->interface =3D=3D gmac->variant->internal_phy) {
+	if (plat_dat->interface =3D=3D PHY_INTERFACE_MODE_INTERNAL) {
 		dev_info(&pdev->dev, "Will use internal PHY\n");
 		gmac->use_internal_phy =3D true;
 		gmac->ephy_clk =3D of_clk_get(plat_dat->phy_node, 0);
--=20
2.13.0

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
