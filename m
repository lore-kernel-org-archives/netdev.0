From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/16] tipc: remove unnecessary wrapper functions of kernel timer APIs
Date: Fri, 9 Jan 2015 15:27:00 +0800
Message-ID: <1420788433-17960-4-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60113 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbAIH1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:27:50 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not only some wrapper function like k_term_timer() is empty, but also
some others including k_start_timer() and k_cancel_timer() don't return
back any value to its caller, what's more, there is no any component
in the kernel world to do such thing. Therefore, these timer interfaces
defined in tipc module should be purged.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/core.h     |   67 ---------------------------------------------------
 net/tipc/discover.c |   32 +++++++++++++-----------
 net/tipc/link.c     |   27 +++++++++++----------
 net/tipc/link.h     |    4 +--
 net/tipc/msg.h      |    2 --
 net/tipc/socket.c   |   17 ++++++-------
 net/tipc/subscr.c   |   17 ++++++-------
 net/tipc/subscr.h   |    2 +-
 8 files changed, 50 insertions(+), 118 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 56fe422..d570689 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -107,73 +107,6 @@ void tipc_unregister_sysctl(void);
 #endif
 
 /*
- * TIPC timer code
- */
-typedef void (*Handler) (unsigned long);
-
-/**
- * k_init_timer - initialize a timer
- * @timer: pointer to timer structure
- * @routine: pointer to routine to invoke when timer expires
- * @argument: value to pass to routine when timer expires
- *
- * Timer must be initialized before use (and terminated when no longer needed).
- */
-static inline void k_init_timer(struct timer_list *timer, Handler routine,
-				unsigned long argument)
-{
-	setup_timer(timer, routine, argument);
-}
-
-/**
- * k_start_timer - start a timer
- * @timer: pointer to timer structure
- * @msec: time to delay (in ms)
- *
- * Schedules a previously initialized timer for later execution.
- * If timer is already running, the new timeout overrides the previous request.
- *
- * To ensure the timer doesn't expire before the specified delay elapses,
- * the amount of delay is rounded up when converting to the jiffies
- * then an additional jiffy is added to account for the fact that
- * the starting time may be in the middle of the current jiffy.
- */
-static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
-{
-	mod_timer(timer, jiffies + msecs_to_jiffies(msec) + 1);
-}
-
-/**
- * k_cancel_timer - cancel a timer
- * @timer: pointer to timer structure
- *
- * Cancels a previously initialized timer.
- * Can be called safely even if the timer is already inactive.
- *
- * WARNING: Must not be called when holding locks required by the timer's
- *          timeout routine, otherwise deadlock can occur on SMP systems!
- */
-static inline void k_cancel_timer(struct timer_list *timer)
-{
-	del_timer_sync(timer);
-}
-
-/**
- * k_term_timer - terminate a timer
- * @timer: pointer to timer structure
- *
- * Prevents further use of a previously initialized timer.
- *
- * WARNING: Caller must ensure timer isn't currently running.
- *
- * (Do not "enhance" this routine to automatically cancel an active timer,
- * otherwise deadlock can arise when a timeout routine calls k_term_timer.)
- */
-static inline void k_term_timer(struct timer_list *timer)
-{
-}
-
-/*
  * TIPC message buffer code
  *
  * TIPC message buffer headroom reserves space for the worst-case
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index aa722a4..1a3a985 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -38,10 +38,14 @@
 #include "link.h"
 #include "discover.h"
 
-#define TIPC_LINK_REQ_INIT	125	/* min delay during bearer start up */
-#define TIPC_LINK_REQ_FAST	1000	/* max delay if bearer has no links */
-#define TIPC_LINK_REQ_SLOW	60000	/* max delay if bearer has links */
-#define TIPC_LINK_REQ_INACTIVE	0xffffffff /* indicates no timer in use */
+/* min delay during bearer start up */
+#define TIPC_LINK_REQ_INIT	msecs_to_jiffies(125)
+/* max delay if bearer has no links */
+#define TIPC_LINK_REQ_FAST	msecs_to_jiffies(1000)
+/* max delay if bearer has links */
+#define TIPC_LINK_REQ_SLOW	msecs_to_jiffies(60000)
+/* indicates no timer in use */
+#define TIPC_LINK_REQ_INACTIVE	0xffffffff
 
 
 /**
@@ -63,7 +67,7 @@ struct tipc_link_req {
 	spinlock_t lock;
 	struct sk_buff *buf;
 	struct timer_list timer;
-	unsigned int timer_intv;
+	unsigned long timer_intv;
 };
 
 /**
@@ -265,7 +269,7 @@ static void disc_update(struct tipc_link_req *req)
 		if ((req->timer_intv == TIPC_LINK_REQ_INACTIVE) ||
 		    (req->timer_intv > TIPC_LINK_REQ_FAST)) {
 			req->timer_intv = TIPC_LINK_REQ_INIT;
-			k_start_timer(&req->timer, req->timer_intv);
+			mod_timer(&req->timer, jiffies + req->timer_intv);
 		}
 	}
 }
@@ -295,12 +299,13 @@ void tipc_disc_remove_dest(struct tipc_link_req *req)
 
 /**
  * disc_timeout - send a periodic link setup request
- * @req: ptr to link request structure
+ * @data: ptr to link request structure
  *
  * Called whenever a link setup request timer associated with a bearer expires.
  */
