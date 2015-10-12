From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v4 4/4] Adds hardware supported cross timestamp
Date: Mon, 12 Oct 2015 11:45:22 -0700
Message-ID: <1444675522-4198-5-git-send-email-christopher.s.hall@intel.com>
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

Modern Intel systems supports cross timestamping of the network device
clock and Always Running Timer (ART) in hardware.  This allows the device
time and system time to be precisely correlated. The timestamp pair is
exposed through the *_get_ts callback used by get_correlated_timestamp().
The hardware cross-timestamp result is made available to applications
through the PTP_SYS_OFFSET_PRECISE ioctl.

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  5 ++
 drivers/net/ethernet/intel/e1000e/ptp.c     | 77 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |  4 ++
 3 files changed, 86 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 133d407..13cff75 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -527,6 +527,11 @@
 #define E1000_RXCW_C          0x20000000        /* Receive config */
 #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
 
+/* HH Time Sync */
+#define E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK	0x0000F000 /* max delay */
+#define E1000_TSYNCTXCTL_SYNC_COMP		0x40000000 /* sync complete */
+#define E1000_TSYNCTXCTL_START_SYNC		0x80000000 /* initiate sync */
+
 #define E1000_TSYNCTXCTL_VALID		0x00000001 /* Tx timestamp valid */
 #define E1000_TSYNCTXCTL_ENABLED	0x00000010 /* enable Tx timestamping */
 
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 25a0ad5..25e2641 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -25,6 +25,8 @@
  */
 
 #include "e1000.h"
+#include <asm/tsc.h>
+#include <linux/timekeeping.h>
 
 /**
  * e1000e_phc_adjfreq - adjust the frequency of the hardware clock
@@ -98,6 +100,77 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
+#define MAX_HW_WAIT_COUNT (3)
+
+static int e1000e_phc_get_ts(struct correlated_ts *cts)
+{
+	struct e1000_adapter *adapter = (struct e1000_adapter *)cts->private;
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+	u32 tsync_ctrl;
+	int ret;
+
+	tsync_ctrl = er32(TSYNCTXCTL);
+	tsync_ctrl |= E1000_TSYNCTXCTL_START_SYNC |
+		E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK;
+	ew32(TSYNCTXCTL, tsync_ctrl);
+	for (i = 0; i < MAX_HW_WAIT_COUNT; ++i) {
+		udelay(1);
+		tsync_ctrl = er32(TSYNCTXCTL);
+		if (tsync_ctrl & E1000_TSYNCTXCTL_SYNC_COMP)
+			break;
+	}
+
+	if (i == MAX_HW_WAIT_COUNT) {
+		ret = -ETIMEDOUT;
+	} else {
+		ret = 0;
+		cts->system_ts = er32(PLTSTMPH);
+		cts->system_ts <<= 32;
+		cts->system_ts |= er32(PLTSTMPL);
+		cts->device_ts = er32(SYSSTMPH);
+		cts->device_ts <<= 32;
+		cts->device_ts |= er32(SYSSTMPL);
+	}
+
+	return ret;
+}
+
+/**
+ * e1000e_phc_getsynctime - Reads the current time from the hardware clock and
+ * correlated system time
+ * @ptp: ptp clock structure
+ * @devts: timespec structure to hold the current device time value
+ * @systs: timespec structure to hold the current system time value
+ *
+ * Read device and system (ART) clock simultaneously and return the correct
+ * clock values in ns after converting into a struct timespec.
+ **/
+static int e1000e_phc_getsynctime(struct ptp_clock_info *ptp, u64 *dev,
+				  u64 *sys )
+{
+	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
+						     ptp_clock_info);
+	unsigned long flags;
+	struct correlated_ts art_correlated_ts;
+	int ret;
+
+	art_correlated_ts.get_ts = e1000e_phc_get_ts;
+	art_correlated_ts.private = adapter;
+	ret = get_correlated_timestamp(&art_correlated_ts,
+				       &art_timestamper);
+	if (ret != 0)
+		return ret;
+
+	*sys = art_correlated_ts.system_real.tv64;
+
+	spin_lock_irqsave(&adapter->systim_lock, flags);
+	*dev = timecounter_cyc2time(&adapter->tc, art_correlated_ts.device_ts);
+	spin_unlock_irqrestore(&adapter->systim_lock, flags);
+
+	return 0;
+}
+
 /**
  * e1000e_phc_gettime - Reads the current time from the hardware clock
  * @ptp: ptp clock structure
@@ -236,6 +309,10 @@ void e1000e_ptp_init(struct e1000_adapter *adapter)
 		break;
 	}
 
+	/* CPU must have ART and GBe must be from Sunrise Point or greater */
+	if (hw->mac.type >= e1000_pch_spt && boot_cpu_has(X86_FEATURE_ART))
+		adapter->ptp_clock_info.getsynctime = e1000e_phc_getsynctime;
+
 	INIT_DELAYED_WORK(&adapter->systim_overflow_work,
 			  e1000e_systim_overflow_work);
 
diff --git a/drivers/net/ethernet/intel/e1000e/regs.h b/drivers/net/ethernet/intel/e1000e/regs.h
index 1d5e0b7..0cb4d36 100644
--- a/drivers/net/ethernet/intel/e1000e/regs.h
+++ b/drivers/net/ethernet/intel/e1000e/regs.h
@@ -245,6 +245,10 @@
 #define E1000_SYSTIML	0x0B600	/* System time register Low - RO */
 #define E1000_SYSTIMH	0x0B604	/* System time register High - RO */
 #define E1000_TIMINCA	0x0B608	/* Increment attributes register - RW */
+#define E1000_SYSSTMPL  0x0B648 /* HH Timesync system stamp low register */
+#define E1000_SYSSTMPH  0x0B64C /* HH Timesync system stamp hi register */
+#define E1000_PLTSTMPL  0x0B640 /* HH Timesync platform stamp low register */
+#define E1000_PLTSTMPH  0x0B644 /* HH Timesync platform stamp hi register */
 #define E1000_RXMTRL	0x0B634	/* Time sync Rx EtherType and Msg Type - RW */
 #define E1000_RXUDP	0x0B638	/* Time Sync Rx UDP Port - RW */
 
-- 
2.1.4
