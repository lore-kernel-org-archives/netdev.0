From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 04/10] sctp: introduce struct sctp_stream_out_ext
Date: Thu, 28 Sep 2017 17:25:17 -0300
Message-ID: <f7e5c4af575b8c925185c991e2e944a3fd3c84e3.1506536044.git.marcelo.leitner@gmail.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:45232 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbdI1UZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 16:25:46 -0400
In-Reply-To: <cover.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the stream schedulers, sctp_stream_out will become too big to be
allocated by kmalloc and as we need to allocate with BH disabled, we
cannot use __vmalloc in sctp_stream_init().

This patch moves out the stats from sctp_stream_out to
sctp_stream_out_ext, which will be allocated only when the application
tries to sendmsg something on it.

Just the introduction of sctp_stream_out_ext would already fix the issue
described above by splitting the allocation in two. Moving the stats
to it also reduces the pressure on the allocator as we will ask for less
memory atomically when creating the socket and we will use GFP_KERNEL
later.

Then, for stream schedulers, we will just use sctp_stream_out_ext.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 10 ++++++++--
 net/sctp/chunk.c           |  6 +++---
 net/sctp/outqueue.c        |  4 ++--
 net/sctp/socket.c          | 27 +++++++++++++++++++++------
 net/sctp/stream.c          | 16 ++++++++++++++++
 5 files changed, 50 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0477945de1a3cf5c27348e99d9a30e02c491d1de..9b2b30b3ba4dfd10c24c3e06ed80779180a06baf 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -84,6 +84,7 @@ struct sctp_ulpq;
 struct sctp_ep_common;
 struct crypto_shash;
 struct sctp_stream;
+struct sctp_stream_out;
 
 
 #include <net/sctp/tsnmap.h>
@@ -380,6 +381,7 @@ struct sctp_sender_hb_info {
 
 int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 		     gfp_t gfp);
+int sctp_stream_init_ext(struct sctp_stream *stream, __u16 sid);
 void sctp_stream_free(struct sctp_stream *stream);
 void sctp_stream_clear(struct sctp_stream *stream);
 void sctp_stream_update(struct sctp_stream *stream, struct sctp_stream *new);
@@ -1315,11 +1317,15 @@ struct sctp_inithdr_host {
 	__u32 initial_tsn;
 };
 
