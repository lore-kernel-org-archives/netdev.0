From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 11:26:25 +0100
Message-ID: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rjw@rjwysocki.net, konrad.wilk@oracle.com,
	Ingo Molnar <mingo@kernel.org>, paulmck@linux.vnet.ibm.com,
	tj@kernel.org, davem@davemloft.net, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


$ make tags
  GEN     tags
ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
ctags: Warning: kernel/locking/lockdep.c:151: null expansion of name pattern "\1"
ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
ctags: Warning: kernel/workqueue.c:323: null expansion of name pattern "\1"
ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"

Which are all the result of the DEFINE_PER_CPU pattern:

scripts/tags.sh:200:	'/\<DEFINE_PER_CPU([^,]*, *\([[:alnum:]_]*\)/\1/v/'
scripts/tags.sh:201:	'/\<DEFINE_PER_CPU_SHARED_ALIGNED([^,]*, *\([[:alnum:]_]*\)/\1/v/'

The below cures them. All except the workqueue one are within reasonable
distance of the 80 char limit. TJ do you have any preference on how to
fix the wq one, or shall we just not care its too long?

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 drivers/acpi/processor_idle.c  | 4 ++--
 drivers/xen/events/events_2l.c | 5 +++--
 kernel/locking/lockdep.c       | 3 +--
 kernel/rcu/rcutorture.c        | 6 ++----
 kernel/workqueue.c             | 3 +--
 net/ipv4/syncookies.c          | 3 +--
 net/ipv6/syncookies.c          | 3 +--
 net/rds/page.c                 | 4 ++--
 8 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 175c86bee3a9..9ca2b2fefd76 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -61,8 +61,8 @@ module_param(latency_factor, uint, 0644);
 
 static DEFINE_PER_CPU(struct cpuidle_device *, acpi_cpuidle_device);
 
-static DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX],
-								acpi_cstate);
+static
+DEFINE_PER_CPU(struct acpi_processor_cx * [CPUIDLE_STATE_MAX], acpi_cstate);
 
 static int disabled_by_idle_boot_param(void)
 {
diff --git a/drivers/xen/events/events_2l.c b/drivers/xen/events/events_2l.c
index 7dd46312c180..403fe3955393 100644
--- a/drivers/xen/events/events_2l.c
+++ b/drivers/xen/events/events_2l.c
@@ -38,8 +38,9 @@
 /* Find the first set bit in a evtchn mask */
 #define EVTCHN_FIRST_BIT(w) find_first_bit(BM(&(w)), BITS_PER_EVTCHN_WORD)
 
-static DEFINE_PER_CPU(xen_ulong_t [EVTCHN_2L_NR_CHANNELS/BITS_PER_EVTCHN_WORD],
-		      cpu_evtchn_mask);
+#define EVTCHN_MASK_SIZE (EVTCHN_2L_NR_CHANNELS/BITS_PER_EVTCHN_WORD)
+
+static DEFINE_PER_CPU(xen_ulong_t [EVTCHN_MASK_SIZE], cpu_evtchn_mask);
 
 static unsigned evtchn_2l_max_channels(void)
 {
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 3261214323fa..9599bc7742a9 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -148,8 +148,7 @@ static inline struct lock_class *hlock_class(struct held_lock *hlock)
 }
 
 #ifdef CONFIG_LOCK_STAT
-static DEFINE_PER_CPU(struct lock_class_stats[MAX_LOCKDEP_KEYS],
-		      cpu_lock_stats);
+static DEFINE_PER_CPU(struct lock_class_stats[MAX_LOCKDEP_KEYS], cpu_lock_stats);
 
 static inline u64 lockstat_clock(void)
 {
diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index d2988d047d66..4d5cc6aa7e1e 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -130,10 +130,8 @@ static struct rcu_torture __rcu *rcu_torture_current;
 static unsigned long rcu_torture_current_version;
 static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
 static DEFINE_SPINLOCK(rcu_torture_lock);
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_count) = { 0 };
-static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_batch) = { 0 };
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_count) = { 0 };
+static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1], rcu_torture_batch) = { 0 };
 static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
 static atomic_t n_rcu_torture_alloc;
 static atomic_t n_rcu_torture_alloc_fail;
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 7ff5dc7d2ac5..16e13d8628a3 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -320,8 +320,7 @@ static bool wq_debug_force_rr_cpu = false;
 module_param_named(debug_force_rr_cpu, wq_debug_force_rr_cpu, bool, 0644);
 
 /* the per-cpu worker pools */
-static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS],
-				     cpu_worker_pools);
+static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS], cpu_worker_pools);
 
 static DEFINE_IDR(worker_pool_idr);	/* PR: idr of all pools */
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 643a86c49020..2d5589b61e9f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -50,8 +50,7 @@ static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 #define TSBITS	6
 #define TSMASK	(((__u32)1 << TSBITS) - 1)
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
-		      ipv4_cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv4_cookie_scratch);
 
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 2906ef20795e..aae3e5ca63ea 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -41,8 +41,7 @@ static __u16 const msstab[] = {
 	9000 - 60,
 };
 
-static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
-		      ipv6_cookie_scratch);
+static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS], ipv6_cookie_scratch);
 
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
diff --git a/net/rds/page.c b/net/rds/page.c
index 5a14e6d6a926..616f21f4e7d7 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -42,8 +42,8 @@ struct rds_page_remainder {
 	unsigned long	r_offset;
 };
 
-static DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder,
-				     rds_page_remainders);
+static
+DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder, rds_page_remainders);
 
 /*
  * returns 0 on success or -errno on failure.
