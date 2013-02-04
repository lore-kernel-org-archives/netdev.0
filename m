From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2] net: remove redundant check for timer pending state before del_timer
Date: Mon, 4 Feb 2013 14:32:57 +0800
Message-ID: <1359959577-31525-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33300 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3BDGaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 01:30:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As in del_timer() there has already placed a timer_pending() function
to check whether the timer to be deleted is pending or not, it's
unnecessary to check timer pending state again before del_timer() is
called.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Eric Dumazet <edumazet@google.com>
---
v1 -> v2:
 * Remove all redundant timer pending checks for the whole net tree
   instead of only removing timer_pending() in sk_stop_timer().

 net/bluetooth/rfcomm/core.c     |    4 ++--
 net/bridge/netfilter/ebt_ulog.c |    6 ++----
 net/core/sock.c                 |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c   |   12 ++++--------
 net/irda/af_irda.c              |    3 +--
 net/netfilter/ipvs/ip_vs_conn.c |    3 +--
 net/sctp/associola.c            |    5 ++---
 net/sctp/input.c                |    3 +--
 net/sctp/outqueue.c             |    4 +---
 net/sctp/sm_sideeffect.c        |    6 ++----
 net/sctp/transport.c            |   11 ++++-------
 11 files changed, 21 insertions(+), 38 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 201fdf7..b23e271 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -257,7 +257,7 @@ static void rfcomm_session_clear_timer(struct rfcomm_session *s)
 {
 	BT_DBG("session %p state %ld", s, s->state);
 
-	if (timer_pending(&s->timer) && del_timer(&s->timer))
+	if (del_timer(&s->timer))
 		rfcomm_session_put(s);
 }
 
