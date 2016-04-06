From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2] sctp: avoid refreshing heartbeat timer too often
Date: Wed,  6 Apr 2016 15:15:19 -0300
Message-ID: <7aa05d5d8b9100fa48798b43887de6d14d577eac.1459966346.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624AbcDFSPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 14:15:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently on high rate SCTP streams the heartbeat timer refresh can
consume quite a lot of resources as timer updates are costly and it
contains a random factor, which a) is also costly and b) invalidates
mod_timer() optimization for not editing a timer to the same value.
It may even cause the timer to be slightly advanced, for no good reason.

As suggested by David Laight this patch now removes this timer update
from hot path by leaving the timer on and re-evaluating upon its
expiration if the heartbeat is still needed or not, similarly to what is
done for TCP. If it's not needed anymore the timer is re-scheduled to
the new timeout, considering the time already elapsed.

For this, we now record the last tx timestamp per transport, updated in
the same spots as hb timer was restarted on tx. Also split up
sctp_transport_reset_timers into sctp_transport_reset_t3_rtx and
sctp_transport_reset_hb_timer, so we can re-arm T3 without re-arming the
heartbeat one.

On loopback with MTU of 65535 and data chunks with 1636, so that we
have a considerable amount of chunks without stressing system calls,
netperf -t SCTP_STREAM -l 30, perf looked like this before:

Samples: 103K of event 'cpu-clock', Event count (approx.): 25833000000
  Overhead  Command  Shared Object      Symbol
+    6,15%  netperf  [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
-    5,43%  netperf  [kernel.vmlinux]   [k] _raw_write_unlock_irqrestore
   - _raw_write_unlock_irqrestore
      - 96,54% _raw_spin_unlock_irqrestore
         - 36,14% mod_timer
            + 97,24% sctp_transport_reset_timers
            + 2,76% sctp_do_sm
         + 33,65% __wake_up_sync_key
         + 28,77% sctp_ulpq_tail_event
         + 1,40% del_timer
      - 1,84% mod_timer
         + 99,03% sctp_transport_reset_timers
         + 0,97% sctp_do_sm
      + 1,50% sctp_ulpq_tail_event

And after this patch, now with netperf -l 60:

Samples: 230K of event 'cpu-clock', Event count (approx.): 57707250000
  Overhead  Command  Shared Object      Symbol
+    5,65%  netperf  [kernel.vmlinux]   [k] memcpy_erms
+    5,59%  netperf  [kernel.vmlinux]   [k] copy_user_enhanced_fast_string
-    5,05%  netperf  [kernel.vmlinux]   [k] _raw_spin_unlock_irqrestore
   - _raw_spin_unlock_irqrestore
      + 49,89% __wake_up_sync_key
      + 45,68% sctp_ulpq_tail_event
      - 2,85% mod_timer
         + 76,51% sctp_transport_reset_t3_rtx
         + 23,49% sctp_do_sm
      + 1,55% del_timer
+    2,50%  netperf  [sctp]             [k] sctp_datamsg_from_user
+    2,26%  netperf  [sctp]             [k] sctp_sendmsg

Throughput-wise, from 6800mbps without the patch to 7050mbps with it,
~3.7%.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
v2:
  patch re-checked, fixed indentation issue.

 include/net/sctp/structs.h |  8 +++++++-
 net/sctp/outqueue.c        | 15 ++++++++++-----
 net/sctp/sm_make_chunk.c   |  3 +--
 net/sctp/sm_sideeffect.c   | 36 ++++++++++++++++--------------------
 net/sctp/transport.c       | 19 +++++++++++++------
 5 files changed, 47 insertions(+), 34 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6df1ce7a411c548bda4163840a90578b6e1b4cfe..5a404c354f4c787e57a6ab6ca68b3ffc537eb1cc 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -847,6 +847,11 @@ struct sctp_transport {
 	 */
 	ktime_t last_time_heard;
 
+	/* When was the last time that we sent a chunk using this
+	 * transport? We use this to check for idle transports
+	 */
+	unsigned long last_time_sent;
+
 	/* Last time(in jiffies) when cwnd is reduced due to the congestion
 	 * indication based on ECNE chunk.
 	 */
@@ -952,7 +957,8 @@ void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
 			  struct sctp_sock *);
 void sctp_transport_pmtu(struct sctp_transport *, struct sock *sk);
 void sctp_transport_free(struct sctp_transport *);
-void sctp_transport_reset_timers(struct sctp_transport *);
+void sctp_transport_reset_t3_rtx(struct sctp_transport *);
+void sctp_transport_reset_hb_timer(struct sctp_transport *);
 int sctp_transport_hold(struct sctp_transport *);
 void sctp_transport_put(struct sctp_transport *);
 void sctp_transport_update_rto(struct sctp_transport *, __u32);
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 8d3d3625130ee0fd294998554a9290d57eae56e7..084718f9b3dad09e21e41e34b989e25627058c98 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -866,8 +866,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 				 * sender MUST assure that at least one T3-rtx
 				 * timer is running.
 				 */
-				if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN)
-					sctp_transport_reset_timers(transport);
+				if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN) {
+					sctp_transport_reset_t3_rtx(transport);
+					transport->last_time_sent = jiffies;
+				}
 			}
 			break;
 
