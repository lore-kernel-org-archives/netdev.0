From: florian@mickler.org
Subject: [RFC PATCH 1/2] mac80211: make max_network_latency notifier atomic safe
Date: Wed,  9 Jun 2010 11:15:13 +0200
Message-ID: <1276074915-26879-1-git-send-email-florian@mickler.org>
Cc: james.bottomley@suse.de, markgross@thegnar.org,
	mgross@linux.intel.com, Florian Mickler <florian@mickler.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Cardona <javier@cozybit.com>, Jouni Malinen <j@w1.fi>,
	Rui Paulo <rpaulo@gmail.com>,
	Kalle Valo <kalle.valo@nokia.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pm list <linux-pm@lists.linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to have the pm_qos framework be callable from interrupt
context, all listeners have to also be callable in that context.

This patch schedules the update of the latency value via
ieee80211_max_network_latency() for execution on
the global workqueue (using schedule_work()).

As there was no synchronization/locking between the listener and the
caller of pm_qos_update_request before, there should be no new races
uncovered by this. Although the timing probably changes.

Signed-off-by: Florian Mickler <florian@mickler.org>
---

This needs some networking expertise to check the reasoning above and
judge the implementation.

 net/mac80211/ieee80211_i.h |    4 +++-
 net/mac80211/main.c        |    5 +++--
 net/mac80211/mlme.c        |   20 +++++++++++++++-----
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 1a9e2da..3d2155a 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -851,6 +851,7 @@ struct ieee80211_local {
 	struct work_struct dynamic_ps_disable_work;
 	struct timer_list dynamic_ps_timer;
 	struct notifier_block network_latency_notifier;
+	struct work_struct network_latency_notifier_work;
 
 	int user_power_level; /* in dBm */
 	int power_constr_level; /* in dBm */
@@ -994,8 +995,9 @@ ieee80211_rx_result ieee80211_sta_rx_mgmt(struct ieee80211_sub_if_data *sdata,
 void ieee80211_send_pspoll(struct ieee80211_local *local,
 			   struct ieee80211_sub_if_data *sdata);
 void ieee80211_recalc_ps(struct ieee80211_local *local, s32 latency);
-int ieee80211_max_network_latency(struct notifier_block *nb,
+int ieee80211_max_network_latency_notification(struct notifier_block *nb,
 				  unsigned long data, void *dummy);
+void ieee80211_max_network_latency(struct work_struct *w);
 void ieee80211_sta_process_chanswitch(struct ieee80211_sub_if_data *sdata,
 				      struct ieee80211_channel_sw_ie *sw_elem,
 				      struct ieee80211_bss *bss,
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 22a384d..5cded3a 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -607,9 +607,10 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	rtnl_unlock();
 
 	ieee80211_led_init(local);
-
+	INIT_WORK(&local->network_latency_notifier_work,
+			ieee80211_max_network_latency);
 	local->network_latency_notifier.notifier_call =
-		ieee80211_max_network_latency;
+		ieee80211_max_network_latency_notification;
 	result = pm_qos_add_notifier(PM_QOS_NETWORK_LATENCY,
 				     &local->network_latency_notifier);
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 0839c4e..feb6134 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1953,17 +1953,27 @@ void ieee80211_mlme_notify_scan_completed(struct ieee80211_local *local)
 	rcu_read_unlock();
 }
 
-int ieee80211_max_network_latency(struct notifier_block *nb,
-				  unsigned long data, void *dummy)
+void ieee80211_max_network_latency(struct work_struct *w)
 {
-	s32 latency_usec = (s32) data;
+	s32 latency_usec = (s32) atomic_long_read(&w->data);
 	struct ieee80211_local *local =
-		container_of(nb, struct ieee80211_local,
-			     network_latency_notifier);
+		container_of(w, struct ieee80211_local,
+			     network_latency_notifier_work);
 
 	mutex_lock(&local->iflist_mtx);
 	ieee80211_recalc_ps(local, latency_usec);
 	mutex_unlock(&local->iflist_mtx);
+}
+
+/* the notifier might be called from interrupt context */
+int ieee80211_max_network_latency_notification(struct notifier_block *nb,
+				  unsigned long data, void *dummy)
+{
+	struct ieee80211_local *local =
+		container_of(nb, struct ieee80211_local,
+				network_latency_notifier);
+	atomic_long_set(&local->network_latency_notifier_work.data, data);
+	schedule_work(&local->network_latency_notifier_work);
 
 	return 0;
 }
-- 
1.7.1