@@ -285,7 +285,7 @@ static void rfcomm_dlc_clear_timer(struct rfcomm_dlc *d)
 {
 	BT_DBG("dlc %p state %ld", d, d->state);
 
-	if (timer_pending(&d->timer) && del_timer(&d->timer))
+	if (del_timer(&d->timer))
 		rfcomm_dlc_put(d);
 }
 
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 3476ec4..3bf43f7 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -70,8 +70,7 @@ static void ulog_send(unsigned int nlgroup)
 {
 	ebt_ulog_buff_t *ub = &ulog_buffers[nlgroup];
 
-	if (timer_pending(&ub->timer))
-		del_timer(&ub->timer);
+	del_timer(&ub->timer);
 
 	if (!ub->skb)
 		return;
@@ -319,8 +318,7 @@ static void __exit ebt_ulog_fini(void)
 	xt_unregister_target(&ebt_ulog_tg_reg);
 	for (i = 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
 		ub = &ulog_buffers[i];
-		if (timer_pending(&ub->timer))
-			del_timer(&ub->timer);
+		del_timer(&ub->timer);
 		spin_lock_bh(&ub->lock);
 		if (ub->skb) {
 			kfree_skb(ub->skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 235fb89..f1e14e2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2230,7 +2230,7 @@ EXPORT_SYMBOL(sk_reset_timer);
 
 void sk_stop_timer(struct sock *sk, struct timer_list* timer)
 {
-	if (timer_pending(timer) && del_timer(timer))
+	if (del_timer(timer))
 		__sock_put(sk);
 }
 EXPORT_SYMBOL(sk_stop_timer);
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index b5ef3cb..7d168dc 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -88,10 +88,8 @@ static void ulog_send(unsigned int nlgroupnum)
 {
 	ulog_buff_t *ub = &ulog_buffers[nlgroupnum];
 
-	if (timer_pending(&ub->timer)) {
-		pr_debug("ulog_send: timer was pending, deleting\n");
-		del_timer(&ub->timer);
-	}
+	pr_debug("ulog_send: timer is deleting\n");
+	del_timer(&ub->timer);
 
 	if (!ub->skb) {
 		pr_debug("ulog_send: nothing to send\n");
@@ -426,10 +424,8 @@ static void __exit ulog_tg_exit(void)
 	/* remove pending timers and free allocated skb's */
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++) {
 		ub = &ulog_buffers[i];
-		if (timer_pending(&ub->timer)) {
-			pr_debug("timer was pending, deleting\n");
-			del_timer(&ub->timer);
-		}
+		pr_debug("timer is deleting\n");
+		del_timer(&ub->timer);
 
 		if (ub->skb) {
 			kfree_skb(ub->skb);
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index b833677..d07e3a6 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2567,8 +2567,7 @@ bed:
 						   err);
 
 			/* If watchdog is still activated, kill it! */
-			if(timer_pending(&(self->watchdog)))
-				del_timer(&(self->watchdog));
+			del_timer(&(self->watchdog));
 
 			IRDA_DEBUG(1, "%s(), ...waking up !\n", __func__);
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 30e764a..68e368a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -796,8 +796,7 @@ static void ip_vs_conn_expire(unsigned long data)
 	 */
 	if (likely(atomic_read(&cp->refcnt) == 1)) {
 		/* delete the timer if it is activated by other users */
-		if (timer_pending(&cp->timer))
-			del_timer(&cp->timer);
+		del_timer(&cp->timer);
 
 		/* does anybody control me? */
 		if (cp->control)
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b45ed1f..2f95f5a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -434,8 +434,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	 * on our state.
 	 */
 	for (i = SCTP_EVENT_TIMEOUT_NONE; i < SCTP_NUM_TIMEOUT_TYPES; ++i) {
-		if (timer_pending(&asoc->timers[i]) &&
-		    del_timer(&asoc->timers[i]))
+		if (del_timer(&asoc->timers[i]))
 			sctp_association_put(asoc);
 	}
 
@@ -1497,7 +1496,7 @@ void sctp_assoc_rwnd_increase(struct sctp_association *asoc, unsigned int len)
 
 		/* Stop the SACK timer.  */
 		timer = &asoc->timers[SCTP_EVENT_TIMEOUT_SACK];
-		if (timer_pending(timer) && del_timer(timer))
+		if (del_timer(timer))
 			sctp_association_put(asoc);
 	}
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 8bd3c27..965bbbb 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -468,8 +468,7 @@ void sctp_icmp_proto_unreachable(struct sock *sk,
 	} else {
 		struct net *net = sock_net(sk);
 
-		if (timer_pending(&t->proto_unreach_timer) &&
-		    del_timer(&t->proto_unreach_timer))
+		if (del_timer(&t->proto_unreach_timer))
 			sctp_association_put(asoc);
 
 		sctp_do_sm(net, SCTP_EVENT_T_OTHER,
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 9bcdbd0..01dca75 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1700,10 +1700,8 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 		 * address.
 		 */
 		if (!transport->flight_size) {
-			if (timer_pending(&transport->T3_rtx_timer) &&
-			    del_timer(&transport->T3_rtx_timer)) {
+			if (del_timer(&transport->T3_rtx_timer))
 				sctp_transport_put(transport);
-			}
 		} else if (restart_timer) {
 			if (!mod_timer(&transport->T3_rtx_timer,
 				       jiffies + transport->rto))
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index c957775..8aab894 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -674,10 +674,8 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 
 	list_for_each_entry(t, &asoc->peer.transport_addr_list,
 			transports) {
-		if (timer_pending(&t->T3_rtx_timer) &&
-		    del_timer(&t->T3_rtx_timer)) {
+		if (del_timer(&t->T3_rtx_timer))
 			sctp_transport_put(t);
-		}
 	}
 }
 
@@ -1517,7 +1515,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_TIMER_STOP:
 			timer = &asoc->timers[cmd->obj.to];
-			if (timer_pending(timer) && del_timer(timer))
+			if (del_timer(timer))
 				sctp_association_put(asoc);
 			break;
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 4e45bb6..9555a6f 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -151,13 +151,11 @@ void sctp_transport_free(struct sctp_transport *transport)
 	 * structure hang around in memory since we know
 	 * the tranport is going away.
 	 */
-	if (timer_pending(&transport->T3_rtx_timer) &&
-	    del_timer(&transport->T3_rtx_timer))
+	if (del_timer(&transport->T3_rtx_timer))
 		sctp_transport_put(transport);
 
 	/* Delete the ICMP proto unreachable timer if it's active. */
-	if (timer_pending(&transport->proto_unreach_timer) &&
-	    del_timer(&transport->proto_unreach_timer))
+	if (del_timer(&transport->proto_unreach_timer))
 		sctp_association_put(transport->asoc);
 
 	sctp_transport_put(transport);
@@ -654,10 +652,9 @@ void sctp_transport_reset(struct sctp_transport *t)
 void sctp_transport_immediate_rtx(struct sctp_transport *t)
 {
 	/* Stop pending T3_rtx_timer */
-	if (timer_pending(&t->T3_rtx_timer)) {
-		(void)del_timer(&t->T3_rtx_timer);
+	if (del_timer(&t->T3_rtx_timer))
 		sctp_transport_put(t);
-	}
+
 	sctp_retransmit(&t->asoc->outqueue, t, SCTP_RTXR_T3_RTX);
 	if (!timer_pending(&t->T3_rtx_timer)) {
 		if (!mod_timer(&t->T3_rtx_timer, jiffies + t->rto))
-- 
1.7.1
