From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 17/18] wcn36xx: Correct remove bss key response encoding
Date: Mon, 18 Apr 2016 22:00:55 -0700
Message-ID: <1461042056-10607-18-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The WCN36XX_HAL_RMV_BSSKEY_RSP carries a single u32 with "status", so we
can use the standard status check function for decoding the result.

This is the last user of the v2 status checker, so remove the struct and
helper function.

Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---

Changes since v2:
- Added this patch to the series

 drivers/net/wireless/ath/wcn36xx/smd.c | 19 +------------------
 drivers/net/wireless/ath/wcn36xx/smd.h |  9 ---------
 2 files changed, 1 insertion(+), 27 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index c15501c06eb2..5f6ca3124bd8 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -312,22 +312,6 @@ static int wcn36xx_smd_rsp_status_check(void *buf, size_t len)
 	return 0;
 }
 
-static int wcn36xx_smd_rsp_status_check_v2(struct wcn36xx *wcn, void *buf,
-					     size_t len)
-{
-	struct wcn36xx_fw_msg_status_rsp_v2 *rsp;
-
-	if (len < sizeof(struct wcn36xx_hal_msg_header) + sizeof(*rsp))
-		return wcn36xx_smd_rsp_status_check(buf, len);
-
-	rsp = buf + sizeof(struct wcn36xx_hal_msg_header);
-
-	if (WCN36XX_FW_MSG_RESULT_SUCCESS != rsp->status)
-		return rsp->status;
-
-	return 0;
-}
-
 int wcn36xx_smd_load_nv(struct wcn36xx *wcn)
 {
 	struct nv_data *nv_d;
@@ -1647,8 +1631,7 @@ int wcn36xx_smd_remove_bsskey(struct wcn36xx *wcn,
 		wcn36xx_err("Sending hal_remove_bsskey failed\n");
 		goto out;
 	}
-	ret = wcn36xx_smd_rsp_status_check_v2(wcn, wcn->hal_buf,
-					      wcn->hal_rsp_len);
+	ret = wcn36xx_smd_rsp_status_check(wcn->hal_buf, wcn->hal_rsp_len);
 	if (ret) {
 		wcn36xx_err("hal_remove_bsskey response failed err=%d\n", ret);
 		goto out;
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index c1b76d75cf85..d74d781f4c8d 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -44,15 +44,6 @@ struct wcn36xx_fw_msg_status_rsp {
 	u32	status;
 } __packed;
 
-/* wcn3620 returns this for tigger_ba */
-
-struct wcn36xx_fw_msg_status_rsp_v2 {
-	u8	bss_id[6];
-	u32	status __packed;
-	u16	count_following_candidates __packed;
-	/* candidate list follows */
-};
