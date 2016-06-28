From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH 4/4] mac80211: sta_info: max_peers reached falsely
Date: Tue, 28 Jun 2016 14:13:07 +0300
Message-ID: <20160628111307.8784-5-yanivma@ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
 <20160628111307.8784-4-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Meirav Kama <meiravk@ti.com>
To: <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:56637 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbcF1LLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 07:11:23 -0400
In-Reply-To: <20160628111307.8784-4-yanivma@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meirav Kama <meiravk@ti.com>

Issue happened when receiving delete_sta command without
changing plink_state from ESTAB to HOLDING before.
When receiving delete_sta command for mesh interface
verify plink_state is not ESTAB and if so, decrease
plink count and update beacon.

Signed-off-by: Meirav Kama <meiravk@ti.com>
Acked-by: Yaniv Machani <yanivma@ti.com>
---
 net/mac80211/sta_info.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 76b737d..1ce6320 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1009,11 +1009,25 @@ int sta_info_destroy_addr_bss(struct ieee80211_sub_if_data *sdata,
 {
 	struct sta_info *sta;
 	int ret;
+#ifdef CONFIG_MAC80211_MESH
+	bool dec_links = false;
+#endif
 
 	mutex_lock(&sdata->local->sta_mtx);
 	sta = sta_info_get_bss(sdata, addr);
+#ifdef CONFIG_MAC80211_MESH
+	if (sdata->vif.type == NL80211_IFTYPE_MESH_POINT &&
+	    sta->mesh->plink_state == NL80211_PLINK_ESTAB)
+		dec_links = true;
+#endif
 	ret = __sta_info_destroy(sta);
 	mutex_unlock(&sdata->local->sta_mtx);
+#ifdef CONFIG_MAC80211_MESH
+	if (dec_links) {
+		mesh_plink_dec_estab_count(sdata);
+		ieee80211_mbss_info_change_notify(sdata, BSS_CHANGED_BEACON);
+	}
+#endif
 
 	return ret;
 }
-- 
2.9.0
