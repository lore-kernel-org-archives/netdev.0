From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCH=20=28net=2Egit=29=203/3=5D=20stmmac=3A=20fix=20MDIO=20settings?=
Date: Fri, 1 Apr 2016 09:07:16 +0200
Message-ID: <1459494436-27386-4-git-send-email-peppe.cavallaro@st.com>
References: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<rhgadsdon@gmail.com>, <linux-kernel@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
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

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Andreas F=C3=A4rber <afaerber@suse.de>
Tested-by: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Cc: Dinh Nguyen <dinh.linux@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   16 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   19 +----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   84 ++++++++++++=
+++----
 include/linux/stmmac.h                             |    2 +-
 4 files changed, 73 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4c5ce98..78464fa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -278,7 +278,6 @@ static void stmmac_eee_ctrl_timer(unsigned long arg=
)
  */
 bool stmmac_eee_init(struct stmmac_priv *priv)
 {
-	char *phy_bus_name =3D priv->plat->phy_bus_name;
 	unsigned long flags;
 	bool ret =3D false;
=20
@@ -290,7 +289,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		goto out;
=20
 	/* Never init EEE in case of a switch is attached */
-	if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
+	if (priv->phydev->is_pseudo_fixed_link)
 		goto out;
=20
 	/* MAC core supports the EEE feature. */
@@ -827,12 +826,8 @@ static int stmmac_init_phy(struct net_device *dev)
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
@@ -871,9 +866,8 @@ static int stmmac_init_phy(struct net_device *dev)
 	}
=20
 	/* If attached to a switch, there is no reason to poll phy handler */
-	if (priv->plat->phy_bus_name)
-		if (!strcmp(priv->plat->phy_bus_name, "fixed"))
-			phydev->irq =3D PHY_IGNORE_INTERRUPT;
+	if (phydev->is_pseudo_fixed_link)
+		phydev->irq =3D PHY_IGNORE_INTERRUPT;
=20
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link =3D %d\n", dev->name, phydev->phy_id, phydev->link);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index af09ced..06704ca 100644
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
index 9cf181f..cf37ea5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -132,6 +132,69 @@ static struct stmmac_axi *stmmac_axi_setup(struct =
platform_device *pdev)
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
@@ -165,30 +228,15 @@ stmmac_probe_config_dt(struct platform_device *pd=
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
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 6e53fa8..e6bc30a 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -108,12 +108,12 @@ struct stmmac_axi {
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
