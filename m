From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 02/13] net: phy: split out PHY speed and duplex string
 generation
Date: Tue, 25 Jul 2017 15:02:42 +0100
Message-ID: <E1da0Q6-0007Kv-Mc@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50840 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdGYOCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:02:46 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other code would like to make use of this, so make the speed and duplex
string generation visible, and place it in a separate file.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 49 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c      | 38 +----------------------------------
 include/linux/phy.h        |  3 +++
 3 files changed, 53 insertions(+), 37 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index 6739b738bbaf..bf01a24f21ce 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -9,6 +9,55 @@
 #include <linux/export.h>
 #include <linux/phy.h>
 
+const char *phy_speed_to_str(int speed)
+{
+	switch (speed) {
+	case SPEED_10:
+		return "10Mbps";
+	case SPEED_100:
+		return "100Mbps";
+	case SPEED_1000:
+		return "1Gbps";
+	case SPEED_2500:
+		return "2.5Gbps";
+	case SPEED_5000:
+		return "5Gbps";
+	case SPEED_10000:
+		return "10Gbps";
+	case SPEED_14000:
+		return "14Gbps";
+	case SPEED_20000:
+		return "20Gbps";
+	case SPEED_25000:
+		return "25Gbps";
+	case SPEED_40000:
+		return "40Gbps";
+	case SPEED_50000:
+		return "50Gbps";
+	case SPEED_56000:
+		return "56Gbps";
+	case SPEED_100000:
+		return "100Gbps";
+	case SPEED_UNKNOWN:
+		return "Unknown";
+	default:
+		return "Unsupported (update phy-core.c)";
+	}
+}
+EXPORT_SYMBOL_GPL(phy_speed_to_str);
+
+const char *phy_duplex_to_str(unsigned int duplex)
+{
+	if (duplex == DUPLEX_HALF)
+		return "Half";
+	if (duplex == DUPLEX_FULL)
+		return "Full";
+	if (duplex == DUPLEX_UNKNOWN)
+		return "Unknown";
+	return "Unsupported (update phy-core.c)";
+}
+EXPORT_SYMBOL_GPL(phy_duplex_to_str);
+
 static void mmd_phy_indirect(struct mii_bus *bus, int phy_addr, int devad,
 			     u16 regnum)
 {
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 0fe478002908..f128a538388f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -39,42 +39,6 @@
 
 #include <asm/irq.h>
 
-static const char *phy_speed_to_str(int speed)
-{
-	switch (speed) {
-	case SPEED_10:
-		return "10Mbps";
-	case SPEED_100:
-		return "100Mbps";
-	case SPEED_1000:
-		return "1Gbps";
-	case SPEED_2500:
-		return "2.5Gbps";
-	case SPEED_5000:
-		return "5Gbps";
-	case SPEED_10000:
-		return "10Gbps";
-	case SPEED_14000:
-		return "14Gbps";
-	case SPEED_20000:
-		return "20Gbps";
-	case SPEED_25000:
-		return "25Gbps";
-	case SPEED_40000:
-		return "40Gbps";
-	case SPEED_50000:
-		return "50Gbps";
-	case SPEED_56000:
-		return "56Gbps";
-	case SPEED_100000:
-		return "100Gbps";
-	case SPEED_UNKNOWN:
-		return "Unknown";
-	default:
-		return "Unsupported (update phy.c)";
-	}
-}
-
 #define PHY_STATE_STR(_state)			\
 	case PHY_##_state:			\
 		return __stringify(_state);	\
@@ -110,7 +74,7 @@ void phy_print_status(struct phy_device *phydev)
 		netdev_info(phydev->attached_dev,
 			"Link is Up - %s/%s - flow control %s\n",
 			phy_speed_to_str(phydev->speed),
-			DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
+			phy_duplex_to_str(phydev->duplex),
 			phydev->pause ? "rx/tx" : "off");
 	} else	{
 		netdev_info(phydev->attached_dev, "Link is Down\n");
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2a9567bb8186..755793c29ad1 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -667,6 +667,9 @@ struct phy_fixup {
 	int (*run)(struct phy_device *phydev);
 };
 
+const char *phy_speed_to_str(int speed);
+const char *phy_duplex_to_str(unsigned int duplex);
+
 /**
  * phy_read_mmd - Convenience function for reading a register
  * from an MMD on a given PHY.
-- 
2.7.4
