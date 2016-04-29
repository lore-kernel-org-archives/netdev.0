From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 5/7] sctp: prepare for socket backlog behavior change
Date: Fri, 29 Apr 2016 14:16:51 -0700
Message-ID: <1461964613-4872-6-git-send-email-edumazet@google.com>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33740 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbcD2VRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 17:17:09 -0400
Received: by mail-pa0-f53.google.com with SMTP id zm5so55824640pac.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 14:17:09 -0700 (PDT)
In-Reply-To: <1461964613-4872-1-git-send-email-edumazet@google.com>
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
