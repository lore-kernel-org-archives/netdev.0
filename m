From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 6/8] SCTP: Implement the receive and verification of AUTH chunk
Date: Fri, 14 Sep 2007 14:44:57 -0400
Message-ID: <11897955003311-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:49232 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770AbXINSpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:12 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the receive path needed to process authenticated
chunks.  Add ability to process the AUTH chunk and handle edge cases
for authenticated COOKIE-ECHO as well.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/constants.h |    4 +-
 include/net/sctp/sm.h        |    1 +
 include/net/sctp/structs.h   |    8 ++
 net/sctp/associola.c         |   10 ++
 net/sctp/endpointola.c       |   29 ++++++
 net/sctp/input.c             |   65 +++++++++++--
 net/sctp/inqueue.c           |   19 ++++
 net/sctp/sm_statefuns.c      |  218 +++++++++++++++++++++++++++++++++++++++++-
 net/sctp/sm_statetable.c     |   33 +++++++
 9 files changed, 374 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 777118f..da8354e 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -183,7 +183,9 @@ typedef enum {
 	SCTP_IERROR_NO_DATA,
 	SCTP_IERROR_BAD_STREAM,
 	SCTP_IERROR_BAD_PORTS,
-
+	SCTP_IERROR_AUTH_BAD_HMAC,
+	SCTP_IERROR_AUTH_BAD_KEYID,
+	SCTP_IERROR_PROTO_VIOLATION,
 } sctp_ierror_t;
 
 
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ee62897..4357307 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -144,6 +144,7 @@ sctp_state_fn_t sctp_sf_do_asconf_ack;
 sctp_state_fn_t sctp_sf_do_9_2_reshutack;
 sctp_state_fn_t sctp_sf_eat_fwd_tsn;
 sctp_state_fn_t sctp_sf_eat_fwd_tsn_fast;
