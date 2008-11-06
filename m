From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 12/13] igb: use clocksync to implement hardware time
	stamping
Date: Thu, 6 Nov 2008 12:13:30 +0100
Message-ID: <1226415452.31699.11.camel@ecld0pohly>
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
Received: from mga03.intel.com ([143.182.124.21]:28793 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756217AbYKKO5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:33 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only TX hardware time stamping is implemented.  Due to
hardware limitations it is not possible to verify reliably which
packet was time stamped when multiple were pending for sending; this
will be solved by only allowing one packet marked for hardware time
stamping into the queue (not implemented yet).

RX time stamping relies on the flag in the packet descriptor which
marks packets that were time stamped. In "all packet" mode this flag
is not set. TODO: also support that mode (even though it'll suffer
from race conditions).

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 drivers/net/igb/e1000_82575.h   |    1 +
 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/e1000_regs.h    |   40 +++++++
 drivers/net/igb/igb.h           |    2 +
 drivers/net/igb/igb_main.c      |  239 +++++++++++++++++++++++++++++++++++++--
 5 files changed, 275 insertions(+), 8 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index c1928b5..dd32a6f 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -116,6 +116,7 @@ union e1000_adv_tx_desc {
 };
 
 /* Adv Transmit Descriptor Config Masks */
+#define E1000_ADVTXD_MAC_TSTAMP   0x00080000 /* IEEE1588 Timestamp packet */
 #define E1000_ADVTXD_DTYP_CTXT    0x00200000 /* Advanced Context Descriptor */
 #define E1000_ADVTXD_DTYP_DATA    0x00300000 /* Advanced Data Descriptor */
 #define E1000_ADVTXD_DCMD_IFCS    0x02000000 /* Insert FCS (Ethernet CRC) */
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index ce70068..2a19698 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -104,6 +104,7 @@
 #define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
 #define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
 #define E1000_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
+#define E1000_RXD_STAT_TS       0x10000 /* Pkt was time stamped */
 #define E1000_RXD_ERR_CE        0x01    /* CRC Error */
 #define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
 #define E1000_RXD_ERR_SEQ       0x04    /* Sequence Error */
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 37f9d55..7b561a1 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -78,9 +78,37 @@
 
 /* IEEE 1588 TIMESYNCH */
 #define E1000_TSYNCTXCTL 0x0B614
+#define E1000_TSYNCTXCTL_VALID (1<<0)
+#define E1000_TSYNCTXCTL_ENABLED (1<<4)
 #define E1000_TSYNCRXCTL 0x0B620
+#define E1000_TSYNCRXCTL_VALID (1<<0)
+#define E1000_TSYNCRXCTL_ENABLED (1<<4)
+enum {
+	E1000_TSYNCRXCTL_TYPE_L2_V2 = 0,
+	E1000_TSYNCRXCTL_TYPE_L4_V1 = (1<<1),
+	E1000_TSYNCRXCTL_TYPE_L2_L4_V2 = (1<<2),
+	E1000_TSYNCRXCTL_TYPE_ALL = (1<<3),
+	E1000_TSYNCRXCTL_TYPE_EVENT_V2 = (1<<3) | (1<<1),
+};
 #define E1000_TSYNCRXCFG 0x05F50
+enum {
+	E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE = 0<<0,
+	E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE = 1<<0,
+	E1000_TSYNCRXCFG_PTP_V1_FOLLOWUP_MESSAGE = 2<<0,
+	E1000_TSYNCRXCFG_PTP_V1_DELAY_RESP_MESSAGE = 3<<0,
+	E1000_TSYNCRXCFG_PTP_V1_MANAGEMENT_MESSAGE = 4<<0,
 
+	E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE = 0<<8,
+	E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE = 1<<8,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_REQ_MESSAGE = 2<<8,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_RESP_MESSAGE = 3<<8,
+	E1000_TSYNCRXCFG_PTP_V2_FOLLOWUP_MESSAGE = 8<<8,
+	E1000_TSYNCRXCFG_PTP_V2_DELAY_RESP_MESSAGE = 9<<8,
+	E1000_TSYNCRXCFG_PTP_V2_PATH_DELAY_FOLLOWUP_MESSAGE = 0xA<<8,
+	E1000_TSYNCRXCFG_PTP_V2_ANNOUNCE_MESSAGE = 0xB<<8,
+	E1000_TSYNCRXCFG_PTP_V2_SIGNALLING_MESSAGE = 0xC<<8,
+	E1000_TSYNCRXCFG_PTP_V2_MANAGEMENT_MESSAGE = 0xD<<8,
+};
 #define E1000_SYSTIML 0x0B600
 #define E1000_SYSTIMH 0x0B604
 #define E1000_TIMINCA 0x0B608
@@ -103,6 +131,18 @@
 #define E1000_ETQF6   0x05CC8
 #define E1000_ETQF7   0x05CCC
 
+/* Filtering Registers */
+#define E1000_SAQF(_n) (0x5980 + 4 * (_n))
+#define E1000_DAQF(_n) (0x59A0 + 4 * (_n))
+#define E1000_SPQF(_n) (0x59C0 + 4 * (_n))
+#define E1000_FTQF(_n) (0x59E0 + 4 * (_n))
+#define E1000_SAQF0 E1000_SAQF(0)
+#define E1000_DAQF0 E1000_DAQF(0)
+#define E1000_SPQF0 E1000_SPQF(0)
+#define E1000_FTQF0 E1000_FTQF(0)
+#define E1000_SYNQF(_n) (0x055FC + (4 * (_n))) /* SYN Packet Queue Fltr */
+#define E1000_ETQF(_n)  (0x05CB0 + (4 * (_n))) /* EType Queue Fltr */
+
 /* Split and Replication RX Control - RW */
 /*
  * Convenience macros
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 2938ab3..86ef1a2 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -35,6 +35,7 @@
 #include "e1000_82575.h"
 
 #include <linux/clocksource.h>
+#include <linux/clocksync.h>
 
 struct igb_adapter;
 
@@ -265,6 +266,7 @@ struct igb_adapter {
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
 	struct clocksource clock;
+	struct clocksync sync;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3a4772e..b320fec 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -227,6 +227,13 @@ static cycle_t igb_read_clock(struct clocksource *cs)
 	return stamp;
 }
 
+static union ktime igb_hwtstamp_raw2sys(struct net_device *netdev,
+					union ktime stamp)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	return clocksync_hw2sys(&adapter->sync, ktime_to_ns(stamp));
+}
+
 #ifdef DEBUG
 /**
  * igb_get_hw_dev_name - return device name string
@@ -244,6 +251,7 @@ char *igb_get_hw_dev_name(struct e1000_hw *hw)
 static char *igb_get_time_str(struct igb_adapter *adapter,
 			char buffer[160])
 {
+	cycle_t hw = clocksource_read(&adapter->clock);
 	struct timespec nic = ns_to_timespec(clocksource_read_time(&adapter->clock));
 	struct timespec sys;
 	struct timespec delta;
@@ -251,7 +259,8 @@ static char *igb_get_time_str(struct igb_adapter *adapter,
 
 	delta = timespec_sub(nic, sys);
 
-	sprintf(buffer, "NIC %ld.%09lus, SYS %ld.%09lus, NIC-SYS %lds + %09luns",
+	sprintf(buffer, "HW %llu, NIC %ld.%09lus, SYS %ld.%09lus, NIC-SYS %lds + %09luns",
+		hw,
 		(long)nic.tv_sec, nic.tv_nsec,
 		(long)sys.tv_sec, sys.tv_nsec,
 		(long)delta.tv_sec, delta.tv_nsec);
@@ -1345,6 +1354,19 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	wrfl();
 	clocksource_init_time(&adapter->clock, ktime_to_ns(ktime_get_real()));
 
+	/*
+	 * Synchronize our NIC clock against system wall clock. NIC
+	 * time stamp reading requires ~3us per sample, each sample
+	 * was pretty stable even under load => only require 10
+	 * samples for each offset comparison.
+	 */
+	memset(&adapter->sync, 0, sizeof(adapter->sync));
+	adapter->sync.clock = &adapter->clock;
+	adapter->sync.systime = ktime_get_real;
+	adapter->sync.num_samples = 10;
+	clocksync_update(&adapter->sync, 0);
+	netdev->hwtstamp_raw2sys = igb_hwtstamp_raw2sys;
+
 #ifdef DEBUG
 	{
 		char buffer[160];
@@ -2716,6 +2738,7 @@ set_itr_now:
 #define IGB_TX_FLAGS_VLAN		0x00000002
 #define IGB_TX_FLAGS_TSO		0x00000004
 #define IGB_TX_FLAGS_IPV4		0x00000008
+#define IGB_TX_FLAGS_TSTAMP             0x00000010
 #define IGB_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IGB_TX_FLAGS_VLAN_SHIFT	16
 
@@ -2936,6 +2959,9 @@ static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
 		cmd_type_len |= E1000_ADVTXD_DCMD_VLE;
 
+	if (tx_flags & IGB_TX_FLAGS_TSTAMP)
+		cmd_type_len |= E1000_ADVTXD_MAC_TSTAMP;
+
 	if (tx_flags & IGB_TX_FLAGS_TSO) {
 		cmd_type_len |= E1000_ADVTXD_DCMD_TSE;
 
@@ -3048,7 +3074,27 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		/* this is a hard error */
 		return NETDEV_TX_BUSY;
 	}
-	skb_orphan(skb);
+
+	/*
+	 * TODO: check that there currently is no other packet with
+	 * time stamping in the queue
+	 *
+	 * when doing time stamping, keep the connection to the socket
+	 * a while longer, it is still needed by skb_hwtstamp_tx(), either
+	 * in igb_clean_tx_irq() or
+	 */
+	if (skb_hwtstamp_check_tx_hardware(skb)) {
+		skb_hwtstamp_tx_in_progress(skb);
+		tx_flags |= IGB_TX_FLAGS_TSTAMP;
+	} else if (!skb_hwtstamp_check_tx_software(skb)) {
+		/*
+		 * TODO: can this be solved in dev.c:dev_hard_start_xmit()?
+		 * There are probably unmodified driver which do something
+		 * like this and thus don't work in combination with
+		 * SOF_TIMESTAMPING_TX_SOFTWARE.
+		 */
+		skb_orphan(skb);
+	}
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
@@ -3746,6 +3792,28 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 					    skb->len;
 				total_packets += segs;
 				total_bytes += bytecount;
+
+				/*
+				 * if we were asked to do hardware
+				 * stamping and such a time stamp is
+				 * available, then it must have been
+				 * for this one here because we only
+				 * allow only one such packet into the
+				 * queue
+				 */
+				if (skb_hwtstamp_check_tx_hardware(skb)) {
+					u32 valid = rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID;
+					if (valid) {
+						u64 tstamp = rd32(E1000_TXSTMPL);
+						tstamp |= (u64)rd32(E1000_TXSTMPH) << 32;
+						clocksync_update(&adapter->sync, tstamp);
+						skb_hwtstamp_tx(skb,
+								ns_to_ktime(clocksource_cyc2time(&adapter->clock,
+													tstamp)),
+								netdev);
+					}
+					skb_orphan(skb);
+				}
 			}
 
 			igb_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -3929,6 +3997,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 {
 	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
 	struct igb_buffer *buffer_info , *next_buffer;
@@ -4018,6 +4087,38 @@ send_up:
 			goto next_desc;
 		}
 
+		/*
+		 * If this bit is set, then the RX registers contain
+		 * the time stamp. No other packet will be time
+		 * stamped until we read these registers, so read the
+		 * registers to make them available again. Because
+		 * only one packet can be time stamped at a time, we
+		 * know that the register values must belong to this
+		 * one here and therefore we don't need to compare
+		 * any of the additional attributes stored for it.
+		 *
+		 * TODO: can time stamping be triggered (thus locking
+		 * the registers) without the packet reaching this point
+		 * here? In that case RX time stamping would get stuck.
+		 *
+		 * TODO: in "time stamp all packets" mode this bit is
+		 * not set. Need a global flag for this mode and then
+		 * always read the registers. Cannot be done without
+		 * a race condition.
+		 */
+		if (staterr & E1000_RXD_STAT_TS) {
+			u64 tstamp;
+
+			WARN(!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID),
+				"igb: no RX time stamp available for time stamped packet");
+			tstamp = rd32(E1000_RXSTMPL);
+			tstamp |= (u64)rd32(E1000_RXSTMPH) << 32;
+			clocksync_update(&adapter->sync, tstamp);
+			skb_hwtstamp_set(skb,
+					ns_to_ktime(clocksource_cyc2time(&adapter->clock,
+										tstamp)));
+		}
+
 		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
