From: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH 1/2 (linux-stable-4.5.y)] Revert "stmmac: Fix
 'eth0: No PHY found' regression"
Date: Mon, 23 May 2016 15:17:42 +0200
Message-ID: <1464009463-23654-2-git-send-email-peppe.cavallaro@st.com>
References: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
Reply-To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <robin.murphy-5wv7dgnIgG8@public.gmane.org>, <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, <afaerber-l3A5Bk7waGM@public.gmane.org>,
        <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, <bert-phGP8mJ4Mqk@public.gmane.org>,
        <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Gabriel Fernandez
	<gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        =?UTF-8?q?Frank=20Sch=C3=A4fer?=
	<fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S
 . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRBWMJRS5AKGQEKHL2HJA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464009463-23654-1-git-send-email-peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>

This reverts commit 88f8b1bb41c6208f81b6a480244533ded7b59493.
due to problems on GeekBox and Banana Pi M1 board when
connected to a real transceiver instead of a switch via
fixed-link.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Cc: Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Andreas F=C3=A4rber <afaerber-l3A5Bk7waGM@public.gmane.org>
Cc: Frank Sch=C3=A4fer <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c     | 11 ++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  9 +--------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_mdio.c
index efb54f3..0faf163 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -199,12 +199,21 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct stmmac_priv *priv =3D netdev_priv(ndev);
 	struct stmmac_mdio_bus_data *mdio_bus_data =3D priv->plat->mdio_bus_data;
 	int addr, found;
-	struct device_node *mdio_node =3D priv->plat->mdio_node;
+	struct device_node *mdio_node =3D NULL;
+	struct device_node *child_node =3D NULL;
=20
 	if (!mdio_bus_data)
 		return 0;
=20
 	if (IS_ENABLED(CONFIG_OF)) {
+		for_each_child_of_node(priv->device->of_node, child_node) {
+			if (of_device_is_compatible(child_node,
+						    "snps,dwmac-mdio")) {
+				mdio_node =3D child_node;
+				break;
+			}
+		}
+
 		if (mdio_node) {
 			netdev_dbg(ndev, "FOUND MDIO subnode\n");
 		} else {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4514ba7..6a52fa1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -110,7 +110,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, co=
nst char **mac)
 	struct device_node *np =3D pdev->dev.of_node;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_dma_cfg *dma_cfg;
-	struct device_node *child_node =3D NULL;
=20
 	plat =3D devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
 	if (!plat)
@@ -141,19 +140,13 @@ stmmac_probe_config_dt(struct platform_device *pdev, =
const char **mac)
 		plat->phy_node =3D of_node_get(np);
 	}
=20
-	for_each_child_of_node(np, child_node)
-		if (of_device_is_compatible(child_node,	"snps,dwmac-mdio")) {
-			plat->mdio_node =3D child_node;
-			break;
-		}
-
 	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
 	 * and warn of its use. Remove this when phy node support is added.
 	 */
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) =3D=3D 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
=20
-	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_node)
+	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_name)
 		plat->mdio_bus_data =3D NULL;
 	else
 		plat->mdio_bus_data =3D
--=20
2.7.4

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
