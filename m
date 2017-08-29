From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/7] rxrpc: Don't negate call->error before
 returning it
Date: Tue, 29 Aug 2017 13:27:14 +0100
Message-ID: <150400963459.21371.7226405489572080523.stgit@warthog.procyon.org.uk>
References: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41809 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbdH2M1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 08:27:16 -0400
In-Reply-To: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call->error is stored as 0 or a negative error code.  Don't negate this
value (ie. make it positive) before returning it from a kernel function
(though it should still be negated before passing to userspace through a
control message).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index b0d2cda6ec0a..bc7f0241d92b 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -61,7 +61,7 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 			  call->cong_cwnd + call->cong_extra))
 			break;
 		if (call->state >= RXRPC_CALL_COMPLETE) {
-			ret = -call->error;
+			ret = call->error;
 			break;
 		}
 		if (signal_pending(current)) {
@@ -364,8 +364,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 call_terminated:
 	rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
-	_leave(" = %d", -call->error);
-	return -call->error;
+	_leave(" = %d", call->error);
+	return call->error;
 
 maybe_error:
 	if (copied)
@@ -660,7 +660,7 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 		break;
 	case RXRPC_CALL_COMPLETE:
 		read_lock_bh(&call->state_lock);
-		ret = -call->error;
+		ret = call->error;
 		read_unlock_bh(&call->state_lock);
 		break;
 	default:
