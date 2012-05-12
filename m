From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/17 v5] rndis_wlan: cleanup: byteswap data from device instead of RNDIS_* defines
Date: Sat, 12 May 2012 10:17:42 +0200
Message-ID: <1336810662-6147-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

All other values from device provided buffer are byteswapped, so it seems more
logical to do same for these.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/rndis_wlan.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 9bbef3f..c7f22cd 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -623,8 +623,8 @@ static int rndis_akm_suite_to_key_mgmt(u32 akm_suite)
 #ifdef DEBUG
 static const char *oid_to_string(__le32 oid)
 {
-	switch (oid) {
-#define OID_STR(oid) case cpu_to_le32(oid): return(#oid)
+	switch (le32_to_cpu(oid)) {
+#define OID_STR(oid) case oid: return(#oid)
 		/* from rndis_host.h */
 		OID_STR(RNDIS_OID_802_3_PERMANENT_ADDRESS);
 		OID_STR(RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE);
@@ -687,19 +687,19 @@ static const char *oid_to_string(__le32 oid)
 static int rndis_error_status(__le32 rndis_status)
 {
 	int ret = -EINVAL;
-	switch (rndis_status) {
-	case cpu_to_le32(RNDIS_STATUS_SUCCESS):
+	switch (le32_to_cpu(rndis_status)) {
+	case RNDIS_STATUS_SUCCESS:
 		ret = 0;
 		break;
-	case cpu_to_le32(RNDIS_STATUS_FAILURE):
-	case cpu_to_le32(RNDIS_STATUS_INVALID_DATA):
+	case RNDIS_STATUS_FAILURE:
+	case RNDIS_STATUS_INVALID_DATA:
 		ret = -EINVAL;
 		break;
-	case cpu_to_le32(RNDIS_STATUS_NOT_SUPPORTED):
+	case RNDIS_STATUS_NOT_SUPPORTED:
 		ret = -EOPNOTSUPP;
 		break;
-	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_READY):
-	case cpu_to_le32(RNDIS_STATUS_ADAPTER_NOT_OPEN):
+	case RNDIS_STATUS_ADAPTER_NOT_READY:
+	case RNDIS_STATUS_ADAPTER_NOT_OPEN:
 		ret = -EBUSY;
 		break;
 	}
@@ -3075,8 +3075,8 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	struct rndis_indicate *msg = ind;
 
-	switch (msg->status) {
-	case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
+	switch (le32_to_cpu(msg->status)) {
+	case RNDIS_STATUS_MEDIA_CONNECT:
 		if (priv->current_command_oid == cpu_to_le32(RNDIS_OID_802_11_ADD_KEY)) {
 			/* OID_802_11_ADD_KEY causes sometimes extra
 			 * "media connect" indications which confuses driver
@@ -3096,7 +3096,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		queue_work(priv->workqueue, &priv->work);
 		break;
 
-	case cpu_to_le32(RNDIS_STATUS_MEDIA_DISCONNECT):
+	case RNDIS_STATUS_MEDIA_DISCONNECT:
 		netdev_info(usbdev->net, "media disconnect\n");
 
 		/* queue work to avoid recursive calls into rndis_command */
@@ -3104,7 +3104,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		queue_work(priv->workqueue, &priv->work);
 		break;
 
-	case cpu_to_le32(RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION):
+	case RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION:
 		rndis_wlan_media_specific_indication(usbdev, msg, buflen);
 		break;
 
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
