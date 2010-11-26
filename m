From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
Date: Fri, 26 Nov 2010 19:54:30 +0800
Message-ID: <1290772470-23713-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realtek.com.tw ([60.250.210.236]:2781 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab0KZL7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 06:59:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct the binary code (Low pass filter & DLY_CAP fine tune from uC).
The incorrect ram code would make the nic working abnormally.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |  141 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 113 insertions(+), 28 deletions(-)
 mode change 100644 => 100755 drivers/net/r8169.c

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
old mode 100644
new mode 100755
index 7d33ef4..c069381
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1718,6 +1718,7 @@ static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
 static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 {
 	static const struct phy_reg phy_reg_init_0[] = {
+		/* Channel Estimation */
 		{ 0x1f, 0x0001 },
 		{ 0x06, 0x4064 },
 		{ 0x07, 0x2863 },
@@ -1734,19 +1735,33 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x12, 0xf49f },
 		{ 0x13, 0x070b },
 		{ 0x1a, 0x05ad },
-		{ 0x14, 0x94c0 }
-	};
-	static const struct phy_reg phy_reg_init_1[] = {
+		{ 0x14, 0x94c0 },
+
+		/*
+		 * Tx Error Issue
+		 * enhance line driver power
+		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
 		{ 0x1f, 0x0005 },
 		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 }
+		{ 0x06, 0x5561 },
+
+		/*
+		 * Can not link to 1Gbps with bad cable
+		 * Decrease SNR threshold form 21.07dB to 19.04dB
+		 */
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf880 }
 	};
 	static const struct phy_reg phy_reg_init_2[] = {
+		/* Low pass filter & DLY_CAP fine tune from uC */
 		{ 0x1f, 0x0005 },
-		{ 0x05, 0xffc2 },
-		{ 0x1f, 0x0005 },
+		{ 0x05, 0xfff6 },
+		{ 0x06, 0x0080 },
 		{ 0x05, 0x8000 },
 		{ 0x06, 0xf8f9 },
 		{ 0x06, 0xfaef },
@@ -2084,29 +2099,51 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		{ 0x06, 0xff01 },
 		{ 0x06, 0x4edd },
 		{ 0x06, 0xff01 },
-		{ 0x05, 0x83d4 },
-		{ 0x06, 0x8000 },
+		{ 0x06, 0xf8fa },
+		{ 0x06, 0xfbef },
+		{ 0x06, 0x79bf },
+		{ 0x06, 0xf822 },
+		{ 0x06, 0xd819 },
+		{ 0x06, 0xd958 },
+		{ 0x06, 0x849f },
+		{ 0x06, 0x09bf },
+		{ 0x06, 0x82be },
+		{ 0x06, 0xd682 },
+		{ 0x06, 0xc602 },
+		{ 0x06, 0x014f },
+		{ 0x06, 0xef97 },
+		{ 0x06, 0xfffe },
+		{ 0x06, 0xfc05 },
+		{ 0x06, 0x17ff },
+		{ 0x06, 0xfe01 },
+		{ 0x06, 0x1700 },
+		{ 0x06, 0x0102 },
 		{ 0x05, 0x83d8 },
 		{ 0x06, 0x8051 },
-		{ 0x02, 0x6010 },
+		{ 0x05, 0x83d6 },
+		{ 0x06, 0x82a0 },
+		{ 0x05, 0x83d4 },
+		{ 0x06, 0x8000 },
+		{ 0x02, 0x2010 },
 		{ 0x03, 0xdc00 },
+		{ 0x1f, 0x0000 },
+		{ 0x0b, 0x0600 },
+		{ 0x1f, 0x0005 },
 		{ 0x05, 0xfff6 },
 		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 },
 		{ 0x1f, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
+	/*
+	 * Rx Error Issue
+	 * Fine Tune Switching regulator parameter
+	 */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x0b, 0x0010, 0x00ef);
 	mdio_plus_minus(ioaddr, 0x0c, 0xa200, 0x5d00);
 
