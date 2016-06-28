From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH] wlcore/wl18xx: mesh: added initial mesh support for wl8
Date: Tue, 28 Jun 2016 13:41:35 +0300
Message-ID: <20160628104305.4533-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maital Hahn <maitalm@ti.com>, Yaniv Machani <yanivma@ti.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>, Guy Mishol <guym@ti.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Arik Nemtsov <arik@wizery.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maital Hahn <maitalm@ti.com>

1. Added support for interface and role of mesh type.
2. Enabled enable/start of mesh-point role,
   and opening and closing a connection with a mesh peer.
3. Added multirole combination of mesh and ap
   under the same limits of dual ap mode.
4. Add support for 'sta_rc_update' opcode for mesh IF.
   The 'sta_rc_update' opcode is being used in mesh_plink.c.
Add support in wlcore to handle this opcode correctly for mesh
(as opposed to current implementation that handles STA only).
5. Bumped the firmware version to support new Mesh functionality

Signed-off-by: Maital Hahn <maitalm@ti.com>
Signed-off-by: Yaniv Machani <yanivma@ti.com>
---
 drivers/net/wireless/ti/wl18xx/main.c     | 15 ++++++++++++---
 drivers/net/wireless/ti/wl18xx/wl18xx.h   |  2 +-
 drivers/net/wireless/ti/wlcore/acx.h      |  1 +
 drivers/net/wireless/ti/wlcore/boot.c     |  2 +-
 drivers/net/wireless/ti/wlcore/cmd.c      | 13 ++++++++-----
 drivers/net/wireless/ti/wlcore/main.c     | 32 +++++++++++++++++++++++++++----
 drivers/net/wireless/ti/wlcore/wlcore_i.h |  1 +
 7 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index ae47c79..4811b74 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -1821,9 +1821,12 @@ static const struct ieee80211_iface_limit wl18xx_iface_limits[] = {
 	},
 	{
 		.max = 1,
-		.types = BIT(NL80211_IFTYPE_AP) |
-			 BIT(NL80211_IFTYPE_P2P_GO) |
-			 BIT(NL80211_IFTYPE_P2P_CLIENT),
+		.types =   BIT(NL80211_IFTYPE_AP)
+			 | BIT(NL80211_IFTYPE_P2P_GO)
+			 | BIT(NL80211_IFTYPE_P2P_CLIENT)
+#ifdef CONFIG_MAC80211_MESH
+			 | BIT(NL80211_IFTYPE_MESH_POINT)
+#endif
 	},
 	{
 		.max = 1,
@@ -1836,6 +1839,12 @@ static const struct ieee80211_iface_limit wl18xx_iface_ap_limits[] = {
 		.max = 2,
 		.types = BIT(NL80211_IFTYPE_AP),
 	},
+#ifdef CONFIG_MAC80211_MESH
+	{
+		.max = 1,
+		.types = BIT(NL80211_IFTYPE_MESH_POINT),
+	},
+#endif
 	{
 		.max = 1,
 		.types = BIT(NL80211_IFTYPE_P2P_DEVICE),
diff --git a/drivers/net/wireless/ti/wl18xx/wl18xx.h b/drivers/net/wireless/ti/wl18xx/wl18xx.h
index 71e9e38..d65cc6d 100644
--- a/drivers/net/wireless/ti/wl18xx/wl18xx.h
+++ b/drivers/net/wireless/ti/wl18xx/wl18xx.h
@@ -29,7 +29,7 @@
 #define WL18XX_IFTYPE_VER	9
 #define WL18XX_MAJOR_VER	WLCORE_FW_VER_IGNORE
 #define WL18XX_SUBTYPE_VER	WLCORE_FW_VER_IGNORE
-#define WL18XX_MINOR_VER	11
+#define WL18XX_MINOR_VER	58
 
 #define WL18XX_CMD_MAX_SIZE          740
 
diff --git a/drivers/net/wireless/ti/wlcore/acx.h b/drivers/net/wireless/ti/wlcore/acx.h
index 0d61fae..6321ed4 100644
--- a/drivers/net/wireless/ti/wlcore/acx.h
+++ b/drivers/net/wireless/ti/wlcore/acx.h
@@ -105,6 +105,7 @@ enum wl12xx_role {
 	WL1271_ROLE_DEVICE,
 	WL1271_ROLE_P2P_CL,
 	WL1271_ROLE_P2P_GO,
+	WL1271_ROLE_MESH_POINT,
 
 	WL12XX_INVALID_ROLE_TYPE = 0xff
 };
diff --git a/drivers/net/wireless/ti/wlcore/boot.c b/drivers/net/wireless/ti/wlcore/boot.c
index 19b7ec7..f75d304 100644
--- a/drivers/net/wireless/ti/wlcore/boot.c
+++ b/drivers/net/wireless/ti/wlcore/boot.c
@@ -130,7 +130,7 @@ fail:
 	wl1271_error("Your WiFi FW version (%u.%u.%u.%u.%u) is invalid.\n"
 		     "Please use at least FW %s\n"
 		     "You can get the latest firmwares at:\n"
-		     "git://github.com/TI-OpenLink/firmwares.git",
+		     "git://git.ti.com/wilink8-wlan/wl18xx_fw.git",
 		     fw_ver[FW_VER_CHIP], fw_ver[FW_VER_IF_TYPE],
 		     fw_ver[FW_VER_MAJOR], fw_ver[FW_VER_SUBTYPE],
 		     fw_ver[FW_VER_MINOR], min_fw_str);
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 3315356..d002dc7 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -629,11 +629,14 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	wl1271_debug(DEBUG_CMD, "cmd role start ap %d", wlvif->role_id);
 
-	/* trying to use hidden SSID with an old hostapd version */
-	if (wlvif->ssid_len == 0 && !bss_conf->hidden_ssid) {
-		wl1271_error("got a null SSID from beacon/bss");
-		ret = -EINVAL;
-		goto out;
+	/* If MESH --> ssid_len is always 0 */
+	if (!ieee80211_vif_is_mesh(vif)) {
+		/* trying to use hidden SSID with an old hostapd version */
+		if (wlvif->ssid_len == 0 && !bss_conf->hidden_ssid) {
+			wl1271_error("got a null SSID from beacon/bss");
+			ret = -EINVAL;
+			goto out;
+		}
 	}
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 10fd24c..79c17b0 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -221,6 +221,7 @@ static void wlcore_rc_update_work(struct work_struct *work)
 	struct wl12xx_vif *wlvif = container_of(work, struct wl12xx_vif,
 						rc_update_work);
 	struct wl1271 *wl = wlvif->wl;
+	struct ieee80211_vif *vif = wl12xx_wlvif_to_vif(wlvif);
 
 	mutex_lock(&wl->mutex);
 
@@ -231,8 +232,16 @@ static void wlcore_rc_update_work(struct work_struct *work)
 	if (ret < 0)
 		goto out;
 
-	wlcore_hw_sta_rc_update(wl, wlvif);
+	if (ieee80211_vif_is_mesh(vif)) {
+		ret = wl1271_acx_set_ht_capabilities(wl, &wlvif->rc_ht_cap,
+						     true, wlvif->sta.hlid);
+		if (ret < 0)
+			goto out_sleep;
+	} else {
+		wlcore_hw_sta_rc_update(wl, wlvif);
+	}
 
+out_sleep:
 	wl1271_ps_elp_sleep(wl);
 out:
 	mutex_unlock(&wl->mutex);
@@ -2153,10 +2162,14 @@ static void wlcore_free_klv_template(struct wl1271 *wl, u8 *idx)
 
 static u8 wl12xx_get_role_type(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 {
+	struct ieee80211_vif *vif = wl12xx_wlvif_to_vif(wlvif);
+
 	switch (wlvif->bss_type) {
 	case BSS_TYPE_AP_BSS:
 		if (wlvif->p2p)
 			return WL1271_ROLE_P2P_GO;
+		else if (ieee80211_vif_is_mesh(vif))
+			return WL1271_ROLE_MESH_POINT;
 		else
 			return WL1271_ROLE_AP;
 
@@ -2198,6 +2211,7 @@ static int wl12xx_init_vif_data(struct wl1271 *wl, struct ieee80211_vif *vif)
 		wlvif->p2p = 1;
 		/* fall-through */
 	case NL80211_IFTYPE_AP:
+	case NL80211_IFTYPE_MESH_POINT:
 		wlvif->bss_type = BSS_TYPE_AP_BSS;
 		break;
 	default:
@@ -4124,9 +4138,14 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 		if (ret < 0)
 			goto out;
 
-		ret = wl1271_ap_set_probe_resp_tmpl(wl, wlvif->basic_rate, vif);
-		if (ret < 0)
-			goto out;
+		/* No need to set probe resp template for mesh */
+		if (!ieee80211_vif_is_mesh(vif)) {
+			ret = wl1271_ap_set_probe_resp_tmpl(wl,
+							    wlvif->basic_rate,
+							    vif);
+			if (ret < 0)
+				goto out;
+		}
 
 		ret = wlcore_set_beacon_template(wl, vif, true);
 		if (ret < 0)
@@ -5629,6 +5648,7 @@ static void wlcore_op_sta_rc_update(struct ieee80211_hw *hw,
 
 	/* this callback is atomic, so schedule a new work */
 	wlvif->rc_update_bw = sta->bandwidth;
+	memcpy(&wlvif->rc_ht_cap, &sta->ht_cap, sizeof(sta->ht_cap));
 	ieee80211_queue_work(hw, &wlvif->rc_update_work);
 }
 
@@ -6050,7 +6070,11 @@ static int wl1271_init_ieee80211(struct wl1271 *wl)
 					 BIT(NL80211_IFTYPE_AP) |
 					 BIT(NL80211_IFTYPE_P2P_DEVICE) |
 					 BIT(NL80211_IFTYPE_P2P_CLIENT) |
+#ifdef CONFIG_MAC80211_MESH
+					 BIT(NL80211_IFTYPE_MESH_POINT) |
+#endif
 					 BIT(NL80211_IFTYPE_P2P_GO);
+
 	wl->hw->wiphy->max_scan_ssids = 1;
 	wl->hw->wiphy->max_sched_scan_ssids = 16;
 	wl->hw->wiphy->max_match_sets = 16;
diff --git a/drivers/net/wireless/ti/wlcore/wlcore_i.h b/drivers/net/wireless/ti/wlcore/wlcore_i.h
index 5c4199f..f5f910b 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore_i.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore_i.h
@@ -472,6 +472,7 @@ struct wl12xx_vif {
 
 	/* update rate conrol */
 	enum ieee80211_sta_rx_bandwidth rc_update_bw;
+	struct ieee80211_sta_ht_cap rc_ht_cap;
 	struct work_struct rc_update_work;
 
 	/*
-- 
2.9.0
