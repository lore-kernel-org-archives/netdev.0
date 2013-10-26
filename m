From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 11/16] wl1251: enable tx path in monitor mode if necessary for packet injection
Date: Sat, 26 Oct 2013 22:34:10 +0200
Message-ID: <1382819655-30430-12-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

If necessary enable the tx path in monitor mode for packet injection using
the JOIN command with BSS_TYPE_STA_BSS and zero BSSID.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
---
 drivers/net/wireless/ti/wl1251/main.c   |    5 +++++
 drivers/net/wireless/ti/wl1251/tx.c     |   17 +++++++++++++++++
 drivers/net/wireless/ti/wl1251/wl1251.h |    1 +
 3 files changed, 23 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 7e6b6d1..174f403 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -487,6 +487,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 	wl->rssi_thold = 0;
 	wl->channel = WL1251_DEFAULT_CHANNEL;
 	wl->monitor_present = false;
+	wl->joined = false;
 
 	wl1251_debugfs_reset(wl);
 
@@ -546,6 +547,7 @@ static void wl1251_op_remove_interface(struct ieee80211_hw *hw,
 	mutex_lock(&wl->mutex);
 	wl1251_debug(DEBUG_MAC80211, "mac80211 remove interface");
 	wl->vif = NULL;
+	memset(wl->bssid, 0, ETH_ALEN);
 	mutex_unlock(&wl->mutex);
 }
 
@@ -619,6 +621,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 		 * at firmware level.
 		 */
 		if (wl->vif == NULL) {
+			wl->joined = false;
 			ret = wl1251_cmd_data_path_rx(wl, wl->channel, 1);
 		} else {
 			ret = wl1251_join(wl, wl->bss_type, wl->channel,
@@ -1610,7 +1613,9 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 	INIT_DELAYED_WORK(&wl->elp_work, wl1251_elp_work);
 	wl->channel = WL1251_DEFAULT_CHANNEL;
 	wl->monitor_present = false;
+	wl->joined = false;
 	wl->scanning = false;
+	wl->bss_type = MAX_BSS_TYPE;
 	wl->default_key = 0;
 	wl->listen_int = 1;
 	wl->rx_counter = 0;
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 3cc82fd..1de4ccb 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -28,6 +28,7 @@
 #include "tx.h"
 #include "ps.h"
 #include "io.h"
+#include "event.h"
 
 static bool wl1251_tx_double_buffer_busy(struct wl1251 *wl, u32 data_out_count)
 {
@@ -298,6 +299,22 @@ static int wl1251_tx_frame(struct wl1251 *wl, struct sk_buff *skb)
 		}
 	}
 
+	/* Enable tx path in monitor mode for packet injection */
+	if ((wl->vif == NULL) && !wl->joined) {
+		ret = wl1251_cmd_join(wl, BSS_TYPE_STA_BSS, wl->channel,
+				      wl->beacon_int, wl->dtim_period);
+		if (ret < 0)
+			wl1251_warning("join failed");
+		else {
+			ret = wl1251_event_wait(wl, JOIN_EVENT_COMPLETE_ID,
+						100);
+			if (ret < 0)
+				wl1251_warning("join timeout");
+			else
+				wl->joined = true;
+		}
+	}
+
 	ret = wl1251_tx_path_status(wl);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index e478e61..1bdf779 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -311,6 +311,7 @@ struct wl1251 {
 	u8 listen_int;
 	int channel;
 	bool monitor_present;
+	bool joined;
 
 	void *target_mem_map;
 	struct acx_data_path_params_resp *data_path;
-- 
1.7.10.4
