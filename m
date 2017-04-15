From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 3/3] sctp: process duplicated strreset asoc request correctly
Date: Sat, 15 Apr 2017 22:00:29 +0800
Message-ID: <e6876cd61324e504915309b2801ed136fe50f9f3.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
 <a636da822b3db12479ce67e3976f43e2bc998517.1492264734.git.lucien.xin@gmail.com>
 <d66876c7fc8ad4b236f2c44dc5b624bff2fd1299.1492264734.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36749 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753827AbdDOOBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 10:01:02 -0400
In-Reply-To: <d66876c7fc8ad4b236f2c44dc5b624bff2fd1299.1492264734.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1492264734.git.lucien.xin@gmail.com>
References: <cover.1492264734.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the replay attack issue for strreset asoc requests.

When a duplicated strreset asoc request is received, reply it with bad
seqno if it's seqno < asoc->strreset_inseq - 2, and reply it with the
result saved in asoc if it's seqno >= asoc->strreset_inseq - 2.

But note that if the result saved in asoc is performed, the sender's next
tsn and receiver's next tsn for the response chunk should be set. It's
safe to get them from asoc. Because if it's changed, which means the peer
has received the response already, the new response with wrong tsn won't
be accepted by peer.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/stream.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index c91d97e..dda53a2 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -529,12 +529,21 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 	__u16 i;
 
 	request_seq = ntohl(tsnreq->request_seq);
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
+		if (result == SCTP_STRRESET_PERFORMED) {
+			next_tsn = asoc->next_tsn;
+			init_tsn =
+				sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + 1;
+		}
+		goto err;
 	}
+	asoc->strreset_inseq++;
 
 	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
 		goto out;
@@ -591,6 +600,8 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 						    next_tsn, GFP_ATOMIC);
 
 out:
+	sctp_update_strreset_result(asoc, result);
+err:
 	return sctp_make_strreset_tsnresp(asoc, result, request_seq,
 					  next_tsn, init_tsn);
 }
-- 
2.1.0
