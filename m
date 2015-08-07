From: Christopher Hall <christopher.s.hall@intel.com>
Subject: [PATCH v2 4/4] Added getsynctime64() callback
Date: Fri,  7 Aug 2015 16:01:35 -0700
Message-ID: <1438988495-9942-5-git-send-email-christopher.s.hall@intel.com>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christopher Hall <christopher.s.hall@intel.com>
To: john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7984 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946349AbbHGXAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 19:00:49 -0400
In-Reply-To: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reads ART (TSC correlated clocksource), converts to realtime clock, and
	reports	cross timestamp to PTP driver
---
 drivers/net/ethernet/intel/e1000e/defines.h |  7 +++
 drivers/net/ethernet/intel/e1000e/ptp.c     | 88 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |  4 ++
 3 files changed, 99 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 133d407..9f16269 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -527,6 +527,13 @@
 #define E1000_RXCW_C          0x20000000        /* Receive config */
 #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
 
+/* HH Time Sync */
+#define E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK   0x0000F000      /* max delay */
+#define E1000_TSYNCTXCTL_SYNC_COMP              0x40000000      /* sync complete
+ */
+#define E1000_TSYNCTXCTL_START_SYNC             0x80000000      /* initiate sync
+ */
+
 #define E1000_TSYNCTXCTL_VALID		0x00000001 /* Tx timestamp valid */
 #define E1000_TSYNCTXCTL_ENABLED	0x00000010 /* enable Tx timestamping */
 
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 25a0ad5..c3d80c4 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -25,6 +25,8 @@
  */
 
 #include "e1000.h"
+#include <asm/tsc.h>
+#include <linux/timekeeping.h>
 
 /**
  * e1000e_phc_adjfreq - adjust the frequency of the hardware clock
@@ -98,6 +100,91 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
+#define HW_WAIT_COUNT (2)
+#define HW_RETRY_COUNT (2)
+
+static int e1000e_phc_get_ts(struct correlated_ts *cts)
+{
+	struct e1000_adapter *adapter = (struct e1000_adapter *) cts->private;
+	struct e1000_hw *hw = &adapter->hw;
+	int i, j;
+	u32 tsync_ctrl;
+	int ret;
+
+	if (hw->mac.type < e1000_pch_spt)
+		return -EOPNOTSUPP;
+
+	for (j = 0; j < HW_RETRY_COUNT; ++j) {
+		tsync_ctrl = er32(TSYNCTXCTL);
+		tsync_ctrl |= E1000_TSYNCTXCTL_START_SYNC |
+			E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK;
+		ew32(TSYNCTXCTL, tsync_ctrl);
+		ret = 0;
+		for (i = 0; i < HW_WAIT_COUNT; ++i) {
+			udelay(2);
+			tsync_ctrl = er32(TSYNCTXCTL);
+			if (tsync_ctrl & E1000_TSYNCTXCTL_SYNC_COMP)
+				break;
+		}
+
+		if (i == HW_WAIT_COUNT) {
+			ret = -ETIMEDOUT;
+		} else if (ret == 0) {
+			cts->system_ts = er32(PLTSTMPH);
+			cts->system_ts <<= 32;
+			cts->system_ts |= er32(PLTSTMPL);
+			cts->device_ts = er32(SYSSTMPH);
+			cts->device_ts <<= 32;
+			cts->device_ts |= er32(SYSSTMPL);
+			break;
+		}
+	}
+
+	return ret;
+}
+
+#define SYNCTIME_RETRY_COUNT (2)
+
+static int e1000e_phc_getsynctime(struct ptp_clock_info *ptp,
+				  struct timespec64 *devts,
+				  struct timespec64 *systs)
+{
+	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
+						     ptp_clock_info);
+	unsigned long flags;
+	u32 remainder;
+	struct correlated_ts art_correlated_ts;
+	u64 device_time;
+	int i, ret;
+
+	if (!cpu_has_art)
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < SYNCTIME_RETRY_COUNT; ++i) {
+		art_correlated_ts.get_ts = e1000e_phc_get_ts;
+		art_correlated_ts.private = adapter;
+		ret = get_correlated_timestamp(&art_correlated_ts,
+					&art_timestamper);
+		if (ret != 0)
+			continue;
+
+		systs->tv_sec =
+			div_u64_rem(art_correlated_ts.system_real.tv64,
+				NSEC_PER_SEC, &remainder);
+		systs->tv_nsec = remainder;
+		spin_lock_irqsave(&adapter->systim_lock, flags);
+		device_time = timecounter_cyc2time(&adapter->tc,
+					art_correlated_ts.device_ts);
+		spin_unlock_irqrestore(&adapter->systim_lock, flags);
+		devts->tv_sec =
+			div_u64_rem(device_time, NSEC_PER_SEC, &remainder);
+		devts->tv_nsec = remainder;
+		break;
+	}
+
+	return ret;
+}
+
 /**
  * e1000e_phc_gettime - Reads the current time from the hardware clock
  * @ptp: ptp clock structure
@@ -190,6 +277,7 @@ static const struct ptp_clock_info e1000e_ptp_clock_info = {
 	.adjfreq	= e1000e_phc_adjfreq,
 	.adjtime	= e1000e_phc_adjtime,
 	.gettime64	= e1000e_phc_gettime,
+	.getsynctime64	= e1000e_phc_getsynctime,
 	.settime64	= e1000e_phc_settime,
 	.enable		= e1000e_phc_enable,
 };
diff --git a/drivers/net/ethernet/intel/e1000e/regs.h b/drivers/net/ethernet/intel/e1000e/regs.h
index b24e5fe..4dd5b54 100644
--- a/drivers/net/ethernet/intel/e1000e/regs.h
+++ b/drivers/net/ethernet/intel/e1000e/regs.h
@@ -246,6 +246,10 @@
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
1.9.1
