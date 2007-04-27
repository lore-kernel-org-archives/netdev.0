From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 20:20:37 -0700 (PDT)
Message-ID: <20070426.202037.94552269.davem@davemloft.net>
References: <20070426.161522.76328746.davem@davemloft.net>
	<20070426.200809.04441500.davem@davemloft.net>
	<20070426.201213.85816532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755204AbXD0DU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 23:20:29 -0400
In-Reply-To: <20070426.201213.85816532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Apr 2007 20:12:13 -0700 (PDT)

> And even more problems, what the heck are you doing here?

And even more:

commit 68c708fd5e90f6d178c84bb7e641589eb2842319
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Apr 26 20:20:21 2007 -0700

    [RXRPC]: Fix pointers passed to bitops.
    
      CC [M]  net/rxrpc/ar-input.o
    net/rxrpc/ar-input.c: In function $,1rx(Brxrpc_fast_process_data$,1ry(B:
    net/rxrpc/ar-input.c:171: warning: passing argument 2 of $,1rx(B__test_and_set_bit$,1ry(B from incompatible pointer type
    net/rxrpc/ar-input.c:180: warning: passing argument 2 of $,1rx(B__clear_bit$,1ry(B from incompatible pointer type
    net/rxrpc/ar-input.c:218: warning: passing argument 2 of $,1rx(B__clear_bit$,1ry(B from incompatible pointer type
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index ceb5d61..91b5bbb 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -168,7 +168,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 	/* we may already have the packet in the out of sequence queue */
 	ackbit = seq - (call->rx_data_eaten + 1);
 	ASSERTCMP(ackbit, >=, 0);
-	if (__test_and_set_bit(ackbit, &call->ackr_window)) {
+	if (__test_and_set_bit(ackbit, call->ackr_window)) {
 		_debug("dup oos #%u [%u,%u]",
 		       seq, call->rx_data_eaten, call->rx_data_post);
 		ack = RXRPC_ACK_DUPLICATE;
@@ -177,7 +177,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 
 	if (seq >= call->ackr_win_top) {
 		_debug("exceed #%u [%u]", seq, call->ackr_win_top);
-		__clear_bit(ackbit, &call->ackr_window);
+		__clear_bit(ackbit, call->ackr_window);
 		ack = RXRPC_ACK_EXCEEDS_WINDOW;
 		goto discard_and_ack;
 	}
@@ -215,7 +215,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 	ret = rxrpc_queue_rcv_skb(call, skb, false, terminal);
 	if (ret < 0) {
 		if (ret == -ENOMEM || ret == -ENOBUFS) {
-			__clear_bit(ackbit, &call->ackr_window);
+			__clear_bit(ackbit, call->ackr_window);
 			ack = RXRPC_ACK_NOSPACE;
 			goto discard_and_ack;
 		}
