From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/5] [SCTP]: "list_for_each()" -> "list_for_each_entry()" where appropriate.
Date: Thu, 10 Apr 2008 15:39:52 -0400
Message-ID: <1207856394-19321-3-git-send-email-vladislav.yasevich@hp.com>
References: <1207856394-19321-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:16622 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbYDJTkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 15:40:03 -0400
In-Reply-To: <1207856394-19321-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert P. J. Day <rpjday@crashcourse.ca>

Replacing (almost) all invocations of list_for_each() with
list_for_each_entry() tightens up the code and allows for the deletion
of numerous list iterator variables that are no longer necessary.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/associola.c     |   34 +++++++++++----------------
 net/sctp/bind_addr.c     |   15 +++---------
 net/sctp/outqueue.c      |   49 +++++++++++++---------------------------
 net/sctp/proc.c          |    9 ++-----
 net/sctp/sm_make_chunk.c |   10 +++-----
 net/sctp/sm_sideeffect.c |   20 +++++----------
 net/sctp/sm_statefuns.c  |   10 +++-----
 net/sctp/socket.c        |   56 ++++++++++++++--------------------------------
 8 files changed, 69 insertions(+), 134 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 422c98a..b4cd2b7 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -718,12 +718,11 @@ struct sctp_transport *sctp_assoc_lookup_paddr(
 					const union sctp_addr *address)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 
 	/* Cycle through all transports searching for a peer address. */
 
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list,
+			transports) {
 		if (sctp_cmp_addr_exact(address, &t->ipaddr))
 			return t;
 	}
@@ -762,7 +761,6 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	struct sctp_transport *second;
 	struct sctp_ulpevent *event;
 	struct sockaddr_storage addr;
-	struct list_head *pos;
 	int spc_state = 0;
 
 	/* Record the transition on the transport.  */
