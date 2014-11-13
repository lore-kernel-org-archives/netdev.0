From: Pranith Kumar <bobby.prani@gmail.com>
Subject: [PATCH 16/16] rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 14:24:22 -0500
Message-ID: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Cc: paulmck@linux.vnet.ibm.com
To: "David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recently lockless_dereference() was added which can be used in place of
hard-coding smp_read_barrier_depends(). The following PATCH makes the change.

Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>
---
 net/rxrpc/ar-ack.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index c6be17a..9237448 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -234,8 +234,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	     loop != call->acks_head || stop;
 	     loop = (loop + 1) &  (call->acks_winsz - 1)
 	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
+		p_txb = lockless_dereference(call)->acks_window + loop;
 		if (*p_txb & 1)
 			continue;
 
@@ -303,8 +302,7 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 	     loop != call->acks_head;
 	     loop = (loop + 1) &  (call->acks_winsz - 1)
 	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
+		p_txb = lockless_dereference(call)->acks_window + loop;
 		txb = (struct sk_buff *) (*p_txb & ~1);
 		sp = rxrpc_skb(txb);
 
@@ -354,9 +352,10 @@ static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
 	resend = 0;
 	resend_at = 0;
 	for (loop = 0; loop < ack->nAcks; loop++) {
-		p_txb = call->acks_window;
-		p_txb += (call->acks_tail + loop) & (call->acks_winsz - 1);
-		smp_read_barrier_depends();
+		struct rxrpc_call *callp = lockless_dereference(call);
+
+		p_txb = callp->acks_window;
+		p_txb += (callp->acks_tail + loop) & (callp->acks_winsz - 1);
 		txb = (struct sk_buff *) (*p_txb & ~1);
 		sp = rxrpc_skb(txb);
 
@@ -385,8 +384,7 @@ static int rxrpc_process_soft_ACKs(struct rxrpc_call *call,
 	     loop != call->acks_head;
 	     loop = (loop + 1) &  (call->acks_winsz - 1)
 	     ) {
-		p_txb = call->acks_window + loop;
-		smp_read_barrier_depends();
+		p_txb = lockless_dereference(call)->acks_window + loop;
 		txb = (struct sk_buff *) (*p_txb & ~1);
 		sp = rxrpc_skb(txb);
 
@@ -432,8 +430,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 	ASSERTCMP(hard - call->acks_hard, <=, win);
 
 	while (call->acks_hard < hard) {
-		smp_read_barrier_depends();
-		_skb = call->acks_window[tail] & ~1;
+		_skb = lockless_dereference(call)->acks_window[tail] & ~1;
 		rxrpc_free_skb((struct sk_buff *) _skb);
 		old_tail = tail;
 		tail = (tail + 1) & (call->acks_winsz - 1);
@@ -577,8 +574,7 @@ static void rxrpc_zap_tx_window(struct rxrpc_call *call)
 	call->acks_window = NULL;
 
 	while (CIRC_CNT(call->acks_head, call->acks_tail, winsz) > 0) {
-		tail = call->acks_tail;
-		smp_read_barrier_depends();
+		tail = lockless_dereference(call)->acks_tail;
 		_skb = acks_window[tail] & ~1;
 		smp_mb();
 		call->acks_tail = (call->acks_tail + 1) & (winsz - 1);
-- 
1.9.1
