From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: bcmgenet: fix reference counting for phy node
Date: Thu,  7 Aug 2014 22:53:40 +0200
Message-ID: <1407444820-16250-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53263 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962AbaHGUxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 16:53:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46or the fixed phy setup make sure to not overwrite a valid value of
phy_dn (that is holding a reference to a phy-handle) and also acquire a
reference to the MAC node to consistently return with the phy_dn pointe=
r
holding a reference.

Also add the corresponding of_node_put in the error path and the remove
function.

=46ixes: 9abf0c2b717a ("net: bcmgenet: use the new fixed PHY helpers")
=46ixes: aa09677cba42 ("net: bcmgenet: add MDIO routines")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net=
/ethernet/broadcom/genet/bcmmii.c
index add8d8596084..cdb28dd7d19d 100644
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
+		priv->phy_dn =3D of_node_get(dn);
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
--=20
2.0.1
