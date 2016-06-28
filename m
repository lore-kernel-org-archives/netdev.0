From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH 3/4] mac80211: mesh: fixed HT ies in beacon template
Date: Tue, 28 Jun 2016 14:13:06 +0300
Message-ID: <20160628111307.8784-4-yanivma@ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Meirav Kama <meiravk@ti.com>
To: <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628111307.8784-3-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meirav Kama <meiravk@ti.com>

There are several values in HT info elements of mesh beacon (built by the
mac80211) that are incorrect.
To fix them:
1. mac80211 will check configuration from cfg and will build accordingly.
2. changes made in mesh default values.

Signed-off-by: Meirav Kama <meiravk@ti.com>
Acked-by: Yaniv Machani <yanivma@ti.com>
---
 net/mac80211/mesh.c | 33 ++++++++++++++++++++++++++++++++-
 net/mac80211/util.c |  3 ---
 net/wireless/mesh.c |  2 +-
 3 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 1f5be54..1b63b11 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -423,6 +423,8 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
 	enum nl80211_band band = ieee80211_get_sdata_band(sdata);
 	struct ieee80211_supported_band *sband;
 	u8 *pos;
+	u16 cap;
+
 
 	sband = local->hw.wiphy->bands[band];
 	if (!sband->ht_cap.ht_supported ||
@@ -431,11 +433,40 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
 	    sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_10)
 		return 0;
 
+    /* determine capability flags */
+	cap = sband->ht_cap.cap;
+
+    /* if channel width is 20MHz - configure HT capab accordingly*/
+	if (sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_20) {
+		cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+		cap &= ~IEEE80211_HT_CAP_DSSSCCK40;
+	}
+
+	/* set SM PS mode properly */
+	cap &= ~IEEE80211_HT_CAP_SM_PS;
+	switch (sdata->smps_mode) {
+	case IEEE80211_SMPS_AUTOMATIC:
+	case IEEE80211_SMPS_NUM_MODES:
+		WARN_ON(1);
+	case IEEE80211_SMPS_OFF:
+		cap |= WLAN_HT_CAP_SM_PS_DISABLED <<
+			IEEE80211_HT_CAP_SM_PS_SHIFT;
+		break;
+	case IEEE80211_SMPS_STATIC:
+		cap |= WLAN_HT_CAP_SM_PS_STATIC <<
+			IEEE80211_HT_CAP_SM_PS_SHIFT;
+		break;
+	case IEEE80211_SMPS_DYNAMIC:
+		cap |= WLAN_HT_CAP_SM_PS_DYNAMIC <<
+			IEEE80211_HT_CAP_SM_PS_SHIFT;
+		break;
+	}
+
 	if (skb_tailroom(skb) < 2 + sizeof(struct ieee80211_ht_cap))
 		return -ENOMEM;
 
 	pos = skb_put(skb, 2 + sizeof(struct ieee80211_ht_cap));
-	ieee80211_ie_build_ht_cap(pos, &sband->ht_cap, sband->ht_cap.cap);
+	ieee80211_ie_build_ht_cap(pos, &sband->ht_cap, cap);
 
 	return 0;
 }
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 42bf0b6..5375a82 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -2349,10 +2349,7 @@ u8 *ieee80211_ie_build_ht_oper(u8 *pos, struct ieee80211_sta_ht_cap *ht_cap,
 	ht_oper->operation_mode = cpu_to_le16(prot_mode);
 	ht_oper->stbc_param = 0x0000;
 
-	/* It seems that Basic MCS set and Supported MCS set
-	   are identical for the first 10 bytes */
 	memset(&ht_oper->basic_set, 0, 16);
-	memcpy(&ht_oper->basic_set, &ht_cap->mcs, 10);
 
 	return pos + sizeof(struct ieee80211_ht_operation);
 }
diff --git a/net/wireless/mesh.c b/net/wireless/mesh.c
index fa2066b..ac19a19 100644
--- a/net/wireless/mesh.c
+++ b/net/wireless/mesh.c
@@ -70,7 +70,7 @@ const struct mesh_config default_mesh_config = {
 	.dot11MeshGateAnnouncementProtocol = false,
 	.dot11MeshForwarding = true,
 	.rssi_threshold = MESH_RSSI_THRESHOLD,
-	.ht_opmode = IEEE80211_HT_OP_MODE_PROTECTION_NONHT_MIXED,
+	.ht_opmode = IEEE80211_HT_OP_MODE_PROTECTION_NONE,
 	.dot11MeshHWMPactivePathToRootTimeout = MESH_PATH_TO_ROOT_TIMEOUT,
 	.dot11MeshHWMProotInterval = MESH_ROOT_INTERVAL,
 	.dot11MeshHWMPconfirmationInterval = MESH_ROOT_CONFIRMATION_INTERVAL,
-- 
2.9.0
