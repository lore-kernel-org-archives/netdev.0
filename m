From: =?UTF-8?q?Micha=C5=82=20K=C4=99pie=C5=84?= <kernel@kempniu.pl>
Subject: [PATCH v4] rfkill: Add rfkill-any LED trigger
Date: Fri,  6 Jan 2017 07:07:47 +0100
Message-ID: <20170106060747.6162-1-kernel@kempniu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB=20=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:32985 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdAFGIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 01:08:15 -0500
Received: by mail-lf0-f67.google.com with SMTP id k62so2543898lfg.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 22:08:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-any,
which may be useful on laptops with a single "radio LED" and multiple
radio transmitters.  The trigger is meant to turn a LED on whenever
there is at least one radio transmitter active and turn it off
otherwise.

Signed-off-by: Michał Kępień <kernel@kempniu.pl>
---
Changes from v3:

  - Revert introducing a new bitfield and instead defer LED event firing
    to a work queue to prevent conditional locking and ensure the
    trigger can really be used from any context.  This also voids the
    need to take rfkill_global_mutex before calling rfkill_set_block()
    in rfkill_resume().

Changes from v2:

  - Handle the global mutex properly when rfkill_set_{hw,sw}_state() or
    rfkill_set_states() is called from within an rfkill callback.  v2
    always tried to lock the global mutex in such a case, which led to a
    deadlock when an rfkill driver called one of the above functions
    from its query or set_block callback.  This is solved by defining a
    new bitfield, RFKILL_BLOCK_SW_HASLOCK, which is set before the above
    callbacks are invoked and cleared afterwards; the functions listed
    above use this bitfield to tell rfkill_any_led_trigger_event()
    whether the global mutex is currently held or not.
    RFKILL_BLOCK_SW_SETCALL cannot be reused for this purpose as setting
    it before invoking the query callback would cause any calls to
    rfkill_set_sw_state() made from within that callback to work on
    RFKILL_BLOCK_SW_PREV instead of RFKILL_BLOCK_SW and thus change the
    way rfkill_set_block() behaves.

  - As rfkill_any_led_trigger_event() now takes a boolean argument which
    tells it whether the global mutex was already taken by the caller,
    all calls to __rfkill_any_led_trigger_event() outside
    rfkill_any_led_trigger_event() have been replaced with calls to
    rfkill_any_led_trigger_event(true).

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

 net/rfkill/core.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 71 insertions(+), 1 deletion(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index afa4f71b4c7b..2064c3a35ef8 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -176,6 +176,50 @@ static void rfkill_led_trigger_unregister(struct rfkill *rfkill)
 {
 	led_trigger_unregister(&rfkill->led_trigger);
 }
+
+static struct led_trigger rfkill_any_led_trigger;
+static struct work_struct rfkill_any_work;
+
+static void rfkill_any_led_trigger_worker(struct work_struct *work)
+{
+	enum led_brightness brightness = LED_OFF;
+	struct rfkill *rfkill;
+
+	mutex_lock(&rfkill_global_mutex);
+	list_for_each_entry(rfkill, &rfkill_list, node) {
+		if (!(rfkill->state & RFKILL_BLOCK_ANY)) {
+			brightness = LED_FULL;
+			break;
+		}
+	}
+	mutex_unlock(&rfkill_global_mutex);
+
+	led_trigger_event(&rfkill_any_led_trigger, brightness);
+}
+
+static void rfkill_any_led_trigger_event(void)
+{
+	schedule_work(&rfkill_any_work);
+}
+
+static void rfkill_any_led_trigger_activate(struct led_classdev *led_cdev)
+{
+	rfkill_any_led_trigger_event();
+}
+
+static int rfkill_any_led_trigger_register(void)
+{
+	INIT_WORK(&rfkill_any_work, rfkill_any_led_trigger_worker);
+	rfkill_any_led_trigger.name = "rfkill-any";
+	rfkill_any_led_trigger.activate = rfkill_any_led_trigger_activate;
+	return led_trigger_register(&rfkill_any_led_trigger);
+}
+
+static void rfkill_any_led_trigger_unregister(void)
+{
+	led_trigger_unregister(&rfkill_any_led_trigger);
+	cancel_work_sync(&rfkill_any_work);
+}
 #else
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
@@ -189,6 +233,19 @@ static inline int rfkill_led_trigger_register(struct rfkill *rfkill)
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
@@ -297,6 +354,7 @@ static void rfkill_set_block(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	if (prev != curr)
 		rfkill_event(rfkill);
@@ -477,6 +535,7 @@ bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 	spin_unlock_irqrestore(&rfkill->lock, flags);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	if (rfkill->registered && prev != blocked)
 		schedule_work(&rfkill->uevent_work);
@@ -520,6 +579,7 @@ bool rfkill_set_sw_state(struct rfkill *rfkill, bool blocked)
 		schedule_work(&rfkill->uevent_work);
 
 	rfkill_led_trigger_event(rfkill);
+	rfkill_any_led_trigger_event();
 
 	return blocked;
 }
@@ -569,6 +629,7 @@ void rfkill_set_states(struct rfkill *rfkill, bool sw, bool hw)
 			schedule_work(&rfkill->uevent_work);
 
 		rfkill_led_trigger_event(rfkill);
+		rfkill_any_led_trigger_event();
 	}
 }
 EXPORT_SYMBOL(rfkill_set_states);
@@ -985,6 +1046,7 @@ int __must_check rfkill_register(struct rfkill *rfkill)
 #endif
 	}
 
+	rfkill_any_led_trigger_event();
 	rfkill_send_events(rfkill, RFKILL_OP_ADD);
 
 	mutex_unlock(&rfkill_global_mutex);
@@ -1017,6 +1079,7 @@ void rfkill_unregister(struct rfkill *rfkill)
 	mutex_lock(&rfkill_global_mutex);
 	rfkill_send_events(rfkill, RFKILL_OP_DEL);
 	list_del_init(&rfkill->node);
+	rfkill_any_led_trigger_event();
 	mutex_unlock(&rfkill_global_mutex);
 
 	rfkill_led_trigger_unregister(rfkill);
@@ -1269,6 +1332,10 @@ static int __init rfkill_init(void)
 	if (error)
 		goto error_misc;
 
+	error = rfkill_any_led_trigger_register();
+	if (error)
+		goto error_led_trigger;
+
 #ifdef CONFIG_RFKILL_INPUT
 	error = rfkill_handler_init();
 	if (error)
@@ -1279,8 +1346,10 @@ static int __init rfkill_init(void)
 
 #ifdef CONFIG_RFKILL_INPUT
 error_input:
-	misc_deregister(&rfkill_miscdev);
+	rfkill_any_led_trigger_unregister();
 #endif
+error_led_trigger:
+	misc_deregister(&rfkill_miscdev);
 error_misc:
 	class_unregister(&rfkill_class);
 error_class:
@@ -1293,6 +1362,7 @@ static void __exit rfkill_exit(void)
 #ifdef CONFIG_RFKILL_INPUT
 	rfkill_handler_exit();
 #endif
+	rfkill_any_led_trigger_unregister();
 	misc_deregister(&rfkill_miscdev);
 	class_unregister(&rfkill_class);
 }
-- 
2.11.0