-static void disc_timeout(struct tipc_link_req *req)
+static void disc_timeout(unsigned long data)
 {
+	struct tipc_link_req *req = (struct tipc_link_req *)data;
 	int max_delay;
 
 	spin_lock_bh(&req->lock);
@@ -329,7 +334,7 @@ static void disc_timeout(struct tipc_link_req *req)
 	if (req->timer_intv > max_delay)
 		req->timer_intv = max_delay;
 
-	k_start_timer(&req->timer, req->timer_intv);
+	mod_timer(&req->timer, jiffies + req->timer_intv);
 exit:
 	spin_unlock_bh(&req->lock);
 }
@@ -363,8 +368,8 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	spin_lock_init(&req->lock);
-	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
-	k_start_timer(&req->timer, req->timer_intv);
+	setup_timer(&req->timer, disc_timeout, (unsigned long)req);
+	mod_timer(&req->timer, jiffies + req->timer_intv);
 	b_ptr->link_req = req;
 	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
 	return 0;
@@ -376,8 +381,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
  */
 void tipc_disc_delete(struct tipc_link_req *req)
 {
-	k_cancel_timer(&req->timer);
-	k_term_timer(&req->timer);
+	del_timer_sync(&req->timer);
 	kfree_skb(req->buf);
 	kfree(req);
 }
@@ -397,7 +401,7 @@ void tipc_disc_reset(struct tipc_bearer *b_ptr)
 	req->domain = b_ptr->domain;
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
-	k_start_timer(&req->timer, req->timer_intv);
+	mod_timer(&req->timer, jiffies + req->timer_intv);
 	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
 	spin_unlock_bh(&req->lock);
 }
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 082c3b5..f2531a8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -106,7 +106,7 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf);
 static int  tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				 struct sk_buff **buf);
-static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
+static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
@@ -169,8 +169,9 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
  * link_timeout - handle expiration of link timer
  * @l_ptr: pointer to link
  */
-static void link_timeout(struct tipc_link *l_ptr)
+static void link_timeout(unsigned long data)
 {
+	struct tipc_link *l_ptr = (struct tipc_link *)data;
 	struct sk_buff *skb;
 
 	tipc_node_lock(l_ptr->owner);
@@ -217,9 +218,9 @@ static void link_timeout(struct tipc_link *l_ptr)
 	tipc_node_unlock(l_ptr->owner);
 }
 
