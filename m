From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH v2] net: gianfar: fix reference counting for phy_node
Date: Thu,  7 Aug 2014 21:41:46 +0200
Message-ID: <1407440506-20028-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1407440131-15517-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58493 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaHGTl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 15:41:57 -0400
In-Reply-To: <1407440131-15517-1-git-send-email-u.kleine-koenig@pengutronix.de>
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

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Changes since (implicit) v1:

 - really do both fixes mentioned in the commit log

 drivers/net/ethernet/freescale/gianfar.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
