From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 03/10] sctp: factor out stream->in allocation
Date: Thu, 28 Sep 2017 17:25:16 -0300
Message-ID: <a2d837095740147003164fe573794c140001ec71.1506536044.git.marcelo.leitner@gmail.com>
References: <cover.1506536044.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35025 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdI1UZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 16:25:44 -0400
In-Reply-To: <cover.1506536044.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same idea as previous patch.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/stream.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 6d0e997d301f89e165367106c02e82f8a6c3a877..952437d656cc71ad1c133a736c539eff9a8d80c2 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -59,6 +59,31 @@ static int sctp_stream_alloc_out(struct sctp_stream *stream, __u16 outcnt,
 	return 0;
 }
 
+static int sctp_stream_alloc_in(struct sctp_stream *stream, __u16 incnt,
+				gfp_t gfp)
+{
+	struct sctp_stream_in *in;
+
+	in = kmalloc_array(incnt, sizeof(*stream->in), gfp);
+
+	if (!in)
+		return -ENOMEM;
+
+	if (stream->in) {
+		memcpy(in, stream->in, min(incnt, stream->incnt) *
+				       sizeof(*in));
+		kfree(stream->in);
+	}
+
+	if (incnt > stream->incnt)
+		memset(in + stream->incnt, 0,
+		       (incnt - stream->incnt) * sizeof(*in));
+
+	stream->in = in;
+
+	return 0;
+}
+
 int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 		     gfp_t gfp)
 {
@@ -84,8 +109,8 @@ int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
 	if (!incnt)
 		return 0;
 
-	stream->in = kcalloc(incnt, sizeof(*stream->in), gfp);
-	if (!stream->in) {
+	i = sctp_stream_alloc_in(stream, incnt, gfp);
+	if (i) {
 		kfree(stream->out);
 		stream->out = NULL;
 		return -ENOMEM;
@@ -623,7 +648,6 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 	struct sctp_strreset_addstrm *addstrm = param.v;
 	struct sctp_stream *stream = &asoc->stream;
 	__u32 result = SCTP_STRRESET_DENIED;
-	struct sctp_stream_in *streamin;
 	__u32 request_seq, incnt;
 	__u16 in, i;
 
@@ -670,13 +694,9 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 	if (!in || incnt > SCTP_MAX_STREAM)
 		goto out;
 
-	streamin = krealloc(stream->in, incnt * sizeof(*streamin),
-			    GFP_ATOMIC);
-	if (!streamin)
+	if (sctp_stream_alloc_in(stream, incnt, GFP_ATOMIC))
 		goto out;
 
-	memset(streamin + stream->incnt, 0, in * sizeof(*streamin));
-	stream->in = streamin;
 	stream->incnt = incnt;
 
 	result = SCTP_STRRESET_PERFORMED;
-- 
2.13.5
