From: nhorman@tuxdriver.com
Subject: [PATCH 2/2] Revert d88dca79d3852a3623f606f781e013d61486828a
Date: Thu, 21 Oct 2010 07:06:16 -0400
Message-ID: <1287659176-14504-3-git-send-email-nhorman@tuxdriver.com>
References: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, jon.maloy@ericsson.com,
	paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, luca@llucax.com.ar,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49682 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757352Ab0JULG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:06:58 -0400
In-Reply-To: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

TIPC needs to have its endianess issues fixed.  Unfortunately, the format of a
subscriber message is passed in directly from user space, so requiring this
message to be in network byte order breaks user space ABI.  Revert this change
until such time as we can determine how to do this in a backwards compatible
manner.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/tipc/subscr.c |   57 ++++++++++++++++++++++++++++++++--------------------
 net/tipc/subscr.h |    2 +
 2 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index ecccfdb..3331396 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -76,6 +76,19 @@ struct top_srv {
 static struct top_srv topsrv = { 0 };
 
 /**
+ * htohl - convert value to endianness used by destination
+ * @in: value to convert
+ * @swap: non-zero if endianness must be reversed
+ *
+ * Returns converted value
+ */
+
+static u32 htohl(u32 in, int swap)
+{
+	return swap ? swab32(in) : in;
+}
+
+/**
  * subscr_send_event - send a message containing a tipc_event to the subscriber
  *
  * Note: Must not hold subscriber's server port lock, since tipc_send() will
@@ -94,11 +107,11 @@ static void subscr_send_event(struct subscription *sub,
 	msg_sect.iov_base = (void *)&sub->evt;
 	msg_sect.iov_len = sizeof(struct tipc_event);
 
-	sub->evt.event = htonl(event);
-	sub->evt.found_lower = htonl(found_lower);
-	sub->evt.found_upper = htonl(found_upper);
-	sub->evt.port.ref = htonl(port_ref);
-	sub->evt.port.node = htonl(node);
+	sub->evt.event = htohl(event, sub->swap);
+	sub->evt.found_lower = htohl(found_lower, sub->swap);
+	sub->evt.found_upper = htohl(found_upper, sub->swap);
+	sub->evt.port.ref = htohl(port_ref, sub->swap);
+	sub->evt.port.node = htohl(node, sub->swap);
 	tipc_send(sub->server_ref, 1, &msg_sect);
 }
 
@@ -274,23 +287,16 @@ static void subscr_cancel(struct tipc_subscr *s,
 {
 	struct subscription *sub;
 	struct subscription *sub_temp;
-	__u32 type, lower, upper;
 	int found = 0;
 
 	/* Find first matching subscription, exit if not found */
 
-	type = ntohl(s->seq.type);
-	lower = ntohl(s->seq.lower);
-	upper = ntohl(s->seq.upper);
-
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
 				 subscription_list) {
-			if ((type == sub->seq.type) &&
-			    (lower == sub->seq.lower) &&
-			    (upper == sub->seq.upper)) {
-				found = 1;
-				break;
-			}
+		if (!memcmp(s, &sub->evt.s, sizeof(struct tipc_subscr))) {
+			found = 1;
+			break;
+		}
 	}
 	if (!found)
 		return;
@@ -319,10 +325,16 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 					     struct subscriber *subscriber)
 {
 	struct subscription *sub;
+	int swap;
+
+	/* Determine subscriber's endianness */
+
+	swap = !(s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE));
 
 	/* Detect & process a subscription cancellation request */
 
-	if (ntohl(s->filter) & TIPC_SUB_CANCEL) {
+	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
+		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
 		subscr_cancel(s, subscriber);
 		return NULL;
 	}
@@ -347,11 +359,11 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 
 	/* Initialize subscription object */
 
-	sub->seq.type = ntohl(s->seq.type);
-	sub->seq.lower = ntohl(s->seq.lower);
-	sub->seq.upper = ntohl(s->seq.upper);
-	sub->timeout = ntohl(s->timeout);
-	sub->filter = ntohl(s->filter);
+	sub->seq.type = htohl(s->seq.type, swap);
+	sub->seq.lower = htohl(s->seq.lower, swap);
+	sub->seq.upper = htohl(s->seq.upper, swap);
+	sub->timeout = htohl(s->timeout, swap);
+	sub->filter = htohl(s->filter, swap);
 	if ((!(sub->filter & TIPC_SUB_PORTS) ==
 	     !(sub->filter & TIPC_SUB_SERVICE)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
@@ -364,6 +376,7 @@ static struct subscription *subscr_subscribe(struct tipc_subscr *s,
 	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
 	sub->server_ref = subscriber->port_ref;
+	sub->swap = swap;
 	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
 	atomic_inc(&topsrv.subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index c20f496..45d89bf 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -53,6 +53,7 @@ typedef void (*tipc_subscr_event) (struct subscription *sub,
  * @nameseq_list: adjacent subscriptions in name sequence's subscription list
  * @subscription_list: adjacent subscriptions in subscriber's subscription list
  * @server_ref: object reference of server port associated with subscription
+ * @swap: indicates if subscriber uses opposite endianness in its messages
  * @evt: template for events generated by subscription
  */
 
@@ -65,6 +66,7 @@ struct subscription {
 	struct list_head nameseq_list;
 	struct list_head subscription_list;
 	u32 server_ref;
+	int swap;
 	struct tipc_event evt;
 };
 
-- 
1.7.2.3

