From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net/phy: micrel: Add workaround for bad autoneg
Date: Wed, 21 Oct 2015 14:17:04 -0500
Message-ID: <1445455024-5519-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Very rarely, the KSZ9031 will appear to complete autonegotiation, but
will drop all traffic afterwards.  When this happens, the idle error
count will read 0xFF after autonegotiation completes.  Reset the PHY
when in that state.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/phy/micrel.c |   23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 499185e..cf6312f 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -514,6 +514,27 @@ static int ksz8873mll_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+static int ksz9031_read_status(struct phy_device *phydev)
+{
+	int err;
+	int regval;
+
+	err = genphy_read_status(phydev);
+	if (err)
+		return err;
+
+	/* Make sure the PHY is not broken. Read idle error count,
+	 * and reset the PHY if it is maxed out.
+	 */
+	regval = phy_read(phydev, MII_STAT1000);
+	if ((regval & 0xFF) == 0xFF) {
+		phy_init_hw(phydev);
+		phydev->link = 0;
+	}
+
+	return 0;
+}
+
 static int ksz8873mll_config_aneg(struct phy_device *phydev)
 {
 	return 0;
@@ -772,7 +793,7 @@ static struct phy_driver ksphy_driver[] = {
 	.driver_data	= &ksz9021_type,
 	.config_init	= ksz9031_config_init,
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= ksz9031_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.suspend	= genphy_suspend,
-- 
1.7.10.4