@@ -4214,12 +4315,32 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
  * @ifreq:
  * @cmd:
  *
- * Currently cannot enable any kind of hardware time stamping, but
- * supports SIOCSHWTSTAMP in general.
+ * Outgoing time stamping can be enabled and disabled. Play nice and
+ * disable it when requested, although it shouldn't case any overhead
+ * when no packet needs it. At most one packet in the queue may be
+ * marked for time stamping, otherwise it would be impossible to tell
+ * for sure to which packet the hardware time stamp belongs.
+ *
+ * Incoming time stamping has to be configured via the hardware
+ * filters. Not all combinations are supported, in particular event
+ * type has to be specified. Matching the kind of event packet is
+ * not supported, with the exception of "all V2 events regardless of
+ * level 2 or 4".
+ *
  **/
 static int igb_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	struct hwtstamp_config config;
+	u32 tsync_tx_ctl_bit = E1000_TSYNCTXCTL_ENABLED;
+	u32 tsync_rx_ctl_bit = E1000_TSYNCRXCTL_ENABLED;
+	u32 tsync_rx_ctl_type = 0;
+	u32 tsync_rx_cfg = 0;
+	int is_l4 = 0;
+	int is_l2 = 0;
+	short port = 319; /* PTP */
+	u32 regval;
 
 	printk("igb_hwtstamp_ioctl\n");
 
