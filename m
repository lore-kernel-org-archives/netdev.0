From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH NET-NEXT 10/12] igb: access to NIC time
Date: Wed, 21 Jan 2009 11:10:10 +0100
Message-ID: <1232532612-10382-10-git-send-email-patrick.ohly@intel.com>
References: <1232532457.7829.19.camel@ecld0pohly>
 <1232532612-10382-1-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-2-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-3-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-4-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-5-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-6-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-7-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-8-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-9-git-send-email-patrick.ohly@intel.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1232532612-10382-9-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adds the register definitions and code to read the time
register.
---
 drivers/net/igb/e1000_regs.h |   28 +++++++++++
 drivers/net/igb/igb.h        |    4 ++
 drivers/net/igb/igb_main.c   |  106 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 138 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index bdf5d83..d225601 100644
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
index 5a27825..2cf2c1a 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -34,6 +34,8 @@
 #include "e1000_mac.h"
 #include "e1000_82575.h"
 
+#include <linux/clocksource.h>
+
 struct igb_adapter;
 
 #ifdef CONFIG_IGB_LRO
@@ -262,6 +264,8 @@ struct igb_adapter {
 	struct napi_struct napi;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
+	struct cyclecounter cycles;
+	struct timecounter clock;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d26dacb..7ab6faf 100644
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
+ * so that the division in %struct timecounter can be done with
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
+ * igb_read_clock - read raw cycle counter (to be used by time counter)
+ */
+static cycle_t igb_read_clock(const struct cyclecounter *tc)
+{
+	struct igb_adapter *adapter =
+		container_of(tc, struct igb_adapter, cycles);
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
@@ -189,6 +237,28 @@ char *igb_get_hw_dev_name(struct e1000_hw *hw)
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
+	cycle_t hw = adapter->cycles.read(&adapter->cycles);
+	struct timespec nic = ns_to_timespec(timecounter_read(&adapter->clock));
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
@@ -1322,6 +1392,42 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 #endif
 
+	/*
+	 * Initialize hardware timer: we keep it running just in case
+	 * that some program needs it later on.
+	 */
+	memset(&adapter->cycles, 0, sizeof(adapter->cycles));
+	adapter->cycles.read = igb_read_clock;
+	adapter->cycles.mask = CLOCKSOURCE_MASK(64);
+	adapter->cycles.mult = 1;
+	adapter->cycles.shift = IGB_TSYNC_SHIFT;
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
+	timecounter_init(&adapter->clock, &adapter->cycles, ktime_to_ns(ktime_get_real()));
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
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
-- 
1.5.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
