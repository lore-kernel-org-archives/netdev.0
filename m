From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 09/11] cputime:Introduce the cputime_to_timespec64/timespec64_to_cputime function
Date: Mon, 20 Apr 2015 13:57:37 +0800
Message-ID: <1429509459-17068-10-git-send-email-baolin.wang@linaro.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36331 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbbDTF7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 01:59:33 -0400
Received: by pabsx10 with SMTP id sx10so196503502pab.3
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 22:59:33 -0700 (PDT)
In-Reply-To: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces some functions for converting cputime to timespec64 and back,
that repalce the timespec type with timespec64 type, as well as for arch/s390 and
arch/powerpc architecture.

And these new methods will replace the old cputime_to_timespec/timespec_to_cputime
function to ready for 2038 issue. The cputime_to_timespec/timespec_to_cputime functions
are moved to include/linux/cputime.h file for removing conveniently.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 arch/powerpc/include/asm/cputime.h    |    6 +++---
 arch/s390/include/asm/cputime.h       |    8 ++++----
 include/asm-generic/cputime_jiffies.h |   10 +++++-----
 include/linux/cputime.h               |   15 +++++++++++++++
 include/linux/jiffies.h               |    3 +++
 kernel/time/time.c                    |   21 +++++++++++++++++++++
 6 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/include/asm/cputime.h b/arch/powerpc/include/asm/cputime.h
index e245255..5dda5c0 100644
--- a/arch/powerpc/include/asm/cputime.h
+++ b/arch/powerpc/include/asm/cputime.h
@@ -154,9 +154,9 @@ static inline cputime_t secs_to_cputime(const unsigned long sec)
 }
 
 /*
- * Convert cputime <-> timespec
+ * Convert cputime <-> timespec64
  */
-static inline void cputime_to_timespec(const cputime_t ct, struct timespec *p)
+static inline void cputime_to_timespec64(const cputime_t ct, struct timespec64 *p)
 {
 	u64 x = (__force u64) ct;
 	unsigned int frac;
@@ -168,7 +168,7 @@ static inline void cputime_to_timespec(const cputime_t ct, struct timespec *p)
 	p->tv_nsec = x;
 }
 
-static inline cputime_t timespec_to_cputime(const struct timespec *p)
+static inline cputime_t timespec64_to_cputime(const struct timespec64 *p)
 {
 	u64 ct;
 
diff --git a/arch/s390/include/asm/cputime.h b/arch/s390/include/asm/cputime.h
index b91e960..1266697 100644
--- a/arch/s390/include/asm/cputime.h
+++ b/arch/s390/include/asm/cputime.h
@@ -89,16 +89,16 @@ static inline cputime_t secs_to_cputime(const unsigned int s)
 }
 
 /*
- * Convert cputime to timespec and back.
+ * Convert cputime to timespec64 and back.
  */
-static inline cputime_t timespec_to_cputime(const struct timespec *value)
+static inline cputime_t timespec64_to_cputime(const struct timespec64 *value)
 {
 	unsigned long long ret = value->tv_sec * CPUTIME_PER_SEC;
 	return (__force cputime_t)(ret + __div(value->tv_nsec * CPUTIME_PER_USEC, NSEC_PER_USEC));
 }
 
-static inline void cputime_to_timespec(const cputime_t cputime,
-				       struct timespec *value)
+static inline void cputime_to_timespec64(const cputime_t cputime,
+				       struct timespec64 *value)
 {
 	unsigned long long __cputime = (__force unsigned long long) cputime;
 #ifndef CONFIG_64BIT
diff --git a/include/asm-generic/cputime_jiffies.h b/include/asm-generic/cputime_jiffies.h
index fe386fc..ec77c0b 100644
--- a/include/asm-generic/cputime_jiffies.h
+++ b/include/asm-generic/cputime_jiffies.h
@@ -44,12 +44,12 @@ typedef u64 __nocast cputime64_t;
 #define secs_to_cputime(sec)		jiffies_to_cputime((sec) * HZ)
 
 /*
- * Convert cputime to timespec and back.
+ * Convert cputime to timespec64 and abck.
  */
-#define timespec_to_cputime(__val)	\
-	jiffies_to_cputime(timespec_to_jiffies(__val))
-#define cputime_to_timespec(__ct,__val)	\
-	jiffies_to_timespec(cputime_to_jiffies(__ct),__val)
+#define timespec64_to_cputime(__val)      \
+	jiffies_to_cputime(timespec64_to_jiffies(__val))
+#define cputime_to_timespec64(__ct,__val)	\
+	jiffies_to_timespec64(cputime_to_jiffies(__ct),__val)
 
 /*
  * Convert cputime to timeval and back.
diff --git a/include/linux/cputime.h b/include/linux/cputime.h
index f2eb2ee..f01896f 100644
--- a/include/linux/cputime.h
+++ b/include/linux/cputime.h
@@ -13,4 +13,19 @@
 	usecs_to_cputime((__nsecs) / NSEC_PER_USEC)
 #endif
 
+static inline cputime_t timespec_to_cputime(const struct timespec *ts)
+{
+	struct timespec64 ts64 = timespec_to_timespec64(*ts);
+	return timespec64_to_cputime(&ts64);
+}
+
+static inline void cputime_to_timespec(const cputime_t cputime,
+					struct timespec *value)
+{
+	struct timespec64 *ts64;
+
+	*ts64 = timespec_to_timespec64(*value);
+	cputime_to_timespec64(cputime, ts64);
+}
+
 #endif /* __LINUX_CPUTIME_H */
diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index c367cbd..dbaa4ee 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -293,6 +293,9 @@ extern unsigned long usecs_to_jiffies(const unsigned int u);
 extern unsigned long timespec_to_jiffies(const struct timespec *value);
 extern void jiffies_to_timespec(const unsigned long jiffies,
 				struct timespec *value);
+extern unsigned long timespec64_to_jiffies(const struct timespec64 *value);
+extern void jiffies_to_timespec64(const unsigned long jiffies,
+				struct timespec64 *value);
 extern unsigned long timeval_to_jiffies(const struct timeval *value);
 extern void jiffies_to_timeval(const unsigned long jiffies,
 			       struct timeval *value);
diff --git a/kernel/time/time.c b/kernel/time/time.c
index 2c85b77..d5978c5 100644
--- a/kernel/time/time.c
+++ b/kernel/time/time.c
@@ -606,6 +606,27 @@ jiffies_to_timespec(const unsigned long jiffies, struct timespec *value)
 }
 EXPORT_SYMBOL(jiffies_to_timespec);
 
+unsigned long
+timespec64_to_jiffies(const struct timespec64 *value)
+{
+	return __timespec_to_jiffies(value->tv_sec, value->tv_nsec);
+}
+EXPORT_SYMBOL(timespec64_to_jiffies);
+
+void
+jiffies_to_timespec64(const unsigned long jiffies, struct timespec64 *value)
+{
+	/*
+	 * Convert jiffies to nanoseconds and separate with
+	 * one divide.
+	 */
+	u32 rem;
+	value->tv_sec = div_u64_rem((u64)jiffies * TICK_NSEC,
+				   NSEC_PER_SEC, &rem);
+	value->tv_nsec = rem;
+}
+EXPORT_SYMBOL(jiffies_to_timespec64);
+
 /*
  * We could use a similar algorithm to timespec_to_jiffies (with a
  * different multiplier for usec instead of nsec). But this has a
-- 
1.7.9.5
