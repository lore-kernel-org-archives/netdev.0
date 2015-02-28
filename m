From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] rxrpc: terminate retrans loop when sending of skb fails
Date: Sat, 28 Feb 2015 11:51:36 +0100
Message-ID: <1425120697-27791-1-git-send-email-fw@strlen.de>
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49992 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbbB1KwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 05:52:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Typo, 'stop' is never set to true.
Seems intent is to not attempt to retransmit more packets after sendmsg
returns an error.

This change is based on code inspection only.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/rxrpc/ar-ack.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index c6be17a..4040418 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -218,7 +218,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	struct rxrpc_header *hdr;
 	struct sk_buff *txb;
 	unsigned long *p_txb, resend_at;
-	int loop, stop;
+	bool stop;
+	int loop;
 	u8 resend;
 
 	_enter("{%d,%d,%d,%d},",
@@ -226,7 +227,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	       atomic_read(&call->sequence),
 	       CIRC_CNT(call->acks_head, call->acks_tail, call->acks_winsz));
 
-	stop = 0;
+	stop = false;
 	resend = 0;
 	resend_at = 0;
 
@@ -255,7 +256,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 			_proto("Tx DATA %%%u { #%d }",
 			       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
 			if (rxrpc_send_packet(call->conn->trans, txb) < 0) {
-				stop = 0;
+				stop = true;
 				sp->resend_at = jiffies + 3;
 			} else {
 				sp->resend_at =
-- 
2.0.5
