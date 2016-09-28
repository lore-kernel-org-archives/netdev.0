From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net 2/3] sctp: remove prsctp_param from sctp_chunk
Date: Thu, 29 Sep 2016 02:37:27 +0800
Message-ID: <0c3d4e6034f7f77fd341cf5baf116bc91a43bdf8.1475087147.git.lucien.xin@gmail.com>
References: <cover.1475087147.git.lucien.xin@gmail.com>
 <03a642a76d02e8536404aa27561c44e348f3e3a0.1475087147.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36793 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754452AbcI1Shk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 14:37:40 -0400
In-Reply-To: <03a642a76d02e8536404aa27561c44e348f3e3a0.1475087147.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1475087147.git.lucien.xin@gmail.com>
References: <cover.1475087147.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp uses chunk->prsctp_param to save the prsctp param for all the
prsctp polices, we didn't need to introduce prsctp_param to sctp_chunk.
We can just use chunk->sinfo.sinfo_timetolive for RTX and BUF polices,
and reuse msg->expires_at for TTL policy, as the prsctp polices and old
expires policy are mutual exclusive.

This patch is to remove prsctp_param from sctp_chunk, and reuse msg's
expires_at for TTL and chunk's sinfo.sinfo_timetolive for RTX and BUF
polices.

Note that sctp can't use chunk's sinfo.sinfo_timetolive for TTL policy,
as it needs a u64 variables to save the expires_at time.

This one also fixes the "netperf-Throughput_Mbps -37.2% regression"
issue.

Fixes: a6c2f792873a ("sctp: implement prsctp TTL policy")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  7 -------
 net/sctp/chunk.c           |  9 +++++++--
 net/sctp/outqueue.c        |  4 ++--
 net/sctp/sm_make_chunk.c   | 15 ---------------
 4 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4f097f5..ced0df3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -606,13 +606,6 @@ struct sctp_chunk {
 	/* This needs to be recoverable for SCTP_SEND_FAILED events. */
 	struct sctp_sndrcvinfo sinfo;
 
-	/* We use this field to record param for prsctp policies,
-	 * for TTL policy, it is the time_to_drop of this chunk,
-	 * for RTX policy, it is the max_sent_count of this chunk,
-	 * for PRIO policy, it is the priority of this chunk.
-	 */
-	unsigned long prsctp_param;
-
 	/* Which association does this belong to?  */
 	struct sctp_association *asoc;
 
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a55e547..14990e2 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -179,6 +179,11 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			 msg, msg->expires_at, jiffies);
 	}
 
+	if (asoc->prsctp_enable &&
+	    SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
+		msg->expires_at =
+			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
+
 	/* This is the biggest possible DATA chunk that can fit into
 	 * the packet
 	 */
@@ -349,14 +354,14 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 	}
 
 	if (SCTP_PR_TTL_ENABLED(chunk->sinfo.sinfo_flags) &&
-	    time_after(jiffies, chunk->prsctp_param)) {
+	    time_after(jiffies, chunk->msg->expires_at)) {
 		if (chunk->sent_count)
 			chunk->asoc->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
 		else
 			chunk->asoc->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
 		return 1;
 	} else if (SCTP_PR_RTX_ENABLED(chunk->sinfo.sinfo_flags) &&
-		   chunk->sent_count > chunk->prsctp_param) {
+		   chunk->sent_count > chunk->sinfo.sinfo_timetolive) {
 		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
 		return 1;
 	}
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 72e54a4..e084f35 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -383,7 +383,7 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
 
 	list_for_each_entry_safe(chk, temp, queue, transmitted_list) {
 		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
-		    chk->prsctp_param <= sinfo->sinfo_timetolive)
+		    chk->sinfo.sinfo_timetolive <= sinfo->sinfo_timetolive)
 			continue;
 
 		list_del_init(&chk->transmitted_list);
@@ -418,7 +418,7 @@ static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
 
 	list_for_each_entry_safe(chk, temp, queue, list) {
 		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
-		    chk->prsctp_param <= sinfo->sinfo_timetolive)
+		    chk->sinfo.sinfo_timetolive <= sinfo->sinfo_timetolive)
 			continue;
 
 		list_del_init(&chk->list);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8c77b87..46ffecc 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -706,20 +706,6 @@ nodata:
 	return retval;
 }
 
-static void sctp_set_prsctp_policy(struct sctp_chunk *chunk,
-				   const struct sctp_sndrcvinfo *sinfo)
-{
-	if (!chunk->asoc->prsctp_enable)
-		return;
-
-	if (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
-		chunk->prsctp_param =
-			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
-	else if (SCTP_PR_RTX_ENABLED(sinfo->sinfo_flags) ||
-		 SCTP_PR_PRIO_ENABLED(sinfo->sinfo_flags))
-		chunk->prsctp_param = sinfo->sinfo_timetolive;
-}
-
 /* Make a DATA chunk for the given association from the provided
  * parameters.  However, do not populate the data payload.
  */
@@ -753,7 +739,6 @@ struct sctp_chunk *sctp_make_datafrag_empty(struct sctp_association *asoc,
 
 	retval->subh.data_hdr = sctp_addto_chunk(retval, sizeof(dp), &dp);
 	memcpy(&retval->sinfo, sinfo, sizeof(struct sctp_sndrcvinfo));
-	sctp_set_prsctp_policy(retval, sinfo);
 
 nodata:
 	return retval;
-- 
2.1.0
