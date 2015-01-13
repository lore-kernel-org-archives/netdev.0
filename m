From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: remove redundant timer
	defined in tipc_sock struct
Date: Tue, 13 Jan 2015 17:07:48 +0800
Message-ID: <1421140068-3614-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org, ericalp@ericsson.com,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
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

Remove the redundant timer defined in tipc_sock structure, instead we
can directly reuse the sk_timer defined in sock structure.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2cec496..c9c34a6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -69,7 +69,6 @@
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
  * @probing_intv:
- * @timer:
  * @port: port - interacts with 'sk' and with the rest of the TIPC stack
  * @peer_name: the peer of the connection, if any
  * @conn_timeout: the time we can wait for an unresponded setup request
@@ -94,7 +93,6 @@ struct tipc_sock {
 	u32 pub_count;
 	u32 probing_state;
 	unsigned long probing_intv;
-	struct timer_list timer;
 	uint conn_timeout;
 	atomic_t dupl_rcvcnt;
 	bool link_cong;
@@ -360,7 +358,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		return -EINVAL;
 	}
 	msg_set_origport(msg, tsk->portid);
-	setup_timer(&tsk->timer, tipc_sk_timeout, (unsigned long)tsk);
+	setup_timer(&sk->sk_timer, tipc_sk_timeout, (unsigned long)tsk);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
@@ -514,7 +512,8 @@ static int tipc_release(struct socket *sock)
 
 	tipc_sk_withdraw(tsk, 0, NULL);
 	probing_state = tsk->probing_state;
-	if (del_timer_sync(&tsk->timer) && probing_state != TIPC_CONN_PROBING)
+	if (del_timer_sync(&sk->sk_timer) &&
+	    probing_state != TIPC_CONN_PROBING)
 		sock_put(sk);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
@@ -1136,7 +1135,8 @@ static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
 static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 				u32 peer_node)
 {
-	struct net *net = sock_net(&tsk->sk);
+	struct sock *sk = &tsk->sk;
+	struct net *net = sock_net(sk);
 	struct tipc_msg *msg = &tsk->phdr;
 
 	msg_set_destnode(msg, peer_node);
@@ -1148,8 +1148,7 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	tsk->probing_intv = CONN_PROBING_INTERVAL;
 	tsk->probing_state = TIPC_CONN_OK;
 	tsk->connected = 1;
-	if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
-		sock_hold(&tsk->sk);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
 	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
 }
@@ -2141,8 +2140,7 @@ static void tipc_sk_timeout(unsigned long data)
 				      0, peer_node, tn->own_addr,
 				      peer_port, tsk->portid, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
-		if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
-			sock_hold(sk);
+		sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
 	}
 	bh_unlock_sock(sk);
 	if (skb)
-- 
1.7.9.5


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
