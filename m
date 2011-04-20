From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 9/9] sctp: move chunk from retransmit queue to
 abandoned list
Date: Wed, 20 Apr 2011 15:32:28 +0800
Message-ID: <4DAE8C0C.8090506@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51529 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752148Ab1DTHca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:32:30 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is still data waiting to retransmit and remain in
retransmit queue, while doing the next retransmit, if the
chunk is abandoned, we should move it to abandoned list.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/outqueue.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 3e9d8d2..1c88c89 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -577,6 +577,13 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 	 * try to send as much as possible.
 	 */
 	list_for_each_entry_safe(chunk, chunk1, lqueue, transmitted_list) {
+		/* If the chunk is abandoned, move it to abandoned list. */
+		if (sctp_chunk_abandoned(chunk)) {
+			list_del_init(&chunk->transmitted_list);
+			sctp_insert_list(&q->abandoned,
+					 &chunk->transmitted_list);
+			continue;
+		}
 
 		/* Make sure that Gap Acked TSNs are not retransmitted.  A
 		 * simple approach is just to move such TSNs out of the
-- 
1.6.5.2


