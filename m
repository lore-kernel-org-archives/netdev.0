From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/5 net-next-2.6] [TIPC]: Add support for customized subscription endianness
Date: Tue, 13 May 2008 14:17:42 -0400
Message-ID: <1210702665-5012-3-git-send-email-allan.stephens@windriver.com>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35529 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754831AbYEMSSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:18:16 -0400
In-Reply-To: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables TIPC's topology server code to do customized
endianness conversions on a per-subscription basis.  (This
capability is needed to support the upcoming consolidation of
subscriber and subscription object references.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/subscr.c |   35 ++++++++++++++++-------------------
 net/tipc/subscr.h |    2 ++
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 81e2bd5..a62e5d3 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -47,7 +47,6 @@
  * @subscriber_list: adjacent subscribers in top. server's list of subscribers
  * @subscription_list: list of subscription objects for this subscriber
  * @port_ref: object reference to port used to communicate with subscriber
- * @swap: indicates if subscriber uses opposite endianness in its messages
  */
 
 struct subscriber {
@@ -56,7 +55,6 @@ struct subscriber {
 	struct list_head subscriber_list;
 	struct list_head subscription_list;
 	u32 port_ref;
-	int swap;
 };
 
 /**
@@ -109,11 +107,11 @@ static void subscr_send_event(struct subscription *sub,
 	msg_sect.iov_base = (void *)&sub->evt;
 	msg_sect.iov_len = sizeof(struct tipc_event);
 
-	sub->evt.event = htohl(event, sub->owner->swap);
-	sub->evt.found_lower = htohl(found_lower, sub->owner->swap);
-	sub->evt.found_upper = htohl(found_upper, sub->owner->swap);
-	sub->evt.port.ref = htohl(port_ref, sub->owner->swap);
-	sub->evt.port.node = htohl(node, sub->owner->swap);
+	sub->evt.event = htohl(event, sub->swap);
+	sub->evt.found_lower = htohl(found_lower, sub->swap);
+	sub->evt.found_upper = htohl(found_upper, sub->swap);
+	sub->evt.port.ref = htohl(port_ref, sub->swap);
+	sub->evt.port.node = htohl(node, sub->swap);
 	tipc_send(sub->owner->port_ref, 1, &msg_sect);
 }
 
@@ -324,18 +322,16 @@ static void subscr_subscribe(struct tipc_subscr *s,
 			     struct subscriber *subscriber)
 {
 	struct subscription *sub;
+	int swap;
 
-	/* Determine/update subscriber's endianness */
+	/* Determine subscriber's endianness */
 
-	if (s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE))
-		subscriber->swap = 0;
-	else
-		subscriber->swap = 1;
+	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
 
 	/* Detect & process a subscription cancellation request */
 
-	if (s->filter & htohl(TIPC_SUB_CANCEL, subscriber->swap)) {
-		s->filter &= ~htohl(TIPC_SUB_CANCEL, subscriber->swap);
+	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
+		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
 		subscr_cancel(s, subscriber);
 		return;
 	}
@@ -360,11 +356,11 @@ static void subscr_subscribe(struct tipc_subscr *s,
 
 	/* Initialize subscription object */
 
-	sub->seq.type = htohl(s->seq.type, subscriber->swap);
-	sub->seq.lower = htohl(s->seq.lower, subscriber->swap);
-	sub->seq.upper = htohl(s->seq.upper, subscriber->swap);
-	sub->timeout = htohl(s->timeout, subscriber->swap);
-	sub->filter = htohl(s->filter, subscriber->swap);
+	sub->seq.type = htohl(s->seq.type, swap);
+	sub->seq.lower = htohl(s->seq.lower, swap);
+	sub->seq.upper = htohl(s->seq.upper, swap);
+	sub->timeout = htohl(s->timeout, swap);
+	sub->filter = htohl(s->filter, swap);
 	if ((!(sub->filter & TIPC_SUB_PORTS)
 	     == !(sub->filter & TIPC_SUB_SERVICE))
 	    || (sub->seq.lower > sub->seq.upper)) {
@@ -378,6 +374,7 @@ static void subscr_subscribe(struct tipc_subscr *s,
 	INIT_LIST_HEAD(&sub->subscription_list);
 	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
+	sub->swap = swap;
 	atomic_inc(&topsrv.subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
 		k_init_timer(&sub->timer,
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index d955368..3e3e026 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -49,6 +49,7 @@ typedef void (*tipc_subscr_event) (struct subscription *sub,
  * @timeout: duration of subscription (in ms)
  * @filter: event filtering to be done for subscription
  * @event_cb: routine invoked when a subscription event is detected
+ * @swap: indicates if subscriber uses opposite endianness in its messages
  * @evt: template for events generated by subscription
  * @subscription_list: adjacent subscriptions in subscriber's subscription list
  * @nameseq_list: adjacent subscriptions in name sequence's subscription list
@@ -61,6 +62,7 @@ struct subscription {
 	u32 timeout;
 	u32 filter;
 	tipc_subscr_event event_cb;
+	int swap;
 	struct tipc_event evt;
 	struct list_head subscription_list;
 	struct list_head nameseq_list;
-- 
1.5.3.2

