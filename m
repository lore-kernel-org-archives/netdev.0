From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 1/2] phy: micrel: Ensure interrupts are reenabled on resume
Date: Fri, 26 Feb 2016 19:18:22 +0100
Message-ID: <1456510703-31559-2-git-send-email-alexandre.belloni@free-electrons.com>
References: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least on ksz8081, when getting back from power down, interrupts are
disabled. ensure they are reenabled if they were previously enabled.

This fixes resuming which is failing on the xplained boards from atmel
since 321beec5047a (net: phy: Use interrupts when available in NOLINK
state)

Fixes: 321beec5047a (net: phy: Use interrupts when available in NOLINK state)
Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/phy/micrel.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 03833dbfca67..a5e265b2bbfb 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -635,6 +635,21 @@ static void kszphy_get_stats(struct phy_device *phydev,
 		data[i] = kszphy_get_stat(phydev, i);
 }
 
+static int kszphy_resume(struct phy_device *phydev)
+{
+	int value;
+
+	mutex_lock(&phydev->lock);
+
+	value = phy_read(phydev, MII_BMCR);
+	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
+
+	kszphy_config_intr(phydev);
+	mutex_unlock(&phydev->lock);
+
+	return 0;
+}
+
 static int kszphy_probe(struct phy_device *phydev)
 {
 	const struct kszphy_type *type = phydev->drv->driver_data;
@@ -844,7 +859,7 @@ static struct phy_driver ksphy_driver[] = {
 	.get_strings	= kszphy_get_strings,
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
-	.resume		= genphy_resume,
+	.resume		= kszphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8061,
 	.name		= "Micrel KSZ8061",
-- 
2.7.0
