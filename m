From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 2/7] net: wireless: wcn36xx: get chip type from platform ops
Date: Sun, 18 Jan 2015 13:10:49 +0800
Message-ID: <20150118051049.31866.47265.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:42176 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbbARFKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:10:55 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Autodetecting the chip type does not work well.
Stop attempting to do it and require a platform op
that tells us what the chip is.

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c    |   18 +++++-------------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |    1 +
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 7dd8873..c4178c7 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -221,17 +221,6 @@ static void wcn36xx_feat_caps_info(struct wcn36xx *wcn)
 	}
 }
 
-static void wcn36xx_detect_chip_version(struct wcn36xx *wcn)
-{
-	if (get_feat_caps(wcn->fw_feat_caps, DOT11AC)) {
-		wcn36xx_info("Chip is 3680\n");
-		wcn->chip_version = WCN36XX_CHIP_3680;
-	} else {
-		wcn36xx_info("Chip is 3660\n");
-		wcn->chip_version = WCN36XX_CHIP_3660;
-	}
-}
-
 static int wcn36xx_start(struct ieee80211_hw *hw)
 {
 	struct wcn36xx *wcn = hw->priv;
@@ -286,8 +275,6 @@ static int wcn36xx_start(struct ieee80211_hw *hw)
 			wcn36xx_feat_caps_info(wcn);
 	}
 
-	wcn36xx_detect_chip_version(wcn);
-
 	/* DMA channel initialization */
 	ret = wcn36xx_dxe_init(wcn);
 	if (ret) {
@@ -1023,6 +1010,11 @@ static int wcn36xx_probe(struct platform_device *pdev)
 	wcn->hw = hw;
 	wcn->dev = &pdev->dev;
 	wcn->ctrl_ops = pdev->dev.platform_data;
+	if (!wcn->ctrl_ops->get_chip_type) {
+		dev_err(&pdev->dev, "Missing ops->get_chip_type\n");
+		return -EINVAL;
+	}
+	wcn->chip_version = wcn->ctrl_ops->get_chip_type();
 
 	mutex_init(&wcn->hal_mutex);
 
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index a5366b6..04793c6 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -110,6 +110,7 @@ struct wcn36xx_platform_ctrl_ops {
 	void (*close)(void);
 	int (*tx)(char *buf, size_t len);
 	int (*get_hw_mac)(u8 *addr);
+	int (*get_chip_type)(void);
 	int (*smsm_change_state)(u32 clear_mask, u32 set_mask);
 };
 
