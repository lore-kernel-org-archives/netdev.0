From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 SCTP updates
Date: Fri, 23 Jul 2004 17:18:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407231708440.4570@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work

to get the following SCTP updates to 2.6.8-rc2.

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/23 16:41:31-07:00 sri@us.ibm.com
#   [SCTP] Mark chunks as ineligible for fast retransmit after they are
#   retransmitted. Also mark any chunks that could not be fit in the
#   PMTU sized packet as ineligible for fast retransmit.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/outqueue.c
#
# ChangeSet
#   2004/07/22 23:22:01-07:00 sri@us.ibm.com
#   [SCTP] Fix missing '+' in the computation of sack chunk size in
#   sctp_sm_pull_sack().
#
#   Signed-off-by: Jorge Hernandez <jhh@lucent.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_statefuns.c
#
# ChangeSet
#   2004/07/22 23:18:24-07:00 sri@us.ibm.com
#   [SCTP] Use idr_get_new_above() with a starting id of 1 to avoid returning
#   an associd of 0.
#
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_make_chunk.c
#
# ChangeSet
#   2004/07/22 23:15:55-07:00 sri@us.ibm.com
#   [SCTP] Fix issues with handling stale cookie error over multihoming
#   associations.
#
#   Signed-off-by: Jorge Hernandez <jhh@lucent.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_statefuns.c
# net/sctp/sm_sideeffect.c
# include/net/sctp/command.h
#
# ChangeSet
#   2004/07/22 23:13:05-07:00 sri@us.ibm.com
#   [SCTP] Fix data not being delivered to user in SHUTDOWN_SENT state.
#
#   Also cleaned up sctp_sf_eat_data_6_2() and sctp_sf_eat_data_fast_4_4()
#   as they have a lot of common code.
#
#   Signed-off-by: Jorge Hernandez <jhh@lucent.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/sm_statefuns.c
# net/sctp/associola.c
# include/net/sctp/sm.h
# include/net/sctp/constants.h
#
# ChangeSet
#   2004/07/22 23:09:04-07:00 sri@us.ibm.com
#   [SCTP] Set/Get default SCTP_PEER_ADDR_PARAMS for endpoint when associd
#   and peer address are 0.
#
#   Signed-off-by: Anand R. Setlur <asetlur@lucent.com>
#   Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
#
# net/sctp/socket.c
#
diff -Nru a/include/net/sctp/command.h b/include/net/sctp/command.h
--- a/include/net/sctp/command.h	2004-07-23 17:08:07 -07:00
+++ b/include/net/sctp/command.h	2004-07-23 17:08:07 -07:00
@@ -94,6 +94,9 @@
 	SCTP_CMD_REPORT_FWDTSN,	 /* Report new cumulative TSN Ack. */
 	SCTP_CMD_PROCESS_FWDTSN, /* Skips were reported, so process further. */
 	SCTP_CMD_CLEAR_INIT_TAG, /* Clears association peer's inittag. */
+	SCTP_CMD_DEL_NON_PRIMARY, /* Removes non-primary peer transports. */
+	SCTP_CMD_T3_RTX_TIMERS_STOP, /* Stops T3-rtx pending timers */
+	SCTP_CMD_FORCE_PRIM_RETRAN,  /* Forces retrans. over primary path. */
 	SCTP_CMD_LAST
 } sctp_verb_t;

diff -Nru a/include/net/sctp/constants.h b/include/net/sctp/constants.h
--- a/include/net/sctp/constants.h	2004-07-23 17:08:07 -07:00
+++ b/include/net/sctp/constants.h	2004-07-23 17:08:07 -07:00
@@ -175,6 +175,10 @@
 	SCTP_IERROR_BAD_TAG,
 	SCTP_IERROR_BIG_GAP,
 	SCTP_IERROR_DUP_TSN,
+	SCTP_IERROR_HIGH_TSN,
+	SCTP_IERROR_IGNORE_TSN,
+	SCTP_IERROR_NO_DATA,
+	SCTP_IERROR_BAD_STREAM,

 } sctp_ierror_t;

diff -Nru a/include/net/sctp/sm.h b/include/net/sctp/sm.h
--- a/include/net/sctp/sm.h	2004-07-23 17:08:07 -07:00
+++ b/include/net/sctp/sm.h	2004-07-23 17:08:07 -07:00
@@ -322,6 +322,9 @@
 				const struct sctp_chunk *chunk,
 				sctp_cmd_seq_t *commands,
 				struct sctp_chunk *err_chunk);
