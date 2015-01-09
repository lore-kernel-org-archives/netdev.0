From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/16] tipc: feed tipc sock
	pointer to tipc_sk_timeout routine
Date: Fri, 9 Jan 2015 15:27:02 +0800
Message-ID: <1420788433-17960-6-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In order to make tipc socket table aware of namespace, a networking
namespace instance must be passed to tipc_sk_lookup(), allowing it
to look up tipc socket instance with a given port ID from a concrete
socket table. However, as now tipc_sk_timeout() only has one port ID
parameter and is not namespace aware, it's unable to obtain a correct
socket instance through tipc_sk_lookup() just with a port ID,
especially after namespace is completely supported.

If port ID is replaced with socket instance as tipc_sk_timeout()'s
parameter, it's unnecessary to look up socket table. But as the timer
handler - tipc_sk_timeout() is run asynchronously, socket reference
must be held before its timer is launched, and must be carefully
checked to identify whether the socket reference needs to be put or
not when its timer is terminated.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   33 ++++++++++++++++-----------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e16197e..c58f66b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -110,7 +110,7 @@ static void tipc_write_space(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
-static void tipc_sk_timeout(unsigned long portid);
+static void tipc_sk_timeout(unsigned long data);
 static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq);
 static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
@@ -361,7 +361,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		return -EINVAL;
 	}
 	msg_set_origport(msg, tsk->portid);
-	setup_timer(&tsk->timer, tipc_sk_timeout, tsk->portid);
+	setup_timer(&tsk->timer, tipc_sk_timeout, (unsigned long)tsk);
 	sk->sk_backlog_rcv = tipc_backlog_rcv;
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
@@ -475,7 +475,7 @@ static int tipc_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
-	u32 dnode;
+	u32 dnode, probing_state;
 
 	/*
 	 * Exit if socket isn't fully initialized (occurs when a failed accept()
@@ -511,7 +511,9 @@ static int tipc_release(struct socket *sock)
 	}
 
 	tipc_sk_withdraw(tsk, 0, NULL);
-	del_timer_sync(&tsk->timer);
+	probing_state = tsk->probing_state;
+	if (del_timer_sync(&tsk->timer) && probing_state != TIPC_CONN_PROBING)
+		sock_put(sk);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
 		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
@@ -1141,7 +1143,8 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	tsk->probing_intv = CONN_PROBING_INTERVAL;
 	tsk->probing_state = TIPC_CONN_OK;
 	tsk->connected = 1;
-	mod_timer(&tsk->timer, jiffies + tsk->probing_intv);
+	if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
+		sock_hold(&tsk->sk);
 	tipc_node_add_conn(peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(peer_node, tsk->portid);
 }
@@ -2096,18 +2099,13 @@ restart:
 	return res;
 }
 
-static void tipc_sk_timeout(unsigned long portid)
+static void tipc_sk_timeout(unsigned long data)
 {
-	struct tipc_sock *tsk;
-	struct sock *sk;
+	struct tipc_sock *tsk = (struct tipc_sock *)data;
+	struct sock *sk = &tsk->sk;
 	struct sk_buff *skb = NULL;
 	u32 peer_port, peer_node;
 
-	tsk = tipc_sk_lookup(portid);
-	if (!tsk)
-		return;
-
-	sk = &tsk->sk;
 	bh_lock_sock(sk);
 	if (!tsk->connected) {
 		bh_unlock_sock(sk);
@@ -2120,18 +2118,19 @@ static void tipc_sk_timeout(unsigned long portid)
 		/* Previous probe not answered -> self abort */
 		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, tipc_own_addr,
-				      peer_node, portid, peer_port,
+				      peer_node, tsk->portid, peer_port,
 				      TIPC_ERR_NO_PORT);
 	} else {
 		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
 				      0, peer_node, tipc_own_addr,
-				      peer_port, portid, TIPC_OK);
+				      peer_port, tsk->portid, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
-		mod_timer(&tsk->timer, jiffies + tsk->probing_intv);
+		if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
+			sock_hold(sk);
 	}
 	bh_unlock_sock(sk);
 	if (skb)
-		tipc_link_xmit_skb(skb, peer_node, portid);
+		tipc_link_xmit_skb(skb, peer_node, tsk->portid);
 exit:
 	sock_put(sk);
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
