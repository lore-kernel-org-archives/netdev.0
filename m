From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 13/17] d80211: master interface auto up/down
Date: Fri, 21 Apr 2006 22:11:44 +0200 (CEST)
Message-ID: <20060421201144.B5799482CC@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14215 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932425AbWDUULQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:16 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason to put master interface to UP/DOWN state manually.

Calling of hw->open and hw->stop callbacks logically belongs to
ieee80211_master_open and ieee80211_master_stop functions, but then we need
to refuse putting master interface to UP state when there is no other
interface running, and similarly, to refuse putting master interface DOWN
when there are other interfaces running. Because the second is not possible,
hw->open and hw->stop need to be called from ieee80211_open/ieee80211_stop.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |   57 +++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 44 insertions(+), 13 deletions(-)

e5df634b3ae1c945076820434d8dcf897c0eb574
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index c20cb00..ea71b6c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1829,10 +1829,38 @@ static inline int identical_mac_addr_all
 		  type2 == IEEE80211_IF_TYPE_AP)));
 }
 
+static int ieee80211_master_open(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata;
+	int res = -EOPNOTSUPP;
+
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+		if (sdata->dev != dev && netif_running(sdata->dev)) {
+			res = 0;
+			break;
+		}
+	}
+	return res;
+}
+
+static int ieee80211_master_stop(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata;
+
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
+		if (sdata->dev != dev && netif_running(sdata->dev))
+			return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
 static int ieee80211_open(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata, *nsdata;
 	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_if_init_conf conf;
 	int res;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1852,8 +1880,6 @@ static int ieee80211_open(struct net_dev
 		return -ENOLINK;
 
 	if (local->hw->add_interface) {
-		struct ieee80211_if_init_conf conf;
-
 		conf.if_id = dev->ifindex;
 		conf.type = sdata->type;
 		conf.mac_addr = dev->dev_addr;
@@ -1868,10 +1894,18 @@ static int ieee80211_open(struct net_dev
 	}
 
         if (local->open_count == 0) {
-		if (local->hw->open) {
+		res = 0;
+		if (local->hw->open)
 			res = local->hw->open(sdata->master);
-			if (res)
-				return res;
+		if (res == 0) {
+			res = dev_open(sdata->master);
+			if (res && local->hw->stop)
+				local->hw->stop(sdata->master);
+		}
+		if (res) {
+			if (local->hw->remove_interface)
+				local->hw->remove_interface(dev, &conf);
+			return res;
 		}
 		ieee80211_init_scan(sdata->master);
 	}
@@ -1886,7 +1920,6 @@ static int ieee80211_stop(struct net_dev
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_local *local = dev->priv;
-	int res;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -1895,11 +1928,9 @@ static int ieee80211_stop(struct net_dev
 	local->open_count--;
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
-		if (local->hw->stop) {
-			res = local->hw->stop(sdata->master);
-			if (res)
-				return res;
-		}
+		dev_close(sdata->master);
+		if (local->hw->stop)
+			local->hw->stop(sdata->master);
         }
 	if (local->hw->remove_interface) {
 		struct ieee80211_if_init_conf conf;
@@ -4035,8 +4066,8 @@ struct net_device *ieee80211_alloc_hw(si
 	mdev->change_mtu = ieee80211_change_mtu;
         mdev->tx_timeout = ieee80211_tx_timeout;
         mdev->get_stats = ieee80211_get_stats;
-        mdev->open = ieee80211_open;
-	mdev->stop = ieee80211_stop;
+	mdev->open = ieee80211_master_open;
+	mdev->stop = ieee80211_master_stop;
 	mdev->type = ARPHRD_IEEE80211;
         mdev->hard_header_parse = header_parse_80211;
 	sprintf(mdev->name, "%s.11", dev->name);
-- 
1.3.0

