From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [net-next PATCH v3 5/8] net: Track start of busy loop instead of
 when it should end
Date: Fri, 24 Mar 2017 10:08:18 -0700
Message-ID: <20170324170818.15226.51326.stgit@localhost.localdomain>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324164902.15226.48358.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This patch flips the logic we were using to determine if the busy polling
has timed out.  The main motivation for this is that we will need to
support two different possible timeout values in the future and by
recording the start time rather than when we would want to end we can focus
on making the end_time specific to the task be it epoll or socket based
polling.

Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 fs/select.c             |   16 ++++++-----
 include/net/busy_poll.h |   68 ++++++++++++++++++++++++++---------------------
 net/core/dev.c          |    6 ++--
 3 files changed, 49 insertions(+), 41 deletions(-)

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
index c55760f4820f..72c82f2ea536 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -46,62 +46,70 @@ static inline bool net_busy_loop_on(void)
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
+	return (unsigned long)(local_clock() >> 10);
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
+		unsigned long end_time = start_time + bp_usec;
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
+		unsigned long end_time = start_time + bp_usec;
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
index af70eb6ba682..2d1b5613b7fd 100644
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
@@ -5111,7 +5111,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 		local_bh_enable();
 
 		if (nonblock || !skb_queue_empty(&sk->sk_receive_queue) ||
-		    busy_loop_timeout(end_time))
+		    sk_busy_loop_timeout(sk, start_time))
 			break;
 
 		if (unlikely(need_resched())) {
@@ -5121,7 +5121,7 @@ void sk_busy_loop(struct sock *sk, int nonblock)
 			rcu_read_unlock();
 			cond_resched();
 			if (!skb_queue_empty(&sk->sk_receive_queue) ||
-			    busy_loop_timeout(end_time))
+			    sk_busy_loop_timeout(sk, start_time))
 				return;
 			goto restart;
 		}
