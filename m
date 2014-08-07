From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH v3] net: gianfar: fix reference counting for phy_node
Date: Thu,  7 Aug 2014 22:01:47 +0200
Message-ID: <1407441707-27172-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1407440506-20028-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33687 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbaHGUBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 16:01:54 -0400
In-Reply-To: <1407440506-20028-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The line before the changed if condition is:

	priv->phy_node =3D of_parse_phandle(np, "phy-handle", 0);

=2E If this call succeeds priv->phy_node must not be overwritten in the=
 if
block; otherwise the reference to the node returned by of_parse_phandle
is lost. So add a check that the if block isn't executed in this case.

=46urthermore in the fixed phy case no reference is aquired for phy_nod=
e
resulting in an of_node_put without holding a reference. To fix that,
get a reference on the MAC dt node.

=46ixes: be40364544bd ("gianfar: use the new fixed PHY helpers")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Changes since v2:

 - add a Fixes: footer as suggested by Thomas Petazzoni via irc

 drivers/net/ethernet/broadcom/genet/bcmmii.c          | 6 ++++--
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 2 +-
 drivers/net/ethernet/freescale/gianfar.c              | 4 ++--
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net=
/ethernet/broadcom/genet/bcmmii.c
index add8d8596084..693659f05776 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -311,12 +311,12 @@ static int bcmgenet_mii_probe(struct net_device *=
dev)
 	/* In the case of a fixed PHY, the DT node associated
 	 * to the PHY is the Ethernet MAC DT node.
 	 */
-	if (of_phy_is_fixed_link(dn)) {
+	if (!priv->phy_dn && of_phy_is_fixed_link(dn)) {
 		ret =3D of_phy_register_fixed_link(dn);
 		if (ret)
 			return ret;
=20
-		priv->phy_dn =3D dn;
+		priv->phy_dn =3D of_get_node(dn);
 	}
=20
 	phydev =3D of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup, 0,
@@ -452,6 +452,7 @@ int bcmgenet_mii_init(struct net_device *dev)
 	return 0;
=20
 out:
+	of_node_put(priv->phy_dn);
 	mdiobus_unregister(priv->mii_bus);
 out_free:
 	kfree(priv->mii_bus->irq);
@@ -463,6 +464,7 @@ void bcmgenet_mii_exit(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv =3D netdev_priv(dev);
=20
+	of_node_put(priv->phy_dn);
 	mdiobus_unregister(priv->mii_bus);
 	kfree(priv->mii_bus->irq);
 	mdiobus_free(priv->mii_bus);
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/dr=
ivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index cfaf17b70f3f..748fd24d3d9e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1033,7 +1033,7 @@ static int fs_enet_probe(struct platform_device *=
ofdev)
 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
 		 */
-		fpi->phy_node =3D ofdev->dev.of_node;
+		fpi->phy_node =3D of_node_get(ofdev->dev.of_node);
 	}
=20
 	if (of_device_is_compatible(ofdev->dev.of_node, "fsl,mpc5125-fec")) {
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/eth=
ernet/freescale/gianfar.c
index 6b0c4775cd0d..fb29d049f4e1 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -892,12 +892,12 @@ static int gfar_of_init(struct platform_device *o=
fdev, struct net_device **pdev)
 	/* In the case of a fixed PHY, the DT node associated
 	 * to the PHY is the Ethernet MAC DT node.
 	 */
-	if (of_phy_is_fixed_link(np)) {
+	if (!priv->phy_node && of_phy_is_fixed_link(np)) {
 		err =3D of_phy_register_fixed_link(np);
 		if (err)
 			goto err_grp_init;
=20
-		priv->phy_node =3D np;
+		priv->phy_node =3D of_node_get(np);
 	}
=20
 	/* Find the TBI PHY.  If it's not there, we don't support SGMII */
--=20
2.0.1
