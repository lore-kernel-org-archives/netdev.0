From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 02/13] timer: Remove init_timer_pinned_deferrable() in favor of timer_setup()
Date: Wed,  4 Oct 2017 16:26:56 -0700
Message-ID: <1507159627-127660-3-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Viresh Kumar <viresh.kumar@linaro.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        linux-pm@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This refactors the only user of init_timer_pinned_deferrable() to use the
new timer_setup() and from_timer(). Adds a pointer back to the policy,
and drops the definition of init_timer_pinned_deferrable().

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-pm@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/cpufreq/powernv-cpufreq.c | 13 +++++++------
 include/linux/timer.h             |  2 --
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/cpufreq/powernv-cpufreq.c b/drivers/cpufreq/powernv-cpufreq.c
index 3ff5160451b4..b6d7c4c98d0a 100644
--- a/drivers/cpufreq/powernv-cpufreq.c
+++ b/drivers/cpufreq/powernv-cpufreq.c
@@ -90,6 +90,7 @@ struct global_pstate_info {
 	int last_gpstate_idx;
 	spinlock_t gpstate_lock;
 	struct timer_list timer;
+	struct cpufreq_policy *policy;
 };
 
 static struct cpufreq_frequency_table powernv_freqs[POWERNV_MAX_PSTATES+1];
@@ -625,10 +626,10 @@ static inline void  queue_gpstate_timer(struct global_pstate_info *gpstates)
  * according quadratic equation. Queues a new timer if it is still not equal
  * to local pstate
  */
-void gpstate_timer_handler(unsigned long data)
+void gpstate_timer_handler(struct timer_list *t)
 {
-	struct cpufreq_policy *policy = (struct cpufreq_policy *)data;
-	struct global_pstate_info *gpstates = policy->driver_data;
+	struct global_pstate_info *gpstates = from_timer(gpstates, t, timer);
+	struct cpufreq_policy *policy = gpstates->policy;
 	int gpstate_idx, lpstate_idx;
 	unsigned long val;
 	unsigned int time_diff = jiffies_to_msecs(jiffies)
@@ -800,9 +801,9 @@ static int powernv_cpufreq_cpu_init(struct cpufreq_policy *policy)
 	policy->driver_data = gpstates;
 
 	/* initialize timer */
-	init_timer_pinned_deferrable(&gpstates->timer);
-	gpstates->timer.data = (unsigned long)policy;
-	gpstates->timer.function = gpstate_timer_handler;
+	gpstates->policy = policy;
+	timer_setup(&gpstates->timer, gpstate_timer_handler,
+		    TIMER_PINNED | TIMER_DEFERRABLE);
 	gpstates->timer.expires = jiffies +
 				msecs_to_jiffies(GPSTATE_TIMER_INTERVAL);
 	spin_lock_init(&gpstates->gpstate_lock);
diff --git a/include/linux/timer.h b/include/linux/timer.h
index 5ef5c9e41a09..d11e819a86e2 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -132,8 +132,6 @@ static inline void init_timer_on_stack_key(struct timer_list *timer,
 	__init_timer((timer), TIMER_PINNED)
 #define init_timer_deferrable(timer)					\
 	__init_timer((timer), TIMER_DEFERRABLE)
-#define init_timer_pinned_deferrable(timer)				\
-	__init_timer((timer), TIMER_DEFERRABLE | TIMER_PINNED)
 #define init_timer_on_stack(timer)					\
 	__init_timer_on_stack((timer), 0)
 
-- 
2.7.4
