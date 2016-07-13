From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH v2 2/3] mac80211: mesh: improve path resolving time
Date: Wed, 13 Jul 2016 14:45:25 +0300
Message-ID: <20160713114528.24835-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yaniv Machani <yanivma@ti.com>, Maital Hahn <maitalm@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34524 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbcGMLmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 07:42:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a packet is received for transmission,
a PREQ frame is sent to resolve the appropriate path to the desired destination.
After path was established, any sequential PREQ will be sent only after
dot11MeshHWMPpreqMinInterval, which usually set to few seconds.

This implementation has an impact in cases where we would like to
resolve the path quickly.
A clear example is when a peer was disconnected from us,
while he acted as a hop to our destination.
Although the path table will be cleared, the next PREQ frame will be sent only after reaching the MinInterval.
This will cause unwanted delay, possibly of few seconds until the traffic will resume.

To improve that, added an 'immediate' flag to be used when the path needs to be resolved.
Once set, a PREQ frame will be send w/o considering the MinInterval parameter.

Signed-off-by: Maital Hahn <maitalm@ti.com>
Signed-off-by: Yaniv Machani <yanivma@ti.com>
---
v2 - Updated comment to explain the scenario better.
   - Removed unnccesary changes that was alreay upstreamed.
   
 net/mac80211/mesh_hwmp.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 8f9c3bd..9783d49 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -19,7 +19,7 @@
 
 #define MAX_PREQ_QUEUE_LEN	64
 
-static void mesh_queue_preq(struct mesh_path *, u8);
+static void mesh_queue_preq(struct mesh_path *, u8, bool);
 
 static inline u32 u32_field_get(const u8 *preq_elem, int offset, bool ae)
 {
@@ -830,7 +830,8 @@ static void hwmp_rann_frame_process(struct ieee80211_sub_if_data *sdata,
 		mhwmp_dbg(sdata,
 			  "time to refresh root mpath %pM\n",
 			  orig_addr);
-		mesh_queue_preq(mpath, PREQ_Q_F_START | PREQ_Q_F_REFRESH);
+		mesh_queue_preq(mpath, PREQ_Q_F_START | PREQ_Q_F_REFRESH,
+				false);
 		mpath->last_preq_to_root = jiffies;
 	}
 
@@ -925,7 +926,7 @@ void mesh_rx_path_sel_frame(struct ieee80211_sub_if_data *sdata,
  * Locking: the function must be called from within a rcu read lock block.
  *
  */
-static void mesh_queue_preq(struct mesh_path *mpath, u8 flags)
+static void mesh_queue_preq(struct mesh_path *mpath, u8 flags, bool immediate)
 {
 	struct ieee80211_sub_if_data *sdata = mpath->sdata;
 	struct ieee80211_if_mesh *ifmsh = &sdata->u.mesh;
@@ -964,18 +965,24 @@ static void mesh_queue_preq(struct mesh_path *mpath, u8 flags)
 	++ifmsh->preq_queue_len;
 	spin_unlock_bh(&ifmsh->mesh_preq_queue_lock);
 
-	if (time_after(jiffies, ifmsh->last_preq + min_preq_int_jiff(sdata)))
+	if (immediate) {
 		ieee80211_queue_work(&sdata->local->hw, &sdata->work);
+	} else {
+		if (time_after(jiffies,
+			       ifmsh->last_preq + min_preq_int_jiff(sdata))) {
+			ieee80211_queue_work(&sdata->local->hw, &sdata->work);
 
-	else if (time_before(jiffies, ifmsh->last_preq)) {
-		/* avoid long wait if did not send preqs for a long time
-		 * and jiffies wrapped around
-		 */
-		ifmsh->last_preq = jiffies - min_preq_int_jiff(sdata) - 1;
-		ieee80211_queue_work(&sdata->local->hw, &sdata->work);
-	} else
-		mod_timer(&ifmsh->mesh_path_timer, ifmsh->last_preq +
-						min_preq_int_jiff(sdata));
+		} else if (time_before(jiffies, ifmsh->last_preq)) {
+			/* avoid long wait if did not send preqs for a long time
+			 * and jiffies wrapped around
+			 */
+			ifmsh->last_preq = jiffies -
+					   min_preq_int_jiff(sdata) - 1;
+			ieee80211_queue_work(&sdata->local->hw, &sdata->work);
+		} else
+			mod_timer(&ifmsh->mesh_path_timer, ifmsh->last_preq +
+				  min_preq_int_jiff(sdata));
+	}
 }
 
 /**
@@ -1110,7 +1117,7 @@ int mesh_nexthop_resolve(struct ieee80211_sub_if_data *sdata,
 	}
 
 	if (!(mpath->flags & MESH_PATH_RESOLVING))
-		mesh_queue_preq(mpath, PREQ_Q_F_START);
+		mesh_queue_preq(mpath, PREQ_Q_F_START, true);
 
 	if (skb_queue_len(&mpath->frame_queue) >= MESH_FRAME_QUEUE_LEN)
 		skb_to_free = skb_dequeue(&mpath->frame_queue);
@@ -1157,8 +1164,9 @@ int mesh_nexthop_lookup(struct ieee80211_sub_if_data *sdata,
 		       msecs_to_jiffies(sdata->u.mesh.mshcfg.path_refresh_time)) &&
 	    ether_addr_equal(sdata->vif.addr, hdr->addr4) &&
 	    !(mpath->flags & MESH_PATH_RESOLVING) &&
-	    !(mpath->flags & MESH_PATH_FIXED))
-		mesh_queue_preq(mpath, PREQ_Q_F_START | PREQ_Q_F_REFRESH);
+	    !(mpath->flags & MESH_PATH_FIXED)) {
+	    mesh_queue_preq(mpath, PREQ_Q_F_START | PREQ_Q_F_REFRESH, false);
+	}
 
 	next_hop = rcu_dereference(mpath->next_hop);
 	if (next_hop) {
@@ -1192,7 +1200,7 @@ void mesh_path_timer(unsigned long data)
 		mpath->discovery_timeout *= 2;
 		mpath->flags &= ~MESH_PATH_REQ_QUEUED;
 		spin_unlock_bh(&mpath->state_lock);
-		mesh_queue_preq(mpath, 0);
+		mesh_queue_preq(mpath, 0, false);
 	} else {
 		mpath->flags &= ~(MESH_PATH_RESOLVING |
 				  MESH_PATH_RESOLVED |
-- 
2.9.0
