From: greearb@candelatech.com
Subject: [RFC] mac80211:  Support on-channel scan option.
Date: Sat, 31 Mar 2012 15:29:29 -0700
Message-ID: <1333232969-3190-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46277 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab2CaW3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 18:29:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This based on an idea posted by Stanislaw Gruszka,
though I accept full blame for the implementation!

This is compile-tested only at this point.

The idea is to let users scan on the current operating
channel without interrupting normal traffic more than
absolutely necessary (changing power level might reset
some hardware, for instance).

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 d9798a3... b64d3c3... M	net/mac80211/ieee80211_i.h
:100644 100644 1633648... 5bee3ea... M	net/mac80211/main.c
:100644 100644 bcfe8c7... c4d7a50... M	net/mac80211/rx.c
:100644 100644 c70e176... 591fdea... M	net/mac80211/scan.c
 net/mac80211/ieee80211_i.h |    3 ++
 net/mac80211/main.c        |    4 ++-
 net/mac80211/rx.c          |    2 +
 net/mac80211/scan.c        |   80 ++++++++++++++++++++++++++++++-------------
 4 files changed, 64 insertions(+), 25 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index d9798a3..b64d3c3 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -785,6 +785,8 @@ struct tpt_led_trigger {
  *	well be on the operating channel
  * @SCAN_HW_SCANNING: The hardware is scanning for us, we have no way to
  *	determine if we are on the operating channel or not
+ * @SCAN_ONCHANNEL_SCANNING:  Do a software scan on only the current operating
+ *	channel. This should not interrupt normal traffic.
  * @SCAN_COMPLETED: Set for our scan work function when the driver reported
  *	that the scan completed.
  * @SCAN_ABORTED: Set for our scan work function when the driver reported
@@ -793,6 +795,7 @@ struct tpt_led_trigger {
 enum {
 	SCAN_SW_SCANNING,
 	SCAN_HW_SCANNING,
+	SCAN_ONCHANNEL_SCANNING,
 	SCAN_COMPLETED,
 	SCAN_ABORTED,
 };
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 1633648..5bee3ea 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -47,7 +47,8 @@ void ieee80211_configure_filter(struct ieee80211_local *local)
 	if (atomic_read(&local->iff_allmultis))
 		new_flags |= FIF_ALLMULTI;
 
-	if (local->monitors || test_bit(SCAN_SW_SCANNING, &local->scanning))
+	if (local->monitors || test_bit(SCAN_SW_SCANNING, &local->scanning) ||
+	    test_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning))
 		new_flags |= FIF_BCN_PRBRESP_PROMISC;
 
 	if (local->fif_probe_req || local->probe_req_reg)
@@ -148,6 +149,7 @@ int ieee80211_hw_config(struct ieee80211_local *local, u32 changed)
 	}
 
 	if (test_bit(SCAN_SW_SCANNING, &local->scanning) ||
+	    test_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning) ||
 	    test_bit(SCAN_HW_SCANNING, &local->scanning))
 		power = chan->max_power;
 	else
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index bcfe8c7..c4d7a50 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -425,6 +425,7 @@ ieee80211_rx_h_passive_scan(struct ieee80211_rx_data *rx)
 
 	if (test_bit(SCAN_HW_SCANNING, &local->scanning) ||
 	    test_bit(SCAN_SW_SCANNING, &local->scanning) ||
+	    test_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning) ||
 	    local->sched_scanning)
 		return ieee80211_scan_rx(rx->sdata, skb);
 
@@ -2919,6 +2920,7 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 		local->dot11ReceivedFragmentCount++;
 
 	if (unlikely(test_bit(SCAN_HW_SCANNING, &local->scanning) ||
+		     test_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning) ||
 		     test_bit(SCAN_SW_SCANNING, &local->scanning)))
 		status->rx_flags |= IEEE80211_RX_IN_SCAN;
 
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index c70e176..591fdea 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -387,6 +387,29 @@ static int ieee80211_start_sw_scan(struct ieee80211_local *local)
 	return 0;
 }
 