@@ -924,8 +926,10 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			error = sctp_outq_flush_rtx(q, packet,
 						    rtx_timeout, &start_timer);
 
-			if (start_timer)
-				sctp_transport_reset_timers(transport);
+			if (start_timer) {
+				sctp_transport_reset_t3_rtx(transport);
+				transport->last_time_sent = jiffies;
+			}
 
 			/* This can happen on COOKIE-ECHO resend.  Only
 			 * one chunk can get bundled with a COOKIE-ECHO.
@@ -1062,7 +1066,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			list_add_tail(&chunk->transmitted_list,
 				      &transport->transmitted);
 
-			sctp_transport_reset_timers(transport);
+			sctp_transport_reset_t3_rtx(transport);
+			transport->last_time_sent = jiffies;
 
 			/* Only let one DATA chunk get bundled with a
 			 * COOKIE-ECHO chunk.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 7f0bf798205ba3c5311bf57ace66aaaa57cb0367..56f364d8f93270f31867333585fb28317f9d87ad 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3080,8 +3080,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 			return SCTP_ERROR_RSRC_LOW;
 
 		/* Start the heartbeat timer. */
-		if (!mod_timer(&peer->hb_timer, sctp_transport_timeout(peer)))
-			sctp_transport_hold(peer);
+		sctp_transport_reset_hb_timer(peer);
 		asoc->new_transport = peer;
 		break;
 	case SCTP_PARAM_DEL_IP:
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 7fe56d0acabf66cfd8fe29dfdb45f7620b470ac7..41b081a64752da3e4de5dafe6d3afac84bf4923d 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -69,8 +69,6 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 			     sctp_cmd_seq_t *commands,
 			     gfp_t gfp);
 
-static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
-				     struct sctp_transport *t);
 /********************************************************************
  * Helper functions
  ********************************************************************/
@@ -367,6 +365,7 @@ void sctp_generate_heartbeat_event(unsigned long data)
 	struct sctp_association *asoc = transport->asoc;
 	struct sock *sk = asoc->base.sk;
 	struct net *net = sock_net(sk);
+	u32 elapsed, timeout;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -378,6 +377,16 @@ void sctp_generate_heartbeat_event(unsigned long data)
 		goto out_unlock;
 	}
 
+	/* Check if we should still send the heartbeat or reschedule */
+	elapsed = jiffies - transport->last_time_sent;
+	timeout = sctp_transport_timeout(transport);
+	if (elapsed < timeout) {
+		elapsed = timeout - elapsed;
+		if (!mod_timer(&transport->hb_timer, jiffies + elapsed))
+			sctp_transport_hold(transport);
+		goto out_unlock;
+	}
+
 	error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
 			   SCTP_ST_TIMEOUT(SCTP_EVENT_TIMEOUT_HEARTBEAT),
 			   asoc->state, asoc->ep, asoc,
@@ -507,7 +516,7 @@ static void sctp_do_8_2_transport_strike(sctp_cmd_seq_t *commands,
 					     0);
 
 		/* Update the hb timer to resend a heartbeat every rto */
