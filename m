From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH v2 3/5] net: phy: dp83848: Reorganize code for readability and safety
Date: Sun, 7 Feb 2016 11:47:19 -0600
Message-ID: <1454867241-20928-4-git-send-email-afd@ti.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:52423 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbcBGRra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 12:47:30 -0500
In-Reply-To: <1454867241-20928-1-git-send-email-afd@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorganize code by moving the desired interrupt mask definition
out of function. Also rearrange the enable/disable interrupt function
to prevent accidental over-writing of values in registers.

Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index d4686d5f..20d3b9d 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -37,6 +37,12 @@
 #define DP83848_MISR_ED_INT_EN		BIT(6) /* Energy detect */
 #define DP83848_MISR_LQM_INT_EN		BIT(7) /* Link Quality Monitor */
 
+#define DP83848_INT_EN_MASK		\
+	(DP83848_MISR_ANC_INT_EN |	\
+	 DP83848_MISR_DUP_INT_EN |	\
+	 DP83848_MISR_SPD_INT_EN |	\
+	 DP83848_MISR_LINK_INT_EN)
+
 static int dp83848_ack_interrupt(struct phy_device *phydev)
 {
 	int err = phy_read(phydev, DP83848_MISR);
@@ -46,23 +52,24 @@ static int dp83848_ack_interrupt(struct phy_device *phydev)
 
 static int dp83848_config_intr(struct phy_device *phydev)
 {
-	int err;
+	int control, ret;
+
+	control = phy_read(phydev, DP83848_MICR);
+	if (control < 0)
+		return control;
 
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
-		err = phy_write(phydev, DP83848_MICR,
-				DP83848_MICR_INT_OE |
-				DP83848_MICR_INTEN);
-		if (err < 0)
-			return err;
-
-		return phy_write(phydev, DP83848_MISR,
-				 DP83848_MISR_ANC_INT_EN |
-				 DP83848_MISR_DUP_INT_EN |
-				 DP83848_MISR_SPD_INT_EN |
-				 DP83848_MISR_LINK_INT_EN);
+		control |= DP83848_MICR_INT_OE;
+		control |= DP83848_MICR_INTEN;
+
+		ret = phy_write(phydev, DP83848_MISR, DP83848_INT_EN_MASK);
+		if (ret < 0)
+			return ret;
+	} else {
+		control &= ~DP83848_MICR_INTEN;
 	}
 
-	return phy_write(phydev, DP83848_MICR, 0x0);
+	return phy_write(phydev, DP83848_MICR, control);
 }
 
 static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
-- 
2.7.0
