From: Hong Liu <hong.liu@intel.com>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Fri, 01 Sep 2006 11:37:47 +0800
Message-ID: <1157081867.11040.41.camel@devlinux-hong>
References: <1156494733.21483.14.camel@devlinux-hong>
	 <20060830191058.14275f74@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24886 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751042AbWIADmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 23:42:10 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060830191058.14275f74@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 01:10, Jiri Benc wrote:
> On Fri, 25 Aug 2006 16:32:13 +0800, Hong Liu wrote:
> > Add hardware scan callback to support cards like ipw3945 which
> > implements the scan command in firmware.
> 
> How ipw3945 performs scan? From the patch, it looks like it switches
> channels (and sends probe requests) in the firmware and delivers all
> received beacons and probe responses through the normal rx path to be
> handled in a software MAC layer. This is really weird behaviour and
> doesn't make sense to me. Why isn't channel switching left to the
> software MAC as well?
> 
> > +/* set station scan completed */
> > +void ieee80211_set_scan_completed(struct net_device *dev);
> 
> Why "set"? "ieee80211_scan_completed" sounds better.
> 
> Thanks,
> 
>  Jiri
> 
> --
> Jiri Benc
> SUSE Labs
> 


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
 
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 557ba17..8541a52 100644
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
@@ -2549,9 +2559,12 @@ int ieee80211_sta_req_scan(struct net_de
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
+	local->sta_scanning = 1;
+	if (local->hw->hw_scan)
+		return local->hw->hw_scan(dev, ssid, ssid_len);
+
 	ieee80211_sta_save_oper_chan(dev);
 
-	local->sta_scanning = 1;
 	/* TODO: stop TX queue? */
 
 	if (ssid) {
