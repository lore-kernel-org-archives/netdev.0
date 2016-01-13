From: "Christopher S. Hall" <christopher.s.hall@intel.com>
Subject: [PATCH v6 9/9] Adds hardware supported cross timestamp
Date: Wed, 13 Jan 2016 04:12:29 -0800
Message-ID: <1452687149-11281-10-git-send-email-christopher.s.hall@intel.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com
To: tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Modern Intel systems supports cross timestamping of the network device
clock and Always Running Timer (ART) in hardware.  This allows the
device time and system time to be precisely correlated. The timestamp
pair is returned through e1000e_phc_get_syncdevicetime() used by
get_system_device_crosststamp().  The hardware cross-timestamp result
is made available to applications through the PTP_SYS_OFFSET_PRECISE
ioctl which calls e1000e_phc_getcrosststamp().

Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
---
 drivers/net/ethernet/intel/Kconfig          |  9 +++
 drivers/net/ethernet/intel/e1000e/defines.h |  5 ++
 drivers/net/ethernet/intel/e1000e/ptp.c     | 88 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/regs.h    |  4 ++
 4 files changed, 106 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 4163b16..62bbddc 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -83,6 +83,15 @@ config E1000E
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
+config E1000E_HWTS
+	bool "Support HW cross-timestamp on PCH devices"
+	default y
+	depends on E1000E && X86
+	---help---
+	 Say Y to enable hardware supported cross-timestamping on PCH
+	 devices. The cross-timestamp is available through the PTP clock
+	 driver precise cross-timestamp ioctl (PTP_SYS_OFFSET_PRECISE).
+
 config IGB
 	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
 	depends on PCI
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
index 25a0ad5..84a53f7 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -26,6 +26,11 @@
 
 #include "e1000.h"
 
+#ifdef CONFIG_E1000E_HWTS
+#include <asm/tsc.h>
+#include <linux/ktime.h>
+#endif
+
 /**
  * e1000e_phc_adjfreq - adjust the frequency of the hardware clock
  * @ptp: ptp clock structure
@@ -98,6 +103,82 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
+#ifdef CONFIG_E1000E_HWTS
+#define MAX_HW_WAIT_COUNT (3)
+
+/**
+ * e1000e_phc_get_syncdevicetime - Callback given to timekeeping code reads system/device registers
+ * @device: current device time
+ * @system: system counter value read synchronously with device time
+ * @ctx: context provided by timekeeping code
+ *
+ * Read device and system (ART) clock simultaneously and return the corrected
+ * clock values in ns.
+ **/
+static int e1000e_phc_get_syncdevicetime(ktime_t *device,
+					 struct system_counterval_t *system,
+					 void *ctx)
+{
+	struct e1000_adapter *adapter = (struct e1000_adapter *)ctx;
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned long flags;
+	int i;
+	u32 tsync_ctrl;
+	cycle_t dev_cycles;
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
+	if (i == MAX_HW_WAIT_COUNT)
+		return -ETIMEDOUT;
+
+	dev_cycles = er32(SYSSTMPH);
+	dev_cycles <<= 32;
+	dev_cycles |= er32(SYSSTMPL);
+	spin_lock_irqsave(&adapter->systim_lock, flags);
+	*device = ns_to_ktime(timecounter_cyc2time(&adapter->tc, dev_cycles));
+	spin_unlock_irqrestore(&adapter->systim_lock, flags);
+
+	system->cycles = er32(PLTSTMPH);
+	system->cycles <<= 32;
+	system->cycles |= er32(PLTSTMPL);
+	system->cs = art_timestamper.related_cs;
+	system->cycles = art_timestamper.convert(&art_timestamper,
+						 system->cycles);
+	return 0;
+}
+
+/**
+ * e1000e_phc_getsynctime - Reads the current system/device cross timestamp
+ * @ptp: ptp clock structure
+ * @cts: structure containing timestamp
+ *
+ * Read device and system (ART) clock simultaneously and return the scaled
+ * clock values in ns.
+ **/
+static int e1000e_phc_getcrosststamp(struct ptp_clock_info *ptp,
+				     struct system_device_crosststamp *xtstamp)
+{
+	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
+						     ptp_clock_info);
+	struct sync_device_time_cb sync_devicetime;
+	int ret;
+
+	sync_devicetime.get_time = e1000e_phc_get_syncdevicetime;
+	sync_devicetime.ctx = adapter;
+	ret = get_device_system_crosststamp(&sync_devicetime, NULL, xtstamp);
+	return ret;
+}
+#endif/*CONFIG_E1000E_HWTS*/
+
 /**
  * e1000e_phc_gettime - Reads the current time from the hardware clock
  * @ptp: ptp clock structure
@@ -236,6 +317,13 @@ void e1000e_ptp_init(struct e1000_adapter *adapter)
 		break;
 	}
 
+#ifdef CONFIG_E1000E_HWTS
+	/* CPU must have ART and GBe must be from Sunrise Point or greater */
+	if (hw->mac.type >= e1000_pch_spt && boot_cpu_has(X86_FEATURE_ART))
+		adapter->ptp_clock_info.getcrosststamp =
+			e1000e_phc_getcrosststamp;
+#endif/*CONFIG_E1000E_HWTS*/
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
