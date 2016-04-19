From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 02/18] wcn36xx: Pad TIM PVM if needed
Date: Mon, 18 Apr 2016 22:00:40 -0700
Message-ID: <1461042056-10607-3-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

The wcn36xx FW expects a fixed size TIM PVM in the beacon template. If
supplied with a shorter than expected PVM it will overwrite the IE
following the TIM.

Squashed with fix from Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>:
Patch "wcn36xx: Pad TIM PVM if needed" has caused a regression in mesh
beaconing.  The field tim_off is always 0 for mesh mode, and thus
pvm_len (referring to the TIM length field) and pad are both incorrectly
calculated.  Thus, msg_body.beacon_length is incorrectly calculated for
mesh mode. Fix this.

Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
[bjorn: squashed in Jason's fixup]
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---

Changes since v1:
- Merged in Jason's patch for skipping the padding in mesh mode.

 drivers/net/wireless/ath/wcn36xx/hal.h |  3 +++
 drivers/net/wireless/ath/wcn36xx/smd.c | 27 +++++++++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index d713204f755d..3af16cba3d12 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -54,6 +54,9 @@
 /* Default Beacon template size */
 #define BEACON_TEMPLATE_SIZE 0x180
 
+/* Minimum PVM size that the FW expects. See comment in smd.c for details. */
+#define TIM_MIN_PVM_SIZE 6
+
 /* Param Change Bitmap sent to HAL */
 #define PARAM_BCN_INTERVAL_CHANGED                      (1 << 0)
 #define PARAM_SHORT_PREAMBLE_CHANGED                 (1 << 1)
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index ff3ed2461a69..089a7e445cd6 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1375,12 +1375,19 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 			    u16 p2p_off)
 {
 	struct wcn36xx_hal_send_beacon_req_msg msg_body;
-	int ret = 0;
+	int ret = 0, pad, pvm_len;
 
 	mutex_lock(&wcn->hal_mutex);
 	INIT_HAL_MSG(msg_body, WCN36XX_HAL_SEND_BEACON_REQ);
 
-	msg_body.beacon_length = skb_beacon->len;
+	pvm_len = skb_beacon->data[tim_off + 1] - 3;
+	pad = TIM_MIN_PVM_SIZE - pvm_len;
+
+	/* Padding is irrelevant to mesh mode since tim_off is always 0. */
+	if (vif->type == NL80211_IFTYPE_MESH_POINT)
+		pad = 0;
+
+	msg_body.beacon_length = skb_beacon->len + pad;
 	/* TODO need to find out why + 6 is needed */
 	msg_body.beacon_length6 = msg_body.beacon_length + 6;
 
@@ -1393,6 +1400,22 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 	memcpy(msg_body.beacon, skb_beacon->data, skb_beacon->len);
 	memcpy(msg_body.bssid, vif->addr, ETH_ALEN);
 
+	if (pad > 0) {
+		/*
+		 * The wcn36xx FW has a fixed size for the PVM in the TIM. If
+		 * given the beacon template from mac80211 with a PVM shorter
+		 * than the FW expectes it will overwrite the data after the
+		 * TIM.
+		 */
+		wcn36xx_dbg(WCN36XX_DBG_HAL, "Pad TIM PVM. %d bytes at %d\n",
+			    pad, pvm_len);
+		memmove(&msg_body.beacon[tim_off + 5 + pvm_len + pad],
+			&msg_body.beacon[tim_off + 5 + pvm_len],
+			skb_beacon->len - (tim_off + 5 + pvm_len));
+		memset(&msg_body.beacon[tim_off + 5 + pvm_len], 0, pad);
+		msg_body.beacon[tim_off + 1] += pad;
+	}
+
 	/* TODO need to find out why this is needed? */
 	if (vif->type == NL80211_IFTYPE_MESH_POINT)
 		/* mesh beacon don't need this, so push further down */
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
