From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 12/12] igb: use clocksync to implement hardware time stamping
Date: Wed, 21 Jan 2009 11:10:12 +0100
Message-ID: <1232532612-10382-12-git-send-email-patrick.ohly@intel.com>
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
 <1232532612-10382-10-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-11-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-api@vger.kernel.org, Patrick Ohly <patrick.ohly@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48344 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760205AbZAUKKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 05:10:42 -0500
In-Reply-To: <1232532612-10382-11-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both TX and RX hardware time stamping are implemented.  Due to
hardware limitations it is not possible to verify reliably which
packet was time stamped when multiple were pending for sending; this
could be solved by only allowing one packet marked for hardware time
stamping into the queue (not implemented yet).

RX time stamping relies on the flag in the packet descriptor which
marks packets that were time stamped. In "all packet" mode this flag
is not set. TODO: also support that mode (even though it'll suffer
from race conditions).

Allocation of RX buffers is not optimal yet: the extra space for
hardware time stamps is always allocated. Either this should only
be done when HW time stamping is (implies reallocation of buffers)
or packets with HW time stamps should be copied into a larger
buffer (implies higher overhead for those packets).
---
 drivers/net/igb/e1000_82575.h   |    1 +
 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/e1000_regs.h    |   40 ++++++
 drivers/net/igb/igb.h           |    4 +
 drivers/net/igb/igb_main.c      |  275 +++++++++++++++++++++++++++++++++++++--
 5 files changed, 312 insertions(+), 9 deletions(-)

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
index 40d0342..8909252 100644
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
index d225601..215d4d6 100644
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
index 2cf2c1a..9972801 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -35,6 +35,8 @@
 #include "e1000_82575.h"
 
 #include <linux/clocksource.h>
+#include <linux/clocksync.h>
+#include <linux/net_tstamp.h>
 
 struct igb_adapter;
 
