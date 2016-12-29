From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: refactor sctp_datamsg_from_user
Date: Thu, 29 Dec 2016 15:53:28 -0200
Message-ID: <ba007bd30f61decbdae5c23541cbdb397c030b68.1483033905.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36151 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752756AbcL2RyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:54:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch refactors sctp_datamsg_from_user() in an attempt to make it
better to read and avoid code duplication for handling the last
fragment.

It also avoids doing division and remaining operations. Even though, it
should still operate similarly as before this patch.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/chunk.c | 107 +++++++++++++++++--------------------------------------
 1 file changed, 32 insertions(+), 75 deletions(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 615f0ddd41dfb1ff46a9d4e564716de8e7b60ea6..e3621cb4827fadb5f5cb41ebe8455dfa3300a765 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -165,14 +165,12 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 					    struct sctp_sndrcvinfo *sinfo,
 					    struct iov_iter *from)
 {
-	int max, whole, i, offset, over, err;
-	int len, first_len;
-	int max_data;
+	size_t len, first_len, max_data, remaining;
+	size_t msg_len = iov_iter_count(from);
+	struct list_head *pos, *temp;
 	struct sctp_chunk *chunk;
 	struct sctp_datamsg *msg;
-	struct list_head *pos, *temp;
-	size_t msg_len = iov_iter_count(from);
-	__u8 frag;
+	int err;
 
 	msg = sctp_datamsg_new(GFP_KERNEL);
 	if (!msg)
@@ -185,7 +183,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	    (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags) ||
 	     !SCTP_PR_POLICY(sinfo->sinfo_flags)))
 		msg->expires_at = jiffies +
-				    msecs_to_jiffies(sinfo->sinfo_timetolive);
+				  msecs_to_jiffies(sinfo->sinfo_timetolive);
 
 	/* This is the biggest possible DATA chunk that can fit into
 	 * the packet
@@ -195,7 +193,6 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		   sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk);
 	max_data = SCTP_TRUNC4(max_data);
 
-	max = asoc->frag_point;
 	/* If the the peer requested that we authenticate DATA chunks
 	 * we need to account for bundling of the AUTH chunks along with
 	 * DATA.
@@ -208,12 +205,11 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 					      hmac_desc->hmac_len);
 	}
 
-	/* Now, check if we need to reduce our max */
-	if (max > max_data)
-		max = max_data;
+	/* Check what's our max considering the above */
+	max_data = min_t(size_t, max_data, asoc->frag_point);
 
-	whole = 0;
-	first_len = max;
+	/* Set first_len and then account for possible bundles on first frag */
+	first_len = max_data;
 
 	/* Check to see if we have a pending SACK and try to let it be bundled
 	 * with this message.  Do this if we don't have any data queued already.
@@ -224,40 +220,38 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	if (timer_pending(&asoc->timers[SCTP_EVENT_TIMEOUT_SACK]) &&
 	    asoc->outqueue.out_qlen == 0 &&
 	    list_empty(&asoc->outqueue.retransmit) &&
-	    msg_len > max)
-		max_data -= SCTP_PAD4(sizeof(sctp_sack_chunk_t));
+	    msg_len > max_data)
+		first_len -= SCTP_PAD4(sizeof(sctp_sack_chunk_t));
 
 	/* Encourage Cookie-ECHO bundling. */
 	if (asoc->state < SCTP_STATE_COOKIE_ECHOED)
-		max_data -= SCTP_ARBITRARY_COOKIE_ECHO_LEN;
-
-	/* Now that we adjusted completely, reset first_len */
-	if (first_len > max_data)
-		first_len = max_data;
+		first_len -= SCTP_ARBITRARY_COOKIE_ECHO_LEN;
 
 	/* Account for a different sized first fragment */
 	if (msg_len >= first_len) {
-		msg_len -= first_len;
-		whole = 1;
 		msg->can_delay = 0;
-	}
-
-	/* How many full sized?  How many bytes leftover? */
-	whole += msg_len / max;
-	over = msg_len % max;
-	offset = 0;
-
-	if ((whole > 1) || (whole && over))
 		SCTP_INC_STATS(sock_net(asoc->base.sk), SCTP_MIB_FRAGUSRMSGS);
+	} else {
+		/* Which may be the only one... */
+		first_len = msg_len;
+	}
 
-	/* Create chunks for all the full sized DATA chunks. */
-	for (i = 0, len = first_len; i < whole; i++) {
-		frag = SCTP_DATA_MIDDLE_FRAG;
+	/* Create chunks for all DATA chunks. */
+	for (remaining = msg_len; remaining; remaining -= len) {
+		u8 frag = SCTP_DATA_MIDDLE_FRAG;
 
-		if (0 == i)
+		if (remaining == msg_len) {
+			/* First frag, which may also be the last */
 			frag |= SCTP_DATA_FIRST_FRAG;
+			len = first_len;
+		} else {
+			/* Middle frags */
+			len = max_data;
+		}
 
-		if ((i == (whole - 1)) && !over) {
+		if (len >= remaining) {
+			/* Last frag, which may also be the first */
+			len = remaining;
 			frag |= SCTP_DATA_LAST_FRAG;
 
 			/* The application requests to set the I-bit of the
@@ -271,7 +265,6 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 
 		chunk = sctp_make_datafrag_empty(asoc, sinfo, len, frag,
 						 0, GFP_KERNEL);
-
 		if (!chunk) {
 			err = -ENOMEM;
 			goto errout;
@@ -282,45 +275,8 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			goto errout_chunk_free;
 
 		/* Put the chunk->skb back into the form expected by send.  */
-		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
-			   - (__u8 *)chunk->skb->data);
-
-		sctp_datamsg_assign(msg, chunk);
-		list_add_tail(&chunk->frag_list, &msg->chunks);
-
-		/* The first chunk, the first chunk was likely short
-		 * to allow bundling, so reset to full size.
-		 */
-		if (0 == i)
-			len = max;
-	}
-
-	/* .. now the leftover bytes. */
-	if (over) {
-		if (!whole)
-			frag = SCTP_DATA_NOT_FRAG;
-		else
-			frag = SCTP_DATA_LAST_FRAG;
-
-		if ((sinfo->sinfo_flags & SCTP_EOF) ||
-		    (sinfo->sinfo_flags & SCTP_SACK_IMMEDIATELY))
-			frag |= SCTP_DATA_SACK_IMM;
-
-		chunk = sctp_make_datafrag_empty(asoc, sinfo, over, frag,
-						 0, GFP_KERNEL);
-
-		if (!chunk) {
-			err = -ENOMEM;
-			goto errout;
-		}
-
-		err = sctp_user_addto_chunk(chunk, over, from);
-
-		/* Put the chunk->skb back into the form expected by send.  */
-		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
-			   - (__u8 *)chunk->skb->data);
-		if (err < 0)
-			goto errout_chunk_free;
+		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr -
+				       chunk->skb->data);
 
 		sctp_datamsg_assign(msg, chunk);
 		list_add_tail(&chunk->frag_list, &msg->chunks);
@@ -338,6 +294,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		sctp_chunk_free(chunk);
 	}
 	sctp_datamsg_put(msg);
+
 	return ERR_PTR(err);
 }
 
-- 
2.9.3