+sctp_state_fn_t sctp_sf_eat_auth;
 
 /* Prototypes for primitive event state functions.  */
 sctp_state_fn_t sctp_sf_do_prm_asoc;
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8cb7bc4..3215da4 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -719,6 +719,13 @@ struct sctp_chunk {
 	 */
 	struct sctp_transport *transport;
 
+	/* SCTP-AUTH:  For the special case inbound processing of COOKIE-ECHO
+	 * we need save a pointer to the AUTH chunk, since the SCTP-AUTH
+	 * spec violates the principle premis that all chunks are processed
+	 * in order.
+	 */
+	struct sk_buff *auth_chunk;
+
 	__u8 rtt_in_progress;	/* Is this chunk used for RTT calculation? */
 	__u8 resent;		/* Has this chunk ever been retransmitted. */
 	__u8 has_tsn;		/* Does this chunk have a TSN yet? */
@@ -1060,6 +1067,7 @@ void sctp_inq_init(struct sctp_inq *);
 void sctp_inq_free(struct sctp_inq *);
 void sctp_inq_push(struct sctp_inq *, struct sctp_chunk *packet);
 struct sctp_chunk *sctp_inq_pop(struct sctp_inq *);
+struct sctp_chunkhdr *sctp_inq_peek(struct sctp_inq *);
 void sctp_inq_set_th_handler(struct sctp_inq *, work_func_t);
 
 /* This is the structure we use to hold outbound chunks.  You push
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 09e592b..5bf2009 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1015,6 +1015,16 @@ static void sctp_assoc_bh_rcv(struct work_struct *work)
 		state = asoc->state;
 		subtype = SCTP_ST_CHUNK(chunk->chunk_hdr->type);
 
+		/* SCTP-AUTH, Section 6.3:
+		 *    The receiver has a list of chunk types which it expects
+		 *    to be received only after an AUTH-chunk.  This list has
+		 *    been sent to the peer during the association setup.  It
+		 *    MUST silently discard these chunks if they are not placed
+		 *    after an AUTH chunk in the packet.
+		 */
+		if (sctp_auth_recv_cid(subtype.chunk, asoc) && !chunk->auth)
+			continue;
+
 		/* Remember where the last DATA chunk came from so we
 		 * know where to send the SACK.
 		 */
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 84843ed..71aa266 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -413,6 +413,7 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 	sctp_subtype_t subtype;
 	sctp_state_t state;
 	int error = 0;
+	int first_time = 1;	/* is this the first time through the looop */
 
 	if (ep->base.dead)
 		return;
@@ -424,6 +425,29 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 	while (NULL != (chunk = sctp_inq_pop(inqueue))) {
 		subtype = SCTP_ST_CHUNK(chunk->chunk_hdr->type);
 
+		/* If the first chunk in the packet is AUTH, do special
+		 * processing specified in Section 6.3 of SCTP-AUTH spec
+		 */
+		if (first_time && (subtype.chunk == SCTP_CID_AUTH)) {
+			struct sctp_chunkhdr *next_hdr;
+
+			next_hdr = sctp_inq_peek(inqueue);
+			if (!next_hdr)
+				goto normal;
+
+			/* If the next chunk is COOKIE-ECHO, skip the AUTH
+			 * chunk while saving a pointer to it so we can do
+			 * Authentication later (during cookie-echo
+			 * processing).
+			 */
+			if (next_hdr->type == SCTP_CID_COOKIE_ECHO) {
+				chunk->auth_chunk = skb_clone(chunk->skb,
+								GFP_ATOMIC);
+				chunk->auth = 1;
+				continue;
+			}
+		}
+normal:
 		/* We might have grown an association since last we
 		 * looked, so try again.
 		 *
@@ -439,6 +463,8 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 		}
 
 		state = asoc ? asoc->state : SCTP_STATE_CLOSED;
+		if (sctp_auth_recv_cid(subtype.chunk, asoc) && !chunk->auth)
+			continue;
 
 		/* Remember where the last DATA chunk came from so we
 		 * know where to send the SACK.
@@ -462,5 +488,8 @@ static void sctp_endpoint_bh_rcv(struct work_struct *work)
 		 */
 		if (!sctp_sk(sk)->ep)
 			break;
+
+		if (first_time)
+			first_time = 0;
 	}
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 47e5601..5a97716 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -903,15 +903,6 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 
 	ch = (sctp_chunkhdr_t *) skb->data;
 
-	/* If this is INIT/INIT-ACK look inside the chunk too. */
-	switch (ch->type) {
-	case SCTP_CID_INIT:
-	case SCTP_CID_INIT_ACK:
-		break;
-	default:
-		return NULL;
-	}
-
 	/* The code below will attempt to walk the chunk and extract
 	 * parameter information.  Before we do that, we need to verify
 	 * that the chunk length doesn't cause overflow.  Otherwise, we'll
@@ -956,6 +947,60 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 	return NULL;
 }
 
+/* SCTP-AUTH, Section 6.3:
+*    If the receiver does not find a STCB for a packet containing an AUTH
+*    chunk as the first chunk and not a COOKIE-ECHO chunk as the second
+*    chunk, it MUST use the chunks after the AUTH chunk to look up an existing
+*    association.
+*
+* This means that any chunks that can help us identify the association need
+* to be looked at to find this assocation.
+*
+* TODO: The only chunk currently defined that can do that is ASCONF, but we
+* don't support that functionality yet.
+*/
+static struct sctp_association *__sctp_rcv_auth_lookup(struct sk_buff *skb,
+				      const union sctp_addr *paddr,
+				      const union sctp_addr *laddr,
+				      struct sctp_transport **transportp)
+{
+	/* XXX - walk through the chunks looking for something that can
+	 * help us find the association.  INIT, and INIT-ACK are not permitted.
+	 * That leaves ASCONF, but we don't support that yet.
+	 */
+	return NULL;
+}
+
+/*
+ * There are circumstances when we need to look inside the SCTP packet
+ * for information to help us find the association.   Examples
+ * include looking inside of INIT/INIT-ACK chunks or after the AUTH
+ * chunks.
+ */
+static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
+				      const union sctp_addr *paddr,
+				      const union sctp_addr *laddr,
+				      struct sctp_transport **transportp)
+{
+	sctp_chunkhdr_t *ch;
+
+	ch = (sctp_chunkhdr_t *) skb->data;
+
+	/* If this is INIT/INIT-ACK look inside the chunk too. */
+	switch (ch->type) {
+	case SCTP_CID_INIT:
+	case SCTP_CID_INIT_ACK:
+		return __sctp_rcv_init_lookup(skb, laddr, transportp);
+		break;
+
+	case SCTP_CID_AUTH:
+		return __sctp_rcv_auth_lookup(skb, paddr, laddr, transportp);
+		break;
+	}
+
+	return NULL;
+}
+
 /* Lookup an association for an inbound skb. */
 static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
 				      const union sctp_addr *paddr,
@@ -971,7 +1016,7 @@ static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
 	 * parameters within the INIT or INIT-ACK.
 	 */
 	if (!asoc)