@@ -4230,11 +4351,113 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int
 	if (config.flags)
 		return -EINVAL;
 
-	if (config.tx_type == HWTSTAMP_TX_OFF &&
-		config.rx_filter_type == HWTSTAMP_FILTER_NONE)
-		return 0;
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		tsync_tx_ctl_bit = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		tsync_tx_ctl_bit = E1000_TSYNCTXCTL_ENABLED;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter_type) {
+	case HWTSTAMP_FILTER_NONE:
+		tsync_rx_ctl_bit = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+		/*
+		 * register TSYNCRXCFG must be set, therefore it is not
+		 * possible to time stamp both Sync and Delay_Req messages
+		 * => fall back to time stamping all packets
+		 */
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_ALL;
+		config.rx_filter_type = HWTSTAMP_FILTER_ALL;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
+		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_SYNC_MESSAGE;
+		is_l4 = 1;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L4_V1;
+		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V1_DELAY_REQ_MESSAGE;
+		is_l4 = 1;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
+		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_SYNC_MESSAGE;
+		is_l2 = 1;
+		is_l4 = 1;
+		config.rx_filter_type = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
+		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE;
+		is_l2 = 1;
+		is_l4 = 1;
+		config.rx_filter_type = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_EVENT_V2;
+		config.rx_filter_type = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		is_l2 = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	/* enable/disable TX */
+	regval = rd32(E1000_TSYNCTXCTL);
+	regval = (regval & ~E1000_TSYNCTXCTL_ENABLED) | tsync_tx_ctl_bit;
+	wr32(E1000_TSYNCTXCTL, regval);
+
+	/* enable/disable RX, define which PTP packets are time stamped */
+	regval = rd32(E1000_TSYNCRXCTL);
+	regval = (regval & ~E1000_TSYNCRXCTL_ENABLED) | tsync_rx_ctl_bit;
+	regval = (regval & ~0xE) | tsync_rx_ctl_type;
+	wr32(E1000_TSYNCRXCTL, regval);
+	wr32(E1000_TSYNCRXCFG, tsync_rx_cfg);
+
+	/*
+	 * Ethertype Filter Queue Filter[0][15:0] = 0x88F7 (Ethertype to filter on)
+	 * Ethertype Filter Queue Filter[0][26] = 0x1 (Enable filter)
+	 * Ethertype Filter Queue Filter[0][30] = 0x1 (Enable Timestamping)
+	 */
+	wr32(E1000_ETQF0, is_l2 ? 0x440088f7 : 0);
+
+	/* L4 Queue Filter[0]: only filter by source and destination port */
+	wr32(E1000_SPQF0, htons(port));
+	wr32(E1000_IMIREXT(0), is_l4 ?
+		((1<<12) | (1<<19) /* bypass size and control flags */) : 0);
+	wr32(E1000_IMIR(0), is_l4 ?
+		(htons(port)
+			| (0<<16) /* immediate interrupt disabled */
+			| 0 /* (1<<17) bit cleared: do not bypass destination port check */)
+		: 0);
+	wr32(E1000_FTQF0, is_l4 ?
+		(0x11 /* UDP */
+			| (1<<15) /* VF not compared */
+			| (1<<27) /* Enable Timestamping */
+			| (7<<28) /* only source port filter enabled, source/target address and protocol masked */ )
+		: ( (1<<15) | (15<<28) /* all mask bits set = filter not enabled */));
+
+	wrfl();
+
+	/* clear TX/RX time stamp registers, just to be sure */
+	regval = rd32(E1000_TXSTMPH);
+	regval = rd32(E1000_RXSTMPH);
 
-	return -ERANGE;
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
 }
 
 /**
-- 
1.6.0.4


