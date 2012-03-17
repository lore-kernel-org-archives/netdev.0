From: Mircea Gherzan <mgherzan@gmail.com>
Subject: [PATCH v2] wl12xx: fix DMA-API-related warnings
Date: Sat, 17 Mar 2012 18:41:53 +0100
Message-ID: <1332006114-30230-1-git-send-email-mgherzan@gmail.com>
Cc: Mircea Gherzan <mgherzan@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the PandaBoard (omap_hsmmc + wl12xx_sdio) with DMA_API_DEBUG:

 WARNING: at lib/dma-debug.c:930 check_for_stack.part.8+0x7c/0xe0()
 omap_hsmmc omap_hsmmc.4: DMA-API: device driver maps memory fromstack

Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
---
 drivers/net/wireless/wl12xx/boot.c   |   14 +++++++++++---
 drivers/net/wireless/wl12xx/cmd.c    |   25 ++++++++++++++++---------
 drivers/net/wireless/wl12xx/event.c  |   10 +++++-----
 drivers/net/wireless/wl12xx/event.h  |    2 ++
 drivers/net/wireless/wl12xx/main.c   |    9 +++++++++
 drivers/net/wireless/wl12xx/wl12xx.h |    3 +++
 6 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/boot.c b/drivers/net/wireless/wl12xx/boot.c
