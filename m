From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.6 and 2.4 SCTP updates.
Date: Fri, 4 Jun 2004 11:44:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406041104520.2786@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Please do a
        bk pull http://linux-lksctp.bkbits.net/lksctp-2.5.work &
        bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
to get the following bugfix csets to 2.6 and 2.4 SCTP.

Thanks
Sridhar

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/03 17:46:29-07:00 sri@us.ibm.com
#   [SCTP] Fix poll() on a 1-1 style socket so that it returns when the
#   association is aborted by peer.
#
# net/sctp/sm_sideeffect.c
#
# ChangeSet
#   2004/06/03 17:40:49-07:00 sri@us.ibm.com
#   [SCTP] Fix to wakeup blocking connect() after max INIT retries failed.
#
# net/sctp/socket.c
# net/sctp/sm_sideeffect.c
#
# ChangeSet
#   2004/06/03 17:33:41-07:00 sri@us.ibm.com
#   [SCTP] Fix missing VTAG validation on certain incoming packets.
#
# net/sctp/sm_statefuns.c
# include/net/sctp/sm.h
#
# ChangeSet
#   2004/06/03 17:26:13-07:00 sri@us.ibm.com
#   [SCTP] Fix the use of cached non-zero vtag in an INIT that is resent
#   after a stale cookie error.
#
# net/sctp/sm_statefuns.c
# net/sctp/sm_sideeffect.c
# include/net/sctp/command.h
#
# ChangeSet
#   2004/06/03 17:19:57-07:00 jhh@lucent.com
#   [SCTP] Fix to not start a new association on a 1-many style sendmsg()
#   with MSG_EOF/MSG_ABORT flag and no data.
#
# net/sctp/socket.c
#
# ChangeSet
#   2004/06/03 17:16:07-07:00 jhh@lucent.com
#   [SCTP] Fix to not setup a new association if the endpoint is in
#   SHUTDOWN_ACK_SENT state and recognizes that the peer has restarted.
#
# net/sctp/sm_statefuns.c
#
diff -Nru a/include/net/sctp/command.h b/include/net/sctp/command.h
--- a/include/net/sctp/command.h	Fri Jun  4 11:08:18 2004
+++ b/include/net/sctp/command.h	Fri Jun  4 11:08:18 2004
@@ -93,6 +93,7 @@
 	SCTP_CMD_PROCESS_OPERR,  /* Process an ERROR chunk. */
 	SCTP_CMD_REPORT_FWDTSN,	 /* Report new cumulative TSN Ack. */
 	SCTP_CMD_PROCESS_FWDTSN, /* Skips were reported, so process further. */
+	SCTP_CMD_CLEAR_INIT_TAG, /* Clears association peer's inittag. */
 	SCTP_CMD_LAST
 } sctp_verb_t;

diff -Nru a/include/net/sctp/sm.h b/include/net/sctp/sm.h
--- a/include/net/sctp/sm.h	Fri Jun  4 11:08:18 2004
+++ b/include/net/sctp/sm.h	Fri Jun  4 11:08:18 2004
@@ -440,6 +440,23 @@
 		BUG();
 }

+/* Check VTAG of the packet matches the sender's own tag. */
+static inline int
+sctp_vtag_verify(const struct sctp_chunk *chunk,
+		 const struct sctp_association *asoc)
+{
+	/* RFC 2960 Sec 8.5 When receiving an SCTP packet, the endpoint
+	 * MUST ensure that the value in the Verification Tag field of
+	 * the received SCTP packet matches its own Tag. If the received
+	 * Verification Tag value does not match the receiver's own
+	 * tag value, the receiver shall silently discard the packet...
+	 */
+        if (ntohl(chunk->sctp_hdr->vtag) == asoc->c.my_vtag)
+                return 1;
+
+	return 0;
+}
+
 /* Check VTAG of the packet matches the sender's own tag OR its peer's
  * tag and the T bit is set in the Chunk Flags.
  */
diff -Nru a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
--- a/net/sctp/sm_sideeffect.c	Fri Jun  4 11:08:18 2004
+++ b/net/sctp/sm_sideeffect.c	Fri Jun  4 11:08:18 2004
@@ -429,6 +429,9 @@
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
 				SCTP_ULPEVENT(event));

+	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
+			SCTP_STATE(SCTP_STATE_CLOSED));
+
 	/* SEND_FAILED sent later when cleaning up the association. */
 	asoc->outqueue.error = error;
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
@@ -457,6 +460,10 @@
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
 			SCTP_STATE(SCTP_STATE_CLOSED));

