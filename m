From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] mac80211: fix locking in update_vlan_tailroom_need_count()
Date: Wed, 17 Jun 2015 13:54:54 +0200
Message-ID: <1434542094-14247-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Unfortunately, Michal's change to fix AP_VLAN crypto tailroom
caused a locking issue that was reported by lockdep, but only
in a few cases - the issue was a classic ABBA deadlock caused
by taking the mtx after the key_mtx, where normally they're
taken the other way around.

As the key mutex protects the field in question (I'm adding a
few annotations to make that clear) only the iteration needs
to be protected, but we can also iterate the interface list
with just RCU protection while holding the key mutex.

Fixes: f9dca80b98ca ("mac80211: fix AP_VLAN crypto tailroom calculation")
Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
Dave, if you're planning to send any more patches to Linus before
the release, please apply this one. Otherwise let me know and I'll
sort it out with Cc stable after the merge window.
---
 net/mac80211/key.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 8abc31ebcf61..b22df3a79a41 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -66,12 +66,15 @@ update_vlan_tailroom_need_count(struct ieee80211_sub_if_data *sdata, int delta)
 	if (sdata->vif.type != NL80211_IFTYPE_AP)
 		return;
 
-	mutex_lock(&sdata->local->mtx);
+	/* crypto_tx_tailroom_needed_cnt is protected by this */
+	assert_key_lock(sdata->local);
+
+	rcu_read_lock();
 
-	list_for_each_entry(vlan, &sdata->u.ap.vlans, u.vlan.list)
+	list_for_each_entry_rcu(vlan, &sdata->u.ap.vlans, u.vlan.list)
 		vlan->crypto_tx_tailroom_needed_cnt += delta;
 
-	mutex_unlock(&sdata->local->mtx);
+	rcu_read_unlock();
 }
 
 static void increment_tailroom_need_count(struct ieee80211_sub_if_data *sdata)
@@ -95,6 +98,8 @@ static void increment_tailroom_need_count(struct ieee80211_sub_if_data *sdata)
 	 * http://mid.gmane.org/1308590980.4322.19.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org
 	 */
 
+	assert_key_lock(sdata->local);
+
 	update_vlan_tailroom_need_count(sdata, 1);
 
 	if (!sdata->crypto_tx_tailroom_needed_cnt++) {
@@ -109,6 +114,8 @@ static void increment_tailroom_need_count(struct ieee80211_sub_if_data *sdata)
 static void decrease_tailroom_need_count(struct ieee80211_sub_if_data *sdata,
 					 int delta)
 {
+	assert_key_lock(sdata->local);
+
 	WARN_ON_ONCE(sdata->crypto_tx_tailroom_needed_cnt < delta);
 
 	update_vlan_tailroom_need_count(sdata, -delta);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