+int sctp_eat_data(const struct sctp_association *asoc,
+		  struct sctp_chunk *chunk,
+		  sctp_cmd_seq_t *commands);

 /* 3rd level prototypes */
 __u32 sctp_generate_tag(const struct sctp_endpoint *);
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/associola.c	2004-07-23 17:08:07 -07:00
@@ -1093,6 +1093,7 @@
 	case SCTP_STATE_ESTABLISHED:
 	case SCTP_STATE_SHUTDOWN_PENDING:
 	case SCTP_STATE_SHUTDOWN_RECEIVED:
+	case SCTP_STATE_SHUTDOWN_SENT:
 		if ((asoc->rwnd > asoc->a_rwnd) &&
 		    ((asoc->rwnd - asoc->a_rwnd) >=
 		     min_t(__u32, (asoc->base.sk->sk_rcvbuf >> 1), asoc->pmtu)))
diff -Nru a/net/sctp/outqueue.c b/net/sctp/outqueue.c
--- a/net/sctp/outqueue.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/outqueue.c	2004-07-23 17:08:07 -07:00
@@ -525,10 +525,10 @@
 			       int rtx_timeout, int *start_timer)
 {
 	struct list_head *lqueue;
-	struct list_head *lchunk;
+	struct list_head *lchunk, *lchunk1;
 	struct sctp_transport *transport = pkt->transport;
 	sctp_xmit_t status;
-	struct sctp_chunk *chunk;
+	struct sctp_chunk *chunk, *chunk1;
 	struct sctp_association *asoc;
 	int error = 0;

@@ -615,6 +615,12 @@
 			 * the transmitted list.
 			 */
 			list_add_tail(lchunk, &transport->transmitted);
+
+			/* Mark the chunk as ineligible for fast retransmit
+			 * after it is retransmitted.
+			 */
+			chunk->fast_retransmit = 0;
+
 			*start_timer = 1;
 			q->empty = 0;

@@ -622,6 +628,18 @@
 			lchunk = sctp_list_dequeue(lqueue);
 			break;
 		};
+
+		/* If we are here due to a retransmit timeout or a fast
+		 * retransmit and if there are any chunks left in the retransmit
+		 * queue that could not fit in the PMTU sized packet, they need			 * to be marked as ineligible for a subsequent fast retransmit.
+		 */
+		if (rtx_timeout && !lchunk) {
+			list_for_each(lchunk1, lqueue) {
+				chunk1 = list_entry(lchunk1, struct sctp_chunk,
+						    transmitted_list);
+				chunk1->fast_retransmit = 0;
+			}
+		}
 	}

 	return error;
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/sm_make_chunk.c	2004-07-23 17:08:07 -07:00
@@ -1846,9 +1846,8 @@
 		if (unlikely(!idr_pre_get(&sctp_assocs_id, gfp)))
 			goto clean_up;
 		spin_lock_bh(&sctp_assocs_id_lock);
-		error = idr_get_new(&sctp_assocs_id,
-				    (void *)asoc,
-				    &assoc_id);
+		error = idr_get_new_above(&sctp_assocs_id, (void *)asoc, 1,
+					  &assoc_id);
 		spin_unlock_bh(&sctp_assocs_id_lock);
 		if (error == -EAGAIN)
 			goto retry;
diff -Nru a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
--- a/net/sctp/sm_sideeffect.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/sm_sideeffect.c	2004-07-23 17:08:07 -07:00
@@ -529,6 +529,23 @@
 	}
 }

+/* Helper function to stop any pending T3-RTX timers */
+static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
+				        struct sctp_association *asoc)
+{
+	struct sctp_transport *t;
+	struct list_head *pos;
+
+	list_for_each(pos, &asoc->peer.transport_addr_list) {
+		t = list_entry(pos, struct sctp_transport, transports);
+		if (timer_pending(&t->T3_rtx_timer) &&
+		    del_timer(&t->T3_rtx_timer)) {
+			sctp_transport_put(t);
+		}
+	}
+}
+
+
 /* Helper function to update the heartbeat timer. */
 static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
 				     struct sctp_association *asoc,
@@ -749,6 +766,26 @@
 	return;
 }

