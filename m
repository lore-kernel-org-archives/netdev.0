From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH 2/4] mac80211/cfg: mesh: fix healing time when a mesh peer is disconnecting
Date: Tue, 28 Jun 2016 14:13:05 +0300
Message-ID: <20160628111307.8784-3-yanivma@ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maital Hahn <maitalm@ti.com>
To: <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628111307.8784-2-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maital Hahn <maitalm@ti.com>

Once receiving a CLOSE action frame from the disconnecting peer,
flush all entries in the path table which has this peer as the
next hop.

In addition, upon receiving a packet, if next hop is not found,
trigger PERQ immidiatly, instead of just putting it in the queue.

Signed-off-by: Maital Hahn <maitalm@ti.com>
Acked-by: Yaniv Machani <yanivma@ti.com>
---
 net/mac80211/cfg.c       |  1 +
 net/mac80211/mesh.c      |  3 ++-
 net/mac80211/mesh_hwmp.c | 42 +++++++++++++++++++++++++-----------------
 3 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 0c12e40..f876ef7 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1011,6 +1011,7 @@ static void sta_apply_mesh_params(struct ieee80211_local *local,
 			if (sta->mesh->plink_state == NL80211_PLINK_ESTAB)
 				changed = mesh_plink_dec_estab_count(sdata);
 			sta->mesh->plink_state = params->plink_state;
+			mesh_path_flush_by_nexthop(sta);
 
 			ieee80211_mps_sta_status_update(sta);
 			changed |= ieee80211_mps_set_sta_local_pm(sta,
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 9214bc1..1f5be54 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -159,7 +159,8 @@ void mesh_sta_cleanup(struct sta_info *sta)
 	if (!sdata->u.mesh.user_mpm) {
 		changed |= mesh_plink_deactivate(sta);
 		del_timer_sync(&sta->mesh->plink_timer);
-	}
+	} else
+		mesh_path_flush_by_nexthop(sta);
 
 	/* make sure no readers can access nexthop sta from here on */
 	mesh_path_flush_by_nexthop(sta);
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
