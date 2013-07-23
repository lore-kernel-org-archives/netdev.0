From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH] net: sun4i: fix timeout check
Date: Mon, 22 Jul 2013 22:09:18 -0300
Message-ID: <1374541758-2025-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
To: Maxime Ripard <maxime.ripard@free-electrons.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zetta.elopez.com.ar ([199.30.59.35]:54134 "EHLO
	zetta.elopez.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab3GWBJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current timeout check is comparing two constant values, so it won't
ever detect a timeout. This patch reworks the affected code a bit so it
has a chance at detecting timeouts correctly.

Signed-off-by: Emilio L=C3=B3pez <emilio@elopez.com.ar>
---
 drivers/net/phy/mdio-sun4i.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.=
c
index 61d3f4e..7f25e49 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -40,7 +40,7 @@ struct sun4i_mdio_data {
 static int sun4i_mdio_read(struct mii_bus *bus, int mii_id, int regnum=
)
 {
 	struct sun4i_mdio_data *data =3D bus->priv;
-	unsigned long start_jiffies;
+	unsigned long timeout_jiffies;
 	int value;
=20
 	/* issue the phy address and reg */
@@ -49,10 +49,9 @@ static int sun4i_mdio_read(struct mii_bus *bus, int =
mii_id, int regnum)
 	writel(0x1, data->membase + EMAC_MAC_MCMD_REG);
=20
 	/* Wait read complete */
-	start_jiffies =3D jiffies;
+	timeout_jiffies =3D jiffies + MDIO_TIMEOUT;
 	while (readl(data->membase + EMAC_MAC_MIND_REG) & 0x1) {
-		if (time_after(start_jiffies,
-			       start_jiffies + MDIO_TIMEOUT))
+		if (time_is_before_jiffies(timeout_jiffies))
 			return -ETIMEDOUT;
 		msleep(1);
 	}
@@ -69,7 +68,7 @@ static int sun4i_mdio_write(struct mii_bus *bus, int =
mii_id, int regnum,
 			    u16 value)
 {
 	struct sun4i_mdio_data *data =3D bus->priv;
-	unsigned long start_jiffies;
+	unsigned long timeout_jiffies;
=20
 	/* issue the phy address and reg */
 	writel((mii_id << 8) | regnum, data->membase + EMAC_MAC_MADR_REG);
@@ -77,10 +76,9 @@ static int sun4i_mdio_write(struct mii_bus *bus, int=
 mii_id, int regnum,
 	writel(0x1, data->membase + EMAC_MAC_MCMD_REG);
=20
 	/* Wait read complete */
-	start_jiffies =3D jiffies;
+	timeout_jiffies =3D jiffies + MDIO_TIMEOUT;
 	while (readl(data->membase + EMAC_MAC_MIND_REG) & 0x1) {
-		if (time_after(start_jiffies,
-			       start_jiffies + MDIO_TIMEOUT))
+		if (time_is_before_jiffies(timeout_jiffies))
 			return -ETIMEDOUT;
 		msleep(1);
 	}
--=20
1.8.3.3