@@ -266,6 +268,8 @@ struct igb_adapter {
 	struct net_device_stats net_stats;
 	struct cyclecounter cycles;
 	struct timecounter clock;
+	struct clocksync sync;
+	struct hwtstamp_config hwtstamp_config;
 
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7ab6faf..71c38cd 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -252,7 +252,8 @@ static char *igb_get_time_str(struct igb_adapter *adapter,
 
 	delta = timespec_sub(nic, sys);
 
-	sprintf(buffer, "NIC %ld.%09lus, SYS %ld.%09lus, NIC-SYS %lds + %09luns",
+	sprintf(buffer, "HW %llu, NIC %ld.%09lus, SYS %ld.%09lus, NIC-SYS %lds + %09luns",
+		hw,
 		(long)nic.tv_sec, nic.tv_nsec,
 		(long)sys.tv_sec, sys.tv_nsec,
 		(long)delta.tv_sec, delta.tv_nsec);
@@ -1418,6 +1419,18 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	wrfl();
 	timecounter_init(&adapter->clock, &adapter->cycles, ktime_to_ns(ktime_get_real()));
 
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
+
 #ifdef DEBUG
 	{
 		char buffer[160];
@@ -2776,6 +2789,7 @@ set_itr_now:
 #define IGB_TX_FLAGS_VLAN		0x00000002
 #define IGB_TX_FLAGS_TSO		0x00000004
 #define IGB_TX_FLAGS_IPV4		0x00000008
+#define IGB_TX_FLAGS_TSTAMP             0x00000010
 #define IGB_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IGB_TX_FLAGS_VLAN_SHIFT	16
 
@@ -3001,6 +3015,9 @@ static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
 		cmd_type_len |= E1000_ADVTXD_DCMD_VLE;
 
+	if (tx_flags & IGB_TX_FLAGS_TSTAMP)
+		cmd_type_len |= E1000_ADVTXD_MAC_TSTAMP;
+
 	if (tx_flags & IGB_TX_FLAGS_TSO) {
 		cmd_type_len |= E1000_ADVTXD_DCMD_TSE;
 
@@ -3092,6 +3109,7 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	unsigned int len;
 	u8 hdr_len = 0;
 	int tso = 0;
+	union skb_shared_tx *shtx;
 
 	len = skb_headlen(skb);
 
@@ -3114,7 +3132,28 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
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
+	shtx = skb_tx(skb);
+	if (shtx && shtx->hardware) {
+		shtx->in_progress = 1;
+		tx_flags |= IGB_TX_FLAGS_TSTAMP;
+	} else if (!shtx) {
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
@@ -3794,6 +3833,8 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 
 			if (skb) {
 				unsigned int segs, bytecount;
+				union skb_shared_tx *shtx;
+
 				/* gso_segs is currently only valid for tcp */
 				segs = skb_shinfo(skb)->gso_segs ?: 1;
 				/* multiply data chunks by size of headers */
@@ -3801,6 +3842,35 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
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
+				shtx = skb_tx(skb);
+				if (shtx && shtx->hardware) {
+					u32 valid = rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID;
+					if (valid) {
+						u64 regval = rd32(E1000_TXSTMPL);
+						u64 ns;
+						struct skb_shared_hwtstamps shhwtstamps;
+
+						memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+						regval |= (u64)rd32(E1000_TXSTMPH) << 32;
+					        ns = timecounter_cyc2time(&adapter->clock,
+									regval);
+						clocksync_update(&adapter->sync, ns);
+						shhwtstamps.hwtstamp = ns_to_ktime(ns);
+						shhwtstamps.syststamp =
+							clocksync_hw2sys(&adapter->sync, ns);
+						skb_tstamp_tx(skb, &shhwtstamps);
+					}
+					skb_orphan(skb);
+				}
 			}
 
 			igb_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -3974,6 +4044,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 {
 	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
 	struct igb_buffer *buffer_info , *next_buffer;
@@ -4065,6 +4136,50 @@ send_up:
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
+		 * If nothing went wrong, then it should have a
+		 * skb_shared_tx that we can turn into a
+		 * skb_shared_hwtstamps.
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
+			u64 regval;
+			u64 ns;
+			struct skb_shared_hwtstamps *shhwtstamps =
+				(struct skb_shared_hwtstamps *)skb_tx(skb);
+
+			WARN(!(rd32(E1000_TSYNCRXCTL) & E1000_TSYNCRXCTL_VALID),
+				"igb: no RX time stamp available for time stamped packet");
+			regval = rd32(E1000_RXSTMPL);
+			regval |= (u64)rd32(E1000_RXSTMPH) << 32;
+			if (shhwtstamps) {
+				ns = timecounter_cyc2time(&adapter->clock, regval);
+				clocksync_update(&adapter->sync, ns);
+				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+				shhwtstamps->hwtstamp = ns_to_ktime(ns);
+				shhwtstamps->syststamp = clocksync_hw2sys(&adapter->sync, ns);
+				skb->optional = (skb->optional & ~SKB_FLAGS_OPTIONAL_TX) |
+					SKB_FLAGS_OPTIONAL_HWTSTAMPS;
+			}
+		}
+
 		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
@@ -4166,8 +4281,26 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 			else
 				bufsz = adapter->rx_buffer_len;
 			bufsz += NET_IP_ALIGN;
-			skb = netdev_alloc_skb(netdev, bufsz);
 
+			/*
+			 * Always allocate the extra space for hardware
+			 * time stamps because even if hardware time stamping
+			 * is off right now, at the time when the buffer is
+			 * used it might be on.
+			 *
+			 * TODO: only allocate the extra space if
+			 * needed and when hardware timestamping is
+			 * enabled, reallocate the buffers without it.
+			 *
+			 * If only a few packets will get time stamped,
+			 * then the extra space is passed through
+			 * the kernel as empty skb_shared_tx (has the
+			 * same size as skb_shared_hwtstamps) and thus
+			 * wasted.
+			 */
+			skb = netdev_alloc_skb_flags(netdev, bufsz,
+						1 /* adapter->hwtstamp_config.rx_filter != HWTSTAMP_FILTER_NONE */ ?
+						SKB_FLAGS_OPTIONAL_TX : 0);
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;
@@ -4258,12 +4391,32 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
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
 
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
@@ -4272,11 +4425,115 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int
 	if (config.flags)
 		return -EINVAL;
 
-	if (config.tx_type == HWTSTAMP_TX_OFF &&
-		config.rx_filter == HWTSTAMP_FILTER_NONE)
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
+	switch (config.rx_filter) {
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
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
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
+		config.rx_filter = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_L2_L4_V2;
+		tsync_rx_cfg = E1000_TSYNCRXCFG_PTP_V2_DELAY_REQ_MESSAGE;
+		is_l2 = 1;
+		is_l4 = 1;
+		config.rx_filter = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		tsync_rx_ctl_type = E1000_TSYNCRXCTL_TYPE_EVENT_V2;
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
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
+	adapter->hwtstamp_config = config;
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
1.5.5.3