-	rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
-
 	if (rtl8168d_efuse_read(ioaddr, 0x01) == 0xb1) {
 		static const struct phy_reg phy_reg_init[] = {
 			{ 0x1f, 0x0002 },
@@ -2147,20 +2184,28 @@ static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
 		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
+	/* RSET couple improve */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_patch(ioaddr, 0x0d, 0x0300);
 	mdio_patch(ioaddr, 0x0f, 0x0010);
 
+	/* Fine tune PLL performance */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
 	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
 
-	rtl_phy_write(ioaddr, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+	mdio_write(ioaddr, 0x1F, 0x0005);
+	mdio_write(ioaddr, 0x05, 0x001B);
+	if (mdio_read(ioaddr, 0x06) == 0xBF00)
+		rtl_phy_write(ioaddr, phy_reg_init_2, ARRAY_SIZE(phy_reg_init_2));
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 {
 	static const struct phy_reg phy_reg_init_0[] = {
+		/* Channel Estimation */
 		{ 0x1f, 0x0001 },
 		{ 0x06, 0x4064 },
 		{ 0x07, 0x2863 },
@@ -2179,16 +2224,31 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1a, 0x05ad },
 		{ 0x14, 0x94c0 },
 
+		/*
+		 * Tx Error Issue
+		 * enhance line driver power
+		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
 		{ 0x1f, 0x0005 },
 		{ 0x05, 0x8332 },
-		{ 0x06, 0x5561 }
+		{ 0x06, 0x5561 },
+
+		/*
+		 * Can not link to 1Gbps with bad cable
+		 * Decrease SNR threshold form 21.07dB to 19.04dB
+		 */
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf880 }
 	};
 	static const struct phy_reg phy_reg_init_1[] = {
+		/* Low pass filter & DLY_CAP fine tune from uC */
 		{ 0x1f, 0x0005 },
-		{ 0x05, 0xffc2 },
-		{ 0x1f, 0x0005 },
+		{ 0x05, 0xfff6 },
+		{ 0x06, 0x0080 },
 		{ 0x05, 0x8000 },
 		{ 0x06, 0xf8f9 },
 		{ 0x06, 0xfaee },
@@ -2485,16 +2545,37 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		{ 0x06, 0xdfff },
 		{ 0x06, 0x014e },
 		{ 0x06, 0xddff },
-		{ 0x06, 0x0100 },
+		{ 0x06, 0x01f8 },
+		{ 0x06, 0xfafb },
+		{ 0x06, 0xef79 },
+		{ 0x06, 0xbff8 },
+		{ 0x06, 0x22d8 },
+		{ 0x06, 0x19d9 },
+		{ 0x06, 0x5884 },
+		{ 0x06, 0x9f09 },
+		{ 0x06, 0xbf82 },
+		{ 0x06, 0x6dd6 },
+		{ 0x06, 0x8275 },
+		{ 0x06, 0x0201 },
+		{ 0x06, 0x4fef },
+		{ 0x06, 0x97ff },
+		{ 0x06, 0xfefc },
+		{ 0x06, 0x0517 },
+		{ 0x06, 0xfffe },
+		{ 0x06, 0x0117 },
+		{ 0x06, 0x0001 },
+		{ 0x06, 0x0200 },
 		{ 0x05, 0x83d8 },
 		{ 0x06, 0x8000 },
+		{ 0x05, 0x83d6 },
+		{ 0x06, 0x824f },
+		{ 0x02, 0x2010 },
 		{ 0x03, 0xdc00 },
+		{ 0x1f, 0x0000 },
+		{ 0x0b, 0x0600 },
+		{ 0x1f, 0x0005 },
 		{ 0x05, 0xfff6 },
 		{ 0x06, 0x00fc },
-		{ 0x1f, 0x0000 },
-
-		{ 0x1f, 0x0000 },
-		{ 0x0d, 0xf880 },
 		{ 0x1f, 0x0000 }
 	};
 
@@ -2540,17 +2621,21 @@ static void rtl8168d_2_hw_phy_config(void __iomem *ioaddr)
 		rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 	}
 
+	/* Fine tune PLL performance */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_plus_minus(ioaddr, 0x02, 0x0100, 0x0600);
 	mdio_plus_minus(ioaddr, 0x03, 0x0000, 0xe000);
 
-	mdio_write(ioaddr, 0x1f, 0x0001);
-	mdio_write(ioaddr, 0x17, 0x0cc0);
-
+	/* Switching regulator Slew rate */
 	mdio_write(ioaddr, 0x1f, 0x0002);
 	mdio_patch(ioaddr, 0x0f, 0x0017);
 
-	rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+	mdio_write(ioaddr, 0x1F, 0x0005);
+	mdio_write(ioaddr, 0x05, 0x001B);
+	if (mdio_read(ioaddr, 0x06) == 0xB300)
+		rtl_phy_write(ioaddr, phy_reg_init_1, ARRAY_SIZE(phy_reg_init_1));
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8168d_3_hw_phy_config(void __iomem *ioaddr)
-- 
1.7.3.2

