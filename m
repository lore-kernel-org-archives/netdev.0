From: Alexandru Gagniuc <alex.g@adaptrum.com>
Subject: [PATCH v2] net/phy/vitesse: Configure RGMII skew on VSC8601, if needed
Date: Wed, 16 Nov 2016 01:02:33 -0800
Message-ID: <1479286953-11481-1-git-send-email-alex.g@adaptrum.com>
References: <20161115.221217.2076182289174952941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, Alexandru Gagniuc <alex.g@adaptrum.com>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115.221217.2076182289174952941.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With RGMII, we need a 1.5 to 2ns skew between clock and data lines. The
VSC8601 can handle this internally. While the VSC8601 can set more
fine-grained delays, the standard skew settings work out of the box.
The same heuristic is used to determine when this skew should be enabled
as in vsc824x_config_init().

Tested on custom board with AM3352 SOC and VSC801 PHY.

Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
---
Changes since v1:
 * Added comment detailing applicability to different RGMII interfaces.

 drivers/net/phy/vitesse.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 2e37eb3..24b4a09 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -62,6 +62,10 @@
 /* Vitesse Extended Page Access Register */
 #define MII_VSC82X4_EXT_PAGE_ACCESS	0x1f
 
+/* Vitesse VSC8601 Extended PHY Control Register 1 */
+#define MII_VSC8601_EPHY_CTL		0x17
+#define MII_VSC8601_EPHY_CTL_RGMII_SKEW	(1 << 8)
+
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8514			0x00070670
@@ -111,6 +115,34 @@ static int vsc824x_config_init(struct phy_device *phydev)
 	return err;
 }
 
+/* This adds a skew for both TX and RX clocks, so the skew should only be
+ * applied to "rgmii-id" interfaces. It may not work as expected
+ * on "rgmii-txid", "rgmii-rxid" or "rgmii" interfaces. */
+static int vsc8601_add_skew(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = phy_read(phydev, MII_VSC8601_EPHY_CTL);
+	if (ret < 0)
+		return ret;
+
+	ret |= MII_VSC8601_EPHY_CTL_RGMII_SKEW;
+	return phy_write(phydev, MII_VSC8601_EPHY_CTL, ret);
+}
+
+static int vsc8601_config_init(struct phy_device *phydev)
+{
+	int ret = 0;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+		ret = vsc8601_add_skew(phydev);
+
+	if (ret < 0)
+		return ret;
+
+	return genphy_config_init(phydev);
+}
+
 static int vsc824x_ack_interrupt(struct phy_device *phydev)
 {
 	int err = 0;
@@ -275,7 +307,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id_mask    = 0x000ffff0,
 	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_INTERRUPT,
-	.config_init    = &genphy_config_init,
+	.config_init    = &vsc8601_config_init,
 	.config_aneg    = &genphy_config_aneg,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
-- 
2.7.4
