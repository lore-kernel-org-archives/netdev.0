From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 3/5] d80211: remove rate limit code
Date: Tue, 3 Oct 2006 11:12:22 -0700
Message-ID: <20061003181222.GC19403@devicescape.com>
References: <20061003181118.537800000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Elliot Schwartz <elliot.schwartz@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-28.dex002.intermedia.net ([64.78.21.113]:28265 "EHLO
	dhost002-28.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750991AbWJCSMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:12:24 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="rate-limit-removal.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elliot Schwartz <elliot.schwartz@devicescape.com>

Remove unused and more or less pointless rate limiting code. This
would have just dropped multicast frames arbitrarily when the limit is
reached which is quite useless and does not really belong to 802.11
code.

Signed-off-by: Elliot Schwartz <elliot.schwartz@devicescape.com>

Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
@@ -58,8 +58,8 @@ enum {
 	PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES = 1001,
 	PRISM2_PARAM_DROP_UNENCRYPTED = 1002,
 	PRISM2_PARAM_PREAMBLE = 1003,
-	PRISM2_PARAM_RATE_LIMIT = 1004,
-	PRISM2_PARAM_RATE_LIMIT_BURST = 1005,
+	PRISM2_PARAM_RATE_LIMIT = 1004, /* no longer used */
+	PRISM2_PARAM_RATE_LIMIT_BURST = 1005,  /* no longer used */
 	PRISM2_PARAM_SHORT_SLOT_TIME = 1006,
 	PRISM2_PARAM_TEST_MODE = 1007,
 	PRISM2_PARAM_NEXT_MODE = 1008,
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -843,38 +843,6 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 }
 
 
-static void ieee80211_rate_limit(unsigned long data)
-{
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-
-	if (local->rate_limit) {
-                local->rate_limit_bucket += local->rate_limit;
-                if (local->rate_limit_bucket > local->rate_limit_burst)
-                        local->rate_limit_bucket = local->rate_limit_burst;
-		local->rate_limit_timer.expires = jiffies + HZ;
-		add_timer(&local->rate_limit_timer);
-	}
-}
-
-
-static ieee80211_txrx_result
-ieee80211_tx_h_rate_limit(struct ieee80211_txrx_data *tx)
-{
-
-	if (likely(!tx->local->rate_limit || tx->u.tx.unicast))
-                return TXRX_CONTINUE;
-
-	/* rate limit */
-        if (tx->local->rate_limit_bucket) {
-                tx->local->rate_limit_bucket--;
-                return TXRX_CONTINUE;
-        }
-
-	I802_DEBUG_INC(tx->local->tx_handlers_drop_rate_limit);
-	return TXRX_DROP;
-}
-
-
 static ieee80211_txrx_result
 ieee80211_tx_h_check_assoc(struct ieee80211_txrx_data *tx)
 {
@@ -4206,7 +4174,6 @@ static ieee80211_rx_handler ieee80211_rx
 
 static ieee80211_tx_handler ieee80211_tx_handlers[] =
 {
-	ieee80211_tx_h_rate_limit,
 	ieee80211_tx_h_check_assoc,
 	ieee80211_tx_h_ps_buf,
 	ieee80211_tx_h_select_key,
@@ -4369,9 +4336,6 @@ struct net_device *ieee80211_alloc_hw(si
         init_timer(&local->scan.timer); /* clear it out */
 
         spin_lock_init(&local->generic_lock);
-	init_timer(&local->rate_limit_timer);
-	local->rate_limit_timer.function = ieee80211_rate_limit;
-	local->rate_limit_timer.data = (unsigned long) local;
 	init_timer(&local->stat_timer);
 	local->stat_timer.function = ieee80211_stat_refresh;
 	local->stat_timer.data = (unsigned long) local;
@@ -4582,8 +4546,6 @@ void ieee80211_unregister_hw(struct net_
 	}
 	rtnl_unlock();
 
-	if (local->rate_limit)
-		del_timer_sync(&local->rate_limit_timer);
 	if (local->stat_time)
 		del_timer_sync(&local->stat_timer);
 	if (local->scan_work.data) {
Index: wireless-dev/net/d80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_i.h
+++ wireless-dev/net/d80211/ieee80211_i.h
@@ -470,10 +470,6 @@ struct ieee80211_local {
         u32 stat_time;
         struct timer_list stat_timer;
 
-        struct timer_list rate_limit_timer;
-        u32 rate_limit;
-        u32 rate_limit_burst;
-        u32 rate_limit_bucket;
         struct proc_dir_entry *proc, *proc_sta, *proc_iface;
 
 	struct work_struct sta_proc_add;
@@ -493,7 +489,6 @@ struct ieee80211_local {
 	unsigned int tx_handlers_drop_unencrypted;
 	unsigned int tx_handlers_drop_fragment;
 	unsigned int tx_handlers_drop_wep;
-	unsigned int tx_handlers_drop_rate_limit;
 	unsigned int tx_handlers_drop_not_assoc;
 	unsigned int tx_handlers_drop_unauth_port;
 	unsigned int rx_handlers_drop;
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -2405,25 +2405,6 @@ static int ieee80211_ioctl_prism2_param(
 		local->short_preamble = value;
 		break;
 
-	case PRISM2_PARAM_RATE_LIMIT_BURST:
-		local->rate_limit_burst = value;
-                local->rate_limit_bucket = value;
-		break;
-
-	case PRISM2_PARAM_RATE_LIMIT:
-		/* number of packets (tokens) allowed per second */
-		if (!local->rate_limit && value) {
-                        if (!local->rate_limit_burst) local->rate_limit_burst =
-				value;
-                        local->rate_limit_bucket = local->rate_limit_burst;
-			local->rate_limit_timer.expires = jiffies + HZ;
-			add_timer(&local->rate_limit_timer);
-		} else if (local->rate_limit && !value) {
-			del_timer_sync(&local->rate_limit_timer);
-		}
-		local->rate_limit = value;
-		break;
-
         case PRISM2_PARAM_STAT_TIME:
                 if (!local->stat_time && value) {
                         local->stat_timer.expires = jiffies + HZ * value / 100;
@@ -2656,14 +2637,6 @@ static int ieee80211_ioctl_get_prism2_pa
 		*param = local->short_preamble;
 		break;
 
-	case PRISM2_PARAM_RATE_LIMIT_BURST:
-		*param = local->rate_limit_burst;
-		break;
-
-	case PRISM2_PARAM_RATE_LIMIT:
-		*param = local->rate_limit;
-		break;
-
         case PRISM2_PARAM_STAT_TIME:
                 *param = local->stat_time;
                 break;
Index: wireless-dev/net/d80211/ieee80211_sysfs.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c
+++ wireless-dev/net/d80211/ieee80211_sysfs.c
@@ -241,7 +241,6 @@ IEEE80211_LOCAL_ATTR(tx_handlers_queued,
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_unencrypted, tx_handlers_drop_unencrypted, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_fragment, tx_handlers_drop_fragment, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_wep, tx_handlers_drop_wep, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_rate_limit, tx_handlers_drop_rate_limit, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_not_assoc, tx_handlers_drop_not_assoc, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_unauth_port, tx_handlers_drop_unauth_port, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_drop, rx_handlers_drop, "%u");
@@ -352,7 +351,6 @@ static struct attribute *ieee80211_stats
 	&class_device_attr_tx_handlers_drop_unencrypted.attr,
 	&class_device_attr_tx_handlers_drop_fragment.attr,
 	&class_device_attr_tx_handlers_drop_wep.attr,
-	&class_device_attr_tx_handlers_drop_rate_limit.attr,
 	&class_device_attr_tx_handlers_drop_not_assoc.attr,
 	&class_device_attr_tx_handlers_drop_unauth_port.attr,
 	&class_device_attr_rx_handlers_drop.attr,

--
