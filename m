From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next] net: rename low latency sockets functions to busy
 poll
Date: Mon, 08 Jul 2013 16:20:34 +0300
Message-ID: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Mortons <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename functions in include/net/ll_poll.h to busy wait.
Clarify documentation about expected power use increase.
Rename POLL_LL to POLL_BUSY_LOOP.
Add need_resched() testing to poll/select busy loops.

Note, that in select and poll can_busy_poll is dynamic and is
updated continuously to reflect the existence of supported
sockets with valid queue information.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 Documentation/sysctl/net.txt    |   12 +++++---
 fs/select.c                     |   60 ++++++++++++++++++++++++---------------
 include/net/ll_poll.h           |   46 ++++++++++++++++--------------
 include/uapi/asm-generic/poll.h |    2 +
 net/core/datagram.c             |    3 +-
 net/ipv4/tcp.c                  |    6 ++--
 net/socket.c                    |   12 ++++----
 7 files changed, 80 insertions(+), 61 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index e658bbf..7323b88 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -53,22 +53,24 @@ Default: 64
 low_latency_read
 ----------------
 Low latency busy poll timeout for socket reads. (needs CONFIG_NET_LL_RX_POLL)
-Approximate time in us to spin waiting for packets on the device queue.
+Approximate time in us to busy loop waiting for packets on the device queue.
 This sets the default value of the SO_LL socket option.
-Can be set or overridden per socket by setting socket option SO_LL.
-Recommended value is 50. May increase power usage.
+Can be set or overridden per socket by setting socket option SO_LL, which is
+the preferred method of enabling.
+If you need to enable the feature globally via sysctl, a value of 50 is recommended.
+Will increase power usage.
 Default: 0 (off)
 
 low_latency_poll
 ----------------
 Low latency busy poll timeout for poll and select. (needs CONFIG_NET_LL_RX_POLL)
-Approximate time in us to spin waiting for packets on the device queue.
+Approximate time in us to busy loop waiting for events.
 Recommended value depends on the number of sockets you poll on.
 For several sockets 50, for several hundreds 100.
 For more than that you probably want to use epoll.
 Note that only sockets with SO_LL set will be busy polled, so you want to either
 selectively set SO_LL on those sockets or set sysctl.net.low_latency_read globally.
-May increase power usage.
+Will increase power usage.
 Default: 0 (off)
 
 rmem_default
diff --git a/fs/select.c b/fs/select.c
index f28a585..25cac5f 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -402,9 +402,9 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
-	unsigned int ll_flag = ll_get_flag();
-	u64 ll_start = ll_start_time(ll_flag);
-	u64 ll_time = ll_run_time();
+	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
+	u64 busy_start = busy_loop_start_time(busy_flag);
+	u64 busy_end = busy_loop_end_time();
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -427,7 +427,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	retval = 0;
 	for (;;) {
 		unsigned long *rinp, *routp, *rexp, *inp, *outp, *exp;
-		bool can_ll = false;
+		bool can_busy_loop = false;
 
 		inp = fds->in; outp = fds->out; exp = fds->ex;
 		rinp = fds->res_in; routp = fds->res_out; rexp = fds->res_ex;
@@ -456,7 +456,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 					mask = DEFAULT_POLLMASK;
 					if (f_op && f_op->poll) {
 						wait_key_set(wait, in, out,
-							     bit, ll_flag);
+							     bit, busy_flag);
 						mask = (*f_op->poll)(f.file, wait);
 					}
 					fdput(f);
@@ -475,11 +475,18 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 						retval++;
 						wait->_qproc = NULL;
 					}
-					if (mask & POLL_LL)
-						can_ll = true;
 					/* got something, stop busy polling */
-					if (retval)
-						ll_flag = 0;
+					if (retval) {
+						can_busy_loop = false;
+						busy_flag = 0;
+
+					/*
+					 * only remember a returned
+					 * POLL_BUSY_LOOP if we asked for it
+					 */
+					} else if (busy_flag & mask)
+						can_busy_loop = true;
+
 				}
 			}
 			if (res_in)
@@ -498,8 +505,9 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
-		/* only if on, have sockets with POLL_LL and not out of time */
-		if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
+		/* only if found POLL_BUSY_LOOP sockets && not out of time */
+		if (!need_resched() && can_busy_loop &&
+		    busy_loop_range(busy_start, busy_end))
 			continue;
 
 		/*
@@ -734,7 +742,8 @@ struct poll_list {
  * if pwait->_qproc is non-NULL.
  */
 static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
