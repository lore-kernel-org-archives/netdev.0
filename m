From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: [Patch 1/1] net/phy: Add interrupt support for dp83640 phy.
Date: Tue,  4 Dec 2012 21:21:38 +0100
Message-ID: <1354652498-16573-1-git-send-email-stephan.gatzka@gmail.com>
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54493 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2LDUXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:23:08 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1836361bkw.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:23:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added functions for ack_interrupt and config_intr. Tested on an mpc5200b
powerpc board.

Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>
---
 drivers/net/phy/dp83640.c |   78 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 77 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 24e05c4..7490b6c 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -48,6 +48,21 @@
 #define CAL_TRIGGER	7
 #define PER_TRIGGER	6
 
+#define MII_DP83640_MICR 0x11
+#define MII_DP83640_MISR 0x12
+
+#define MII_DP83640_MICR_OE 0x1
+#define MII_DP83640_MICR_IE 0x2
+
+#define MII_DP83640_MISR_RHF_INT_EN 0x01
+#define MII_DP83640_MISR_FHF_INT_EN 0x02
+#define MII_DP83640_MISR_ANC_INT_EN 0x04
+#define MII_DP83640_MISR_DUP_INT_EN 0x08
+#define MII_DP83640_MISR_SPD_INT_EN 0x10
+#define MII_DP83640_MISR_LINK_INT_EN 0x20
+#define MII_DP83640_MISR_ED_INT_EN 0x40
+#define MII_DP83640_MISR_LQ_INT_EN 0x80
+
 /* phyter seems to miss the mark by 16 ns */
 #define ADJTIME_FIX	16
 
@@ -1043,6 +1058,65 @@ static void dp83640_remove(struct phy_device *phydev)
 	kfree(dp83640);
 }
 
+static int dp83640_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_DP83640_MISR);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dp83640_config_intr(struct phy_device *phydev)
+{
+	int micr;
+	int misr;
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		misr = phy_read(phydev, MII_DP83640_MISR);
+		if (misr < 0)
+			return misr;
+		misr |=
+			(MII_DP83640_MISR_ANC_INT_EN |
+			MII_DP83640_MISR_DUP_INT_EN |
+			MII_DP83640_MISR_SPD_INT_EN |
+			MII_DP83640_MISR_LINK_INT_EN);
+		err = phy_write(phydev, MII_DP83640_MISR, misr);
+		if (err < 0)
+			return err;
+
+		micr = phy_read(phydev, MII_DP83640_MICR);
+		if (micr < 0)
+			return micr;
+		micr |=
+			(MII_DP83640_MICR_OE |
+			MII_DP83640_MICR_IE);
+		return phy_write(phydev, MII_DP83640_MICR, micr);
+	} else {
+		micr = phy_read(phydev, MII_DP83640_MICR);
+		if (micr < 0)
+			return micr;
+		micr &=
+			~(MII_DP83640_MICR_OE |
+			MII_DP83640_MICR_IE);
+		err = phy_write(phydev, MII_DP83640_MICR, micr);
+		if (err < 0)
+			return err;
+
+		misr = phy_read(phydev, MII_DP83640_MISR);
+		if (misr < 0)
+			return misr;
+		misr &=
+			~(MII_DP83640_MISR_ANC_INT_EN |
+			MII_DP83640_MISR_DUP_INT_EN |
+			MII_DP83640_MISR_SPD_INT_EN |
+			MII_DP83640_MISR_LINK_INT_EN);
+		return phy_write(phydev, MII_DP83640_MISR, misr);
+	}
+}
+
 static int dp83640_hwtstamp(struct phy_device *phydev, struct ifreq *ifr)
 {
 	struct dp83640_private *dp83640 = phydev->priv;
@@ -1253,11 +1327,13 @@ static struct phy_driver dp83640_driver = {
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "NatSemi DP83640",
 	.features	= PHY_BASIC_FEATURES,
-	.flags		= 0,
+	.flags		= PHY_HAS_INTERRUPT,
 	.probe		= dp83640_probe,
 	.remove		= dp83640_remove,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt  = dp83640_ack_interrupt,
+	.config_intr    = dp83640_config_intr,
 	.ts_info	= dp83640_ts_info,
 	.hwtstamp	= dp83640_hwtstamp,
 	.rxtstamp	= dp83640_rxtstamp,
-- 
1.7.9.5
