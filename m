From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next] softirq: reduce latencies
Date: Fri, 04 Jan 2013 01:12:01 -0800
Message-ID: <1357290721.5452.55.camel@joe-AO722>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
	 <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	 <1357252816.21409.26384.camel@edumazet-glaptop>
	 <1357285780.21409.28416.camel@edumazet-glaptop>
	 <1357287351.5452.44.camel@joe-AO722>
	 <1357287786.1678.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357287786.1678.87.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-04 at 00:23 -0800, Eric Dumazet wrote:
> On Fri, 2013-01-04 at 00:15 -0800, Joe Perches wrote:
> > Perhaps MAX_SOFTIRQ_TIME should be
> > #define MAX_SOFTIRQ_TIME msecs_to_jiffies(2)
> > though it would be nicer if it were a compile time constant.
> 
> If you send a patch to convert msecs_to_jiffies() to an inline function
> when HZ = 1000, I will gladly use it instead of (2*HZ/1000)
> 
> Right now, max(1, msecs_to_jiffies(2)) uses way too many instructions,
> while it should be the constant 2, known at compile time.

Something like this might work.

This is incomplete, it just does msecs_to_jiffies,
and it should convert usecs_to_jiffies and the
jiffies_to_<foo> types too.

Maybe it's worthwhile.

It does reduce object size by 16 bytes per call site
(x86-32) when the argument is a constant. There are
about 800 of these jiffies conversions in kernel sources.

What do you think?

 include/linux/jiffies.h | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/time.c           | 42 +++---------------------------------------
 2 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index 82ed068..c67ddcf 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -291,7 +291,54 @@ extern unsigned long preset_lpj;
  */
 extern unsigned int jiffies_to_msecs(const unsigned long j);
 extern unsigned int jiffies_to_usecs(const unsigned long j);
-extern unsigned long msecs_to_jiffies(const unsigned int m);
+extern unsigned long __msecs_to_jiffies(const unsigned int m);
+
+static inline unsigned long __inline_msecs_to_jiffies(const unsigned int m)
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
+
+#define msecs_to_jiffies(x)			\
+	(__builtin_constant_p(x) ?		\
+	 __inline_msecs_to_jiffies(x) :		\
+	 __msecs_to_jiffies(x))
+
 extern unsigned long usecs_to_jiffies(const unsigned int u);
 extern unsigned long timespec_to_jiffies(const struct timespec *value);
 extern void jiffies_to_timespec(const unsigned long jiffies,
diff --git a/kernel/time.c b/kernel/time.c
index d226c6a..231f2ac 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -425,47 +425,11 @@ EXPORT_SYMBOL(ns_to_timeval);
  *
  * We must also be careful about 32-bit overflows.
  */
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
 
 unsigned long usecs_to_jiffies(const unsigned int u)
 {
