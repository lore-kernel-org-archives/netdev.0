From: David Howells <dhowells@redhat.com>
Subject: [PATCH 09/13] rxrpc: Use ACCESS_ONCE() when accessing circular
 buffer pointers
Date: Fri, 04 Mar 2016 16:38:08 +0000
Message-ID: <20160304163808.31057.35519.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ACCESS_ONCE() when accessing the other-end pointer into a circular
buffer as it's possible the other-end pointer might change whilst we're
doing this, and if we access it twice, we might get some weird things
happening.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-output.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 353f5c9141ea..14c8df6b7f41 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -401,7 +401,8 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 	int ret;
 
 	_enter(",{%d},%ld",
-	       CIRC_SPACE(call->acks_head, call->acks_tail, call->acks_winsz),
+	       CIRC_SPACE(call->acks_head, ACCESS_ONCE(call->acks_tail),
+			  call->acks_winsz),
 	       *timeo);
 
 	add_wait_queue(&call->tx_waitq, &myself);
@@ -409,7 +410,7 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		ret = 0;
-		if (CIRC_SPACE(call->acks_head, call->acks_tail,
+		if (CIRC_SPACE(call->acks_head, ACCESS_ONCE(call->acks_tail),
 			       call->acks_winsz) > 0)
 			break;
 		if (signal_pending(current)) {
@@ -570,7 +571,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			_debug("alloc");
 
-			if (CIRC_SPACE(call->acks_head, call->acks_tail,
+			if (CIRC_SPACE(call->acks_head,
+				       ACCESS_ONCE(call->acks_tail),
 				       call->acks_winsz) <= 0) {
 				ret = -EAGAIN;
 				if (msg->msg_flags & MSG_DONTWAIT)
@@ -686,7 +688,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			sp->hdr.flags = conn->out_clientflag;
 			if (msg_data_left(msg) == 0 && !more)
 				sp->hdr.flags |= RXRPC_LAST_PACKET;
-			else if (CIRC_SPACE(call->acks_head, call->acks_tail,
+			else if (CIRC_SPACE(call->acks_head,
+					    ACCESS_ONCE(call->acks_tail),
 					    call->acks_winsz) > 1)
 				sp->hdr.flags |= RXRPC_MORE_PACKETS;
 			if (more && seq & 1)
