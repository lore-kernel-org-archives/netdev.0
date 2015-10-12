From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v4 3/4] Add PTP_SYS_OFFSET_PRECISE for driver crosstimestamping
Date: Mon, 12 Oct 2015 11:45:21 -0700
Message-ID: <1444675522-4198-4-git-send-email-christopher.s.hall@intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
Cc: x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com,
	"Christopher S. Hall" <christopher.s.hall@intel.com>
To: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, network /system cross-timestamping is performed in the
PTP_SYS_OFFSET ioctl. The PTP clock driver reads gettimeofday() and the
gettime64() callback provided by the driver. The cross-timestamp is best
effort where the latency between the capture of system time
(getnstimeofday()) and the device time (driver callback) may be significant.

The getsynctime() callback and corresponding PTP_SYS_OFFSET_PRECISE ioctl
allows the driver to perform this device/system correlation when for example
cross timestamp hardware is available. Modern Intel systems can do this for
onboard Ethernet controllers using the ART counter. There is virtually zero
latency between captures of the ART and network device clock.

The capabilities ioctl (PTP_CLOCK_GETCAPS), is augmented allowing
applications to query whether or not drivers implement the
getsynctime callback, providing more precise cross timestamping.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 Documentation/ptp/testptp.c      |  6 ++++--
 drivers/ptp/ptp_chardev.c        | 26 ++++++++++++++++++++++++++
 include/linux/ptp_clock_kernel.h |  6 ++++++
 include/uapi/linux/ptp_clock.h   | 12 +++++++++++-
 4 files changed, 47 insertions(+), 3 deletions(-)

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
index da7bae9..7db6f02 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -120,11 +120,14 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 	struct ptp_clock_caps caps;
 	struct ptp_clock_request req;
 	struct ptp_sys_offset *sysoff = NULL;
+	struct ptp_sys_offset_precise precise_offset;
 	struct ptp_pin_desc pd;
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
 	struct timespec64 ts;
+	u64 cross_dev, cross_sys;
+	u32 rem;
 	int enable, err = 0;
 	unsigned int i, pin_index;
 
@@ -138,6 +141,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		caps.n_per_out = ptp->info->n_per_out;
 		caps.pps = ptp->info->pps;
 		caps.n_pins = ptp->info->n_pins;
+		caps.cross_timestamping = ptp->info->getsynctime != NULL;
 		if (copy_to_user((void __user *)arg, &caps, sizeof(caps)))
 			err = -EFAULT;
 		break;
@@ -180,6 +184,28 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		err = ops->enable(ops, &req, enable);
 		break;
 
+	case PTP_SYS_OFFSET_PRECISE:
+		if (!ptp->info->getsynctime || ptp->info->getsynctime(
+			    ptp->info, &cross_dev, &cross_sys)) {
+			err = -ENOSYS;
+			break;
+		}
+		if (copy_from_user(&precise_offset, (void __user *)arg,
+				   sizeof(precise_offset))) {
+			err = -EFAULT;
+			break;
+		}
+		precise_offset.dev.sec =
+			div_u64_rem(cross_dev, NSEC_PER_SEC, &rem);
+		precise_offset.dev.nsec = rem;
+		precise_offset.sys.sec =
+			div_u64_rem(cross_sys, NSEC_PER_SEC, &rem);
+		precise_offset.sys.nsec = rem;
+		if (copy_to_user((void __user *)arg, &precise_offset,
+				 sizeof(precise_offset)))
+			err = -EFAULT;
+		break;
+
 	case PTP_SYS_OFFSET:
 		sysoff = kmalloc(sizeof(*sysoff), GFP_KERNEL);
 		if (!sysoff) {
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index b8b7306..eb6fe50 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -67,6 +67,11 @@ struct ptp_clock_request {
  * @gettime64:  Reads the current time from the hardware clock.
  *              parameter ts: Holds the result.
  *
+ * @getsynctime:  Reads the current time from the hardware clock and
+ *                system clock simultaneously.
+ *                parameter dev: Holds the device time
+ *                parameter sys: Holds the system time
+ *
  * @settime64:  Set the current time on the hardware clock.
  *              parameter ts: Time value to set.
  *
@@ -105,6 +110,7 @@ struct ptp_clock_info {
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
+	int (*getsynctime)(struct ptp_clock_info *ptp, u64 *dev, u64 *sys);
 	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
 	int (*enable)(struct ptp_clock_info *ptp,
 		      struct ptp_clock_request *request, int on);
diff --git a/include/uapi/linux/ptp_clock.h b/include/uapi/linux/ptp_clock.h
index f0b7bfe..9412aaa 100644
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
@@ -81,6 +83,12 @@ struct ptp_sys_offset {
 	struct ptp_clock_time ts[2 * PTP_MAX_SAMPLES + 1];
 };
 
+struct ptp_sys_offset_precise {
+	unsigned int rsv[4];    /* Reserved for future use. */
+	struct ptp_clock_time dev;
+	struct ptp_clock_time sys;
+};
+
 enum ptp_pin_function {
 	PTP_PF_NONE,
 	PTP_PF_EXTTS,
@@ -124,6 +132,8 @@ struct ptp_pin_desc {
 #define PTP_SYS_OFFSET     _IOW(PTP_CLK_MAGIC, 5, struct ptp_sys_offset)
 #define PTP_PIN_GETFUNC    _IOWR(PTP_CLK_MAGIC, 6, struct ptp_pin_desc)
 #define PTP_PIN_SETFUNC    _IOW(PTP_CLK_MAGIC, 7, struct ptp_pin_desc)
+#define PTP_SYS_OFFSET_PRECISE \
+	_IOWR(PTP_CLK_MAGIC, 8, struct ptp_sys_offset_precise)
 
 struct ptp_extts_event {
 	struct ptp_clock_time t; /* Time event occured. */
-- 
2.1.4