+static void ieee80211_scan_state_send_probe(struct ieee80211_local *local,
+					    unsigned long *next_delay)
+{
+	int i;
+	struct ieee80211_sub_if_data *sdata = local->scan_sdata;
+	enum ieee80211_band band = local->hw.conf.channel->band;
+
+	for (i = 0; i < local->scan_req->n_ssids; i++)
+		ieee80211_send_probe_req(
+			sdata, NULL,
+			local->scan_req->ssids[i].ssid,
+			local->scan_req->ssids[i].ssid_len,
+			local->scan_req->ie, local->scan_req->ie_len,
+			local->scan_req->rates[band], false,
+			local->scan_req->no_cck);
+
+	/*
+	 * After sending probe requests, wait for probe responses
+	 * on the channel.
+	 */
+	*next_delay = IEEE80211_CHANNEL_TIME;
+	local->next_scan_state = SCAN_DECISION;
+}
 
 static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 				  struct cfg80211_scan_request *req)
@@ -438,6 +461,33 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 	local->scan_req = req;
 	local->scan_sdata = sdata;
 
+	/* If we are scanning only on the current channel, then
+	 * we do not need to stop normal activities
+	 */
+	if ((req->n_channels == 1) &&
+	    (req->channels[0]->center_freq ==
+	     local->hw.conf.channel->center_freq)) {
+		unsigned long next_delay;
+		__set_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning);
+		ieee80211_recalc_idle(local);
+		ieee80211_configure_filter(local); /* accept probe-responses */
+		/* We need to set power level at maximum rate for scanning. */
+		ieee80211_hw_config(local, 0);
+
+		if (req->channels[0]->flags & IEEE80211_CHAN_PASSIVE_SCAN ||
+		    !local->scan_req->n_ssids) {
+			next_delay = IEEE80211_PASSIVE_CHANNEL_TIME;
+		} else {
+			ieee80211_scan_state_send_probe(local, &next_delay);
+			next_delay = IEEE80211_CHANNEL_TIME;
+		}
+
+		/* Now, just wait a bit and we are all done! */
+		ieee80211_queue_delayed_work(&local->hw, &local->scan_work,
+					     next_delay);
+		return 0;
+	}
+
 	if (local->ops->hw_scan)
 		__set_bit(SCAN_HW_SCANNING, &local->scanning);
 	else
@@ -598,30 +648,6 @@ static void ieee80211_scan_state_set_channel(struct ieee80211_local *local,
 	local->next_scan_state = SCAN_SEND_PROBE;
 }
 
-static void ieee80211_scan_state_send_probe(struct ieee80211_local *local,
-					    unsigned long *next_delay)
-{
-	int i;
-	struct ieee80211_sub_if_data *sdata = local->scan_sdata;
-	enum ieee80211_band band = local->hw.conf.channel->band;
-
-	for (i = 0; i < local->scan_req->n_ssids; i++)
-		ieee80211_send_probe_req(
-			sdata, NULL,
-			local->scan_req->ssids[i].ssid,
-			local->scan_req->ssids[i].ssid_len,
-			local->scan_req->ie, local->scan_req->ie_len,
-			local->scan_req->rates[band], false,
-			local->scan_req->no_cck);
-
-	/*
-	 * After sending probe requests, wait for probe responses
-	 * on the channel.
-	 */
-	*next_delay = IEEE80211_CHANNEL_TIME;
-	local->next_scan_state = SCAN_DECISION;
-}
-
 static void ieee80211_scan_state_suspend(struct ieee80211_local *local,
 					 unsigned long *next_delay)
 {
@@ -672,6 +698,12 @@ void ieee80211_scan_work(struct work_struct *work)
 
 	sdata = local->scan_sdata;
 
+	/* When scanning on-channel, the first-callback means completeed. */
+	if (test_and_clear_bit(SCAN_ONCHANNEL_SCANNING, &local->scanning)) {
+		aborted = test_and_clear_bit(SCAN_ABORTED, &local->scanning);
+		goto out_complete;
+	}
+
 	if (test_and_clear_bit(SCAN_COMPLETED, &local->scanning)) {
 		aborted = test_and_clear_bit(SCAN_ABORTED, &local->scanning);
 		goto out_complete;
-- 
1.7.3.4
