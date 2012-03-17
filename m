From: Mircea Gherzan <mgherzan@gmail.com>
Subject: [PATCH] wl12xx: fix DMA-API-related warnings
Date: Sat, 17 Mar 2012 17:26:32 +0100
Message-ID: <1332001592-17074-1-git-send-email-mgherzan@gmail.com>
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
 drivers/net/wireless/wl12xx/boot.c  |   14 +++++++++++---
 drivers/net/wireless/wl12xx/cmd.c   |   25 ++++++++++++++++---------
 drivers/net/wireless/wl12xx/event.c |   18 +++++++++++-------
 3 files changed, 38 insertions(+), 19 deletions(-)

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
index d3280df68..bcd0c93 100644
--- a/drivers/net/wireless/wl12xx/event.c
+++ b/drivers/net/wireless/wl12xx/event.c
@@ -439,25 +439,29 @@ void wl1271_event_mbox_config(struct wl1271 *wl)
 
 int wl1271_event_handle(struct wl1271 *wl, u8 mbox_num)
 {
-	struct event_mailbox mbox;
-	int ret;
+	struct event_mailbox *mbox;
+	int ret = 0;
 
 	wl1271_debug(DEBUG_EVENT, "EVENT on mbox %d", mbox_num);
 
 	if (mbox_num > 1)
 		return -EINVAL;
 
+	/* no GFP_ATOMIC: we're called from the threaded IRQ handler */
+	mbox = kmalloc(sizeof(*mbox), GFP_DMA);
+
 	/* first we read the mbox descriptor */
-	wl1271_read(wl, wl->mbox_ptr[mbox_num], &mbox,
-		    sizeof(struct event_mailbox), false);
+	wl1271_read(wl, wl->mbox_ptr[mbox_num], mbox, sizeof(*mbox), false);
 
 	/* process the descriptor */
-	ret = wl1271_event_process(wl, &mbox);
+	ret = wl1271_event_process(wl, mbox);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	/* then we let the firmware know it can go on...*/
 	wl1271_write32(wl, ACX_REG_INTERRUPT_TRIG, INTR_TRIG_EVENT_ACK);
 
-	return 0;
+out:
+	kfree(mbox);
+	return ret;
 }
-- 
1.7.9.1
