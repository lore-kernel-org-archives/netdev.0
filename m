From: Joe Perches <joe@perches.com>
Subject: [PATCH] jiffies conversions: Use compile time constants when
 possible
Date: Fri, 04 Jan 2013 13:15:43 -0800
Message-ID: <1357334143.5452.66.camel@joe-AO722>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357252816.21409.26384.camel@edumazet-glaptop>
	 <1357285780.21409.28416.camel@edumazet-glaptop>
	 <1357287351.5452.44.camel@joe-AO722>
	 <1357287786.1678.87.camel@edumazet-glaptop>
	 <1357290721.5452.55.camel@joe-AO722>
	 <1357318824.1678.1678.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43429 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755243Ab3ADVPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2013 16:15:44 -0500
In-Reply-To: <1357318824.1678.1678.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the multiplications and divisions at compile time
instead of runtime when the converted value is a constant.

Make the calculation functions static __always_inline to jiffies.h.

Add #defines with __builtin_constant_p to test and use the
static inline or the runtime functions as appropriate.

Prefix the old exported symbols/functions with __

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/jiffies.h | 136 ++++++++++++++++++++++++++++++++++++++++++++++--
 kernel/time.c           | 106 +++++--------------------------------
 2 files changed, 144 insertions(+), 98 deletions(-)

diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index 82ed068..88578e4 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -289,10 +289,138 @@ extern unsigned long preset_lpj;
 /*
  * Convert various time units to each other:
  */
