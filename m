From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next] net: convert lls to use time_in_range()
Date: Tue, 02 Jul 2013 12:49:58 +0300
Message-ID: <51D2A246.3000705@linux.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com> <20130701.140833.1705666564717621661.davem@davemloft.net> <51D2919F.7050007@linux.intel.com> <51D29329.4060004@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, devel-lists@codyps.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D29329.4060004@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Time in range will fail safely if we move to a different cpu with an
extremely large clock skew.
Add time_in_range64() and convert lls to use it.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---
v1->v2
fixed double call to sched_clock() in can_poll_ll(), checkpatchisms


  fs/select.c             |   10 ++++++----
  include/linux/jiffies.h |    4 ++++
  include/net/ll_poll.h   |   26 +++++++++++++++++---------
  3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 3654075..f28a585 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -403,7 +403,8 @@ int do_select(int n, fd_set_bits *fds, struct 
timespec *end_time)
  	int retval, i, timed_out = 0;
  	unsigned long slack = 0;
  	unsigned int ll_flag = ll_get_flag();
-	u64 ll_time = ll_end_time();
+	u64 ll_start = ll_start_time(ll_flag);
+	u64 ll_time = ll_run_time();

  	rcu_read_lock();
  	retval = max_select_fd(n, fds);
@@ -498,7 +499,7 @@ int do_select(int n, fd_set_bits *fds, struct 
timespec *end_time)
  		}

  		/* only if on, have sockets with POLL_LL and not out of time */
-		if (ll_flag && can_ll && can_poll_ll(ll_time))
+		if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
  			continue;

  		/*
@@ -770,7 +771,8 @@ static int do_poll(unsigned int nfds,  struct 
poll_list *list,
  	int timed_out = 0, count = 0;
  	unsigned long slack = 0;
  	unsigned int ll_flag = ll_get_flag();
-	u64 ll_time = ll_end_time();
+	u64 ll_start = ll_start_time(ll_flag);
+	u64 ll_time = ll_run_time();

  	/* Optimise the no-wait case */
  	if (end_time && !end_time->tv_sec && !end_time->tv_nsec) {
@@ -819,7 +821,7 @@ static int do_poll(unsigned int nfds,  struct 
poll_list *list,
  			break;

  		/* only if on, have sockets with POLL_LL and not out of time */
-		if (ll_flag && can_ll && can_poll_ll(ll_time))
+		if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))
  			continue;

  		/*
diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index 8fb8edf..97ba4e7 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -139,6 +139,10 @@ static inline u64 get_jiffies_64(void)
  	 ((__s64)(a) - (__s64)(b) >= 0))
  #define time_before_eq64(a,b)	time_after_eq64(b,a)

+#define time_in_range64(a, b, c) \
+	(time_after_eq64(a, b) && \
+	 time_before_eq64(a, c))
+
  /*
   * These four macros compare jiffies and 'a' for convenience.
   */
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 6c06f7c..b76f004 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -67,19 +67,23 @@ static inline u64 ll_sched_clock(void)
  /* we don't mind a ~2.5% imprecision so <<10 instead of *1000
   * sk->sk_ll_usec is a u_int so this can't overflow
   */
-static inline u64 ll_sk_end_time(struct sock *sk)
+static inline u64 ll_sk_run_time(struct sock *sk)
  {
-	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + ll_sched_clock();
+	return (u64)ACCESS_ONCE(sk->sk_ll_usec) << 10;
  }

  /* in poll/select we use the global sysctl_net_ll_poll value
   * only call sched_clock() if enabled
   */
-static inline u64 ll_end_time(void)
+static inline u64 ll_run_time(void)
  {
-	u64 end_time = ACCESS_ONCE(sysctl_net_ll_poll);
+	return (u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10;
+}

-	return end_time ? (end_time << 10) + ll_sched_clock() : 0;
+/* if flag is not set we don't need to know the time */
+static inline u64 ll_start_time(unsigned int flag)
+{
+	return flag ? ll_sched_clock() : 0;
  }

  static inline bool sk_valid_ll(struct sock *sk)
@@ -88,9 +92,12 @@ static inline bool sk_valid_ll(struct sock *sk)
  	       !need_resched() && !signal_pending(current);
  }

-static inline bool can_poll_ll(u64 end_time)
+/* careful! time_in_range64 will evaluate now twice */
+static inline bool can_poll_ll(u64 start_time, u64 run_time)
  {
-	return !time_after64(ll_sched_clock(), end_time);
+	u64 now = ll_sched_clock();
+
+	return time_in_range64(now, start_time, start_time + run_time);
  }

  /* when used in sock_poll() nonblock is known at compile time to be true
@@ -98,7 +105,8 @@ static inline bool can_poll_ll(u64 end_time)
   */
  static inline bool sk_poll_ll(struct sock *sk, int nonblock)
  {
-	u64 end_time = nonblock ? 0 : ll_sk_end_time(sk);
+	u64 start_time = ll_start_time(!nonblock);
+	u64 run_time = ll_sk_run_time(sk);
  	const struct net_device_ops *ops;
  	struct napi_struct *napi;
  	int rc = false;
@@ -129,7 +137,7 @@ static inline bool sk_poll_ll(struct sock *sk, int 
nonblock)
  					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);

  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 can_poll_ll(end_time));
+		 can_poll_ll(start_time, run_time));

  	rc = !skb_queue_empty(&sk->sk_receive_queue);
  out:
