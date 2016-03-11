From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCHv2=20=28net=2Egit=29=202/2=5D=20stmmac=3A=20fix=20MDIO=20settings?=
Date: Fri, 11 Mar 2016 08:44:05 +0100
Message-ID: <1457682245-22746-3-git-send-email-peppe.cavallaro@st.com>
References: <1457682245-22746-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:56454 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934008AbcCKHho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 02:37:44 -0500
In-Reply-To: <1457682245-22746-1-git-send-email-peppe.cavallaro@st.com>
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
---

V2: use is_pseudo_fixed_link

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++--------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   14 +++++-------=
--
 include/linux/stmmac.h                             |    1 -
 3 files changed, 8 insertions(+), 18 deletions(-)

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
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6a52fa1..ed33920 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -138,7 +138,11 @@ stmmac_probe_config_dt(struct platform_device *pde=
v, const char **mac)
 			return ERR_PTR(-ENODEV);
=20
 		plat->phy_node =3D of_node_get(np);
-	}
+	} else
+		plat->mdio_bus_data =3D
+			devm_kzalloc(&pdev->dev,
+				     sizeof(struct stmmac_mdio_bus_data),
+				     GFP_KERNEL);
=20
 	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
 	 * and warn of its use. Remove this when phy node support is added.
@@ -146,14 +150,6 @@ stmmac_probe_config_dt(struct platform_device *pde=
v, const char **mac)
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
-
 	of_property_read_u32(np, "tx-fifo-depth", &plat->tx_fifo_size);
=20
 	of_property_read_u32(np, "rx-fifo-depth", &plat->rx_fifo_size);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index eead8ab..1b4884c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -94,7 +94,6 @@ struct stmmac_dma_cfg {
 };
=20
 struct plat_stmmacenet_data {
-	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
--=20
1.7.4.4
