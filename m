From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next] net/fs: change busy poll time accounting
Date: Tue, 09 Jul 2013 11:16:35 +0300
Message-ID: <20130709081635.20852.54955.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggested by Linus:
Changed time accounting for busy-poll:
- Make it microsecond based.
- Use unsigned longs.
- Revert back to use time_after instead of time_in_range.
Reorder poll/select busy loop conditions:
- Clear busy_flag after one time we can't busy-poll.
- Only init busy_end if we actually are going to busy-poll.
Added one more missing need_resched() test.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 fs/select.c           |   31 ++++++++++++++++++----------
 include/net/ll_poll.h |   55 +++++++++++++++----------------------------------
 2 files changed, 37 insertions(+), 49 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 25cac5f..50a804b 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -403,8 +403,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
 	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
-	u64 busy_start = busy_loop_start_time(busy_flag);
-	u64 busy_end = busy_loop_end_time();
+	unsigned long busy_end = 0;
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -506,9 +505,15 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 		}
 
 		/* only if found POLL_BUSY_LOOP sockets && not out of time */
-		if (!need_resched() && can_busy_loop &&
-		    busy_loop_range(busy_start, busy_end))
-			continue;
+		if (can_busy_loop && !need_resched()) {
+			if (!busy_end) {
+				busy_end = busy_loop_end_time();
+				continue;
+			}
+			if (!busy_loop_timeout(busy_end))
+				continue;
+		}
+		busy_flag = 0;
 
 		/*
 		 * If this is the first loop and we have a timeout
@@ -780,9 +785,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
 	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
-	u64 busy_start = busy_loop_start_time(busy_flag);
-	u64 busy_end = busy_loop_end_time();
-
+	unsigned long busy_end = 0;
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -834,9 +837,15 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 			break;
 
 		/* only if found POLL_BUSY_LOOP sockets && not out of time */
-		if (!need_resched() && can_busy_loop &&
-		    busy_loop_range(busy_start, busy_end))
-			continue;
+		if (can_busy_loop && !need_resched()) {
+			if (!busy_end) {
+				busy_end = busy_loop_end_time();
+				continue;
+			}
+			if (!busy_loop_timeout(busy_end))
+				continue;
+		}
+		busy_flag = 0;
 
 		/*
 		 * If this is the first loop and we have a timeout
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index f14dd88..2bacbbf 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -47,7 +47,7 @@ static inline bool net_busy_loop_on(void)
  * we only care that the average is bounded
  */
 #ifdef CONFIG_DEBUG_PREEMPT
-static inline u64 busy_loop_sched_clock(void)
+static inline u64 busy_loop_us_clock(void)
 {
 	u64 rc;
 
@@ -55,37 +55,24 @@ static inline u64 busy_loop_sched_clock(void)
 	rc = sched_clock();
 	preempt_enable_no_resched_notrace();
 
-	return rc;
+	return rc >> 10;
 }
 #else /* CONFIG_DEBUG_PREEMPT */
-static inline u64 busy_loop_sched_clock(void)
+static inline u64 busy_loop_us_clock(void)
 {
-	return sched_clock();
+	return sched_clock() >> 10;
 }
 #endif /* CONFIG_DEBUG_PREEMPT */
 
-/* we don't mind a ~2.5% imprecision so <<10 instead of *1000
- * sk->sk_ll_usec is a u_int so this can't overflow
- */
-static inline u64 sk_busy_loop_end_time(struct sock *sk)
+static inline unsigned long sk_busy_loop_end_time(struct sock *sk)
 {
-	return (u64)ACCESS_ONCE(sk->sk_ll_usec) << 10;
+	return busy_loop_us_clock() + ACCESS_ONCE(sk->sk_ll_usec);
 }
 
-/* in poll/select we use the global sysctl_net_ll_poll value
- * only call sched_clock() if enabled
- */
-static inline u64 busy_loop_end_time(void)
-{
-	return (u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10;
-}
-
-/* if flag is not set we don't need to know the time
- * so we want to avoid a potentially expensive sched_clock()
- */
-static inline u64 busy_loop_start_time(unsigned int flag)
+/* in poll/select we use the global sysctl_net_ll_poll value */
+static inline unsigned long busy_loop_end_time(void)
 {
-	return flag ? busy_loop_sched_clock() : 0;
+	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_ll_poll);
 }
 
 static inline bool sk_can_busy_loop(struct sock *sk)
@@ -94,12 +81,10 @@ static inline bool sk_can_busy_loop(struct sock *sk)
 	       !need_resched() && !signal_pending(current);
 }
 
-/* careful! time_in_range64 will evaluate now twice */
-static inline bool busy_loop_range(u64 start_time, u64 run_time)
-{
-	u64 now = busy_loop_sched_clock();
 
-	return time_in_range64(now, start_time, start_time + run_time);
+static inline bool busy_loop_timeout(unsigned long end_time)
+{
+	return time_after(busy_loop_us_clock(), end_time);
 }
 
 /* when used in sock_poll() nonblock is known at compile time to be true
@@ -107,8 +92,7 @@ static inline bool busy_loop_range(u64 start_time, u64 run_time)
  */
 static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 {
-	u64 start_time = busy_loop_start_time(!nonblock);
-	u64 end_time = sk_busy_loop_end_time(sk);
+	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
 	const struct net_device_ops *ops;
 	struct napi_struct *napi;
 	int rc = false;
@@ -139,7 +123,7 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 busy_loop_range(start_time, end_time));
+		 !need_resched() && !busy_loop_timeout(end_time));
 
 	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
@@ -165,12 +149,7 @@ static inline unsigned long net_busy_loop_on(void)
 	return 0;
 }
 
-static inline u64 busy_loop_start_time(unsigned int flag)
-{
-	return 0;
-}
-
-static inline u64 busy_loop_end_time(void)
+static inline unsigned long busy_loop_end_time(void)
 {
 	return 0;
 }
@@ -193,9 +172,9 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 {
 }
 
-static inline bool busy_loop_range(u64 start_time, u64 run_time)
+static inline bool busy_loop_timeout(unsigned long end_time)
 {
-	return false;
+	return true;
 }
 
 #endif /* CONFIG_NET_LL_RX_POLL */
