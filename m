From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: fix socket timer deadlock
Date: Fri, 17 Jun 2016 06:35:57 -0400
Message-ID: <1466159757-12095-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
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

We sometimes observe a 'deadly embrace' type deadlock occurring
between mutually connected sockets on the same node. This happens
when the one-hour peer supervision timers happen to expire
simultaneously in both sockets.

The scenario is as follows:

CPU 1:                          CPU 2:
--------                        --------
tipc_sk_timeout(sk1)            tipc_sk_timeout(sk2)
  lock(sk1.slock)                 lock(sk2.slock)
  msg_create(probe)               msg_create(probe)
  unlock(sk1.slock)               unlock(sk2.slock)
  tipc_node_xmit_skb()            tipc_node_xmit_skb()
    tipc_node_xmit()                tipc_node_xmit()
      tipc_sk_rcv(sk2)                tipc_sk_rcv(sk1)
        lock(sk2.slock)                 lock((sk1.slock)
        filter_rcv()                    filter_rcv()
          tipc_sk_proto_rcv()             tipc_sk_proto_rcv()
            msg_create(probe_rsp)           msg_create(probe_rsp)
            tipc_sk_respond()               tipc_sk_respond()
              tipc_node_xmit_skb()            tipc_node_xmit_skb()
                tipc_node_xmit()                tipc_node_xmit()
                  tipc_sk_rcv(sk1)                tipc_sk_rcv(sk2)
                    lock((sk1.slock)                lock((sk2.slock)
                    ===> DEADLOCK                   ===> DEADLOCK

Further analysis reveals that there are three different locations in the
socket code where tipc_sk_respond() is called within the context of the
socket lock, with ensuing risk of similar deadlocks.

We now solve this by passing a buffer queue along with all upcalls where
sk_lock.slock may potentially be held. Response or rejected message
buffers are accumulated into this queue instead of being sent out
directly, and only sent once we know we are safely outside the slock
context.

Reported-by: GUNA <gbalasun@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 54 ++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 42 insertions(+), 12 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 88bfcd7..c49b8df 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -796,9 +796,11 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
  * @tsk: receiving socket
  * @skb: pointer to message buffer.
  */
-static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb)
+static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
+			      struct sk_buff_head *xmitq)
 {
 	struct sock *sk = &tsk->sk;
+	u32 onode = tsk_own_node(tsk);
 	struct tipc_msg *hdr = buf_msg(skb);
 	int mtyp = msg_type(hdr);
 	bool conn_cong;
@@ -811,7 +813,8 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb)
 
 	if (mtyp == CONN_PROBE) {
 		msg_set_type(hdr, CONN_PROBE_REPLY);
-		tipc_sk_respond(sk, skb, TIPC_OK);
+		if (tipc_msg_reverse(onode, &skb, TIPC_OK))
+			__skb_queue_tail(xmitq, skb);
 		return;
 	} else if (mtyp == CONN_ACK) {
 		conn_cong = tsk_conn_cong(tsk);
@@ -1686,7 +1689,8 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *skb)
  *
  * Returns true if message was added to socket receive queue, otherwise false
  */
-static bool filter_rcv(struct sock *sk, struct sk_buff *skb)
+static bool filter_rcv(struct sock *sk, struct sk_buff *skb,
+		       struct sk_buff_head *xmitq)
 {
 	struct socket *sock = sk->sk_socket;
 	struct tipc_sock *tsk = tipc_sk(sk);
@@ -1696,7 +1700,7 @@ static bool filter_rcv(struct sock *sk, struct sk_buff *skb)
 	int usr = msg_user(hdr);
 
 	if (unlikely(msg_user(hdr) == CONN_MANAGER)) {
-		tipc_sk_proto_rcv(tsk, skb);
+		tipc_sk_proto_rcv(tsk, skb, xmitq);
 		return false;
 	}
 
@@ -1739,7 +1743,8 @@ static bool filter_rcv(struct sock *sk, struct sk_buff *skb)
 	return true;
 
 reject:
-	tipc_sk_respond(sk, skb, err);
+	if (tipc_msg_reverse(tsk_own_node(tsk), &skb, err))
+		__skb_queue_tail(xmitq, skb);
 	return false;
 }
 
@@ -1755,9 +1760,24 @@ reject:
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	unsigned int truesize = skb->truesize;
+	struct sk_buff_head xmitq;
+	u32 dnode, selector;
 
-	if (likely(filter_rcv(sk, skb)))
+	__skb_queue_head_init(&xmitq);
+
+	if (likely(filter_rcv(sk, skb, &xmitq))) {
 		atomic_add(truesize, &tipc_sk(sk)->dupl_rcvcnt);
+		return 0;
+	}
+
+	if (skb_queue_empty(&xmitq))
+		return 0;
+
+	/* Send response/rejected message */
+	skb = __skb_dequeue(&xmitq);
+	dnode = msg_destnode(buf_msg(skb));
+	selector = msg_origport(buf_msg(skb));
+	tipc_node_xmit_skb(sock_net(sk), skb, dnode, selector);
 	return 0;
 }
 
@@ -1771,12 +1791,13 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
  * Caller must hold socket lock
  */
 static void tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
-			    u32 dport)
+			    u32 dport, struct sk_buff_head *xmitq)
 {
+	unsigned long time_limit = jiffies + 2;
+	struct sk_buff *skb;
 	unsigned int lim;
 	atomic_t *dcnt;
-	struct sk_buff *skb;
-	unsigned long time_limit = jiffies + 2;
+	u32 onode;
 
 	while (skb_queue_len(inputq)) {
 		if (unlikely(time_after_eq(jiffies, time_limit)))
@@ -1788,7 +1809,7 @@ static void tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
 
 		/* Add message directly to receive queue if possible */
 		if (!sock_owned_by_user(sk)) {
-			filter_rcv(sk, skb);
+			filter_rcv(sk, skb, xmitq);
 			continue;
 		}
 
@@ -1801,7 +1822,9 @@ static void tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
 			continue;
 
 		/* Overload => reject message back to sender */
-		tipc_sk_respond(sk, skb, TIPC_ERR_OVERLOAD);
+		onode = tipc_own_addr(sock_net(sk));
+		if (tipc_msg_reverse(onode, &skb, TIPC_ERR_OVERLOAD))
+			__skb_queue_tail(xmitq, skb);
 		break;
 	}
 }
@@ -1814,12 +1837,14 @@ static void tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
  */
 void tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 {
+	struct sk_buff_head xmitq;
 	u32 dnode, dport = 0;
 	int err;
 	struct tipc_sock *tsk;
 	struct sock *sk;
 	struct sk_buff *skb;
 
+	__skb_queue_head_init(&xmitq);
 	while (skb_queue_len(inputq)) {
 		dport = tipc_skb_peek_port(inputq, dport);
 		tsk = tipc_sk_lookup(net, dport);
@@ -1827,9 +1852,14 @@ void tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 		if (likely(tsk)) {
 			sk = &tsk->sk;
 			if (likely(spin_trylock_bh(&sk->sk_lock.slock))) {
-				tipc_sk_enqueue(inputq, sk, dport);
+				tipc_sk_enqueue(inputq, sk, dport, &xmitq);
 				spin_unlock_bh(&sk->sk_lock.slock);
 			}
+			/* Send pending response/rejected messages, if any */
+			while ((skb = __skb_dequeue(&xmitq))) {
+				dnode = msg_destnode(buf_msg(skb));
+				tipc_node_xmit_skb(net, skb, dnode, dport);
+			}
 			sock_put(sk);
 			continue;
 		}
-- 
1.9.1


------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports. http://sdm.link/zohomanageengine
