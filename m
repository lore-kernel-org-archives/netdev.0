From: Philippe Reynes <tremyfr@yahoo.fr>
Subject: [PATCH] net: phy: smsc: force all capable mode if the phy is started in powerdown mode
Date: Sat,  1 Dec 2012 21:44:49 +0100
Message-ID: <1354394689-28281-1-git-send-email-tremyfr@yahoo.fr>
Cc: otavio@ossystems.com.br, javier@dowhile0.org, jkosina@suse.cz,
	eric.jarrige@armadeus.org, julien.boibessot@armadeus.com,
	thomas.petazzoni@free-electrons.com,
	Philippe Reynes <tremyfr@yahoo.fr>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A SMSC PHY in power down mode can't be used.
If a SMSC PHY is in this mode in the config_init
stage, the mode "all capable" is set. So the PHY
could then be used.

Signed-off-by: Philippe Reynes <tremyfr@yahoo.fr>
---
 drivers/net/phy/smsc.c  |   27 ++++++++++++++++++++++++++-
 include/linux/smscphy.h |    5 +++++
 2 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 88e3991..63018d0 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -43,7 +43,32 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 
 static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+	/*
+	 * If the SMSC PHY is in power down mode, then set it
+	 * in all capable mode before using it.
+	 */
+	int rc = phy_read(phydev, MII_LAN83C185_SPECIAL_MODES);
+	if (rc < 0)
+		return rc;
+
+	if ((rc & MII_LAN83C185_MODE_MASK) == MII_LAN83C185_MODE_POWERDOWN) {
+		int timeout = 50000;
+
+		/* set "all capable" mode and reset the phy */
+		rc |= MII_LAN83C185_MODE_ALL;
+		phy_write(phydev, MII_LAN83C185_SPECIAL_MODES, rc);
+		phy_write(phydev, MII_BMCR, BMCR_RESET);
+
+		/* wait end of reset (max 500 ms) */
+		do {
+			udelay(10);
+			if (timeout-- == 0)
+				return -1;
+			rc = phy_read(phydev, MII_BMCR);
+		} while (rc & BMCR_RESET);
+	}
+
+	rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
 	if (rc < 0)
 		return rc;
 
diff --git a/include/linux/smscphy.h b/include/linux/smscphy.h
index ce718cb..f4bf16e 100644
--- a/include/linux/smscphy.h
+++ b/include/linux/smscphy.h
@@ -4,6 +4,7 @@
 #define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
 #define MII_LAN83C185_IM  30 /* Interrupt Mask */
 #define MII_LAN83C185_CTRL_STATUS 17 /* Mode/Status Register */
+#define MII_LAN83C185_SPECIAL_MODES 18 /* Special Modes Register */
 
 #define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
 #define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
@@ -22,4 +23,8 @@
 #define MII_LAN83C185_EDPWRDOWN (1 << 13) /* EDPWRDOWN */
 #define MII_LAN83C185_ENERGYON  (1 << 1)  /* ENERGYON */
 
+#define MII_LAN83C185_MODE_MASK      0xE0
+#define MII_LAN83C185_MODE_POWERDOWN 0xC0 /* Power Down mode */
+#define MII_LAN83C185_MODE_ALL       0xE0 /* All capable mode */
+
 #endif /* __LINUX_SMSCPHY_H__ */
-- 
1.7.4.4
