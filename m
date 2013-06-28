From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next 1/2] net: fix LLS debug_smp_processor_id() warning
Date: Fri, 28 Jun 2013 15:59:26 +0300
Message-ID: <20130628125926.14419.89905.stgit@ladj378.jer.intel.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Our use of sched_clock is OK because we don't mind the side effects
of calling it and occasionally waking up on a different CPU.

When CONFIG_DEBUG_PREEMPT is on, disable preempt before calling
sched_clock() so we don't trigger a debug_smp_processor_id() warning.

Reported-by: Cody P Schafer <devel-lists@codyps.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/ll_poll.h |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index 5bf2b3a..6d45e6f 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -37,20 +37,40 @@ extern unsigned int sysctl_net_ll_poll __read_mostly;
 #define LL_FLUSH_FAILED		-1
 #define LL_FLUSH_BUSY		-2
 
-/* we can use sched_clock() because we don't care much about precision
+/* a wrapper to make debug_smp_processor_id() happy
+ * we can use sched_clock() because we don't care much about precision
  * we only care that the average is bounded
- * we don't mind a ~2.5% imprecision so <<10 instead of *1000
+ */
+#ifdef CONFIG_DEBUG_PREEMPT
+static inline u64 ll_sched_clock(void)
+{
+	u64 rc;
+
+	preempt_disable_notrace();
+	rc = sched_clock();
+	preempt_enable_no_resched_notrace();
+
+	return rc;
+}
+#else /* CONFIG_DEBUG_PREEMPT */
+static inline u64 ll_sched_clock(void)
+{
+	return sched_clock();
+}
+#endif /* CONFIG_DEBUG_PREEMPT */
+
+/* we don't mind a ~2.5% imprecision so <<10 instead of *1000
  * sk->sk_ll_usec is a u_int so this can't overflow
  */
 static inline u64 ll_sk_end_time(struct sock *sk)
 {
-	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + sched_clock();
+	return ((u64)ACCESS_ONCE(sk->sk_ll_usec) << 10) + ll_sched_clock();
 }
 
 /* in poll/select we use the global sysctl_net_ll_poll value */
 static inline u64 ll_end_time(void)
 {
-	return ((u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10) + sched_clock();
+	return ((u64)ACCESS_ONCE(sysctl_net_ll_poll) << 10) + ll_sched_clock();
 }
 
 static inline bool sk_valid_ll(struct sock *sk)
@@ -61,7 +81,7 @@ static inline bool sk_valid_ll(struct sock *sk)
 
 static inline bool can_poll_ll(u64 end_time)
 {
-	return !time_after64(sched_clock(), end_time);
+	return !time_after64(ll_sched_clock(), end_time);
 }
 
 /* when used in sock_poll() nonblock is known at compile time to be true
