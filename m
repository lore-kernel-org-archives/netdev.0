From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/7] rxrpc: Note a successfully aborted kernel
 operation
Date: Thu, 06 Apr 2017 11:22:30 +0100
Message-ID: <149147414996.21583.14783666788381967193.stgit@warthog.procyon.org.uk>
References: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make rxrpc_kernel_abort_call() return an indication as to whether it
actually aborted the operation or not so that kafs can trace the failure of
the operation.  Note that 'success' in this context means changing the
state of the call, not necessarily successfully transmitting an ABORT
packet.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/net/af_rxrpc.h |    2 +-
 net/rxrpc/sendmsg.c    |   12 ++++++++----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 1061a472a3e3..b5f5187f488c 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -39,7 +39,7 @@ int rxrpc_kernel_send_data(struct socket *, struct rxrpc_call *,
 			   struct msghdr *, size_t);
 int rxrpc_kernel_recv_data(struct socket *, struct rxrpc_call *,
 			   void *, size_t, size_t *, bool, u32 *);
-void rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
+bool rxrpc_kernel_abort_call(struct socket *, struct rxrpc_call *,
 			     u32, int, const char *);
 void rxrpc_kernel_end_call(struct socket *, struct rxrpc_call *);
 void rxrpc_kernel_get_peer(struct socket *, struct rxrpc_call *,
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 601c0a3e31a2..e836fa00dc5a 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -642,20 +642,24 @@ EXPORT_SYMBOL(rxrpc_kernel_send_data);
  * @error: Local error value
  * @why: 3-char string indicating why.
  *
- * Allow a kernel service to abort a call, if it's still in an abortable state.
+ * Allow a kernel service to abort a call, if it's still in an abortable state
+ * and return true if the call was aborted, false if it was already complete.
  */
-void rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
+bool rxrpc_kernel_abort_call(struct socket *sock, struct rxrpc_call *call,
 			     u32 abort_code, int error, const char *why)
 {
+	bool aborted;
+
 	_enter("{%d},%d,%d,%s", call->debug_id, abort_code, error, why);
 
 	mutex_lock(&call->user_mutex);
 
-	if (rxrpc_abort_call(why, call, 0, abort_code, error))
+	aborted = rxrpc_abort_call(why, call, 0, abort_code, error);
+	if (aborted)
 		rxrpc_send_abort_packet(call);
 
 	mutex_unlock(&call->user_mutex);
-	_leave("");
+	return aborted;
 }
 
 EXPORT_SYMBOL(rxrpc_kernel_abort_call);