+/* Helper function to remove the association non-primary peer
+ * transports.
+ */
+static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
+{
+	struct sctp_transport *t;
+	struct list_head *pos;
+	struct list_head *temp;
+
+	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
+		t = list_entry(pos, struct sctp_transport, transports);
+		if (!sctp_cmp_addr_exact(&t->ipaddr,
+		                         &asoc->peer.primary_addr)) {
+			sctp_assoc_del_peer(asoc, &t->ipaddr);
+		}
+	}
+
+	return;
+}
+
 /* These three macros allow us to pull the debugging code out of the
  * main flow of sctp_do_sm() to keep attention focused on the real
  * functionality there.
@@ -1048,6 +1085,27 @@
 			if (cmd->obj.ptr)
 				sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
 						SCTP_CHUNK(cmd->obj.ptr));
+
+			/* FIXME - Eventually come up with a cleaner way to
+			 * enabling COOKIE-ECHO + DATA bundling during
+			 * multihoming stale cookie scenarios, the following
+			 * command plays with asoc->peer.retran_path to
+			 * avoid the problem of sending the COOKIE-ECHO and
+			 * DATA in different paths, which could result
+			 * in the association being ABORTed if the DATA chunk
+			 * is processed first by the server.  Checking the
+			 * init error counter simply causes this command
+			 * to be executed only during failed attempts of
+			 * association establishment.
+			 */
+			if ((asoc->peer.retran_path !=
+			     asoc->peer.primary_path) &&
+			    (asoc->counters[SCTP_COUNTER_INIT_ERROR] > 0)) {
+				sctp_add_cmd_sf(commands,
+				                SCTP_CMD_FORCE_PRIM_RETRAN,
+						SCTP_NULL());
+			}
+
 			break;

 		case SCTP_CMD_GEN_SHUTDOWN:
@@ -1281,6 +1339,19 @@
 			break;
 		case SCTP_CMD_CLEAR_INIT_TAG:
 			asoc->peer.i.init_tag = 0;
+			break;
+		case SCTP_CMD_DEL_NON_PRIMARY:
+			sctp_cmd_del_non_primary(asoc);
+			break;
+		case SCTP_CMD_T3_RTX_TIMERS_STOP:
+			sctp_cmd_t3_rtx_timers_stop(commands, asoc);
+			break;
+		case SCTP_CMD_FORCE_PRIM_RETRAN:
+			t = asoc->peer.retran_path;
+			asoc->peer.retran_path = asoc->peer.primary_path;
+			error = sctp_outq_uncork(&asoc->outqueue);
+			local_cork = 0;
+			asoc->peer.retran_path = t;
 			break;
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/sm_statefuns.c	2004-07-23 17:08:07 -07:00
@@ -472,8 +472,6 @@
 	 */
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_INIT));
-	sctp_add_cmd_sf(commands, SCTP_CMD_COUNTER_RESET,
-			SCTP_COUNTER(SCTP_COUNTER_INIT_ERROR));
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_COOKIE));
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
@@ -674,6 +672,15 @@
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

+	/* Reset init error count upon receipt of COOKIE-ACK,
+	 * to avoid problems with the managemement of this
+	 * counter in stale cookie situations when a transition back
+	 * from the COOKIE-ECHOED state to the COOKIE-WAIT
+	 * state is performed.
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_COUNTER_RESET,
+	                SCTP_COUNTER(SCTP_COUNTER_INIT_ERROR));
+
 	/* RFC 2960 5.1 Normal Establishment of an Association
 	 *
 	 * E) Upon reception of the COOKIE ACK, endpoint "A" will move
@@ -1872,8 +1879,6 @@
 	time_t stale;
 	sctp_cookie_preserve_param_t bht;
 	sctp_errhdr_t *err;
-	struct list_head *pos;
-	struct sctp_transport *t;
 	struct sctp_chunk *reply;
 	struct sctp_bind_addr *bp;
 	int attempts;
@@ -1920,20 +1925,27 @@
 	/* Clear peer's init_tag cached in assoc as we are sending a new INIT */
 	sctp_add_cmd_sf(commands, SCTP_CMD_CLEAR_INIT_TAG, SCTP_NULL());

+	/* Stop pending T3-rtx and heartbeat timers */
+	sctp_add_cmd_sf(commands, SCTP_CMD_T3_RTX_TIMERS_STOP, SCTP_NULL());
+	sctp_add_cmd_sf(commands, SCTP_CMD_HB_TIMERS_STOP, SCTP_NULL());
+
+	/* Delete non-primary peer ip addresses since we are transitioning
+	 * back to the COOKIE-WAIT state
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_DEL_NON_PRIMARY, SCTP_NULL());
+
+	/* If we've sent any data bundled with COOKIE-ECHO we will need to
+	 * resend
+	 */
+	sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN,
+			SCTP_TRANSPORT(asoc->peer.primary_path));
+
 	/* Cast away the const modifier, as we want to just
 	 * rerun it through as a sideffect.
 	 */
 	sctp_add_cmd_sf(commands, SCTP_CMD_COUNTER_INC,
 			SCTP_COUNTER(SCTP_COUNTER_INIT_ERROR));

