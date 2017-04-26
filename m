From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 2/3] tipc: improve error
	validations for sockets in CONNECTING state
Date: Wed, 26 Apr 2017 10:05:01 +0200
Message-ID: <1493193902-18332-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, the checks for sockets in CONNECTING state was based on
the assumption that the incoming message was always from the
peer's accepted data socket.

However an application using a non-blocking socket sends an implicit
connect, this socket which is in CONNECTING state can receive error
messages from the peer's listening socket. As we discard these
messages, the application socket hangs as there due to inactivity.
In addition to this, there are other places where we process errors
but do not notify the user.

In this commit, we process such incoming error messages and notify
our users about them using sk_state_change().

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3b8df510a80c..38c367f6ced4 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1259,7 +1259,10 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
 	long timeo = *timeop;
-	int err;
+	int err = sock_error(sk);
+
+	if (err)
+		return err;
 
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
@@ -1281,6 +1284,10 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 		err = sock_intr_errno(timeo);
 		if (signal_pending(current))
 			break;
+
+		err = sock_error(sk);
+		if (err)
+			break;
 	}
 	finish_wait(sk_sleep(sk), &wait);
 	*timeop = timeo;
@@ -1551,6 +1558,8 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 	struct sock *sk = &tsk->sk;
 	struct net *net = sock_net(sk);
 	struct tipc_msg *hdr = buf_msg(skb);
+	u32 pport = msg_origport(hdr);
+	u32 pnode = msg_orignode(hdr);
 
 	if (unlikely(msg_mcast(hdr)))
 		return false;
@@ -1558,18 +1567,28 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 	switch (sk->sk_state) {
 	case TIPC_CONNECTING:
 		/* Accept only ACK or NACK message */
-		if (unlikely(!msg_connected(hdr)))
-			return false;
+		if (unlikely(!msg_connected(hdr))) {
+			if (pport != tsk_peer_port(tsk) ||
+			    pnode != tsk_peer_node(tsk))
+				return false;
+
+			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
+			sk->sk_err = ECONNREFUSED;
+			sk->sk_state_change(sk);
+			return true;
+		}
 
 		if (unlikely(msg_errcode(hdr))) {
 			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = ECONNREFUSED;
+			sk->sk_state_change(sk);
 			return true;
 		}
 
 		if (unlikely(!msg_isdata(hdr))) {
 			tipc_set_sk_state(sk, TIPC_DISCONNECTING);
 			sk->sk_err = EINVAL;
+			sk->sk_state_change(sk);
 			return true;
 		}
 
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
