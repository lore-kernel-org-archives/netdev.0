From: Wenyou Yang <wenyou.yang@atmel.com>
Subject: [PATCH v2] net: phy: micrel: Add specific suspend
Date: Fri, 5 Aug 2016 14:35:41 +0800
Message-ID: <1470378941-12387-1-git-send-email-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Wenyou Yang <wenyou.yang@atmel.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable all interrupts when suspend, they will be enabled
when resume. Otherwise, the suspend/resume process will be
blocked occasionally.

Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2:
 - Use fairly generic phydrv->config_intr() with
   PHY_INTERRUPT_DISABLED, then call genphy_suspend().
 - Modify kszphy_resume() with PHY_INTERRUPT_ENABLED accordingly.
 - Add static attribute for kszphy_suspend().

 drivers/net/phy/micrel.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8fefc..b598d46 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -647,17 +647,28 @@ static void kszphy_get_stats(struct phy_device *phydev,
 		data[i] = kszphy_get_stat(phydev, i);
 }
 
-static int kszphy_resume(struct phy_device *phydev)
+static int kszphy_suspend(struct phy_device *phydev)
 {
-	int value;
+	/* Disable PHY Interrupts */
+	if (phy_interrupt_is_valid(phydev)) {
+		phydev->interrupts = PHY_INTERRUPT_DISABLED;
+		if (phydev->drv->config_intr)
+			phydev->drv->config_intr(phydev);
+	}
 
-	mutex_lock(&phydev->lock);
+	return genphy_suspend(phydev);
+}
 
-	value = phy_read(phydev, MII_BMCR);
-	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
+static int kszphy_resume(struct phy_device *phydev)
+{
+	genphy_resume(phydev);
 
-	kszphy_config_intr(phydev);
-	mutex_unlock(&phydev->lock);
+	/* Enable PHY Interrupts */
+	if (phy_interrupt_is_valid(phydev)) {
+		phydev->interrupts = PHY_INTERRUPT_ENABLED;
+		if (phydev->drv->config_intr)
+			phydev->drv->config_intr(phydev);
+	}
 
 	return 0;
 }
@@ -870,7 +881,7 @@ static struct phy_driver ksphy_driver[] = {
 	.get_sset_count = kszphy_get_sset_count,
 	.get_strings	= kszphy_get_strings,
 	.get_stats	= kszphy_get_stats,
-	.suspend	= genphy_suspend,
+	.suspend	= kszphy_suspend,
 	.resume		= kszphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8061,
-- 
2.7.4
