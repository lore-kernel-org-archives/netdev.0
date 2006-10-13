From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 12/14] [TIPC] Added subscription cancellation capability
Date: Fri, 13 Oct 2006 13:37:53 +0200
Message-ID: <11607394754005-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org, Lijun Chen <chenli@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:49824 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751401AbWJMLiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lijun Chen <chenli@nortel.com>

This patch allows a TIPC application to cancel an existing
topology service subscription by re-requesting the subscription
with the TIPC_SUB_CANCEL filter bit set.  (All other bits of
the cancel request must match the original subscription request.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 include/linux/tipc.h |    1 +
 net/tipc/subscr.c    |   99 ++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index 243a15f..bea4694 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -129,6 +129,7 @@ #define TIPC_CONN_SHUTDOWN	5
 
 #define TIPC_SUB_PORTS     	0x01  	/* filter for port availability */
 #define TIPC_SUB_SERVICE     	0x02  	/* filter for service availability */
+#define TIPC_SUB_CANCEL         0x04    /* cancel a subscription */
 #if 0
 /* The following filter options are not currently implemented */
 #define TIPC_SUB_NO_BIND_EVTS	0x04	/* filter out "publish" events */
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index c51600b..77a87c2 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -155,7 +155,7 @@ void tipc_subscr_report_overlap(struct s
 	    sub->seq.upper, found_lower, found_upper);
 	if (!tipc_subscr_overlap(sub, found_lower, found_upper))
 		return;
-	if (!must && (sub->filter != TIPC_SUB_PORTS))
+	if (!must && !(sub->filter & TIPC_SUB_PORTS))
 		return;
 	subscr_send_event(sub, found_lower, found_upper, event, port_ref, node);
 }
@@ -176,6 +176,13 @@ static void subscr_timeout(struct subscr
 	if (subscriber == NULL)
 		return;
 
+	/* Validate timeout (in case subscription is being cancelled) */
+
+	if (sub->timeout == TIPC_WAIT_FOREVER) {
+		tipc_ref_unlock(subscriber_ref);
+		return;
+	}
+
 	/* Unlink subscription from name table */
 
 	tipc_nametbl_unsubscribe(sub);
@@ -199,6 +206,20 @@ static void subscr_timeout(struct subscr
 }
 
 /**
+ * subscr_del - delete a subscription within a subscription list
+ *
+ * Called with subscriber locked.
+ */
+
+static void subscr_del(struct subscription *sub)
+{
+	tipc_nametbl_unsubscribe(sub);
+	list_del(&sub->subscription_list);
+	kfree(sub);
+	atomic_dec(&topsrv.subscription_count);
+}
+
+/**
  * subscr_terminate - terminate communication with a subscriber
  * 
  * Called with subscriber locked.  Routine must temporarily release this lock
@@ -227,12 +248,9 @@ static void subscr_terminate(struct subs
 			k_cancel_timer(&sub->timer);
 			k_term_timer(&sub->timer);
 		}
-		tipc_nametbl_unsubscribe(sub);
-		list_del(&sub->subscription_list);
-		dbg("Term: Removed sub %u,%u,%u from subscriber %x list\n",
+		dbg("Term: Removing sub %u,%u,%u from subscriber %x list\n",
 		    sub->seq.type, sub->seq.lower, sub->seq.upper, subscriber);
-		kfree(sub);
-		atomic_dec(&topsrv.subscription_count);
+		subscr_del(sub);
 	}
 
 	/* Sever connection to subscriber */
@@ -253,6 +271,49 @@ static void subscr_terminate(struct subs
 }
 
 /**
+ * subscr_cancel - handle subscription cancellation request
+ * 
+ * Called with subscriber locked.  Routine must temporarily release this lock
+ * to enable the subscription timeout routine to finish without deadlocking; 
+ * the lock is then reclaimed to allow caller to release it upon return.
+ * 
+ * Note that fields of 's' use subscriber's endianness! 
+ */
+
+static void subscr_cancel(struct tipc_subscr *s,
+			  struct subscriber *subscriber)
+{
+	struct subscription *sub;
+	struct subscription *sub_temp;
+	int found = 0;
+
+	/* Find first matching subscription, exit if not found */
+	
+	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
+				 subscription_list) {
+		if (!memcmp(s, &sub->evt.s, sizeof(struct tipc_subscr))) {
+			found = 1;
+			break;
+		}
+	}
+	if (!found)
+		return;
+
+	/* Cancel subscription timer (if used), then delete subscription */
+
+	if (sub->timeout != TIPC_WAIT_FOREVER) {
+		sub->timeout = TIPC_WAIT_FOREVER;
+		spin_unlock_bh(subscriber->lock);
+		k_cancel_timer(&sub->timer);
+		k_term_timer(&sub->timer);
+		spin_lock_bh(subscriber->lock);
+	}
+	dbg("Cancel: removing sub %u,%u,%u from subscriber %x list\n",
+	    sub->seq.type, sub->seq.lower, sub->seq.upper, subscriber);
+	subscr_del(sub);
+}
+
+/**
  * subscr_subscribe - create subscription for subscriber
  * 
  * Called with subscriber locked
@@ -263,6 +324,21 @@ static void subscr_subscribe(struct tipc
 {
 	struct subscription *sub;
 
+	/* Determine/update subscriber's endianness */
+
+	if (s->filter & (TIPC_SUB_PORTS | TIPC_SUB_SERVICE))
+		subscriber->swap = 0;
+	else
+		subscriber->swap = 1;
+
+	/* Detect & process a subscription cancellation request */
+
+	if (s->filter & htohl(TIPC_SUB_CANCEL, subscriber->swap)) {
+		s->filter &= ~htohl(TIPC_SUB_CANCEL, subscriber->swap);
+		subscr_cancel(s, subscriber);
+		return;
+	}
+
 	/* Refuse subscription if global limit exceeded */
 
 	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
@@ -281,13 +357,6 @@ static void subscr_subscribe(struct tipc
 		return;
 	}
 
-	/* Determine/update subscriber's endianness */
-
-	if ((s->filter == TIPC_SUB_PORTS) || (s->filter == TIPC_SUB_SERVICE))
-		subscriber->swap = 0;
-	else
-		subscriber->swap = 1;
-
 	/* Initialize subscription object */
 
 	memset(sub, 0, sizeof(*sub));
@@ -296,8 +365,8 @@ static void subscr_subscribe(struct tipc
 	sub->seq.upper = htohl(s->seq.upper, subscriber->swap);
 	sub->timeout = htohl(s->timeout, subscriber->swap);
 	sub->filter = htohl(s->filter, subscriber->swap);
-	if ((((sub->filter != TIPC_SUB_PORTS) 
-	      && (sub->filter != TIPC_SUB_SERVICE)))
+	if ((!(sub->filter & TIPC_SUB_PORTS)
+	     == !(sub->filter & TIPC_SUB_SERVICE))
 	    || (sub->seq.lower > sub->seq.upper)) {
 		warn("Subscription rejected, illegal request\n");
 		kfree(sub);
-- 
1.4.1

