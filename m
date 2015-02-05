From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/9] tipc: use existing
	sk_write_queue for outgoing packet chain
Date: Thu,  5 Feb 2015 08:36:40 -0500
Message-ID: <1423143404-23322-6-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The list for outgoing traffic buffers from a socket is currently
allocated on the stack. This forces us to initialize the queue for
each sent message, something costing extra CPU cycles in the most
critical data path. Later in this series we will introduce a new
safe input buffer queue, something that would force us to initialize
even the spinlock of the outgoing queue. A closer analysis reveals
that the queue always is filled and emptied within the same lock_sock()
session. It is therefore safe to use a queue aggregated in the socket
itself for this purpose. Since there already exists a queue for this
in struct sock, sk_write_queue, we introduce use of that queue in
this commit.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 31 +++++++++++++------------------
 1 file changed, 13 insertions(+), 18 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e14b2ae..611a04f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -69,8 +69,6 @@
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
  * @probing_intv:
- * @port: port - interacts with 'sk' and with the rest of the TIPC stack
- * @peer_name: the peer of the connection, if any
  * @conn_timeout: the time we can wait for an unresponded setup request
  * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rcv queue
  * @link_cong: non-zero if owner must sleep because of link congestion
@@ -737,7 +735,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
-	struct sk_buff_head head;
+	struct sk_buff_head *pktchain = &sk->sk_write_queue;
 	struct iov_iter save = msg->msg_iter;
 	uint mtu;
 	int rc;
@@ -753,13 +751,12 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, pktchain);
 	if (unlikely(rc < 0))
 		return rc;
 
 	do {
-		rc = tipc_bclink_xmit(net, &head);
+		rc = tipc_bclink_xmit(net, pktchain);
 		if (likely(rc >= 0)) {
 			rc = dsz;
 			break;
@@ -773,7 +770,7 @@ new_mtu:
 		tipc_sk(sk)->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
-			__skb_queue_purge(&head);
+			__skb_queue_purge(pktchain);
 	} while (!rc);
 	return rc;
 }
@@ -897,7 +894,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct net *net = sock_net(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
 	u32 dnode, dport;
-	struct sk_buff_head head;
+	struct sk_buff_head *pktchain = &sk->sk_write_queue;
 	struct sk_buff *skb;
 	struct tipc_name_seq *seq = &dest->addr.nameseq;
 	struct iov_iter save;
@@ -972,15 +969,14 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	save = m->msg_iter;
 new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
-	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, pktchain);
 	if (rc < 0)
 		goto exit;
 
 	do {
-		skb = skb_peek(&head);
+		skb = skb_peek(pktchain);
 		TIPC_SKB_CB(skb)->wakeup_pending = tsk->link_cong;
-		rc = tipc_link_xmit(net, &head, dnode, tsk->portid);
+		rc = tipc_link_xmit(net, pktchain, dnode, tsk->portid);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
@@ -996,7 +992,7 @@ new_mtu:
 		tsk->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
-			__skb_queue_purge(&head);
+			__skb_queue_purge(pktchain);
 	} while (!rc);
 exit:
 	if (iocb)
@@ -1054,7 +1050,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	struct net *net = sock_net(sk);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
-	struct sk_buff_head head;
+	struct sk_buff_head *pktchain = &sk->sk_write_queue;
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	u32 portid = tsk->portid;
 	int rc = -EINVAL;
@@ -1091,13 +1087,12 @@ next:
 	save = m->msg_iter;
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
-	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &head);
+	rc = tipc_msg_build(mhdr, m, sent, send, mtu, pktchain);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
 		if (likely(!tsk_conn_cong(tsk))) {
-			rc = tipc_link_xmit(net, &head, dnode, portid);
+			rc = tipc_link_xmit(net, pktchain, dnode, portid);
 			if (likely(!rc)) {
 				tsk->sent_unacked++;
 				sent += send;
@@ -1117,7 +1112,7 @@ next:
 		}
 		rc = tipc_wait_for_sndpkt(sock, &timeo);
 		if (rc)
-			__skb_queue_purge(&head);
+			__skb_queue_purge(pktchain);
 	} while (!rc);
 exit:
 	if (iocb)
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
