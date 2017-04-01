From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next] sctp: add SCTP_PR_STREAM_STATUS sockopt for prsctp
Date: Sat,  1 Apr 2017 17:07:46 +0800
Message-ID: <0618a2ca7e92ebdfc0953c38da2f727b8b270090.1491037666.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34426 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdDAJHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 05:07:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before when implementing sctp prsctp, SCTP_PR_STREAM_STATUS wasn't
added, as it needs to save abandoned_(un)sent for every stream.

After sctp stream reconf is added in sctp, assoc has structure
sctp_stream_out to save per stream info.

This patch is to add SCTP_PR_STREAM_STATUS by putting the prsctp
per stream statistics into sctp_stream_out.

v1->v2:
  fix an indent issue.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  2 ++
 include/uapi/linux/sctp.h  |  1 +
 net/sctp/chunk.c           | 14 +++++++++--
 net/sctp/outqueue.c        | 10 ++++++++
 net/sctp/socket.c          | 59 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 592dece..3e61a54 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1315,6 +1315,8 @@ struct sctp_inithdr_host {
 struct sctp_stream_out {
 	__u16	ssn;
 	__u8	state;
+	__u64	abandoned_unsent[SCTP_PR_INDEX(MAX) + 1];
+	__u64	abandoned_sent[SCTP_PR_INDEX(MAX) + 1];
 };
 
 struct sctp_stream_in {
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 7212870..ced9d8b 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -115,6 +115,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_SUPPORTED	113
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
+#define SCTP_PR_STREAM_STATUS	116
 #define SCTP_RECONFIG_SUPPORTED	117
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index e3621cb..697721a 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -306,14 +306,24 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 
 	if (SCTP_PR_TTL_ENABLED(chunk->sinfo.sinfo_flags) &&
 	    time_after(jiffies, chunk->msg->expires_at)) {
-		if (chunk->sent_count)
+		struct sctp_stream_out *streamout =
+			&chunk->asoc->stream->out[chunk->sinfo.sinfo_stream];
+
+		if (chunk->sent_count) {
 			chunk->asoc->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
-		else
+			streamout->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
+		} else {
 			chunk->asoc->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
+			streamout->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
+		}
 		return 1;
 	} else if (SCTP_PR_RTX_ENABLED(chunk->sinfo.sinfo_flags) &&
 		   chunk->sent_count > chunk->sinfo.sinfo_timetolive) {
+		struct sctp_stream_out *streamout =
+			&chunk->asoc->stream->out[chunk->sinfo.sinfo_stream];
+
 		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
+		streamout->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
 		return 1;
 	} else if (!SCTP_PR_POLICY(chunk->sinfo.sinfo_flags) &&
 		   chunk->msg->expires_at &&
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 025ccff..3f78d7f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -353,6 +353,8 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
 	struct sctp_chunk *chk, *temp;
 
 	list_for_each_entry_safe(chk, temp, queue, transmitted_list) {
+		struct sctp_stream_out *streamout;
+
 		if (!SCTP_PR_PRIO_ENABLED(chk->sinfo.sinfo_flags) ||
 		    chk->sinfo.sinfo_timetolive <= sinfo->sinfo_timetolive)
 			continue;
@@ -361,8 +363,10 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
 		sctp_insert_list(&asoc->outqueue.abandoned,
 				 &chk->transmitted_list);
 
+		streamout = &asoc->stream->out[chk->sinfo.sinfo_stream];
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
+		streamout->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
 
 		if (!chk->tsn_gap_acked) {
 			if (chk->transport)
@@ -396,6 +400,12 @@ static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
 		q->out_qlen -= chk->skb->len;
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
+		if (chk->sinfo.sinfo_stream < asoc->stream->outcnt) {
+			struct sctp_stream_out *streamout =
+				&asoc->stream->out[chk->sinfo.sinfo_stream];
+
+			streamout->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
+		}
 
 		msg_len -= SCTP_DATA_SNDSIZE(chk) +
 			   sizeof(struct sk_buff) +
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ccc08fc..6489446 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6576,6 +6576,61 @@ static int sctp_getsockopt_pr_assocstatus(struct sock *sk, int len,
 	return retval;
 }
 
+static int sctp_getsockopt_pr_streamstatus(struct sock *sk, int len,
+					   char __user *optval,
+					   int __user *optlen)
+{
+	struct sctp_stream_out *streamout;
+	struct sctp_association *asoc;
+	struct sctp_prstatus params;
+	int retval = -EINVAL;
+	int policy;
+
+	if (len < sizeof(params))
+		goto out;
+
+	len = sizeof(params);
+	if (copy_from_user(&params, optval, len)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	policy = params.sprstat_policy;
+	if (policy & ~SCTP_PR_SCTP_MASK)
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.sprstat_assoc_id);
+	if (!asoc || params.sprstat_sid >= asoc->stream->outcnt)
+		goto out;
+
+	streamout = &asoc->stream->out[params.sprstat_sid];
+	if (policy == SCTP_PR_SCTP_NONE) {
+		params.sprstat_abandoned_unsent = 0;
+		params.sprstat_abandoned_sent = 0;
+		for (policy = 0; policy <= SCTP_PR_INDEX(MAX); policy++) {
+			params.sprstat_abandoned_unsent +=
+				streamout->abandoned_unsent[policy];
+			params.sprstat_abandoned_sent +=
+				streamout->abandoned_sent[policy];
+		}
+	} else {
+		params.sprstat_abandoned_unsent =
+			streamout->abandoned_unsent[__SCTP_PR_INDEX(policy)];
+		params.sprstat_abandoned_sent =
+			streamout->abandoned_sent[__SCTP_PR_INDEX(policy)];
+	}
+
+	if (put_user(len, optlen) || copy_to_user(optval, &params, len)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	retval = 0;
+
+out:
+	return retval;
+}
+
 static int sctp_getsockopt_reconfig_supported(struct sock *sk, int len,
 					      char __user *optval,
 					      int __user *optlen)
@@ -6825,6 +6880,10 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_pr_assocstatus(sk, len, optval,
 							optlen);
 		break;
+	case SCTP_PR_STREAM_STATUS:
+		retval = sctp_getsockopt_pr_streamstatus(sk, len, optval,
+							 optlen);
+		break;
 	case SCTP_RECONFIG_SUPPORTED:
 		retval = sctp_getsockopt_reconfig_supported(sk, len, optval,
 							    optlen);
-- 
2.1.0
