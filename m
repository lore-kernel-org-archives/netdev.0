From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 3/3] tipc: close the connection if
	protocol messages contain errors
Date: Wed, 26 Apr 2017 10:05:02 +0200
Message-ID: <1493193902-18332-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1493193902-18332-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1493193902-18332-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a socket is shutting down, we notify the peer node about the
connection termination by reusing an incoming message if possible.
If the last received message was a connection acknowledgment
message, we reverse this message and set the error code to
TIPC_ERR_NO_PORT and send it to peer.

In tipc_sk_proto_rcv(), we never check for message errors while
processing the connection acknowledgment or probe messages. Thus
this message performs the usual flow control accounting and leaves
the session hanging.

In this commit, we terminate the connection when we receive such
error messages.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 38c367f6ced4..bdce99f9407a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -866,6 +866,14 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
 	if (!tsk_peer_msg(tsk, hdr))
 		goto exit;
 
+	if (unlikely(msg_errcode(hdr))) {
+		tipc_set_sk_state(sk, TIPC_DISCONNECTING);
+		tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
+				      tsk_peer_port(tsk));
+		sk->sk_state_change(sk);
+		goto exit;
+	}
+
 	tsk->probe_unacked = false;
 
 	if (mtyp == CONN_PROBE) {
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