-static void link_set_timer(struct tipc_link *l_ptr, u32 time)
+static void link_set_timer(struct tipc_link *link, unsigned long time)
 {
-	k_start_timer(&l_ptr->timer, time);
+	mod_timer(&link->timer, jiffies + time);
 }
 
 /**
@@ -299,8 +300,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	tipc_node_attach_link(n_ptr, l_ptr);
 
-	k_init_timer(&l_ptr->timer, (Handler)link_timeout,
-		     (unsigned long)l_ptr);
+	setup_timer(&l_ptr->timer, link_timeout, (unsigned long)l_ptr);
 
 	link_state_event(l_ptr, STARTING_EVT);
 
@@ -479,7 +479,7 @@ static void link_activate(struct tipc_link *l_ptr)
 static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 {
 	struct tipc_link *other;
-	u32 cont_intv = l_ptr->continuity_interval;
+	unsigned long cont_intv = l_ptr->cont_intv;
 
 	if (l_ptr->flags & LINK_STOPPED)
 		return;
@@ -1880,15 +1880,16 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 	kfree_skb(buf);
 }
 
-static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
+static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 {
-	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
+	unsigned long intv = ((tol / 4) > 500) ? 500 : tol / 4;
+
+	if ((tol < TIPC_MIN_LINK_TOL) || (tol > TIPC_MAX_LINK_TOL))
 		return;
 
-	l_ptr->tolerance = tolerance;
-	l_ptr->continuity_interval =
-		((tolerance / 4) > 500) ? 500 : tolerance / 4;
-	l_ptr->abort_limit = tolerance / (l_ptr->continuity_interval / 4);
+	l_ptr->tolerance = tol;
+	l_ptr->cont_intv = msecs_to_jiffies(intv);
+	l_ptr->abort_limit = tol / (jiffies_to_msecs(l_ptr->cont_intv) / 4);
 }
 
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 55812e8..15ca850 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -105,7 +105,7 @@ struct tipc_stats {
  * @peer_bearer_id: bearer id used by link's peer endpoint
  * @bearer_id: local bearer id used by link
  * @tolerance: minimum link continuity loss needed to reset link [in ms]
- * @continuity_interval: link continuity testing interval [in ms]
+ * @cont_intv: link continuity testing interval
  * @abort_limit: # of unacknowledged continuity probes needed to reset link
  * @state: current state of link FSM
  * @fsm_msg_cnt: # of protocol messages link FSM has sent in current state
@@ -146,7 +146,7 @@ struct tipc_link {
 	u32 peer_bearer_id;
 	u32 bearer_id;
 	u32 tolerance;
-	u32 continuity_interval;
+	unsigned long cont_intv;
 	u32 abort_limit;
 	int state;
 	u32 fsm_msg_cnt;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index d5c83d7..1a52f7c 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -77,12 +77,10 @@
 
 #define TIPC_MEDIA_ADDR_OFFSET	5
 
-
 struct tipc_msg {
 	__be32 hdr[15];
 };
 
-
 static inline u32 msg_word(struct tipc_msg *m, u32 pos)
 {
 	return ntohl(m->hdr[pos]);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 701f31b..e16197e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -47,7 +47,7 @@
 #define SS_READY		-2	/* socket is connectionless */
 
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
-#define CONN_PROBING_INTERVAL	3600000	/* [ms] => 1 h */
+#define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
 #define TIPC_FWD_MSG		1
 #define TIPC_CONN_OK		0
 #define TIPC_CONN_PROBING	1
@@ -68,7 +68,7 @@
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
- * @probing_interval:
+ * @probing_intv:
  * @timer:
  * @port: port - interacts with 'sk' and with the rest of the TIPC stack
  * @peer_name: the peer of the connection, if any
@@ -93,7 +93,7 @@ struct tipc_sock {
 	struct list_head publications;
 	u32 pub_count;
 	u32 probing_state;
-	u32 probing_interval;
+	unsigned long probing_intv;
 	struct timer_list timer;
 	uint conn_timeout;
 	atomic_t dupl_rcvcnt;
@@ -361,7 +361,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		return -EINVAL;
 	}
 	msg_set_origport(msg, tsk->portid);
-	k_init_timer(&tsk->timer, (Handler)tipc_sk_timeout, tsk->portid);
+	setup_timer(&tsk->timer, tipc_sk_timeout, tsk->portid);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
@@ -511,7 +511,7 @@ static int tipc_release(struct socket *sock)
 	}
 
 	tipc_sk_withdraw(tsk, 0, NULL);
-	k_cancel_timer(&tsk->timer);
+	del_timer_sync(&tsk->timer);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
 		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
@@ -522,7 +522,6 @@ static int tipc_release(struct socket *sock)
 			tipc_link_xmit_skb(skb, dnode, tsk->portid);
 		tipc_node_remove_conn(dnode, tsk->portid);
 	}
-	k_term_timer(&tsk->timer);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
 	__skb_queue_purge(&sk->sk_receive_queue);
@@ -1139,10 +1138,10 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	tsk->probing_interval = CONN_PROBING_INTERVAL;
+	tsk->probing_intv = CONN_PROBING_INTERVAL;
 	tsk->probing_state = TIPC_CONN_OK;
 	tsk->connected = 1;
