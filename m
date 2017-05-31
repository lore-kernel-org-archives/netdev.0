From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/2] sctp: define the member stream as an object instead of pointer in asoc
Date: Wed, 31 May 2017 16:36:31 +0800
Message-ID: <a10f4c7eb03629c4b2316e2096895b8a99f4c1cf.1496219741.git.lucien.xin@gmail.com>
References: <cover.1496219741.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36487 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdEaIgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:36:50 -0400
In-Reply-To: <cover.1496219741.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1496219741.git.lucien.xin@gmail.com>
References: <cover.1496219741.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Marcelo's suggestion, stream is a fixed size member of asoc and would
not grow with more streams. To avoid an allocation for it, this patch is
to define it as an object instead of pointer and update the places using
it, also create sctp_stream_update() called in sctp_assoc_update() to
migrate the stream info from one stream to another.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  3 +-
 net/sctp/associola.c       | 13 ++++-----
 net/sctp/chunk.c           |  4 +--
 net/sctp/outqueue.c        | 10 +++----
 net/sctp/proc.c            |  4 +--
 net/sctp/sm_make_chunk.c   |  2 +-
 net/sctp/sm_statefuns.c    |  8 +++---
 net/sctp/socket.c          | 14 +++++-----
 net/sctp/stream.c          | 68 ++++++++++++++++++++++------------------------
 net/sctp/ulpqueue.c        |  8 +++---
 10 files changed, 65 insertions(+), 69 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index a8b38e1..c8dbf41 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -381,6 +381,7 @@ int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp);
 int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp);
 void sctp_stream_free(struct sctp_stream *stream);
 void sctp_stream_clear(struct sctp_stream *stream);
+void sctp_stream_update(struct sctp_stream *stream, struct sctp_stream *new);
 
 /* What is the current SSN number for this stream? */
 #define sctp_ssn_peek(stream, type, sid) \