-	/* If we've sent any data bundled with COOKIE-ECHO we need to
-	 * resend.
-	 */
-	list_for_each(pos, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
-		sctp_add_cmd_sf(commands, SCTP_CMD_RETRAN, SCTP_TRANSPORT(t));
-	}
-
 	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 			SCTP_TO(SCTP_EVENT_TIMEOUT_T1_COOKIE));
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
@@ -2321,12 +2333,7 @@
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_datahdr_t *data_hdr;
-	struct sctp_chunk *err;
-	size_t datalen;
-	sctp_verb_t deliver;
-	int tmp;
-	__u32 tsn;
+	int error;

 	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
@@ -2334,158 +2341,22 @@
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
         }

-	data_hdr = chunk->subh.data_hdr = (sctp_datahdr_t *)chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_datahdr_t));
-
-	tsn = ntohl(data_hdr->tsn);
-	SCTP_DEBUG_PRINTK("eat_data: TSN 0x%x.\n", tsn);
-
-	/* ASSERT:  Now skb->data is really the user data.  */
-
-	/* Process ECN based congestion.
-	 *
-	 * Since the chunk structure is reused for all chunks within
-	 * a packet, we use ecn_ce_done to track if we've already
-	 * done CE processing for this packet.
-	 *
-	 * We need to do ECN processing even if we plan to discard the
-	 * chunk later.
-	 */
-
-	if (!chunk->ecn_ce_done) {
-		struct sctp_af *af;
-		chunk->ecn_ce_done = 1;
-
-		af = sctp_get_af_specific(
-			ipver2af(chunk->skb->nh.iph->version));
-
-		if (af && af->is_ce(chunk->skb) && asoc->peer.ecn_capable) {
-			/* Do real work as sideffect. */
-			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
-					SCTP_U32(tsn));
-		}
-	}
-
-	tmp = sctp_tsnmap_check(&asoc->peer.tsn_map, tsn);
-	if (tmp < 0) {
-		/* The TSN is too high--silently discard the chunk and
-		 * count on it getting retransmitted later.
-		 */
+	error = sctp_eat_data(asoc, chunk, commands );
+	switch (error) {
+	case SCTP_IERROR_NO_ERROR:
+		break;
+	case SCTP_IERROR_HIGH_TSN:
+	case SCTP_IERROR_BAD_STREAM:
 		goto discard_noforce;
-	} else if (tmp > 0) {
-		/* This is a duplicate.  Record it.  */
-		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_DUP, SCTP_U32(tsn));
+	case SCTP_IERROR_DUP_TSN:
+	case SCTP_IERROR_IGNORE_TSN:
 		goto discard_force;
+	case SCTP_IERROR_NO_DATA:
+		goto consume;
+	default:
+		BUG();
 	}

