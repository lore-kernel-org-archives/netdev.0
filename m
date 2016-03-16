From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCHv4=20=28net=2Egit=29=201/2=5D=20Revert=20=22stmmac=3A=20Fix=20=27eth0=3A=20No=20PHY=20found=27=20regression=22?=
Date: Wed, 16 Mar 2016 10:38:48 +0100
Message-ID: <1458121129-18818-2-git-send-email-peppe.cavallaro@st.com>
References: <1458121129-18818-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:41955 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965965AbcCPJdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:33:53 -0400
In-Reply-To: <1458121129-18818-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 88f8b1bb41c6208f81b6a480244533ded7b59493.
due to problems on GeekBox and Banana Pi M1 board when
connected to a real transceiver instead of a switch via
fixed-link.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Cc: Andreas F=C3=A4rber <afaerber@suse.de>
Cc: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
Cc: Dinh Nguyen <dinh.linux@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   11 ++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    9 +--------
 include/linux/stmmac.h                             |    1 -
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index efb54f3..0faf163 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -199,12 +199,21 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct stmmac_priv *priv =3D netdev_priv(ndev);
 	struct stmmac_mdio_bus_data *mdio_bus_data =3D priv->plat->mdio_bus_d=
ata;
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
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4514ba7..6a52fa1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -110,7 +110,6 @@ stmmac_probe_config_dt(struct platform_device *pdev=
, const char **mac)
 	struct device_node *np =3D pdev->dev.of_node;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_dma_cfg *dma_cfg;
-	struct device_node *child_node =3D NULL;
=20
 	plat =3D devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
 	if (!plat)
@@ -141,19 +140,13 @@ stmmac_probe_config_dt(struct platform_device *pd=
ev, const char **mac)
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
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) =3D=3D=
 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
=20
-	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_node=
)
+	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_na=
me)
 		plat->mdio_bus_data =3D NULL;
 	else
 		plat->mdio_bus_data =3D
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 881a79d..eead8ab 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -100,7 +100,6 @@ struct plat_stmmacenet_data {
 	int interface;
 	struct stmmac_mdio_bus_data *mdio_bus_data;
 	struct device_node *phy_node;
-	struct device_node *mdio_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	int clk_csr;
 	int has_gmac;
--=20
1.7.4.4
