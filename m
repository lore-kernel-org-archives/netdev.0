From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: partial chunk should be drop without sending abort packet
Date: Mon, 24 Aug 2015 18:08:30 +0800
Message-ID: <88918657d985bc0e55e64ca232dcd5f2b76b7cb4.1440410910.git.lucien.xin@gmail.com>
Cc: mleitner@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33661 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbbHXKIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 06:08:34 -0400
Received: by pacti10 with SMTP id ti10so20690601pac.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 03:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as RFC 4960, 6.10 said, *if the receiver detects a partial chunk, it MUST drop
the chunk*, we should not send the abort. but if we put this discard to inside
state machine, it will send abort.

so we just drop the partial chunk there, never let this chunk go into the state
machine.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/inqueue.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 7e8a16c..a22ca57 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -183,9 +183,9 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 		/* This is not a singleton */
 		chunk->singleton = 0;
 	} else if (chunk->chunk_end > skb_tail_pointer(chunk->skb)) {
-		/* Discard inside state machine. */
-		chunk->pdiscard = 1;
-		chunk->chunk_end = skb_tail_pointer(chunk->skb);
+		sctp_chunk_free(chunk);
+		chunk = queue->in_progress = NULL;
+		return NULL;
 	} else {
 		/* We are at the end of the packet, so mark the chunk
 		 * in case we need to send a SACK.
-- 
2.1.0