-	/* This is a new TSN.  */
-
-	/* Discard if there is no room in the receive window.
-	 * Actually, allow a little bit of overflow (up to a MTU).
-	 */
-	datalen = ntohs(chunk->chunk_hdr->length);
-	datalen -= sizeof(sctp_data_chunk_t);
-
-	deliver = SCTP_CMD_CHUNK_ULP;
-
-	/* Think about partial delivery. */
-	if ((datalen >= asoc->rwnd) && (!asoc->ulpq.pd_mode)) {
-
-		/* Even if we don't accept this chunk there is
-		 * memory pressure.
-		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_PART_DELIVER, SCTP_NULL());
-	}
-
-        /* Spill over rwnd a little bit.  Note: While allowed, this spill over
-	 * seems a bit troublesome in that frag_point varies based on
-	 * PMTU.  In cases, such as loopback, this might be a rather
-	 * large spill over.
-	 */
-	if (!asoc->rwnd || asoc->rwnd_over ||
-	    (datalen > asoc->rwnd + asoc->frag_point)) {
-
-		/* If this is the next TSN, consider reneging to make
-		 * room.   Note: Playing nice with a confused sender.  A
-		 * malicious sender can still eat up all our buffer
-		 * space and in the future we may want to detect and
-		 * do more drastic reneging.
-		 */
-		if (sctp_tsnmap_has_gap(&asoc->peer.tsn_map) &&
-		    (sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + 1) == tsn) {
-			SCTP_DEBUG_PRINTK("Reneging for tsn:%u\n", tsn);
-			deliver = SCTP_CMD_RENEGE;
-		} else {
-			SCTP_DEBUG_PRINTK("Discard tsn: %u len: %Zd, "
-					  "rwnd: %d\n", tsn, datalen,
-					  asoc->rwnd);
-			goto discard_force;
-		}
-	}
-
-	/*
-	 * Section 3.3.10.9 No User Data (9)
-	 *
-	 * Cause of error
-	 * ---------------
-	 * No User Data:  This error cause is returned to the originator of a
-	 * DATA chunk if a received DATA chunk has no user data.
-	 */
-	if (unlikely(0 == datalen)) {
-		err = sctp_make_abort_no_data(asoc, chunk, tsn);
-		if (err) {
-			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-					SCTP_CHUNK(err));
-		}
-		/* We are going to ABORT, so we might as well stop
-		 * processing the rest of the chunks in the packet.
-		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
-		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
-				SCTP_U32(SCTP_ERROR_NO_DATA));
-		SCTP_INC_STATS(SctpAborteds);
-		SCTP_DEC_STATS(SctpCurrEstab);
-		return SCTP_DISPOSITION_CONSUME;
-	}
-
-	/* If definately accepting the DATA chunk, record its TSN, otherwise
-	 * wait for renege processing.
-	 */
-	if (SCTP_CMD_CHUNK_ULP == deliver)
-		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
-
-	/* Note: Some chunks may get overcounted (if we drop) or overcounted
-	 * if we renege and the chunk arrives again.
-	 */
-	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
-		SCTP_INC_STATS(SctpInUnorderChunks);
-	else
-		SCTP_INC_STATS(SctpInOrderChunks);
-
-	/* RFC 2960 6.5 Stream Identifier and Stream Sequence Number
-	 *
-	 * If an endpoint receive a DATA chunk with an invalid stream
-	 * identifier, it shall acknowledge the reception of the DATA chunk
-	 * following the normal procedure, immediately send an ERROR chunk
-	 * with cause set to "Invalid Stream Identifier" (See Section 3.3.10)
-	 * and discard the DATA chunk.
-	 */
-	if (ntohs(data_hdr->stream) >= asoc->c.sinit_max_instreams) {
-		err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
-					 &data_hdr->stream,
-					 sizeof(data_hdr->stream));
-		if (err)
-			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-					SCTP_CHUNK(err));
-		goto discard_noforce;
-	}
-
-	/* Send the data up to the user.  Note:  Schedule  the
-	 * SCTP_CMD_CHUNK_ULP cmd before the SCTP_CMD_GEN_SACK, as the SACK
-	 * chunk needs the updated rwnd.
-	 */
-	sctp_add_cmd_sf(commands, deliver, SCTP_CHUNK(chunk));
-
 	if (asoc->autoclose) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
@@ -2551,6 +2422,9 @@
 				SCTP_TO(SCTP_EVENT_TIMEOUT_SACK));
 	}
 	return SCTP_DISPOSITION_DISCARD;
+consume:
+	return SCTP_DISPOSITION_CONSUME;
+
 }

 /*
@@ -2576,11 +2450,7 @@
 				     sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_datahdr_t *data_hdr;
-	struct sctp_chunk *err;
-	size_t datalen;
-	int tmp;
-	__u32 tsn;
+	int error;

 	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
@@ -2588,110 +2458,23 @@
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
 	}

-	data_hdr = chunk->subh.data_hdr = (sctp_datahdr_t *) chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_datahdr_t));
-
-	tsn = ntohl(data_hdr->tsn);
-
-	SCTP_DEBUG_PRINTK("eat_data: TSN 0x%x.\n", tsn);
-
-	/* ASSERT:  Now skb->data is really the user data.  */
-
-	/* Process ECN based congestion.
-	 *
-	 * Since the chunk structure is reused for all chunks within
-	 * a packet, we use ecn_ce_done to track if we've already
-	 * done CE processing for this packet.
-	 *
-	 * We need to do ECN processing even if we plan to discard the
-	 * chunk later.
-	 */
-	if (!chunk->ecn_ce_done) {
-		struct sctp_af *af;
-		chunk->ecn_ce_done = 1;
-
-		af = sctp_get_af_specific(
-			ipver2af(chunk->skb->nh.iph->version));
-
-		if (af && af->is_ce(chunk->skb) && asoc->peer.ecn_capable) {
-			/* Do real work as sideffect. */
-			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
-					SCTP_U32(tsn));
-		}
-	}
-
-	tmp = sctp_tsnmap_check(&asoc->peer.tsn_map, tsn);
-	if (tmp < 0) {
-		/* The TSN is too high--silently discard the chunk and
-		 * count on it getting retransmitted later.
-		 */
-		goto gen_shutdown;
-	} else if (tmp > 0) {
-		/* This is a duplicate.  Record it.  */
-		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_DUP, SCTP_U32(tsn));
-		goto gen_shutdown;
-	}
-
-	/* This is a new TSN.  */

