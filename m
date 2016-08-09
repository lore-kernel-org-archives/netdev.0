From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 2/6] rxrpc: Need to flag call as being released on
 connect failure
Date: Tue, 09 Aug 2016 17:33:25 +0100
Message-ID: <147076040590.13232.15006934873155574657.stgit@warthog.procyon.org.uk>
References: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If rxrpc_new_client_call() fails to make a connection, the call record that
it allocated needs to be marked as RXRPC_CALL_RELEASED before it is passed
to rxrpc_put_call() to indicate that it no longer has any attachment to the
AF_RXRPC socket.

Without this, an assertion failure may occur at:

	net/rxrpc/call_object:635

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index e8c953c48cb8..ae057e0740f3 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -275,6 +275,7 @@ error:
 	list_del_init(&call->link);
 	write_unlock_bh(&rxrpc_call_lock);
 
+	set_bit(RXRPC_CALL_RELEASED, &call->flags);
 	call->state = RXRPC_CALL_DEAD;
 	rxrpc_put_call(call);
 	_leave(" = %d", ret);
@@ -287,6 +288,7 @@ error:
 	 */
 found_user_ID_now_present:
 	write_unlock(&rx->call_lock);
+	set_bit(RXRPC_CALL_RELEASED, &call->flags);
 	call->state = RXRPC_CALL_DEAD;
 	rxrpc_put_call(call);
 	_leave(" = -EEXIST [%p]", call);