-				     bool *can_ll, unsigned int ll_flag)
+				     bool *can_busy_poll,
+				     unsigned int busy_flag)
 {
 	unsigned int mask;
 	int fd;
@@ -748,10 +757,10 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait,
 			mask = DEFAULT_POLLMASK;
 			if (f.file->f_op && f.file->f_op->poll) {
 				pwait->_key = pollfd->events|POLLERR|POLLHUP;
-				pwait->_key |= ll_flag;
+				pwait->_key |= busy_flag;
 				mask = f.file->f_op->poll(f.file, pwait);
-				if (mask & POLL_LL)
-					*can_ll = true;
+				if (mask & busy_flag)
+					*can_busy_poll = true;
 			}
 			/* Mask out unneeded events. */
 			mask &= pollfd->events | POLLERR | POLLHUP;
@@ -770,9 +779,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
-	unsigned int ll_flag = ll_get_flag();
-	u64 ll_start = ll_start_time(ll_flag);
-	u64 ll_time = ll_run_time();
+	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
+	u64 busy_start = busy_loop_start_time(busy_flag);
+	u64 busy_end = busy_loop_end_time();
+
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -785,7 +795,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 
 	for (;;) {
 		struct poll_list *walk;
-		bool can_ll = false;
+		bool can_busy_loop = false;
 
 		for (walk = list; walk != NULL; walk = walk->next) {
 			struct pollfd * pfd, * pfd_end;
@@ -800,10 +810,13 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 				 * this. They'll get immediately deregistered
 				 * when we break out and return.
 				 */
-				if (do_pollfd(pfd, pt, &can_ll, ll_flag)) {
+				if (do_pollfd(pfd, pt, &can_busy_loop,
+					      busy_flag)) {
 					count++;
 					pt->_qproc = NULL;
-					ll_flag = 0;
+					/* found something, stop busy polling */
+					busy_flag = 0;
+					can_busy_loop = false;
 				}
 			}
 		}
@@ -820,8 +833,9 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
-		/* only if on, have sockets with POLL_LL and not out of time */
-		if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
+		/* only if found POLL_BUSY_LOOP sockets && not out of time */
+		if (!need_resched() && can_busy_loop &&
+		    busy_loop_range(busy_start, busy_end))
 			continue;
 
 		/*
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 0d620ba..f14dd88 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -37,9 +37,9 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 #define LL_FLUSH_FAILED		-1
 #define LL_FLUSH_BUSY		-2
 
-static inline unsigned int ll_get_flag(void)
+static inline bool net_busy_loop_on(void)
 {
-	return sysctl_net_ll_poll ? POLL_LL : 0;
+	return sysctl_net_ll_poll;
 }
 
 /* a wrapper to make debug_smp_processor_id() happy
@@ -47,7 +47,7 @@ static inline unsigned int ll_get_flag(void)
  * we only care that the average is bounded
  */
 #ifdef CONFIG_DEBUG_PREEMPT
-static inline u64 ll_sched_clock(void)
+static inline u64 busy_loop_sched_clock(void)
 {
 	u64 rc;
 
@@ -58,7 +58,7 @@ static inline u64 ll_sched_clock(void)
 	return rc;
 }
 #else /* CONFIG_DEBUG_PREEMPT */
-static inline u64 ll_sched_clock(void)
+static inline u64 busy_loop_sched_clock(void)
 {
 	return sched_clock();
 }
@@ -67,7 +67,7 @@ static inline u64 ll_sched_clock(void)
 /* we don't mind a ~2.5% imprecision so <<10 instead of *1000
  * sk->sk_ll_usec is a u_int so this can't overflow
  */
-static inline u64 ll_sk_run_time(struct sock *sk)
+static inline u64 sk_busy_loop_end_time(struct sock *sk)
 {
 	return (u64)ACCESS_ONCE(sk->sk_ll_usec) << 10;
 }
@@ -75,27 +75,29 @@ static inline u64 ll_sk_run_time(struct sock *sk)
 /* in poll/select we use the global sysctl_net_ll_poll value
  * only call sched_clock() if enabled
  */
-static inline u64 ll_run_time(void)
+static inline u64 busy_loop_end_time(void)
 {
 	return (u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10;
 }
 
-/* if flag is not set we don't need to know the time */
-static inline u64 ll_start_time(unsigned int flag)
+/* if flag is not set we don't need to know the time
+ * so we want to avoid a potentially expensive sched_clock()
+ */
+static inline u64 busy_loop_start_time(unsigned int flag)
 {
-	return flag ? ll_sched_clock() : 0;
+	return flag ? busy_loop_sched_clock() : 0;
 }
 
-static inline bool sk_valid_ll(struct sock *sk)
+static inline bool sk_can_busy_loop(struct sock *sk)
 {
 	return sk->sk_ll_usec && sk->sk_napi_id &&
 	       !need_resched() && !signal_pending(current);
 }
 
 /* careful! time_in_range64 will evaluate now twice */
-static inline bool can_poll_ll(u64 start_time, u64 run_time)
+static inline bool busy_loop_range(u64 start_time, u64 run_time)
 {
-	u64 now = ll_sched_clock();
+	u64 now = busy_loop_sched_clock();
 
 	return time_in_range64(now, start_time, start_time + run_time);
 }
@@ -103,10 +105,10 @@ static inline bool can_poll_ll(u64 start_time, u64 run_time)
 /* when used in sock_poll() nonblock is known at compile time to be true
  * so the loop and end_time will be optimized out
  */
-static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 {
-	u64 start_time = ll_start_time(!nonblock);
-	u64 run_time = ll_sk_run_time(sk);
+	u64 start_time = busy_loop_start_time(!nonblock);
+	u64 end_time = sk_busy_loop_end_time(sk);
 	const struct net_device_ops *ops;
 	struct napi_struct *napi;
 	int rc = false;
@@ -137,7 +139,7 @@ static inline bool sk_poll_ll(struct sock *sk, int nonblock)
 					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 can_poll_ll(start_time, run_time));
+		 busy_loop_range(start_time, end_time));
 
 	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
@@ -158,27 +160,27 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 }
 
 #else /* CONFIG_NET_LL_RX_POLL */
-static inline unsigned long ll_get_flag(void)
+static inline unsigned long net_busy_loop_on(void)
 {
 	return 0;
 }
 
-static inline u64 ll_start_time(unsigned int flag)
+static inline u64 busy_loop_start_time(unsigned int flag)
 {
 	return 0;
 }
 
-static inline u64 ll_run_time(void)
+static inline u64 busy_loop_end_time(void)
 {
 	return 0;
 }
 
-static inline bool sk_valid_ll(struct sock *sk)
+static inline bool sk_can_busy_loop(struct sock *sk)
 {
 	return false;
 }
 
-static inline bool sk_poll_ll(struct sock *sk, int nonblock)
+static inline bool sk_busy_poll(struct sock *sk, int nonblock)
 {
 	return false;
 }
@@ -191,7 +193,7 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 {
 }
 
-static inline bool can_poll_ll(u64 start_time, u64 run_time)
+static inline bool busy_loop_range(u64 start_time, u64 run_time)
 {
 	return false;
 }
diff --git a/include/uapi/asm-generic/poll.h b/include/uapi/asm-generic/poll.h
index 4aee586..a969498 100644
--- a/include/uapi/asm-generic/poll.h
+++ b/include/uapi/asm-generic/poll.h
@@ -30,7 +30,7 @@
 
 #define POLLFREE	0x4000	/* currently only for epoll */
 
-#define POLL_LL		0x8000
+#define POLL_BUSY_LOOP	0x8000
 
 struct pollfd {
 	int fd;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 9cbaba9..6e9ab31 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -208,7 +208,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		}
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
-		if (sk_valid_ll(sk) && sk_poll_ll(sk, flags & MSG_DONTWAIT))
+		if (sk_can_busy_loop(sk) &&
+		    sk_busy_loop(sk, flags & MSG_DONTWAIT))
 			continue;
 
 		/* User doesn't want to wait */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46ed9af..15cbfa9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1554,9 +1554,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
-	if (sk_valid_ll(sk) && skb_queue_empty(&sk->sk_receive_queue)
-	    && (sk->sk_state == TCP_ESTABLISHED))
-		sk_poll_ll(sk, nonblock);
+	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
+	    (sk->sk_state == TCP_ESTABLISHED))
+		sk_busy_loop(sk, nonblock);
 
 	lock_sock(sk);
 
