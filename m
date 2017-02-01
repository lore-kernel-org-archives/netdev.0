From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 1/2] net: ethernet: bgmac: init sequence bug
Date: Wed,  1 Feb 2017 17:39:11 -0500
Message-ID: <1485988752-21030-2-git-send-email-jon.mason@broadcom.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zac Schroff <zschroff@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
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
 drivers/net/ethernet/broadcom/bgmac-platform.c | 10 +++++++---
 include/linux/bcma/bcma_regs.h                 |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 6f736c1..9bbe05c 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -61,15 +61,19 @@ static bool platform_bgmac_clk_enabled(struct bgmac *bgmac)
 
 static void platform_bgmac_clk_enable(struct bgmac *bgmac, u32 flags)
 {
-	bgmac_idm_write(bgmac, BCMA_IOCTL,
-			(BCMA_IOCTL_CLK | BCMA_IOCTL_FGC | flags));
+	u32 regval;
+
+	/* Some bits of BCMA_IOCTL set by HW/ATF & should not change */
+	regval = bgmac_idm_read(bgmac, BCMA_IOCTL) & BCMA_IOCTL_DO_NOT_MODIFY;
+	regval |= ((flags & (~BCMA_IOCTL_DO_NOT_MODIFY)) | BCMA_IOCTL_CLK);
+	bgmac_idm_write(bgmac, BCMA_IOCTL, regval | BCMA_IOCTL_FGC);
 	bgmac_idm_read(bgmac, BCMA_IOCTL);
 
 	bgmac_idm_write(bgmac, BCMA_RESET_CTL, 0);
 	bgmac_idm_read(bgmac, BCMA_RESET_CTL);
 	udelay(1);
 
-	bgmac_idm_write(bgmac, BCMA_IOCTL, (BCMA_IOCTL_CLK | flags));
+	bgmac_idm_write(bgmac, BCMA_IOCTL, regval);
 	bgmac_idm_read(bgmac, BCMA_IOCTL);
 	udelay(1);
 }
diff --git a/include/linux/bcma/bcma_regs.h b/include/linux/bcma/bcma_regs.h
index 9986f82..41d7404 100644
--- a/include/linux/bcma/bcma_regs.h
+++ b/include/linux/bcma/bcma_regs.h
@@ -31,6 +31,7 @@
 #define  BCMA_IOCTL_CORE_BITS		0x3FFC
 #define  BCMA_IOCTL_PME_EN		0x4000
 #define  BCMA_IOCTL_BIST_EN		0x8000
+#define  BCMA_IOCTL_DO_NOT_MODIFY	0x7FFFFF80
 #define BCMA_IOST			0x0500 /* IO status */
 #define  BCMA_IOST_CORE_BITS		0x0FFF
 #define  BCMA_IOST_DMA64		0x1000
-- 
2.7.4