-		asoc = __sctp_rcv_init_lookup(skb, laddr, transportp);
+		asoc = __sctp_rcv_lookup_harder(skb, paddr, laddr, transportp);
 
 	return asoc;
 }
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 88aa224..2e48613 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -100,6 +100,25 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
 	q->immediate.func(&q->immediate);
 }
 
+/* Peek at the next chunk on the inqeue. */
+struct sctp_chunkhdr *sctp_inq_peek(struct sctp_inq *queue)
+{
+	struct sctp_chunk *chunk;
+	sctp_chunkhdr_t *ch = NULL;
+
+	chunk = queue->in_progress;
+	/* If there is no more chunks in this packet, say so */
+	if (chunk->singleton ||
+	    chunk->end_of_packet ||
+	    chunk->pdiscard)
+		    return NULL;
+
+	ch = (sctp_chunkhdr_t *)chunk->chunk_end;
+
+	return ch;
+}
+
+
 /* Extract a chunk from an SCTP inqueue.
  *
  * WARNING:  If you need to put the chunk on another queue, you need to
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7d8e92f..21b0f48 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -118,6 +118,11 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
+static sctp_ierror_t sctp_sf_authenticate(const struct sctp_endpoint *ep,
+				    const struct sctp_association *asoc,
+				    const sctp_subtype_t type,
+				    struct sctp_chunk *chunk);
+
 /* Small helper function that checks if the chunk length
  * is of the appropriate length.  The 'required_length' argument
  * is set to be the size of a specific chunk we are testing.
@@ -470,8 +475,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
-		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
-
 		/* This chunk contains fatal error. It is to be discarded.
 		 * Send an ABORT, with causes if there is any.
 		 */
@@ -496,6 +499,22 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 			sctp_sf_tabort_8_4_8(ep, asoc, type, arg, commands);
 			error = SCTP_ERROR_INV_PARAM;
 		}
+
+		/* SCTP-AUTH, Section 6.3:
+		 *    It should be noted that if the receiver wants to tear
+		 *    down an association in an authenticated way only, the
+		 *    handling of malformed packets should not result in
+		 *    tearing down the association.
+		 *
+		 * This means that if we only want to abort associations
+		 * in an authenticated way (i.e AUTH+ABORT), then we
+		 * can't destory this association just becuase the packet
+		 * was malformed.
+		 */
+		if (sctp_auth_recv_cid(SCTP_CID_ABORT, asoc))
+			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
+		SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
 		return sctp_stop_t1_and_abort(commands, error, ECONNREFUSED,
 						asoc, chunk->transport);
 	}
