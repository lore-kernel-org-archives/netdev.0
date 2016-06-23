From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH] wlcore: time sync : add support for 64 bit clock
Date: Thu, 23 Jun 2016 14:12:39 +0300
Message-ID: <20160623111332.23326-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yaniv Machani <yanivma@ti.com>, Kalle Valo <kvalo@codeaurora.org>,
	Guy Mishol <guym@ti.com>, Eliad Peller <eliad@wizery.com>,
	Johannes Berg <johannes.berg@intel.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed the configuration to support 64bit instead of 32bit
this in order to offload the driver from handling a wraparound.

Signed-off-by: Yaniv Machani <yanivma@ti.com>
---
 drivers/net/wireless/ti/wl18xx/event.c | 26 +++++++++++++++++---------
 drivers/net/wireless/ti/wl18xx/event.h | 19 +++++++++++++------
 2 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ti/wl18xx/event.c b/drivers/net/wireless/ti/wl18xx/event.c
index ef81184..2c5df43 100644
--- a/drivers/net/wireless/ti/wl18xx/event.c
+++ b/drivers/net/wireless/ti/wl18xx/event.c
@@ -112,12 +112,18 @@ static int wlcore_smart_config_decode_event(struct wl1271 *wl,
 	return 0;
 }
 
-static void wlcore_event_time_sync(struct wl1271 *wl, u16 tsf_msb, u16 tsf_lsb)
+static void wlcore_event_time_sync(struct wl1271 *wl,
+				   u16 tsf_high_msb, u16 tsf_high_lsb,
+				   u16 tsf_low_msb, u16 tsf_low_lsb)
 {
-	u32 clock;
-	/* convert the MSB+LSB to a u32 TSF value */
-	clock = (tsf_msb << 16) | tsf_lsb;
-	wl1271_info("TIME_SYNC_EVENT_ID: clock %u", clock);
+	u32 clock_low;
+	u32 clock_high;
+
+	clock_high = (tsf_high_msb << 16) | tsf_high_lsb;
+	clock_low = (tsf_low_msb << 16) | tsf_low_lsb;
+
+	wl1271_info("TIME_SYNC_EVENT_ID: clock_high %u, clock low %u",
+		    clock_high, clock_low);
 }
 
 int wl18xx_process_mailbox_events(struct wl1271 *wl)
@@ -138,8 +144,10 @@ int wl18xx_process_mailbox_events(struct wl1271 *wl)
 
 	if (vector & TIME_SYNC_EVENT_ID)
 		wlcore_event_time_sync(wl,
-				mbox->time_sync_tsf_msb,
-				mbox->time_sync_tsf_lsb);
+			mbox->time_sync_tsf_high_msb,
+			mbox->time_sync_tsf_high_lsb,
+			mbox->time_sync_tsf_low_msb,
+			mbox->time_sync_tsf_low_lsb);
 
 	if (vector & RADAR_DETECTED_EVENT_ID) {
 		wl1271_info("radar event: channel %d type %s",
@@ -187,11 +195,11 @@ int wl18xx_process_mailbox_events(struct wl1271 *wl)
 	 */
 	if (vector & MAX_TX_FAILURE_EVENT_ID)
 		wlcore_event_max_tx_failure(wl,
-				le32_to_cpu(mbox->tx_retry_exceeded_bitmap));
+				le16_to_cpu(mbox->tx_retry_exceeded_bitmap));
 
 	if (vector & INACTIVE_STA_EVENT_ID)
 		wlcore_event_inactive_sta(wl,
-				le32_to_cpu(mbox->inactive_sta_bitmap));
+				le16_to_cpu(mbox->inactive_sta_bitmap));
 
 	if (vector & REMAIN_ON_CHANNEL_COMPLETE_EVENT_ID)
 		wlcore_event_roc_complete(wl);
diff --git a/drivers/net/wireless/ti/wl18xx/event.h b/drivers/net/wireless/ti/wl18xx/event.h
index 070de12..b436bf9 100644
--- a/drivers/net/wireless/ti/wl18xx/event.h
+++ b/drivers/net/wireless/ti/wl18xx/event.h
@@ -74,10 +74,16 @@ struct wl18xx_event_mailbox {
 	__le16 bss_loss_bitmap;
 
 	/* bitmap of stations (by HLID) which exceeded max tx retries */
-	__le32 tx_retry_exceeded_bitmap;
+	__le16 tx_retry_exceeded_bitmap;
+
+	/* time sync high msb*/
+	u16 time_sync_tsf_high_msb;
 
 	/* bitmap of inactive stations (by HLID) */
-	__le32 inactive_sta_bitmap;
+	__le16 inactive_sta_bitmap;
+
+	/* time sync high lsb*/
+	u16 time_sync_tsf_high_lsb;
 
 	/* rx BA win size indicated by RX_BA_WIN_SIZE_CHANGE_EVENT_ID */
 	u8 rx_ba_role_id;
@@ -98,14 +104,15 @@ struct wl18xx_event_mailbox {
 	u8 sc_sync_channel;
 	u8 sc_sync_band;
 
-	/* time sync msb*/
-	u16 time_sync_tsf_msb;
+	/* time sync low msb*/
+	u16 time_sync_tsf_low_msb;
+
 	/* radar detect */
 	u8 radar_channel;
 	u8 radar_type;
 
-	/* time sync lsb*/
-	u16 time_sync_tsf_lsb;
+	/* time sync low lsb*/
+	u16 time_sync_tsf_low_lsb;
 
 } __packed;
 
-- 
2.9.0
