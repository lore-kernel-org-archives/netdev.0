From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 3/6] sctp: free msg->chunks when sctp_primitive_SEND return err
Date: Wed, 14 Sep 2016 02:04:20 +0800
Message-ID: <6b43f456f94dfcaeabc8071806f0609fed59a595.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
 <4f21a8880a3f8e7daed8a53f10649a1d4dfbb12a.1473789537.git.lucien.xin@gmail.com>
 <10622d6256e2c49fa7ec555dec3bd35b47a50b2b.1473789537.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34025 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755296AbcIMSEq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 14:04:46 -0400
In-Reply-To: <10622d6256e2c49fa7ec555dec3bd35b47a50b2b.1473789537.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last patch "sctp: do not return the transmit err back to sctp_sendmsg"
made sctp_primitive_SEND return err only when asoc state is unavailable.
In this case, chunks are not enqueued, they have no chance to be freed if
we don't take care of them later.

This Patch is actually to revert commit 1cd4d5c4326a ("sctp: remove the
unused sctp_datamsg_free()"), commit 69b5777f2e57 ("sctp: hold the chunks
only after the chunk is enqueued in outq") and commit 8b570dc9f7b6 ("sctp:
only drop the reference on the datamsg after sending a msg"), to use
sctp_datamsg_free to free the chunks of current msg.

Fixes: 8b570dc9f7b6 ("sctp: only drop the reference on the datamsg after sending a msg")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  1 +
 net/sctp/chunk.c           | 13 +++++++++++++
 net/sctp/outqueue.c        |  1 -
 net/sctp/socket.c          |  8 ++++++--
 4 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ce93c4b..f61fb7c 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -537,6 +537,7 @@ struct sctp_datamsg {
 struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
 					    struct sctp_sndrcvinfo *,
 					    struct iov_iter *);
+void sctp_datamsg_free(struct sctp_datamsg *);
 void sctp_datamsg_put(struct sctp_datamsg *);
 void sctp_chunk_fail(struct sctp_chunk *, int error);
 int sctp_chunk_abandoned(struct sctp_chunk *);
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a55e547..af9cc80 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -70,6 +70,19 @@ static struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
 	return msg;
 }
 
+void sctp_datamsg_free(struct sctp_datamsg *msg)
+{
+	struct sctp_chunk *chunk;
+
+	/* This doesn't have to be a _safe vairant because
+	 * sctp_chunk_free() only drops the refs.
+	 */
+	list_for_each_entry(chunk, &msg->chunks, frag_list)
+		sctp_chunk_free(chunk);
+
+	sctp_datamsg_put(msg);
+}
+
 /* Final destructruction of datamsg memory. */
 static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 {
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index da2418b..6c109b0 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -304,7 +304,6 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk, gfp_t gfp)
 			 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
 			 "illegal chunk");
 
-		sctp_chunk_hold(chunk);
 		sctp_outq_tail_data(q, chunk);
 		if (chunk->asoc->prsctp_enable &&
 		    SCTP_PR_PRIO_ENABLED(chunk->sinfo.sinfo_flags))
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9fc417a..6cdc61c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1958,6 +1958,8 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 
 	/* Now send the (possibly) fragmented message. */
 	list_for_each_entry(chunk, &datamsg->chunks, frag_list) {
+		sctp_chunk_hold(chunk);
+
 		/* Do accounting for the write space.  */
 		sctp_set_owner_w(chunk);
 
@@ -1970,13 +1972,15 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	 * breaks.
 	 */
 	err = sctp_primitive_SEND(net, asoc, datamsg);
-	sctp_datamsg_put(datamsg);
 	/* Did the lower layer accept the chunk? */
-	if (err)
+	if (err) {
+		sctp_datamsg_free(datamsg);
 		goto out_free;
+	}
 
 	pr_debug("%s: we sent primitively\n", __func__);
 
+	sctp_datamsg_put(datamsg);
 	err = msg_len;
 
 	if (unlikely(wait_connect)) {
-- 
2.1.0
