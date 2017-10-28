From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/4] sctp: fix some type cast warnings introduced by stream reconf
Date: Sat, 28 Oct 2017 19:43:54 +0800
Message-ID: <d85747d7d1af0972a00b8d4594a84f2afe97aac8.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:44989 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ1LoO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:44:14 -0400
In-Reply-To: <cover.1509190967.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These warnings were found by running 'make C=2 M=net/sctp/'.

They are introduced by not aware of Endian when coding stream
reconf patches.

Since commit c0d8bab6ae51 ("sctp: add get and set sockopt for
reconf_enable") enabled stream reconf feature for users, the
Fixes tag below would use it.

Fixes: c0d8bab6ae51 ("sctp: add get and set sockopt for reconf_enable")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h        | 32 ++++++++++++++++----------------
 include/net/sctp/sm.h       |  2 +-
 include/net/sctp/ulpevent.h |  2 +-
 net/sctp/sm_make_chunk.c    |  5 +++--
 net/sctp/stream.c           | 26 +++++++++++++++++---------
 net/sctp/ulpevent.c         |  2 +-
 6 files changed, 39 insertions(+), 30 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 82b171e..09d7412 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -716,28 +716,28 @@ struct sctp_reconf_chunk {
 
 struct sctp_strreset_outreq {
 	struct sctp_paramhdr param_hdr;
-	__u32 request_seq;
-	__u32 response_seq;
-	__u32 send_reset_at_tsn;
-	__u16 list_of_streams[0];
+	__be32 request_seq;
+	__be32 response_seq;
+	__be32 send_reset_at_tsn;
+	__be16 list_of_streams[0];
 };
 
 struct sctp_strreset_inreq {
 	struct sctp_paramhdr param_hdr;
-	__u32 request_seq;
-	__u16 list_of_streams[0];
+	__be32 request_seq;
+	__be16 list_of_streams[0];
 };
 
 struct sctp_strreset_tsnreq {
 	struct sctp_paramhdr param_hdr;
-	__u32 request_seq;
+	__be32 request_seq;
 };
 
 struct sctp_strreset_addstrm {
 	struct sctp_paramhdr param_hdr;
-	__u32 request_seq;
-	__u16 number_of_streams;
-	__u16 reserved;
+	__be32 request_seq;
+	__be16 number_of_streams;
+	__be16 reserved;
 };
 
 enum {
@@ -752,16 +752,16 @@ enum {
 
 struct sctp_strreset_resp {
 	struct sctp_paramhdr param_hdr;
-	__u32 response_seq;
-	__u32 result;
+	__be32 response_seq;
+	__be32 result;
 };
 
 struct sctp_strreset_resptsn {
 	struct sctp_paramhdr param_hdr;
-	__u32 response_seq;
-	__u32 result;
-	__u32 senders_next_tsn;
-	__u32 receivers_next_tsn;
+	__be32 response_seq;
+	__be32 result;
+	__be32 senders_next_tsn;
+	__be32 receivers_next_tsn;
 };
 
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2db3d3a..88233cf 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -261,7 +261,7 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 				    struct sctp_fwdtsn_skip *skiplist);
 struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc);
 struct sctp_chunk *sctp_make_strreset_req(const struct sctp_association *asoc,
-					  __u16 stream_num, __u16 *stream_list,
+					  __u16 stream_num, __be16 *stream_list,
 					  bool out, bool in);
 struct sctp_chunk *sctp_make_strreset_tsnreq(
 					const struct sctp_association *asoc);
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index b8c86ec..231dc42 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -130,7 +130,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 
 struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	const struct sctp_association *asoc, __u16 flags,
-	__u16 stream_num, __u16 *stream_list, gfp_t gfp);
+	__u16 stream_num, __be16 *stream_list, gfp_t gfp);
 
 struct sctp_ulpevent *sctp_ulpevent_make_assoc_reset_event(
 	const struct sctp_association *asoc, __u16 flags,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ca8f196..57c5504 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3591,7 +3591,7 @@ static struct sctp_chunk *sctp_make_reconf(const struct sctp_association *asoc,
  */
 struct sctp_chunk *sctp_make_strreset_req(
 					const struct sctp_association *asoc,
-					__u16 stream_num, __u16 *stream_list,
+					__u16 stream_num, __be16 *stream_list,
 					bool out, bool in)
 {
 	struct sctp_strreset_outreq outreq;
@@ -3788,7 +3788,8 @@ bool sctp_verify_reconf(const struct sctp_association *asoc,
 {
 	struct sctp_reconf_chunk *hdr;
 	union sctp_params param;
-	__u16 last = 0, cnt = 0;
+	__be16 last = 0;
+	__u16 cnt = 0;
 
 	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
 	sctp_walk_params(param, hdr, params) {
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 63ea155..fa8371f 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -118,6 +118,7 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 	__u16 i, str_nums, *str_list;
 	struct sctp_chunk *chunk;
 	int retval = -EINVAL;
+	__be16 *nstr_list;
 	bool out, in;
 
 	if (!asoc->peer.reconf_capable ||
@@ -148,13 +149,18 @@ int sctp_send_reset_streams(struct sctp_association *asoc,
 			if (str_list[i] >= stream->incnt)
 				goto out;
 
+	nstr_list = kcalloc(str_nums, sizeof(__be16), GFP_KERNEL);
+	if (!nstr_list) {
+		retval = -ENOMEM;
+		goto out;
+	}
+
 	for (i = 0; i < str_nums; i++)
-		str_list[i] = htons(str_list[i]);
+		nstr_list[i] = htons(str_list[i]);
 
-	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
+	chunk = sctp_make_strreset_req(asoc, str_nums, nstr_list, out, in);
 
-	for (i = 0; i < str_nums; i++)
-		str_list[i] = ntohs(str_list[i]);
+	kfree(nstr_list);
 
 	if (!chunk) {
 		retval = -ENOMEM;
@@ -305,7 +311,7 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 }
 
 static struct sctp_paramhdr *sctp_chunk_lookup_strreset_param(
-			struct sctp_association *asoc, __u32 resp_seq,
+			struct sctp_association *asoc, __be32 resp_seq,
 			__be16 type)
 {
 	struct sctp_chunk *chunk = asoc->strreset_chunk;
@@ -345,8 +351,9 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 {
 	struct sctp_strreset_outreq *outreq = param.v;
 	struct sctp_stream *stream = &asoc->stream;
-	__u16 i, nums, flags = 0, *str_p = NULL;
 	__u32 result = SCTP_STRRESET_DENIED;
+	__u16 i, nums, flags = 0;
+	__be16 *str_p = NULL;
 	__u32 request_seq;
 
 	request_seq = ntohl(outreq->request_seq);
@@ -439,8 +446,9 @@ struct sctp_chunk *sctp_process_strreset_inreq(
 	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
 	struct sctp_chunk *chunk = NULL;
-	__u16 i, nums, *str_p;
 	__u32 request_seq;
+	__u16 i, nums;
+	__be16 *str_p;
 
 	request_seq = ntohl(inreq->request_seq);
 	if (TSN_lt(asoc->strreset_inseq, request_seq) ||
@@ -769,7 +777,7 @@ struct sctp_chunk *sctp_process_strreset_resp(
 
 	if (req->type == SCTP_PARAM_RESET_OUT_REQUEST) {
 		struct sctp_strreset_outreq *outreq;
-		__u16 *str_p;
+		__be16 *str_p;
 
 		outreq = (struct sctp_strreset_outreq *)req;
 		str_p = outreq->list_of_streams;
@@ -794,7 +802,7 @@ struct sctp_chunk *sctp_process_strreset_resp(
 			nums, str_p, GFP_ATOMIC);
 	} else if (req->type == SCTP_PARAM_RESET_IN_REQUEST) {
 		struct sctp_strreset_inreq *inreq;
-		__u16 *str_p;
+		__be16 *str_p;
 
 		/* if the result is performed, it's impossible for inreq */
 		if (result == SCTP_STRRESET_PERFORMED)
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 67abc01..5447228 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -847,7 +847,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_sender_dry_event(
 
 struct sctp_ulpevent *sctp_ulpevent_make_stream_reset_event(
 	const struct sctp_association *asoc, __u16 flags, __u16 stream_num,
-	__u16 *stream_list, gfp_t gfp)
+	__be16 *stream_list, gfp_t gfp)
 {
 	struct sctp_stream_reset_event *sreset;
 	struct sctp_ulpevent *event;
-- 
2.1.0
