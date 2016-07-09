From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 4/6] sctp: implement prsctp TTL policy
Date: Sat,  9 Jul 2016 19:47:43 +0800
Message-ID: <bb59be49cce6ce873c75e43f1ba8f772dd5eed58.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
 <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
 <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
 <63a9a850836134ba72b9377e8b99694d869e3fba.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36532 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932850AbcGILsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:48:11 -0400
In-Reply-To: <63a9a850836134ba72b9377e8b99694d869e3fba.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prsctp TTL policy is a policy to abandon chunks when they expire
at the specific time in local stack. It's similar with expires_at
in struct sctp_datamsg.

This patch uses sinfo->sinfo_timetolive to set the specific time for
TTL policy. sinfo->sinfo_timetolive is also used for msg->expires_at.
So if prsctp_enable or TTL policy is not enabled, msg->expires_at
still works as before.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 10 ++++++++++
 net/sctp/chunk.c           | 20 +++++++++++++++++---
 net/sctp/output.c          |  2 ++
 net/sctp/sm_make_chunk.c   | 12 ++++++++++++
 net/sctp/socket.c          |  4 ++--
 5 files changed, 43 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index d8e464a..6bcda71 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -602,6 +602,16 @@ struct sctp_chunk {
 	/* This needs to be recoverable for SCTP_SEND_FAILED events. */
 	struct sctp_sndrcvinfo sinfo;
 
+	/* We use this field to record param for prsctp policies,
+	 * for TTL policy, it is the time_to_drop of this chunk,
+	 * for RTX policy, it is the max_sent_count of this chunk,
+	 * for PRIO policy, it is the priority of this chunk.
+	 */
+	unsigned long prsctp_param;
+
+	/* How many times this chunk have been sent, for prsctp RTX policy */
+	int sent_count;
+
 	/* Which association does this belong to?  */
 	struct sctp_association *asoc;
 
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 1eb94bf..2698d12 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -335,13 +335,27 @@ errout:
 /* Check whether this message has expired. */
 int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 {
-	struct sctp_datamsg *msg = chunk->msg;
+	if (!chunk->asoc->prsctp_enable ||
+	    !SCTP_PR_POLICY(chunk->sinfo.sinfo_flags)) {
+		struct sctp_datamsg *msg = chunk->msg;
+
+		if (!msg->can_abandon)
+			return 0;
+
+		if (time_after(jiffies, msg->expires_at))
+			return 1;
 
-	if (!msg->can_abandon)
 		return 0;
+	}
 
-	if (time_after(jiffies, msg->expires_at))
+	if (SCTP_PR_TTL_ENABLED(chunk->sinfo.sinfo_flags) &&
+	    time_after(jiffies, chunk->prsctp_param)) {
+		if (chunk->sent_count)
+			chunk->asoc->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
+		else
+			chunk->asoc->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
 		return 1;
+	}
 
 	return 0;
 }
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 2e9223b..7425f6c 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -316,6 +316,8 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 		packet->has_data = 1;
 		/* timestamp the chunk for rtx purposes */
 		chunk->sent_at = jiffies;
+		/* Mainly used for prsctp RTX policy */
+		chunk->sent_count++;
 		break;
 	case SCTP_CID_COOKIE_ECHO:
 		packet->has_cookie_echo = 1;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0e3045e..2c431ee 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -711,6 +711,17 @@ nodata:
 	return retval;
 }
 
+static void sctp_set_prsctp_policy(struct sctp_chunk *chunk,
+				   const struct sctp_sndrcvinfo *sinfo)
+{
+	if (!chunk->asoc->prsctp_enable)
+		return;
+
+	if (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
+		chunk->prsctp_param =
+			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
+}
+
 /* Make a DATA chunk for the given association from the provided
  * parameters.  However, do not populate the data payload.
  */
@@ -744,6 +755,7 @@ struct sctp_chunk *sctp_make_datafrag_empty(struct sctp_association *asoc,
 
 	retval->subh.data_hdr = sctp_addto_chunk(retval, sizeof(dp), &dp);
 	memcpy(&retval->sinfo, sinfo, sizeof(struct sctp_sndrcvinfo));
+	sctp_set_prsctp_policy(retval, sinfo);
 
 nodata:
 	return retval;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c3167c4..0861429 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7099,7 +7099,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 
 			if (cmsgs->srinfo->sinfo_flags &
 			    ~(SCTP_UNORDERED | SCTP_ADDR_OVER |
-			      SCTP_SACK_IMMEDIATELY |
+			      SCTP_SACK_IMMEDIATELY | SCTP_PR_SCTP_MASK |
 			      SCTP_ABORT | SCTP_EOF))
 				return -EINVAL;
 			break;
@@ -7123,7 +7123,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 
 			if (cmsgs->sinfo->snd_flags &
 			    ~(SCTP_UNORDERED | SCTP_ADDR_OVER |
-			      SCTP_SACK_IMMEDIATELY |
+			      SCTP_SACK_IMMEDIATELY | SCTP_PR_SCTP_MASK |
 			      SCTP_ABORT | SCTP_EOF))
 				return -EINVAL;
 			break;
-- 
2.1.0
