From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 02/11] timekeeping:Introduce the current_kernel_time64() function with timespec64 type
Date: Mon, 20 Apr 2015 13:57:30 +0800
Message-ID: <1429509459-17068-3-git-send-email-baolin.wang@linaro.org>
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

This patch adds current_kernel_time64() function with timespec64 type,
and makes current_kernel_time() 'static inline' and moves it to timekeeping.h
file.

It is convenient for user to get the current kernel time with timespec64 type,
and delete the current_kernel_time() function easily in timekeeping.h file. That
is ready for 2038 when get the current time.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/timekeeping.h |   10 +++++++++-
 kernel/time/timekeeping.c   |    6 +++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index 3eaae47..c6d5ae9 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -18,10 +18,18 @@ extern int do_sys_settimeofday(const struct timespec *tv,
  * Kernel time accessors
  */
 unsigned long get_seconds(void);
-struct timespec current_kernel_time(void);
+struct timespec64 current_kernel_time64(void);
 /* does not take xtime_lock */
 struct timespec __current_kernel_time(void);
 
+static inline struct timespec current_kernel_time(void)
+{
+	struct timespec64 now;
+
+	now = current_kernel_time64();
+	return timespec64_to_timespec(now);
+}
+
 /*
  * timespec based interfaces
  */
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index 91db941..8ccc02c 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -1721,7 +1721,7 @@ struct timespec __current_kernel_time(void)
 	return timespec64_to_timespec(tk_xtime(tk));
 }
 
-struct timespec current_kernel_time(void)
+struct timespec64 current_kernel_time64(void)
 {
 	struct timekeeper *tk = &tk_core.timekeeper;
 	struct timespec64 now;
@@ -1733,9 +1733,9 @@ struct timespec current_kernel_time(void)
 		now = tk_xtime(tk);
 	} while (read_seqcount_retry(&tk_core.seq, seq));
 
-	return timespec64_to_timespec(now);
+	return now;
 }
-EXPORT_SYMBOL(current_kernel_time);
+EXPORT_SYMBOL(current_kernel_time64);
 
 struct timespec64 get_monotonic_coarse64(void)
 {
-- 
1.7.9.5
