From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/8] posix clocks: dynamic clock ids.
Date: Thu, 23 Sep 2010 19:31:33 +0200
Message-ID: <c234c15972e000eb1fd3e9e0e298130df23948c9.1285261534.git.richard.cochran@omicron.at>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org, linux-api@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1285261533.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch augments the POSIX clock code to offer a dynamic clock
creation method. Instead of registering a hard coded clock ID, modules
may call create_posix_clock(), which returns a new clock ID.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/posix-timers.h |    7 ++++++-
 include/linux/time.h         |    2 ++
 kernel/posix-timers.c        |   41 ++++++++++++++++++++++++++++++++++-------
 3 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index abf61cc..08aa4da 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -68,6 +68,7 @@ struct k_itimer {
 };
 
 struct k_clock {
+	clockid_t id;
 	int res;		/* in nanoseconds */
 	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
 	int (*clock_set) (const clockid_t which_clock, struct timespec * tp);
@@ -86,7 +87,11 @@ struct k_clock {
 			   struct itimerspec * cur_setting);
 };
 
-void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock);
+/* Regsiter a posix clock with a "well known" clock id. */
+int register_posix_clock(const clockid_t id, struct k_clock *clock);
+
+/* Create a new posix clock with a dynamic clock id. */
+clockid_t create_posix_clock(struct k_clock *clock);
 
 /* error handlers for timer_create, nanosleep and settime */
 int do_posix_clock_nonanosleep(const clockid_t, int flags, struct timespec *,
diff --git a/include/linux/time.h b/include/linux/time.h
index 9f15ac7..914c48d 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -299,6 +299,8 @@ struct itimerval {
 #define CLOCKS_MASK			(CLOCK_REALTIME | CLOCK_MONOTONIC)
 #define CLOCKS_MONO			CLOCK_MONOTONIC
 
+#define CLOCK_INVALID			-1
+
 /*
  * The various flags for setting POSIX.1b interval timers:
  */
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 446b566..67fba5c 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -132,6 +132,8 @@ static DEFINE_SPINLOCK(idr_lock);
  */
 
 static struct k_clock posix_clocks[MAX_CLOCKS];
+static DECLARE_BITMAP(clocks_map, MAX_CLOCKS);
+static DEFINE_MUTEX(clocks_mux); /* protects 'posix_clocks' and 'clocks_map' */
 
 /*
  * These ones are defined below.
@@ -484,18 +486,43 @@ static struct pid *good_sigevent(sigevent_t * event)
 	return task_pid(rtn);
 }
 
-void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock)
+int register_posix_clock(const clockid_t id, struct k_clock *clock)
 {
-	if ((unsigned) clock_id >= MAX_CLOCKS) {
-		printk("POSIX clock register failed for clock_id %d\n",
-		       clock_id);
-		return;
-	}
+	struct k_clock *kc;
+	int err = 0;
 
-	posix_clocks[clock_id] = *new_clock;
+	mutex_lock(&clocks_mux);
+	if (test_bit(id, clocks_map)) {
+		pr_err("clock_id %d already registered\n", id);
+		err = -EBUSY;
+		goto out;
+	}
+	kc = &posix_clocks[id];
+	*kc = *clock;
+	kc->id = id;
+	set_bit(id, clocks_map);
+out:
+	mutex_unlock(&clocks_mux);
+	return err;
 }
 EXPORT_SYMBOL_GPL(register_posix_clock);
 
+clockid_t create_posix_clock(struct k_clock *clock)
+{
+	clockid_t id;
+
+	mutex_lock(&clocks_mux);
+	id = find_first_zero_bit(clocks_map, MAX_CLOCKS);
+	mutex_unlock(&clocks_mux);
+
+	if (id < MAX_CLOCKS) {
+		register_posix_clock(id, clock);
+		return id;
+	}
+	return CLOCK_INVALID;
+}
+EXPORT_SYMBOL_GPL(create_posix_clock);
+
 static struct k_itimer * alloc_posix_timer(void)
 {
 	struct k_itimer *tmr;
-- 
1.7.0.4
