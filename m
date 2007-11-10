From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/13] tg3: 5784 / 5764 DMA engine lockup fix
Date: Fri, 09 Nov 2007 16:38:46 -0800
Message-ID: <1194655126.5745.266.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3326 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbXKJAjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

5784 and 5764 devices lock up when the link speed is 10Mbps, the CPMU
link speed mode is enabled, and the MAC clock is running at 1.5Mhz.  The
fix is to run the MAC clock at faster speeds.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 833cb9b..b865c5d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6369,6 +6369,21 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		val = tr32(TG3_CPMU_CTRL);
 		val &= ~(CPMU_CTRL_LINK_AWARE_MODE | CPMU_CTRL_LINK_IDLE_MODE);
 		tw32(TG3_CPMU_CTRL, val);
+
+		val = tr32(TG3_CPMU_LSPD_10MB_CLK);
+		val &= ~CPMU_LSPD_10MB_MACCLK_MASK;
+		val |= CPMU_LSPD_10MB_MACCLK_6_25;
+		tw32(TG3_CPMU_LSPD_10MB_CLK, val);
+
+		val = tr32(TG3_CPMU_LNK_AWARE_PWRMD);
+		val &= ~CPMU_LNK_AWARE_MACCLK_MASK;
+		val |= CPMU_LNK_AWARE_MACCLK_6_25;
+		tw32(TG3_CPMU_LNK_AWARE_PWRMD, val);
+
+		val = tr32(TG3_CPMU_HST_ACC);
+		val &= ~CPMU_HST_ACC_MACCLK_MASK;
+		val |= CPMU_HST_ACC_MACCLK_6_25;
+		tw32(TG3_CPMU_HST_ACC, val);
 	}
 
 	/* This works around an issue with Athlon chipsets on
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 4659697..c6aad49 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -857,13 +857,24 @@
 #define  CPMU_CTRL_LINK_IDLE_MODE	 0x00000200
 #define  CPMU_CTRL_LINK_AWARE_MODE	 0x00000400
 #define  CPMU_CTRL_LINK_SPEED_MODE	 0x00004000
-/* 0x3604 --> 0x360c unused */
+#define TG3_CPMU_LSPD_10MB_CLK		0x00003604
+#define  CPMU_LSPD_10MB_MACCLK_MASK	 0x001f0000
+#define  CPMU_LSPD_10MB_MACCLK_6_25	 0x00130000
+/* 0x3608 --> 0x360c unused */
 
 #define TG3_CPMU_LSPD_1000MB_CLK	0x0000360c
 #define  CPMU_LSPD_1000MB_MACCLK_62_5	 0x00000000
 #define  CPMU_LSPD_1000MB_MACCLK_12_5	 0x00110000
 #define  CPMU_LSPD_1000MB_MACCLK_MASK	 0x001f0000
-/* 0x3610 --> 0x365c unused */
+#define TG3_CPMU_LNK_AWARE_PWRMD	0x00003610
+#define  CPMU_LNK_AWARE_MACCLK_MASK	 0x001f0000
+#define  CPMU_LNK_AWARE_MACCLK_6_25	 0x00130000
+/* 0x3614 --> 0x361c unused */
+
+#define TG3_CPMU_HST_ACC		0x0000361c
+#define  CPMU_HST_ACC_MACCLK_MASK	 0x001f0000
+#define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
+/* 0x3620 --> 0x365c unused */
 
 #define TG3_CPMU_MUTEX_REQ		0x0000365c
 #define  CPMU_MUTEX_REQ_DRIVER		 0x00001000


