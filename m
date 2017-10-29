From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] wlcore: Use common error handling code in
 wlcore_set_beacon_template()
Date: Sun, 29 Oct 2017 21:14:30 +0100
Message-ID: <f50c8edf-834d-9003-5a3c-dc83ec4016ce@users.sourceforge.net>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 20:16:22 +0100

Adjust jump targets so that a bit of exception handling can be better
reused at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ti/wlcore/main.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 0365b5e40a8d..12a9d6509382 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -4024,10 +4024,9 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 	wl1271_debug(DEBUG_MASTER, "beacon updated");
 
 	ret = wl1271_ssid_set(wlvif, beacon, ieoffset);
-	if (ret < 0) {
-		dev_kfree_skb(beacon);
-		goto out;
-	}
+	if (ret < 0)
+		goto free_skb;
+
 	min_rate = wl1271_tx_min_rate_get(wl, wlvif->basic_rate_set);
 	tmpl_id = is_ap ? CMD_TEMPL_AP_BEACON :
 		CMD_TEMPL_BEACON;
@@ -4035,10 +4034,8 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 				      beacon->data,
 				      beacon->len, 0,
 				      min_rate);
-	if (ret < 0) {
-		dev_kfree_skb(beacon);
-		goto out;
-	}
+	if (ret < 0)
+		goto free_skb;
 
 	wlvif->wmm_enabled =
 		cfg80211_find_vendor_ie(WLAN_OUI_MICROSOFT,
@@ -4051,7 +4048,7 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 	 * by usermode, don't use the beacon data.
 	 */
 	if (test_bit(WLVIF_FLAG_AP_PROBE_RESP_SET, &wlvif->flags))
-		goto end_bcn;
+		goto free_skb;
 
 	/* remove TIM ie from probe response */
 	wl12xx_remove_ie(beacon, WLAN_EID_TIM, ieoffset);
@@ -4081,9 +4078,8 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 					      beacon->data,
 					      beacon->len, 0,
 					      min_rate);
-end_bcn:
+free_skb:
 	dev_kfree_skb(beacon);
-out:
 	return ret;
 }
 
-- 
2.14.3

