From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH] net: phy: at803x: Register 'link_change_notify' only for
 AT8030
Date: Wed, 27 Apr 2016 13:34:25 +0200
Message-ID: <5720A3C1.2040401@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to register the callback introduced by
commit 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
for non faulty PHYs.

The check on the PHY ID is not necessary anymore and thus has been
removed from the callback implementation as well.

Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
 drivers/net/phy/at803x.c | 43 ++++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index b3ffaee..7fdc676 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -353,33 +353,32 @@ static void at803x_link_change_notify(struct phy_device *phydev)
 	struct at803x_priv *priv = phydev->priv;
 
 	/*
-	 * Conduct a hardware reset for AT8030 every time a link loss is
+	 * Conduct a hardware reset for AT8030 (this callback is only
+	 * registered for AT8030 at the moment) every time a link loss is
 	 * signalled. This is necessary to circumvent a hardware bug that
 	 * occurs when the cable is unplugged while TX packets are pending
 	 * in the FIFO. In such cases, the FIFO enters an error mode it
 	 * cannot recover from by software.
 	 */
-	if (phydev->drv->phy_id == ATH8030_PHY_ID) {
-		if (phydev->state == PHY_NOLINK) {
-			if (priv->gpiod_reset && !priv->phy_reset) {
-				struct at803x_context context;
-
-				at803x_context_save(phydev, &context);
-
-				gpiod_set_value(priv->gpiod_reset, 1);
-				msleep(1);
-				gpiod_set_value(priv->gpiod_reset, 0);
-				msleep(1);
-
-				at803x_context_restore(phydev, &context);
-
-				phydev_dbg(phydev, "%s(): phy was reset\n",
-					   __func__);
-				priv->phy_reset = true;
-			}
-		} else {
-			priv->phy_reset = false;
+	if (phydev->state == PHY_NOLINK) {
+		if (priv->gpiod_reset && !priv->phy_reset) {
+			struct at803x_context context;
+
+			at803x_context_save(phydev, &context);
+
+			gpiod_set_value(priv->gpiod_reset, 1);
+			msleep(1);
+			gpiod_set_value(priv->gpiod_reset, 0);
+			msleep(1);
+
+			at803x_context_restore(phydev, &context);
+
+			phydev_dbg(phydev, "%s(): phy was reset\n",
+				   __func__);
+			priv->phy_reset = true;
 		}
+	} else {
+		priv->phy_reset = false;
 	}
 }
 
@@ -391,7 +390,6 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id_mask		= 0xffffffef,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
-	.link_change_notify	= at803x_link_change_notify,
 	.set_wol		= at803x_set_wol,
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
@@ -427,7 +425,6 @@ static struct phy_driver at803x_driver[] = {
 	.phy_id_mask		= 0xffffffef,
 	.probe			= at803x_probe,
 	.config_init		= at803x_config_init,
-	.link_change_notify	= at803x_link_change_notify,
 	.set_wol		= at803x_set_wol,
 	.get_wol		= at803x_get_wol,
 	.suspend		= at803x_suspend,
-- 
2.1.4
