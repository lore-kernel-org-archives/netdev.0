From: Hong Liu <hong.liu@intel.com>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Fri, 01 Sep 2006 15:34:38 +0800
Message-ID: <1157096078.11534.4.camel@devlinux-hong>
References: <1156494733.21483.14.camel@devlinux-hong>
	 <20060830191058.14275f74@griffin.suse.cz>
	 <1157081867.11040.41.camel@devlinux-hong>  <1157092863.2878.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55088 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751268AbWIAHjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 03:39:02 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1157092863.2878.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-01 at 14:41, Johannes Berg wrote:
> On Fri, 2006-09-01 at 11:37 +0800, Hong Liu wrote:
> > 
> > +     local->sta_scanning = 1;
> > +     if (local->hw->hw_scan)
> > +             return local->hw->hw_scan(dev, ssid, ssid_len);
> > +
> 
> My question still stands, is it proper to assign sta_scanning to 1 even
> if the function returns an error?
> 
> johannes
> 
> 
Thanks for point this out!
Change to only set sta_scanning to 1 if hw_scan successes.


Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 42fdbf7..1caa8a9 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -600,6 +600,10 @@ struct ieee80211_hw {
         int (*passive_scan)(struct net_device *dev, int state,
                             struct ieee80211_scan_conf *conf);
 
+	/* Ask the hardware to service the scan request, no need to start
+	 * the scan state machine in stack. */
+	int (*hw_scan)(struct net_device *dev, u8 *ssid, size_t len);
+
         /* return low-level statistics */
 	int (*get_stats)(struct net_device *dev,
 			 struct ieee80211_low_level_stats *stats);
@@ -906,6 +910,8 @@ void ieee80211_tx_led(int state, struct 
  */
 void ieee80211_rx_led(int state, struct net_device *dev);
 
+/* called by driver to notify scan status completed */
+void ieee80211_scan_completed(struct net_device *dev);
 
 /* IEEE 802.11 defines */
 
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 557ba17..1f60a22 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2410,6 +2410,29 @@ static int ieee80211_active_scan(struct 
 }
 
 
+void ieee80211_scan_completed(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	union iwreq_data wrqu;
+
+	printk(KERN_DEBUG "%s: scan completed\n", dev->name);
+	local->sta_scanning = 0;
+	local->last_scan_completed = jiffies;
+
+	memset(&wrqu, 0, sizeof(wrqu));
+	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
+
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+		if (!ifsta->bssid_set ||
+		    (!ifsta->state == IEEE80211_IBSS_JOINED &&
+		    !ieee80211_sta_active_ibss(dev)))
+			ieee80211_sta_find_ibss(dev, ifsta);
+	}
+}
+EXPORT_SYMBOL(ieee80211_scan_completed);
+
 static void ieee80211_sta_scan_work(void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -2418,7 +2441,6 @@ static void ieee80211_sta_scan_work(void
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
-	union iwreq_data wrqu;
 	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
@@ -2435,20 +2457,8 @@ static void ieee80211_sta_scan_work(void
 				       "operational channel after scan\n",
 				       dev->name);
 			}
-			printk(KERN_DEBUG "%s: scan completed\n", dev->name);
-			local->sta_scanning = 0;
-			local->last_scan_completed = jiffies;
-			memset(&wrqu, 0, sizeof(wrqu));
-			wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
-			if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
-				struct ieee80211_sub_if_data *sdata =
-					IEEE80211_DEV_TO_SUB_IF(dev);
-				struct ieee80211_if_sta *ifsta = &sdata->u.sta;
-				if (!ifsta->bssid_set ||
-				    (ifsta->state == IEEE80211_IBSS_JOINED &&
-				     !ieee80211_sta_active_ibss(dev)))
-					ieee80211_sta_find_ibss(dev, ifsta);
-			}
+
+			ieee80211_scan_completed(dev);
 			return;
 		}
 		skip = !(local->enabled_modes & (1 << mode->mode));
@@ -2549,6 +2559,13 @@ int ieee80211_sta_req_scan(struct net_de
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
+	if (local->hw->hw_scan) {
+		int rc = local->hw->hw_scan(dev, ssid, ssid_len);
+		if (!rc)
+			local->sta_scanning = 1;
+		return rc;
+	}
+
 	ieee80211_sta_save_oper_chan(dev);
 
 	local->sta_scanning = 1;
