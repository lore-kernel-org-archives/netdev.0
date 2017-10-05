From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/mac80211/mesh_plink: Convert timers to use
Date: Wed, 4 Oct 2017 17:49:52 -0700
Message-ID: <20171005004952.GA23133@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. This requires adding a pointer back
to the sta_info since container_of() can't resolve the sta_info.

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/mac80211/mesh_plink.c | 9 +++++----
 net/mac80211/sta_info.c   | 2 +-
 net/mac80211/sta_info.h   | 2 ++
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index f69c6c38ca43..fcc02beaee6d 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -604,8 +604,9 @@ void mesh_neighbour_update(struct ieee80211_sub_if_data *sdata,
 	ieee80211_mbss_info_change_notify(sdata, changed);
 }
 
-static void mesh_plink_timer(unsigned long data)
+static void mesh_plink_timer(struct timer_list *t)
 {
+	struct mesh_sta *mesh = from_timer(mesh, t, plink_timer);
 	struct sta_info *sta;
 	u16 reason = 0;
 	struct ieee80211_sub_if_data *sdata;
@@ -617,7 +618,7 @@ static void mesh_plink_timer(unsigned long data)
 	 * del_timer_sync() this timer after having made sure
 	 * it cannot be readded (by deleting the plink.)
 	 */
-	sta = (struct sta_info *) data;
+	sta = mesh->plink_sta;
 
 	if (sta->sdata->local->quiescing)
 		return;
@@ -698,8 +699,8 @@ static void mesh_plink_timer(unsigned long data)
 static inline void mesh_plink_timer_set(struct sta_info *sta, u32 timeout)
 {
 	sta->mesh->plink_timer.expires = jiffies + msecs_to_jiffies(timeout);
-	sta->mesh->plink_timer.data = (unsigned long) sta;
-	sta->mesh->plink_timer.function = mesh_plink_timer;
+	sta->mesh->plink_sta = sta;
+	sta->mesh->plink_timer.function = (TIMER_FUNC_TYPE)mesh_plink_timer;
 	sta->mesh->plink_timeout = timeout;
 	add_timer(&sta->mesh->plink_timer);
 }
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 69615016d5bf..5e5de9455e4e 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -332,7 +332,7 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 		spin_lock_init(&sta->mesh->plink_lock);
 		if (ieee80211_vif_is_mesh(&sdata->vif) &&
 		    !sdata->u.mesh.user_mpm)
-			init_timer(&sta->mesh->plink_timer);
+			timer_setup(&sta->mesh->plink_timer, NULL, 0);
 		sta->mesh->nonpeer_pm = NL80211_MESH_POWER_ACTIVE;
 	}
 #endif
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 3acbdfa9f649..21d9760ce5c3 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -344,6 +344,7 @@ DECLARE_EWMA(mesh_fail_avg, 20, 8)
  * @plink_state: peer link state
  * @plink_timeout: timeout of peer link
  * @plink_timer: peer link watch timer
+ * @plink_sta: peer link watch timer's sta_info
  * @t_offset: timing offset relative to this host
  * @t_offset_setpoint: reference timing offset of this sta to be used when
  * 	calculating clockdrift
@@ -356,6 +357,7 @@ DECLARE_EWMA(mesh_fail_avg, 20, 8)
  */
 struct mesh_sta {
 	struct timer_list plink_timer;
+	struct sta_info *plink_sta;
 
 	s64 t_offset;
 	s64 t_offset_setpoint;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