index 8f9cf5a..89c78d1 100644
--- a/drivers/net/wireless/wl12xx/boot.c
+++ b/drivers/net/wireless/wl12xx/boot.c
@@ -142,14 +142,22 @@ static void wl1271_parse_fw_ver(struct wl1271 *wl)
 
 static void wl1271_boot_fw_version(struct wl1271 *wl)
 {
-	struct wl1271_static_data static_data;
+	struct wl1271_static_data *static_data;
 
-	wl1271_read(wl, wl->cmd_box_addr, &static_data, sizeof(static_data),
+	static_data = kmalloc(sizeof(*static_data), GFP_DMA);
+	if (!static_data) {
+		__WARN();
+		return;
+	}
+
+	wl1271_read(wl, wl->cmd_box_addr, static_data, sizeof(*static_data),
 		    false);
 
-	strncpy(wl->chip.fw_ver_str, static_data.fw_version,
+	strncpy(wl->chip.fw_ver_str, static_data->fw_version,
 		sizeof(wl->chip.fw_ver_str));
 
+	kfree(static_data);
+
 	/* make sure the string is NULL-terminated */
 	wl->chip.fw_ver_str[sizeof(wl->chip.fw_ver_str) - 1] = '\0';
 
diff --git a/drivers/net/wireless/wl12xx/cmd.c b/drivers/net/wireless/wl12xx/cmd.c
index 25990bd..a5c8800 100644
--- a/drivers/net/wireless/wl12xx/cmd.c
+++ b/drivers/net/wireless/wl12xx/cmd.c
@@ -342,8 +342,12 @@ int wl1271_cmd_ext_radio_parms(struct wl1271 *wl)
  */
 static int wl1271_cmd_wait_for_event_or_timeout(struct wl1271 *wl, u32 mask)
 {
-	u32 events_vector, event;
+	u32 *events_vector;
+	u32 event;
 	unsigned long timeout;
+	int ret = 0;
+
+	events_vector = kmalloc(sizeof(*events_vector), GFP_DMA);
 
 	timeout = jiffies + msecs_to_jiffies(WL1271_EVENT_TIMEOUT);
 
@@ -351,21 +355,24 @@ static int wl1271_cmd_wait_for_event_or_timeout(struct wl1271 *wl, u32 mask)
 		if (time_after(jiffies, timeout)) {
 			wl1271_debug(DEBUG_CMD, "timeout waiting for event %d",
 				     (int)mask);
-			return -ETIMEDOUT;
+			ret = -ETIMEDOUT;
+			goto out;
 		}
 
 		msleep(1);
 
 		/* read from both event fields */
-		wl1271_read(wl, wl->mbox_ptr[0], &events_vector,
-			    sizeof(events_vector), false);
-		event = events_vector & mask;
-		wl1271_read(wl, wl->mbox_ptr[1], &events_vector,
-			    sizeof(events_vector), false);
-		event |= events_vector & mask;
+		wl1271_read(wl, wl->mbox_ptr[0], events_vector,
+			    sizeof(*events_vector), false);
+		event = *events_vector & mask;
+		wl1271_read(wl, wl->mbox_ptr[1], events_vector,
+			    sizeof(*events_vector), false);
+		event |= *events_vector & mask;
 	} while (!event);
 
-	return 0;
+out:
+	kfree(events_vector);
+	return ret;
 }
 
 static int wl1271_cmd_wait_for_event(struct wl1271 *wl, u32 mask)
diff --git a/drivers/net/wireless/wl12xx/event.c b/drivers/net/wireless/wl12xx/event.c
index d3280df68..10007f5 100644
--- a/drivers/net/wireless/wl12xx/event.c
+++ b/drivers/net/wireless/wl12xx/event.c
@@ -233,8 +233,9 @@ static void wl1271_event_mbox_dump(struct event_mailbox *mbox)
 	wl1271_debug(DEBUG_EVENT, "\tmask: 0x%x", mbox->events_mask);
 }
 
-static int wl1271_event_process(struct wl1271 *wl, struct event_mailbox *mbox)
+static int wl1271_event_process(struct wl1271 *wl)
 {
+	struct event_mailbox *mbox = wl->mbox;
 	struct ieee80211_vif *vif;
 	struct wl12xx_vif *wlvif;
 	int ret;
@@ -439,7 +440,6 @@ void wl1271_event_mbox_config(struct wl1271 *wl)
 
 int wl1271_event_handle(struct wl1271 *wl, u8 mbox_num)
 {
-	struct event_mailbox mbox;
 	int ret;
 
 	wl1271_debug(DEBUG_EVENT, "EVENT on mbox %d", mbox_num);
@@ -448,11 +448,11 @@ int wl1271_event_handle(struct wl1271 *wl, u8 mbox_num)
 		return -EINVAL;
 
 	/* first we read the mbox descriptor */
-	wl1271_read(wl, wl->mbox_ptr[mbox_num], &mbox,
-		    sizeof(struct event_mailbox), false);
+	wl1271_read(wl, wl->mbox_ptr[mbox_num], wl->mbox,
+		    sizeof(*wl->mbox), false);
 
 	/* process the descriptor */
-	ret = wl1271_event_process(wl, &mbox);
+	ret = wl1271_event_process(wl);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/wireless/wl12xx/event.h b/drivers/net/wireless/wl12xx/event.h
index 1d878ba..7a6b18b 100644
--- a/drivers/net/wireless/wl12xx/event.h
+++ b/drivers/net/wireless/wl12xx/event.h
@@ -127,6 +127,8 @@ struct event_mailbox {
 	u8 reserved_7[12];
 } __packed;
 
+struct wl1271;
+
 int wl1271_event_unmask(struct wl1271 *wl);
 void wl1271_event_mbox_config(struct wl1271 *wl);
 int wl1271_event_handle(struct wl1271 *wl, u8 mbox);
diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index d5f55a1..f63fde4 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -5071,8 +5071,17 @@ static struct ieee80211_hw *wl1271_alloc_hw(void)
 		goto err_dummy_packet;
 	}
 
+	wl->mbox = kmalloc(sizeof(*wl->mbox), GFP_DMA);
+	if (!wl->mbox) {
+		ret = -ENOMEM;
+		goto err_fwlog;
+	}
+
 	return hw;
 
+err_fwlog:
+	free_page((unsigned long)wl->fwlog);
+
 err_dummy_packet:
 	dev_kfree_skb(wl->dummy_packet);
 
diff --git a/drivers/net/wireless/wl12xx/wl12xx.h b/drivers/net/wireless/wl12xx/wl12xx.h
index b2b09cd..0d02c7a 100644
--- a/drivers/net/wireless/wl12xx/wl12xx.h
+++ b/drivers/net/wireless/wl12xx/wl12xx.h
@@ -34,6 +34,7 @@
 
 #include "conf.h"
 #include "ini.h"
+#include "event.h"
 
 #define WL127X_FW_NAME "ti-connectivity/wl127x-fw-3.bin"
 #define WL128X_FW_NAME "ti-connectivity/wl128x-fw-3.bin"
@@ -394,6 +395,8 @@ struct wl1271 {
 	/* Hardware recovery work */
 	struct work_struct recovery_work;
 
+	struct event_mailbox *mbox;
+
 	/* The mbox event mask */
 	u32 event_mask;
 
-- 
1.7.9.1
