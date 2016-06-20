From: Maxim Altshul <maxim.altshul@ti.com>
Subject: [PATCH 1/3] wlcore/wl18xx: Add functionality to accept TX rate per link
Date: Mon, 20 Jun 2016 16:00:20 +0300
Message-ID: <1466427622-5953-2-git-send-email-maxim.altshul@ti.com>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eliad@wizery.com>, <yanivma@ti.com>, <guym@ti.com>,
	<arik@wizery.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	Maxim Altshul <maxim.altshul@ti.com>
To: <johannes@sipsolutions.net>, <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40474 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbcFTNAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 09:00:03 -0400
In-Reply-To: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW will provide a TX rate per link for each FW status,
and wlcore will be able to store the information for
the use of the mesh hwmp module.

This is used mainly in mesh.
Rates are reported when a mesh interface is up.

Signed-off-by: Maxim Altshul <maxim.altshul@ti.com>
---
 drivers/net/wireless/ti/wl18xx/main.c     |  4 ++++
 drivers/net/wireless/ti/wl18xx/tx.c       | 22 ++++++++++++++++++----
 drivers/net/wireless/ti/wl18xx/wl18xx.h   |  6 +++++-
 drivers/net/wireless/ti/wlcore/main.c     |  1 +
 drivers/net/wireless/ti/wlcore/rx.c       |  7 +++++++
 drivers/net/wireless/ti/wlcore/wlcore_i.h | 13 +++++++++++++
 6 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index 6e89e13..a7913ec 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -1214,6 +1214,10 @@ static void wl18xx_convert_fw_status(struct wl1271 *wl, void *raw_fw_status,
 			int_fw_status->counters.tx_voice_released_blks;
 	fw_status->counters.tx_last_rate =
 			int_fw_status->counters.tx_last_rate;
+	fw_status->counters.tx_last_rate_mbps =
+			int_fw_status->counters.tx_last_rate_mbps;
+	fw_status->counters.hlid =
+			int_fw_status->counters.hlid;
 
 	fw_status->log_start_addr = le32_to_cpu(int_fw_status->log_start_addr);
 
diff --git a/drivers/net/wireless/ti/wl18xx/tx.c b/drivers/net/wireless/ti/wl18xx/tx.c
index 3406ffb..d198827 100644
--- a/drivers/net/wireless/ti/wl18xx/tx.c
+++ b/drivers/net/wireless/ti/wl18xx/tx.c
@@ -30,9 +30,9 @@
 
 static
 void wl18xx_get_last_tx_rate(struct wl1271 *wl, struct ieee80211_vif *vif,
-			     u8 band, struct ieee80211_tx_rate *rate)
+			     u8 band, struct ieee80211_tx_rate *rate, u8 hlid)
 {
-	u8 fw_rate = wl->fw_status->counters.tx_last_rate;
+	u8 fw_rate = wl->links[hlid].fw_rate_idx;
 
 	if (fw_rate > CONF_HW_RATE_INDEX_MAX) {
 		wl1271_error("last Tx rate invalid: %d", fw_rate);
@@ -79,6 +79,7 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 	struct sk_buff *skb;
 	int id = tx_stat_byte & WL18XX_TX_STATUS_DESC_ID_MASK;
 	bool tx_success;
+	struct wl1271_tx_hw_descr *tx_desc;
 
 	/* check for id legality */
 	if (unlikely(id >= wl->num_tx_desc || wl->tx_frames[id] == NULL)) {
@@ -91,6 +92,7 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 
 	skb = wl->tx_frames[id];
 	info = IEEE80211_SKB_CB(skb);
+	tx_desc = (struct wl1271_tx_hw_descr *)skb->data;
 
 	if (wl12xx_is_dummy_packet(wl, skb)) {
 		wl1271_free_tx_id(wl, id);
@@ -105,7 +107,9 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 	 * the info->status structures
 	 */
 	wl18xx_get_last_tx_rate(wl, info->control.vif,
-				info->band, &info->status.rates[0]);
+				info->band,
+				&info->status.rates[0],
+				tx_desc->hlid);
 
 	info->status.rates[0].count = 1; /* no data about retries */
 	info->status.ack_signal = -1;
@@ -144,12 +148,22 @@ void wl18xx_tx_immediate_complete(struct wl1271 *wl)
 	struct wl18xx_fw_status_priv *status_priv =
 		(struct wl18xx_fw_status_priv *)wl->fw_status->priv;
 	struct wl18xx_priv *priv = wl->priv;
-	u8 i;
+	u8 i, hlid;
 
 	/* nothing to do here */
 	if (priv->last_fw_rls_idx == status_priv->fw_release_idx)
 		return;
 
+	/* update rates per link */
+	hlid = wl->fw_status->counters.hlid;
+
+	if (hlid < WLCORE_MAX_LINKS) {
+		wl->links[hlid].fw_rate_idx =
+				wl->fw_status->counters.tx_last_rate;
+		wl->links[hlid].fw_rate_mbps =
+				wl->fw_status->counters.tx_last_rate_mbps;
+	}
+
 	/* freed Tx descriptors */
 	wl1271_debug(DEBUG_TX, "last released desc = %d, current idx = %d",
 		     priv->last_fw_rls_idx, status_priv->fw_release_idx);
diff --git a/drivers/net/wireless/ti/wl18xx/wl18xx.h b/drivers/net/wireless/ti/wl18xx/wl18xx.h
index d65cc6d..5371cbd 100644
--- a/drivers/net/wireless/ti/wl18xx/wl18xx.h
+++ b/drivers/net/wireless/ti/wl18xx/wl18xx.h
@@ -125,7 +125,11 @@ struct wl18xx_fw_packet_counters {
 	/* Tx rate of the last transmitted packet */
 	u8 tx_last_rate;
 
-	u8 padding[2];
+	/* Tx rate or Tx rate estimate pre-calculated by fw in mbps units */
+	u8 tx_last_rate_mbps;
+
+	/* hlid for which the rates were reported */
+	u8 hlid;
 } __packed;
 
 /* FW status registers */
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 926d9b4..39dec7d 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5091,6 +5091,7 @@ static int wl12xx_sta_add(struct wl1271 *wl,
 		return ret;
 
 	wl_sta = (struct wl1271_station *)sta->drv_priv;
+	wl_sta->wl = wl;
 	hlid = wl_sta->hlid;
 
 	ret = wl12xx_cmd_add_peer(wl, wlvif, sta, hlid);
diff --git a/drivers/net/wireless/ti/wlcore/rx.c b/drivers/net/wireless/ti/wlcore/rx.c
index 438f271..c87d1d4 100644
--- a/drivers/net/wireless/ti/wlcore/rx.c
+++ b/drivers/net/wireless/ti/wlcore/rx.c
@@ -228,6 +228,13 @@ int wlcore_rx(struct wl1271 *wl, struct wl_fw_status *status)
 	enum wl_rx_buf_align rx_align;
 	int ret = 0;
 
+	/* update rates per link */
+	hlid = status->counters.hlid;
+
+	if (hlid < WLCORE_MAX_LINKS)
+		wl->links[hlid].fw_rate_mbps =
+				status->counters.tx_last_rate_mbps;
+
 	while (drv_rx_counter != fw_rx_counter) {
 		buf_size = 0;
 		rx_counter = drv_rx_counter;
diff --git a/drivers/net/wireless/ti/wlcore/wlcore_i.h b/drivers/net/wireless/ti/wlcore/wlcore_i.h
index cb72b2b..3875190 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore_i.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore_i.h
@@ -174,6 +174,12 @@ struct wl_fw_status {
 
 		/* Tx rate of the last transmitted packet */
 		u8 tx_last_rate;
+
+		/* Tx rate or Tx rate estimate pre calculated by fw in mbps */
+		u8 tx_last_rate_mbps;
+
+		/* hlid for which the rates were reported */
+		u8 hlid;
 	} counters;
 
 	u32 log_start_addr;
@@ -278,6 +284,12 @@ struct wl1271_link {
 	/* bitmap of TIDs where RX BA sessions are active for this link */
 	u8 ba_bitmap;
 
+	/* the last fw rate index we used for this link */
+	u8 fw_rate_idx;
+
+	/* the last fw rate [Mbps] we used for this link */
+	u8 fw_rate_mbps;
+
 	/* The wlvif this link belongs to. Might be null for global links */
 	struct wl12xx_vif *wlvif;
 
@@ -340,6 +352,7 @@ struct wl1271_station {
 	 * Used in both AP and STA mode.
 	 */
 	u64 total_freed_pkts;
+	struct wl1271 *wl;
 };
 
 struct wl12xx_vif {
-- 
2.7.2
