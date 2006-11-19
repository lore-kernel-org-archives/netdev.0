From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 5/13] d80211: reduce master ieee80211_ptr deref in scan
	routines
Date: Sun, 19 Nov 2006 20:27:17 +0100
Message-ID: <1163964437.15473.49.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59064 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933059AbWKST3M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:29:12 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes a bunch of prototypes to have struct ieee80211_local*
instead of struct net_device* where that makes sense.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:13:56.719275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:13:57.379275208 +0100
@@ -2266,7 +2266,7 @@ static int ieee80211_open(struct net_dev
 				local->hw->remove_interface(dev, &conf);
 			return res;
 		}
-		ieee80211_init_scan(local->mdev);
+		ieee80211_init_scan(local);
 	}
         local->open_count++;
 
@@ -2303,7 +2303,7 @@ static int ieee80211_stop(struct net_dev
 
 	local->open_count--;
         if (local->open_count == 0) {
-		ieee80211_stop_scan(local->mdev);
+		ieee80211_stop_scan(local);
 		dev_close(local->mdev);
 		if (local->apdev)
 			dev_close(local->apdev);
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-11-19 20:13:56.719275208 +0100
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-11-19 20:13:57.379275208 +0100
@@ -593,8 +593,8 @@ int ieee80211_set_hw_encryption(struct n
 				struct ieee80211_key *key);
 
 /* ieee80211_scan.c */
-void ieee80211_init_scan(struct net_device *dev);
-void ieee80211_stop_scan(struct net_device *dev);
+void ieee80211_init_scan(struct ieee80211_local *local);
+void ieee80211_stop_scan(struct ieee80211_local *local);
 
 
 
--- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-11-19 20:13:50.889275208 +0100
+++ wireless-dev/net/d80211/ieee80211_scan.c	2006-11-19 20:13:57.379275208 +0100
@@ -105,10 +105,9 @@ static void next_chan_all_modes(struct i
 }
 
 
-static void ieee80211_scan_start(struct net_device *dev,
+static void ieee80211_scan_start(struct ieee80211_local *local,
 				 struct ieee80211_scan_conf *conf)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int old_mode_idx = local->scan.mode_idx;
 	int old_chan_idx = local->scan.chan_idx;
 	struct ieee80211_hw_modes *mode = NULL;
@@ -118,7 +117,7 @@ static void ieee80211_scan_start(struct 
 	if (!local->hw->passive_scan) {
 		printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
 		       "does not support passive scanning. Disabled.\n",
-		       dev->name);
+		       local->mdev->name);
 		return;
 	}
 
@@ -136,7 +135,7 @@ static void ieee80211_scan_start(struct 
 
 	if (!local->scan.skb) {
 		printk(KERN_DEBUG "%s: Scan start called even though scan.skb "
-		       "is not set\n", dev->name);
+		       "is not set\n", local->mdev->name);
 	}
 
 	if (local->scan.our_mode_only) {
@@ -163,7 +162,7 @@ static void ieee80211_scan_start(struct 
 #if 0
 	printk(KERN_DEBUG "%s: Doing scan on mode: %d freq: %d chan: %d "
 	       "for %d ms\n",
-	       dev->name, conf->scan_phymode, conf->scan_freq,
+	       local->mdev->name, conf->scan_phymode, conf->scan_freq,
 	       conf->scan_channel, conf->scan_time);
 #endif
 	local->scan.rx_packets = 0;
@@ -171,9 +170,9 @@ static void ieee80211_scan_start(struct 
 	local->scan.freq = chan->freq;
 	local->scan.in_scan = 1;
 
-	ieee80211_netif_oper(dev, NETIF_STOP);
+	ieee80211_netif_oper(local->mdev, NETIF_STOP);
 
-	ret = local->hw->passive_scan(dev, IEEE80211_SCAN_START, conf);
+	ret = local->hw->passive_scan(local->mdev, IEEE80211_SCAN_START, conf);
 
 	if (ret == 0) {
 		long usec = local->hw->channel_change_time +
@@ -185,7 +184,7 @@ static void ieee80211_scan_start(struct 
 		local->scan.in_scan = 0;
 		if (conf->skb)
 			dev_kfree_skb(conf->skb);
-		ieee80211_netif_oper(dev, NETIF_WAKE);
+		ieee80211_netif_oper(local->mdev, NETIF_WAKE);
 		if (ret == -EAGAIN) {
 			local->scan.timer.expires = jiffies +
 				(local->scan.interval * HZ / 100);
@@ -193,7 +192,7 @@ static void ieee80211_scan_start(struct 
 			local->scan.chan_idx = old_chan_idx;
 		} else {
 			printk(KERN_DEBUG "%s: Got unknown error from "
-			       "passive_scan %d\n", dev->name, ret);
+			       "passive_scan %d\n", local->mdev->name, ret);
 			local->scan.timer.expires = jiffies +
 				(local->scan.interval * HZ);
 		}
@@ -204,10 +203,9 @@ static void ieee80211_scan_start(struct 
 }
 
 
-static void ieee80211_scan_stop(struct net_device *dev,
+static void ieee80211_scan_stop(struct ieee80211_local *local,
 				struct ieee80211_scan_conf *conf)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int wait;
@@ -228,12 +226,12 @@ static void ieee80211_scan_stop(struct n
 
 	chan = &mode->channels[local->scan.chan_idx];
 
-	local->hw->passive_scan(dev, IEEE80211_SCAN_END, conf);
+	local->hw->passive_scan(local->mdev, IEEE80211_SCAN_END, conf);
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	printk(KERN_DEBUG "%s: Did scan on mode: %d freq: %d chan: %d "
 	       "GOT: %d Beacon: %d (%d)\n",
-	       dev->name,
+	       local->mdev->name,
 	       mode->mode, chan->freq, chan->chan,
 	       local->scan.rx_packets, local->scan.rx_beacon,
 	       local->scan.tries);
@@ -241,7 +239,7 @@ static void ieee80211_scan_stop(struct n
 	local->scan.num_scans++;
 
 	local->scan.in_scan = 0;
-	ieee80211_netif_oper(dev, NETIF_WAKE);
+	ieee80211_netif_oper(local->mdev, NETIF_WAKE);
 
 	local->scan.tries = 0;
 	/* Use random interval of scan.interval .. 2 * scan.interval */
@@ -253,10 +251,9 @@ static void ieee80211_scan_stop(struct n
 }
 
 
-static void ieee80211_scan_handler(unsigned long uldev)
+static void ieee80211_scan_handler(unsigned long ullocal)
 {
-        struct net_device *dev = (struct net_device *) uldev;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_local *local = (struct ieee80211_local *) ullocal;
 	struct ieee80211_scan_conf conf;
 
 	if (local->scan.interval == 0 && !local->scan.in_scan) {
@@ -276,15 +273,14 @@ static void ieee80211_scan_handler(unsig
         conf.running_antenna_max = local->conf.antenna_max;
 
 	if (local->scan.in_scan == 0)
-		ieee80211_scan_start(dev, &conf);
+		ieee80211_scan_start(local, &conf);
 	else
-		ieee80211_scan_stop(dev, &conf);
+		ieee80211_scan_stop(local, &conf);
 }
 
 
-void ieee80211_init_scan(struct net_device *dev)
+void ieee80211_init_scan(struct ieee80211_local *local)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hdr hdr;
 	u16 fc;
 	int len = 10;
@@ -296,7 +292,7 @@ void ieee80211_init_scan(struct net_devi
 		memset(&local->scan.tx_control, 0,
 		       sizeof(local->scan.tx_control));
 		printk(KERN_DEBUG "%s: Does not support passive scan, "
-		       "disabled\n", dev->name);
+		       "disabled\n", local->mdev->name);
 		return;
 	}
 
@@ -304,7 +300,7 @@ void ieee80211_init_scan(struct net_devi
 	local->scan.our_mode_only = 1;
 	local->scan.time = 10000;
 	local->scan.timer.function = ieee80211_scan_handler;
-	local->scan.timer.data = (unsigned long) dev;
+	local->scan.timer.data = (unsigned long) local;
 	local->scan.timer.expires = jiffies + local->scan.interval * HZ;
 	add_timer(&local->scan.timer);
 
@@ -313,7 +309,7 @@ void ieee80211_init_scan(struct net_devi
 	local->scan.skb = alloc_skb(len, GFP_KERNEL);
 	if (!local->scan.skb) {
 		printk(KERN_WARNING "%s: Failed to allocate CTS packet for "
-		       "passive scan\n", dev->name);
+		       "passive scan\n", local->mdev->name);
 		return;
 	}
 
@@ -322,7 +318,7 @@ void ieee80211_init_scan(struct net_devi
 	hdr.duration_id =
 		cpu_to_le16(2 * local->hw->channel_change_time +
 			    local->scan.time);
-	memcpy(hdr.addr1, dev->dev_addr, ETH_ALEN); /* DA */
+	memcpy(hdr.addr1, local->mdev->dev_addr, ETH_ALEN); /* DA */
 	hdr.seq_ctrl = 0;
 
 	memcpy(skb_put(local->scan.skb, len), &hdr, len);
@@ -333,15 +329,14 @@ void ieee80211_init_scan(struct net_devi
 	memset(&extra, 0, sizeof(extra));
 	extra.endidx = local->num_curr_rates;
 	local->scan.tx_control.tx_rate =
-		rate_control_get_rate(local, dev, local->scan.skb, &extra)->val;
+		rate_control_get_rate(local, local->mdev,
+				      local->scan.skb, &extra)->val;
 	local->scan.tx_control.flags |= IEEE80211_TXCTL_NO_ACK;
 }
 
 
-void ieee80211_stop_scan(struct net_device *dev)
+void ieee80211_stop_scan(struct ieee80211_local *local)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-
 	if (local->hw->passive_scan) {
 		del_timer_sync(&local->scan.timer);
 		dev_kfree_skb(local->scan.skb);


