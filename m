From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/14] rxrpc: Purge the to_be_accepted queue on
 socket release
Date: Sun, 18 Sep 2016 00:18:26 +0100
Message-ID: <147415430646.17897.4833203211143872574.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Purge the queue of to_be_accepted calls on socket release.  Note that
purging sock_calls doesn't release the ref owned by to_be_accepted.

Probably the sock_calls list is redundant given a purges of the recvmsg_q,
the to_be_accepted queue and the calls tree.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 22f9b0d1a138..b0ffbd9664e6 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -476,6 +476,16 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
 
 	_enter("%p", rx);
 
+	while (!list_empty(&rx->to_be_accepted)) {
+		call = list_entry(rx->to_be_accepted.next,
+				  struct rxrpc_call, accept_link);
+		list_del(&call->accept_link);
+		rxrpc_abort_call("SKR", call, 0, RX_CALL_DEAD, ECONNRESET);
+		rxrpc_send_call_packet(call, RXRPC_PACKET_TYPE_ABORT);
+		rxrpc_release_call(rx, call);
+		rxrpc_put_call(call, rxrpc_call_put);
+	}
+
 	while (!list_empty(&rx->sock_calls)) {
 		call = list_entry(rx->sock_calls.next,
 				  struct rxrpc_call, sock_link);
