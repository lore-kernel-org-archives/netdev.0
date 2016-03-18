From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: do not leak chunks that are sent to unconfirmed paths
Date: Fri, 18 Mar 2016 18:39:19 -0300
Message-ID: <1458337159-22792-4-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932510AbcCRVjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 17:39:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a chunk is scheduled to be sent through a transport that
is currently unconfirmed, it will be leaked as it is dequeued from outq
and is not re-queued nor freed.

As I'm not aware of any situation that may lead to this situation, I'm
fixing this by freeing the chunk and also logging a trace so that we can
fix the other bug if it ever happens.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/outqueue.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index f03541d0f12d052d1f58901d57852be46f18a15a..8d3d3625130ee0fd294998554a9290d57eae56e7 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -978,8 +978,12 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 			     (new_transport->state == SCTP_UNCONFIRMED) ||
 			     (new_transport->state == SCTP_PF)))
 				new_transport = asoc->peer.active_path;
-			if (new_transport->state == SCTP_UNCONFIRMED)
+			if (new_transport->state == SCTP_UNCONFIRMED) {
+				WARN_ONCE(1, "Atempt to send packet on unconfirmed path.");
+				sctp_chunk_fail(chunk, 0);
+				sctp_chunk_free(chunk);
 				continue;
+			}
 
 			/* Change packets if necessary.  */
 			if (new_transport != transport) {
-- 
2.5.0
