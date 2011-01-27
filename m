From: John Stultz <richardcochran@gmail.com>
Subject: [PATCH V10 01/15] time: Introduce timekeeping_inject_offset
Date: Thu, 27 Jan 2011 11:54:04 +0100
Message-ID: <6aec014551fc1d34924d6a7bcf97769867c15ba9.1296124770.git.richard.cochran@omicron.at>
References: <cover.1296124770.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1296124770.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a kernel-internal timekeeping interface to add or subtract
a fixed amount from CLOCK_REALTIME. This makes it so kernel users or
interfaces trying to do so do not have to read the time, then add an
offset and then call settimeofday(), which adds some extra error in
comparision to just simply adding the offset in the kernel timekeeping
core.

CC: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/time.h      |    1 +
 kernel/time/timekeeping.c |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index 1e6d3b5..8863688 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -168,6 +168,7 @@ extern int timekeeping_valid_for_hres(void);
 extern u64 timekeeping_max_deferment(void);
 extern void update_wall_time(void);
 extern void timekeeping_leap_insert(int leapsecond);
+extern int timekeeping_inject_offset(struct timespec *ts);
 
 struct tms;
 extern void do_sys_times(struct tms *);
diff --git a/kernel/time/timekeeping.c b/kernel/time/timekeeping.c
index d27c756..1e284a5 100644
--- a/kernel/time/timekeeping.c
+++ b/kernel/time/timekeeping.c
@@ -387,6 +387,42 @@ int do_settimeofday(struct timespec *tv)
 
 EXPORT_SYMBOL(do_settimeofday);
 
+
+/**
+ * timekeeping_inject_offset - Adds or subtracts from the current time.
+ * @tv:		pointer to the timespec variable containing the offset
+ *
+ * Adds or subtracts an offset value from the current time.
+ */
+int timekeeping_inject_offset(struct timespec *ts)
+{
+	unsigned long flags;
+
+	if ((unsigned long)ts->tv_nsec >= NSEC_PER_SEC)
+		return -EINVAL;
+
+	write_seqlock_irqsave(&xtime_lock, flags);
+
+	timekeeping_forward_now();
+
+	xtime = timespec_add(xtime, *ts);
+	wall_to_monotonic = timespec_sub(wall_to_monotonic, *ts);
+
+	timekeeper.ntp_error = 0;
+	ntp_clear();
+
+	update_vsyscall(&xtime, &wall_to_monotonic, timekeeper.clock,
+				timekeeper.mult);
+
+	write_sequnlock_irqrestore(&xtime_lock, flags);
+
+	/* signal hrtimers about time change */
+	clock_was_set();
+
+	return 0;
+}
+EXPORT_SYMBOL(timekeeping_inject_offset);
+
 /**
  * change_clocksource - Swaps clocksources if a new one is available
  *
-- 
1.7.0.4
