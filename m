From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] sctp: prepare for socket backlog behavior change
Date: Wed, 27 Apr 2016 22:25:51 -0700
Message-ID: <1461821152-23200-6-git-send-email-edumazet@google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34530 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcD1F0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 01:26:11 -0400
Received: by mail-pf0-f176.google.com with SMTP id y69so29261664pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 22:26:10 -0700 (PDT)
In-Reply-To: <1461821152-23200-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_inq_push() will soon be called without BH being blocked
when generic socket code flushes the socket backlog.

It is very possible SCTP can be converted to not rely on BH,
but this needs to be done by SCTP experts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/inqueue.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index b335ffcef0b9..9d87bba0ff1d 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -89,10 +89,12 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
 	 * Eventually, we should clean up inqueue to not rely
 	 * on the BH related data structures.
 	 */
+	local_bh_disable();
 	list_add_tail(&chunk->list, &q->in_chunk_list);
 	if (chunk->asoc)
 		chunk->asoc->stats.ipackets++;
 	q->immediate.func(&q->immediate);
+	local_bh_enable();
 }
 
 /* Peek at the next chunk on the inqeue. */
-- 
2.8.0.rc3.226.g39d4020
