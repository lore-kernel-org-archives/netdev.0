From: kaber@trash.net
Subject: [PATCH 60/84] netfilter: xt_LED: add refcounts to LED target
Date: Mon, 10 May 2010 22:18:31 +0200
Message-ID: <1273522735-24672-61-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adam Nielsen <a.nielsen@shikadi.net>

Add reference counting to the netfilter LED target, to fix errors when
multiple rules point to the same target ("LED trigger already exists").

Signed-off-by: Adam Nielsen <a.nielsen@shikadi.net>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_LED.c |   69 +++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index efcf56d..bd102c7 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -31,12 +31,18 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Adam Nielsen <a.nielsen@shikadi.net>");
 MODULE_DESCRIPTION("Xtables: trigger LED devices on packet match");
 
+static LIST_HEAD(xt_led_triggers);
+static DEFINE_MUTEX(xt_led_mutex);
+
 /*
  * This is declared in here (the kernel module) only, to avoid having these
  * dependencies in userspace code.  This is what xt_led_info.internal_data
  * points to.
  */
 struct xt_led_info_internal {
+	struct list_head list;
+	int refcnt;
+	char *trigger_id;
 	struct led_trigger netfilter_led_trigger;
 	struct timer_list timer;
 };
@@ -53,7 +59,7 @@ led_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	 */
 	if ((ledinfo->delay > 0) && ledinfo->always_blink &&
 	    timer_pending(&ledinternal->timer))
-		led_trigger_event(&ledinternal->netfilter_led_trigger,LED_OFF);
+		led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
 
 	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_FULL);
 
@@ -74,12 +80,23 @@ led_tg(struct sk_buff *skb, const struct xt_target_param *par)
 
 static void led_timeout_callback(unsigned long data)
 {
-	struct xt_led_info *ledinfo = (struct xt_led_info *)data;
-	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
+	struct xt_led_info_internal *ledinternal = (struct xt_led_info_internal *)data;
 
 	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
 }
 
+static struct xt_led_info_internal *led_trigger_lookup(const char *name)
+{
+	struct xt_led_info_internal *ledinternal;
+
+	list_for_each_entry(ledinternal, &xt_led_triggers, list) {
+		if (!strcmp(name, ledinternal->netfilter_led_trigger.name)) {
+			return ledinternal;
+		}
+	}
+	return NULL;
+}
+
 static int led_tg_check(const struct xt_tgchk_param *par)
 {
 	struct xt_led_info *ledinfo = par->targinfo;
@@ -91,11 +108,25 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 		return -EINVAL;
 	}
 
+	mutex_lock(&xt_led_mutex);
+
+	ledinternal = led_trigger_lookup(ledinfo->id);
+	if (ledinternal) {
+		ledinternal->refcnt++;
+		goto out;
+	}
+
+	err = -ENOMEM;
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
 	if (!ledinternal)
-		return -ENOMEM;
+		goto exit_mutex_only;
+
+	ledinternal->trigger_id = kstrdup(ledinfo->id, GFP_KERNEL);
+	if (!ledinternal->trigger_id)
+		goto exit_internal_alloc;
 
-	ledinternal->netfilter_led_trigger.name = ledinfo->id;
+	ledinternal->refcnt = 1;
+	ledinternal->netfilter_led_trigger.name = ledinternal->trigger_id;
 
 	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
@@ -108,13 +139,26 @@ static int led_tg_check(const struct xt_tgchk_param *par)
 	/* See if we need to set up a timer */
 	if (ledinfo->delay > 0)
 		setup_timer(&ledinternal->timer, led_timeout_callback,
-			    (unsigned long)ledinfo);
+			    (unsigned long)ledinternal);
+
+	list_add_tail(&ledinternal->list, &xt_led_triggers);
+
+out:
+	mutex_unlock(&xt_led_mutex);
 
 	ledinfo->internal_data = ledinternal;
+
 	return 0;
 
 exit_alloc:
+	kfree(ledinternal->trigger_id);
+
+exit_internal_alloc:
 	kfree(ledinternal);
+
+exit_mutex_only:
+	mutex_unlock(&xt_led_mutex);
+
 	return err;
 }
 
@@ -123,10 +167,23 @@ static void led_tg_destroy(const struct xt_tgdtor_param *par)
 	const struct xt_led_info *ledinfo = par->targinfo;
 	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
 
+	mutex_lock(&xt_led_mutex);
+
+	if (--ledinternal->refcnt) {
+		mutex_unlock(&xt_led_mutex);
+		return;
+	}
+
+	list_del(&ledinternal->list);
+
 	if (ledinfo->delay > 0)
 		del_timer_sync(&ledinternal->timer);
 
 	led_trigger_unregister(&ledinternal->netfilter_led_trigger);
+
+	mutex_unlock(&xt_led_mutex);
+
+	kfree(ledinternal->trigger_id);
 	kfree(ledinternal);
 }
 
-- 
1.7.0.4