@@ -1750,7 +1751,7 @@ struct sctp_association {
 	__u32 default_rcv_context;
 
 	/* Stream arrays */
-	struct sctp_stream *stream;
+	struct sctp_stream stream;
 
 	/* All outbound chunks go through this structure.  */
 	struct sctp_outq outqueue;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 9523828..6625b15 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -291,7 +291,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	return asoc;
 
 stream_free:
-	sctp_stream_free(asoc->stream);
+	sctp_stream_free(&asoc->stream);
 fail_init:
 	sock_put(asoc->base.sk);
 	sctp_endpoint_put(asoc->ep);
@@ -365,7 +365,7 @@ void sctp_association_free(struct sctp_association *asoc)
 	sctp_tsnmap_free(&asoc->peer.tsn_map);
 
 	/* Free stream information. */
-	sctp_stream_free(asoc->stream);
+	sctp_stream_free(&asoc->stream);
 
 	if (asoc->strreset_chunk)
 		sctp_chunk_free(asoc->strreset_chunk);
@@ -1151,7 +1151,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		/* Reinitialize SSN for both local streams
 		 * and peer's streams.
 		 */
-		sctp_stream_clear(asoc->stream);
+		sctp_stream_clear(&asoc->stream);
 
 		/* Flush the ULP reassembly and ordered queue.
 		 * Any data there will now be stale and will
@@ -1177,11 +1177,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
 
-		if (sctp_state(asoc, COOKIE_WAIT)) {
-			sctp_stream_free(asoc->stream);
-			asoc->stream = new->stream;
-			new->stream = NULL;
-		}
+		if (sctp_state(asoc, COOKIE_WAIT))
+			sctp_stream_update(&asoc->stream, &new->stream);
 
 		if (!asoc->assoc_id) {
 			/* get a new association id since we don't have one
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 697721a..81466f6 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -307,7 +307,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 	if (SCTP_PR_TTL_ENABLED(chunk->sinfo.sinfo_flags) &&
 	    time_after(jiffies, chunk->msg->expires_at)) {
 		struct sctp_stream_out *streamout =
-			&chunk->asoc->stream->out[chunk->sinfo.sinfo_stream];
+			&chunk->asoc->stream.out[chunk->sinfo.sinfo_stream];
 
 		if (chunk->sent_count) {
 			chunk->asoc->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
@@ -320,7 +320,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 	} else if (SCTP_PR_RTX_ENABLED(chunk->sinfo.sinfo_flags) &&
 		   chunk->sent_count > chunk->sinfo.sinfo_timetolive) {
 		struct sctp_stream_out *streamout =
-			&chunk->asoc->stream->out[chunk->sinfo.sinfo_stream];
+			&chunk->asoc->stream.out[chunk->sinfo.sinfo_stream];
 
 		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
 		streamout->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index fe4c3d46..20299df 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -363,7 +363,7 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
 		sctp_insert_list(&asoc->outqueue.abandoned,
 				 &chk->transmitted_list);
 
-		streamout = &asoc->stream->out[chk->sinfo.sinfo_stream];
+		streamout = &asoc->stream.out[chk->sinfo.sinfo_stream];
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
 		streamout->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
@@ -400,9 +400,9 @@ static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
 		q->out_qlen -= chk->skb->len;
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
-		if (chk->sinfo.sinfo_stream < asoc->stream->outcnt) {
+		if (chk->sinfo.sinfo_stream < asoc->stream.outcnt) {
 			struct sctp_stream_out *streamout =
-				&asoc->stream->out[chk->sinfo.sinfo_stream];
+				&asoc->stream.out[chk->sinfo.sinfo_stream];
 
 			streamout->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
 		}
@@ -1036,7 +1036,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			/* RFC 2960 6.5 Every DATA chunk MUST carry a valid
 			 * stream identifier.
 			 */
-			if (chunk->sinfo.sinfo_stream >= asoc->stream->outcnt) {
+			if (chunk->sinfo.sinfo_stream >= asoc->stream.outcnt) {
 
 				/* Mark as failed send. */
 				sctp_chunk_fail(chunk, SCTP_ERROR_INV_STRM);
@@ -1054,7 +1054,7 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 				continue;
 			}
 
-			if (asoc->stream->out[sid].state == SCTP_STREAM_CLOSED) {
+			if (asoc->stream.out[sid].state == SCTP_STREAM_CLOSED) {
 				sctp_outq_head_data(q, chunk);
 				goto sctp_flush_out;
 			}
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index a0b29d4..5a27d0f 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -361,8 +361,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	sctp_seq_dump_remote_addrs(seq, assoc);
 	seq_printf(seq, "\t%8lu %5d %5d %4d %4d %4d %8d "
 		   "%8d %8d %8d %8d",
-		assoc->hbinterval, assoc->stream->incnt,
-		assoc->stream->outcnt, assoc->max_retrans,
+		assoc->hbinterval, assoc->stream.incnt,
+		assoc->stream.outcnt, assoc->max_retrans,
 		assoc->init_retries, assoc->shutdown_retries,
 		assoc->rtx_data_chunks,
 		atomic_read(&sk->sk_wmem_alloc),
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 92e332e..2441814 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1544,7 +1544,7 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 
 	/* All fragments will be on the same stream */
 	sid = ntohs(chunk->subh.data_hdr->stream);
-	stream = chunk->asoc->stream;
+	stream = &chunk->asoc->stream;
 
 	/* Now assign the sequence number to the entire message.
 	 * All fragments must have the same stream sequence number.
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f863b55..df73190 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3958,7 +3958,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn(struct net *net,
 
 	/* Silently discard the chunk if stream-id is not valid */
 	sctp_walk_fwdtsn(skip, chunk) {
-		if (ntohs(skip->stream) >= asoc->stream->incnt)
+		if (ntohs(skip->stream) >= asoc->stream.incnt)
 			goto discard_noforce;
 	}
 
@@ -4029,7 +4029,7 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
 
 	/* Silently discard the chunk if stream-id is not valid */
 	sctp_walk_fwdtsn(skip, chunk) {
-		if (ntohs(skip->stream) >= asoc->stream->incnt)
+		if (ntohs(skip->stream) >= asoc->stream.incnt)
 			goto gen_shutdown;
 	}
 
@@ -6365,7 +6365,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * and discard the DATA chunk.
 	 */
 	sid = ntohs(data_hdr->stream);
-	if (sid >= asoc->stream->incnt) {
+	if (sid >= asoc->stream.incnt) {
 		/* Mark tsn as received even though we drop it */
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_TSN, SCTP_U32(tsn));
 
@@ -6387,7 +6387,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * and is invalid.
 	 */
 	ssn = ntohs(data_hdr->ssn);
-	if (ordered && SSN_lt(ssn, sctp_ssn_peek(asoc->stream, in, sid)))
+	if (ordered && SSN_lt(ssn, sctp_ssn_peek(&asoc->stream, in, sid)))
 		return SCTP_IERROR_PROTO_VIOLATION;
 
 	/* Send the data up to the user.  Note:  Schedule  the
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f16c8d9..0822046 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1920,7 +1920,7 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	}
 
 	/* Check for invalid stream. */
-	if (sinfo->sinfo_stream >= asoc->stream->outcnt) {
+	if (sinfo->sinfo_stream >= asoc->stream.outcnt) {
 		err = -EINVAL;
 		goto out_free;
 	}
@@ -4497,8 +4497,8 @@ int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
 	info->sctpi_rwnd = asoc->a_rwnd;
 	info->sctpi_unackdata = asoc->unack_data;
 	info->sctpi_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
-	info->sctpi_instrms = asoc->stream->incnt;
-	info->sctpi_outstrms = asoc->stream->outcnt;
+	info->sctpi_instrms = asoc->stream.incnt;
+	info->sctpi_outstrms = asoc->stream.outcnt;
 	list_for_each(pos, &asoc->base.inqueue.in_chunk_list)
 		info->sctpi_inqueue++;
 	list_for_each(pos, &asoc->outqueue.out_chunk_list)
@@ -4727,8 +4727,8 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 	status.sstat_unackdata = asoc->unack_data;
 
 	status.sstat_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
-	status.sstat_instrms = asoc->stream->incnt;
-	status.sstat_outstrms = asoc->stream->outcnt;
+	status.sstat_instrms = asoc->stream.incnt;
+	status.sstat_outstrms = asoc->stream.outcnt;
 	status.sstat_fragmentation_point = asoc->frag_point;
 	status.sstat_primary.spinfo_assoc_id = sctp_assoc2id(transport->asoc);
 	memcpy(&status.sstat_primary.spinfo_address, &transport->ipaddr,
@@ -6600,10 +6600,10 @@ static int sctp_getsockopt_pr_streamstatus(struct sock *sk, int len,
 		goto out;
 
 	asoc = sctp_id2assoc(sk, params.sprstat_assoc_id);
-	if (!asoc || params.sprstat_sid >= asoc->stream->outcnt)
+	if (!asoc || params.sprstat_sid >= asoc->stream.outcnt)
 		goto out;
 
-	streamout = &asoc->stream->out[params.sprstat_sid];
+	streamout = &asoc->stream.out[params.sprstat_sid];
 	if (policy == SCTP_PR_SCTP_NONE) {
 		params.sprstat_abandoned_unsent = 0;
 		params.sprstat_abandoned_sent = 0;
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index dda53a2..af6b498 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -37,30 +37,23 @@
 
 int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp)
 {
-	struct sctp_stream *stream;
+	struct sctp_stream *stream = &asoc->stream;
 	int i;
 
-	stream = kzalloc(sizeof(*stream), gfp);
-	if (!stream)
-		return -ENOMEM;
-
 	stream->outcnt = asoc->c.sinit_num_ostreams;
 	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
-	if (!stream->out) {
-		kfree(stream);
+	if (!stream->out)
 		return -ENOMEM;
-	}
+
 	for (i = 0; i < stream->outcnt; i++)
 		stream->out[i].state = SCTP_STREAM_OPEN;
 
-	asoc->stream = stream;
-
 	return 0;
 }
 
 int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp)
 {
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	int i;
 
 	/* Initial stream->out size may be very big, so free it and alloc
@@ -70,7 +63,7 @@ int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp)
 	stream->outcnt = asoc->c.sinit_num_ostreams;
 	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
 	if (!stream->out)
-		goto nomem;
+		return -ENOMEM;
 
 	for (i = 0; i < stream->outcnt; i++)
 		stream->out[i].state = SCTP_STREAM_OPEN;
@@ -79,26 +72,17 @@ int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp)
 	stream->in = kcalloc(stream->incnt, sizeof(*stream->in), gfp);
 	if (!stream->in) {
 		kfree(stream->out);
-		goto nomem;
+		stream->out = NULL;
+		return -ENOMEM;
 	}
 
 	return 0;
-
-nomem:
-	asoc->stream = NULL;
-	kfree(stream);
-
-	return -ENOMEM;
 }
 
 void sctp_stream_free(struct sctp_stream *stream)
 {
-	if (unlikely(!stream))
-		return;
-
 	kfree(stream->out);
 	kfree(stream->in);
-	kfree(stream);
 }
 
 void sctp_stream_clear(struct sctp_stream *stream)
@@ -112,6 +96,19 @@ void sctp_stream_clear(struct sctp_stream *stream)
 		stream->in[i].ssn = 0;
 }
 
+void sctp_stream_update(struct sctp_stream *stream, struct sctp_stream *new)
+{
+	sctp_stream_free(stream);
+
+	stream->out = new->out;
+	stream->in  = new->in;
+	stream->outcnt = new->outcnt;
+	stream->incnt  = new->incnt;
+
+	new->out = NULL;
+	new->in  = NULL;
+}
+
 static int sctp_send_reconf(struct sctp_association *asoc,
 			    struct sctp_chunk *chunk)
 {
@@ -128,7 +125,7 @@ static int sctp_send_reconf(struct sctp_association *asoc,
 int sctp_send_reset_streams(struct sctp_association *asoc,
 			    struct sctp_reset_streams *params)
 {
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u16 i, str_nums, *str_list;
 	struct sctp_chunk *chunk;
 	int retval = -EINVAL;
@@ -214,6 +211,7 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 
 int sctp_send_reset_assoc(struct sctp_association *asoc)
 {
+	struct sctp_stream *stream = &asoc->stream;
 	struct sctp_chunk *chunk = NULL;
 	int retval;
 	__u16 i;
@@ -230,8 +228,8 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
 		return -ENOMEM;
 
 	/* Block further xmit of data until this request is completed */
-	for (i = 0; i < asoc->stream->outcnt; i++)
-		asoc->stream->out[i].state = SCTP_STREAM_CLOSED;
+	for (i = 0; i < stream->outcnt; i++)
+		stream->out[i].state = SCTP_STREAM_CLOSED;
 
 	asoc->strreset_chunk = chunk;
 	sctp_chunk_hold(asoc->strreset_chunk);
@@ -241,8 +239,8 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
 		sctp_chunk_put(asoc->strreset_chunk);
 		asoc->strreset_chunk = NULL;
 
-		for (i = 0; i < asoc->stream->outcnt; i++)
-			asoc->stream->out[i].state = SCTP_STREAM_OPEN;
+		for (i = 0; i < stream->outcnt; i++)
+			stream->out[i].state = SCTP_STREAM_OPEN;
 
 		return retval;
 	}
@@ -255,7 +253,7 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
 int sctp_send_add_streams(struct sctp_association *asoc,
 			  struct sctp_add_streams *params)
 {
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	struct sctp_chunk *chunk = NULL;
 	int retval = -ENOMEM;
 	__u32 outcnt, incnt;
@@ -357,7 +355,7 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 				struct sctp_ulpevent **evp)
 {
 	struct sctp_strreset_outreq *outreq = param.v;
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u16 i, nums, flags = 0, *str_p = NULL;
 	__u32 result = SCTP_STRRESET_DENIED;
 	__u32 request_seq;
@@ -449,7 +447,7 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 				struct sctp_ulpevent **evp)
 {
 	struct sctp_strreset_inreq *inreq = param.v;
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
 	struct sctp_chunk *chunk = NULL;
 	__u16 i, nums, *str_p;
@@ -523,7 +521,7 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 {
 	__u32 init_tsn = 0, next_tsn = 0, max_tsn_seen;
 	struct sctp_strreset_tsnreq *tsnreq = param.v;
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
 	__u32 request_seq;
 	__u16 i;
@@ -612,7 +610,7 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 				struct sctp_ulpevent **evp)
 {
 	struct sctp_strreset_addstrm *addstrm = param.v;
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
 	struct sctp_stream_in *streamin;
 	__u32 request_seq, incnt;
@@ -687,7 +685,7 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 				struct sctp_ulpevent **evp)
 {
 	struct sctp_strreset_addstrm *addstrm = param.v;
-	struct sctp_stream *stream = asoc->stream;
+	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
 	struct sctp_stream_out *streamout;
 	struct sctp_chunk *chunk = NULL;
@@ -758,8 +756,8 @@ struct sctp_chunk *sctp_process_strreset_resp(
 				union sctp_params param,
 				struct sctp_ulpevent **evp)
 {
+	struct sctp_stream *stream = &asoc->stream;
 	struct sctp_strreset_resp *resp = param.v;
-	struct sctp_stream *stream = asoc->stream;
 	struct sctp_transport *t;
 	__u16 i, nums, flags = 0;
 	sctp_paramhdr_t *req;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index aa3624d..25f7e41 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -764,7 +764,7 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 	__u16 sid, csid, cssn;
 
 	sid = event->stream;
-	stream  = ulpq->asoc->stream;
+	stream  = &ulpq->asoc->stream;
 
 	event_list = (struct sk_buff_head *) sctp_event2skb(event)->prev;
 
@@ -858,7 +858,7 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 	/* Note: The stream ID must be verified before this routine.  */
 	sid = event->stream;
 	ssn = event->ssn;
-	stream  = ulpq->asoc->stream;
+	stream  = &ulpq->asoc->stream;
 
 	/* Is this the expected SSN for this stream ID?  */
 	if (ssn != sctp_ssn_peek(stream, in, sid)) {
@@ -893,7 +893,7 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 	struct sk_buff_head *lobby = &ulpq->lobby;
 	__u16 csid, cssn;
 
-	stream = ulpq->asoc->stream;
+	stream = &ulpq->asoc->stream;
 
 	/* We are holding the chunks by stream, by SSN.  */
 	skb_queue_head_init(&temp);
@@ -958,7 +958,7 @@ void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn)
 	struct sctp_stream *stream;
 
 	/* Note: The stream ID must be verified before this routine.  */
-	stream  = ulpq->asoc->stream;
+	stream  = &ulpq->asoc->stream;
 
 	/* Is this an old SSN?  If so ignore. */
 	if (SSN_lt(ssn, sctp_ssn_peek(stream, in, sid)))
-- 
2.1.0
