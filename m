From: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Wed, 13 Jul 2016 23:07:48 +0300
Message-ID: <20160713200755.26839-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The HT capab info field inside the HT capab IE of the mesh beacon
is incorrect (in the case of 20MHz channel width).
To fix this driver will check configuration from cfg and
will build it accordingly.

Signed-off-by: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>
Signed-off-by: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
---
V3 - Fixes redundant spaces,empty lines and added FALLTHROUGH note.

 net/mac80211/mesh.c | 33 ++++++++++++++++++++++++++++++++-
 net/mac80211/util.c |  3 ---
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 9214bc1..6a67049 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -422,6 +422,7 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
 	enum nl80211_band band = ieee80211_get_sdata_band(sdata);
 	struct ieee80211_supported_band *sband;
 	u8 *pos;
+	u16 cap;
 
 	sband = local->hw.wiphy->bands[band];
 	if (!sband->ht_cap.ht_supported ||
@@ -430,11 +431,41 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
 	    sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_10)
 		return 0;
 
+	/* determine capability flags */
+	cap = sband->ht_cap.cap;
+
+	/* if channel width is 20MHz - configure HT capab accordingly*/
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
+		/* FALLTHROUGH */
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
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
