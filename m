From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] [SCTP]: Remove redundant wrapper functions.
Date: Fri, 14 Mar 2008 23:49:32 +0100
Message-ID: <1205534972-907-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:53698 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755241AbYCNWrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2008 18:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_datamsg_free and sctp_datamsg_track are just aliases for
sctp_datamsg_put and sctp_chunk_hold, respectively.

Saves 32 Bytes on x86.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sctp/structs.h |    2 --
 net/sctp/chunk.c           |   16 +---------------
 net/sctp/socket.c          |    4 ++--
 3 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8966599..0ce0443 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -637,8 +637,6 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
 					    struct sctp_sndrcvinfo *,
 					    struct msghdr *, int len);
 void sctp_datamsg_put(struct sctp_datamsg *);
-void sctp_datamsg_free(struct sctp_datamsg *);
-void sctp_datamsg_track(struct sctp_chunk *);
 void sctp_chunk_fail(struct sctp_chunk *, int error);
 int sctp_chunk_abandoned(struct sctp_chunk *);
 
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index e1f3550..ed85764 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -136,20 +136,6 @@ void sctp_datamsg_put(struct sctp_datamsg *msg)
 		sctp_datamsg_destroy(msg);
 }
 
-/* Free a message.  Really just give up a reference, the
- * really free happens in sctp_datamsg_destroy().
- */
-void sctp_datamsg_free(struct sctp_datamsg *msg)
-{
-	sctp_datamsg_put(msg);
-}
-
-/* Hold on to all the fragments until all chunks have been sent. */
-void sctp_datamsg_track(struct sctp_chunk *chunk)
-{
-	sctp_chunk_hold(chunk);
-}
-
 /* Assign a chunk to this datamsg. */
 static void sctp_datamsg_assign(struct sctp_datamsg *msg, struct sctp_chunk *chunk)
 {
@@ -295,7 +281,7 @@ errout:
 		chunk = list_entry(pos, struct sctp_chunk, frag_list);
 		sctp_chunk_free(chunk);
 	}
-	sctp_datamsg_free(msg);
+	sctp_datamsg_put(msg);
 	return NULL;
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1316694..ebe552e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1729,7 +1729,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	/* Now send the (possibly) fragmented message. */
 	list_for_each(pos, &datamsg->chunks) {
 		chunk = list_entry(pos, struct sctp_chunk, frag_list);
-		sctp_datamsg_track(chunk);
+		sctp_chunk_hold(chunk);
 
 		/* Do accounting for the write space.  */
 		sctp_set_owner_w(chunk);
@@ -1748,7 +1748,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		SCTP_DEBUG_PRINTK("We sent primitively.\n");
 	}
 
-	sctp_datamsg_free(datamsg);
+	sctp_datamsg_put(datamsg);
 	if (err)
 		goto out_free;
 	else
-- 
1.5.3.7