+	/* Set sk_err to ECONNRESET on a 1-1 style socket. */
+	if (!sctp_style(asoc->base.sk, UDP))
+		asoc->base.sk->sk_err = ECONNRESET;
+
 	/* SEND_FAILED sent later when cleaning up the association. */
 	asoc->outqueue.error = error;
 	sctp_add_cmd_sf(commands, SCTP_CMD_DELETE_TCB, SCTP_NULL());
@@ -1271,6 +1278,9 @@

 		case SCTP_CMD_PROCESS_OPERR:
 			sctp_cmd_process_operr(commands, asoc, chunk);
+			break;
+		case SCTP_CMD_CLEAR_INIT_TAG:
+			asoc->peer.i.init_tag = 0;
 			break;
 		default:
 			printk(KERN_WARNING "Impossible command: %u, %p\n",
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	Fri Jun  4 11:08:18 2004
+++ b/net/sctp/sm_statefuns.c	Fri Jun  4 11:08:18 2004
@@ -171,7 +171,7 @@
  *    Verification Tag field to Tag_A, and also provide its own
  *    Verification Tag (Tag_Z) in the Initiate Tag field.
  *
- * Verification Tag: No checking.
+ * Verification Tag: Must be 0.
  *
  * Inputs
  * (endpoint, asoc, chunk)
@@ -219,6 +219,12 @@
 	     (sk->sk_ack_backlog >= sk->sk_max_ack_backlog)))
 		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);

+	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
+	 * Tag.
+	 */
+	if (chunk->sctp_hdr->vtag != 0)
+		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
+
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
@@ -377,6 +383,9 @@
 	if (!chunk->singleton)
 		return SCTP_DISPOSITION_VIOLATION;

+	if (!sctp_vtag_verify(chunk, asoc))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
 	/* Grab the INIT header.  */
 	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;

@@ -659,8 +668,12 @@
 				      const sctp_subtype_t type, void *arg,
 				      sctp_cmd_seq_t *commands)
 {
+	struct sctp_chunk *chunk = arg;
 	struct sctp_ulpevent *ev;

+	if (!sctp_vtag_verify(chunk, asoc))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
 	/* RFC 2960 5.1 Normal Establishment of an Association
 	 *
 	 * E) Upon reception of the COOKIE ACK, endpoint "A" will move
@@ -807,13 +820,7 @@
 	struct sctp_chunk *reply;
 	size_t paylen = 0;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. If the received
-	 * Verification Tag value does not match the receiver's own
-	 * tag value, the receiver shall silently discard the packet...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	/* 8.3 The receiver of the HEARTBEAT should immediately
@@ -876,11 +883,7 @@
 	sctp_sender_hb_info_t *hbinfo;
 	unsigned long max_interval;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. ...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	hbinfo = (sctp_sender_hb_info_t *) chunk->skb->data;
@@ -1130,6 +1133,12 @@
 	if (!chunk->singleton)
 		return SCTP_DISPOSITION_VIOLATION;

+	/* 3.1 A packet containing an INIT chunk MUST have a zero Verification
+	 * Tag.
+	 */
+	if (chunk->sctp_hdr->vtag != 0)
+		return sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
+
 	/* Grab the INIT header.  */
 	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;

@@ -1386,6 +1395,8 @@
 	sctp_init_chunk_t *peer_init;
 	struct sctp_ulpevent *ev;
 	struct sctp_chunk *repl;
+	struct sctp_chunk *err;
+	sctp_disposition_t disposition;

 	/* new_asoc is a brand-new association, so these are not yet
 	 * side effects--it is safe to run them here.
@@ -1405,6 +1416,29 @@
 		return SCTP_DISPOSITION_CONSUME;
 	}

+	/* If the endpoint is in the SHUTDOWN-ACK-SENT state and recognizes
+	 * the peer has restarted (Action A), it MUST NOT setup a new
+	 * association but instead resend the SHUTDOWN ACK and send an ERROR
+	 * chunk with a "Cookie Received while Shutting Down" error cause to
+	 * its peer.
+	*/
+	if (sctp_state(asoc, SHUTDOWN_ACK_SENT)) {
+		disposition = sctp_sf_do_9_2_reshutack(ep, asoc,
+				SCTP_ST_CHUNK(chunk->chunk_hdr->type),
+				chunk, commands);
+		if (SCTP_DISPOSITION_NOMEM == disposition)
+			goto nomem;
+
+		err = sctp_make_op_error(asoc, chunk,
+					 SCTP_ERROR_COOKIE_IN_SHUTDOWN,
+					 NULL, 0);
+		if (err)
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(err));
+
+		return SCTP_DISPOSITION_CONSUME;
+	}
+
 	/* For now, fail any unsent/unacked data.  Consider the optional
 	 * choice of resending of this data.
 	 */