@@ -674,6 +693,36 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(const struct sctp_endpoint *ep,
 	if (error)
 		goto nomem_init;
 
+	/* SCTP-AUTH:  auth_chunk pointer is only set when the cookie-echo
+	 * is supposed to be authenticated and we have to do delayed
+	 * authentication.  We've just recreated the association using
+	 * the information in the cookie and now it's much easier to
+	 * do the authentication.
+	 */
+	if (chunk->auth_chunk) {
+		struct sctp_chunk auth;
+		sctp_ierror_t ret;
+
+		/* set-up our fake chunk so that we can process it */
+		auth.skb = chunk->auth_chunk;
+		auth.asoc = chunk->asoc;
+		auth.sctp_hdr = chunk->sctp_hdr;
+		auth.chunk_hdr = (sctp_chunkhdr_t *)skb_push(chunk->auth_chunk,
+					    sizeof(sctp_chunkhdr_t));
+		skb_pull(chunk->auth_chunk, sizeof(sctp_chunkhdr_t));
+		auth.transport = chunk->transport;
+
+		ret = sctp_sf_authenticate(ep, new_asoc, type, &auth);
+
+		/* We can now safely free the auth_chunk clone */
+		kfree_skb(chunk->auth_chunk);
+
+		if (ret != SCTP_IERROR_NO_ERROR) {
+			sctp_association_free(new_asoc);
+			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+		}
+	}
+
 	repl = sctp_make_cookie_ack(new_asoc, chunk);
 	if (!repl)
 		goto nomem_init;
@@ -3581,6 +3630,156 @@ gen_shutdown:
 }
 
 /*
+ * SCTP-AUTH Section 6.3 Receving authenticated chukns
+ *
+ *    The receiver MUST use the HMAC algorithm indicated in the HMAC
+ *    Identifier field.  If this algorithm was not specified by the
+ *    receiver in the HMAC-ALGO parameter in the INIT or INIT-ACK chunk
+ *    during association setup, the AUTH chunk and all chunks after it MUST
+ *    be discarded and an ERROR chunk SHOULD be sent with the error cause
+ *    defined in Section 4.1.
+ *
+ *    If an endpoint with no shared key receives a Shared Key Identifier
+ *    other than 0, it MUST silently discard all authenticated chunks.  If
+ *    the endpoint has at least one endpoint pair shared key for the peer,
+ *    it MUST use the key specified by the Shared Key Identifier if a
+ *    key has been configured for that Shared Key Identifier.  If no
+ *    endpoint pair shared key has been configured for that Shared Key
+ *    Identifier, all authenticated chunks MUST be silently discarded.
+ *
+ * Verification Tag:  8.5 Verification Tag [Normal verification]
+ *
+ * The return value is the disposition of the chunk.
+ */
+static sctp_ierror_t sctp_sf_authenticate(const struct sctp_endpoint *ep,
+				    const struct sctp_association *asoc,
+				    const sctp_subtype_t type,
+				    struct sctp_chunk *chunk)
+{
+	struct sctp_authhdr *auth_hdr;
+	struct sctp_hmac *hmac;
+	unsigned int sig_len;
+	__u16 key_id;
+	__u8 *save_digest;
+	__u8 *digest;
+
+	/* Pull in the auth header, so we can do some more verification */
+	auth_hdr = (struct sctp_authhdr *)chunk->skb->data;
+	chunk->subh.auth_hdr = auth_hdr;
+	skb_pull(chunk->skb, sizeof(struct sctp_authhdr));
+
+	/* Make sure that we suport the HMAC algorithm from the auth
+	 * chunk.
+	 */
+	if (!sctp_auth_asoc_verify_hmac_id(asoc, auth_hdr->hmac_id))
+		return SCTP_IERROR_AUTH_BAD_HMAC;
+
+	/* Make sure that the provided shared key identifier has been
+	 * configured
+	 */
+	key_id = ntohs(auth_hdr->shkey_id);
+	if (key_id != asoc->active_key_id && !sctp_auth_get_shkey(asoc, key_id))
+		return SCTP_IERROR_AUTH_BAD_KEYID;
+
+
+	/* Make sure that the length of the signature matches what
+	 * we expect.
+	 */
+	sig_len = ntohs(chunk->chunk_hdr->length) - sizeof(sctp_auth_chunk_t);
+	hmac = sctp_auth_get_hmac(ntohs(auth_hdr->hmac_id));
+	if (sig_len != hmac->hmac_len)
+		return SCTP_IERROR_PROTO_VIOLATION;
+
+	/* Now that we've done validation checks, we can compute and
+	 * verify the hmac.  The steps involved are:
+	 *  1. Save the digest from the chunk.
+	 *  2. Zero out the digest in the chunk.
+	 *  3. Compute the new digest
+	 *  4. Compare saved and new digests.
+	 */
+	digest = auth_hdr->hmac;
+	skb_pull(chunk->skb, sig_len);
+
+	save_digest = kmemdup(digest, sig_len, GFP_ATOMIC);
+	if (!save_digest)
+		goto nomem;
+
+	memset(digest, 0, sig_len);
+
+	sctp_auth_calculate_hmac(asoc, chunk->skb,
+				(struct sctp_auth_chunk *)chunk->chunk_hdr,
+				GFP_ATOMIC);
+
+	/* Discard the packet if the digests do not match */
+	if (memcmp(save_digest, digest, sig_len)) {
+		kfree(save_digest);
+		return SCTP_IERROR_BAD_SIG;
+	}
+
+	kfree(save_digest);
+	chunk->auth = 1;
+
+	return SCTP_IERROR_NO_ERROR;
+nomem:
+	return SCTP_IERROR_NOMEM;
+}
+
+sctp_disposition_t sctp_sf_eat_auth(const struct sctp_endpoint *ep,
+				    const struct sctp_association *asoc,
+				    const sctp_subtype_t type,
+				    void *arg,
+				    sctp_cmd_seq_t *commands)
+{
+	struct sctp_authhdr *auth_hdr;
+	struct sctp_chunk *chunk = arg;
+	struct sctp_chunk *err_chunk;
+	sctp_ierror_t error;
+
+	if (!sctp_vtag_verify(chunk, asoc)) {
+		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
+				SCTP_NULL());
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+	}
+
+	/* Make sure that the AUTH chunk has valid length.  */
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_auth_chunk)))
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
+	auth_hdr = (struct sctp_authhdr *)chunk->skb->data;
+	error = sctp_sf_authenticate(ep, asoc, type, chunk);
+	switch (error) {
+		case SCTP_IERROR_AUTH_BAD_HMAC:
+			/* Generate the ERROR chunk and discard the rest
+			 * of the packet
+			 */
+			err_chunk = sctp_make_op_error(asoc, chunk,
+							SCTP_ERROR_UNSUP_HMAC,
+							&auth_hdr->hmac_id,
+							sizeof(__u16));
+			if (err_chunk) {
+				sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+						SCTP_CHUNK(err_chunk));
+			}
+			/* Fall Through */
+		case SCTP_IERROR_AUTH_BAD_KEYID:
+		case SCTP_IERROR_BAD_SIG:
+			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+			break;
+		case SCTP_IERROR_PROTO_VIOLATION:
+			return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+							  commands);
+			break;
+		case SCTP_IERROR_NOMEM:
+			return SCTP_DISPOSITION_NOMEM;
+		default:
+			break;
+	}
+
+	return SCTP_DISPOSITION_CONSUME;
+}
+
+/*
  * Process an unknown chunk.
  *
  * Section: 3.2. Also, 2.1 in the implementor's guide.
@@ -3766,6 +3965,20 @@ static sctp_disposition_t sctp_sf_abort_violation(
 	if (!abort)
 		goto nomem;
 
+	/* SCTP-AUTH, Section 6.3:
+	 *    It should be noted that if the receiver wants to tear
+	 *    down an association in an authenticated way only, the
+	 *    handling of malformed packets should not result in
+	 *    tearing down the association.
+	 *
+	 * This means that if we only want to abort associations
+	 * in an authenticated way (i.e AUTH+ABORT), then we
+	 * can't destory this association just becuase the packet
+	 * was malformed.
+	 */
+	if (sctp_auth_recv_cid(SCTP_CID_ABORT, asoc))
+		goto discard;
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(abort));
 	SCTP_INC_STATS(SCTP_MIB_OUTCTRLCHUNKS);
 
