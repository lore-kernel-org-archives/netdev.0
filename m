From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] tipc: avoid packets leaking on socket
	receive queue
Date: Sun, 22 Nov 2015 15:46:05 +0800
Message-ID: <1448178365-14827-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>, <jon.maloy@ericsson.com>
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

Even if we drain receive queue thoroughly in tipc_release() after tipc
socket is removed from rhashtable, it is possible that some packets
are in flight because some CPU runs receiver and did rhashtable lookup
before we removed socket. They will achieve receive queue, but nobody
delete them at all. To avoid this leak, we register a private socket
destructor to purge receive queue, meaning releasing packets pending
on receive queue will be delayed until the last reference of tipc
socket will be released.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 552dbab..b53246f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -105,6 +105,7 @@ struct tipc_sock {
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static void tipc_data_ready(struct sock *sk);
 static void tipc_write_space(struct sock *sk);
+static void tipc_sock_destruct(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
@@ -381,6 +382,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	sk->sk_rcvbuf = sysctl_tipc_rmem[1];
 	sk->sk_data_ready = tipc_data_ready;
 	sk->sk_write_space = tipc_write_space;
+	sk->sk_destruct = tipc_sock_destruct;
 	tsk->conn_timeout = CONN_TIMEOUT_DEFAULT;
 	tsk->sent_unacked = 0;
 	atomic_set(&tsk->dupl_rcvcnt, 0);
@@ -470,9 +472,6 @@ static int tipc_release(struct socket *sock)
 		tipc_node_remove_conn(net, dnode, tsk->portid);
 	}
 
-	/* Discard any remaining (connection-based) messages in receive queue */
-	__skb_queue_purge(&sk->sk_receive_queue);
-
 	/* Reject any messages that accumulated in backlog queue */
 	sock->state = SS_DISCONNECTING;
 	release_sock(sk);
@@ -1515,6 +1514,11 @@ static void tipc_data_ready(struct sock *sk)
 	rcu_read_unlock();
 }
 
+static void tipc_sock_destruct(struct sock *sk)
+{
+	__skb_queue_purge(&sk->sk_receive_queue);
+}
+
 /**
  * filter_connect - Handle all incoming messages for a connection-based socket
  * @tsk: TIPC socket
-- 
1.7.9.5


------------------------------------------------------------------------------
