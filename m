From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v2 5/8] net: Track start of busy loop instead of
 when it should end
Date: Thu, 23 Mar 2017 14:37:42 -0700
Message-ID: <20170323213742.12615.85793.stgit@localhost.localdomain>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323211820.12615.88907.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch flips the logic we were using to determine if the busy polling
has timed out.  The main motivation for this is that we will need to
support two different possible timeout values in the future and by
recording the start time rather than when we would want to end we can focus
on making the end_time specific to the task be it epoll or socket based
polling.

I am also flipping the logic a bit.  The previous code was taking
local_clock() and shifting it by 10 to get the time value in microseconds.
That works for most values but has a side effect of us potentially
encountering time values that will never time out as the current time will
never exceed the recorded clock value plus the timeout usecs if the clock
value was approaching a roll-over.  To account for that I am leaving
start_time as a nanoseconds value instead of shifting it down to a
microseconds value.  In addition I am limiting the busy_poll and busy_read
values so that they cannot exceed about 2 seconds.  By doing this I can add
the timeout value into the nanosecond value and be guaranteed that we will
not prematurely trigger timeouts, even on 32 bit architectures.

The last bit I changed is to move from using a shift by 10 to just using
NSEC_PER_USEC and using multiplication for any run time calculations and
division for a few compile time ones.  This should be more accurate and
perform about the same on most architectures since modern CPUs typically
handle multiplication without too much overhead.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 fs/select.c                |   16 +++++----
 include/net/busy_poll.h    |   78 +++++++++++++++++++++++++++-----------------
 net/core/dev.c             |    6 ++-
 net/core/sysctl_net_core.c |   11 +++++-
 4 files changed, 68 insertions(+), 43 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index e2112270d75a..9287d3a96e35 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -409,7 +409,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec64 *end_time)
 	int retval, i, timed_out = 0;
 	u64 slack = 0;
 	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
-	unsigned long busy_end = 0;
+	unsigned long busy_start = 0;
 
 	rcu_read_lock();
 	retval = max_select_fd(n, fds);
