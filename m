From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 2/2] igb: offer a PTP Hardware
	Clock instead of the timecompare method
Date: Sat,  7 Jan 2012 20:38:21 +0100
Message-ID: <cf32731fdebd43472123eae1876c0f30205a0e03.1325964581.git.richardcochran@gmail.com>
References: <cover.1325964581.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1325964581.git.richardcochran@gmail.com>
In-Reply-To: <cover.1325964581.git.richardcochran@gmail.com>
References: <cover.1325964581.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This commit removes the legacy timecompare code from the igb driver and
offers a tunable PHC instead.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/Makefile   |    2 +-
 drivers/net/ethernet/intel/igb/igb.h      |   13 ++-
 drivers/net/ethernet/intel/igb/igb_main.c |  167 +----------------------------
 drivers/net/ethernet/intel/igb/igb_ptp.c  |   66 +++++++++++
 4 files changed, 77 insertions(+), 171 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index c6e4621..42f0868 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -32,6 +32,6 @@
 
 obj-$(CONFIG_IGB) += igb.o
 
-igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
+igb-objs := igb_main.o igb_ethtool.o igb_ptp.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o
 
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index f30458d..d554d83 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -34,8 +34,6 @@
 #include "e1000_mac.h"
 #include "e1000_82575.h"
 
-#include <linux/clocksource.h>
-#include <linux/timecompare.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
 #include <linux/bitops.h>
