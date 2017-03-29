From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: alloc stream info when initializing asoc
Date: Thu, 30 Mar 2017 01:00:53 +0800
Message-ID: <06d5884ac36a3ad5f5bceaf0088aede14870088b.1490806853.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32884 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752140AbdC2RBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:01:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending a msg without asoc established, sctp will send INIT packet
first and then enqueue chunks.

Before receiving INIT_ACK, stream info is not yet alloced. But enqueuing
chunks needs to access stream info, like out stream state and out stream
cnt.

This patch is to fix it by allocing out stream info when initializing an
asoc, allocing in stream and re-allocing out stream when processing init.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  3 ++-
 net/sctp/associola.c       |  7 ++++++-
 net/sctp/sm_make_chunk.c   |  9 ++-------
 net/sctp/stream.c          | 43 +++++++++++++++++++++++++++++++++++--------
 4 files changed, 45 insertions(+), 17 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8caa5ee..a127b7c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -377,7 +377,8 @@ typedef struct sctp_sender_hb_info {
 	__u64 hb_nonce;
 } sctp_sender_hb_info_t;
 
-struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp);
+int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp);
+int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp);
 void sctp_stream_free(struct sctp_stream *stream);
 void sctp_stream_clear(struct sctp_stream *stream);
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 0439a1a..0b26df5 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -246,6 +246,9 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	if (!sctp_ulpq_init(&asoc->ulpq, asoc))
 		goto fail_init;
 
+	if (sctp_stream_new(asoc, gfp))
+		goto fail_init;
+
 	/* Assume that peer would support both address types unless we are
 	 * told otherwise.
 	 */
@@ -264,7 +267,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	/* AUTH related initializations */
 	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
 	if (sctp_auth_asoc_copy_shkeys(ep, asoc, gfp))
-		goto fail_init;
+		goto stream_free;
 
 	asoc->active_key_id = ep->active_key_id;
 	asoc->prsctp_enable = ep->prsctp_enable;
@@ -287,6 +290,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	return asoc;
 
+stream_free:
+	sctp_stream_free(asoc->stream);
 fail_init:
 	sock_put(asoc->base.sk);
 	sctp_endpoint_put(asoc->ep);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 969a30c..118faff 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2460,15 +2460,10 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * association.
 	 */
 	if (!asoc->temp) {
-		int error;
-
-		asoc->stream = sctp_stream_new(asoc->c.sinit_max_instreams,
-					       asoc->c.sinit_num_ostreams, gfp);
-		if (!asoc->stream)
+		if (sctp_stream_init(asoc, gfp))
 			goto clean_up;
 
-		error = sctp_assoc_set_id(asoc, gfp);
-		if (error)
+		if (sctp_assoc_set_id(asoc, gfp))
 			goto clean_up;
 	}
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 1c6cc04..bbed997 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -35,33 +35,60 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
-struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp)
+int sctp_stream_new(struct sctp_association *asoc, gfp_t gfp)
 {
 	struct sctp_stream *stream;
 	int i;
 
 	stream = kzalloc(sizeof(*stream), gfp);
 	if (!stream)
-		return NULL;
+		return -ENOMEM;
 
-	stream->outcnt = outcnt;
+	stream->outcnt = asoc->c.sinit_num_ostreams;
 	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
 	if (!stream->out) {
 		kfree(stream);
-		return NULL;
+		return -ENOMEM;
 	}
 	for (i = 0; i < stream->outcnt; i++)
 		stream->out[i].state = SCTP_STREAM_OPEN;
 
-	stream->incnt = incnt;
+	asoc->stream = stream;
+
+	return 0;
+}
+
+int sctp_stream_init(struct sctp_association *asoc, gfp_t gfp)
+{
+	struct sctp_stream *stream = asoc->stream;
+	int i;
+
+	/* Initial stream->out size may be very big, so free it and alloc
+	 * a new one with new outcnt to save memory.
+	 */
+	kfree(stream->out);
+	stream->outcnt = asoc->c.sinit_num_ostreams;
+	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
+	if (!stream->out)
+		goto nomem;
+
+	for (i = 0; i < stream->outcnt; i++)
+		stream->out[i].state = SCTP_STREAM_OPEN;
+
+	stream->incnt = asoc->c.sinit_max_instreams;
 	stream->in = kcalloc(stream->incnt, sizeof(*stream->in), gfp);
 	if (!stream->in) {
 		kfree(stream->out);
-		kfree(stream);
-		return NULL;
+		goto nomem;
 	}
 
-	return stream;
+	return 0;
+
+nomem:
+	asoc->stream = NULL;
+	kfree(stream);
+
+	return -ENOMEM;
 }
 
 void sctp_stream_free(struct sctp_stream *stream)
-- 
2.1.0
