From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 11/12] [RFC] ipv4: avoid timespec in timestamp computation
Date: Wed, 30 Sep 2015 13:26:41 +0200
Message-ID: <1443612402-3000775-12-git-send-email-arnd@arndb.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an attempt to avoid the use of timespec in ipv4, where
getnstimeofday() used to be used for computing the number of
milliseconds since midnight, in three places.

That computation would overflow in 2038 on 32-bit machines,
and the normal workaround for this is to use timespec64, which
in turn requires an expensive div_s64_mod() function call
for calculating the seconds modulo 86400.

Instead, this approach introduces a new generic helper function
that does this more efficiently, by using only a 32-bit modulo
(which the compiler can turn into two multiplications), relying
on 39 bits to be sufficient for the current time of day. This
is roughly 100 times faster than a full divmod operation on ARM.

As a further optimization, this does not use the exact nanosecond
value but instead relies tk_xtime() to report the time of the
last jiffy, which is slightly less accurate, depending on the
value of HZ.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/timekeeping.h |  2 ++
 kernel/time/timekeeping.c   | 34 ++++++++++++++++++++++++++++++++++
 net/ipv4/icmp.c             |  8 +++-----
 net/ipv4/ip_options.c       |  9 ++-------
 4 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/include/linux/timekeeping.h b/include/linux/timekeeping.h
index ca2eaa9077eb..3e126f8c2876 100644
--- a/include/linux/timekeeping.h
+++ b/include/linux/timekeeping.h
@@ -44,6 +44,8 @@ extern void ktime_get_ts64(struct timespec64 *ts);
 extern time64_t ktime_get_seconds(void);
 extern time64_t ktime_get_real_seconds(void);
 
+extern u32 ktime_get_ms_since_midnight(void);
+
 extern int __getnstimeofday64(struct timespec64 *tv);
 extern void getnstimeofday64(struct timespec64 *tv);
 extern void getboottime64(struct timespec64 *ts);
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index ed5049ff94c5..3a1e030fa969 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -846,6 +846,40 @@ time64_t ktime_get_real_seconds(void)
 }
 EXPORT_SYMBOL_GPL(ktime_get_real_seconds);
 
+#if IS_ENABLED(CONFIG_INET)
+u32 ktime_get_ms_of_day(void)
+{
+	struct timekeeper *tk = &tk_core.timekeeper;
+	struct timespec64 now;
+	unsigned long seq;
+	u32 ms;
+
+	/* we assume that the coarse time is good enough here */
+	do {
+		seq = read_seqcount_begin(&tk_core.seq);
+
+		now = tk_xtime(tk);
+	} while (read_seqcount_retry(&tk_core.seq, seq));
+
+	/*
+	 * efficiently calculate the milliseconds since midnight:
+	 * 86400 seconds per day == 2^7 * 675, which helps us
+	 * replace an expensive div_s64_rem() with a hand-written
+	 * 39-bit modulo on 32-bit architectures.
+	 */
+	if (!IS_ENABLED(CONFIG_64BIT))
+		ms = (now.tv_sec & 0x7f) * MSEC_PER_SEC +
+		     ((u32)(now.tv_sec >> 7) % 675) * 0x80 * MSEC_PER_SEC;
+	else
+		ms = (now.tv_sec % 86400) * MSEC_PER_SEC;
+
+	ms += now.tv_nsec / NSEC_PER_MSEC;
+
+	return ms;
+}
+EXPORT_SYMBOL_GPL(ktime_get_ms_since_midnight);
+#endif
+
 #ifdef CONFIG_NTP_PPS
 
 /**
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5eb8ac4089d..b1c53f2f7bd5 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -914,7 +914,6 @@ static bool icmp_echo(struct sk_buff *skb)
  */
 static bool icmp_timestamp(struct sk_buff *skb)
 {
-	struct timespec tv;
 	struct icmp_bxm icmp_param;
 	/*
 	 *	Too short.
@@ -923,11 +922,10 @@ static bool icmp_timestamp(struct sk_buff *skb)
 		goto out_err;
 
 	/*
-	 *	Fill in the current time as ms since midnight UT:
+	 *	Fill in the current time as ms since midnight UT,
+	 *	this could probably be done faster.
 	 */
-	getnstimeofday(&tv);
-	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC +
-					 tv.tv_nsec / NSEC_PER_MSEC);
+	icmp_param.data.times[1] = htonl(ktime_get_ms_since_midnight());
 	icmp_param.data.times[2] = icmp_param.data.times[1];
 	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
 		BUG();
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index bd246792360b..339ce528ecae 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -58,10 +58,8 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 		if (opt->ts_needaddr)
 			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, skb, rt);
 		if (opt->ts_needtime) {
-			struct timespec tv;
 			__be32 midtime;
-			getnstimeofday(&tv);
-			midtime = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC);
+			midtime = htonl(ktime_get_ms_since_midnight());
 			memcpy(iph+opt->ts+iph[opt->ts+2]-5, &midtime, 4);
 		}
 		return;
@@ -415,10 +413,7 @@ int ip_options_compile(struct net *net,
 					break;
 				}
 				if (timeptr) {
-					struct timespec tv;
-					u32  midtime;
-					getnstimeofday(&tv);
-					midtime = (tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC;
+					u32 midtime = ktime_get_ms_since_midnight();
 					put_unaligned_be32(midtime, timeptr);
 					opt->is_changed = 1;
 				}
-- 
2.1.0.rc2
