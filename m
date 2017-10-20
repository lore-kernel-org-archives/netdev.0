From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Don't release call mutex on error pointer
Date: Fri, 20 Oct 2017 17:01:22 +0100
Message-ID: <150851528227.19340.4842940319829659889.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't release call mutex at the end of rxrpc_kernel_begin_call() if the
call pointer actually holds an error value.

Fixes: 540b1c48c37a ("rxrpc: Fix deadlock between call creation and sendmsg/recvmsg")
Reported-by: Marc Dionne <marc.dionne@auristor.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 73c980e26581..054e32872808 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -311,10 +311,11 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, tx_total_len,
 				     gfp);
 	/* The socket has been unlocked. */
-	if (!IS_ERR(call))
+	if (!IS_ERR(call)) {
 		call->notify_rx = notify_rx;
+		mutex_unlock(&call->user_mutex);
+	}
 
-	mutex_unlock(&call->user_mutex);
 	_leave(" = %p", call);
 	return call;
 }
