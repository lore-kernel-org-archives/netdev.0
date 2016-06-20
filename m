From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/6] wcn36xx: Fix up wcn36xx_smd_update_scan_params()
Date: Sun, 19 Jun 2016 23:19:48 -0700
Message-ID: <1466403588-7041-6-git-send-email-bjorn.andersson@linaro.org>
References: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466403588-7041-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix up the wcn36xx_smd_update_scan_params() to work with non-ancient
versions of the firmware and support actually specifying the list of
channels.

Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h |  4 ++--
 drivers/net/wireless/ath/wcn36xx/smd.c | 15 +++++++++------
 drivers/net/wireless/ath/wcn36xx/smd.h |  2 +-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index 658bfb8baabe..4f87ef1e1eb8 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -4123,7 +4123,7 @@ struct wcn36xx_hal_update_scan_params_req {
 
 /* Update scan params - sent from host to PNO to be used during PNO
  * scanningx */
-struct update_scan_params_req_ex {
+struct wcn36xx_hal_update_scan_params_req_ex {
 
 	struct wcn36xx_hal_msg_header header;
 
@@ -4151,7 +4151,7 @@ struct update_scan_params_req_ex {
 
 	/* Cb State */
 	enum phy_chan_bond_state state;
-};
+} __packed;
 
 /* Update scan params - sent from host to PNO to be used during PNO
  * scanningx */
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index f9b2785cc277..994eba6cbaa8 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -675,22 +675,25 @@ static int wcn36xx_smd_update_scan_params_rsp(void *buf, size_t len)
 	return 0;
 }
 
-int wcn36xx_smd_update_scan_params(struct wcn36xx *wcn)
+int wcn36xx_smd_update_scan_params(struct wcn36xx *wcn,
+				   u8 *channels, size_t channel_count)
 {
-	struct wcn36xx_hal_update_scan_params_req msg_body;
+	struct wcn36xx_hal_update_scan_params_req_ex msg_body;
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
 	INIT_HAL_MSG(msg_body, WCN36XX_HAL_UPDATE_SCAN_PARAM_REQ);
 
-	msg_body.dot11d_enabled	= 0;
-	msg_body.dot11d_resolved = 0;
-	msg_body.channel_count = 26;
+	msg_body.dot11d_enabled	= false;
+	msg_body.dot11d_resolved = true;
+
+	msg_body.channel_count = channel_count;
+	memcpy(msg_body.channels, channels, channel_count);
 	msg_body.active_min_ch_time = 60;
 	msg_body.active_max_ch_time = 120;
 	msg_body.passive_min_ch_time = 60;
 	msg_body.passive_max_ch_time = 110;
-	msg_body.state = 0;
+	msg_body.state = PHY_SINGLE_CHANNEL_CENTERED;
 
 	PREPARE_HAL_BUF(wcn->hal_buf, msg_body);
 
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index 493f6191a173..40d829563c2b 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -64,7 +64,7 @@ int wcn36xx_smd_start_scan(struct wcn36xx *wcn);
 int wcn36xx_smd_end_scan(struct wcn36xx *wcn);
 int wcn36xx_smd_finish_scan(struct wcn36xx *wcn,
 			    enum wcn36xx_hal_sys_mode mode);
-int wcn36xx_smd_update_scan_params(struct wcn36xx *wcn);
+int wcn36xx_smd_update_scan_params(struct wcn36xx *wcn, u8 *channels, size_t channel_count);
 int wcn36xx_smd_add_sta_self(struct wcn36xx *wcn, struct ieee80211_vif *vif);
 int wcn36xx_smd_delete_sta_self(struct wcn36xx *wcn, u8 *addr);
 int wcn36xx_smd_delete_sta(struct wcn36xx *wcn, u8 sta_index);
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