-		sctp_cmd_hb_timer_update(commands, transport);
+		sctp_transport_reset_hb_timer(transport);
 	}
 
 	if (transport->state != SCTP_INACTIVE &&
@@ -634,11 +643,8 @@ static void sctp_cmd_hb_timers_start(sctp_cmd_seq_t *cmds,
 	 * hold a reference on the transport to make sure none of
 	 * the needed data structures go away.
 	 */
-	list_for_each_entry(t, &asoc->peer.transport_addr_list, transports) {
-
-		if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
-			sctp_transport_hold(t);
-	}
+	list_for_each_entry(t, &asoc->peer.transport_addr_list, transports)
+		sctp_transport_reset_hb_timer(t);
 }
 
 static void sctp_cmd_hb_timers_stop(sctp_cmd_seq_t *cmds,
@@ -669,15 +675,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 }
 
 
-/* Helper function to update the heartbeat timer. */
-static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
-				     struct sctp_transport *t)
-{
-	/* Update the heartbeat timer.  */
-	if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
-		sctp_transport_hold(t);
-}
-
 /* Helper function to handle the reception of an HEARTBEAT ACK.  */
 static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 				  struct sctp_association *asoc,
@@ -742,8 +739,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	sctp_transport_update_rto(t, (jiffies - hbinfo->sent_at));
 
 	/* Update the heartbeat timer.  */
-	if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
-		sctp_transport_hold(t);
+	sctp_transport_reset_hb_timer(t);
 
 	if (was_unconfirmed && asoc->peer.transport_count == 1)
 		sctp_transport_immediate_rtx(t);
@@ -1614,7 +1610,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_HB_TIMER_UPDATE:
 			t = cmd->obj.transport;
-			sctp_cmd_hb_timer_update(commands, t);
+			sctp_transport_reset_hb_timer(t);
 			break;
 
 		case SCTP_CMD_HB_TIMERS_STOP:
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 9b6b48c7524e4b441a151b80f0babec81f539d49..81b86678be4d6fccc527d3c3e509c12576b2194c 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -183,7 +183,7 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
 /* Start T3_rtx timer if it is not already running and update the heartbeat
  * timer.  This routine is called every time a DATA chunk is sent.
  */
-void sctp_transport_reset_timers(struct sctp_transport *transport)
+void sctp_transport_reset_t3_rtx(struct sctp_transport *transport)
 {
 	/* RFC 2960 6.3.2 Retransmission Timer Rules
 	 *
@@ -197,11 +197,18 @@ void sctp_transport_reset_timers(struct sctp_transport *transport)
 		if (!mod_timer(&transport->T3_rtx_timer,
 			       jiffies + transport->rto))
 			sctp_transport_hold(transport);
+}
+
+void sctp_transport_reset_hb_timer(struct sctp_transport *transport)
+{
+	unsigned long expires;
 
 	/* When a data chunk is sent, reset the heartbeat interval.  */
-	if (!mod_timer(&transport->hb_timer,
-		       sctp_transport_timeout(transport)))
-	    sctp_transport_hold(transport);
+	expires = jiffies + sctp_transport_timeout(transport);
+	if (time_before(transport->hb_timer.expires, expires) &&
+	    !mod_timer(&transport->hb_timer,
+		       expires + prandom_u32_max(transport->rto)))
+		sctp_transport_hold(transport);
 }
 
 /* This transport has been assigned to an association.
@@ -595,13 +602,13 @@ void sctp_transport_burst_reset(struct sctp_transport *t)
 unsigned long sctp_transport_timeout(struct sctp_transport *trans)
 {
 	/* RTO + timer slack +/- 50% of RTO */
-	unsigned long timeout = (trans->rto >> 1) + prandom_u32_max(trans->rto);
+	unsigned long timeout = trans->rto >> 1;
 
 	if (trans->state != SCTP_UNCONFIRMED &&
 	    trans->state != SCTP_PF)
 		timeout += trans->hbinterval;
 
-	return timeout + jiffies;
+	return timeout;
 }
 
 /* Reset transport variables to their initial values */
-- 
2.5.0
