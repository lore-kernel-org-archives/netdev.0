From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 07/14] SCTP: Fix a potential race between timers and receive path.
Date: Mon, 12 Nov 2007 11:38:22 -0500
Message-ID: <11948855153314-git-send-email-vladislav.yasevich@hp.com>
References: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56246 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbXKLQig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:38:36 -0500
In-Reply-To: <11948855091808-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a possible race condition where the timer code will
free the association and the next packet in the queue will also
attempt to free the same association.

The example is, when we receive an ABORT at about the same time
as the retransmission timer fires.  If the timer wins the race,
it will free the association.  Once it releases the lock, the
queue processing will recieve the ABORT and will try to free
the association again.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/inqueue.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index f10fe7f..cf4b7eb 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -90,6 +90,10 @@ void sctp_inq_free(struct sctp_inq *queue)
 void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
 {
 	/* Directly call the packet handling routine. */
+	if (chunk->rcvr->dead) {
+		sctp_chunk_free(chunk);
+		return;
+	}
 
 	/* We are now calling this either from the soft interrupt
 	 * or from the backlog processing.
-- 
1.5.2.4