-	datalen = ntohs(chunk->chunk_hdr->length);
-	datalen -= sizeof(sctp_data_chunk_t);
-
-	/*
-	 * Section 3.3.10.9 No User Data (9)
-	 *
-	 * Cause of error
-	 * ---------------
-	 * No User Data:  This error cause is returned to the originator of a
-	 * DATA chunk if a received DATA chunk has no user data.
-	 */
-	if (unlikely(0 == datalen)) {
-		err = sctp_make_abort_no_data(asoc, chunk, tsn);
-		if (err) {
-			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-					SCTP_CHUNK(err));
-		}
-		/* We are going to ABORT, so we might as well stop
-		 * processing the rest of the chunks in the packet.
-		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
-		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
-				SCTP_U32(SCTP_ERROR_NO_DATA));
-		SCTP_INC_STATS(SctpAborteds);
-		SCTP_DEC_STATS(SctpCurrEstab);
-		return SCTP_DISPOSITION_CONSUME;
-	}
-
-	/* We are accepting this DATA chunk. */
-
-	/* Record the fact that we have received this TSN.  */
-	sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
-
-	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
-		SCTP_INC_STATS(SctpInUnorderChunks);
-	else
-		SCTP_INC_STATS(SctpInOrderChunks);
-
-	/* RFC 2960 6.5 Stream Identifier and Stream Sequence Number
-	 *
-	 * If an endpoint receive a DATA chunk with an invalid stream
-	 * identifier, it shall acknowledge the reception of the DATA chunk
-	 * following the normal procedure, immediately send an ERROR chunk
-	 * with cause set to "Invalid Stream Identifier" (See Section 3.3.10)
-	 * and discard the DATA chunk.
-	 */
-	if (ntohs(data_hdr->stream) >= asoc->c.sinit_max_instreams) {
-		err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
-					 &data_hdr->stream,
-					 sizeof(data_hdr->stream));
-		if (err) {
-			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-					SCTP_CHUNK(err));
-		}
+	error = sctp_eat_data(asoc, chunk, commands );
+	switch (error) {
+	case SCTP_IERROR_NO_ERROR:
+	case SCTP_IERROR_HIGH_TSN:
+	case SCTP_IERROR_DUP_TSN:
+	case SCTP_IERROR_IGNORE_TSN:
+	case SCTP_IERROR_BAD_STREAM:
+		break;
+	case SCTP_IERROR_NO_DATA:
+		goto consume;
+	default:
+		BUG();
 	}

 	/* Go a head and force a SACK, since we are shutting down. */
