From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/2] sctp: merge sctp_stream_new and sctp_stream_init
Date: Wed, 31 May 2017 16:36:32 +0800
Message-ID: <cb70ccffc2556fbe7025295de6c529ab006187e2.1496219741.git.lucien.xin@gmail.com>
References: <cover.1496219741.git.lucien.xin@gmail.com>
 <a10f4c7eb03629c4b2316e2096895b8a99f4c1cf.1496219741.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35630 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdEaIhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:37:08 -0400
In-Reply-To: <a10f4c7eb03629c4b2316e2096895b8a99f4c1cf.1496219741.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1496219741.git.lucien.xin@gmail.com>
References: <cover.1496219741.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since last patch, sctp doesn't need to alloc memory for asoc->stream any
more. sctp_stream_new and sctp_stream_init both are used to alloc memory
for stream.in or stream.out, and their names are also confusing.

This patch is to merge them into sctp_stream_init, and only pass stream
and streamcnt parameters into it, instead of the whole asoc.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  4 ++--
 net/sctp/associola.c       |  3 ++-
 net/sctp/sm_make_chunk.c   |  3 ++-
 net/sctp/stream.c          | 33 +++++++++++----------------------
 4 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c8dbf41..5051317 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -377,8 +377,8 @@ typedef struct sctp_sender_hb_info {
 	__u64 hb_nonce;
 } sctp_sender_hb_info_t;
 
-int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp);
-int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp);
+int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
+		     gfp_t gfp);
 void sctp_stream_free(struct sctp_stream *stream);
 void sctp_stream_clear(struct sctp_stream *stream);
 void sctp_stream_update(struct sctp_stream *stream, struct sctp_stream *new);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 6625b15..288c5e0 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -246,7 +246,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	if (!sctp_ulpq_init(&asoc->ulpq, asoc))
 		goto fail_init;
 
-	if (sctp_stream_new(asoc, gfp))
+	if (sctp_stream_init(&asoc->stream, asoc->c.sinit_num_ostreams,
+			     0, gfp))
 		goto fail_init;
 
 	/* Assume that peer would support both address types unless we are
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2441814..bd439ed 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2454,7 +2454,8 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * stream sequence number shall be set to 0.
 	 */
 
-	if (sctp_stream_init(asoc, gfp))
+	if (sctp_stream_init(&asoc->stream, asoc->c.sinit_num_ostreams,
+			     asoc->c.sinit_max_instreams, gfp))
 		goto clean_up;
 
 	if (!asoc->temp && sctp_assoc_set_id(asoc, gfp))
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index af6b498..82e6d40 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -35,47 +35,36 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp)
+int sctp_stream_init(struct sctp_stream *stream, __u16 outcnt, __u16 incnt,
+		     gfp_t gfp)
 {
-	struct sctp_stream *stream = &asoc->stream;
-	int i;
-
-	stream->outcnt = asoc->c.sinit_num_ostreams;
-	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
-	if (!stream->out)
-		return -ENOMEM;
-
-	for (i = 0; i < stream->outcnt; i++)
-		stream->out[i].state = SCTP_STREAM_OPEN;
-
-	return 0;
-}
-
-int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp)
-{
-	struct sctp_stream *stream = &asoc->stream;
 	int i;
 
 	/* Initial stream->out size may be very big, so free it and alloc
 	 * a new one with new outcnt to save memory.
 	 */
 	kfree(stream->out);
-	stream->outcnt = asoc->c.sinit_num_ostreams;
-	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
+
+	stream->out = kcalloc(outcnt, sizeof(*stream->out), gfp);
 	if (!stream->out)
 		return -ENOMEM;
 
+	stream->outcnt = outcnt;
 	for (i = 0; i < stream->outcnt; i++)
 		stream->out[i].state = SCTP_STREAM_OPEN;
 
-	stream->incnt = asoc->c.sinit_max_instreams;
-	stream->in = kcalloc(stream->incnt, sizeof(*stream->in), gfp);
+	if (!incnt)
+		return 0;
+
+	stream->in = kcalloc(incnt, sizeof(*stream->in), gfp);
 	if (!stream->in) {
 		kfree(stream->out);
 		stream->out = NULL;
 		return -ENOMEM;
 	}
 
+	stream->incnt = incnt;
+
 	return 0;
 }
 
-- 
2.1.0
