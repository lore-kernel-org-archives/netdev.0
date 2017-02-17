From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/7] sctp: implement receiver-side procedures for the Outgoing SSN Reset Request Parameter
Date: Fri, 17 Feb 2017 12:45:39 +0800
Message-ID: <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
 <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35933 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbdBQEq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:27 -0500
In-Reply-To: <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Outgoing
SSN Reset Request Parameter described in rfc6525 section 5.2.2.

Note that some checks must be after request_seq check, as even those
checks fail, strreset_inseq still has to be increase by 1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |   6 +++
 net/sctp/stream.c     | 113 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 119 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 8a85dd7..c0f9bea 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -280,6 +280,12 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
+/* Prototypes for stream-processing functions.  */
+struct sctp_chunk *sctp_process_strreset_outreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
+
 /* Prototypes for statetable processing. */
 
 int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index eb02490..531fcc4 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -294,3 +294,116 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 out:
 	return retval;
 }
+
+static sctp_paramhdr_t *sctp_chunk_lookup_strreset_param(
+			struct sctp_association *asoc, __u32 resp_seq)
+{
+	struct sctp_chunk *chunk = asoc->strreset_chunk;
+	struct sctp_reconf_chunk *hdr;
+	union sctp_params param;
+
+	if (ntohl(resp_seq) != asoc->strreset_outseq || !chunk)
+		return NULL;
+
+	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
+	sctp_walk_params(param, hdr, params) {
+		/* sctp_strreset_tsnreq is actually the basic structure
+		 * of all stream reconf params, so it's safe to use it
+		 * to access request_seq.
+		 */
+		struct sctp_strreset_tsnreq *req = param.v;
+
+		if (req->request_seq == resp_seq)
+			return param.v;
+	}
+
+	return NULL;
+}
+
+struct sctp_chunk *sctp_process_strreset_outreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_outreq *outreq = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	__u16 i, nums, flags = 0, *str_p = NULL;
+	__u32 result = SCTP_STRRESET_DENIED;
+	__u32 request_seq;
+
+	request_seq = ntohl(outreq->request_seq);
+
+	if (ntohl(outreq->send_reset_at_tsn) >
+	    sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)) {
+		result = SCTP_STRRESET_IN_PROGRESS;
+		goto out;
+	}
+
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	/* Check strreset_enable after inseq inc, as sender cannot tell
+	 * the peer doesn't enable strreset after receiving response with
+	 * result denied, as well as to keep consistent with bsd.
+	 */
+	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
+		goto out;
+
+	if (asoc->strreset_chunk) {
+		sctp_paramhdr_t *param_hdr;
+		struct sctp_transport *t;
+
+		param_hdr = sctp_chunk_lookup_strreset_param(
+					asoc, outreq->response_seq);
+		if (!param_hdr || param_hdr->type !=
+					SCTP_PARAM_RESET_IN_REQUEST) {
+			/* same process with outstanding isn't 0 */
+			result = SCTP_STRRESET_ERR_IN_PROGRESS;
+			goto out;
+		}
+
+		asoc->strreset_outstanding--;
+		asoc->strreset_outseq++;
+
+		if (!asoc->strreset_outstanding) {
+			t = asoc->strreset_chunk->transport;
+			if (del_timer(&t->reconf_timer))
+				sctp_transport_put(t);
+
+			sctp_chunk_put(asoc->strreset_chunk);
+			asoc->strreset_chunk = NULL;
+		}
+
+		flags = SCTP_STREAM_RESET_INCOMING_SSN;
+	}
+
+	nums = (ntohs(param.p->length) - sizeof(*outreq)) / 2;
+	if (nums) {
+		str_p = outreq->list_of_streams;
+		for (i = 0; i < nums; i++) {
+			if (ntohs(str_p[i]) >= stream->incnt) {
+				result = SCTP_STRRESET_ERR_WRONG_SSN;
+				goto out;
+			}
+		}
+
+		for (i = 0; i < nums; i++)
+			stream->in[ntohs(str_p[i])].ssn = 0;
+	} else {
+		for (i = 0; i < stream->incnt; i++)
+			stream->in[i].ssn = 0;
+	}
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_stream_reset_event(asoc,
+		flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
+		GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_resp(asoc, result, request_seq);
+}
-- 
2.1.0
