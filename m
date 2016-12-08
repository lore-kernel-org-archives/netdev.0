From: =?UTF-8?q?Micha=C5=82=20K=C4=99pie=C5=84?= <kernel@kempniu.pl>
Subject: [PATCH v2 2/2] net: rfkill: Add rfkill-any LED trigger
Date: Thu,  8 Dec 2016 08:30:52 +0100
Message-ID: <20161208073052.12988-2-kernel@kempniu.pl>
References: <20161208073052.12988-1-kernel@kempniu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208073052.12988-1-kernel@kempniu.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-any,
which may be useful on laptops with a single "radio LED" and multiple
radio transmitters.  The trigger is meant to turn a LED on whenever
there is at least one radio transmitter active and turn it off
otherwise.

Signed-off-by: Michał Kępień <kernel@kempniu.pl>
---
Changes from v1:

  - take rfkill_global_mutex before calling rfkill_set_block() in
    rfkill_resume(); the need for doing this was previously obviated by
    908209c ("rfkill: don't impose global states on resume"), but given
    that __rfkill_any_led_trigger_event() is called from
    rfkill_set_block() unconditionally, each caller of the latter needs
    to take care of locking rfkill_global_mutex,

  - declare __rfkill_any_led_trigger_event() even when
    CONFIG_RFKILL_LEDS=n to prevent implicit declaration errors,

  - remove the #ifdef surrounding rfkill_any_led_trigger_{,un}register()
    calls to prevent compilation warnings about functions and a label
    being defined but not used,

  - move the rfkill_any_led_trigger_register() call in rfkill_init()
    before the rfkill_handler_init() call to avoid the need to call
    rfkill_handler_exit() from rfkill_init() and thus prevent a section
    mismatch.

 net/rfkill/core.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index f28e441..cd50b11 100644
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
@@ -189,6 +230,23 @@ static inline int rfkill_led_trigger_register(struct rfkill *rfkill)
 static inline void rfkill_led_trigger_unregister(struct rfkill *rfkill)
 {
 }
+
+static void __rfkill_any_led_trigger_event(void)
+{
+}
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
@@ -297,6 +355,7 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	__rfkill_any_led_trigger_event();
 
 	if (prev != curr)
 		rfkill_event(rfkill);
@@ -477,6 +536,7 @@ bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	if (!rfkill->registered)
 		return ret;
@@ -523,6 +583,7 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
 		schedule_work(&rfkill->uevent_work);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	return blocked;
 }
@@ -572,6 +633,7 @@ void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
 			schedule_work(&rfkill->uevent_work);
 
 		rfkill_led_trigger_event(rfkill);
+		rfkill_any_led_trigger_event();
 	}
 }
 EXPORT_SYMBOL(rfkill_set_states);
@@ -815,8 +877,10 @@ static int rfkill_resume(struct device *dev)
 	rfkill->suspended = false;
 
 	if (!rfkill->persistent) {
+		mutex_lock(&rfkill_global_mutex);
 		cur = !!(rfkill->state & RFKILL_BLOCK_SW);
 		rfkill_set_block(rfkill, cur);
+		mutex_unlock(&rfkill_global_mutex);
 	}
 
 	if (rfkill->ops->poll && !rfkill->polling_paused)
@@ -988,6 +1052,7 @@ int __must_check rfkill_register(struct rfkill *rfkill)
 #endif
 	}
 
+	__rfkill_any_led_trigger_event();
 	rfkill_send_events(rfkill, RFKILL_OP_ADD);
 
 	mutex_unlock(&rfkill_global_mutex);
@@ -1020,6 +1085,7 @@ void rfkill_unregister(struct rfkill *rfkill)
 	mutex_lock(&rfkill_global_mutex);
 	rfkill_send_events(rfkill, RFKILL_OP_DEL);
 	list_del_init(&rfkill->node);
+	__rfkill_any_led_trigger_event();
 	mutex_unlock(&rfkill_global_mutex);
 
 	rfkill_led_trigger_unregister(rfkill);
@@ -1272,6 +1338,10 @@ static int __init rfkill_init(void)
 	if (error)
 		goto error_misc;
 
+	error = rfkill_any_led_trigger_register();
+	if (error)
+		goto error_led_trigger;
+
 #ifdef CONFIG_RFKILL_INPUT
 	error = rfkill_handler_init();
 	if (error)
@@ -1281,6 +1351,8 @@ static int __init rfkill_init(void)
 	return 0;
 
 error_input:
+	rfkill_any_led_trigger_unregister();
+error_led_trigger:
 	misc_deregister(&rfkill_miscdev);
 error_misc:
 	class_unregister(&rfkill_class);
@@ -1294,6 +1366,7 @@ static void __exit rfkill_exit(void)
 #ifdef CONFIG_RFKILL_INPUT
 	rfkill_handler_exit();
 #endif
+	rfkill_any_led_trigger_unregister();
 	misc_deregister(&rfkill_miscdev);
 	class_unregister(&rfkill_class);
 }
-- 
2.10.2
