From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/13] d80211: clean up some stupid list and loop code
Date: Sun, 19 Nov 2006 20:22:20 +0100
Message-ID: <1163964140.15473.39.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:33674 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933052AbWKSTYH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:24:07 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"for (; condition ;)"??
Ever heard of while loops?

Also clean up some list handling (still. *sigh*)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-19 20:13:52.269275208 +0100
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-19 20:13:54.109275208 +0100
@@ -1314,16 +1314,10 @@ void ieee80211_rx_bss_list_init(struct n
 void ieee80211_rx_bss_list_deinit(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_sta_bss *bss;
-	struct list_head *ptr;
+	struct ieee80211_sta_bss *bss, *tmp;
 
-	for (;;) {
-		ptr = local->sta_bss_list.next;
-		if (!ptr || ptr == &local->sta_bss_list)
-			break;
-		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
+	list_for_each_entry_safe(bss, tmp, &local->sta_bss_list, list)
 		ieee80211_rx_bss_put(dev, bss);
-	}
 }
 
 
--- wireless-dev.orig/net/d80211/sta_info.c	2006-11-19 20:13:52.339275208 +0100
+++ wireless-dev/net/d80211/sta_info.c	2006-11-19 20:13:54.119275208 +0100
@@ -324,16 +324,13 @@ static void sta_info_cleanup_expire_buff
 static void sta_info_cleanup(unsigned long data)
 {
 	struct ieee80211_local *local = (struct ieee80211_local *) data;
-	struct list_head *ptr;
+	struct sta_info *sta, *tmp;
 
 	spin_lock_bh(&local->sta_lock);
-	ptr = local->sta_list.next;
-	while (ptr && ptr != &local->sta_list) {
-		struct sta_info *sta = (struct sta_info *) ptr;
+	list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
 		__sta_info_get(sta);
 		sta_info_cleanup_expire_buffered(local, sta);
 		sta_info_put(sta);
-		ptr = ptr->next;
 	}
 	spin_unlock_bh(&local->sta_lock);
 
@@ -411,14 +408,11 @@ int sta_info_start(struct ieee80211_loca
 
 void sta_info_stop(struct ieee80211_local *local)
 {
-	struct list_head *ptr;
+	struct sta_info *sta, *tmp;
 
 	del_timer(&local->sta_cleanup);
 
-	ptr = local->sta_list.next;
-	while (ptr && ptr != &local->sta_list) {
-		struct sta_info *sta = (struct sta_info *) ptr;
-		ptr = ptr->next;
+	list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
 		/* sta_info_free must be called with 0 as the last
 		 * parameter to ensure all sysfs sta entries are
 		 * unregistered. We don't need locking at this
--- wireless-dev.orig/net/d80211/wme.c	2006-11-19 20:13:52.399275208 +0100
+++ wireless-dev/net/d80211/wme.c	2006-11-19 20:13:54.119275208 +0100
@@ -211,8 +211,7 @@ static inline int classify80211(struct s
 	skb->priority = classify_1d(skb, qd);
 
 	/* incase we are a client verify acm is not set for this ac */
-	for (; unlikely(local->wmm_acm & BIT(skb->priority)); )
-	{
+	while (unlikely(local->wmm_acm & BIT(skb->priority))) {
 		if (wme_downgrade_ac(skb)) {
 			/* No AC with lower priority has acm=0,
 			* drop packet. */


