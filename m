From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next 2/2] net: avoid calling sched_clock when LLS is off
Date: Fri, 28 Jun 2013 15:59:35 +0300
Message-ID: <20130628125934.14419.38109.stgit@ladj378.jer.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32423 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755046Ab3F1M7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 08:59:39 -0400
In-Reply-To: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Low Latency Sockets code for select and poll so that
when LLS is disabled sched_clock() is never called.

Also, avoid sending POLL_LL to sockets if disabled.

Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 fs/select.c           |   11 +++++++----
 include/net/ll_poll.h |   17 +++++++++++++++--
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 79b876e..3654075 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -402,7 +402,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 	poll_table *wait;
 	int retval, i, timed_out = 0;
 	unsigned long slack = 0;
-	unsigned int ll_flag = POLL_LL;
+	unsigned int ll_flag = ll_get_flag();
 	u64 ll_time = ll_end_time();
 
 	rcu_read_lock();
@@ -497,7 +497,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 			break;
 		}
 
-		if (can_ll && can_poll_ll(ll_time))
+		/* only if on, have sockets with POLL_LL and not out of time */
+		if (ll_flag && can_ll && can_poll_ll(ll_time))
 			continue;
 
 		/*
@@ -768,7 +769,7 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 	ktime_t expire, *to = NULL;
 	int timed_out = 0, count = 0;
 	unsigned long slack = 0;
-	unsigned int ll_flag = POLL_LL;
+	unsigned int ll_flag = ll_get_flag();
 	u64 ll_time = ll_end_time();
 
 	/* Optimise the no-wait case */
@@ -817,8 +818,10 @@ static int do_poll(unsigned int nfds,  struct poll_list *list,
 		if (count || timed_out)
 			break;
 
-		if (can_ll && can_poll_ll(ll_time))
+		/* only if on, have sockets with POLL_LL and not out of time */
+		if (ll_flag && can_ll && can_poll_ll(ll_time))
 			continue;
+
 		/*
 		 * If this is the first loop and we have a timeout
 		 * given, then we convert to ktime_t and set the to
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 6d45e6f..6c06f7c 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -37,6 +37,11 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 #define LL_FLUSH_FAILED		-1
 #define LL_FLUSH_BUSY		-2
 
+static inline unsigned int ll_get_flag(void)
+{
+	return sysctl_net_ll_poll ? POLL_LL : 0;
+}
+
 /* a wrapper to make debug_smp_processor_id() happy
  * we can use sched_clock() because we don't care much about precision
  * we only care that the average is bounded
@@ -67,10 +72,14 @@ static inline u64 ll_sk_end_time(struct sock *sk)
 	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + ll_sched_clock();
 }
 
-/* in poll/select we use the global sysctl_net_ll_poll value */
+/* in poll/select we use the global sysctl_net_ll_poll value
+ * only call sched_clock() if enabled
+ */
 static inline u64 ll_end_time(void)
 {
-	return ((u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10) + ll_sched_clock();
+	u64 end_time = ACCESS_ONCE(sysctl_net_ll_poll);
+
+	return end_time ? (end_time << 10) + ll_sched_clock() : 0;
 }
 
 static inline bool sk_valid_ll(struct sock *sk)
@@ -141,6 +150,10 @@ static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
 }
 
 #else /* CONFIG_NET_LL_RX_POLL */
+static inline unsigned long ll_get_flag(void)
+{
+	return 0;
+}
 
 static inline u64 sk_ll_end_time(struct sock *sk)
 {
