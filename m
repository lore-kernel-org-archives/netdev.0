From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v2 1/2] net: ethernet: bgmac: init sequence bug
Date: Fri,  3 Feb 2017 16:08:52 -0500
Message-ID: <1486156133-5639-2-git-send-email-jon.mason@broadcom.com>
References: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zac Schroff <zschroff@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zac Schroff <zschroff@broadcom.com>

Fix a bug in the 'bgmac' driver init sequence that blind writes for init
sequence where it should preserve most bits other than the ones it is
deliberately manipulating.

Signed-off-by: Zac Schroff <zschroff@broadcom.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Fixes: f6a95a24957 ("net: ethernet: bgmac: Add platform device support")
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 14 +++++++++-----
 drivers/net/ethernet/broadcom/bgmac.h          | 16 ++++++++++++++++
 2 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 6f736c1..a626dce 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -51,8 +51,7 @@ static void platform_bgmac_idm_write(struct bgmac *bgmac, u16 offset, u32 value)
 
 static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
 {
-	if ((bgmac_idm_read(bgmac, BCMA_IOCTL) &
-	     (BCMA_IOCTL_CLK | BCMA_IOCTL_FGC)) != BCMA_IOCTL_CLK)
+	if ((bgmac_idm_read(bgmac, BCMA_IOCTL) & BGMAC_CLK_EN) != BGMAC_CLK_EN)
 		return false;
 	if (bgmac_idm_read(bgmac, BCMA_RESET_CTL) & BCMA_RESET_CTL_RESET)
 		return false;
@@ -61,15 +60,20 @@ static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
 
 static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
 {
-	bgmac_idm_write(bgmac, BCMA_IOCTL,
-			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
+	u32 val;
+
+	val = bgmac_idm_read(bgmac, BCMA_IOCTL);
+	/* Some bits of BCMA_IOCTL set by HW/ATF and should not change */
+	val |= flags & ~(BGMAC_AWCACHE | BGMAC_ARCACHE | BGMAC_AWUSER |
+			 BGMAC_ARUSER);
+	val |= BGMAC_CLK_EN;
 	bgmac_idm_read(bgmac, BCMA_IOCTL);
 
 	bgmac_idm_write(bgmac, BCMA_RESET_CTL, 0);
 	bgmac_idm_read(bgmac, BCMA_RESET_CTL);
 	udelay(1);
 
-	bgmac_idm_write(bgmac, BCMA_IOCTL, (BCMA_IOCTL_CLK | flags));
+	bgmac_idm_write(bgmac, BCMA_IOCTL, val);
 	bgmac_idm_read(bgmac, BCMA_IOCTL);
 	udelay(1);
 }
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 71f493f..c8d33eb 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -213,6 +213,22 @@
 /* BCMA GMAC core specific IO Control (BCMA_IOCTL) flags */
 #define BGMAC_BCMA_IOCTL_SW_CLKEN		0x00000004	/* PHY Clock Enable */
 #define BGMAC_BCMA_IOCTL_SW_RESET		0x00000008	/* PHY Reset */
+/* The IOCTL values appear to be different in NS, NSP, and NS2, and do not match
+ * the values directly above
+ */
+#define BGMAC_CLK_EN				BIT(0)
+#define BGMAC_RESERVED_0			BIT(1)
+#define BGMAC_SOURCE_SYNC_MODE_EN		BIT(2)
+#define BGMAC_DEST_SYNC_MODE_EN			BIT(3)
+#define BGMAC_TX_CLK_OUT_INVERT_EN		BIT(4)
+#define BGMAC_DIRECT_GMII_MODE			BIT(5)
+#define BGMAC_CLK_250_SEL			BIT(6)
+#define BGMAC_AWCACHE				(0xf << 7)
+#define BGMAC_RESERVED_1			(0x1f << 11)
+#define BGMAC_ARCACHE				(0xf << 16)
+#define BGMAC_AWUSER				(0x3f << 20)
+#define BGMAC_ARUSER				(0x3f << 26)
+#define BGMAC_RESERVED				BIT(31)
 
 /* BCMA GMAC core specific IO status (BCMA_IOST) flags */
 #define BGMAC_BCMA_IOST_ATTACHED		0x00000800
-- 
2.7.4
