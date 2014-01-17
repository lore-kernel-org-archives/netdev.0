From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/5] tipc: standardize connect
	routine
Date: Fri, 17 Jan 2014 09:50:03 +0800
Message-ID: <1389923407-26969-2-git-send-email-ying.xue@windriver.com>
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

Comparing the behaviour of how to wait for events in TIPC connect()
with other stacks, the TIPC implementation might be perceived as
different, and sometimes even incorrect. For instance, as both
sock->state and sk_sleep() are directly fed to
wait_event_interruptible_timeout() as its arguments, and socket lock
has to be released before we call wait_event_interruptible_timeout(),
the two variables associated with socket are exposed out of socket
lock protection, thereby probably getting stale values so that the
process of calling connect() cannot be woken up exactly even if
correct event arrives or it is woken up improperly even if the wake
condition is not satisfied in practice. Therefore, standardizing its
behaviour with sk_stream_wait_connect routine can avoid these risks.

Additionally the implementation of connect routine is simplified as a
whole, allowing it to return correct values in all different cases.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   63 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 33 insertions(+), 30 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c8341d1..b2ae25a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1438,6 +1438,28 @@ static void wakeupdispatch(struct tipc_port *tport)
 	sk->sk_write_space(sk);
 }
 
+static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
+{
+	struct sock *sk = sock->sk;
+	DEFINE_WAIT(wait);
+	int done;
+
+	do {
+		int err = sock_error(sk);
+		if (err)
+			return err;
+		if (!*timeo_p)
+			return -ETIMEDOUT;
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo_p);
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		done = sk_wait_event(sk, timeo_p, sock->state != SS_CONNECTING);
+		finish_wait(sk_sleep(sk), &wait);
+	} while (!done);
+	return 0;
+}
+
 /**
  * connect - establish a connection to another TIPC port
  * @sock: socket structure
@@ -1453,7 +1475,8 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	struct sock *sk = sock->sk;
 	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
 	struct msghdr m = {NULL,};
-	unsigned int timeout;
+	long timeout = (flags & O_NONBLOCK) ? 0 : tipc_sk(sk)->conn_timeout;
+	socket_state previous;
 	int res;
 
 	lock_sock(sk);
@@ -1475,8 +1498,7 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 	}
 
-	timeout = (flags & O_NONBLOCK) ? 0 : tipc_sk(sk)->conn_timeout;
-
+	previous = sock->state;
 	switch (sock->state) {
 	case SS_UNCONNECTED:
 		/* Send a 'SYN-' to destination */
@@ -1498,41 +1520,22 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		 * case is EINPROGRESS, rather than EALREADY.
 		 */
 		res = -EINPROGRESS;
-		break;
 	case SS_CONNECTING:
-		res = -EALREADY;
+		if (previous == SS_CONNECTING)
+			res = -EALREADY;
+		if (!timeout)
+			goto exit;
+		timeout = msecs_to_jiffies(timeout);
+		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
+		res = tipc_wait_for_connect(sock, &timeout);
 		break;
 	case SS_CONNECTED:
 		res = -EISCONN;
 		break;
 	default:
 		res = -EINVAL;
-		goto exit;
-	}
-
-	if (sock->state == SS_CONNECTING) {
-		if (!timeout)
-			goto exit;
-
-		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
-		release_sock(sk);
-		res = wait_event_interruptible_timeout(*sk_sleep(sk),
-				sock->state != SS_CONNECTING,
-				timeout ? (long)msecs_to_jiffies(timeout)
-					: MAX_SCHEDULE_TIMEOUT);
-		if (res <= 0) {
-			if (res == 0)
-				res = -ETIMEDOUT;
-			return res;
-		}
-		lock_sock(sk);
+		break;
 	}
-
-	if (unlikely(sock->state == SS_DISCONNECTING))
-		res = sock_error(sk);
-	else
-		res = 0;
-
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.9.5


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
