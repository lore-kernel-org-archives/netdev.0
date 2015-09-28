From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/5] ntp/pps: replace getnstime_raw_and_real with 64-bit version
Date: Mon, 28 Sep 2015 22:21:29 +0200
Message-ID: <1443471692-2946597-3-git-send-email-arnd@arndb.de>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:56608 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbI1UXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 16:23:06 -0400
In-Reply-To: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is exactly one caller of getnstime_raw_and_real in the kernel,
which is the pps_get_ts function. This changes the caller and
the implementation to work on timespec64 types rather than timespec,
to avoid the time_t overflow on 32-bit architectures.

For consistency with the other new functions (ktime_get_seconds,
ktime_get_real_*, ...), I'm renaming the function to
ktime_get_raw_and_real_ts64.

We still need to convert from the internal 64-bit type to 32 bit
types in the caller, but this conversion is now pushed out from
getnstime_raw_and_real to pps_get_ts. A follow-up patch changes
the remaining pps code to completely avoid the conversion.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/pps_kernel.h  |  7 ++++++-
 include/linux/timekeeping.h |  4 ++--
 kernel/time/timekeeping.c   | 12 ++++++------
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/pps_kernel.h b/include/linux/pps_kernel.h
index 1d2cd21242e8..b2fbd62ab18d 100644
--- a/include/linux/pps_kernel.h
+++ b/include/linux/pps_kernel.h
@@ -115,7 +115,12 @@ static inline void timespec_to_pps_ktime(struct pps_ktime *kt,
 
 static inline void pps_get_ts(struct pps_event_time *ts)
 {
-	getnstime_raw_and_real(&ts->ts_raw, &ts->ts_real);
+	struct timespec64 raw, real;
+
+	ktime_get_raw_and_real_ts64(&raw, &real);
+
+	ts->ts_raw = timespec64_to_timespec(raw);
+	ts->ts_real = timespec64_to_timespec(real);
 }
 
 #else /* CONFIG_NTP_PPS */
diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 474331cd1ef8..ca2eaa9077eb 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -269,8 +269,8 @@ extern void timekeeping_inject_sleeptime64(struct timespec64 *delta);
 /*
  * PPS accessor
  */
-extern void getnstime_raw_and_real(struct timespec *ts_raw,
-				   struct timespec *ts_real);
+extern void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw,
+				        struct timespec64 *ts_real);
 
 /*
  * Persistent clock related interfaces
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 3112977dfca0..ed5049ff94c5 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -849,7 +849,7 @@ EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
 #ifdef CONFIG_NTP_PPS
 
 /**
- * getnstime_raw_and_real - get day and raw monotonic time in timespec format
+ * ktime_get_raw_and_real_ts64 - get day and raw monotonic time in timespec format
  * @ts_raw:	pointer to the timespec to be set to raw monotonic time
  * @ts_real:	pointer to the timespec to be set to the time of day
  *
@@ -857,7 +857,7 @@ EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
  * same time atomically and stores the resulting timestamps in timespec
  * format.
  */
-void getnstime_raw_and_real(struct timespec *ts_raw, struct timespec *ts_real)
+void ktime_get_raw_and_real_ts64(struct timespec64 *ts_raw, struct timespec64 *ts_real)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
 	unsigned long seq;
@@ -868,7 +868,7 @@ void getnstime_raw_and_real(struct timespec *ts_raw, struct timespec *ts_real)
 	do {
 		seq = read_seqcount_begin(&tk_core.seq);
 
-		*ts_raw = timespec64_to_timespec(tk->raw_time);
+		*ts_raw = tk->raw_time;
 		ts_real->tv_sec = tk->xtime_sec;
 		ts_real->tv_nsec = 0;
 
@@ -877,10 +877,10 @@ void getnstime_raw_and_real(struct timespec *ts_raw, struct timespec *ts_real)
 
 	} while (read_seqcount_retry(&tk_core.seq, seq));
 
-	timespec_add_ns(ts_raw, nsecs_raw);
-	timespec_add_ns(ts_real, nsecs_real);
+	timespec64_add_ns(ts_raw, nsecs_raw);
+	timespec64_add_ns(ts_real, nsecs_real);
 }
-EXPORT_SYMBOL(getnstime_raw_and_real);
+EXPORT_SYMBOL(ktime_get_raw_and_real_ts64);
 
 #endif /* CONFIG_NTP_PPS */
 
-- 
2.1.0.rc2
