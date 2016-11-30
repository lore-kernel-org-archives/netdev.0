From: =?UTF-8?q?Micha=C5=82=20K=C4=99pie=C5=84?= <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
Subject: [PATCH 2/2] net: rfkill: Add rfkill-any LED trigger
Date: Wed, 30 Nov 2016 13:03:17 +0100
Message-ID: <20161130120317.11851-2-kernel@kempniu.pl>
References: <20161130120317.11851-1-kernel@kempniu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161130120317.11851-1-kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new "global" (i.e. not per-rfkill device) LED trigger,
rfkill-any, which may be useful for laptops with a single "radio LED"
and multiple radio transmitters.  The trigger is meant to turn a LED on
whenever there is at least one radio transmitter active and turn it off
otherwise.

Signed-off-by: Michał Kępień <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
---
Note that the search for any active radio will have quadratic complexity
whenever __rfkill_switch_all() is used (as it calls rfkill_set_block()
for every affected rfkill device), but I intentionally refrained from
implementing rfkill_any_led_trigger_event() using struct work_struct to
keep things simple, given the average number of rfkill devices in
hardware these days.  Please let me know in case this should be
reworked.

 net/rfkill/core.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index f28e441..5275f2f 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -176,6 +176,47 @@ static void rfkill_led_trigger_unregister(struct rfkill *rfkill)
 {
 	led_trigger_unregister(&rfkill->led_trigger);
 }
+
+static struct led_trigger rfkill_any_led_trigger;
+
+static void __rfkill_any_led_trigger_event(void)
+{
+	enum led_brightness brightness = LED_OFF;
+	struct rfkill *rfkill;
+
+	list_for_each_entry(rfkill, &rfkill_list, node) {
+		if (!(rfkill->state & RFKILL_BLOCK_ANY)) {
+			brightness = LED_FULL;
+			break;
+		}
+	}
+
+	led_trigger_event(&rfkill_any_led_trigger, brightness);
+}
+
+static void rfkill_any_led_trigger_event(void)
+{
+	mutex_lock(&rfkill_global_mutex);
+	__rfkill_any_led_trigger_event();
+	mutex_unlock(&rfkill_global_mutex);
+}
+
+static void rfkill_any_led_trigger_activate(struct led_classdev *led_cdev)
+{
+	rfkill_any_led_trigger_event();
+}
+
+static int rfkill_any_led_trigger_register(void)
+{
+	rfkill_any_led_trigger.name = "rfkill-any";
+	rfkill_any_led_trigger.activate = rfkill_any_led_trigger_activate;
+	return led_trigger_register(&rfkill_any_led_trigger);
+}
+
+static void rfkill_any_led_trigger_unregister(void)
+{
+	led_trigger_unregister(&rfkill_any_led_trigger);
+}
 #else
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
@@ -189,6 +230,19 @@ static inline int rfkill_led_trigger_register(struct rfkill *rfkill)
 static inline void rfkill_led_trigger_unregister(struct rfkill *rfkill)
 {
 }
+
+static void rfkill_any_led_trigger_event(void)
+{
+}
+
+static int rfkill_any_led_trigger_register(void)
+{
+	return 0;
+}
+
+static void rfkill_any_led_trigger_unregister(void)
+{
+}
 #endif /* CONFIG_RFKILL_LEDS */
 
 static void rfkill_fill_event(struct rfkill_event *ev, struct rfkill *rfkill,
@@ -297,6 +351,7 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	__rfkill_any_led_trigger_event();
 
 	if (prev != curr)
 		rfkill_event(rfkill);
@@ -477,6 +532,7 @@ bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	if (!rfkill->registered)
 		return ret;
@@ -523,6 +579,7 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
 		schedule_work(&rfkill->uevent_work);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	return blocked;
 }
@@ -572,6 +629,7 @@ void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
 			schedule_work(&rfkill->uevent_work);
 
 		rfkill_led_trigger_event(rfkill);
+		rfkill_any_led_trigger_event();
 	}
 }
 EXPORT_SYMBOL(rfkill_set_states);
@@ -988,6 +1046,7 @@ int __must_check rfkill_register(struct rfkill *rfkill)
 #endif
 	}
 
+	__rfkill_any_led_trigger_event();
 	rfkill_send_events(rfkill, RFKILL_OP_ADD);
 
 	mutex_unlock(&rfkill_global_mutex);
@@ -1020,6 +1079,7 @@ void rfkill_unregister(struct rfkill *rfkill)
 	mutex_lock(&rfkill_global_mutex);
 	rfkill_send_events(rfkill, RFKILL_OP_DEL);
 	list_del_init(&rfkill->node);
+	__rfkill_any_led_trigger_event();
 	mutex_unlock(&rfkill_global_mutex);
 
 	rfkill_led_trigger_unregister(rfkill);
@@ -1278,8 +1338,18 @@ static int __init rfkill_init(void)
 		goto error_input;
 #endif
 
+#ifdef CONFIG_RFKILL_LEDS
+	error = rfkill_any_led_trigger_register();
+	if (error)
+		goto error_led_trigger;
+#endif
+
 	return 0;
 
+error_led_trigger:
+#ifdef CONFIG_RFKILL_INPUT
+	rfkill_handler_exit();
+#endif
 error_input:
 	misc_deregister(&rfkill_miscdev);
 error_misc:
@@ -1291,6 +1361,9 @@ subsys_initcall(rfkill_init);
 
 static void __exit rfkill_exit(void)
 {
+#ifdef CONFIG_RFKILL_LEDS
+	rfkill_any_led_trigger_unregister();
+#endif
 #ifdef CONFIG_RFKILL_INPUT
 	rfkill_handler_exit();
 #endif
-- 
2.10.2
