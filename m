From: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH 2/2 (linux-stable-4.5.y)] stmmac: fix MDIO settings
Date: Mon, 23 May 2016 15:17:43 +0200
Message-ID: <1464009463-23654-3-git-send-email-peppe.cavallaro@st.com>
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
        Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S
 . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
To: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRBYUJRS5AKGQEX3WLTFI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464009463-23654-1-git-send-email-peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Initially the phy_bus_name was added to manipulate the
driver name but it was recently just used to manage the
fixed-link and then to take some decision at run-time.
So the patch uses the is_pseudo_fixed_link and removes
the phy_bus_name variable not necessary anymore.

The driver can manage the mdio registration by using phy-handle,
dwmac-mdio and own parameter e.g. snps,phy-addr.
This patch takes care about all these possible configurations
and fixes the mdio registration in case of there is a real
transceiver or a switch (that needs to be managed by using
fixed-link).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Reviewed-by: Andreas F=C3=A4rber <afaerber-l3A5Bk7waGM@public.gmane.org>
Tested-by: Frank Sch=C3=A4fer <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 11 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 19 +----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 84 +++++++++++++++++-=
----
 3 files changed, 70 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index c21015b..389d7d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -271,7 +271,6 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
  */
 bool stmmac_eee_init(struct stmmac_priv *priv)
 {
-	char *phy_bus_name =3D priv->plat->phy_bus_name;
 	unsigned long flags;
 	bool ret =3D false;
=20
@@ -283,7 +282,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		goto out;
=20
 	/* Never init EEE in case of a switch is attached */
-	if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
+	if (priv->phydev->is_pseudo_fixed_link)
 		goto out;
=20
 	/* MAC core supports the EEE feature. */
@@ -820,12 +819,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		phydev =3D of_phy_connect(dev, priv->plat->phy_node,
 					&stmmac_adjust_link, 0, interface);
 	} else {
-		if (priv->plat->phy_bus_name)
-			snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
-				 priv->plat->phy_bus_name, priv->plat->bus_id);
-		else
-			snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
-				 priv->plat->bus_id);
+		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
+			 priv->plat->bus_id);
=20
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_mdio.c
index 0faf163..3f5512f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -198,29 +198,12 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct mii_bus *new_bus;
 	struct stmmac_priv *priv =3D netdev_priv(ndev);
 	struct stmmac_mdio_bus_data *mdio_bus_data =3D priv->plat->mdio_bus_data;
+	struct device_node *mdio_node =3D priv->plat->mdio_node;
 	int addr, found;
-	struct device_node *mdio_node =3D NULL;
-	struct device_node *child_node =3D NULL;
=20
 	if (!mdio_bus_data)
 		return 0;
=20
-	if (IS_ENABLED(CONFIG_OF)) {
-		for_each_child_of_node(priv->device->of_node, child_node) {
-			if (of_device_is_compatible(child_node,
-						    "snps,dwmac-mdio")) {
-				mdio_node =3D child_node;
-				break;
-			}
-		}
-
-		if (mdio_node) {
-			netdev_dbg(ndev, "FOUND MDIO subnode\n");
-		} else {
-			netdev_warn(ndev, "No MDIO subnode found\n");
-		}
-	}
-
 	new_bus =3D mdiobus_alloc();
 	if (new_bus =3D=3D NULL)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6a52fa1..190fb6d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -96,6 +96,69 @@ static int dwmac1000_validate_ucast_entries(int ucast_en=
tries)
 }
=20
 /**
+ * stmmac_dt_phy - parse device-tree driver parameters to allocate PHY res=
ources
+ * @plat: driver data platform structure
+ * @np: device tree node
+ * @dev: device pointer
+ * Description:
+ * The mdio bus will be allocated in case of a phy transceiver is on board=
;
+ * it will be NULL if the fixed-link is configured.
+ * If there is the "snps,dwmac-mdio" sub-node the mdio will be allocated
+ * in any case (for DSA, mdio must be registered even if fixed-link).
+ * The table below sums the supported configurations:
+ *	-------------------------------
+ *	snps,phy-addr	|     Y
+ *	-------------------------------
+ *	phy-handle	|     Y
+ *	-------------------------------
+ *	fixed-link	|     N
+ *	-------------------------------
+ *	snps,dwmac-mdio	|
+ *	  even if	|     Y
+ *	fixed-link	|
+ *	-------------------------------
+ *
+ * It returns 0 in case of success otherwise -ENODEV.
+ */
+static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
+			 struct device_node *np, struct device *dev)
+{
+	bool mdio =3D true;
+
+	/* If phy-handle property is passed from DT, use it as the PHY */
+	plat->phy_node =3D of_parse_phandle(np, "phy-handle", 0);
+	if (plat->phy_node)
+		dev_dbg(dev, "Found phy-handle subnode\n");
+
+	/* If phy-handle is not specified, check if we have a fixed-phy */
+	if (!plat->phy_node && of_phy_is_fixed_link(np)) {
+		if ((of_phy_register_fixed_link(np) < 0))
+			return -ENODEV;
+
+		dev_dbg(dev, "Found fixed-link subnode\n");
+		plat->phy_node =3D of_node_get(np);
+		mdio =3D false;
+	}
+
+	/* If snps,dwmac-mdio is passed from DT, always register the MDIO */
+	for_each_child_of_node(np, plat->mdio_node) {
+		if (of_device_is_compatible(plat->mdio_node, "snps,dwmac-mdio"))
+			break;
+	}
+
+	if (plat->mdio_node) {
+		dev_dbg(dev, "Found MDIO subnode\n");
+		mdio =3D true;
+	}
+
+	if (mdio)
+		plat->mdio_bus_data =3D
+			devm_kzalloc(dev, sizeof(struct stmmac_mdio_bus_data),
+				     GFP_KERNEL);
+	return 0;
+}
+
+/**
  * stmmac_probe_config_dt - parse device-tree driver parameters
  * @pdev: platform_device structure
  * @plat: driver data platform structure
@@ -129,30 +192,15 @@ stmmac_probe_config_dt(struct platform_device *pdev, =
const char **mac)
 	/* Default to phy auto-detection */
 	plat->phy_addr =3D -1;
=20
-	/* If we find a phy-handle property, use it as the PHY */
-	plat->phy_node =3D of_parse_phandle(np, "phy-handle", 0);
-
-	/* If phy-handle is not specified, check if we have a fixed-phy */
-	if (!plat->phy_node && of_phy_is_fixed_link(np)) {
-		if ((of_phy_register_fixed_link(np) < 0))
-			return ERR_PTR(-ENODEV);
-
-		plat->phy_node =3D of_node_get(np);
-	}
-
 	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
 	 * and warn of its use. Remove this when phy node support is added.
 	 */
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) =3D=3D 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
=20
-	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_name)
-		plat->mdio_bus_data =3D NULL;
-	else
-		plat->mdio_bus_data =3D
-			devm_kzalloc(&pdev->dev,
-				     sizeof(struct stmmac_mdio_bus_data),
-				     GFP_KERNEL);
+	/* To Configure PHY by using all device-tree supported properties */
+	if (stmmac_dt_phy(plat, np, &pdev->dev))
+		return ERR_PTR(-ENODEV);
=20
 	of_property_read_u32(np, "tx-fifo-depth", &plat->tx_fifo_size);
=20
--=20
2.7.4

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
