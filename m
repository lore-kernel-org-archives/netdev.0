From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: hold the chunks only after the chunk is enqueued in outq
Date: Sat,  5 Dec 2015 15:15:17 +0800
Message-ID: <b2131d0e9ac5a34aea93d6770fcf68c4496d1d7d.1449299717.git.lucien.xin@gmail.com>
Cc: marcelo.leitner@gmail.com, vyasevic@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35968 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbbLEHWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:22:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a msg is sent, sctp will hold the chunks of this msg and then try
to enqueue them. But if the chunks are not enqueued in sctp_outq_tail()
because of the invalid state, sctp_cmd_interpreter() may still return
success to sctp_sendmsg() after calling sctp_outq_flush(), these chunks
will become orphans and will leak.

So we fix them by moving sctp_chunk_hold() to sctp_outq_tail(), where we
are sure that the chunk is going to get queued.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/outqueue.c | 1 +
 net/sctp/socket.c   | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7e8f0a1..0b3d818 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -324,6 +324,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 				 sctp_cname(SCTP_ST_CHUNK(chunk->chunk_hdr->type)) :
 				 "illegal chunk");
 
+			sctp_chunk_hold(chunk);
 			sctp_outq_tail_data(q, chunk);
 			if (chunk->chunk_hdr->flags & SCTP_DATA_UNORDERED)
 				SCTP_INC_STATS(net, SCTP_MIB_OUTUNORDERCHUNKS);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 03c8256..8804731 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1952,8 +1952,6 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 
 	/* Now send the (possibly) fragmented message. */
 	list_for_each_entry(chunk, &datamsg->chunks, frag_list) {
-		sctp_chunk_hold(chunk);
-
 		/* Do accounting for the write space.  */
 		sctp_set_owner_w(chunk);
 
-- 
2.1.0
