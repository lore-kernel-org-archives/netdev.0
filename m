From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 09/17] RxRPC: Use iov_iter_count() in rxrpc_send_data() instead of the len argument
Date: Sat, 11 Apr 2015 22:18:20 +0100
Message-ID: <1428787108-13650-9-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37873 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Use iov_iter_count() in rxrpc_send_data() to get the remaining data length
instead of using the len argument as the len argument is now redundant.

Signed-off-by: David Howells <dhowells@redhat.com>
---
 net/rxrpc/ar-output.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index f48dc1a..de8d2f1 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -546,8 +546,6 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	call->tx_pending = NULL;
 
 	copied = 0;
-	if (len > iov_iter_count(&msg->msg_iter))
-		len = iov_iter_count(&msg->msg_iter);
 	do {
 		if (!skb) {
 			size_t size, chunk, max, space;
@@ -570,8 +568,8 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			max &= ~(call->conn->size_align - 1UL);
 
 			chunk = max;
-			if (chunk > len && !more)
-				chunk = len;
+			if (chunk > iov_iter_count(&msg->msg_iter) && !more)
+				chunk = iov_iter_count(&msg->msg_iter);
 
 			space = chunk + call->conn->size_align;
 			space &= ~(call->conn->size_align - 1UL);
@@ -614,11 +612,11 @@ static int rxrpc_send_data(struct kiocb *iocb,
 		sp = rxrpc_skb(skb);
 
 		/* append next segment of data to the current buffer */
-		if (len > 0) {
+		if (iov_iter_count(&msg->msg_iter) > 0) {
 			int copy = skb_tailroom(skb);
 			ASSERTCMP(copy, >, 0);
-			if (copy > len)
-				copy = len;
+			if (copy > iov_iter_count(&msg->msg_iter))
+				copy = iov_iter_count(&msg->msg_iter);
 			if (copy > sp->remain)
 				copy = sp->remain;
 
@@ -630,8 +628,6 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			sp->remain -= copy;
 			skb->mark += copy;
 			copied += copy;
-
-			len -= copy;
 		}
 
 		/* check for the far side aborting the call or a network error
@@ -640,7 +636,8 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			goto call_aborted;
 
 		/* add the packet to the send queue if it's now full */
-		if (sp->remain <= 0 || (!len && !more)) {
+		if (sp->remain <= 0 ||
+		    (iov_iter_count(&msg->msg_iter) == 0 && !more)) {
 			struct rxrpc_connection *conn = call->conn;
 			uint32_t seq;
 			size_t pad;
@@ -670,7 +667,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			sp->hdr.serviceId = conn->service_id;
 
 			sp->hdr.flags = conn->out_clientflag;
-			if (len == 0 && !more)
+			if (iov_iter_count(&msg->msg_iter) == 0 && !more)
 				sp->hdr.flags |= RXRPC_LAST_PACKET;
 			else if (CIRC_SPACE(call->acks_head, call->acks_tail,
 					    call->acks_winsz) > 1)
@@ -686,10 +683,11 @@ static int rxrpc_send_data(struct kiocb *iocb,
 
 			memcpy(skb->head, &sp->hdr,
 			       sizeof(struct rxrpc_header));
-			rxrpc_queue_packet(call, skb, !iov_iter_count(&msg->msg_iter) && !more);
+			rxrpc_queue_packet(call, skb,
+					   iov_iter_count(&msg->msg_iter) == 0 && !more);
 			skb = NULL;
 		}
-	} while (len > 0);
+	} while (iov_iter_count(&msg->msg_iter) > 0);
 
 success:
 	ret = copied;
-- 
2.1.4