diff --git a/net/socket.c b/net/socket.c
index 4da14cb..45afa64 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1148,7 +1148,7 @@ EXPORT_SYMBOL(sock_create_lite);
 /* No kernel lock held - perfect */
 static unsigned int sock_poll(struct file *file, poll_table *wait)
 {
-	unsigned int ll_flag = 0;
+	unsigned int busy_flag = 0;
 	struct socket *sock;
 
 	/*
@@ -1156,16 +1156,16 @@ static unsigned int sock_poll(struct file *file, poll_table *wait)
 	 */
 	sock = file->private_data;
 
-	if (sk_valid_ll(sock->sk)) {
+	if (sk_can_busy_loop(sock->sk)) {
 		/* this socket can poll_ll so tell the system call */
-		ll_flag = POLL_LL;
+		busy_flag = POLL_BUSY_LOOP;
 
 		/* once, only if requested by syscall */
-		if (wait && (wait->_key & POLL_LL))
-			sk_poll_ll(sock->sk, 1);
+		if (wait && (wait->_key & POLL_BUSY_LOOP))
+			sk_busy_loop(sock->sk, 1);
 	}
 
-	return ll_flag | sock->ops->poll(file, sock, wait);
+	return busy_flag | sock->ops->poll(file, sock, wait);
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)
