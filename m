From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 4/5] sctp: change to check peer prsctp_capable when using prsctp polices
Date: Wed, 28 Sep 2016 18:46:31 +0800
Message-ID: <7a83f44a517780fd7bc60caa49479fbc7e606936.1475059350.git.lucien.xin@gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com>
 <03a642a76d02e8536404aa27561c44e348f3e3a0.1475059350.git.lucien.xin@gmail.com>
 <ca37ab66bfd8b97078ff8e3645bc7c1e909396e8.1475059350.git.lucien.xin@gmail.com>
 <da30a54fd8b6674e6cf6f013a3633d59aaeea020.1475059350.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36631 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753080AbcI1Kqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:46:51 -0400
In-Reply-To: <da30a54fd8b6674e6cf6f013a3633d59aaeea020.1475059350.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1475059350.git.lucien.xin@gmail.com>
References: <cover.1475059350.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now before using prsctp polices, sctp uses asoc->prsctp_enable to
check if prsctp is enabled. However asoc->prsctp_enable is set only
means local host support prsctp, sctp should not abandon packet if
peer host doesn't enable prsctp.

So this patch is to use asoc->peer.prsctp_capable to check if prsctp
is enabled on both side, instead of asoc->prsctp_enable, as asoc's
peer.prsctp_capable is set only when local and peer both enable prsctp.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/chunk.c    | 4 ++--
 net/sctp/outqueue.c | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 14990e2..0a3dbec 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -179,7 +179,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			 msg, msg->expires_at, jiffies);
 	}
 
-	if (asoc->prsctp_enable &&
+	if (asoc->peer.prsctp_capable &&
 	    SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
 		msg->expires_at =
 			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
@@ -340,7 +340,7 @@ errout:
 /* Check whether this message has expired. */
 int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 {
-	if (!chunk->asoc->prsctp_enable ||
+	if (!chunk->asoc->peer.prsctp_capable ||
 	    !SCTP_PR_POLICY(chunk->sinfo.sinfo_flags)) {
 		struct sctp_datamsg *msg = chunk->msg;
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 17b6fcd..70d45c3e 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -326,7 +326,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 
 			sctp_chunk_hold(chunk);
 			sctp_outq_tail_data(q, chunk);
-			if (chunk->asoc->prsctp_enable &&
+			if (chunk->asoc->peer.prsctp_capable &&
 			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
 				chunk->asoc->sent_cnt_removable++;
 			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
@@ -442,7 +442,7 @@ void sctp_prsctp_prune(struct sctp_association *asoc,
 {
 	struct sctp_transport *transport;
 
-	if (!asoc->prsctp_enable || !asoc->sent_cnt_removable)
+	if (!asoc->peer.prsctp_capable || !asoc->sent_cnt_removable)
 		return;
 
 	msg_len = sctp_prsctp_prune_sent(asoc, sinfo,
@@ -1053,7 +1053,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 
 				/* Mark as failed send. */
 				sctp_chunk_fail(chunk, SCTP_ERROR_INV_STRM);
-				if (asoc->prsctp_enable &&
+				if (asoc->peer.prsctp_capable &&
 				    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
 					asoc->sent_cnt_removable--;
 				sctp_chunk_free(chunk);
@@ -1345,7 +1345,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 		tsn = ntohl(tchunk->subh.data_hdr->tsn);
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(&tchunk->transmitted_list);
-			if (asoc->prsctp_enable &&
+			if (asoc->peer.prsctp_capable &&
 			    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
 				asoc->sent_cnt_removable--;
 			sctp_chunk_free(tchunk);
-- 
2.1.0