+struct sctp_stream_out_ext {
+	__u64 abandoned_unsent[SCTP_PR_INDEX(MAX) + 1];
+	__u64 abandoned_sent[SCTP_PR_INDEX(MAX) + 1];
+};
+
 struct sctp_stream_out {
 	__u16	ssn;
 	__u8	state;
-	__u64	abandoned_unsent[SCTP_PR_INDEX(MAX) + 1];
-	__u64	abandoned_sent[SCTP_PR_INDEX(MAX) + 1];
+	struct sctp_stream_out_ext *ext;
 };
 
 struct sctp_stream_in {
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 3afac275ee82dbec825dd71378dffe69a53718a7..7b261afc47b9d709fdd780a93aaba874f35d79be 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -311,10 +311,10 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 
 		if (chunk->sent_count) {
 			chunk->asoc->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
-			streamout->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
+			streamout->ext->abandoned_sent[SCTP_PR_INDEX(TTL)]++;
 		} else {
 			chunk->asoc->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
-			streamout->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
+			streamout->ext->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
 		}
 		return 1;
 	} else if (SCTP_PR_RTX_ENABLED(chunk->sinfo.sinfo_flags) &&
@@ -323,7 +323,7 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 			&chunk->asoc->stream.out[chunk->sinfo.sinfo_stream];
 
 		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
-		streamout->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
+		streamout->ext->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
 		return 1;
 	} else if (!SCTP_PR_POLICY(chunk->sinfo.sinfo_flags) &&
 		   chunk->msg->expires_at &&
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 2966ff400755fe93e3658e09d3bb44b9d7d19d2e..746b07b7937d8730824b9e09917d947aa7863ec6 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -366,7 +366,7 @@ static int sctp_prsctp_prune_sent(struct sctp_association *asoc,
 		streamout = &asoc->stream.out[chk->sinfo.sinfo_stream];
 		asoc->sent_cnt_removable--;
 		asoc->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
-		streamout->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
+		streamout->ext->abandoned_sent[SCTP_PR_INDEX(PRIO)]++;
 
 		if (!chk->tsn_gap_acked) {
 			if (chk->transport)
@@ -404,7 +404,7 @@ static int sctp_prsctp_prune_unsent(struct sctp_association *asoc,
 			struct sctp_stream_out *streamout =
 				&asoc->stream.out[chk->sinfo.sinfo_stream];
 
-			streamout->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
+			streamout->ext->abandoned_unsent[SCTP_PR_INDEX(PRIO)]++;
 		}
 
 		msg_len -= SCTP_DATA_SNDSIZE(chk) +
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d4730ada7f3233367be7a0e3bb10e286a25602c8..d207734326b085e60625e4333f74221481114892 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1927,6 +1927,13 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 		goto out_free;
 	}
 
+	/* Allocate sctp_stream_out_ext if not already done */
+	if (unlikely(!asoc->stream.out[sinfo->sinfo_stream].ext)) {
+		err = sctp_stream_init_ext(&asoc->stream, sinfo->sinfo_stream);
+		if (err)
+			goto out_free;
+	}
+
 	if (sctp_wspace(asoc) < msg_len)
 		sctp_prsctp_prune(asoc, sinfo, msg_len - sctp_wspace(asoc));
 
@@ -6645,7 +6652,7 @@ static int sctp_getsockopt_pr_streamstatus(struct sock *sk, int len,
 					   char __user *optval,
 					   int __user *optlen)
 {
-	struct sctp_stream_out *streamout;
+	struct sctp_stream_out_ext *streamoute;
 	struct sctp_association *asoc;
 	struct sctp_prstatus params;
 	int retval = -EINVAL;
@@ -6668,21 +6675,29 @@ static int sctp_getsockopt_pr_streamstatus(struct sock *sk, int len,
 	if (!asoc || params.sprstat_sid >= asoc->stream.outcnt)
 		goto out;
 
-	streamout = &asoc->stream.out[params.sprstat_sid];
+	streamoute = asoc->stream.out[params.sprstat_sid].ext;
+	if (!streamoute) {
+		/* Not allocated yet, means all stats are 0 */
+		params.sprstat_abandoned_unsent = 0;
+		params.sprstat_abandoned_sent = 0;
+		retval = 0;
+		goto out;
+	}
+
 	if (policy == SCTP_PR_SCTP_NONE) {
 		params.sprstat_abandoned_unsent = 0;
 		params.sprstat_abandoned_sent = 0;
 		for (policy = 0; policy <= SCTP_PR_INDEX(MAX); policy++) {
 			params.sprstat_abandoned_unsent +=
-				streamout->abandoned_unsent[policy];
+				streamoute->abandoned_unsent[policy];
 			params.sprstat_abandoned_sent +=
-				streamout->abandoned_sent[policy];
+				streamoute->abandoned_sent[policy];
 		}
 	} else {
 		params.sprstat_abandoned_unsent =
-			streamout->abandoned_unsent[__SCTP_PR_INDEX(policy)];
+			streamoute->abandoned_unsent[__SCTP_PR_INDEX(policy)];
 		params.sprstat_abandoned_sent =
-			streamout->abandoned_sent[__SCTP_PR_INDEX(policy)];
+			streamoute->abandoned_sent[__SCTP_PR_INDEX(policy)];
 	}
 
 	if (put_user(len, optlen) || copy_to_user(optval, &params, len)) {
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 952437d656cc71ad1c133a736c539eff9a8d80c2..055ca25bbc91bf932db8048c72a1b11cc2214942 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -121,8 +121,24 @@ int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 	return 0;
 }
 
+int sctp_stream_init_ext(struct sctp_stream *stream, __u16 sid)
+{
+	struct sctp_stream_out_ext *soute;
+
+	soute = kzalloc(sizeof(*soute), GFP_KERNEL);
+	if (!soute)
+		return -ENOMEM;
+	stream->out[sid].ext = soute;
+
+	return 0;
+}
+
 void sctp_stream_free(struct sctp_stream *stream)
 {
+	int i;
+
+	for (i = 0; i < stream->outcnt; i++)
+		kfree(stream->out[i].ext);
 	kfree(stream->out);
 	kfree(stream->in);
 }
-- 
2.13.5
