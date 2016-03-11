From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCHv3=20=28net=2Egit=29=202/2=5D=20stmmac=3A=20fix=20MDIO=20settings?=
Date: Fri, 11 Mar 2016 14:33:16 +0100
Message-ID: <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:35079 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752710AbcCKN1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 08:27:02 -0500
In-Reply-To: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initially the phy_bus_name was added to manipulate the
driver name but It was recently just used to manage the
fixed-link and then to take some decision at run-time
inside the main (for example to skip EEE).
So the patch uses the is_pseudo_fixed_link and removes
removes the phy_bus_name variable not necessary anymore.

The driver can manage the mdio registration by using phy-handle,
dwmac-mdio and own parameter e.g. snps,phy-addr.
This patch takes care about all these possible configurations
and fixes the mdio registration in case of there is a real
transceiver or a switch (that needs to be managed by using
fixed-link).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Andreas F=C3=A4rber <afaerber@suse.de>
Tested-by: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Cc: Dinh Nguyen <dinh.linux@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Phil Reid <preid@electromag.com.au>
---

V2: use is_pseudo_fixed_link
V3: parse device-tree driver parameters to allocate PHY resources consi=
dering
    DSA case (+ fixed-link).

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   19 +-----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   77 ++++++++++++=
++++----
 include/linux/stmmac.h                             |    2 +-
 4 files changed, 68 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
index c21015b..389d7d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -271,7 +271,6 @@ static void stmmac_eee_ctrl_timer(unsigned long arg=
)
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
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 0faf163..3f5512f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -198,29 +198,12 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct mii_bus *new_bus;
 	struct stmmac_priv *priv =3D netdev_priv(ndev);
 	struct stmmac_mdio_bus_data *mdio_bus_data =3D priv->plat->mdio_bus_d=
ata;
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
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6a52fa1..d2322e9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -96,6 +96,66 @@ static int dwmac1000_validate_ucast_entries(int ucas=
t_entries)
 }
=20
 /**
+ * stmmac_dt_phy - parse device-tree driver parameters to allocate PHY=
 resources
+ * @plat: driver data platform structure
+ * @np: device tree node
+ * @dev: device pointer
+ * Description:
+ * The mdio bus will be allocated in case of a phy transceiver is on b=
oard;
+ * it will be NULL if the fixed-link is configured.
+ * If there is the "snps,dwmac-mdio" sub-node the mdio will be allocat=
ed
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
+ * It returns true in case of the mdio needs to be registered in the m=
ain.
+ */
+static bool stmmac_dt_phy(struct plat_stmmacenet_data *plat,
+			  struct device_node *np, struct device *dev)
+{
+	bool ret =3D true;
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
+
+		ret =3D false;
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
+		ret =3D true;
+	}
+
+	return ret;
+}
+
+/**
  * stmmac_probe_config_dt - parse device-tree driver parameters
  * @pdev: platform_device structure
  * @plat: driver data platform structure
@@ -129,30 +189,19 @@ stmmac_probe_config_dt(struct platform_device *pd=
ev, const char **mac)
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
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) =3D=3D=
 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
=20
-	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_na=
me)
-		plat->mdio_bus_data =3D NULL;
-	else
+	/* To Configure PHY by using all device-tree supported properties */
+	if (stmmac_dt_phy(plat, np, &pdev->dev)) {
 		plat->mdio_bus_data =3D
 			devm_kzalloc(&pdev->dev,
 				     sizeof(struct stmmac_mdio_bus_data),
 				     GFP_KERNEL);
+	}
=20
 	of_property_read_u32(np, "tx-fifo-depth", &plat->tx_fifo_size);
=20
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index eead8ab..8b1ff2b 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -94,12 +94,12 @@ struct stmmac_dma_cfg {
 };
=20
 struct plat_stmmacenet_data {
-	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
 	struct stmmac_mdio_bus_data *mdio_bus_data;
 	struct device_node *phy_node;
+	struct device_node *mdio_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	int clk_csr;
 	int has_gmac;
--=20
1.7.4.4
