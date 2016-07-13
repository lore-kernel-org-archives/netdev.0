From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH v2 1/3] mac80211: mesh: flush stations before beacons are stopped
Date: Wed, 13 Jul 2016 14:44:41 +0300
Message-ID: <20160713114449.24665-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maital Hahn <maitalm@ti.com>, Yaniv Machani <yanivma@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34495 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcGMLle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 07:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maital Hahn <maitalm@ti.com>

Some drivers (e.g. wl18xx) expect that the last stage in the
de-initialization process will be stopping the beacons, similar to AP flow.
Update ieee80211_stop_mesh() flow accordingly.
As peers can be removed dynamically, this would not impact other drivers.

Tested also on Ralink RT3572 chipset.

Signed-off-by: Maital Hahn <maitalm@ti.com>
Signed-off-by: Yaniv Machani <yanivma@ti.com>
---
V2- updated comment, patch was tested with RT3572

 net/mac80211/mesh.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 21b1fdf..9214bc1 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -896,20 +896,22 @@ void ieee80211_stop_mesh(struct ieee80211_sub_if_data *sdata)
 
 	netif_carrier_off(sdata->dev);
 
+	/* flush STAs and mpaths on this iface */
+	sta_info_flush(sdata);
+	mesh_path_flush_by_iface(sdata);
+
 	/* stop the beacon */
 	ifmsh->mesh_id_len = 0;
 	sdata->vif.bss_conf.enable_beacon = false;
 	clear_bit(SDATA_STATE_OFFCHANNEL_BEACON_STOPPED, &sdata->state);
 	ieee80211_bss_info_change_notify(sdata, BSS_CHANGED_BEACON_ENABLED);
+
+	/* remove beacon */
 	bcn = rcu_dereference_protected(ifmsh->beacon,
 					lockdep_is_held(&sdata->wdev.mtx));
 	RCU_INIT_POINTER(ifmsh->beacon, NULL);
 	kfree_rcu(bcn, rcu_head);
 
-	/* flush STAs and mpaths on this iface */
-	sta_info_flush(sdata);
-	mesh_path_flush_by_iface(sdata);
-
 	/* free all potentially still buffered group-addressed frames */
 	local->total_ps_buffered -= skb_queue_len(&ifmsh->ps.bc_buf);
 	skb_queue_purge(&ifmsh->ps.bc_buf);
-- 
2.9.0
