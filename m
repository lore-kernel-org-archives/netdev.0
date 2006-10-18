From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/18] d80211: del sta timer on interface close
Date: Wed, 18 Oct 2006 17:49:26 +0200 (CEST)
Message-ID: <20061018154926.7DFFA47F60@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13986 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161186AbWJRPs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:48:58 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delete sta timer when the corresponding network interface is brought down.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   24 ++++++++++++++++++++++++
 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_iface.c |   12 +++---------
 net/d80211/ieee80211_sta.c   |    3 +++
 4 files changed, 31 insertions(+), 9 deletions(-)

606451a64310c8084e9a3de07bafb8360989d004
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 036eca1..b30bd80 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2106,6 +2106,29 @@ static struct net_device_stats *ieee8021
 	return &(sdata->stats);
 }
 
+void ieee80211_if_shutdown(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	ASSERT_RTNL();
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		sdata->u.sta.state = IEEE80211_DISABLED;
+		del_timer_sync(&sdata->u.sta.timer);
+		if (local->scan_work.data == sdata->dev) {
+			local->sta_scanning = 0;
+			cancel_delayed_work(&local->scan_work);
+			flush_scheduled_work();
+			/* see comment in ieee80211_unregister_hw to
+			 * understand why this works */
+			local->scan_work.data = NULL;
+		}
+		break;
+	}
+}
+
 static inline int identical_mac_addr_allowed(int type1, int type2)
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
@@ -2306,6 +2329,7 @@ static int ieee80211_stop(struct net_dev
 		conf.mac_addr = dev->dev_addr;
 		local->hw->remove_interface(sdata->master, &conf);
 	}
+	ieee80211_if_shutdown(dev);
 
 	ieee80211_start_hard_monitor(local);
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 425fc9b..6fd208e 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -583,6 +583,7 @@ void ieee80211_tx_set_iswep(struct ieee8
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
 void ieee80211_if_mgmt_setup(struct net_device *dev);
+void ieee80211_if_shutdown(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 0a10c86..9a187af 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -242,6 +242,9 @@ #endif
 		ieee80211_key_free(sdata->keys[i]);
 	}
 
+	/* Shouldn't be necessary but won't hurt */
+	ieee80211_if_shutdown(dev);
+
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_AP: {
 		/* Remove all virtual interfaces that use this BSS
@@ -286,15 +289,6 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		break;
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
-		del_timer_sync(&sdata->u.sta.timer);
-		if (local->scan_work.data == sdata->dev) {
-			local->sta_scanning = 0;
-			cancel_delayed_work(&local->scan_work);
-			flush_scheduled_work();
-			/* see comment in ieee80211_unregister_hw to
-			 * understand why this works */
-			local->scan_work.data = NULL;
-		}
 		kfree(sdata->u.sta.extra_ie);
 		sdata->u.sta.extra_ie = NULL;
 		kfree(sdata->u.sta.assocreq_ies);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index dd95ce8..159474f 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1848,6 +1848,9 @@ void ieee80211_sta_timer(unsigned long p
 	struct ieee80211_if_sta *ifsta;
 
 	dev = (struct net_device *) ptr;
+	if (!netif_running(dev))
+		return;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS) {
-- 
1.3.0

