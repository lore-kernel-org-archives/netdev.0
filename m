From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 1/3] tipc: unify tipc_wait_for_sndpkt()
	and tipc_wait_for_sndmsg() functions
Date: Tue,  3 Jan 2017 10:26:46 -0500
Message-ID: <1483457208-29033-2-git-send-email-jon.maloy@ericsson.com>
References: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The functions tipc_wait_for_sndpkt() and tipc_wait_for_sndmsg() are very
similar. The latter function is also called from two locations, and
there will be more in the coming commits, which will all need to test on
different conditions.

Instead of making yet another duplicates of the function, we now
introduce a new macro tipc_wait_for_cond() where the wakeup condition
can be stated as an argument to the call. This macro replaces all
current and future uses of the two functions, which can now be
eliminated.

Acked-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 108 +++++++++++++++++++++++++-----------------------------
 1 file changed, 49 insertions(+), 59 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 800caaa..f27462e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -110,7 +110,6 @@ static void tipc_write_space(struct sock *sk);
 static void tipc_sock_destruct(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
-static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
 static void tipc_sk_timeout(unsigned long data);
 static int tipc_sk_publish(struct tipc_sock *tsk, uint scope,
 			   struct tipc_name_seq const *seq);
@@ -334,6 +333,49 @@ static int tipc_set_sk_state(struct sock *sk, int state)
 	return res;
 }
 
+static int tipc_sk_sock_err(struct socket *sock, long *timeout)
+{
+	struct sock *sk = sock->sk;
+	int err = sock_error(sk);
+	int typ = sock->type;
+
+	if (err)
+		return err;
+	if (typ == SOCK_STREAM || typ == SOCK_SEQPACKET) {
+		if (sk->sk_state == TIPC_DISCONNECTING)
+			return -EPIPE;
+		else if (!tipc_sk_connected(sk))
+			return -ENOTCONN;
+	}
+	if (!*timeout)
+		return -EAGAIN;
+	if (signal_pending(current))
+		return sock_intr_errno(*timeout);
+
+	return 0;
+}
+
+#define tipc_wait_for_cond(sock_, timeout_, condition_)			\
+({								        \
+	int rc_ = 0;							\
+	int done_ = 0;							\
+									\
+	while (!(condition_) && !done_) {				\
+		struct sock *sk_ = sock->sk;				\
+		DEFINE_WAIT_FUNC(wait_, woken_wake_function);		\
+									\
+		rc_ = tipc_sk_sock_err(sock_, timeout_);		\
+		if (rc_)						\
+			break;						\
+		prepare_to_wait(sk_sleep(sk_), &wait_,			\
+				TASK_INTERRUPTIBLE);			\
+		done_ = sk_wait_event(sk_, timeout_,			\
+				      (condition_), &wait_);		\
+		remove_wait_queue(sk_sleep(sk_), &wait_);		\
+	}								\
+	rc_;								\
+})
+
 /**
  * tipc_sk_create - create a TIPC socket
  * @net: network namespace (must be default network)
@@ -721,7 +763,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 		if (rc == -ELINKCONG) {
 			tsk->link_cong = 1;
-			rc = tipc_wait_for_sndmsg(sock, &timeo);
+			rc = tipc_wait_for_cond(sock, &timeo, !tsk->link_cong);
 			if (!rc)
 				continue;
 		}
@@ -830,31 +872,6 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
 	kfree_skb(skb);
 }
 
-static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
-{
-	DEFINE_WAIT_FUNC(wait, woken_wake_function);
-	struct sock *sk = sock->sk;
-	struct tipc_sock *tsk = tipc_sk(sk);
-	int done;
-
-	do {
-		int err = sock_error(sk);
-		if (err)
-			return err;
-		if (sk->sk_shutdown & SEND_SHUTDOWN)
-			return -EPIPE;
-		if (!*timeo_p)
-			return -EAGAIN;
-		if (signal_pending(current))
-			return sock_intr_errno(*timeo_p);
-
-		add_wait_queue(sk_sleep(sk), &wait);
-		done = sk_wait_event(sk, timeo_p, !tsk->link_cong, &wait);
-		remove_wait_queue(sk_sleep(sk), &wait);
-	} while (!done);
-	return 0;
-}
-
 /**
  * tipc_sendmsg - send message in connectionless manner
  * @sock: socket structure
@@ -970,7 +987,7 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 		}
 		if (rc == -ELINKCONG) {
 			tsk->link_cong = 1;
-			rc = tipc_wait_for_sndmsg(sock, &timeo);
+			rc = tipc_wait_for_cond(sock, &timeo, !tsk->link_cong);
 			if (!rc)
 				continue;
 		}
@@ -985,36 +1002,6 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 	return rc;
 }
 
-static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
-{
-	DEFINE_WAIT_FUNC(wait, woken_wake_function);
-	struct sock *sk = sock->sk;
-	struct tipc_sock *tsk = tipc_sk(sk);
-	int done;
-
-	do {
-		int err = sock_error(sk);
-		if (err)
-			return err;
-		if (sk->sk_state == TIPC_DISCONNECTING)
-			return -EPIPE;
-		else if (!tipc_sk_connected(sk))
-			return -ENOTCONN;
-		if (!*timeo_p)
-			return -EAGAIN;
-		if (signal_pending(current))
-			return sock_intr_errno(*timeo_p);
-
-		add_wait_queue(sk_sleep(sk), &wait);
-		done = sk_wait_event(sk, timeo_p,
-				     (!tsk->link_cong &&
-				      !tsk_conn_cong(tsk)) ||
-				      !tipc_sk_connected(sk), &wait);
-		remove_wait_queue(sk_sleep(sk), &wait);
-	} while (!done);
-	return 0;
-}
-
 /**
  * tipc_send_stream - send stream-oriented data
  * @sock: socket structure
@@ -1109,7 +1096,10 @@ static int __tipc_send_stream(struct socket *sock, struct msghdr *m, size_t dsz)
 
 			tsk->link_cong = 1;
 		}
-		rc = tipc_wait_for_sndpkt(sock, &timeo);
+		rc = tipc_wait_for_cond(sock, &timeo,
+					(!tsk->link_cong &&
+					 !tsk_conn_cong(tsk) &&
+					 tipc_sk_connected(sk)));
 	} while (!rc);
 
 	__skb_queue_purge(&pktchain);
-- 
2.7.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
