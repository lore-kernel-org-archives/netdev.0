From: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in iface.c
Date: Mon, 24 Mar 2014 00:48:08 +0530
Message-ID: <1395602288-13958-1-git-send-email-monamagarwal123@gmail.com>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/iface.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index b8d331e..4826c8f 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -423,7 +423,7 @@ int ieee80211_add_virtual_monitor(struct ieee80211_local *local)
 	mutex_unlock(&local->mtx);
 	if (ret) {
 		mutex_lock(&local->iflist_mtx);
-		rcu_assign_pointer(local->monitor_sdata, NULL);
+		RCU_INIT_POINTER(local->monitor_sdata, NULL);
 		mutex_unlock(&local->iflist_mtx);
 		synchronize_net();
 		drv_remove_interface(local, sdata);
@@ -452,7 +452,7 @@ void ieee80211_del_virtual_monitor(struct ieee80211_local *local)
 		return;
 	}
 
-	rcu_assign_pointer(local->monitor_sdata, NULL);
+	RCU_INIT_POINTER(local->monitor_sdata, NULL);
 	mutex_unlock(&local->iflist_mtx);
 
 	synchronize_net();
@@ -876,7 +876,7 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	switch (sdata->vif.type) {
 	case NL80211_IFTYPE_AP_VLAN:
 		list_del(&sdata->u.vlan.list);
-		rcu_assign_pointer(sdata->vif.chanctx_conf, NULL);
+		RCU_INIT_POINTER(sdata->vif.chanctx_conf, NULL);
 		/* no need to tell driver */
 		break;
 	case NL80211_IFTYPE_MONITOR:
@@ -895,7 +895,7 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 		break;
 	case NL80211_IFTYPE_P2P_DEVICE:
 		/* relies on synchronize_rcu() below */
-		rcu_assign_pointer(local->p2p_sdata, NULL);
+		RCU_INIT_POINTER(local->p2p_sdata, NULL);
 		/* fall through */
 	default:
 		cancel_work_sync(&sdata->work);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
