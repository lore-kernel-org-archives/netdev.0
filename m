From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 11/16] tipc: create
	TIPC_PROBING/TIPC_ESTABLISHED as new sk_states
Date: Thu, 27 Oct 2016 16:22:32 +0200
Message-ID: <1477578157-13256-12-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now, tipc maintains probing state for connected sockets in
tsk->probing_state variable.

In this commit, we express this information as socket states and
this remove the variable. The sk_state is set to TIPC_PROBING
instead of setting probing_state to TIPC_CONN_PROBING. Similarly
sk_state is set to TIPC_ESTABLISHED instead of TIPC_CONN_OK.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc.h |  2 ++
 net/tipc/socket.c         | 23 +++++++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
index 8a107085f268..189bfed0363c 100644
--- a/include/uapi/linux/tipc.h
+++ b/include/uapi/linux/tipc.h
@@ -181,6 +181,8 @@ struct tipc_event {
  */
 enum {
 	TIPC_LISTEN = 1,
+	TIPC_PROBING,
+	TIPC_ESTABLISHED,
 };
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7c9c97363e81..04d388c063a6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -47,8 +47,6 @@
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
 #define TIPC_FWD_MSG		1
-#define TIPC_CONN_OK		0
-#define TIPC_CONN_PROBING	1
 #define TIPC_MAX_PORT		0xffffffff
 #define TIPC_MIN_PORT		1
 
@@ -345,6 +343,7 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 static int tipc_set_sk_state(struct sock *sk, int state)
 {
 	int oldstate = sk->sk_socket->state;
+	int oldsk_state = sk->sk_state;
 	int res = -EINVAL;
 
 	switch (state) {
@@ -352,6 +351,17 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		if (oldstate == SS_UNCONNECTED)
 			res = 0;
 		break;
+	case TIPC_PROBING:
+		if (oldsk_state == TIPC_ESTABLISHED)
+			res = 0;
+		break;
+	case TIPC_ESTABLISHED:
+		if (oldsk_state == TIPC_PROBING ||
+		    oldsk_state == TIPC_ESTABLISHED ||
+		    oldstate == SS_CONNECTING ||
+		    oldstate == SS_UNCONNECTED)
+			res = 0;
+		break;
 	}
 
 	if (res)
@@ -855,7 +865,8 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
 	if (!tsk_peer_msg(tsk, hdr))
 		goto exit;
 
-	tsk->probing_state = TIPC_CONN_OK;
+	if (tipc_set_sk_state(sk, TIPC_ESTABLISHED))
+		goto exit;
 
 	if (mtyp == CONN_PROBE) {
 		msg_set_type(hdr, CONN_PROBE_REPLY);
@@ -1195,8 +1206,8 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	tsk->probing_state = TIPC_CONN_OK;
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
+	tipc_set_sk_state(sk, TIPC_ESTABLISHED);
 	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
 	tsk->peer_caps = tipc_node_get_capabilities(net, peer_node);
@@ -2260,7 +2271,7 @@ static void tipc_sk_timeout(unsigned long data)
 	peer_port = tsk_peer_port(tsk);
 	peer_node = tsk_peer_node(tsk);
 
-	if (tsk->probing_state == TIPC_CONN_PROBING) {
+	if (sk->sk_state == TIPC_PROBING) {
 		if (!sock_owned_by_user(sk)) {
 			sk->sk_socket->state = SS_DISCONNECTING;
 			tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
@@ -2278,7 +2289,7 @@ static void tipc_sk_timeout(unsigned long data)
 	skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
 			      INT_H_SIZE, 0, peer_node, own_node,
 			      peer_port, tsk->portid, TIPC_OK);
-	tsk->probing_state = TIPC_CONN_PROBING;
+	tipc_set_sk_state(sk, TIPC_PROBING);
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
 	bh_unlock_sock(sk);
 	if (skb)
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