-gen_shutdown:
+
 	/* Implementor's Guide.
 	 *
 	 * While in SHUTDOWN-SENT state, the SHUTDOWN sender MUST immediately
@@ -2707,6 +2490,8 @@
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_T2_SHUTDOWN));
 	}
+
+consume:
 	return SCTP_DISPOSITION_CONSUME;
 }

@@ -4709,7 +4494,7 @@
 	num_blocks = ntohs(sack->num_gap_ack_blocks);
 	num_dup_tsns = ntohs(sack->num_dup_tsns);
 	len = sizeof(struct sctp_sackhdr);
-	len = (num_blocks + num_dup_tsns) * sizeof(__u32);
+	len += (num_blocks + num_dup_tsns) * sizeof(__u32);
 	if (len > chunk->skb->len)
 		return NULL;

@@ -4847,4 +4632,172 @@
 		} else
 			sctp_chunk_free (err_chunk);
 	}
+}
+
+
+/* Process a data chunk */
+int sctp_eat_data(const struct sctp_association *asoc,
+		  struct sctp_chunk *chunk,
+		  sctp_cmd_seq_t *commands)
+{
+	sctp_datahdr_t *data_hdr;
+	struct sctp_chunk *err;
+	size_t datalen;
+	sctp_verb_t deliver;
+	int tmp;
+	__u32 tsn;
+
+	data_hdr = chunk->subh.data_hdr = (sctp_datahdr_t *)chunk->skb->data;
+	skb_pull(chunk->skb, sizeof(sctp_datahdr_t));
+
+	tsn = ntohl(data_hdr->tsn);
+	SCTP_DEBUG_PRINTK("eat_data: TSN 0x%x.\n", tsn);
+
+	/* ASSERT:  Now skb->data is really the user data.  */
+
+	/* Process ECN based congestion.
+	 *
+	 * Since the chunk structure is reused for all chunks within
+	 * a packet, we use ecn_ce_done to track if we've already
+	 * done CE processing for this packet.
+	 *
+	 * We need to do ECN processing even if we plan to discard the
+	 * chunk later.
+	 */
+
+	if (!chunk->ecn_ce_done) {
+		struct sctp_af *af;
+		chunk->ecn_ce_done = 1;
+
+		af = sctp_get_af_specific(
+			ipver2af(chunk->skb->nh.iph->version));
+
+		if (af && af->is_ce(chunk->skb) && asoc->peer.ecn_capable) {
+			/* Do real work as sideffect. */
+			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
+					SCTP_U32(tsn));
+		}
+	}
+
+	tmp = sctp_tsnmap_check(&asoc->peer.tsn_map, tsn);
+	if (tmp < 0) {
+		/* The TSN is too high--silently discard the chunk and
+		 * count on it getting retransmitted later.
+		 */
+		return SCTP_IERROR_HIGH_TSN;
+	} else if (tmp > 0) {
+		/* This is a duplicate.  Record it.  */
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_DUP, SCTP_U32(tsn));
+		return SCTP_IERROR_DUP_TSN;
+	}
+
+	/* This is a new TSN.  */
+
+	/* Discard if there is no room in the receive window.
+	 * Actually, allow a little bit of overflow (up to a MTU).
+	 */
+	datalen = ntohs(chunk->chunk_hdr->length);
+	datalen -= sizeof(sctp_data_chunk_t);
+
+	deliver = SCTP_CMD_CHUNK_ULP;
+
+	/* Think about partial delivery. */
+	if ((datalen >= asoc->rwnd) && (!asoc->ulpq.pd_mode)) {
+
+		/* Even if we don't accept this chunk there is
+		 * memory pressure.
+		 */
+		sctp_add_cmd_sf(commands, SCTP_CMD_PART_DELIVER, SCTP_NULL());
+	}
+
+        /* Spill over rwnd a little bit.  Note: While allowed, this spill over
+	 * seems a bit troublesome in that frag_point varies based on
+	 * PMTU.  In cases, such as loopback, this might be a rather
+	 * large spill over.
+	 */
+	if (!asoc->rwnd || asoc->rwnd_over ||
+	    (datalen > asoc->rwnd + asoc->frag_point)) {
+
+		/* If this is the next TSN, consider reneging to make
+		 * room.   Note: Playing nice with a confused sender.  A
+		 * malicious sender can still eat up all our buffer
+		 * space and in the future we may want to detect and
+		 * do more drastic reneging.
+		 */
+		if (sctp_tsnmap_has_gap(&asoc->peer.tsn_map) &&
+		    (sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + 1) == tsn) {
+			SCTP_DEBUG_PRINTK("Reneging for tsn:%u\n", tsn);
+			deliver = SCTP_CMD_RENEGE;
+		} else {
+			SCTP_DEBUG_PRINTK("Discard tsn: %u len: %Zd, "
+					  "rwnd: %d\n", tsn, datalen,
+					  asoc->rwnd);
+			return SCTP_IERROR_IGNORE_TSN;
+		}
+	}
+
+	/*
+	 * Section 3.3.10.9 No User Data (9)
+	 *
+	 * Cause of error
+	 * ---------------
+	 * No User Data:  This error cause is returned to the originator of a
+	 * DATA chunk if a received DATA chunk has no user data.
+	 */
+	if (unlikely(0 == datalen)) {
+		err = sctp_make_abort_no_data(asoc, chunk, tsn);
+		if (err) {
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(err));
+		}
+		/* We are going to ABORT, so we might as well stop
+		 * processing the rest of the chunks in the packet.
+		 */
+		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
+		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
+				SCTP_U32(SCTP_ERROR_NO_DATA));
+		SCTP_INC_STATS(SctpAborteds);
+		SCTP_DEC_STATS(SctpCurrEstab);
+		return SCTP_IERROR_NO_DATA;
+	}
+
+	/* If definately accepting the DATA chunk, record its TSN, otherwise
+	 * wait for renege processing.
+	 */
+	if (SCTP_CMD_CHUNK_ULP == deliver)
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
+
+	/* Note: Some chunks may get overcounted (if we drop) or overcounted
+	 * if we renege and the chunk arrives again.
+	 */
+	if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
+		SCTP_INC_STATS(SctpInUnorderChunks);
+	else
+		SCTP_INC_STATS(SctpInOrderChunks);
+
+	/* RFC 2960 6.5 Stream Identifier and Stream Sequence Number
+	 *
+	 * If an endpoint receive a DATA chunk with an invalid stream
+	 * identifier, it shall acknowledge the reception of the DATA chunk
+	 * following the normal procedure, immediately send an ERROR chunk
+	 * with cause set to "Invalid Stream Identifier" (See Section 3.3.10)
+	 * and discard the DATA chunk.
+	 */
+	if (ntohs(data_hdr->stream) >= asoc->c.sinit_max_instreams) {
+		err = sctp_make_op_error(asoc, chunk, SCTP_ERROR_INV_STRM,
+					 &data_hdr->stream,
+					 sizeof(data_hdr->stream));
+		if (err)
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(err));
+		return SCTP_IERROR_BAD_STREAM;
+	}
+
+	/* Send the data up to the user.  Note:  Schedule  the
+	 * SCTP_CMD_CHUNK_ULP cmd before the SCTP_CMD_GEN_SACK, as the SACK
+	 * chunk needs the updated rwnd.
+	 */
+	sctp_add_cmd_sf(commands, deliver, SCTP_CHUNK(chunk));
+
+	return SCTP_IERROR_NO_ERROR;
 }
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2004-07-23 17:08:07 -07:00
+++ b/net/sctp/socket.c	2004-07-23 17:08:07 -07:00
@@ -1697,6 +1697,32 @@
 	if (copy_from_user(&params, optval, optlen))
 		return -EFAULT;

