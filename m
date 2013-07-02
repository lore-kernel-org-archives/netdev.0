From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 0/2] net: lls cleanup patches
Date: Tue, 02 Jul 2013 11:38:55 +0300
Message-ID: <51D2919F.7050007@linux.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com> <20130701.140833.1705666564717621661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, devel-lists@codyps.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130701.140833.1705666564717621661.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2013 00:08, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Fri, 28 Jun 2013 15:59:18 +0300
>
>> Here are two cleanup patches.
>>
>> 1. fix warning from debug_smp_processor_id().
>> - reported by Cody P Schafer.
>>

> Applied, but like Ben said perhaps you want to remember the last cpu you
> got the sched_clock() measurement from and abort the ll poll if it changes
> on you instead of using a comparison between two cpus.
>
> But then again, since preemption is enabled, the cpu could change
> back and forth during the sched_clock() call, so you wouldn't be able
> to reliably detect this anyways.
>
> In the grand scheme of things all of this probably doesn't matter at
> all.

The only thing that really worries me, is the possibility of time
on the new cpu to be completely random, then we could be back in the
range where time_after() will be false again and end up polling for
another year.

A simple way to limit the damage would be to use time_in_range()
instead of time_after(), then if we have a completely random time we
would be out of the range and fail safely.

would something like this be an acceptable solution?

---
[PATCH net-next] net: convert lls to use time_in_range()

Time in range will fail safely if we move to a different cpu with an
extremely large clock skew.
Add time_in_range64() and convert lls to use it.

Signed-of-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

  fs/select.c             |   10 ++++++----
  include/linux/jiffies.h |    4 ++++
  include/net/ll_poll.h   |   24 +++++++++++++++---------
  3 files changed, 25 insertions(+), 13 deletions(-)

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
index 8fb8edf..37b7354 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -139,6 +139,10 @@ static inline u64 get_jiffies_64(void)
  	 ((__s64)(a) - (__s64)(b) >= 0))
  #define time_before_eq64(a,b)	time_after_eq64(b,a)

+#define time_in_range64(a,b,c) \
+	(time_after_eq64(a,b) && \
+	 time_before_eq64(a,c))
+
  /*
   * These four macros compare jiffies and 'a' for convenience.
   */
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 6c06f7c..61c2daf 100644
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
@@ -88,9 +92,10 @@ static inline bool sk_valid_ll(struct sock *sk)
  	       !need_resched() && !signal_pending(current);
  }

-static inline bool can_poll_ll(u64 end_time)
+static inline bool can_poll_ll(u64 start_time, u64 run_time)
  {
-	return !time_after64(ll_sched_clock(), end_time);
+	return time_in_range64(ll_sched_clock(), start_time,
+			       start_time + run_time);
  }

  /* when used in sock_poll() nonblock is known at compile time to be true
@@ -98,7 +103,8 @@ static inline bool can_poll_ll(u64 end_time)
   */
  static inline bool sk_poll_ll(struct sock *sk, int nonblock)
  {
-	u64 end_time = nonblock ? 0 : ll_sk_end_time(sk);
+	u64 start_time = ll_start_time(!nonblock);
+	u64 run_time = ll_sk_run_time(sk);
  	const struct net_device_ops *ops;
  	struct napi_struct *napi;
  	int rc = false;
@@ -129,7 +135,7 @@ static inline bool sk_poll_ll(struct sock *sk, int 
nonblock)
  					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);

  	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 can_poll_ll(end_time));
+		 can_poll_ll(start_time, run_time));

  	rc = !skb_queue_empty(&sk->sk_receive_queue);
  out:
