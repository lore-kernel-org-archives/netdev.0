From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/14] rxrpc: Fix retransmission algorithm
Date: Sun, 18 Sep 2016 00:19:00 +0100
Message-ID: <147415434067.17897.11639501706857055164.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936187AbcIQXTD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:19:03 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the retransmission algorithm use for-loops instead of do-loops and
move the counter increments into the for-statement increment slots.

Though the do-loops are slighly more efficient since there will be at least
one pass through the each loop, the counter increments are harder to get
right as the continue-statements skip them.

Without this, if there are any positive acks within the loop, the do-loop
will cycle forever because the counter increment is never done.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 9367c3be31eb..f0cabc48a1b7 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -163,8 +163,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	 */
 	now = jiffies;
 	resend_at = now + rxrpc_resend_timeout;
-	seq = cursor + 1;
-	do {
+	for (seq = cursor + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		annotation = call->rxtx_annotations[ix];
 		if (annotation == RXRPC_TX_ANNO_ACK)
@@ -184,8 +183,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 		/* Okay, we need to retransmit a packet. */
 		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS;
-		seq++;
-	} while (before_eq(seq, top));
+	}
 
 	call->resend_at = resend_at;
 
@@ -194,8 +192,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	 * lock is dropped, it may clear some of the retransmission markers for
 	 * packets that it soft-ACKs.
 	 */
-	seq = cursor + 1;
-	do {
+	for (seq = cursor + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		annotation = call->rxtx_annotations[ix];
 		if (annotation != RXRPC_TX_ANNO_RETRANS)
@@ -237,8 +234,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 		if (after(call->tx_hard_ack, seq))
 			seq = call->tx_hard_ack;
-		seq++;
-	} while (before_eq(seq, top));
+	}
 
 out_unlock:
 	spin_unlock_bh(&call->lock);
