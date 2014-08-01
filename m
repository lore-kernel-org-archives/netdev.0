From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: xt_LED: fix too short led-always-blink
Date: Fri,  1 Aug 2014 18:40:38 +0200
Message-ID: <1406911239-6250-3-git-send-email-pablo@netfilter.org>
References: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47139 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754413AbaHAQke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 12:40:34 -0400
In-Reply-To: <1406911239-6250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Prchal <jiri.prchal@aksignal.cz>

If led-always-blink is set, then between switch led OFF and ON
is almost zero time. So blink is invisible. This use oneshot led trigger
with fixed time 50ms witch is enough to see blink.

Signed-off-by: Jiri Prchal <jiri.prchal@aksignal.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LED.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 993de2b..92c71cd 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -50,11 +50,14 @@ struct xt_led_info_internal {
 	struct timer_list timer;
 };
 
+#define XT_LED_BLINK_DELAY 50 /* ms */
+
 static unsigned int
 led_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_led_info *ledinfo = par->targinfo;
 	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
+	unsigned long led_delay = XT_LED_BLINK_DELAY;
 
 	/*
 	 * If "always blink" is enabled, and there's still some time until the
@@ -62,9 +65,10 @@ led_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	 */
 	if ((ledinfo->delay > 0) && ledinfo->always_blink &&
 	    timer_pending(&ledinternal->timer))
-		led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
-
-	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_FULL);
+		led_trigger_blink_oneshot(&ledinternal->netfilter_led_trigger,
+					  &led_delay, &led_delay, 1);
+	else
+		led_trigger_event(&ledinternal->netfilter_led_trigger, LED_FULL);
 
 	/* If there's a positive delay, start/update the timer */
 	if (ledinfo->delay > 0) {
-- 
1.7.10.4
