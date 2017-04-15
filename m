From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/3] sctp: process duplicated strreset out and addstrm out requests correctly
Date: Sat, 15 Apr 2017 22:00:27 +0800
Message-ID: <a636da822b3db12479ce67e3976f43e2bc998517.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34930 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbdDOOAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 10:00:46 -0400
In-Reply-To: <cover.1492264734.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp stream reconf will process a request again even if it's seqno is
less than asoc->strreset_inseq.

If one request has been done successfully and some data chunks have been
accepted and then a duplicated strreset out request comes, the streamin's
ssn will be cleared. It will cause that stream will never receive chunks
any more because of unsynchronized ssn. It allows a replay attack.

A similar issue also exists when processing addstrm out requests. It will
cause more extra streams being added.

This patch is to fix it by saving the last 2 results into asoc. When a
duplicated strreset out or addstrm out request is received, reply it with
bad seqno if it's seqno < asoc->strreset_inseq - 2, and reply it with the
result saved in asoc if it's seqno >= asoc->strreset_inseq - 2.

Note that it saves last 2 results instead of only last 1 result, because
two requests can be sent together in one chunk.

And note that when receiving a duplicated request, the receiver side will
still reply it even if the peer has received the response. It's safe, As
the response will be dropped by the peer.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  1 +
 net/sctp/stream.c          | 39 +++++++++++++++++++++++++++++----------
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index b751399..a8b38e1 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1889,6 +1889,7 @@ struct sctp_association {
 
 	__u32 strreset_outseq; /* Update after receiving response */
 	__u32 strreset_inseq; /* Update after receiving request */
+	__u32 strreset_result[2]; /* save the results of last 2 responses */
 
 	struct sctp_chunk *strreset_chunk; /* save request chunk */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 4ec3679..6cab7c3 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -344,6 +344,13 @@ static sctp_paramhdr_t *sctp_chunk_lookup_strreset_param(
 	return NULL;
 }
 
+static void sctp_update_strreset_result(struct sctp_association *asoc,
+					__u32 result)
+{
+	asoc->strreset_result[1] = asoc->strreset_result[0];
+	asoc->strreset_result[0] = result;
+}
+
 struct sctp_chunk *sctp_process_strreset_outreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
@@ -360,15 +367,19 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 	if (ntohl(outreq->send_reset_at_tsn) >
 	    sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)) {
 		result = SCTP_STRRESET_IN_PROGRESS;
-		goto out;
+		goto err;
 	}
 
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
+		goto err;
 	}
+	asoc->strreset_inseq++;
 
 	/* Check strreset_enable after inseq inc, as sender cannot tell
 	 * the peer doesn't enable strreset after receiving response with
@@ -427,6 +438,8 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 		GFP_ATOMIC);
 
 out:
+	sctp_update_strreset_result(asoc, result);
+err:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
 
@@ -582,15 +595,19 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 	__u32 result = SCTP_STRRESET_DENIED;
 	struct sctp_stream_in *streamin;
 	__u32 request_seq, incnt;
-	__u16 in;
+	__u16 in, i;
 
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
+		goto err;
 	}
+	asoc->strreset_inseq++;
 
 	if (!(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ))
 		goto out;
@@ -638,6 +655,8 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 		0, ntohs(addstrm->number_of_streams), 0, GFP_ATOMIC);
 
 out:
+	sctp_update_strreset_result(asoc, result);
+err:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
 
-- 
2.1.0
