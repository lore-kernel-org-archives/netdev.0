From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/27] sctp: replace ssnmap with asoc stream arrays
Date: Sun,  1 Jan 2017 19:20:19 +0800
Message-ID: <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36363 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755063AbdAALVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:21:09 -0500
In-Reply-To: <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stream arrays are used to save per stream information, which includes
ssn for each stream already.

This patch is to replace ssnmap with asoc stream arrays.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 19 ++++++-------------
 net/sctp/associola.c       | 10 ----------
 net/sctp/sm_make_chunk.c   | 11 ++---------
 net/sctp/sm_statefuns.c    |  3 +--
 net/sctp/ulpqueue.c        | 33 +++++++++++----------------------
 5 files changed, 20 insertions(+), 56 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 549f17d..f81c321 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -407,23 +407,16 @@ void sctp_ssnmap_free(struct sctp_ssnmap *map);
 void sctp_ssnmap_clear(struct sctp_ssnmap *map);
 
 /* What is the current SSN number for this stream? */
-static inline __u16 sctp_ssn_peek(struct sctp_stream *stream, __u16 id)
-{
-	return stream->ssn[id];
-}
+#define sctp_ssn_peek(asoc, type, sid) \
+	((asoc)->stream##type[sid].ssn)
 
 /* Return the next SSN number for this stream.	*/
-static inline __u16 sctp_ssn_next(struct sctp_stream *stream, __u16 id)
-{
-	return stream->ssn[id]++;
-}
+#define sctp_ssn_next(asoc, type, sid) \
+	((asoc)->stream##type[sid].ssn++)
 
 /* Skip over this ssn and all below. */
-static inline void sctp_ssn_skip(struct sctp_stream *stream, __u16 id, 
-				 __u16 ssn)
-{
-	stream->ssn[id] = ssn+1;
-}
+#define sctp_ssn_skip(asoc, type, sid, ssn) \
+	((asoc)->stream##type[sid].ssn = ssn + 1)
               
 /*
  * Pointers to address related SCTP functions.
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 290ec4d..ea03270 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -358,9 +358,6 @@ void sctp_association_free(struct sctp_association *asoc)
 
 	sctp_tsnmap_free(&asoc->peer.tsn_map);
 
-	/* Free ssnmap storage. */
-	sctp_ssnmap_free(asoc->ssnmap);
-
 	/* Free stream information. */
 	kfree(asoc->streamout);
 	kfree(asoc->streamin);
@@ -1143,8 +1140,6 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		/* Reinitialize SSN for both local streams
 		 * and peer's streams.
 		 */
-		sctp_ssnmap_clear(asoc->ssnmap);
-
 		for (i = 0; i < asoc->streamoutcnt; i++)
 			asoc->streamout[i].ssn = 0;
 
@@ -1174,11 +1169,6 @@ void sctp_assoc_update(struct sctp_association *asoc,
 
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
-		if (!asoc->ssnmap) {
-			/* Move the ssnmap. */
-			asoc->ssnmap = new->ssnmap;
-			new->ssnmap = NULL;
-		}
 
 		if (!asoc->streamin && !asoc->streamout) {
 			asoc->streamout = new->streamout;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index eeadeef..78cbd1b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1527,7 +1527,6 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 {
 	struct sctp_datamsg *msg;
 	struct sctp_chunk *lchunk;
-	struct sctp_stream *stream;
 	__u16 ssn;
 	__u16 sid;
 
@@ -1536,7 +1535,6 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 
 	/* All fragments will be on the same stream */
 	sid = ntohs(chunk->subh.data_hdr->stream);
-	stream = &chunk->asoc->ssnmap->out;
 
 	/* Now assign the sequence number to the entire message.
 	 * All fragments must have the same stream sequence number.
@@ -1547,9 +1545,9 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 			ssn = 0;
 		} else {
 			if (lchunk->chunk_hdr->flags & SCTP_DATA_LAST_FRAG)
-				ssn = sctp_ssn_next(stream, sid);
+				ssn = sctp_ssn_next(chunk->asoc, out, sid);
 			else
-				ssn = sctp_ssn_peek(stream, sid);
+				ssn = sctp_ssn_peek(chunk->asoc, out, sid);
 		}
 
 		lchunk->subh.data_hdr->ssn = htons(ssn);
@@ -2447,11 +2445,6 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 		asoc->streamoutcnt = asoc->c.sinit_num_ostreams;
 		asoc->streamincnt = asoc->c.sinit_max_instreams;
 
-		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
-					       asoc->c.sinit_num_ostreams, gfp);
-		if (!asoc->ssnmap)
-			goto clean_up;
-
 		asoc->streamout = kcalloc(asoc->streamoutcnt,
 					  sizeof(*asoc->streamout), gfp);
 		if (!asoc->streamout)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3382ef2..8a130a7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6274,9 +6274,8 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * and is invalid.
 	 */
 	ssn = ntohs(data_hdr->ssn);
-	if (ordered && SSN_lt(ssn, sctp_ssn_peek(&asoc->ssnmap->in, sid))) {
+	if (ordered && SSN_lt(ssn, sctp_ssn_peek(asoc, in, sid)))
 		return SCTP_IERROR_PROTO_VIOLATION;
-	}
 
 	/* Send the data up to the user.  Note:  Schedule  the
 	 * SCTP_CMD_CHUNK_ULP cmd before the SCTP_CMD_GEN_SACK, as the SACK
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 84d0fda..0d8bf26 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -760,11 +760,9 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 	struct sk_buff_head *event_list;
 	struct sk_buff *pos, *tmp;
 	struct sctp_ulpevent *cevent;
-	struct sctp_stream *in;
 	__u16 sid, csid, cssn;
 
 	sid = event->stream;
-	in  = &ulpq->asoc->ssnmap->in;
 
 	event_list = (struct sk_buff_head *) sctp_event2skb(event)->prev;
 
@@ -782,11 +780,11 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 		if (csid < sid)
 			continue;
 
-		if (cssn != sctp_ssn_peek(in, sid))
+		if (cssn != sctp_ssn_peek(ulpq->asoc, in, sid))
 			break;
 
-		/* Found it, so mark in the ssnmap. */
-		sctp_ssn_next(in, sid);
+		/* Found it, so mark in stream array. */
+		sctp_ssn_next(ulpq->asoc, in, sid);
 
 		__skb_unlink(pos, &ulpq->lobby);
 
@@ -849,7 +847,6 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 					     struct sctp_ulpevent *event)
 {
 	__u16 sid, ssn;
-	struct sctp_stream *in;
 
 	/* Check if this message needs ordering.  */
 	if (SCTP_DATA_UNORDERED & event->msg_flags)
@@ -858,10 +855,9 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 	/* Note: The stream ID must be verified before this routine.  */
 	sid = event->stream;
 	ssn = event->ssn;
-	in  = &ulpq->asoc->ssnmap->in;
 
 	/* Is this the expected SSN for this stream ID?  */
-	if (ssn != sctp_ssn_peek(in, sid)) {
+	if (ssn != sctp_ssn_peek(ulpq->asoc, in, sid)) {
 		/* We've received something out of order, so find where it
 		 * needs to be placed.  We order by stream and then by SSN.
 		 */
@@ -870,7 +866,7 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 	}
 
 	/* Mark that the next chunk has been found.  */
-	sctp_ssn_next(in, sid);
+	sctp_ssn_next(ulpq->asoc, in, sid);
 
 	/* Go find any other chunks that were waiting for
 	 * ordering.
@@ -888,13 +884,10 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 	struct sk_buff *pos, *tmp;
 	struct sctp_ulpevent *cevent;
 	struct sctp_ulpevent *event;
-	struct sctp_stream *in;
 	struct sk_buff_head temp;
 	struct sk_buff_head *lobby = &ulpq->lobby;
 	__u16 csid, cssn;
 
-	in  = &ulpq->asoc->ssnmap->in;
-
 	/* We are holding the chunks by stream, by SSN.  */
 	skb_queue_head_init(&temp);
 	event = NULL;
@@ -912,7 +905,7 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 			continue;
 
 		/* see if this ssn has been marked by skipping */
-		if (!SSN_lt(cssn, sctp_ssn_peek(in, csid)))
+		if (!SSN_lt(cssn, sctp_ssn_peek(ulpq->asoc, in, csid)))
 			break;
 
 		__skb_unlink(pos, lobby);
@@ -932,8 +925,9 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 		csid = cevent->stream;
 		cssn = cevent->ssn;
 
-		if (csid == sid && cssn == sctp_ssn_peek(in, csid)) {
-			sctp_ssn_next(in, csid);
+		if (csid == sid &&
+		    cssn == sctp_ssn_peek(ulpq->asoc, in, csid)) {
+			sctp_ssn_next(ulpq->asoc, in, csid);
 			__skb_unlink(pos, lobby);
 			__skb_queue_tail(&temp, pos);
 			event = sctp_skb2event(pos);
@@ -955,17 +949,12 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
  */
 void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn)
 {
-	struct sctp_stream *in;
-
-	/* Note: The stream ID must be verified before this routine.  */
-	in  = &ulpq->asoc->ssnmap->in;
-
 	/* Is this an old SSN?  If so ignore. */
-	if (SSN_lt(ssn, sctp_ssn_peek(in, sid)))
+	if (SSN_lt(ssn, sctp_ssn_peek(ulpq->asoc, in, sid)))
 		return;
 
 	/* Mark that we are no longer expecting this SSN or lower. */
-	sctp_ssn_skip(in, sid, ssn);
+	sctp_ssn_skip(ulpq->asoc, in, sid, ssn);
 
 	/* Go find any other chunks that were waiting for
 	 * ordering and deliver them if needed.
-- 
2.1.0