-extern unsigned int jiffies_to_msecs(const unsigned long j);
-extern unsigned int jiffies_to_usecs(const unsigned long j);
-extern unsigned long msecs_to_jiffies(const unsigned int m);
-extern unsigned long usecs_to_jiffies(const unsigned int u);
+
+/*
+ * Avoid unnecessary multiplications/divisions in the
+ * two most common HZ cases:
+ */
+static __always_inline unsigned int
+__inline_jiffies_to_msecs(const unsigned long j)
+{
+#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
+	return (MSEC_PER_SEC / HZ) * j;
+#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
+	return (j + (HZ / MSEC_PER_SEC) - 1)/(HZ / MSEC_PER_SEC);
+#else
+# if BITS_PER_LONG == 32
+	return (HZ_TO_MSEC_MUL32 * j) >> HZ_TO_MSEC_SHR32;
+# else
+	return (j * HZ_TO_MSEC_NUM) / HZ_TO_MSEC_DEN;
+# endif
+#endif
+}
+extern unsigned int __jiffies_to_msecs(const unsigned long j);
+
+#define jiffies_to_msecs(x)			\
+	(__builtin_constant_p(x) ?		\
+	 __inline_jiffies_to_msecs(x) :		\
+	 __jiffies_to_msecs(x))
+
+static __always_inline unsigned int
+__inline_jiffies_to_usecs(const unsigned long j)
+{
+#if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
+	return (USEC_PER_SEC / HZ) * j;
+#elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
+	return (j + (HZ / USEC_PER_SEC) - 1)/(HZ / USEC_PER_SEC);
+#else
+# if BITS_PER_LONG == 32
+	return (HZ_TO_USEC_MUL32 * j) >> HZ_TO_USEC_SHR32;
+# else
+	return (j * HZ_TO_USEC_NUM) / HZ_TO_USEC_DEN;
+# endif
+#endif
+}
+extern unsigned int __jiffies_to_usecs(const unsigned long j);
+
+#define jiffies_to_usecs(x)			\
+	(__builtin_constant_p(x) ?		\
+	 __inline_jiffies_to_usecs(x) :		\
+	 __jiffies_to_usecs(x))
+
+/*
+ * When we convert to jiffies then we interpret incoming values
+ * the following way:
+ *
+ * - negative values mean 'infinite timeout' (MAX_JIFFY_OFFSET)
+ *
+ * - 'too large' values [that would result in larger than
+ *   MAX_JIFFY_OFFSET values] mean 'infinite timeout' too.
+ *
+ * - all other values are converted to jiffies by either multiplying
+ *   the input value by a factor or dividing it with a factor
+ *
+ * We must also be careful about 32-bit overflows.
+ */
+static __always_inline unsigned long
+__inline_msecs_to_jiffies(const unsigned int m)
+{
+	/*
+	 * Negative value, means infinite timeout:
+	 */
+	if ((int)m < 0)
+		return MAX_JIFFY_OFFSET;
+
+#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
+	/*
+	 * HZ is equal to or smaller than 1000, and 1000 is a nice
+	 * round multiple of HZ, divide with the factor between them,
+	 * but round upwards:
+	 */
+	return (m + (MSEC_PER_SEC / HZ) - 1) / (MSEC_PER_SEC / HZ);
+#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
+	/*
+	 * HZ is larger than 1000, and HZ is a nice round multiple of
+	 * 1000 - simply multiply with the factor between them.
+	 *
+	 * But first make sure the multiplication result cannot
+	 * overflow:
+	 */
+	if (m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+
+	return m * (HZ / MSEC_PER_SEC);
+#else
+	/*
+	 * Generic case - multiply, round and divide. But first
+	 * check that if we are doing a net multiplication, that
+	 * we wouldn't overflow:
+	 */
+	if (HZ > MSEC_PER_SEC && m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+
+	return (MSEC_TO_HZ_MUL32 * m + MSEC_TO_HZ_ADJ32)
+		>> MSEC_TO_HZ_SHR32;
+#endif
+}
+extern unsigned long __msecs_to_jiffies(const unsigned int m);
+
+#define msecs_to_jiffies(x)			\
+	(__builtin_constant_p(x) ?		\
+	 __inline_msecs_to_jiffies(x) :		\
+	 __msecs_to_jiffies(x))
+
+static __always_inline unsigned long
+__inline_usecs_to_jiffies(const unsigned int u)
+{
+	if (u > jiffies_to_usecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+#if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
+	return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);
+#elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
+	return u * (HZ / USEC_PER_SEC);
+#else
+	return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
+		>> USEC_TO_HZ_SHR32;
+#endif
+}
+extern unsigned long __usecs_to_jiffies(const unsigned int u);
+
+#define usecs_to_jiffies(x)			\
+	(__builtin_constant_p(x) ?		\
+	 __inline_usecs_to_jiffies(x) :		\
+	 __usecs_to_jiffies(x))
+
 extern unsigned long timespec_to_jiffies(const struct timespec *value);
 extern void jiffies_to_timespec(const unsigned long jiffies,
 				struct timespec *value);
diff --git a/kernel/time.c b/kernel/time.c
index d226c6a..b9d1024 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -228,41 +228,18 @@ EXPORT_SYMBOL(current_fs_time);
 
 /*
  * Convert jiffies to milliseconds and back.
- *
- * Avoid unnecessary multiplications/divisions in the
- * two most common HZ cases:
  */
-inline unsigned int jiffies_to_msecs(const unsigned long j)
+unsigned int __jiffies_to_msecs(const unsigned long j)
 {
-#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
-	return (MSEC_PER_SEC / HZ) * j;
-#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
-	return (j + (HZ / MSEC_PER_SEC) - 1)/(HZ / MSEC_PER_SEC);
-#else
-# if BITS_PER_LONG == 32
-	return (HZ_TO_MSEC_MUL32 * j) >> HZ_TO_MSEC_SHR32;
-# else
-	return (j * HZ_TO_MSEC_NUM) / HZ_TO_MSEC_DEN;
-# endif
-#endif
+	return __inline_jiffies_to_msecs(j);
 }
-EXPORT_SYMBOL(jiffies_to_msecs);
+EXPORT_SYMBOL(__jiffies_to_msecs);
 
-inline unsigned int jiffies_to_usecs(const unsigned long j)
+unsigned int __jiffies_to_usecs(const unsigned long j)
 {
-#if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
-	return (USEC_PER_SEC / HZ) * j;
-#elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
-	return (j + (HZ / USEC_PER_SEC) - 1)/(HZ / USEC_PER_SEC);
-#else
-# if BITS_PER_LONG == 32
-	return (HZ_TO_USEC_MUL32 * j) >> HZ_TO_USEC_SHR32;
-# else
-	return (j * HZ_TO_USEC_NUM) / HZ_TO_USEC_DEN;
-# endif
-#endif
+	return __inline_jiffies_to_usecs(j);
 }
-EXPORT_SYMBOL(jiffies_to_usecs);
+EXPORT_SYMBOL(__jiffies_to_usecs);
 
 /**
  * timespec_trunc - Truncate timespec to a granularity
@@ -411,76 +388,17 @@ struct timeval ns_to_timeval(const s64 nsec)
 }
 EXPORT_SYMBOL(ns_to_timeval);
 
-/*
- * When we convert to jiffies then we interpret incoming values
- * the following way:
- *
- * - negative values mean 'infinite timeout' (MAX_JIFFY_OFFSET)
- *
- * - 'too large' values [that would result in larger than
- *   MAX_JIFFY_OFFSET values] mean 'infinite timeout' too.
- *
- * - all other values are converted to jiffies by either multiplying
- *   the input value by a factor or dividing it with a factor
- *
- * We must also be careful about 32-bit overflows.
- */
-unsigned long msecs_to_jiffies(const unsigned int m)
+unsigned long __msecs_to_jiffies(const unsigned int m)
 {
-	/*
-	 * Negative value, means infinite timeout:
-	 */
-	if ((int)m < 0)
-		return MAX_JIFFY_OFFSET;
-
-#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
-	/*
-	 * HZ is equal to or smaller than 1000, and 1000 is a nice
-	 * round multiple of HZ, divide with the factor between them,
-	 * but round upwards:
-	 */
-	return (m + (MSEC_PER_SEC / HZ) - 1) / (MSEC_PER_SEC / HZ);
-#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
-	/*
-	 * HZ is larger than 1000, and HZ is a nice round multiple of
-	 * 1000 - simply multiply with the factor between them.
-	 *
-	 * But first make sure the multiplication result cannot
-	 * overflow:
-	 */
-	if (m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
-		return MAX_JIFFY_OFFSET;
-
-	return m * (HZ / MSEC_PER_SEC);
-#else
-	/*
-	 * Generic case - multiply, round and divide. But first
-	 * check that if we are doing a net multiplication, that
-	 * we wouldn't overflow:
-	 */
-	if (HZ > MSEC_PER_SEC && m > jiffies_to_msecs(MAX_JIFFY_OFFSET))
-		return MAX_JIFFY_OFFSET;
-
-	return (MSEC_TO_HZ_MUL32 * m + MSEC_TO_HZ_ADJ32)
-		>> MSEC_TO_HZ_SHR32;
-#endif
+	return __inline_msecs_to_jiffies(m);
 }
-EXPORT_SYMBOL(msecs_to_jiffies);
+EXPORT_SYMBOL(__msecs_to_jiffies);
 
-unsigned long usecs_to_jiffies(const unsigned int u)
+unsigned long __usecs_to_jiffies(const unsigned int u)
 {
-	if (u > jiffies_to_usecs(MAX_JIFFY_OFFSET))
-		return MAX_JIFFY_OFFSET;
-#if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
-	return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);
-#elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
-	return u * (HZ / USEC_PER_SEC);
-#else
-	return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
-		>> USEC_TO_HZ_SHR32;
-#endif
+	return __inline_usecs_to_jiffies(u);
 }
-EXPORT_SYMBOL(usecs_to_jiffies);
+EXPORT_SYMBOL(__usecs_to_jiffies);
 
 /*
  * The TICK_NSEC - 1 rounds up the value to the next resolution.  Note
