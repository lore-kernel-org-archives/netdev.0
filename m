From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 01/16] wcn36xx: Clean up wcn36xx_smd_send_beacon
Date: Mon, 28 Mar 2016 23:06:18 -0700
Message-ID: <1459231593-360-2-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pontus Fuchs <pontus.fuchs@gmail.com>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33062 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcC2GGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 02:06:38 -0400
Received: by mail-pf0-f174.google.com with SMTP id 4so6633346pfd.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 23:06:37 -0700 (PDT)
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

Needed for coming improvements. No functional changes.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h |  7 +++++--
 drivers/net/wireless/ath/wcn36xx/smd.c | 12 +++++-------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index b947de0fb2e5..4fd77ccc2287 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -51,8 +51,8 @@
 #define WALN_HAL_STA_INVALID_IDX 0xFF
 #define WCN36XX_HAL_BSS_INVALID_IDX 0xFF
 
-/* Default Beacon template size */
-#define BEACON_TEMPLATE_SIZE 0x180
+/* Default Beacon template size. */
+#define BEACON_TEMPLATE_SIZE 0x17C
 
 /* Param Change Bitmap sent to HAL */
 #define PARAM_BCN_INTERVAL_CHANGED                      (1 << 0)
@@ -2884,6 +2884,9 @@ struct update_beacon_rsp_msg {
 struct wcn36xx_hal_send_beacon_req_msg {
 	struct wcn36xx_hal_msg_header header;
 
+	/* length of the template + 6. Only qcom knows why */
+	u32 beacon_length6;
+
 	/* length of the template. */
 	u32 beacon_length;
 
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 74f56a81ad9a..ff3ed2461a69 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1380,19 +1380,17 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 	mutex_lock(&wcn->hal_mutex);
 	INIT_HAL_MSG(msg_body, WCN36XX_HAL_SEND_BEACON_REQ);
 
-	/* TODO need to find out why this is needed? */
-	msg_body.beacon_length = skb_beacon->len + 6;
+	msg_body.beacon_length = skb_beacon->len;
+	/* TODO need to find out why + 6 is needed */
+	msg_body.beacon_length6 = msg_body.beacon_length + 6;
 
-	if (BEACON_TEMPLATE_SIZE > msg_body.beacon_length) {
-		memcpy(&msg_body.beacon, &skb_beacon->len, sizeof(u32));
-		memcpy(&(msg_body.beacon[4]), skb_beacon->data,
-		       skb_beacon->len);
-	} else {
+	if (msg_body.beacon_length > BEACON_TEMPLATE_SIZE) {
 		wcn36xx_err("Beacon is to big: beacon size=%d\n",
 			      msg_body.beacon_length);
 		ret = -ENOMEM;
 		goto out;
 	}
+	memcpy(msg_body.beacon, skb_beacon->data, skb_beacon->len);
 	memcpy(msg_body.bssid, vif->addr, ETH_ALEN);
 
 	/* TODO need to find out why this is needed? */
-- 
2.5.0
