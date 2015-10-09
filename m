From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v4 3/3] net: unix: optimize wakeups in unix_dgram_recvmsg()
Date: Fri, 09 Oct 2015 11:12:20 -0400
Message-ID: <5617D954.2050609@akamai.com>
References: <201510091233.yMQNHrfk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	rweikusat@mobileactivedefense.com, viro@zeniv.linux.org.uk,
	davidel@xmailserver.org, dave@stgolabs.net, olivier@mauras.ch,
	pageexec@freemail.hu, torvalds@linux-foundation.org,
	peterz@infradead.org, joe@perches.com
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201510091233.yMQNHrfk%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/09/2015 12:29 AM, kbuild test robot wrote:
> Hi Jason,
> 
> [auto build test ERROR on v4.3-rc3 -- if it's inappropriate base, please ignore]
> 
> config: x86_64-randconfig-i0-201540 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    net/unix/af_unix.c: In function 'unix_dgram_writable':
>>> net/unix/af_unix.c:2465:3: error: 'other_full' undeclared (first use in this function)
>      *other_full = false;
>       ^
>    net/unix/af_unix.c:2465:3: note: each undeclared identifier is reported only once for each function it appears in
> 


Forgot to refresh this patch before sending. The one that I tested with
is below.

Thanks,

-Jason




Now that connect() permanently registers a callback routine, we can induce
extra overhead in unix_dgram_recvmsg(), which unconditionally wakes up
its peer_wait queue on every receive. This patch makes the wakeup there
conditional on there being waiters.

Tested using: http://www.spinics.net/lists/netdev/msg145533.html

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 92 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 69 insertions(+), 24 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 6a4a345..cf21ffd 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -61,6 +61,7 @@ struct unix_sock {
 	unsigned long		flags;
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
+#define UNIX_NOSPACE		2
 	struct socket_wq	peer_wq;
 	wait_queue_t		wait;
 };
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f789423..ac9bcd8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,7 +326,7 @@ found:
 	return s;
 }
 
-static inline int unix_writable(struct sock *sk)
+static inline bool unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
@@ -1079,6 +1079,12 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 
 	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
 
+	set_bit(UNIX_NOSPACE, &u->flags);
+	/* Ensure that we either see space in the peer sk_receive_queue via the
+	 * unix_recvq_full() check below, or we receive a wakeup when it
+	 * empties. Pairs with the mb in unix_dgram_recvmsg().
+	 */
+	smp_mb__after_atomic();
 	sched = !sock_flag(other, SOCK_DEAD) &&
 		!(other->sk_shutdown & RCV_SHUTDOWN) &&
 		unix_recvq_full(other);
@@ -1623,17 +1629,27 @@ restart:
 
 	if (unix_peer(other) != sk && unix_recvq_full(other)) {
 		if (!timeo) {
-			err = -EAGAIN;
-			goto out_unlock;
-		}
-
-		timeo = unix_wait_for_peer(other, timeo);
+			set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
+			/* Ensure that we either see space in the peer
+			 * sk_receive_queue via the unix_recvq_full() check
+			 * below, or we receive a wakeup when it empties. This
+			 * makes sure that epoll ET triggers correctly. Pairs
+			 * with the mb in unix_dgram_recvmsg().
+			 */
+			smp_mb__after_atomic();
+			if (unix_recvq_full(other)) {
+				err = -EAGAIN;
+				goto out_unlock;
+			}
+		} else {
+			timeo = unix_wait_for_peer(other, timeo);
 
-		err = sock_intr_errno(timeo);
-		if (signal_pending(current))
-			goto out_free;
+			err = sock_intr_errno(timeo);
+			if (signal_pending(current))
+				goto out_free;
 
-		goto restart;
+			goto restart;
+		}
 	}
 
 	if (sock_flag(other, SOCK_RCVTSTAMP))
@@ -1939,8 +1955,19 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		goto out_unlock;
 	}
 
-	wake_up_interruptible_sync_poll(&u->peer_wait,
-					POLLOUT | POLLWRNORM | POLLWRBAND);
+	/* Ensure that waiters on our sk->sk_receive_queue draining that check
+	 * via unix_recvq_full() either see space in the queue or get a wakeup
+	 * below. sk->sk_receive_queue is reduece by the __skb_recv_datagram()
+	 * call above. Pairs with the mb in unix_dgram_sendmsg(),
+	 *unix_dgram_poll(), and unix_wait_for_peer().
+	 */
+	smp_mb();
+	if (test_bit(UNIX_NOSPACE, &u->flags)) {
+		clear_bit(UNIX_NOSPACE, &u->flags);
+		wake_up_interruptible_sync_poll(&u->peer_wait,
+						POLLOUT | POLLWRNORM |
+						POLLWRBAND);
+	}
 
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
@@ -2432,11 +2459,25 @@ static unsigned int unix_poll(struct file *file, struct socket *sock, poll_table
 	return mask;
 }
 
+static bool unix_dgram_writable(struct sock *sk, struct sock *other,
+				bool *other_nospace)
+{
+	*other_nospace = false;
+
+	if (other && unix_peer(other) != sk && unix_recvq_full(other)) {
+		*other_nospace = true;
+		return false;
+	}
+
+	return unix_writable(sk);
+}
+
 static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 				    poll_table *wait)
 {
 	struct sock *sk = sock->sk, *other;
-	unsigned int mask, writable;
+	unsigned int mask;
+	bool other_nospace;
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
@@ -2468,20 +2509,23 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	if (!(poll_requested_events(wait) & (POLLWRBAND|POLLWRNORM|POLLOUT)))
 		return mask;
 
-	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
-	if (other) {
-		if (unix_peer(other) != sk) {
-			if (unix_recvq_full(other))
-				writable = 0;
-		}
-		sock_put(other);
-	}
-
-	if (writable)
+	if (unix_dgram_writable(sk, other, &other_nospace)) {
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
-	else
+	} else {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		if (other_nospace)
+			set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
+		/* Ensure that we either see space in the peer sk_receive_queue
+		 * via the unix_recvq_full() check below, or we receive a wakeup
+		 * when it empties. Pairs with the mb in unix_dgram_recvmsg().
+		 */
+		smp_mb__after_atomic();
+		if (unix_dgram_writable(sk, other, &other_nospace))
+			mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+	}
+	if (other)
+		sock_put(other);
 
 	return mask;
 }
-- 
2.6.1
