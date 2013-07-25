From: Fabio Baltieri <fabio.baltieri@gmail.com>
Subject: [PATCH v2] mac80211: use oneshot blink API for LED triggers
Date: Thu, 25 Jul 2013 12:00:26 +0200
Message-ID: <1374746426-22030-1-git-send-email-fabio.baltieri@gmail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Fabio Baltieri <fabio.baltieri@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change mac80211 LED trigger code to use the generic
led_trigger_blink_oneshot() API for transmit and receive activity
indication.

This gives a better feedback to the user, as with the new API each
activity event results in a visible blink, while a constant traffic
results in a continuous blink at constant rate.

Signed-off-by: Fabio Baltieri <fabio.baltieri@gmail.com>
---

Changes from v1:
- fixed some wrong indentations

 net/mac80211/ieee80211_i.h |  1 -
 net/mac80211/led.c         | 19 +++++++------------
 net/mac80211/led.h         |  2 +-
 net/mac80211/status.c      |  2 +-
 net/mac80211/tx.c          |  1 -
 5 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8412a30..1178139 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1063,7 +1063,6 @@ struct ieee80211_local {
 	u32 dot11TransmittedFrameCount;
 
 #ifdef CONFIG_MAC80211_LEDS
-	int tx_led_counter, rx_led_counter;
 	struct led_trigger *tx_led, *rx_led, *assoc_led, *radio_led;
 	struct tpt_led_trigger *tpt_led_trigger;
 	char tx_led_name[32], rx_led_name[32],
diff --git a/net/mac80211/led.c b/net/mac80211/led.c
index bcffa69..e2b8364 100644
--- a/net/mac80211/led.c
+++ b/net/mac80211/led.c
@@ -12,27 +12,22 @@
 #include <linux/export.h>
 #include "led.h"
 
+#define MAC80211_BLINK_DELAY 50 /* ms */
+
 void ieee80211_led_rx(struct ieee80211_local *local)
 {
+	unsigned long led_delay = MAC80211_BLINK_DELAY;
 	if (unlikely(!local->rx_led))
 		return;
-	if (local->rx_led_counter++ % 2 == 0)
-		led_trigger_event(local->rx_led, LED_OFF);
-	else
-		led_trigger_event(local->rx_led, LED_FULL);
+	led_trigger_blink_oneshot(local->rx_led, &led_delay, &led_delay, 0);
 }
 
-/* q is 1 if a packet was enqueued, 0 if it has been transmitted */
-void ieee80211_led_tx(struct ieee80211_local *local, int q)
+void ieee80211_led_tx(struct ieee80211_local *local)
 {
+	unsigned long led_delay = MAC80211_BLINK_DELAY;
 	if (unlikely(!local->tx_led))
 		return;
-	/* not sure how this is supposed to work ... */
-	local->tx_led_counter += 2*q-1;
-	if (local->tx_led_counter % 2 == 0)
-		led_trigger_event(local->tx_led, LED_OFF);
-	else
-		led_trigger_event(local->tx_led, LED_FULL);
+	led_trigger_blink_oneshot(local->tx_led, &led_delay, &led_delay, 0);
 }
 
 void ieee80211_led_assoc(struct ieee80211_local *local, bool associated)
diff --git a/net/mac80211/led.h b/net/mac80211/led.h
index e0275d9..6ca2f29 100644
--- a/net/mac80211/led.h
+++ b/net/mac80211/led.h
@@ -13,7 +13,7 @@
 
 #ifdef CONFIG_MAC80211_LEDS
 void ieee80211_led_rx(struct ieee80211_local *local);
-void ieee80211_led_tx(struct ieee80211_local *local, int q);
+void ieee80211_led_tx(struct ieee80211_local *local);
 void ieee80211_led_assoc(struct ieee80211_local *local,
 			 bool associated);
 void ieee80211_led_radio(struct ieee80211_local *local,
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 4343920..e3c889b 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -557,7 +557,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	rcu_read_unlock();
 
-	ieee80211_led_tx(local, 0);
+	ieee80211_led_tx(local);
 
 	/* SNMP counters
 	 * Fragments are passed to low-level drivers as separate skbs, so these
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 4105d0c..6c4e60d 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1281,7 +1281,6 @@ static bool __ieee80211_tx(struct ieee80211_local *local,
 				    txpending);
 
 	ieee80211_tpt_led_trig_tx(local, fc, led_len);
-	ieee80211_led_tx(local, 1);
 
 	WARN_ON_ONCE(!skb_queue_empty(skbs));
 
-- 
1.8.2
