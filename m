From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 4/7] sctp: implement receiver-side procedures for the Add Outgoing Streams Request Parameter
Date: Fri, 10 Mar 2017 12:11:09 +0800
Message-ID: <f73e5ede81d0eeccdf955eb7d77eadcda5166c9e.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
 <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
 <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34763 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754135AbdCJEME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:12:04 -0500
In-Reply-To: <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Receiver-Side Procedures for the Add Outgoing
Streams Request Parameter described in section 5.2.5.

It is also to improve sctp_chunk_lookup_strreset_param, so that it
can be used for processing addstrm_out request.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h   |  4 +++
 net/sctp/sm_statefuns.c |  3 ++
 net/sctp/stream.c       | 89 +++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 86 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2629d66..93ae50b 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -297,6 +297,10 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_addstrm_out(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6982064..881122b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3875,6 +3875,9 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 		else if (param.p->type == SCTP_PARAM_RESET_TSN_REQUEST)
 			reply = sctp_process_strreset_tsnreq(
 				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_ADD_OUT_STREAMS)
+			reply = sctp_process_strreset_addstrm_out(
+				(struct sctp_association *)asoc, param, &ev);
 		/* More handles for other types will be added here, by now it
 		 * just ignores other types.
 		 */
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 7e993b0..df2794d 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -303,13 +303,14 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 }
 
 static sctp_paramhdr_t *sctp_chunk_lookup_strreset_param(
-			struct sctp_association *asoc, __u32 resp_seq)
+			struct sctp_association *asoc, __u32 resp_seq,
+			__be16 type)
 {
 	struct sctp_chunk *chunk = asoc->strreset_chunk;
 	struct sctp_reconf_chunk *hdr;
 	union sctp_params param;
 
-	if (ntohl(resp_seq) != asoc->strreset_outseq || !chunk)
+	if (!chunk)
 		return NULL;
 
 	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
@@ -320,7 +321,8 @@ static sctp_paramhdr_t *sctp_chunk_lookup_strreset_param(
 		 */
 		struct sctp_strreset_tsnreq *req = param.v;
 
-		if (req->request_seq == resp_seq)
+		if ((!resp_seq || req->request_seq == resp_seq) &&
+		    (!type || type == req->param_hdr.type))
 			return param.v;
 	}
 
@@ -361,13 +363,9 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 		goto out;
 
 	if (asoc->strreset_chunk) {
-		sctp_paramhdr_t *param_hdr;
-		struct sctp_transport *t;
-
-		param_hdr = sctp_chunk_lookup_strreset_param(
-					asoc, outreq->response_seq);
-		if (!param_hdr || param_hdr->type !=
-					SCTP_PARAM_RESET_IN_REQUEST) {
+		if (!sctp_chunk_lookup_strreset_param(
+				asoc, outreq->response_seq,
+				SCTP_PARAM_RESET_IN_REQUEST)) {
 			/* same process with outstanding isn't 0 */
 			result = SCTP_STRRESET_ERR_IN_PROGRESS;
 			goto out;
@@ -377,6 +375,8 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 		asoc->strreset_outseq++;
 
 		if (!asoc->strreset_outstanding) {
+			struct sctp_transport *t;
+
 			t = asoc->strreset_chunk->transport;
 			if (del_timer(&t->reconf_timer))
 				sctp_transport_put(t);
@@ -556,3 +556,72 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 	return sctp_make_strreset_tsnresp(asoc, result, request_seq,
 					  next_tsn, init_tsn);
 }
+
+struct sctp_chunk *sctp_process_strreset_addstrm_out(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_addstrm *addstrm = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	__u32 result = SCTP_STRRESET_DENIED;
+	struct sctp_stream_in *streamin;
+	__u32 request_seq, incnt;
+	__u16 in;
+
+	request_seq = ntohl(addstrm->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ))
+		goto out;
+
+	if (asoc->strreset_chunk) {
+		if (!sctp_chunk_lookup_strreset_param(
+			asoc, 0, SCTP_PARAM_RESET_ADD_IN_STREAMS)) {
+			/* same process with outstanding isn't 0 */
+			result = SCTP_STRRESET_ERR_IN_PROGRESS;
+			goto out;
+		}
+
+		asoc->strreset_outstanding--;
+		asoc->strreset_outseq++;
+
+		if (!asoc->strreset_outstanding) {
+			struct sctp_transport *t;
+
+			t = asoc->strreset_chunk->transport;
+			if (del_timer(&t->reconf_timer))
+				sctp_transport_put(t);
+
+			sctp_chunk_put(asoc->strreset_chunk);
+			asoc->strreset_chunk = NULL;
+		}
+	}
+
+	in = ntohs(addstrm->number_of_streams);
+	incnt = stream->incnt + in;
+	if (!in || incnt > SCTP_MAX_STREAM)
+		goto out;
+
+	streamin = krealloc(stream->in, incnt * sizeof(*streamin),
+			    GFP_ATOMIC);
+	if (!streamin)
+		goto out;
+
+	memset(streamin + stream->incnt, 0, in * sizeof(*streamin));
+	stream->in = streamin;
+	stream->incnt = incnt;
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_stream_change_event(asoc,
+		0, ntohs(addstrm->number_of_streams), 0, GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_resp(asoc, result, request_seq);
+}
-- 
2.1.0
