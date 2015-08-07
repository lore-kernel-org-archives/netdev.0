From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 3/4] Add support for driver cross-timestamp to PTP_SYS_OFFSET ioctl
Date: Fri,  7 Aug 2015 16:01:34 -0700
Message-ID: <1438988495-9942-4-git-send-email-christopher.s.hall@intel.com>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows system and device time ("cross-timestamp") to be
performed by the driver. Currently, the cross-timestamping is performed
in the PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday()
and the gettime64() callback provided by the driver. The cross-timestamp
is best effort where the latency between the capture of system time
(getnstimeofday()) and the device time (driver callback) may be
significant.

This patch adds an additional callback getsynctime64(). Which will be
called when the driver is able to perform a more accurate, implementation
specific cross-timestamping.  For example, future network devices that
implement PCIE PTM will be able to precisely correlate the device clock
with the system clock with virtually zero latency between captures.
This added callback can be used by the driver to expose this functionality.

The callback, getsynctime64(), will only be called when defined and
n_samples == 1 because the driver returns only 1 cross-timestamp where
multiple samples cannot be chained together.

This patch also adds to the capabilities ioctl (PTP_CLOCK_GETCAPS),
allowing applications to query whether or not drivers implement the
getsynctime callback, providing more precise cross timestamping.

Commit Details:

Added additional callback to ptp_clock_info:

* getsynctime64()

This takes 2 arguments referring to system and device time

With this callback drivers may provide both system time and device time
to ensure precise correlation

Modified PTP_SYS_OFFSET ioctl in PTP clock driver to use the above
callback if it's available

Added capability (PTP_CLOCK_GETCAPS) for checking whether driver supports
cross timestamping

Added check for cross timestamping flag to testptp.c
---
 Documentation/ptp/testptp.c      |  6 ++++--
 drivers/ptp/ptp_chardev.c        | 29 +++++++++++++++++++++--------
 include/linux/ptp_clock_kernel.h |  7 +++++++
 include/uapi/linux/ptp_clock.h   |  4 +++-
 4 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
index 2bc8abc..8004efd 100644
--- a/Documentation/ptp/testptp.c
+++ b/Documentation/ptp/testptp.c
@@ -276,13 +276,15 @@ int main(int argc, char *argv[])
 			       "  %d external time stamp channels\n"
 			       "  %d programmable periodic signals\n"
 			       "  %d pulse per second\n"
-			       "  %d programmable pins\n",
+			       "  %d programmable pins\n"
+			       "  %d cross timestamping\n",
 			       caps.max_adj,
 			       caps.n_alarm,
 			       caps.n_ext_ts,
 			       caps.n_per_out,
 			       caps.pps,
-			       caps.n_pins);
+			       caps.n_pins,
+			       caps.cross_timestamping);
 		}
 	}
 
diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index da7bae9..392ccfa 100644
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
+		caps.cross_timestamping = ptp->info->getsynctime64 != NULL;
 		if (copy_to_user((void __user *)arg, &caps, sizeof(caps)))
 			err = -EFAULT;
 		break;
@@ -196,19 +197,31 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 			break;
 		}
 		pct = &sysoff->ts[0];
-		for (i = 0; i < sysoff->n_samples; i++) {
-			getnstimeofday64(&ts);
+		if (ptp->info->getsynctime64 && sysoff->n_samples == 1 &&
+		    ptp->info->getsynctime64(ptp->info, &ts, &systs) == 0) {
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
index b8b7306..8c43345 100644
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
@@ -105,6 +110,8 @@ struct ptp_clock_info {
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
+	int (*getsynctime64)(struct ptp_clock_info *ptp, struct timespec64 *dev,
+			struct timespec64 *sys);
 	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
index f0b7bfe..ffb2635 100644
--- a/include/uapi/linux/ptp_clock.h
+++ b/include/uapi/linux/ptp_clock.h
@@ -51,7 +51,9 @@ struct ptp_clock_caps {
 	int n_per_out; /* Number of programmable periodic signals. */
 	int pps;       /* Whether the clock supports a PPS callback. */
 	int n_pins;    /* Number of input/output pins. */
-	int rsv[14];   /* Reserved for future use. */
+	/* Whether the clock supports precise system-device cross timestamps */
+	int cross_timestamping;
+	int rsv[13];   /* Reserved for future use. */
 };
 
 struct ptp_extts_request {
-- 
1.9.1
