From: greearb@candelatech.com
Subject: [PATCH v2] mac80211:  Optimize scans on current operating channel.
Date: Fri, 21 Jan 2011 10:03:08 -0800
Message-ID: <1295632988-7227-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41449 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1AUSDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 13:03:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This should decrease un-necessary flushes, on/off channel work,
and channel changes in cases where the only scanned channel is
the current operating channel.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v2:  Check channels instead of flag when determining if we should
  do a channel change in scan_completed_finish.

:100644 100644 c47d7c0... 59fe5e7... M	net/mac80211/ieee80211_i.h
:100644 100644 1236710... e6de0e7... M	net/mac80211/rx.c
:100644 100644 3e660db... fa0aeb9... M	net/mac80211/scan.c
 net/mac80211/ieee80211_i.h |    5 +++++
 net/mac80211/rx.c          |   11 ++++++++---
 net/mac80211/scan.c        |   41 +++++++++++++++++++++++++----------------
 3 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index c47d7c0..59fe5e7 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -660,6 +660,10 @@ struct tpt_led_trigger {
  *	that the scan completed.
  * @SCAN_ABORTED: Set for our scan work function when the driver reported
  *	a scan complete for an aborted scan.
+ * @SCAN_LEFT_OPER_CHANNEL:  Set this flag if the scan process leaves the
+ *      operating channel at any time.  If scanning ONLY the current operating
+ *      channel this flag should not be set, and this will allow fewer
+ *      offchannel changes.
  */
 enum {
 	SCAN_SW_SCANNING,
@@ -667,6 +671,7 @@ enum {
 	SCAN_OFF_CHANNEL,
 	SCAN_COMPLETED,
 	SCAN_ABORTED,
+	SCAN_LEFT_OPER_CHANNEL,
 };
 
 /**
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 1236710..e6de0e7 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -388,6 +388,7 @@ ieee80211_rx_h_passive_scan(struct ieee80211_rx_data *rx)
 	struct ieee80211_local *local = rx->local;
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(rx->skb);
 	struct sk_buff *skb = rx->skb;
+	int ret;
 
 	if (likely(!(status->rx_flags & IEEE80211_RX_IN_SCAN)))
 		return RX_CONTINUE;
@@ -396,10 +397,14 @@ ieee80211_rx_h_passive_scan(struct ieee80211_rx_data *rx)
 		return ieee80211_scan_rx(rx->sdata, skb);
 
 	if (test_bit(SCAN_SW_SCANNING, &local->scanning)) {
-		/* drop all the other packets during a software scan anyway */
-		if (ieee80211_scan_rx(rx->sdata, skb) != RX_QUEUED)
+		ret = ieee80211_scan_rx(rx->sdata, skb);
+		/* drop all the other packets while scanning off channel */
+		if (ret != RX_QUEUED &&
+		    test_bit(SCAN_OFF_CHANNEL, &local->scanning)) {
 			dev_kfree_skb(skb);
-		return RX_QUEUED;
+			return RX_QUEUED;
+		}
+		return ret;
 	}
 
 	/* scanning finished during invoking of handlers */
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 3e660db..fa0aeb9 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -293,11 +293,14 @@ static void __ieee80211_scan_completed_finish(struct ieee80211_hw *hw,
 {
 	struct ieee80211_local *local = hw_to_local(hw);
 
-	ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
+	if ((local->oper_channel != local->hw.conf.channel) || was_hw_scan)
+		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
+
 	if (!was_hw_scan) {
 		ieee80211_configure_filter(local);
 		drv_sw_scan_complete(local);
-		ieee80211_offchannel_return(local, true);
+		if (test_bit(SCAN_LEFT_OPER_CHANNEL, &local->scanning))
+			ieee80211_offchannel_return(local, true);
 	}
 
 	mutex_lock(&local->mtx);
@@ -397,13 +400,10 @@ static int ieee80211_start_sw_scan(struct ieee80211_local *local)
 
 	drv_sw_scan_start(local);
 
-	ieee80211_offchannel_stop_beaconing(local);
-
 	local->leave_oper_channel_time = 0;
 	local->next_scan_state = SCAN_DECISION;
 	local->scan_channel_idx = 0;
-
-	drv_flush(local, false);
+	__clear_bit(SCAN_LEFT_OPER_CHANNEL, &local->scanning);
 
 	ieee80211_configure_filter(local);
 
@@ -543,7 +543,18 @@ static void ieee80211_scan_state_decision(struct ieee80211_local *local,
 	}
 	mutex_unlock(&local->iflist_mtx);
 
-	if (local->scan_channel) {
+	next_chan = local->scan_req->channels[local->scan_channel_idx];
+
+	if (local->oper_channel == local->hw.conf.channel) {
+		if (next_chan == local->oper_channel)
+			local->next_scan_state = SCAN_SET_CHANNEL;
+		else
+			/*
+			 * we're on the operating channel currently, let's
+			 * leave that channel now to scan another one
+			 */
+			local->next_scan_state = SCAN_LEAVE_OPER_CHANNEL;
+	} else {
 		/*
 		 * we're currently scanning a different channel, let's
 		 * see if we can scan another channel without interfering
@@ -559,7 +570,6 @@ static void ieee80211_scan_state_decision(struct ieee80211_local *local,
 		 *
 		 * Otherwise switch back to the operating channel.
 		 */
-		next_chan = local->scan_req->channels[local->scan_channel_idx];
 
 		bad_latency = time_after(jiffies +
 				ieee80211_scan_get_channel_time(next_chan),
@@ -577,12 +587,6 @@ static void ieee80211_scan_state_decision(struct ieee80211_local *local,
 			local->next_scan_state = SCAN_ENTER_OPER_CHANNEL;
 		else
 			local->next_scan_state = SCAN_SET_CHANNEL;
-	} else {
-		/*
-		 * we're on the operating channel currently, let's
-		 * leave that channel now to scan another one
-		 */
-		local->next_scan_state = SCAN_LEAVE_OPER_CHANNEL;
 	}
 
 	*next_delay = 0;
@@ -591,9 +595,12 @@ static void ieee80211_scan_state_decision(struct ieee80211_local *local,
 static void ieee80211_scan_state_leave_oper_channel(struct ieee80211_local *local,
 						    unsigned long *next_delay)
 {
+	ieee80211_offchannel_stop_beaconing(local);
+
 	ieee80211_offchannel_stop_station(local);
 
 	__set_bit(SCAN_OFF_CHANNEL, &local->scanning);
+	__set_bit(SCAN_LEFT_OPER_CHANNEL, &local->scanning);
 
 	/*
 	 * What if the nullfunc frames didn't arrive?
@@ -640,8 +647,10 @@ static void ieee80211_scan_state_set_channel(struct ieee80211_local *local,
 	chan = local->scan_req->channels[local->scan_channel_idx];
 
 	local->scan_channel = chan;
-	if (ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL))
-		skip = 1;
+
+	if (chan != local->hw.conf.channel)
+		if (ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL))
+			skip = 1;
 
 	/* advance state machine to next channel/band */
 	local->scan_channel_idx++;
-- 
1.7.2.3