@@ -329,9 +327,6 @@ struct igb_adapter {
 
 	/* OS defined structs */
 	struct pci_dev *pdev;
-	struct cyclecounter cycles;
-	struct timecounter clock;
-	struct timecompare compare;
 	struct hwtstamp_config hwtstamp_config;
 
 	spinlock_t stats64_lock;
@@ -386,7 +381,6 @@ struct igb_adapter {
 #define IGB_DMCTLX_DCFLUSH_DIS     0x80000000  /* Disable DMA Coal Flush */
 
 #define IGB_82576_TSYNC_SHIFT 19
-#define IGB_82580_TSYNC_SHIFT 24
 #define IGB_TS_HDR_LEN        16
 enum e1000_state_t {
 	__IGB_TESTING,
@@ -423,6 +417,13 @@ extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
 extern void igb_power_up_link(struct igb_adapter *);
 
+extern void igb_ptp_init(struct igb_adapter *adapter);
+extern void igb_ptp_remove(struct igb_adapter *adapter);
+
+extern void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
+				   struct skb_shared_hwtstamps *hwtstamps,
+				   u64 systim);
+
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.reset)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 89d576c..0ee04b9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -113,7 +113,6 @@ static void igb_free_all_rx_resources(struct igb_adapter *);
 static void igb_setup_mrqc(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
-static void igb_init_hw_timer(struct igb_adapter *adapter);
 static int igb_sw_init(struct igb_adapter *);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
@@ -549,33 +548,6 @@ exit:
 	return;
 }
 
-
-/**
- * igb_read_clock - read raw cycle counter (to be used by time counter)
- */
-static cycle_t igb_read_clock(const struct cyclecounter *tc)
-{
-	struct igb_adapter *adapter =
-		container_of(tc, struct igb_adapter, cycles);
-	struct e1000_hw *hw = &adapter->hw;
-	u64 stamp = 0;
-	int shift = 0;
-
-	/*
-	 * The timestamp latches on lowest register read. For the 82580
-	 * the lowest register is SYSTIMR instead of SYSTIML.  However we never
-	 * adjusted TIMINCA so SYSTIMR will just read as all 0s so ignore it.
-	 */
-	if (hw->mac.type >= e1000_82580) {
-		stamp = rd32(E1000_SYSTIMR) >> 8;
-		shift = IGB_82580_TSYNC_SHIFT;
-	}
-
-	stamp |= (u64)rd32(E1000_SYSTIML) << shift;
-	stamp |= (u64)rd32(E1000_SYSTIMH) << (shift + 32);
-	return stamp;
-}
-
 /**
  * igb_get_hw_dev - return device
  * used by hardware layer to print debugging information
@@ -2080,7 +2052,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 #endif
 	/* do hw tstamp init after resetting */
-	igb_init_hw_timer(adapter);
+	igb_ptp_init(adapter);
 
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
@@ -2150,6 +2122,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	igb_ptp_remove(adapter);
+
 	/*
 	 * The watchdog timer may be rescheduled, so explicitly
 	 * disable watchdog from being rescheduled.
@@ -2269,112 +2243,6 @@ out:
 }
 
 /**
- * igb_init_hw_timer - Initialize hardware timer used with IEEE 1588 timestamp
- * @adapter: board private structure to initialize
- *
- * igb_init_hw_timer initializes the function pointer and values for the hw
- * timer found in hardware.
- **/
-static void igb_init_hw_timer(struct igb_adapter *adapter)
-{
-	struct e1000_hw *hw = &adapter->hw;
-
-	switch (hw->mac.type) {
-	case e1000_i350:
-	case e1000_82580:
-		memset(&adapter->cycles, 0, sizeof(adapter->cycles));
-		adapter->cycles.read = igb_read_clock;
-		adapter->cycles.mask = CLOCKSOURCE_MASK(64);
-		adapter->cycles.mult = 1;
-		/*
-		 * The 82580 timesync updates the system timer every 8ns by 8ns
-		 * and the value cannot be shifted.  Instead we need to shift
-		 * the registers to generate a 64bit timer value.  As a result
-		 * SYSTIMR/L/H, TXSTMPL/H, RXSTMPL/H all have to be shifted by
-		 * 24 in order to generate a larger value for synchronization.
-		 */
-		adapter->cycles.shift = IGB_82580_TSYNC_SHIFT;
-		/* disable system timer temporarily by setting bit 31 */
-		wr32(E1000_TSAUXC, 0x80000000);
-		wrfl();
-
-		/* Set registers so that rollover occurs soon to test this. */
-		wr32(E1000_SYSTIMR, 0x00000000);
-		wr32(E1000_SYSTIML, 0x80000000);
-		wr32(E1000_SYSTIMH, 0x000000FF);
-		wrfl();
-
-		/* enable system timer by clearing bit 31 */
-		wr32(E1000_TSAUXC, 0x0);
-		wrfl();
-
-		timecounter_init(&adapter->clock,
-				 &adapter->cycles,
-				 ktime_to_ns(ktime_get_real()));
-		/*
-		 * Synchronize our NIC clock against system wall clock. NIC
-		 * time stamp reading requires ~3us per sample, each sample
-		 * was pretty stable even under load => only require 10
-		 * samples for each offset comparison.
-		 */
-		memset(&adapter->compare, 0, sizeof(adapter->compare));
-		adapter->compare.source = &adapter->clock;
-		adapter->compare.target = ktime_get_real;
-		adapter->compare.num_samples = 10;
-		timecompare_update(&adapter->compare, 0);
-		break;
-	case e1000_82576:
-		/*
-		 * Initialize hardware timer: we keep it running just in case
-		 * that some program needs it later on.
-		 */
-		memset(&adapter->cycles, 0, sizeof(adapter->cycles));
-		adapter->cycles.read = igb_read_clock;
-		adapter->cycles.mask = CLOCKSOURCE_MASK(64);
-		adapter->cycles.mult = 1;
-		/**
-		 * Scale the NIC clock cycle by a large factor so that
-		 * relatively small clock corrections can be added or
-		 * subtracted at each clock tick. The drawbacks of a large
-		 * factor are a) that the clock register overflows more quickly
-		 * (not such a big deal) and b) that the increment per tick has
-		 * to fit into 24 bits.  As a result we need to use a shift of
-		 * 19 so we can fit a value of 16 into the TIMINCA register.
-		 */
-		adapter->cycles.shift = IGB_82576_TSYNC_SHIFT;
-		wr32(E1000_TIMINCA,
-		                (1 << E1000_TIMINCA_16NS_SHIFT) |
-		                (16 << IGB_82576_TSYNC_SHIFT));
-
-		/* Set registers so that rollover occurs soon to test this. */
-		wr32(E1000_SYSTIML, 0x00000000);
-		wr32(E1000_SYSTIMH, 0xFF800000);
-		wrfl();
-
-		timecounter_init(&adapter->clock,
-				 &adapter->cycles,
-				 ktime_to_ns(ktime_get_real()));
-		/*
-		 * Synchronize our NIC clock against system wall clock. NIC
-		 * time stamp reading requires ~3us per sample, each sample
-		 * was pretty stable even under load => only require 10
-		 * samples for each offset comparison.
-		 */
-		memset(&adapter->compare, 0, sizeof(adapter->compare));
-		adapter->compare.source = &adapter->clock;
-		adapter->compare.target = ktime_get_real;
-		adapter->compare.num_samples = 10;
-		timecompare_update(&adapter->compare, 0);
-		break;
-	case e1000_82575:
-		/* 82575 does not support timesync */
-	default:
-		break;
-	}
-
-}
-
-/**
  * igb_sw_init - Initialize general software structures (struct igb_adapter)
  * @adapter: board private structure to initialize
  *
@@ -5628,35 +5496,6 @@ static int igb_poll(struct napi_struct *napi, int budget)
 }
 
 /**
- * igb_systim_to_hwtstamp - convert system time value to hw timestamp
- * @adapter: board private structure
- * @shhwtstamps: timestamp structure to update
- * @regval: unsigned 64bit system time value.
- *
- * We need to convert the system time value stored in the RX/TXSTMP registers
- * into a hwtstamp which can be used by the upper level timestamping functions
- */
-static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
-                                   struct skb_shared_hwtstamps *shhwtstamps,
-                                   u64 regval)
-{
-	u64 ns;
-
-	/*
-	 * The 82580 starts with 1ns at bit 0 in RX/TXSTMPL, shift this up to
-	 * 24 to match clock shift we setup earlier.
-	 */
-	if (adapter->hw.mac.type >= e1000_82580)
-		regval <<= IGB_82580_TSYNC_SHIFT;
-
-	ns = timecounter_cyc2time(&adapter->clock, regval);
-	timecompare_update(&adapter->compare, ns);
-	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
-	shhwtstamps->hwtstamp = ns_to_ktime(ns);
-	shhwtstamps->syststamp = timecompare_transform(&adapter->compare, ns);
-}
-
-/**
  * igb_tx_hwtstamp - utility function which checks for TX time stamp
  * @q_vector: pointer to q_vector containing needed info
  * @buffer: pointer to igb_tx_buffer structure
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index dd27be1..69a1f21 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -26,6 +26,9 @@
 #define ISGN			0x80000000
 
 /*
+ * The 82580 timesync updates the system timer every 8ns by 8ns,
+ * and this update value cannot be reprogrammed.
+ *
  * Neither the 82576 nor the 82580 offer registers wide enough to hold
  * nanoseconds time values for very long. For the 82580, SYSTIM always
  * counts nanoseconds, but the upper 24 bits are not availible. The
@@ -37,6 +40,14 @@
  * field are needed to provide the nominal 16 nanosecond period,
  * leaving 19 bits for fractional nanoseconds.
  *
+ * We scale the NIC clock cycle by a large factor so that relatively
+ * small clock corrections can be added or subtracted at each clock
+ * tick. The drawbacks of a large factor are a) that the clock
+ * register overflows more quickly (not such a big deal) and b) that
+ * the increment per tick has to fit into 24 bits.  As a result we
+ * need to use a shift of 19 so we can fit a value of 16 into the
+ * TIMINCA register.
+ *
  *
  *             SYSTIMH            SYSTIML
  *        +--------------+   +---+---+------+
@@ -153,6 +164,11 @@ static u64 igb_82580_systim_read(struct igb_adapter *igb)
 	u32 lo, hi, jk;
 	struct e1000_hw *hw = &igb->hw;
 
+	/*
+	 * The timestamp latches on lowest register read. For the 82580
+	 * the lowest register is SYSTIMR instead of SYSTIML.  However we only
+	 * need to provide nanosecond resolution, so we just ignore it.
+	 */
 	jk = rd32(E1000_SYSTIMR);
 	lo = rd32(E1000_SYSTIML);
 	hi = rd32(E1000_SYSTIMH);
