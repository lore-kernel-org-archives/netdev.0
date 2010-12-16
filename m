From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Thu, 16 Dec 2010 16:41:59 +0100
Message-ID: <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1292512461.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new mode bit into the timex structure. When set, the bit
instructs the kernel to add the given time value to the current time.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 include/linux/timex.h |    3 ++-
 kernel/time/ntp.c     |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/include/linux/timex.h b/include/linux/timex.h
index 32d852f..82d4b24 100644
--- a/include/linux/timex.h
+++ b/include/linux/timex.h
@@ -73,7 +73,7 @@ struct timex {
 	long tolerance;		/* clock frequency tolerance (ppm)
 				 * (read only)
 				 */
-	struct timeval time;	/* (read only) */
+	struct timeval time;	/* (read only, except for ADJ_SETOFFSET) */
 	long tick;		/* (modified) usecs between clock ticks */
 
 	long ppsfreq;           /* pps frequency (scaled ppm) (ro) */
@@ -101,6 +101,7 @@ struct timex {
 #define ADJ_ESTERROR		0x0008	/* estimated time error */
 #define ADJ_STATUS		0x0010	/* clock status */
 #define ADJ_TIMECONST		0x0020	/* pll time constant */
+#define ADJ_SETOFFSET		0x0040  /* add 'time' to current time */
 #define ADJ_TAI			0x0080	/* set TAI offset */
 #define ADJ_MICRO		0x1000	/* select microsecond resolution */
 #define ADJ_NANO		0x2000	/* select nanosecond resolution */
diff --git a/kernel/time/ntp.c b/kernel/time/ntp.c
index d232189..e9e3915 100644
--- a/kernel/time/ntp.c
+++ b/kernel/time/ntp.c
@@ -454,6 +454,7 @@ static inline void process_adjtimex_modes(struct timex *txc, struct timespec *ts
 int do_adjtimex(struct timex *txc)
 {
 	struct timespec ts;
+	ktime_t delta, kt;
 	int result;
 
 	/* Validate the data before disabling interrupts */
@@ -482,8 +483,33 @@ int do_adjtimex(struct timex *txc)
 			hrtimer_cancel(&leap_timer);
 	}
 
+	if (txc->modes & ADJ_SETOFFSET) {
+		/* Validate the delta value. */
+		if (txc->time.tv_sec && txc->time.tv_usec < 0)
+			return -EINVAL;
+
+		if (txc->modes & ADJ_NANO) {
+			struct timespec tmp;
+			tmp.tv_sec  = txc->time.tv_sec;
+			tmp.tv_nsec = txc->time.tv_usec;
+			delta = timespec_to_ktime(tmp);
+		} else
+			delta = timeval_to_ktime(txc->time);
+
+		/* Adding the delta should be an "atomic" operation. */
+		local_irq_disable();
+	}
+
 	getnstimeofday(&ts);
 
+	if (txc->modes & ADJ_SETOFFSET) {
+		kt = timespec_to_ktime(ts);
+		kt = ktime_add(kt, delta);
+		ts = ktime_to_timespec(kt);
+		do_settimeofday(&ts);
+		local_irq_enable();
+	}
+
 	write_seqlock_irq(&xtime_lock);
 
 	if (txc->modes & ADJ_ADJTIME) {
-- 
1.7.0.4
