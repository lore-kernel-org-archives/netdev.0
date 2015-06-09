From: <erik.hugne@ericsson.com>
Subject: [PATCH] tipc: disconnect socket directly after
	probe failure
Date: Tue, 9 Jun 2015 17:27:12 +0200
Message-ID: <1433863632-12699-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

If the TIPC connection timer expires in a probing state, a
self abort message is supposed to be generated and delivered
to the local socket. This is currently broken, and the abort
message is actually sent out to the peer node with invalid
addressing information. This will cause the link to enter
a constant retransmission state and eventually reset.
We fix this by removing the self-abort message creation and
tear down connection immediately instead.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 30ea82a..46b6ed5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2140,11 +2140,17 @@ static void tipc_sk_timeout(unsigned long data)
 	peer_node = tsk_peer_node(tsk);
 
 	if (tsk->probing_state == TIPC_CONN_PROBING) {
-		/* Previous probe not answered -> self abort */
-		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
-				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
-				      own_node, peer_node, tsk->portid,
-				      peer_port, TIPC_ERR_NO_PORT);
+		if (!sock_owned_by_user(sk)) {
+			sk->sk_socket->state = SS_DISCONNECTING;
+			tsk->connected = 0;
+			tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
+					      tsk_peer_port(tsk));
+			sk->sk_state_change(sk);
+		} else {
+			/* Try again later */
+			sk_reset_timer(sk, &sk->sk_timer, (HZ / 20));
+		}
+
 	} else {
 		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
 				      INT_H_SIZE, 0, peer_node, own_node,
-- 
2.1.4


------------------------------------------------------------------------------
