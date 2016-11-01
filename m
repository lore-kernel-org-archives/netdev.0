From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 11/16] tipc: create
	TIPC_ESTABLISHED as a new sk_state
Date: Tue, 1 Nov 2016 14:02:44 +0100
Message-ID: <1478005369-17239-12-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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
this remove the variable. We set probe_unacked flag when a probe
is sent out and reset it if we receive a reply. Instead of the
probing state TIPC_CONN_OK, we create a new state TIPC_ESTABLISHED.

There is no functional change in this commit.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
v2: remove TIPC_PROBING state and replace it with probe_unacked flag.
---
 net/tipc/socket.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ce7d9be8833c..9215e2144b6a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -47,13 +47,12 @@
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 #define CONN_PROBING_INTERVAL	msecs_to_jiffies(3600000)  /* [ms] => 1 h */
 #define TIPC_FWD_MSG		1
-#define TIPC_CONN_OK		0
-#define TIPC_CONN_PROBING	1
 #define TIPC_MAX_PORT		0xffffffff
 #define TIPC_MIN_PORT		1
 
 enum {
 	TIPC_LISTEN = TCP_LISTEN,
+	TIPC_ESTABLISHED = TCP_ESTABLISHED,
 };
 
 /**
@@ -88,9 +87,9 @@ struct tipc_sock {
 	struct list_head sock_list;
 	struct list_head publications;
 	u32 pub_count;
-	u32 probing_state;
 	uint conn_timeout;
 	atomic_t dupl_rcvcnt;
+	bool probe_unacked;
 	bool link_cong;
 	u16 snt_unacked;
 	u16 snd_win;
@@ -356,6 +355,11 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 		if (oldstate == SS_UNCONNECTED)
 			res = 0;
 		break;
+	case TIPC_ESTABLISHED:
+		if (oldstate == SS_CONNECTING ||
+		    oldstate == SS_UNCONNECTED)
+			res = 0;
+		break;
 	}
 
 	if (!res)
@@ -858,7 +862,7 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
 	if (!tsk_peer_msg(tsk, hdr))
 		goto exit;
 
-	tsk->probing_state = TIPC_CONN_OK;
+	tsk->probe_unacked = false;
 
 	if (mtyp == CONN_PROBE) {
 		msg_set_type(hdr, CONN_PROBE_REPLY);
@@ -1198,8 +1202,8 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	tsk->probing_state = TIPC_CONN_OK;
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
+	tipc_set_sk_state(sk, TIPC_ESTABLISHED);
 	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
 	tsk->peer_caps = tipc_node_get_capabilities(net, peer_node);
@@ -2263,7 +2267,7 @@ static void tipc_sk_timeout(unsigned long data)
 	peer_port = tsk_peer_port(tsk);
 	peer_node = tsk_peer_node(tsk);
 
-	if (tsk->probing_state == TIPC_CONN_PROBING) {
+	if (tsk->probe_unacked) {
 		if (!sock_owned_by_user(sk)) {
 			sk->sk_socket->state = SS_DISCONNECTING;
 			tipc_node_remove_conn(sock_net(sk), tsk_peer_node(tsk),
@@ -2281,7 +2285,7 @@ static void tipc_sk_timeout(unsigned long data)
 	skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
 			      INT_H_SIZE, 0, peer_node, own_node,
 			      peer_port, tsk->portid, TIPC_OK);
-	tsk->probing_state = TIPC_CONN_PROBING;
+	tsk->probe_unacked = true;
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
 	bh_unlock_sock(sk);
 	if (skb)
-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
