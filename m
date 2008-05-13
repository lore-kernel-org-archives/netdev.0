From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/5 net-next-2.6] [TIPC]: Consolidate subscriber & subscriber port references
Date: Tue, 13 May 2008 14:17:44 -0400
Message-ID: <1210702665-5012-5-git-send-email-allan.stephens@windriver.com>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35535 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907AbYEMSSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:18:16 -0400
In-Reply-To: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies TIPC's network topology service so that it
only requires a single reference table entry per subscriber
connection, rather than two.  This is achieved by letting the
reference to the server port communicating with the subscriber
act as the reference to the subscriber object itself.  (Since
the subscriber cannot exist without its port, and vice versa,
this dual role for the reference is perfectly natural.)  This
consolidation reduces the size of the reference table by 50%
in the default configuration.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.c   |    3 +-
 net/tipc/subscr.c |  199 ++++++++++++++++++++++++++++++-----------------------
 net/tipc/subscr.h |    4 +-
 3 files changed, 116 insertions(+), 90 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 6d6aa5a..3d97386 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -164,8 +164,7 @@ int tipc_core_start(void)
 	tipc_mode = TIPC_NODE_MODE;
 
 	if ((res = tipc_handler_start()) ||
-	    (res = tipc_ref_table_init(tipc_max_ports + tipc_max_subscriptions,
-				       tipc_random)) ||
+	    (res = tipc_ref_table_init(tipc_max_ports, tipc_random)) ||
 	    (res = tipc_reg_start()) ||
 	    (res = tipc_nametbl_init()) ||
 	    (res = tipc_k_signal((Handler)tipc_subscr_start, 0)) ||
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index dde23f1..7c62791 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -38,23 +38,22 @@
 #include "dbg.h"
 #include "subscr.h"
 #include "name_table.h"
+#include "port.h"
 #include "ref.h"
 
 /**
  * struct subscriber - TIPC network topology subscriber
- * @ref: object reference to subscriber object itself
- * @lock: pointer to spinlock controlling access to subscriber object
+ * @port_ref: object reference to server port connecting to subscriber
+ * @lock: pointer to spinlock controlling access to subscriber's server port
  * @subscriber_list: adjacent subscribers in top. server's list of subscribers
  * @subscription_list: list of subscription objects for this subscriber
- * @port_ref: object reference to port used to communicate with subscriber
  */
 
 struct subscriber {
-	u32 ref;
+	u32 port_ref;
 	spinlock_t *lock;
 	struct list_head subscriber_list;
 	struct list_head subscription_list;
-	u32 port_ref;
 };
 
 /**
@@ -91,6 +90,9 @@ static u32 htohl(u32 in, int swap)
 
 /**
  * subscr_send_event - send a message containing a tipc_event to the subscriber
+ *
+ * Note: Must not hold subscriber's server port lock, since tipc_send() will
+ *       try to take the lock if the message is rejected and returned!
  */
 
 static void subscr_send_event(struct subscription *sub,
@@ -110,7 +112,7 @@ static void subscr_send_event(struct subscription *sub,
 	sub->evt.found_upper = htohl(found_upper, sub->swap);
 	sub->evt.port.ref = htohl(port_ref, sub->swap);
 	sub->evt.port.node = htohl(node, sub->swap);
-	tipc_send(sub->owner->port_ref, 1, &msg_sect);
+	tipc_send(sub->server_ref, 1, &msg_sect);
 }
 
 /**
@@ -163,20 +165,18 @@ void tipc_subscr_report_overlap(struct subscription *sub,
 
 static void subscr_timeout(struct subscription *sub)
 {
-	struct subscriber *subscriber;
-	u32 subscriber_ref;
+	struct port *server_port;
 
-	/* Validate subscriber reference (in case subscriber is terminating) */
+	/* Validate server port reference (in case subscriber is terminating) */
 
-	subscriber_ref = sub->owner->ref;
-	subscriber = (struct subscriber *)tipc_ref_lock(subscriber_ref);
-	if (subscriber == NULL)
+	server_port = tipc_port_lock(sub->server_ref);
+	if (server_port == NULL)
 		return;
 
 	/* Validate timeout (in case subscription is being cancelled) */
 
 	if (sub->timeout == TIPC_WAIT_FOREVER) {
-		tipc_ref_unlock(subscriber_ref);
+		tipc_port_unlock(server_port);
 		return;
 	}
 
@@ -184,19 +184,21 @@ static void subscr_timeout(struct subscription *sub)
 
 	tipc_nametbl_unsubscribe(sub);
 
-	/* Notify subscriber of timeout, then unlink subscription */
+	/* Unlink subscription from subscriber */
 
-	subscr_send_event(sub,
-			  sub->evt.s.seq.lower,
-			  sub->evt.s.seq.upper,
-			  TIPC_SUBSCR_TIMEOUT,
-			  0,
-			  0);
 	list_del(&sub->subscription_list);
 
+	/* Release subscriber's server port */
+
+	tipc_port_unlock(server_port);
+
+	/* Notify subscriber of timeout */
+
+	subscr_send_event(sub, sub->evt.s.seq.lower, sub->evt.s.seq.upper,
+			  TIPC_SUBSCR_TIMEOUT, 0, 0);
+
 	/* Now destroy subscription */
 
-	tipc_ref_unlock(subscriber_ref);
 	k_term_timer(&sub->timer);
 	kfree(sub);
 	atomic_dec(&topsrv.subscription_count);
@@ -205,7 +207,7 @@ static void subscr_timeout(struct subscription *sub)
 /**
  * subscr_del - delete a subscription within a subscription list
  *
- * Called with subscriber locked.
+ * Called with subscriber port locked.
  */
 
 static void subscr_del(struct subscription *sub)
@@ -219,7 +221,7 @@ static void subscr_del(struct subscription *sub)
 /**
  * subscr_terminate - terminate communication with a subscriber
  *
- * Called with subscriber locked.  Routine must temporarily release this lock
+ * Called with subscriber port locked.  Routine must temporarily release lock
  * to enable subscription timeout routine(s) to finish without deadlocking;
  * the lock is then reclaimed to allow caller to release it upon return.
  * (This should work even in the unlikely event some other thread creates
@@ -229,14 +231,21 @@ static void subscr_del(struct subscription *sub)
 
 static void subscr_terminate(struct subscriber *subscriber)
 {
+	u32 port_ref;
 	struct subscription *sub;
 	struct subscription *sub_temp;
 
 	/* Invalidate subscriber reference */
 
-	tipc_ref_discard(subscriber->ref);
+	port_ref = subscriber->port_ref;
+	subscriber->port_ref = 0;
 	spin_unlock_bh(subscriber->lock);
 
+	/* Sever connection to subscriber */
+
+	tipc_shutdown(port_ref);
+	tipc_deleteport(port_ref);
+
 	/* Destroy any existing subscriptions for subscriber */
 
 	list_for_each_entry_safe(sub, sub_temp, &subscriber->subscription_list,
@@ -250,27 +259,25 @@ static void subscr_terminate(struct subscriber *subscriber)
 		subscr_del(sub);
 	}
 
-	/* Sever connection to subscriber */
-
-	tipc_shutdown(subscriber->port_ref);
-	tipc_deleteport(subscriber->port_ref);
-
 	/* Remove subscriber from topology server's subscriber list */
 
 	spin_lock_bh(&topsrv.lock);
 	list_del(&subscriber->subscriber_list);
 	spin_unlock_bh(&topsrv.lock);
 
-	/* Now destroy subscriber */
+	/* Reclaim subscriber lock */
 
 	spin_lock_bh(subscriber->lock);
+
+	/* Now destroy subscriber */
+
 	kfree(subscriber);
 }
 
 /**
  * subscr_cancel - handle subscription cancellation request
  *
- * Called with subscriber locked.  Routine must temporarily release this lock
+ * Called with subscriber port locked.  Routine must temporarily release lock
  * to enable the subscription timeout routine to finish without deadlocking;
  * the lock is then reclaimed to allow caller to release it upon return.
  *
@@ -313,11 +320,11 @@ static void subscr_cancel(struct tipc_subscr *s,
 /**
  * subscr_subscribe - create subscription for subscriber
  *
- * Called with subscriber locked
+ * Called with subscriber port locked.
  */
 
-static void subscr_subscribe(struct tipc_subscr *s,
-			     struct subscriber *subscriber)
+static struct subscription *subscr_subscribe(struct tipc_subscr *s,
+					     struct subscriber *subscriber)
 {
 	struct subscription *sub;
 	int swap;
@@ -331,7 +338,7 @@ static void subscr_subscribe(struct tipc_subscr *s,
 	if (s->filter & htohl(TIPC_SUB_CANCEL, swap)) {
 		s->filter &= ~htohl(TIPC_SUB_CANCEL, swap);
 		subscr_cancel(s, subscriber);
-		return;
+		return NULL;
 	}
 
 	/* Refuse subscription if global limit exceeded */
@@ -340,16 +347,16 @@ static void subscr_subscribe(struct tipc_subscr *s,
 		warn("Subscription rejected, subscription limit reached (%u)\n",
 		     tipc_max_subscriptions);
 		subscr_terminate(subscriber);
-		return;
+		return NULL;
 	}
 
 	/* Allocate subscription object */
 
-	sub = kzalloc(sizeof(*sub), GFP_ATOMIC);
+	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
 		warn("Subscription rejected, no memory\n");
 		subscr_terminate(subscriber);
-		return;
+		return NULL;
 	}
 
 	/* Initialize subscription object */
@@ -365,40 +372,41 @@ static void subscr_subscribe(struct tipc_subscr *s,
 		warn("Subscription rejected, illegal request\n");
 		kfree(sub);
 		subscr_terminate(subscriber);
-		return;
+		return NULL;
 	}
 	sub->event_cb = subscr_send_event;
-	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
-	INIT_LIST_HEAD(&sub->subscription_list);
 	INIT_LIST_HEAD(&sub->nameseq_list);
 	list_add(&sub->subscription_list, &subscriber->subscription_list);
+	sub->server_ref = subscriber->port_ref;
 	sub->swap = swap;
+	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
 	atomic_inc(&topsrv.subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
 		k_init_timer(&sub->timer,
 			     (Handler)subscr_timeout, (unsigned long)sub);
 		k_start_timer(&sub->timer, sub->timeout);
 	}
-	sub->owner = subscriber;
-	tipc_nametbl_subscribe(sub);
+
+	return sub;
 }
 
 /**
  * subscr_conn_shutdown_event - handle termination request from subscriber
+ *
+ * Called with subscriber's server port unlocked.
  */
 
 static void subscr_conn_shutdown_event(void *usr_handle,
-				       u32 portref,
+				       u32 port_ref,
 				       struct sk_buff **buf,
 				       unsigned char const *data,
 				       unsigned int size,
 				       int reason)
 {
-	struct subscriber *subscriber;
+	struct subscriber *subscriber = usr_handle;
 	spinlock_t *subscriber_lock;
 
-	subscriber = tipc_ref_lock((u32)(unsigned long)usr_handle);
-	if (subscriber == NULL)
+	if (tipc_port_lock(port_ref) == NULL)
 		return;
 
 	subscriber_lock = subscriber->lock;
@@ -408,6 +416,8 @@ static void subscr_conn_shutdown_event(void *usr_handle,
 
 /**
  * subscr_conn_msg_event - handle new subscription request from subscriber
+ *
+ * Called with subscriber's server port unlocked.
  */
 
 static void subscr_conn_msg_event(void *usr_handle,
@@ -416,20 +426,46 @@ static void subscr_conn_msg_event(void *usr_handle,
 				  const unchar *data,
 				  u32 size)
 {
-	struct subscriber *subscriber;
+	struct subscriber *subscriber = usr_handle;
 	spinlock_t *subscriber_lock;
+	struct subscription *sub;
+
+	/*
+	 * Lock subscriber's server port (& make a local copy of lock pointer,
+	 * in case subscriber is deleted while processing subscription request)
+	 */
 
-	subscriber = tipc_ref_lock((u32)(unsigned long)usr_handle);
-	if (subscriber == NULL)
+	if (tipc_port_lock(port_ref) == NULL)
 		return;
 
 	subscriber_lock = subscriber->lock;
-	if (size != sizeof(struct tipc_subscr))
-		subscr_terminate(subscriber);
-	else
-		subscr_subscribe((struct tipc_subscr *)data, subscriber);
 
-	spin_unlock_bh(subscriber_lock);
+	if (size != sizeof(struct tipc_subscr)) {
+		subscr_terminate(subscriber);
+		spin_unlock_bh(subscriber_lock);
+	} else {
+		sub = subscr_subscribe((struct tipc_subscr *)data, subscriber);
+		spin_unlock_bh(subscriber_lock);
+		if (sub != NULL) {
+
+			/*
+			 * We must release the server port lock before adding a
+			 * subscription to the name table since TIPC needs to be
+			 * able to (re)acquire the port lock if an event message
+			 * issued by the subscription process is rejected and
+			 * returned.  The subscription cannot be deleted while
+			 * it is being added to the name table because:
+			 * a) the single-threading of the native API port code
+			 *    ensures the subscription cannot be cancelled and
+			 *    the subscriber connection cannot be broken, and
+			 * b) the name table lock ensures the subscription
+			 *    timeout code cannot delete the subscription,
+			 * so the subscription object is still protected.
+			 */
+
+			tipc_nametbl_subscribe(sub);
+		}
+	}
 }
 
 /**
@@ -445,16 +481,10 @@ static void subscr_named_msg_event(void *usr_handle,
 				   struct tipc_portid const *orig,
 				   struct tipc_name_seq const *dest)
 {
-	struct subscriber *subscriber;
-	struct iovec msg_sect = {NULL, 0};
-	spinlock_t *subscriber_lock;
+	static struct iovec msg_sect = {NULL, 0};
 
-	dbg("subscr_named_msg_event: orig = %x own = %x,\n",
-	    orig->node, tipc_own_addr);
-	if (size && (size != sizeof(struct tipc_subscr))) {
-		warn("Subscriber rejected, invalid subscription size\n");
-		return;
-	}
+	struct subscriber *subscriber;
+	u32 server_port_ref;
 
 	/* Create subscriber object */
 
@@ -465,18 +495,11 @@ static void subscr_named_msg_event(void *usr_handle,
 	}
 	INIT_LIST_HEAD(&subscriber->subscription_list);
 	INIT_LIST_HEAD(&subscriber->subscriber_list);
-	subscriber->ref = tipc_ref_acquire(subscriber, &subscriber->lock);
-	if (subscriber->ref == 0) {
-		warn("Subscriber rejected, reference table exhausted\n");
-		kfree(subscriber);
-		return;
-	}
-	spin_unlock_bh(subscriber->lock);
 
-	/* Establish a connection to subscriber */
+	/* Create server port & establish connection to subscriber */
 
 	tipc_createport(topsrv.user_ref,
-			(void *)(unsigned long)subscriber->ref,
+			subscriber,
 			importance,
 			NULL,
 			NULL,
@@ -488,32 +511,36 @@ static void subscr_named_msg_event(void *usr_handle,
 			&subscriber->port_ref);
 	if (subscriber->port_ref == 0) {
 		warn("Subscriber rejected, unable to create port\n");
-		tipc_ref_discard(subscriber->ref);
 		kfree(subscriber);
 		return;
 	}
 	tipc_connect2port(subscriber->port_ref, orig);
 
+	/* Lock server port (& save lock address for future use) */
+
+	subscriber->lock = tipc_port_lock(subscriber->port_ref)->publ.lock;
 
 	/* Add subscriber to topology server's subscriber list */
 
-	tipc_ref_lock(subscriber->ref);
 	spin_lock_bh(&topsrv.lock);
 	list_add(&subscriber->subscriber_list, &topsrv.subscriber_list);
 	spin_unlock_bh(&topsrv.lock);
 
-	/*
-	 * Subscribe now if message contains a subscription,
-	 * otherwise send an empty response to complete connection handshaking
-	 */
+	/* Unlock server port */
 
-	subscriber_lock = subscriber->lock;
-	if (size)
-		subscr_subscribe((struct tipc_subscr *)data, subscriber);
-	else
-		tipc_send(subscriber->port_ref, 1, &msg_sect);
+	server_port_ref = subscriber->port_ref;
+	spin_unlock_bh(subscriber->lock);
 
-	spin_unlock_bh(subscriber_lock);
+	/* Send an ACK- to complete connection handshaking */
+
+	tipc_send(server_port_ref, 1, &msg_sect);
+
+	/* Handle optional subscription request */
+
+	if (size != 0) {
+		subscr_conn_msg_event(subscriber, server_port_ref,
+				      buf, data, size);
+	}
 }
 
 int tipc_subscr_start(void)
@@ -572,8 +599,8 @@ void tipc_subscr_stop(void)
 		list_for_each_entry_safe(subscriber, subscriber_temp,
 					 &topsrv.subscriber_list,
 					 subscriber_list) {
-			tipc_ref_lock(subscriber->ref);
 			subscriber_lock = subscriber->lock;
+			spin_lock_bh(subscriber_lock);
 			subscr_terminate(subscriber);
 			spin_unlock_bh(subscriber_lock);
 		}
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 3e3e026..b9af687 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -49,12 +49,12 @@ typedef void (*tipc_subscr_event) (struct subscription *sub,
  * @timeout: duration of subscription (in ms)
  * @filter: event filtering to be done for subscription
  * @event_cb: routine invoked when a subscription event is detected
+ * @server_ref: object reference of server port associated with subscription
  * @swap: indicates if subscriber uses opposite endianness in its messages
  * @evt: template for events generated by subscription
  * @subscription_list: adjacent subscriptions in subscriber's subscription list
  * @nameseq_list: adjacent subscriptions in name sequence's subscription list
  * @timer_ref: reference to timer governing subscription duration (may be NULL)
- * @owner: pointer to subscriber object associated with this subscription
  */
 
 struct subscription {
@@ -62,12 +62,12 @@ struct subscription {
 	u32 timeout;
 	u32 filter;
 	tipc_subscr_event event_cb;
+	u32 server_ref;
 	int swap;
 	struct tipc_event evt;
 	struct list_head subscription_list;
 	struct list_head nameseq_list;
 	struct timer_list timer;
-	struct subscriber *owner;
 };
 
 int tipc_subscr_overlap(struct subscription * sub,
-- 
1.5.3.2

