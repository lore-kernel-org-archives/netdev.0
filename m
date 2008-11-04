From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 10/13] igb: infrastructure for hardware time stamping
Date: Tue, 4 Nov 2008 10:27:59 +0100
Message-ID: <1226415443.31699.9.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27675 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756209AbYKKO5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:24 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds register definitions and a clocksource accessing the
NIC time.

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 drivers/net/igb/e1000_regs.h |   28 +++++++++++
 drivers/net/igb/igb.h        |    3 +
 drivers/net/igb/igb_main.c   |  105 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 136 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 95523af..37f9d55 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -75,6 +75,34 @@
 #define E1000_FCRTH    0x02168  /* Flow Control Receive Threshold High - RW */
 #define E1000_RDFPCQ(_n)  (0x02430 + (0x4 * (_n)))
 #define E1000_FCRTV    0x02460  /* Flow Control Refresh Timer Value - RW */
+
+/* IEEE 1588 TIMESYNCH */
+#define E1000_TSYNCTXCTL 0x0B614
+#define E1000_TSYNCRXCTL 0x0B620
+#define E1000_TSYNCRXCFG 0x05F50
+
+#define E1000_SYSTIML 0x0B600
+#define E1000_SYSTIMH 0x0B604
+#define E1000_TIMINCA 0x0B608
+
+#define E1000_RXMTRL     0x0B634
+#define E1000_RXSTMPL 0x0B624
+#define E1000_RXSTMPH 0x0B628
+#define E1000_RXSATRL 0x0B62C
+#define E1000_RXSATRH 0x0B630
+
+#define E1000_TXSTMPL 0x0B618
+#define E1000_TXSTMPH 0x0B61C
+
+#define E1000_ETQF0   0x05CB0
+#define E1000_ETQF1   0x05CB4
+#define E1000_ETQF2   0x05CB8
+#define E1000_ETQF3   0x05CBC
+#define E1000_ETQF4   0x05CC0
+#define E1000_ETQF5   0x05CC4
+#define E1000_ETQF6   0x05CC8
+#define E1000_ETQF7   0x05CCC
+
 /* Split and Replication RX Control - RW */
 /*
  * Convenience macros
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 4ff6f05..2938ab3 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -34,6 +34,8 @@
 #include "e1000_mac.h"
 #include "e1000_82575.h"
 
+#include <linux/clocksource.h>
+
 struct igb_adapter;
 
 #ifdef CONFIG_IGB_LRO
@@ -262,6 +264,7 @@ struct igb_adapter {
 	struct napi_struct napi;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
+	struct clocksource clock;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index becf8d6..3a4772e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -179,6 +179,54 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+/**
+ * Scale the NIC clock cycle by a large factor so that
+ * relatively small clock corrections can be added or
+ * substracted at each clock tick. The drawbacks of a
+ * large factor are a) that the clock register overflows
+ * more quickly (not such a big deal) and b) that the
+ * increment per tick has to fit into 24 bits.
+ *
+ * Note that
+ *   TIMINCA = IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS *
+ *             IGB_TSYNC_SCALE
+ *   TIMINCA += TIMINCA * adjustment [ppm] / 1e9
+ *
+ * The base scale factor is intentionally a power of two
+ * so that the division in clocksource can be done with
+ * a shift.
+ */
+#define IGB_TSYNC_SHIFT (19)
+#define IGB_TSYNC_SCALE (1<<IGB_TSYNC_SHIFT)
+
+/**
+ * The duration of one clock cycle of the NIC.
+ *
+ * @todo This hard-coded value is part of the specification and might change
+ * in future hardware revisions. Add revision check.
+ */
+#define IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS 16
+
+#if (IGB_TSYNC_SCALE * IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS) >= (1<<24)
+# error IGB_TSYNC_SCALE and/or IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS are too large to fit into TIMINCA
+#endif
+
+/**
+ * igb_read_clock - read raw cycle counter (to be used by clocksource)
+ */
+static cycle_t igb_read_clock(struct clocksource *cs)
+{
+	struct igb_adapter *adapter =
+		container_of(cs, struct igb_adapter, clock);
+	struct e1000_hw *hw = &adapter->hw;
+	u64 stamp;
+
+	stamp =  rd32(E1000_SYSTIML);
+	stamp |= (u64)rd32(E1000_SYSTIMH) << 32ULL;
+
+	return stamp;
+}
+
 #ifdef DEBUG
 /**
  * igb_get_hw_dev_name - return device name string
@@ -189,6 +237,27 @@ char *igb_get_hw_dev_name(struct e1000_hw *hw)
 	struct igb_adapter *adapter = hw->back;
 	return adapter->netdev->name;
 }
+
+/**
+ * igb_get_time_str - format current NIC and system time as string
+ */
+static char *igb_get_time_str(struct igb_adapter *adapter,
+			char buffer[160])
+{
+	struct timespec nic = ns_to_timespec(clocksource_read_time(&adapter->clock));
+	struct timespec sys;
+	struct timespec delta;
+	getnstimeofday(&sys);
+
+	delta = timespec_sub(nic, sys);
+
+	sprintf(buffer, "NIC %ld.%09lus, SYS %ld.%09lus, NIC-SYS %lds + %09luns",
+		(long)nic.tv_sec, nic.tv_nsec,
+		(long)sys.tv_sec, sys.tv_nsec,
+		(long)delta.tv_sec, delta.tv_nsec);
+
+	return buffer;
+}
 #endif
 
 /**
@@ -1250,6 +1319,42 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 #endif
 
+	/*
+	 * Initialize hardware timer: we keep it running just in case
+	 * that some program needs it later on.
+	 */
+	memset(&adapter->clock, 0, sizeof(adapter->clock));
+	adapter->clock.read_clock = igb_read_clock;
+	adapter->clock.mask = (u64)(s64)-1;
+	adapter->clock.mult = 1;
+	adapter->clock.shift = IGB_TSYNC_SHIFT;
+	wr32(E1000_TIMINCA, (1<<24) | IGB_TSYNC_CYCLE_TIME_IN_NANOSECONDS * IGB_TSYNC_SCALE);
+#if 0
+	/*
+	 * Avoid rollover while we initialize by resetting the time counter.
+	 */
+	wr32(E1000_SYSTIML, 0x00000000);
+	wr32(E1000_SYSTIMH, 0x00000000);
+#else
+	/*
+	 * Set registers so that rollover occurs soon to test this.
+	 */
+	wr32(E1000_SYSTIML, 0x00000000);
+	wr32(E1000_SYSTIMH, 0xFF800000);
+#endif
+	wrfl();
+	clocksource_init_time(&adapter->clock, ktime_to_ns(ktime_get_real()));
+
+#ifdef DEBUG
+	{
+		char buffer[160];
+		printk(KERN_DEBUG
+			"igb: %s: hw %p initialized timer\n",
+			igb_get_time_str(adapter, buffer),
+			&adapter->hw);
+	}
+#endif
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev,
-- 
1.6.0.4