-	k_start_timer(&tsk->timer, tsk->probing_interval);
+	mod_timer(&tsk->timer, jiffies + tsk->probing_intv);
 	tipc_node_add_conn(peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(peer_node, tsk->portid);
 }
@@ -2128,7 +2127,7 @@ static void tipc_sk_timeout(unsigned long portid)
 				      0, peer_node, tipc_own_addr,
 				      peer_port, portid, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
-		k_start_timer(&tsk->timer, tsk->probing_interval);
+		mod_timer(&tsk->timer, jiffies + tsk->probing_intv);
 	}
 	bh_unlock_sock(sk);
 	if (skb)
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 0344206..e6cb959 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -141,8 +141,9 @@ void tipc_subscr_report_overlap(struct tipc_subscription *sub, u32 found_lower,
 	subscr_send_event(sub, found_lower, found_upper, event, port_ref, node);
 }
 
-static void subscr_timeout(struct tipc_subscription *sub)
+static void subscr_timeout(unsigned long data)
 {
+	struct tipc_subscription *sub = (struct tipc_subscription *)data;
 	struct tipc_subscriber *subscriber = sub->subscriber;
 
 	/* The spin lock per subscriber is used to protect its members */
@@ -167,7 +168,6 @@ static void subscr_timeout(struct tipc_subscription *sub)
 			  TIPC_SUBSCR_TIMEOUT, 0, 0);
 
 	/* Now destroy subscription */
-	k_term_timer(&sub->timer);
 	kfree(sub);
 	atomic_dec(&subscription_count);
 }
@@ -207,8 +207,7 @@ static void subscr_release(struct tipc_subscriber *subscriber)
 				 subscription_list) {
 		if (sub->timeout != TIPC_WAIT_FOREVER) {
 			spin_unlock_bh(&subscriber->lock);
-			k_cancel_timer(&sub->timer);
-			k_term_timer(&sub->timer);
+			del_timer_sync(&sub->timer);
 			spin_lock_bh(&subscriber->lock);
 		}
 		subscr_del(sub);
@@ -250,8 +249,7 @@ static void subscr_cancel(struct tipc_subscr *s,
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
 		sub->timeout = TIPC_WAIT_FOREVER;
 		spin_unlock_bh(&subscriber->lock);
-		k_cancel_timer(&sub->timer);
-		k_term_timer(&sub->timer);
+		del_timer_sync(&sub->timer);
 		spin_lock_bh(&subscriber->lock);
 	}
 	subscr_del(sub);
@@ -296,7 +294,7 @@ static int subscr_subscribe(struct tipc_subscr *s,
 	sub->seq.type = htohl(s->seq.type, swap);
 	sub->seq.lower = htohl(s->seq.lower, swap);
 	sub->seq.upper = htohl(s->seq.upper, swap);
-	sub->timeout = htohl(s->timeout, swap);
+	sub->timeout = msecs_to_jiffies(htohl(s->timeout, swap));
 	sub->filter = htohl(s->filter, swap);
 	if ((!(sub->filter & TIPC_SUB_PORTS) ==
 	     !(sub->filter & TIPC_SUB_SERVICE)) ||
@@ -311,9 +309,8 @@ static int subscr_subscribe(struct tipc_subscr *s,
 	memcpy(&sub->evt.s, s, sizeof(struct tipc_subscr));
 	atomic_inc(&subscription_count);
 	if (sub->timeout != TIPC_WAIT_FOREVER) {
-		k_init_timer(&sub->timer,
-			     (Handler)subscr_timeout, (unsigned long)sub);
-		k_start_timer(&sub->timer, sub->timeout);
+		setup_timer(&sub->timer, subscr_timeout, (unsigned long)sub);
+		mod_timer(&sub->timer, jiffies + sub->timeout);
 	}
 	*sub_p = sub;
 	return 0;
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 393e417..ab01713 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -58,7 +58,7 @@ struct tipc_subscriber;
 struct tipc_subscription {
 	struct tipc_subscriber *subscriber;
 	struct tipc_name_seq seq;
-	u32 timeout;
+	unsigned long timeout;
 	u32 filter;
 	struct timer_list timer;
 	struct list_head nameseq_list;
-- 
1.7.9.5
