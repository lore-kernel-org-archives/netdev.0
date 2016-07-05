From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/24] rxrpc: Fix handling of connection failure in
 client call creation
Date: Tue, 05 Jul 2016 14:13:22 +0100
Message-ID: <146772440282.21657.12592972329641602560.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If rxrpc_connect_call() fails during the creation of a client connection,
there are two bugs that we can hit that need fixing:

 (1) The call state should be moved to RXRPC_CALL_DEAD before the call
     cleanup phase is invoked.  If not, this can cause an assertion failure
     later.

 (2) call->link should be reinitialised after being deleted in
     rxrpc_new_client_call() - which otherwise leads to a failure later
     when the call cleanup attempts to delete the link again.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index ad933daae13b..6223a7ed831f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -425,9 +425,10 @@ error:
 	rxrpc_put_call(call);
 
 	write_lock_bh(&rxrpc_call_lock);
-	list_del(&call->link);
+	list_del_init(&call->link);
 	write_unlock_bh(&rxrpc_call_lock);
 
+	call->state = RXRPC_CALL_DEAD;
 	rxrpc_put_call(call);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
@@ -439,6 +440,7 @@ error:
 	 */
 found_user_ID_now_present:
 	write_unlock(&rx->call_lock);
+	call->state = RXRPC_CALL_DEAD;
 	rxrpc_put_call(call);
 	_leave(" = -EEXIST [%p]", call);
 	return ERR_PTR(-EEXIST);