+	/*
+	 * API 7. Socket Options (setting the default value for the endpoint)
+	 * All options that support specific settings on an association by
+	 * filling in either an association id variable or a sockaddr_storage
+	 * SHOULD also support setting of the same value for the entire endpoint
+	 * (i.e. future associations). To accomplish this the following logic is
+	 * used when setting one of these options:
+
+	 * c) If neither the sockaddr_storage or association identification is
+	 *    set i.e. the sockaddr_storage is set to all 0's (INADDR_ANY) and
+	 *    the association identification is 0, the settings are a default
+	 *    and to be applied to the endpoint (all future associations).
+	 */
+
+	/* update default value for endpoint (all future associations) */
+	if (!params.spp_assoc_id &&
+	    sctp_is_any(( union sctp_addr *)&params.spp_address)) {
+		if (params.spp_hbinterval)
+			sctp_sk(sk)->paddrparam.spp_hbinterval =
+						params.spp_hbinterval;
+		if (sctp_max_retrans_path)
+			sctp_sk(sk)->paddrparam.spp_pathmaxrxt =
+						params.spp_pathmaxrxt;
+		return 0;
+	}
+
 	trans = sctp_addr_id2transport(sk, &params.spp_address,
 				       params.spp_assoc_id);
 	if (!trans)
@@ -2864,6 +2890,17 @@
 	if (copy_from_user(&params, optval, len))
 		return -EFAULT;

+	/* If no association id is specified retrieve the default value
+	 * for the endpoint that will be used for all future associations
+	 */
+	if (!params.spp_assoc_id &&
+	    sctp_is_any(( union sctp_addr *)&params.spp_address)) {
+		params.spp_hbinterval = sctp_sk(sk)->paddrparam.spp_hbinterval;
+		params.spp_pathmaxrxt = sctp_sk(sk)->paddrparam.spp_pathmaxrxt;
+
+		goto done;
+	}
+
 	trans = sctp_addr_id2transport(sk, &params.spp_address,
 				       params.spp_assoc_id);
 	if (!trans)
@@ -2883,6 +2920,7 @@
 	 */
 	params.spp_pathmaxrxt = trans->error_threshold;

+done:
 	if (copy_to_user(optval, &params, len))
 		return -EFAULT;
