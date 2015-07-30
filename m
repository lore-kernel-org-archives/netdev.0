From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Thu, 30 Jul 2015 10:15:48 -0500
Message-ID: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ksz9031 has a behavior where it will clear the interrupt enable bits
when leaving power down.  To work around this, make sure the interrupt
bits are in the state they are expected to be when resuming.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---

Changes for V2: Actually make sure it compiles this time.

---
 drivers/net/phy/micrel.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 499185e..9774582 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -447,6 +447,22 @@ static int ksz9031_center_flp_timing(struct phy_device *phydev)
 	return genphy_restart_aneg(phydev);
 }
 
+static int ksz9031_resume(struct phy_device *phydev)
+{
+	int result;
+
+	result = genphy_resume(phydev);
+
+	if (result)
+		return result;
+
+	/* This phy will reset interrupt enables when leaving power down */
+	if (PHY_INTERRUPT_ENABLED & phydev->interrupts)
+		result = kszphy_config_intr(phydev);
+
+	return result;
+}
+
 static int ksz9031_config_init(struct phy_device *phydev)
 {
 	const struct device *dev = &phydev->dev;
@@ -776,7 +792,7 @@ static struct phy_driver ksphy_driver[] = {
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
 	.suspend	= genphy_suspend,
-	.resume		= genphy_resume,
+	.resume		= ksz9031_resume,
 	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
-- 
1.7.10.4