@@ -512,11 +512,11 @@ int do_select(int n, fd_set_bits *fds, struct timespec64 *end_time)
 
 		/* only if found POLL_BUSY_LOOP sockets && not out of time */
 		if (can_busy_loop && !need_resched()) {
-			if (!busy_end) {
-				busy_end = busy_loop_end_time();
+			if (!busy_start) {
+				busy_start = busy_loop_current_time();
 				continue;
 			}
-			if (!busy_loop_timeout(busy_end))
+			if (!busy_loop_timeout(busy_start))
 				continue;
 		}
 		busy_flag = 0;
@@ -800,7 +800,7 @@ static int do_poll(struct poll_list *list, struct poll_wqueues *wait,
 	int timed_out = 0, count = 0;
 	u64 slack = 0;
 	unsigned int busy_flag = net_busy_loop_on() ? POLL_BUSY_LOOP : 0;
-	unsigned long busy_end = 0;
+	unsigned long busy_start = 0;
 
 	/* Optimise the no-wait case */
 	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -853,11 +853,11 @@ static int do_poll(struct poll_list *list, struct poll_wqueues *wait,
 
 		/* only if found POLL_BUSY_LOOP sockets && not out of time */
 		if (can_busy_loop && !need_resched()) {
-			if (!busy_end) {
-				busy_end = busy_loop_end_time();
+			if (!busy_start) {
+				busy_start = busy_loop_current_time();
 				continue;
 			}
-			if (!busy_loop_timeout(busy_end))
+			if (!busy_loop_timeout(busy_start))
 				continue;
 		}
 		busy_flag = 0;
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index c55760f4820f..4626cb22f625 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -41,67 +41,85 @@
  */
 #define MIN_NAPI_ID ((unsigned int)(NR_CPUS + 1))
 
+/* The timer checks are using time_after() to determine if we have
+ * exceeded out timeout period. In order to support that we have to limit
+ * ourselves to the smallest possible signed type and then in addition
+ * account for the fact that we are recording our value in microseconds
+ * instead of nanoseconds.
+ *
+ * This limit should be just a little over 2 seconds.
+ */
+#define MAX_BUSY_POLL (INT_MAX / NSEC_PER_USEC)
+
 static inline bool net_busy_loop_on(void)
 {
 	return sysctl_net_busy_poll;
 }
 
-static inline u64 busy_loop_us_clock(void)
+static inline bool sk_can_busy_loop(const struct sock *sk)
 {
-	return local_clock() >> 10;
+	return sk->sk_ll_usec && !signal_pending(current);
 }
 
-static inline unsigned long sk_busy_loop_end_time(struct sock *sk)
-{
-	return busy_loop_us_clock() + ACCESS_ONCE(sk->sk_ll_usec);
-}
+void sk_busy_loop(struct sock *sk, int nonblock);
 
-/* in poll/select we use the global sysctl_net_ll_poll value */
-static inline unsigned long busy_loop_end_time(void)
+#else /* CONFIG_NET_RX_BUSY_POLL */
+static inline unsigned long net_busy_loop_on(void)
 {
-	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_busy_poll);
+	return 0;
 }
 
-static inline bool sk_can_busy_loop(const struct sock *sk)
+static inline bool sk_can_busy_loop(struct sock *sk)
 {
-	return sk->sk_ll_usec && !signal_pending(current);
+	return false;
 }
 
-static inline bool busy_loop_timeout(unsigned long end_time)
+static inline void sk_busy_loop(struct sock *sk, int nonblock)
 {
-	unsigned long now = busy_loop_us_clock();
-
-	return time_after(now, end_time);
 }
 
-void sk_busy_loop(struct sock *sk, int nonblock);
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 
-#else /* CONFIG_NET_RX_BUSY_POLL */
-static inline unsigned long net_busy_loop_on(void)
+static inline unsigned long busy_loop_current_time(void)
 {
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	return (unsigned long)local_clock();
+#else
 	return 0;
+#endif
 }
 
-static inline unsigned long busy_loop_end_time(void)
+/* in poll/select we use the global sysctl_net_ll_poll value */
+static inline bool busy_loop_timeout(unsigned long start_time)
 {
-	return 0;
-}
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned long bp_usec = READ_ONCE(sysctl_net_busy_poll);
 
-static inline bool sk_can_busy_loop(struct sock *sk)
-{
-	return false;
-}
+	if (bp_usec) {
+		unsigned long end_time = start_time + (bp_usec * NSEC_PER_USEC);
+		unsigned long now = busy_loop_current_time();
 
-static inline bool busy_loop_timeout(unsigned long end_time)
-{
+		return time_after(now, end_time);
+	}
+#endif
 	return true;
 }
 
-static inline void sk_busy_loop(struct sock *sk, int nonblock)
+static inline bool sk_busy_loop_timeout(struct sock *sk,
+					unsigned long start_time)
 {
-}
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	unsigned long bp_usec = READ_ONCE(sk->sk_ll_usec);
 
-#endif /* CONFIG_NET_RX_BUSY_POLL */
+	if (bp_usec) {
+		unsigned long end_time = start_time + (bp_usec * NSEC_PER_USEC);
+		unsigned long now = busy_loop_current_time();
+
+		return time_after(now, end_time);
+	}
+#endif
+	return true;
+}
 
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 6b0458b5afe0..73ebf2f5600e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5062,7 +5062,7 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 
 void sk_busy_loop(struct sock *sk, int nonblock)
 {
-	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
+	unsigned long start_time = nonblock ? 0 : busy_loop_current_time();
 	int (*napi_poll)(struct napi_struct *napi, int budget);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
@@ -5112,7 +5112,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 		local_bh_enable();
 
 		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
-		    busy_loop_timeout(end_time))
+		    sk_busy_loop_timeout(sk, start_time))
 			break;
 
 		if (unlikely(need_resched())) {
@@ -5122,7 +5122,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 			rcu_read_unlock();
 			cond_resched();
 			if (!skb_queue_empty(&sk->sk_receive_queue) ||
-			    busy_loop_timeout(end_time))
+			    sk_busy_loop_timeout(sk, start_time))
 				return;
 			goto restart;
 		}
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 4ead336e14ea..88417a0a179a 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -27,6 +27,9 @@
 static int min_sndbuf = SOCK_MIN_SNDBUF;
 static int min_rcvbuf = SOCK_MIN_RCVBUF;
 static int max_skb_frags = MAX_SKB_FRAGS;
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static int max_busy_poll = MAX_BUSY_POLL;
+#endif
 
 static int net_msg_warn;	/* Unused, but still a sysctl */
 
@@ -408,14 +411,18 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 		.data		= &sysctl_net_busy_poll,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &max_busy_poll,
 	},
 	{
 		.procname	= "busy_read",
 		.data		= &sysctl_net_busy_read,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &max_busy_poll,
 	},
 #endif
 #ifdef CONFIG_NET_SCHED
