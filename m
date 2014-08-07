From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH v4] net: gianfar: fix reference counting for phy_node
Date: Thu,  7 Aug 2014 22:17:07 +0200
Message-ID: <1407442627-1508-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1407441707-27172-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49007 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbaHGURN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 16:17:13 -0400
In-Reply-To: <1407441707-27172-1-git-send-email-u.kleine-koenig@pengutronix.de>
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
Hello,

I don't know how, but somehow I managed to add unrelated stuff to v3. S=
o:

Changes since v3:

 - Reset patch to the v2 one.

Sorry for the patch flood, I hope I got it right this time.

Best regards
Uwe

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
