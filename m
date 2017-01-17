From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 2/6] sctp: add stream reconf timer
Date: Wed, 18 Jan 2017 00:44:43 +0800
Message-ID: <1a1ff083ca37b6de6bacf038ae5d0367f0112edd.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
 <eff824eb34c55a83e35334597e6d510a5dde3ce6.1484670664.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33295 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdAQQph (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:45:37 -0500
In-Reply-To: <eff824eb34c55a83e35334597e6d510a5dde3ce6.1484670664.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add a per transport timer based on sctp timer frame
for stream reconf chunk retransmission. It would start after sending
a reconf request chunk, and stop after receiving the response chunk.

If the timer expires, besides retransmitting the reconf request chunk,
it would also do the same thing with data RTO timer. like to increase
the appropriate error counts, and perform threshold management, possibly
destroying the asoc if sctp retransmission thresholds are exceeded, just
as section 5.1.1 describes.

This patch is also to add asoc strreset_chunk, it is used to save the
reconf request chunk, so that it can be retransmitted, and to check if
the response is really for this request by comparing the information
inside with the response chunk as well.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  1 +
 include/net/sctp/sm.h        |  2 ++
 include/net/sctp/structs.h   |  6 ++++++
 net/sctp/associola.c         |  9 +++++++++
 net/sctp/sm_sideeffect.c     | 32 ++++++++++++++++++++++++++++++++
 net/sctp/sm_statefuns.c      | 28 ++++++++++++++++++++++++++++
 net/sctp/sm_statetable.c     | 20 ++++++++++++++++++++
 net/sctp/transport.c         | 17 +++++++++++++++--
 8 files changed, 113 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 5b847e4..8307c86 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -90,6 +90,7 @@ typedef enum {
 	SCTP_EVENT_TIMEOUT_T4_RTO,
 	SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD,
 	SCTP_EVENT_TIMEOUT_HEARTBEAT,
+	SCTP_EVENT_TIMEOUT_RECONF,
 	SCTP_EVENT_TIMEOUT_SACK,
 	SCTP_EVENT_TIMEOUT_AUTOCLOSE,
 } sctp_event_timeout_t;
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 3462cb0..d2d9e28 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -167,6 +167,7 @@ sctp_state_fn_t sctp_sf_cookie_wait_icmp_abort;
 
 /* Prototypes for timeout event state functions.  */
 sctp_state_fn_t sctp_sf_do_6_3_3_rtx;
+sctp_state_fn_t sctp_sf_send_reconf;
 sctp_state_fn_t sctp_sf_do_6_2_sack;
 sctp_state_fn_t sctp_sf_autoclose_timer_expire;
 
@@ -278,6 +279,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
 /* 2nd level prototypes */
 void sctp_generate_t3_rtx_event(unsigned long peer);
 void sctp_generate_heartbeat_event(unsigned long peer);
+void sctp_generate_reconf_event(unsigned long peer);
 void sctp_generate_proto_unreach_event(unsigned long peer);
 
 void sctp_ootb_pkt_free(struct sctp_packet *);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3dc983e..463b4d6 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -877,6 +877,9 @@ struct sctp_transport {
 	/* Timer to handle ICMP proto unreachable envets */
 	struct timer_list proto_unreach_timer;
 
+	/* Timer to handler reconf chunk rtx */
+	struct timer_list reconf_timer;
+
 	/* Since we're using per-destination retransmission timers
 	 * (see above), we're also using per-destination "transmitted"
 	 * queues.  This probably ought to be a private struct
@@ -935,6 +938,7 @@ void sctp_transport_pmtu(struct sctp_transport *, struct sock *sk);
 void sctp_transport_free(struct sctp_transport *);
 void sctp_transport_reset_t3_rtx(struct sctp_transport *);
 void sctp_transport_reset_hb_timer(struct sctp_transport *);
+void sctp_transport_reset_reconf_timer(struct sctp_transport *transport);
 int sctp_transport_hold(struct sctp_transport *);
 void sctp_transport_put(struct sctp_transport *);
 void sctp_transport_update_rto(struct sctp_transport *, __u32);
@@ -1868,6 +1872,8 @@ struct sctp_association {
 	__u32 strreset_outseq; /* Update after receiving response */
 	__u32 strreset_inseq; /* Update after receiving request */
 
+	struct sctp_chunk *strreset_chunk; /* save request chunk */
+
 	struct sctp_priv_assoc_stats stats;
 
 	int sent_cnt_removable;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 42ece6f..fc33540 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -362,6 +362,9 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Free stream information. */
 	sctp_stream_free(asoc->stream);
 
+	if (asoc->strreset_chunk)
+		sctp_chunk_free(asoc->strreset_chunk);
+
 	/* Clean up the bound address list. */
 	sctp_bind_addr_free(&asoc->base.bind_addr);
 
@@ -520,6 +523,12 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 	if (asoc->peer.last_data_from == peer)
 		asoc->peer.last_data_from = transport;
 
+	if (asoc->strreset_chunk &&
+	    asoc->strreset_chunk->transport == peer) {
+		asoc->strreset_chunk->transport = transport;
+		sctp_transport_reset_reconf_timer(transport);
+	}
+
 	/* If we remove the transport an INIT was last sent to, set it to
 	 * NULL. Combined with the update of the retran path above, this
 	 * will cause the next INIT to be sent to the next available
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index c345bf1..a455271 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -436,6 +436,37 @@ void sctp_generate_proto_unreach_event(unsigned long data)
 	sctp_association_put(asoc);
 }
 
+ /* Handle the timeout of the RE-CONFIG timer. */
+void sctp_generate_reconf_event(unsigned long data)
+{
+	struct sctp_transport *transport = (struct sctp_transport *)data;
+	struct sctp_association *asoc = transport->asoc;
+	struct sock *sk = asoc->base.sk;
+	struct net *net = sock_net(sk);
+	int error = 0;
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		pr_debug("%s: sock is busy\n", __func__);
+
+		/* Try again later.  */
+		if (!mod_timer(&transport->reconf_timer, jiffies + (HZ / 20)))
+			sctp_transport_hold(transport);
+		goto out_unlock;
+	}
+
+	error = sctp_do_sm(net, SCTP_EVENT_T_TIMEOUT,
+			   SCTP_ST_TIMEOUT(SCTP_EVENT_TIMEOUT_RECONF),
+			   asoc->state, asoc->ep, asoc,
+			   transport, GFP_ATOMIC);
+
+	if (error)
+		sk->sk_err = -error;
+
+out_unlock:
+	bh_unlock_sock(sk);
+	sctp_transport_put(transport);
+}
 
 /* Inject a SACK Timeout event into the state machine.  */
 static void sctp_generate_sack_event(unsigned long data)
@@ -453,6 +484,7 @@ sctp_timer_event_t *sctp_timer_events[SCTP_NUM_TIMEOUT_TYPES] = {
 	sctp_generate_t4_rto_event,
 	sctp_generate_t5_shutdown_guard_event,
 	NULL,
+	NULL,
 	sctp_generate_sack_event,
 	sctp_generate_autoclose_event,
 };
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 0ceded3..2ae186a 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1021,6 +1021,34 @@ sctp_disposition_t sctp_sf_sendbeat_8_3(struct net *net,
 	return SCTP_DISPOSITION_CONSUME;
 }
 
+/* resend asoc strreset_chunk.  */
+sctp_disposition_t sctp_sf_send_reconf(struct net *net,
+				       const struct sctp_endpoint *ep,
+				       const struct sctp_association *asoc,
+				       const sctp_subtype_t type, void *arg,
+				       sctp_cmd_seq_t *commands)
+{
+	struct sctp_transport *transport = arg;
+
+	if (asoc->overall_error_count >= asoc->max_retrans) {
+		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
+				SCTP_ERROR(ETIMEDOUT));
+		/* CMD_ASSOC_FAILED calls CMD_DELETE_TCB. */
+		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
+				SCTP_PERR(SCTP_ERROR_NO_ERROR));
+		SCTP_INC_STATS(net, SCTP_MIB_ABORTEDS);
+		SCTP_DEC_STATS(net, SCTP_MIB_CURRESTAB);
+		return SCTP_DISPOSITION_DELETE_TCB;
+	}
+
+	sctp_chunk_hold(asoc->strreset_chunk);
+	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+			SCTP_CHUNK(asoc->strreset_chunk));
+	sctp_add_cmd_sf(commands, SCTP_CMD_STRIKE, SCTP_TRANSPORT(transport));
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
 /*
  * Process an heartbeat request.
  *
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index a987d54..3da521a 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -888,6 +888,25 @@ static const sctp_sm_table_entry_t other_event_table[SCTP_NUM_OTHER_TYPES][SCTP_
 	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
 }
 
+#define TYPE_SCTP_EVENT_TIMEOUT_RECONF { \
+	/* SCTP_STATE_CLOSED */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_COOKIE_WAIT */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_COOKIE_ECHOED */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_ESTABLISHED */ \
+	TYPE_SCTP_FUNC(sctp_sf_send_reconf), \
+	/* SCTP_STATE_SHUTDOWN_PENDING */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_SHUTDOWN_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_timer_ignore), \
+}
+
 static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][SCTP_STATE_NUM_STATES] = {
 	TYPE_SCTP_EVENT_TIMEOUT_NONE,
 	TYPE_SCTP_EVENT_TIMEOUT_T1_COOKIE,
@@ -897,6 +916,7 @@ static const sctp_sm_table_entry_t timeout_event_table[SCTP_NUM_TIMEOUT_TYPES][S
 	TYPE_SCTP_EVENT_TIMEOUT_T4_RTO,
 	TYPE_SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD,
 	TYPE_SCTP_EVENT_TIMEOUT_HEARTBEAT,
+	TYPE_SCTP_EVENT_TIMEOUT_RECONF,
 	TYPE_SCTP_EVENT_TIMEOUT_SACK,
 	TYPE_SCTP_EVENT_TIMEOUT_AUTOCLOSE,
 };
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index a1652ab..baa1ac0 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -88,9 +88,11 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 	INIT_LIST_HEAD(&peer->transports);
 
 	setup_timer(&peer->T3_rtx_timer, sctp_generate_t3_rtx_event,
-			(unsigned long)peer);
+		    (unsigned long)peer);
 	setup_timer(&peer->hb_timer, sctp_generate_heartbeat_event,
-			(unsigned long)peer);
+		    (unsigned long)peer);
+	setup_timer(&peer->reconf_timer, sctp_generate_reconf_event,
+		    (unsigned long)peer);
 	setup_timer(&peer->proto_unreach_timer,
 		    sctp_generate_proto_unreach_event, (unsigned long)peer);
 
@@ -144,6 +146,9 @@ void sctp_transport_free(struct sctp_transport *transport)
 	if (del_timer(&transport->T3_rtx_timer))
 		sctp_transport_put(transport);
 
+	if (del_timer(&transport->reconf_timer))
+		sctp_transport_put(transport);
+
 	/* Delete the ICMP proto unreachable timer if it's active. */
 	if (del_timer(&transport->proto_unreach_timer))
 		sctp_association_put(transport->asoc);
@@ -211,6 +216,14 @@ void sctp_transport_reset_hb_timer(struct sctp_transport *transport)
 		sctp_transport_hold(transport);
 }
 
+void sctp_transport_reset_reconf_timer(struct sctp_transport *transport)
+{
+	if (!timer_pending(&transport->reconf_timer))
+		if (!mod_timer(&transport->reconf_timer,
+			       jiffies + transport->rto))
+			sctp_transport_hold(transport);
+}
+
 /* This transport has been assigned to an association.
  * Initialize fields from the association or from the sock itself.
  * Register the reference count in the association.
-- 
2.1.0
