From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 1/1] Added additional callback to ptp_clock_info:
Date: Thu,  2 Jul 2015 18:14:48 -0700
Message-ID: <1435886088-13890-2-git-send-email-christopher.s.hall@intel.com>
References: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de,
	christopher.s.hall@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25795 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059AbbGCBNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 21:13:41 -0400
In-Reply-To: <1435886088-13890-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* getsynctime64()

This takes 2 arguments referring to system and device time

With this callback drivers may provide both system time and device time
to ensure precise correlation

Modified PTP_SYS_OFFSET ioctl in PTP clock driver to use the above
callback if it's available

Added capability (PTP_CLOCK_GETCAPS) for checking whether driver supports
precise timestamping

Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
---
 drivers/ptp/ptp_chardev.c        | 29 +++++++++++++++++++++--------
 include/linux/ptp_clock_kernel.h |  8 ++++++++
 include/uapi/linux/ptp_clock.h   |  4 +++-
 3 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index da7bae9..2a83aea 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -124,7 +124,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
-	struct timespec64 ts;
+	struct timespec64 ts, systs;
 	int enable, err = 0;
 	unsigned int i, pin_index;
 
@@ -138,6 +138,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		caps.n_per_out = ptp->info->n_per_out;
 		caps.pps = ptp->info->pps;
 		caps.n_pins = ptp->info->n_pins;
+		caps.precise_timestamping = ptp->info->getsynctime64 != NULL;
 		if (copy_to_user((void __user *)arg, &caps, sizeof(caps)))
 			err = -EFAULT;
 		break;
@@ -196,19 +197,31 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 			break;
 		}
 		pct = &sysoff->ts[0];
-		for (i = 0; i < sysoff->n_samples; i++) {
-			getnstimeofday64(&ts);
+		if (ptp->info->getsynctime64 && sysoff->n_samples == 1) {
+			ptp->info->getsynctime64(ptp->info, &ts, &systs);
+			pct->sec = systs.tv_sec;
+			pct->nsec = systs.tv_nsec;
+			pct++;
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
 			pct++;
-			ptp->info->gettime64(ptp->info, &ts);
+			pct->sec = systs.tv_sec;
+			pct->nsec = systs.tv_nsec;
+		} else {
+			for (i = 0; i < sysoff->n_samples; i++) {
+				getnstimeofday64(&ts);
+				pct->sec = ts.tv_sec;
+				pct->nsec = ts.tv_nsec;
+				pct++;
+				ptp->info->gettime64(ptp->info, &ts);
+				pct->sec = ts.tv_sec;
+				pct->nsec = ts.tv_nsec;
+				pct++;
+			}
+			getnstimeofday64(&ts);
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
-			pct++;
 		}
-		getnstimeofday64(&ts);
-		pct->sec = ts.tv_sec;
-		pct->nsec = ts.tv_nsec;
 		if (copy_to_user((void __user *)arg, sysoff, sizeof(*sysoff)))
 			err = -EFAULT;
 		break;
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index b8b7306..344f129 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -67,6 +67,11 @@ struct ptp_clock_request {
  * @gettime64:  Reads the current time from the hardware clock.
  *              parameter ts: Holds the result.
  *
+ * @getsynctime64:  Reads the current time from the hardware clock and system
+ *                  clock simultaneously.
+ *                  parameter dev: Holds the device time
+ *                  parameter sys: Holds the system time
+ *
  * @settime64:  Set the current time on the hardware clock.
  *              parameter ts: Time value to set.
  *
@@ -105,6 +110,9 @@ struct ptp_clock_info {
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
+	int (*getsynctime64)
+		(struct ptp_clock_info *ptp, struct timespec64 *dev,
+		 struct timespec64 *sys);
 	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
index f0b7bfe..421b637 100644
--- a/include/uapi/linux/ptp_clock.h
+++ b/include/uapi/linux/ptp_clock.h
@@ -51,7 +51,9 @@ struct ptp_clock_caps {
 	int n_per_out; /* Number of programmable periodic signals. */
 	int pps;       /* Whether the clock supports a PPS callback. */
 	int n_pins;    /* Number of input/output pins. */
-	int rsv[14];   /* Reserved for future use. */
+	/* Whether the clock supports precise system-device cross timestamps */
+	int precise_timestamping;
+	int rsv[13];   /* Reserved for future use. */
 };
 
 struct ptp_extts_request {
-- 
1.9.1
