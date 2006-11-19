From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 13/13] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 20:33:12 +0100
Message-ID: <1163964793.15473.65.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:51900 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933074AbWKSTgP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:36:15 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If hardware shall do scanning, the hw_scan operation must be set. However,
if the driver is for multiple cards that may or may not do hardware
scanning, it'll need a flag.

Similar issues arise with passive_scan().

This patch introduces flags to fix these issues.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 20:14:02.959275208 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 20:14:03.619275208 +0100
@@ -504,6 +504,12 @@ struct ieee80211_hw {
 	/* do hardware fragmentation */
 #define IEEE80211_HW_FRAG (1<<15)
 
+	/* hardware does scanning instead of software */
+#define IEEE80211_HW_PASSIVE_SCAN (1<<16)
+
+	/* hardware does scanning instead of software */
+#define IEEE80211_HW_SCAN (1<<17)
+
 	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
@@ -625,7 +631,8 @@ struct ieee80211_ops {
                             struct ieee80211_scan_conf *conf);
 
 	/* Ask the hardware to service the scan request, no need to start
-	 * the scan state machine in stack. */
+	 * the scan state machine in stack.
+	 * This callback goes along with the IEEE80211_HW_SCAN flag. */
 	int (*hw_scan)(struct ieee80211_hw *hw, u8 *ssid, size_t len);
 
         /* return low-level statistics */
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-19 20:13:58.049275208 +0100
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-19 20:14:03.619275208 +0100
@@ -2552,7 +2552,7 @@ int ieee80211_sta_req_scan(struct net_de
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
-	if (local->ops->hw_scan) {
+	if (local->ops->hw_scan && (local->hw.flags & IEEE80211_HW_SCAN)) {
 		int rc = local->ops->hw_scan(local_to_hw(local),
 					    ssid, ssid_len);
 		if (!rc) {
--- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-11-19 20:13:58.049275208 +0100
+++ wireless-dev/net/d80211/ieee80211_scan.c	2006-11-19 20:14:03.629275208 +0100
@@ -114,7 +114,8 @@ static void ieee80211_scan_start(struct 
 	struct ieee80211_channel *chan = NULL;
 	int ret;
 
-	if (!local->ops->passive_scan) {
+	if (!local->ops->passive_scan ||
+	    !(local->hw.flags & IEEE80211_HW_PASSIVE_SCAN)) {
 		printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
 		       "does not support passive scanning. Disabled.\n",
 		       local->mdev->name);