@@ -3784,6 +3997,7 @@ static sctp_disposition_t sctp_sf_abort_violation(
 		SCTP_DEC_STATS(SCTP_MIB_CURRESTAB);
 	}
 
+discard:
 	sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
 
 	SCTP_INC_STATS(SCTP_MIB_ABORTEDS);
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 70a91ec..e7efccf 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -523,6 +523,34 @@ static const sctp_sm_table_entry_t prsctp_chunk_event_table[SCTP_NUM_PRSCTP_CHUN
 	TYPE_SCTP_FWD_TSN,
 }; /*state_fn_t prsctp_chunk_event_table[][] */
 
+#define TYPE_SCTP_AUTH { \
+	/* SCTP_STATE_EMPTY */ \
+	TYPE_SCTP_FUNC(sctp_sf_ootb), \
+	/* SCTP_STATE_CLOSED */ \
+	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
+	/* SCTP_STATE_COOKIE_WAIT */ \
+	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
+	/* SCTP_STATE_COOKIE_ECHOED */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+	/* SCTP_STATE_ESTABLISHED */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+	/* SCTP_STATE_SHUTDOWN_PENDING */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+	/* SCTP_STATE_SHUTDOWN_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+	/* SCTP_STATE_SHUTDOWN_RECEIVED */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+	/* SCTP_STATE_SHUTDOWN_ACK_SENT */ \
+	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
+} /* TYPE_SCTP_AUTH */
+
+/* The primary index for this table is the chunk type.
+ * The secondary index for this table is the state.
+ */
+static const sctp_sm_table_entry_t auth_chunk_event_table[SCTP_NUM_AUTH_CHUNK_TYPES][SCTP_STATE_NUM_STATES] = {
+	TYPE_SCTP_AUTH,
+}; /*state_fn_t auth_chunk_event_table[][] */
+
 static const sctp_sm_table_entry_t
 chunk_event_table_unknown[SCTP_STATE_NUM_STATES] = {
 	/* SCTP_STATE_EMPTY */
@@ -976,5 +1004,10 @@ static const sctp_sm_table_entry_t *sctp_chunk_event_lookup(sctp_cid_t cid,
 			return &addip_chunk_event_table[1][state];
 	}
 
+	if (sctp_auth_enable) {
+		if (cid == SCTP_CID_AUTH)
+			return &auth_chunk_event_table[0][state];
+	}
+
 	return &chunk_event_table_unknown[state];
 }
-- 
1.5.2.4

