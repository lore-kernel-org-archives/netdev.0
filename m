From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 08/11] time/posix-clock:Convert to the 64bit methods for k_clock and posix_clock_operations structure
Date: Mon, 20 Apr 2015 13:57:36 +0800
Message-ID: <1429509459-17068-9-git-send-email-baolin.wang@linaro.org>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	baolin.wang@linaro.org, y2038@lists.linaro.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts the posix clock operations over to the new methods with
timespec64/itimerspec64 type to making them ready for 2038, and it is based on
the ptp patch series.

And also changes to the 64bit methods for k_clock structure, that
converts the timespec/itimerspec type to timespec64/itimerspec64 type.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 drivers/ptp/ptp_clock.c     |   26 ++++++++------------------
 include/linux/posix-clock.h |   10 +++++-----
 kernel/time/posix-clock.c   |   20 ++++++++++----------
 3 files changed, 23 insertions(+), 33 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index bee8270..8c086e7 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -97,32 +97,24 @@ static s32 scaled_ppm_to_ppb(long ppm)
 
 /* posix clock implementation */
 
-static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
+static int ptp_clock_getres(struct posix_clock *pc, struct timespec64 *tp)
 {
 	tp->tv_sec = 0;
 	tp->tv_nsec = 1;
 	return 0;
 }
 
-static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
+static int ptp_clock_settime(struct posix_clock *pc,
+				const struct timespec64 *tp)
 {
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	struct timespec64 ts = timespec_to_timespec64(*tp);
-
-	return ptp->info->settime64(ptp->info, &ts);
+	return ptp->info->settime64(ptp->info, tp);
 }
 
-static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
+static int ptp_clock_gettime(struct posix_clock *pc, struct timespec64 *tp)
 {
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	struct timespec64 ts;
-	int err;
-
-	err = ptp->info->gettime64(ptp->info, &ts);
-	if (!err)
-		*tp = timespec64_to_timespec(ts);
-
-	return err;
+	return ptp->info->gettime64(ptp->info, tp);
 }
 
 static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
@@ -134,8 +126,7 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 	ops = ptp->info;
 
 	if (tx->modes & ADJ_SETOFFSET) {
-		struct timespec ts;
-		ktime_t kt;
+		struct timespec64 ts;
 		s64 delta;
 
 		ts.tv_sec  = tx->time.tv_sec;
@@ -147,8 +138,7 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 		if ((unsigned long) ts.tv_nsec >= NSEC_PER_SEC)
 			return -EINVAL;
 
-		kt = timespec_to_ktime(ts);
-		delta = ktime_to_ns(kt);
+		delta = timespec64_to_ns(&ts);
 		err = ops->adjtime(ops, delta);
 	} else if (tx->modes & ADJ_FREQUENCY) {
 		s32 ppb = scaled_ppm_to_ppb(tx->freq);
diff --git a/include/linux/posix-clock.h b/include/linux/posix-clock.h
index 34c4498..fd7e22c 100644
--- a/include/linux/posix-clock.h
+++ b/include/linux/posix-clock.h
@@ -59,23 +59,23 @@ struct posix_clock_operations {
 
 	int  (*clock_adjtime)(struct posix_clock *pc, struct timex *tx);
 
-	int  (*clock_gettime)(struct posix_clock *pc, struct timespec *ts);
+	int  (*clock_gettime)(struct posix_clock *pc, struct timespec64 *ts);
 
-	int  (*clock_getres) (struct posix_clock *pc, struct timespec *ts);
+	int  (*clock_getres)(struct posix_clock *pc, struct timespec64 *ts);
 
 	int  (*clock_settime)(struct posix_clock *pc,
-			      const struct timespec *ts);
+			      const struct timespec64 *ts);
 
 	int  (*timer_create) (struct posix_clock *pc, struct k_itimer *kit);
 
 	int  (*timer_delete) (struct posix_clock *pc, struct k_itimer *kit);
 
 	void (*timer_gettime)(struct posix_clock *pc,
-			      struct k_itimer *kit, struct itimerspec *tsp);
+			      struct k_itimer *kit, struct itimerspec64 *tsp);
 
 	int  (*timer_settime)(struct posix_clock *pc,
 			      struct k_itimer *kit, int flags,
-			      struct itimerspec *tsp, struct itimerspec *old);
+			      struct itimerspec64 *tsp, struct itimerspec64 *old);
 	/*
 	 * Optional character device methods:
 	 */
diff --git a/kernel/time/posix-clock.c b/kernel/time/posix-clock.c
index ce033c7..e21e4c1 100644
--- a/kernel/time/posix-clock.c
+++ b/kernel/time/posix-clock.c
@@ -297,7 +297,7 @@ out:
 	return err;
 }
 
-static int pc_clock_gettime(clockid_t id, struct timespec *ts)
+static int pc_clock_gettime(clockid_t id, struct timespec64 *ts)
 {
 	struct posix_clock_desc cd;
 	int err;
@@ -316,7 +316,7 @@ static int pc_clock_gettime(clockid_t id, struct timespec *ts)
 	return err;
 }
 
-static int pc_clock_getres(clockid_t id, struct timespec *ts)
+static int pc_clock_getres(clockid_t id, struct timespec64 *ts)
 {
 	struct posix_clock_desc cd;
 	int err;
@@ -335,7 +335,7 @@ static int pc_clock_getres(clockid_t id, struct timespec *ts)
 	return err;
 }
 
-static int pc_clock_settime(clockid_t id, const struct timespec *ts)
+static int pc_clock_settime(clockid_t id, const struct timespec64 *ts)
 {
 	struct posix_clock_desc cd;
 	int err;
@@ -399,7 +399,7 @@ static int pc_timer_delete(struct k_itimer *kit)
 	return err;
 }
 
-static void pc_timer_gettime(struct k_itimer *kit, struct itimerspec *ts)
+static void pc_timer_gettime(struct k_itimer *kit, struct itimerspec64 *ts)
 {
 	clockid_t id = kit->it_clock;
 	struct posix_clock_desc cd;
@@ -414,7 +414,7 @@ static void pc_timer_gettime(struct k_itimer *kit, struct itimerspec *ts)
 }
 
 static int pc_timer_settime(struct k_itimer *kit, int flags,
-			    struct itimerspec *ts, struct itimerspec *old)
+			    struct itimerspec64 *ts, struct itimerspec64 *old)
 {
 	clockid_t id = kit->it_clock;
 	struct posix_clock_desc cd;
@@ -435,12 +435,12 @@ static int pc_timer_settime(struct k_itimer *kit, int flags,
 }
 
 struct k_clock clock_posix_dynamic = {
-	.clock_getres	= pc_clock_getres,
-	.clock_set	= pc_clock_settime,
-	.clock_get	= pc_clock_gettime,
+	.clock_getres64	= pc_clock_getres,
+	.clock_set64	= pc_clock_settime,
+	.clock_get64	= pc_clock_gettime,
 	.clock_adj	= pc_clock_adjtime,
 	.timer_create	= pc_timer_create,
-	.timer_set	= pc_timer_settime,
+	.timer_set64	= pc_timer_settime,
 	.timer_del	= pc_timer_delete,
-	.timer_get	= pc_timer_gettime,
+	.timer_get64	= pc_timer_gettime,
 };
-- 
1.7.9.5