@@ -814,8 +812,8 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 	 */
 	first = NULL; second = NULL;
 
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list,
+			transports) {
 
 		if ((t->state == SCTP_INACTIVE) ||
 		    (t->state == SCTP_UNCONFIRMED))
@@ -932,7 +930,6 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
 {
 	struct sctp_transport *active;
 	struct sctp_transport *match;
-	struct list_head *entry, *pos;
 	struct sctp_transport *transport;
 	struct sctp_chunk *chunk;
 	__be32 key = htonl(tsn);
@@ -956,8 +953,8 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
 
 	active = asoc->peer.active_path;
 
-	list_for_each(entry, &active->transmitted) {
-		chunk = list_entry(entry, struct sctp_chunk, transmitted_list);
+	list_for_each_entry(chunk, &active->transmitted,
+			transmitted_list) {
 
 		if (key == chunk->subh.data_hdr->tsn) {
 			match = active;
@@ -966,14 +963,13 @@ struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *asoc,
 	}
 
 	/* If not found, go search all the other transports. */
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
+			transports) {
 
 		if (transport == active)
 			break;
-		list_for_each(entry, &transport->transmitted) {
-			chunk = list_entry(entry, struct sctp_chunk,
-					   transmitted_list);
+		list_for_each_entry(chunk, &transport->transmitted,
+				transmitted_list) {
 			if (key == chunk->subh.data_hdr->tsn) {
 				match = transport;
 				goto out;
@@ -1154,9 +1150,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 
 	} else {
 		/* Add any peer addresses from the new association. */
-		list_for_each(pos, &new->peer.transport_addr_list) {
-			trans = list_entry(pos, struct sctp_transport,
-					   transports);
+		list_for_each_entry(trans, &new->peer.transport_addr_list,
+				transports) {
 			if (!sctp_assoc_lookup_paddr(asoc, &trans->ipaddr))
 				sctp_assoc_add_peer(asoc, &trans->ipaddr,
 						    GFP_ATOMIC, trans->state);
@@ -1306,15 +1301,14 @@ struct sctp_transport *sctp_assoc_choose_shutdown_transport(
 void sctp_assoc_sync_pmtu(struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 	__u32 pmtu = 0;
 
 	if (!asoc)
 		return;
 
 	/* Get the lowest pmtu of all the transports. */
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list,
+				transports) {
 		if (t->pmtu_pending && t->dst) {
 			sctp_transport_update_pmtu(t, dst_mtu(t->dst));
 			t->pmtu_pending = 0;
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index ceefda0..80e6df0 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -67,15 +67,13 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
 			int flags)
 {
 	struct sctp_sockaddr_entry *addr;
-	struct list_head *pos;
 	int error = 0;
 
 	/* All addresses share the same port.  */
 	dest->port = src->port;
 
 	/* Extract the addresses which are relevant for this scope.  */
-	list_for_each(pos, &src->address_list) {
-		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+	list_for_each_entry(addr, &src->address_list, list) {
 		error = sctp_copy_one_addr(dest, &addr->a, scope,
 					   gfp, flags);
 		if (error < 0)
@@ -87,9 +85,7 @@ int sctp_bind_addr_copy(struct sctp_bind_addr *dest,
 	 * the assumption that we must be sitting behind a NAT.
 	 */
 	if (list_empty(&dest->address_list) && (SCTP_SCOPE_GLOBAL == scope)) {
-		list_for_each(pos, &src->address_list) {
-			addr = list_entry(pos, struct sctp_sockaddr_entry,
-					  list);
+		list_for_each_entry(addr, &src->address_list, list) {
 			error = sctp_copy_one_addr(dest, &addr->a,
 						   SCTP_SCOPE_LINK, gfp,
 						   flags);
@@ -115,14 +111,12 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
 			gfp_t gfp)
 {
 	struct sctp_sockaddr_entry *addr;
-	struct list_head *pos;
 	int error = 0;
 
 	/* All addresses share the same port.  */
 	dest->port = src->port;
 
-	list_for_each(pos, &src->address_list) {
-		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+	list_for_each_entry(addr, &src->address_list, list) {
 		error = sctp_add_bind_addr(dest, &addr->a, 1, gfp);
 		if (error < 0)
 			break;
@@ -273,8 +267,7 @@ union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
 
 	addrparms = retval;
 
-	list_for_each(pos, &bp->address_list) {
-		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
+	list_for_each_entry(addr, &bp->address_list, list) {
 		af = sctp_get_af_specific(addr->a.v4.sin_family);
 		len = af->to_addr_param(&addr->a, &rawaddr);
 		memcpy(addrparms.v, &rawaddr, len);
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 392012f..213c2e2 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -221,12 +221,12 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 void sctp_outq_teardown(struct sctp_outq *q)
 {
 	struct sctp_transport *transport;
-	struct list_head *lchunk, *pos, *temp;
+	struct list_head *lchunk, *temp;
 	struct sctp_chunk *chunk, *tmp;
 
 	/* Throw away unacknowledged chunks. */
-	list_for_each(pos, &q->asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(transport, &q->asoc->peer.transport_addr_list,
+			transports) {
 		while ((lchunk = sctp_list_dequeue(&transport->transmitted)) != NULL) {
 			chunk = list_entry(lchunk, struct sctp_chunk,
 					   transmitted_list);
@@ -538,7 +538,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 			       int rtx_timeout, int *start_timer)
 {
 	struct list_head *lqueue;
-	struct list_head *lchunk, *lchunk1;
+	struct list_head *lchunk;
 	struct sctp_transport *transport = pkt->transport;
 	sctp_xmit_t status;
 	struct sctp_chunk *chunk, *chunk1;
@@ -649,9 +649,7 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 		 * to be marked as ineligible for a subsequent fast retransmit.
 		 */
 		if (rtx_timeout && !lchunk) {
-			list_for_each(lchunk1, lqueue) {
-				chunk1 = list_entry(lchunk1, struct sctp_chunk,
-						    transmitted_list);
+			list_for_each_entry(chunk1, lqueue, transmitted_list) {
 				if (chunk1->fast_retransmit > 0)
 					chunk1->fast_retransmit = -1;
 			}
@@ -1037,7 +1035,6 @@ static void sctp_sack_update_unack_data(struct sctp_association *assoc,
 static __u32 sctp_highest_new_tsn(struct sctp_sackhdr *sack,
 				  struct sctp_association *asoc)
 {
-	struct list_head *ltransport, *lchunk;
 	struct sctp_transport *transport;
 	struct sctp_chunk *chunk;
 	__u32 highest_new_tsn, tsn;
@@ -1045,12 +1042,9 @@ static __u32 sctp_highest_new_tsn(struct sctp_sackhdr *sack,
 
 	highest_new_tsn = ntohl(sack->cum_tsn_ack);
 
-	list_for_each(ltransport, transport_list) {
-		transport = list_entry(ltransport, struct sctp_transport,
-				       transports);
-		list_for_each(lchunk, &transport->transmitted) {
-			chunk = list_entry(lchunk, struct sctp_chunk,
-					   transmitted_list);
+	list_for_each_entry(transport, transport_list, transports) {
+		list_for_each_entry(chunk, &transport->transmitted,
+				transmitted_list) {
 			tsn = ntohl(chunk->subh.data_hdr->tsn);
 
 			if (!chunk->tsn_gap_acked &&
@@ -1073,7 +1067,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	struct sctp_association *asoc = q->asoc;
 	struct sctp_transport *transport;
 	struct sctp_chunk *tchunk = NULL;
-	struct list_head *lchunk, *transport_list, *pos, *temp;
+	struct list_head *lchunk, *transport_list, *temp;
 	sctp_sack_variable_t *frags = sack->variable;
 	__u32 sack_ctsn, ctsn, tsn;
 	__u32 highest_tsn, highest_new_tsn;
@@ -1099,9 +1093,8 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	 */
 	if (TSN_lte(primary->cacc.next_tsn_at_change, sack_ctsn)) {
 		primary->cacc.changeover_active = 0;
-		list_for_each(pos, transport_list) {
-			transport = list_entry(pos, struct sctp_transport,
-					transports);
+		list_for_each_entry(transport, transport_list,
+				transports) {
 			transport->cacc.cycling_changeover = 0;
 		}
 	}
@@ -1116,9 +1109,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	 */
 	if (sack->num_gap_ack_blocks &&
 	    primary->cacc.changeover_active) {
-		list_for_each(pos, transport_list) {
-			transport = list_entry(pos, struct sctp_transport,
-					transports);
+		list_for_each_entry(transport, transport_list, transports) {
 			transport->cacc.cacc_saw_newack = 0;
 		}
 	}
@@ -1147,9 +1138,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	 *
 	 * This is a MASSIVE candidate for optimization.
 	 */
-	list_for_each(pos, transport_list) {
-		transport  = list_entry(pos, struct sctp_transport,
-					transports);
+	list_for_each_entry(transport, transport_list, transports) {
 		sctp_check_transmitted(q, &transport->transmitted,
 				       transport, sack, highest_new_tsn);
 		/*
@@ -1161,9 +1150,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 			count_of_newacks ++;
 	}
 
-	list_for_each(pos, transport_list) {
-		transport  = list_entry(pos, struct sctp_transport,
-					transports);
+	list_for_each_entry(transport, transport_list, transports) {
 		sctp_mark_missing(q, &transport->transmitted, transport,
 				  highest_new_tsn, count_of_newacks);
 	}
@@ -1220,9 +1207,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	if (!q->empty)
 		goto finish;
 
-	list_for_each(pos, transport_list) {
-		transport  = list_entry(pos, struct sctp_transport,
-					transports);
+	list_for_each_entry(transport, transport_list, transports) {
 		q->empty = q->empty && list_empty(&transport->transmitted);
 		if (!q->empty)
 			goto finish;
@@ -1596,14 +1581,12 @@ static void sctp_mark_missing(struct sctp_outq *q,
 			      int count_of_newacks)
 {
 	struct sctp_chunk *chunk;
-	struct list_head *pos;
 	__u32 tsn;
 	char do_fast_retransmit = 0;
 	struct sctp_transport *primary = q->asoc->peer.primary_path;
 
-	list_for_each(pos, transmitted_queue) {
+	list_for_each_entry(chunk, transmitted_queue, transmitted_list) {
 
-		chunk = list_entry(pos, struct sctp_chunk, transmitted_list);
 		tsn = ntohl(chunk->subh.data_hdr->tsn);
 
 		/* RFC 2960 7.2.4, sctpimpguide-05 2.8.2 M3) Examine all
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 99062f5..0aba759 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -124,7 +124,6 @@ void sctp_snmp_proc_exit(void)
 /* Dump local addresses of an association/endpoint. */
 static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_common *epb)
 {
-	struct list_head *pos;
 	struct sctp_association *asoc;
 	struct sctp_sockaddr_entry *laddr;
 	struct sctp_transport *peer;
@@ -137,8 +136,7 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 	    primary = &peer->saddr;
 	}
 
-	list_for_each(pos, &epb->bind_addr.address_list) {
-		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
+	list_for_each_entry(laddr, &epb->bind_addr.address_list, list) {
 		addr = &laddr->a;
 		af = sctp_get_af_specific(addr->sa.sa_family);
 		if (primary && af->cmp_addr(addr, primary)) {
@@ -151,14 +149,13 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 /* Dump remote addresses of an association. */
 static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_association *assoc)
 {
-	struct list_head *pos;
 	struct sctp_transport *transport;
 	union sctp_addr *addr, *primary;
 	struct sctp_af *af;
 
 	primary = &assoc->peer.primary_addr;
-	list_for_each(pos, &assoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(transport, &assoc->peer.transport_addr_list,
+			transports) {
 		addr = &transport->ipaddr;
 		af = sctp_get_af_specific(addr->sa.sa_family);
 		if (af->cmp_addr(addr, primary)) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index c898245..0679bdd 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2246,8 +2246,8 @@ int sctp_process_init(struct sctp_association *asoc, sctp_cid_t cid,
 	 * high (for example, implementations MAY use the size of the receiver
 	 * advertised window).
 	 */
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(transport, &asoc->peer.transport_addr_list,
+			transports) {
 		transport->ssthresh = asoc->peer.i.a_rwnd;
 	}
 
@@ -3043,7 +3043,6 @@ static int sctp_asconf_param_success(struct sctp_association *asoc,
 	union sctp_addr	addr;
 	struct sctp_bind_addr *bp = &asoc->base.bind_addr;
 	union sctp_addr_param *addr_param;
-	struct list_head *pos;
 	struct sctp_transport *transport;
 	struct sctp_sockaddr_entry *saddr;
 	int retval = 0;
@@ -3071,9 +3070,8 @@ static int sctp_asconf_param_success(struct sctp_association *asoc,
 		local_bh_disable();
 		retval = sctp_del_bind_addr(bp, &addr);
 		local_bh_enable();
-		list_for_each(pos, &asoc->peer.transport_addr_list) {
-			transport = list_entry(pos, struct sctp_transport,
-						 transports);
+		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
+				transports) {
 			dst_release(transport->dst);
 			sctp_transport_route(transport, NULL,
 					     sctp_sk(asoc->base.sk));
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 02bf32c..5fdb623 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -545,14 +545,12 @@ static void sctp_cmd_hb_timers_start(sctp_cmd_seq_t *cmds,
 				     struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 
 	/* Start a heartbeat timer for each transport on the association.
 	 * hold a reference on the transport to make sure none of
 	 * the needed data structures go away.
 	 */
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list, transports) {
 
 		if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
 			sctp_transport_hold(t);
@@ -563,12 +561,11 @@ static void sctp_cmd_hb_timers_stop(sctp_cmd_seq_t *cmds,
 				    struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 
 	/* Stop all heartbeat timers. */
 
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list,
+			transports) {
 		if (del_timer(&t->hb_timer))
 			sctp_transport_put(t);
 	}
@@ -579,10 +576,9 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 					struct sctp_association *asoc)
 {
 	struct sctp_transport *t;
-	struct list_head *pos;
 
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(t, &asoc->peer.transport_addr_list,
+			transports) {
 		if (timer_pending(&t->T3_rtx_timer) &&
 		    del_timer(&t->T3_rtx_timer)) {
 			sctp_transport_put(t);
@@ -1065,7 +1061,6 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 	struct sctp_chunk *new_obj;
 	struct sctp_chunk *chunk = NULL;
 	struct sctp_packet *packet;
-	struct list_head *pos;
 	struct timer_list *timer;
 	unsigned long timeout;
 	struct sctp_transport *t;
@@ -1397,9 +1392,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			/* If we've sent any data bundled with
 			 * COOKIE-ECHO we need to resend.
 			 */
-			list_for_each(pos, &asoc->peer.transport_addr_list) {
-				t = list_entry(pos, struct sctp_transport,
-					       transports);
+			list_for_each_entry(t, &asoc->peer.transport_addr_list,
+					transports) {
 				sctp_retransmit_mark(&asoc->outqueue, t,
 					    SCTP_RTXR_T1_RTX);
 			}
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b534dbe..6222848 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1226,7 +1226,6 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_transport *new_addr, *addr;
-	struct list_head *pos, *pos2;
 	int found;
 
 	/* Implementor's Guide - Sectin 5.2.2
@@ -1243,12 +1242,11 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 	new_addr = NULL;
 	found = 0;
 
-	list_for_each(pos, &new_asoc->peer.transport_addr_list) {
-		new_addr = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
+			transports) {
 		found = 0;
-		list_for_each(pos2, &asoc->peer.transport_addr_list) {
-			addr = list_entry(pos2, struct sctp_transport,
-					  transports);
+		list_for_each_entry(addr, &asoc->peer.transport_addr_list,
+				transports) {
 			if (sctp_cmp_addr_exact(&new_addr->ipaddr,
 						&addr->ipaddr)) {
 				found = 1;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 025f467..8c90289 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -513,7 +513,6 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 	union sctp_addr			saveaddr;
 	void				*addr_buf;
 	struct sctp_af			*af;
-	struct list_head		*pos;
 	struct list_head		*p;
 	int 				i;
 	int 				retval = 0;
@@ -527,8 +526,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 	SCTP_DEBUG_PRINTK("%s: (sk: %p, addrs: %p, addrcnt: %d)\n",
 			  __func__, sk, addrs, addrcnt);
 
-	list_for_each(pos, &ep->asocs) {
-		asoc = list_entry(pos, struct sctp_association, asocs);
+	list_for_each_entry(asoc, &ep->asocs, asocs) {
 
 		if (!asoc->peer.asconf_capable)
 			continue;
@@ -699,7 +697,6 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 	union sctp_addr		*laddr;
 	void			*addr_buf;
 	struct sctp_af		*af;
-	struct list_head	*pos, *pos1;
 	struct sctp_sockaddr_entry *saddr;
 	int 			i;
 	int 			retval = 0;
@@ -713,8 +710,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 	SCTP_DEBUG_PRINTK("%s: (sk: %p, addrs: %p, addrcnt: %d)\n",
 			  __func__, sk, addrs, addrcnt);
 
-	list_for_each(pos, &ep->asocs) {
-		asoc = list_entry(pos, struct sctp_association, asocs);
+	list_for_each_entry(asoc, &ep->asocs, asocs) {
 
 		if (!asoc->peer.asconf_capable)
 			continue;
@@ -787,9 +783,8 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		 * as some of the addresses in the bind address list are
 		 * about to be deleted and cannot be used as source addresses.
 		 */
-		list_for_each(pos1, &asoc->peer.transport_addr_list) {
-			transport = list_entry(pos1, struct sctp_transport,
-					       transports);
+		list_for_each_entry(transport, &asoc->peer.transport_addr_list,
+					transports) {
 			dst_release(transport->dst);
 			sctp_transport_route(transport, NULL,
 					     sctp_sk(asoc->base.sk));
@@ -1397,7 +1392,6 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	long timeo;
 	__u16 sinfo_flags = 0;
 	struct sctp_datamsg *datamsg;
-	struct list_head *pos;
 	int msg_flags = msg->msg_flags;
 
 	SCTP_DEBUG_PRINTK("sctp_sendmsg(sk: %p, msg: %p, msg_len: %zu)\n",
@@ -1727,8 +1721,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	/* Now send the (possibly) fragmented message. */
-	list_for_each(pos, &datamsg->chunks) {
-		chunk = list_entry(pos, struct sctp_chunk, frag_list);
+	list_for_each_entry(chunk, &datamsg->chunks, frag_list) {
 		sctp_chunk_hold(chunk);
 
 		/* Do accounting for the write space.  */
@@ -2301,11 +2294,8 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	 * transport.
 	 */
 	if (!trans && asoc) {
-		struct list_head *pos;
-
-		list_for_each(pos, &asoc->peer.transport_addr_list) {
-			trans = list_entry(pos, struct sctp_transport,
-					   transports);
+		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
+				transports) {
 			sctp_apply_peer_addr_params(&params, trans, asoc, sp,
 						    hb_change, pmtud_change,
 						    sackdelay_change);
@@ -2396,11 +2386,8 @@ static int sctp_setsockopt_delayed_ack_time(struct sock *sk,
 
 	/* If change is for association, also apply to each transport. */
 	if (asoc) {
-		struct list_head *pos;
-
-		list_for_each(pos, &asoc->peer.transport_addr_list) {
-			trans = list_entry(pos, struct sctp_transport,
-					   transports);
+		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
+				transports) {
 			if (params.assoc_value) {
 				trans->sackdelay =
 					msecs_to_jiffies(params.assoc_value);
@@ -2632,13 +2619,10 @@ static int sctp_setsockopt_associnfo(struct sock *sk, char __user *optval, int o
 		if (assocparams.sasoc_asocmaxrxt != 0) {
 			__u32 path_sum = 0;
 			int   paths = 0;
-			struct list_head *pos;
 			struct sctp_transport *peer_addr;
 
-			list_for_each(pos, &asoc->peer.transport_addr_list) {
-				peer_addr = list_entry(pos,
-						struct sctp_transport,
-						transports);
+			list_for_each_entry(peer_addr, &asoc->peer.transport_addr_list,
+					transports) {
 				path_sum += peer_addr->pathmaxrxt;
 				paths++;
 			}
@@ -2716,7 +2700,6 @@ static int sctp_setsockopt_mappedv4(struct sock *sk, char __user *optval, int op
 static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, int optlen)
 {
 	struct sctp_association *asoc;
-	struct list_head *pos;
 	struct sctp_sock *sp = sctp_sk(sk);
 	int val;
 
@@ -2729,8 +2712,7 @@ static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, int optl
 	sp->user_frag = val;
 
 	/* Update the frag_point of the existing associations. */
-	list_for_each(pos, &(sp->ep->asocs)) {
-		asoc = list_entry(pos, struct sctp_association, asocs);
+	list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
 		asoc->frag_point = sctp_frag_point(sp, asoc->pathmtu);
 	}
 
@@ -4151,7 +4133,6 @@ static int sctp_getsockopt_peer_addrs_old(struct sock *sk, int len,
 					  int __user *optlen)
 {
 	struct sctp_association *asoc;
-	struct list_head *pos;
 	int cnt = 0;
 	struct sctp_getaddrs_old getaddrs;
 	struct sctp_transport *from;
@@ -4176,8 +4157,8 @@ static int sctp_getsockopt_peer_addrs_old(struct sock *sk, int len,
 		return -EINVAL;
 
 	to = (void __user *)getaddrs.addrs;
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		from = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(from, &asoc->peer.transport_addr_list,
+				transports) {
 		memcpy(&temp, &from->ipaddr, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(sk->sk_family)->sockaddr_len;
@@ -4200,7 +4181,6 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 				      char __user *optval, int __user *optlen)
 {
 	struct sctp_association *asoc;
-	struct list_head *pos;
 	int cnt = 0;
 	struct sctp_getaddrs getaddrs;
 	struct sctp_transport *from;
@@ -4225,8 +4205,8 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 	to = optval + offsetof(struct sctp_getaddrs,addrs);
 	space_left = len - offsetof(struct sctp_getaddrs,addrs);
 
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		from = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry(from, &asoc->peer.transport_addr_list,
+				transports) {
 		memcpy(&temp, &from->ipaddr, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(sk->sk_family)->sockaddr_len;
@@ -6193,11 +6173,9 @@ do_nonblock:
 void sctp_write_space(struct sock *sk)
 {
 	struct sctp_association *asoc;
-	struct list_head *pos;
 
 	/* Wake up the tasks in each wait queue.  */
-	list_for_each(pos, &((sctp_sk(sk))->ep->asocs)) {
-		asoc = list_entry(pos, struct sctp_association, asocs);
+	list_for_each_entry(asoc, &((sctp_sk(sk))->ep->asocs), asocs) {
 		__sctp_write_space(asoc);
 	}
 }
-- 
1.5.3.5

