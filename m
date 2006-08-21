From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 13/14] ipw2200: enable wireless extension passive scan
Date: Mon, 21 Aug 2006 11:39:03 +0800
Message-ID: <20060821033903.GA5434@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49696 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932591AbWHUDk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:58 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables the ipw2200 driver to support passive scanning as
offered by the wireless extensions. For this, I enhanced the ipw_wx_set_scan
function in such a way that it differentiates between a passive and an
active scan request. Additionally, I added a new function called
ipw_request_passive_scan that is similiar to the ipw_request_scan
function to perform passive scans. Last but not least, I added a field
(in fact it is a work_struct struct) called request_passive_scan to
the ipw_priv struct.

Signed-off-by: Thomas King <king@informatik.uni-mannheim.de>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   51 ++++++++++++++++++++++++++++++----------
 drivers/net/wireless/ipw2200.h |    1 +
 2 files changed, 39 insertions(+), 13 deletions(-)

58fb625939741d4ba2cbd660c1723f49ebe1b9f1
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 1525830..ea14b55 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -6169,7 +6169,7 @@ static void ipw_add_scan_channels(struct
 	}
 }
 
-static int ipw_request_scan(struct ipw_priv *priv)
+static int ipw_request_scan_helper(struct ipw_priv *priv, int type)
 {
 	struct ipw_scan_request_ext scan;
 	int err = 0, scan_type;
@@ -6200,19 +6200,29 @@ static int ipw_request_scan(struct ipw_p
 	}
 
 	memset(&scan, 0, sizeof(scan));
+	scan.full_scan_index = cpu_to_le32(ieee80211_get_scans(priv->ieee));
 
-	if (priv->config & CFG_SPEED_SCAN)
+	if (type == IW_SCAN_TYPE_PASSIVE) {
+	  	IPW_DEBUG_WX("use passive scanning\n");
+	  	scan_type = IPW_SCAN_PASSIVE_FULL_DWELL_SCAN;
+		scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] =
+			cpu_to_le16(120);
+		ipw_add_scan_channels(priv, &scan, scan_type);
+		goto send_request;
+	}
+
+	/* Use active scan by default. */
+  	if (priv->config & CFG_SPEED_SCAN)
 		scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_SCAN] =
-		    cpu_to_le16(30);
+			cpu_to_le16(30);
 	else
 		scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_SCAN] =
-		    cpu_to_le16(20);
+			cpu_to_le16(20);
 
 	scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_AND_DIRECT_SCAN] =
-	    cpu_to_le16(20);
-	scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] = cpu_to_le16(120);
+		cpu_to_le16(20);
 
-	scan.full_scan_index = cpu_to_le32(ieee80211_get_scans(priv->ieee));
+  	scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] = cpu_to_le16(120);
 
 #ifdef CONFIG_IPW2200_MONITOR
 	if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
@@ -6249,7 +6259,7 @@ static int ipw_request_scan(struct ipw_p
 		 *
 		 * TODO: Move SPEED SCAN support to all modes and bands */
 		scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] =
-		    cpu_to_le16(2000);
+			cpu_to_le16(2000);
 	} else {
 #endif				/* CONFIG_IPW2200_MONITOR */
 		/* If we are roaming, then make this a directed scan for the
@@ -6275,6 +6285,7 @@ static int ipw_request_scan(struct ipw_p
 	}
 #endif
 
+send_request:
 	err = ipw_send_scan_request_ext(priv, &scan);
 	if (err) {
 		IPW_DEBUG_HC("Sending scan command failed: %08X\n", err);
@@ -6285,11 +6296,19 @@ static int ipw_request_scan(struct ipw_p
 	priv->status &= ~STATUS_SCAN_PENDING;
 	queue_delayed_work(priv->workqueue, &priv->scan_check,
 			   IPW_SCAN_CHECK_WATCHDOG);
-      done:
+done:
 	mutex_unlock(&priv->mutex);
 	return err;
 }
 
+static int ipw_request_passive_scan(struct ipw_priv *priv) {
+  	return ipw_request_scan_helper(priv, IW_SCAN_TYPE_PASSIVE);
+}
+
+static int ipw_request_scan(struct ipw_priv *priv) {
+	return ipw_request_scan_helper(priv, IW_SCAN_TYPE_ACTIVE);
+}
+
 static void ipw_bg_abort_scan(void *data)
 {
 	struct ipw_priv *priv = data;
@@ -9378,15 +9397,19 @@ static int ipw_wx_set_scan(struct net_de
 			   union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-	struct iw_scan_req *req = NULL;
-	if (wrqu->data.length
-	    && wrqu->data.length == sizeof(struct iw_scan_req)) {
-		req = (struct iw_scan_req *)extra;
+	struct iw_scan_req *req = (struct iw_scan_req *)extra;
+
+	if (wrqu->data.length == sizeof(struct iw_scan_req)) {
 		if (wrqu->data.flags & IW_SCAN_THIS_ESSID) {
 			ipw_request_direct_scan(priv, req->essid,
 						req->essid_len);
 			return 0;
 		}
+		if (req->scan_type == IW_SCAN_TYPE_PASSIVE) {
+			queue_work(priv->workqueue,
+				   &priv->request_passive_scan);
+			return 0;
+		}
 	}
 
 	IPW_DEBUG_WX("Start scan\n");
@@ -10618,6 +10641,8 @@ static int ipw_setup_deferred_work(struc
 	INIT_WORK(&priv->down, (void (*)(void *))ipw_bg_down, priv);
 	INIT_WORK(&priv->request_scan,
 		  (void (*)(void *))ipw_request_scan, priv);
+	INIT_WORK(&priv->request_passive_scan,
+		  (void (*)(void *))ipw_request_passive_scan, priv);
 	INIT_WORK(&priv->gather_stats,
 		  (void (*)(void *))ipw_bg_gather_stats, priv);
 	INIT_WORK(&priv->abort_scan, (void (*)(void *))ipw_bg_abort_scan, priv);
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index a1df67f..dad5eed 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1296,6 +1296,7 @@ struct ipw_priv {
 	struct work_struct system_config;
 	struct work_struct rx_replenish;
 	struct work_struct request_scan;
+  	struct work_struct request_passive_scan;
 	struct work_struct adapter_restart;
 	struct work_struct rf_kill;
 	struct work_struct up;
-- 
1.2.6