@@ -1883,6 +1917,9 @@

 	sctp_addto_chunk(reply, sizeof(bht), &bht);

+	/* Clear peer's init_tag cached in assoc as we are sending a new INIT */
+	sctp_add_cmd_sf(commands, SCTP_CMD_CLEAR_INIT_TAG, SCTP_NULL());
+
 	/* Cast away the const modifier, as we want to just
 	 * rerun it through as a sideffect.
 	 */
@@ -2071,13 +2108,7 @@
 	skb_pull(chunk->skb, sizeof(sctp_shutdownhdr_t));
 	chunk->subh.shutdown_hdr = sdh;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. If the received
-	 * Verification Tag value does not match the receiver's own
-	 * tag value, the receiver shall silently discard the packet...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	/* Upon the reception of the SHUTDOWN, the peer endpoint shall
@@ -2190,13 +2221,7 @@
 	sctp_cwrhdr_t *cwr;
 	struct sctp_chunk *chunk = arg;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. If the received
-	 * Verification Tag value does not match the receiver's own
-	 * tag value, the receiver shall silently discard the packet...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	cwr = (sctp_cwrhdr_t *) chunk->skb->data;
@@ -2246,13 +2271,7 @@
 	sctp_ecnehdr_t *ecne;
 	struct sctp_chunk *chunk = arg;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. If the received
-	 * Verification Tag value does not match the receiver's own
-	 * tag value, the receiver shall silently discard the packet...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	ecne = (sctp_ecnehdr_t *) chunk->skb->data;
@@ -2309,13 +2328,7 @@
 	int tmp;
 	__u32 tsn;

-	/* RFC 2960 8.5 Verification Tag
-	 *
-	 * When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag.
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag) {
+	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -2569,13 +2582,7 @@
 	int tmp;
 	__u32 tsn;

-	/* RFC 2960 8.5 Verification Tag
-	 *
-	 * When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag.
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag) {
+	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -2745,11 +2752,7 @@
 	sctp_sackhdr_t *sackh;
 	__u32 ctsn;

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag. ...
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	/* Pull the SACK chunk from the data buffer */
@@ -2895,6 +2898,9 @@
 	struct sctp_chunk *reply;
 	struct sctp_ulpevent *ev;

+	if (!sctp_vtag_verify(chunk, asoc))
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
 	/* 10.2 H) SHUTDOWN COMPLETE notification
 	 *
 	 * When SCTP completes the shutdown procedures (section 9.2) this
@@ -3229,13 +3235,7 @@
 	__u16 len;
 	__u32 tsn;

-	/* RFC 2960 8.5 Verification Tag
-	 *
-	 * When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag.
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag) {
+	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -3293,13 +3293,7 @@
 	__u16 len;
 	__u32 tsn;

-	/* RFC 2960 8.5 Verification Tag
-	 *
-	 * When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag.
-	 */
-	if (ntohl(chunk->sctp_hdr->vtag) != asoc->c.my_vtag) {
+	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
@@ -3376,13 +3370,7 @@

 	SCTP_DEBUG_PRINTK("Processing the unknown chunk id %d.\n", type.chunk);

-	/* 8.5 When receiving an SCTP packet, the endpoint MUST ensure
-	 * that the value in the Verification Tag field of the
-	 * received SCTP packet matches its own Tag.  If the received
-	 * Verification Tag value does not match the receiver's own
-	 * tag value, the receiver shall silently discard the packet.
-	 */
-	if (ntohl(unk_chunk->sctp_hdr->vtag) != asoc->c.my_vtag)
+	if (!sctp_vtag_verify(unk_chunk, asoc))
 		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);

 	switch (type.chunk & SCTP_CID_ACTION_MASK) {
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	Fri Jun  4 11:08:18 2004
+++ b/net/sctp/socket.c	Fri Jun  4 11:08:18 2004
@@ -1164,6 +1164,11 @@
 	if (!asoc) {
 		SCTP_DEBUG_PRINTK("There is no association yet.\n");

+		if (sinfo_flags & (MSG_EOF | MSG_ABORT)) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
+
 		/* Check for invalid stream against the stream counts,
 		 * either the default or the user specified stream counts.
 		 */
@@ -4388,7 +4393,11 @@
 	return err;

 do_error:
-	err = -ECONNREFUSED;
+	if (asoc->counters[SCTP_COUNTER_INIT_ERROR] + 1 >=
+					 	asoc->max_init_attempts)
+		err = -ETIMEDOUT;
+	else
+		err = -ECONNREFUSED;
 	goto out;

 do_interrupted:
