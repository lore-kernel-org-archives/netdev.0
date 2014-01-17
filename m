From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/5] tipc: standardize sendmsg
	routine of connectionless socket
Date: Fri, 17 Jan 2014 09:50:05 +0800
Message-ID: <1389923407-26969-4-git-send-email-ying.xue@windriver.com>
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

Comparing the behaviour of how to wait for events in TIPC sendmsg()
with other stacks, the TIPC implementation might be perceived as
different, and sometimes even incorrect. For instance, sk_sleep()
and tport->congested variables associated with socket are exposed
without socket lock protection while wait_event_interruptible_timeout()
accesses them. So standardizing it with similar implementation
in other stacks can help us correct these errors which the process
of calling sendmsg() cannot be woken up event if an expected event
arrive at socket or improperly woken up although the wake condition
doesn't match.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 008f6fd..3e01973 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -567,6 +567,31 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 	return 0;
 }
 
+static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
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
+		if (!*timeo_p)
+			return -EAGAIN;
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo_p);
+
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		done = sk_wait_event(sk, timeo_p, !tport->congested);
+		finish_wait(sk_sleep(sk), &wait);
+	} while (!done);
+	return 0;
+}
+
 /**
  * send_msg - send message in connectionless manner
  * @iocb: if NULL, indicates that socket lock is already held
@@ -588,7 +613,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
 	int needs_conn;
-	long timeout_val;
+	long timeo;
 	int res = -EINVAL;
 
 	if (unlikely(!dest))
@@ -625,8 +650,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		reject_rx_queue(sk);
 	}
 
-	timeout_val = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
-
+	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 	do {
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			res = dest_name_check(dest, m);
@@ -660,14 +684,9 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 				sock->state = SS_CONNECTING;
 			break;
 		}
-		if (timeout_val <= 0L) {
-			res = timeout_val ? timeout_val : -EWOULDBLOCK;
+		res = tipc_wait_for_sndmsg(sock, &timeo);
+		if (res)
 			break;
-		}
-		release_sock(sk);
-		timeout_val = wait_event_interruptible_timeout(*sk_sleep(sk),
-					       !tport->congested, timeout_val);
-		lock_sock(sk);
 	} while (1);
 
 exit:
-- 
1.7.9.5


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
