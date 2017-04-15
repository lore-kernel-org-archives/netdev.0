From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/3] sctp: process duplicated strreset in and addstrm in requests correctly
Date: Sat, 15 Apr 2017 22:00:28 +0800
Message-ID: <d66876c7fc8ad4b236f2c44dc5b624bff2fd1299.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
 <a636da822b3db12479ce67e3976f43e2bc998517.1492264734.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34318 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdDOOAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 10:00:54 -0400
In-Reply-To: <a636da822b3db12479ce67e3976f43e2bc998517.1492264734.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the replay attack issue for strreset and addstrm in
requests.

When a duplicated strreset in or addstrm in request is received, reply it
with bad seqno if it's seqno < asoc->strreset_inseq - 2, and reply it with
the result saved in asoc if it's seqno >= asoc->strreset_inseq - 2.

For strreset in or addstrm in request, if the receiver side processes it
successfully, a strreset out or addstrm out request(as a response for that
request) will be sent back to peer. reconf_time will retransmit the out
request even if it's lost.

So when receiving a duplicated strreset in or addstrm in request and it's
result was performed, it shouldn't reply this request, but drop it instead.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/stream.c | 38 +++++++++++++++++++++++++++++---------
 1 file changed, 29 insertions(+), 9 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 6cab7c3..c91d97e 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -456,12 +456,18 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 	__u32 request_seq;
 
 	request_seq = ntohl(inreq->request_seq);
-	if (request_seq > asoc->strreset_inseq) {
+	if (TSN_lt(asoc->strreset_inseq, request_seq) ||
+	    TSN_lt(request_seq, asoc->strreset_inseq - 2)) {
 		result = SCTP_STRRESET_ERR_BAD_SEQNO;
-		goto out;
-	} else if (request_seq == asoc->strreset_inseq) {
-		asoc->strreset_inseq++;
+		goto err;
+	} else if (TSN_lt(request_seq, asoc->strreset_inseq)) {
+		i = asoc->strreset_inseq - request_seq - 1;
+		result = asoc->strreset_result[i];
+		if (result == SCTP_STRRESET_PERFORMED)
+			return NULL;
+		goto err;
 	}
+	asoc->strreset_inseq++;
 
 	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
 		goto out;
@@ -496,10 +502,14 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 	asoc->strreset_outstanding = 1;
 	sctp_chunk_hold(asoc->strreset_chunk);
 
+	result = SCTP_STRRESET_PERFORMED;
+
 	*evp = sctp_ulpevent_make_stream_reset_event(asoc,
 		SCTP_STREAM_RESET_INCOMING_SSN, nums, str_p, GFP_ATOMIC);
 
 out:
+	sctp_update_strreset_result(asoc, result);
+err:
 	if (!chunk)
 		chunk =  sctp_make_strreset_resp(asoc, result, request_seq);
 
@@ -671,15 +681,21 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 	struct sctp_stream_out *streamout;
 	struct sctp_chunk *chunk = NULL;
 	__u32 request_seq, outcnt;
-	__u16 out;
+	__u16 out, i;
 
 	request_seq = ntohl(addstrm->request_seq);
-	if (request_seq > asoc->strreset_inseq) {
+	if (TSN_lt(asoc->strreset_inseq, request_seq) ||
+	    TSN_lt(request_seq, asoc->strreset_inseq - 2)) {
 		result = SCTP_STRRESET_ERR_BAD_SEQNO;
-		goto out;
-	} else if (request_seq == asoc->strreset_inseq) {
-		asoc->strreset_inseq++;
+		goto err;
+	} else if (TSN_lt(request_seq, asoc->strreset_inseq)) {
+		i = asoc->strreset_inseq - request_seq - 1;
+		result = asoc->strreset_result[i];
+		if (result == SCTP_STRRESET_PERFORMED)
+			return NULL;
+		goto err;
 	}
+	asoc->strreset_inseq++;
 
 	if (!(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ))
 		goto out;
@@ -712,10 +728,14 @@ struct sctp_chunk *sctp_process_strreset_addstrm_in(
 
 	stream->outcnt = outcnt;
 
+	result = SCTP_STRRESET_PERFORMED;
+
 	*evp = sctp_ulpevent_make_stream_change_event(asoc,
 		0, 0, ntohs(addstrm->number_of_streams), GFP_ATOMIC);
 
 out:
+	sctp_update_strreset_result(asoc, result);
+err:
 	if (!chunk)
 		chunk = sctp_make_strreset_resp(asoc, result, request_seq);
 
-- 
2.1.0
