From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 4/5] tipc: standardize sendmsg
	routine of connected socket
Date: Fri, 17 Jan 2014 09:50:06 +0800
Message-ID: <1389923407-26969-5-git-send-email-ying.xue@windriver.com>
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

Standardize the behaviour of waiting for events in TIPC send_packet()
so that all variables of socket or port structures are protected within
socket lock, allowing the process of calling sendmsg() to be woken up
at appropriate time.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   60 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 41 insertions(+), 19 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3e01973..c480310 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -695,6 +695,34 @@ exit:
 	return res;
 }
 
+static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
+{
+	struct sock *sk = sock->sk;
+	struct tipc_port *tport = tipc_sk_port(sk);
+	DEFINE_WAIT(wait);
+	int done;
+
+	do {
+		int err = sock_error(sk);
+		if (err)
+			return err;
+		if (sock->state == SS_DISCONNECTING)
+			return -EPIPE;
+		else if (sock->state != SS_CONNECTED)
+			return -ENOTCONN;
+		if (!*timeo_p)
+			return -EAGAIN;
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo_p);
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		done = sk_wait_event(sk, timeo_p,
+				     (!tport->congested || !tport->connected));
+		finish_wait(sk_sleep(sk), &wait);
+	} while (!done);
+	return 0;
+}
+
 /**
  * send_packet - send a connection-oriented message
  * @iocb: if NULL, indicates that socket lock is already held
@@ -712,8 +740,8 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
-	long timeout_val;
-	int res;
+	int res = -EINVAL;
+	long timeo;
 
 	/* Handle implied connection establishment */
 	if (unlikely(dest))
@@ -725,30 +753,24 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (iocb)
 		lock_sock(sk);
 
-	timeout_val = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
+	if (unlikely(sock->state != SS_CONNECTED)) {
+		if (sock->state == SS_DISCONNECTING)
+			res = -EPIPE;
+		else
+			res = -ENOTCONN;
+		goto exit;
+	}
 
+	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 	do {
-		if (unlikely(sock->state != SS_CONNECTED)) {
-			if (sock->state == SS_DISCONNECTING)
-				res = -EPIPE;
-			else
-				res = -ENOTCONN;
-			break;
-		}
-
 		res = tipc_send(tport->ref, m->msg_iov, total_len);
 		if (likely(res != -ELINKCONG))
 			break;
-		if (timeout_val <= 0L) {
-			res = timeout_val ? timeout_val : -EWOULDBLOCK;
+		res = tipc_wait_for_sndpkt(sock, &timeo);
+		if (res)
 			break;
-		}
-		release_sock(sk);
-		timeout_val = wait_event_interruptible_timeout(*sk_sleep(sk),
-			(!tport->congested || !tport->connected), timeout_val);
-		lock_sock(sk);
 	} while (1);
-
+exit:
 	if (iocb)
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
