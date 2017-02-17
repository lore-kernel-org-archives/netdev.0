From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 4/7] sctp: implement receiver-side procedures for the Incoming SSN Reset Request Parameter
Date: Fri, 17 Feb 2017 12:45:40 +0800
Message-ID: <3b70615422bf6d43013332d4b37c70160a0c1d32.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
 <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
 <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35073 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932202AbdBQEqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:25 -0500
In-Reply-To: <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Incoming
SSN Reset Request Parameter described in rfc6525 section 5.2.3.

It's also to move str_list endian conversion out of sctp_make_strreset_req,
so that sctp_make_strreset_req can be used more conveniently to process
inreq.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h    |  4 +++
 net/sctp/sm_make_chunk.c |  8 +-----
 net/sctp/stream.c        | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index c0f9bea..f6a828d 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -285,6 +285,10 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_inreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9680c58..60d9fdc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3617,7 +3617,7 @@ struct sctp_chunk *sctp_make_strreset_req(
 	__u16 stream_len = stream_num * 2;
 	struct sctp_strreset_inreq inreq;
 	struct sctp_chunk *retval;
-	__u16 outlen, inlen, i;
+	__u16 outlen, inlen;
 
 	outlen = (sizeof(outreq) + stream_len) * out;
 	inlen = (sizeof(inreq) + stream_len) * in;
@@ -3626,9 +3626,6 @@ struct sctp_chunk *sctp_make_strreset_req(
 	if (!retval)
 		return NULL;
 
-	for (i = 0; i < stream_num; i++)
-		stream_list[i] = htons(stream_list[i]);
-
 	if (outlen) {
 		outreq.param_hdr.type = SCTP_PARAM_RESET_OUT_REQUEST;
 		outreq.param_hdr.length = htons(outlen);
@@ -3653,9 +3650,6 @@ struct sctp_chunk *sctp_make_strreset_req(
 			sctp_addto_chunk(retval, stream_len, stream_list);
 	}
 
-	for (i = 0; i < stream_num; i++)
-		stream_list[i] = ntohs(stream_list[i]);
-
 	return retval;
 }
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 531fcc4..1c6cc04 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -135,7 +135,14 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 			if (str_list[i] >= stream->incnt)
 				goto out;
 
+	for (i = 0; i < str_nums; i++)
+		str_list[i] = htons(str_list[i]);
+
 	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
+
+	for (i = 0; i < str_nums; i++)
+		str_list[i] = ntohs(str_list[i]);
+
 	if (!chunk) {
 		retval = -ENOMEM;
 		goto out;
@@ -407,3 +414,66 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 out:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
+
+struct sctp_chunk *sctp_process_strreset_inreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_inreq *inreq = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	__u32 result = SCTP_STRRESET_DENIED;
+	struct sctp_chunk *chunk = NULL;
+	__u16 i, nums, *str_p;
+	__u32 request_seq;
+
+	request_seq = ntohl(inreq->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
+		goto out;
+
+	if (asoc->strreset_outstanding) {
+		result = SCTP_STRRESET_ERR_IN_PROGRESS;
+		goto out;
+	}
+
+	nums = (ntohs(param.p->length) - sizeof(*inreq)) / 2;
+	str_p = inreq->list_of_streams;
+	for (i = 0; i < nums; i++) {
+		if (ntohs(str_p[i]) >= stream->outcnt) {
+			result = SCTP_STRRESET_ERR_WRONG_SSN;
+			goto out;
+		}
+	}
+
+	chunk = sctp_make_strreset_req(asoc, nums, str_p, 1, 0);
+	if (!chunk)
+		goto out;
+
+	if (nums)
+		for (i = 0; i < nums; i++)
+			stream->out[ntohs(str_p[i])].state =
+					       SCTP_STREAM_CLOSED;
+	else
+		for (i = 0; i < stream->outcnt; i++)
+			stream->out[i].state = SCTP_STREAM_CLOSED;
+
+	asoc->strreset_chunk = chunk;
+	asoc->strreset_outstanding = 1;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	*evp = sctp_ulpevent_make_stream_reset_event(asoc,
+		SCTP_STREAM_RESET_INCOMING_SSN, nums, str_p, GFP_ATOMIC);
+
+out:
+	if (!chunk)
+		chunk =  sctp_make_strreset_resp(asoc, result, request_seq);
+
+	return chunk;
+}
-- 
2.1.0
