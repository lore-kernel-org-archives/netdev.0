From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 11/19] rxrpc: Access socket accept queue under
 right lock
Date: Thu, 30 Jun 2016 15:12:00 +0100
Message-ID: <146729592088.26306.12478214428736330734.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The socket's accept queue (socket->acceptq) should be accessed under
socket->call_lock, not under the connection lock.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 638d66df284a..fc32aa5764a2 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -1089,7 +1089,7 @@ void rxrpc_process_call(struct work_struct *work)
 
 		if (call->state == RXRPC_CALL_SERVER_SECURING) {
 			_debug("securing");
-			write_lock(&call->conn->lock);
+			write_lock(&call->socket->call_lock);
 			if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
 			    !test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
 				_debug("not released");
@@ -1097,7 +1097,7 @@ void rxrpc_process_call(struct work_struct *work)
 				list_move_tail(&call->accept_link,
 					       &call->socket->acceptq);
 			}
-			write_unlock(&call->conn->lock);
+			write_unlock(&call->socket->call_lock);
 			read_lock(&call->state_lock);
 			if (call->state < RXRPC_CALL_COMPLETE)
 				set_bit(RXRPC_CALL_EV_POST_ACCEPT, &call->events);