@@ -425,3 +441,53 @@ void igb_ptp_remove(struct igb_adapter *adapter)
 
 #endif /*CONFIG_PTP_1588_CLOCK*/
 }
+
+/**
+ * igb_systim_to_hwtstamp - convert system time value to hw timestamp
+ * @adapter: board private structure
+ * @hwtstamps: timestamp structure to update
+ * @systim: unsigned 64bit system time value.
+ *
+ * We need to convert the system time value stored in the RX/TXSTMP registers
+ * into a hwtstamp which can be used by the upper level timestamping functions.
+ *
+ * The 'tmreg_lock' spinlock is used to protect the consistency of the
+ * system time value. This is needed because reading the 64 bit time
+ * value involves reading two (or three) 32 bit registers. The first
+ * read latches the value. Ditto for writing.
+ *
+ * In addition, here have extended the system time with an overflow
+ * counter in software. We have to watch the most significant bit for
+ * one-to-zero transition, in order to keep count of the overflow.
+ */
+void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
+			    struct skb_shared_hwtstamps *hwtstamps,
+			    u64 systim)
+{
+	u64 ns;
+	unsigned long flags;
+	unsigned int shift;
+
+	switch (adapter->hw.mac.type) {
+	case e1000_i350:
+	case e1000_82580:
+		ns = systim;
+		shift = OFL_SHIFT_82580;
+		break;
+	case e1000_82576:
+		ns = systim >> NS_SHIFT_82576;
+		shift = OFL_SHIFT_82576;
+		break;
+	default:
+		return;
+	}
+
+	spin_lock_irqsave(&adapter->tmreg_lock, flags);
+
+	ns = igb_overflow_get(adapter, ns, shift);
+
+	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+
+	memset(hwtstamps, 0, sizeof(*hwtstamps));
+	hwtstamps->hwtstamp = ns_to_ktime(ns);
+}
-- 
1.7.2.5


------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
