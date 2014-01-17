From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/5] tipc: standardize accept
	routine
Date: Fri, 17 Jan 2014 09:50:04 +0800
Message-ID: <1389923407-26969-3-git-send-email-ying.xue@windriver.com>
References: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1389923407-26969-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Comparing the behaviour of how to wait for events in TIPC accept()
with other stacks, the TIPC implementation might be perceived as
different, and sometimes even incorrect. As sk_sleep() and
sk->sk_receive_queue variables associated with socket are not
protected by socket lock, the process of calling accept() may be
woken up improperly or sometimes cannot be woken up at all. After
standardizing it with inet_csk_wait_for_connect routine, we can
get benefits including: avoiding 'thundering herd' phenomenon,
adding a timeout mechanism for accept(), coping with a pending
signal, and having sk_sleep() and sk->sk_receive_queue being
always protected within socket lock scope and so on.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   54 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 41 insertions(+), 13 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b2ae25a..008f6fd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1566,6 +1566,42 @@ static int listen(struct socket *sock, int len)
 	return res;
 }
 
+static int tipc_wait_for_accept(struct socket *sock, long timeo)
+{
+	struct sock *sk = sock->sk;
+	DEFINE_WAIT(wait);
+	int err;
+
+	/* True wake-one mechanism for incoming connections: only
+	 * one process gets woken up, not the 'whole herd'.
+	 * Since we do not 'race & poll' for established sockets
+	 * anymore, the common case will execute the loop only once.
+	*/
+	for (;;) {
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
+					  TASK_INTERRUPTIBLE);
+		if (skb_queue_empty(&sk->sk_receive_queue)) {
+			release_sock(sk);
+			timeo = schedule_timeout(timeo);
+			lock_sock(sk);
+		}
+		err = 0;
+		if (!skb_queue_empty(&sk->sk_receive_queue))
+			break;
+		err = -EINVAL;
+		if (sock->state != SS_LISTENING)
+			break;
+		err = sock_intr_errno(timeo);
+		if (signal_pending(current))
+			break;
+		err = -EAGAIN;
+		if (!timeo)
+			break;
+	}
+	finish_wait(sk_sleep(sk), &wait);
+	return err;
+}
+
 /**
  * accept - wait for connection request
  * @sock: listening socket
@@ -1582,7 +1618,7 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 	struct tipc_port *new_tport;
 	struct tipc_msg *msg;
 	u32 new_ref;
-
+	long timeo;
 	int res;
 
 	lock_sock(sk);
@@ -1592,18 +1628,10 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		goto exit;
 	}
 
-	while (skb_queue_empty(&sk->sk_receive_queue)) {
-		if (flags & O_NONBLOCK) {
-			res = -EWOULDBLOCK;
-			goto exit;
-		}
-		release_sock(sk);
-		res = wait_event_interruptible(*sk_sleep(sk),
-				(!skb_queue_empty(&sk->sk_receive_queue)));
-		lock_sock(sk);
-		if (res)
-			goto exit;
-	}
+	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
+	res = tipc_wait_for_accept(sock, timeo);
+	if (res)
+		goto exit;
 
 	buf = skb_peek(&sk->sk_receive_queue);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
