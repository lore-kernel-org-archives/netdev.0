From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: add hardware timestamping support
Date: Mon, 17 Oct 2011 05:21:01 -0700
Message-ID: <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab1JQMVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 08:21:09 -0400
In-Reply-To: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Enable hardware offloading of timestamps via the SO_TIMESTAMPING
functionality. Adds support for enabling the hardware cycle counter,
and enabling the SO_TIMESTAMPING method for extracting the hardware
timestamps through the skb.

In the initial version, the cyclecounter structure was not properly
converting the cycles into nanoseconds, due to an incorrectly
calculated incvalue. v3 fixed this issue by recalculating the math and
giving a proper right-shift value to the cycle counter
structure. However, the DMA clock which is used to generate the
cyclecounter register changes frequency based on the link speed. This
version recalculates the incvalue based on the link speed every time
the device changes link speed.

The cyclecounter has the potential to miss a wrap-around of the
systim register (this should occur no more often than every 35
seconds) unless some activity regarding the cycle counter occurs at
least once within this time. This version adds a cycle counter read
every time the watchdog task is run, which should occur at least once
within this timeframe. Any packets being timestamped will also count
as a read due to the call to timecompare_update.

This version fixes an issue regarding timecompare not updating
detected skew after the clock offset is changed due to ptpd or outside
influence from the OS. Now the skew detection is forced just before we
hand a timestamp up to the kernel stack

Signed-off-by: Jacob E Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   21 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  445 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |   32 ++
 3 files changed, 497 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 6c4d693..9e6635e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -36,6 +36,10 @@
 #include <linux/aer.h>
 #include <linux/if_vlan.h>
 
+#include <linux/clocksource.h>
+#include <linux/timecompare.h>
+#include <linux/net_tstamp.h>
+
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb.h"
@@ -103,6 +107,7 @@
 #define IXGBE_TX_FLAGS_FSO		(u32)(1 << 6)
 #define IXGBE_TX_FLAGS_TXSW		(u32)(1 << 7)
 #define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 8)
+#define IXGBE_TX_FLAGS_TSTAMP		(u32)(1 << 9)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
@@ -319,6 +324,16 @@ struct ixgbe_q_vector {
 	char name[IFNAMSIZ + 9];
 };
 
+#define IXGBE_INCVAL_BASE_10GB   32
+#define IXGBE_INCVAL_BASE_1GB    320
+#define IXGBE_INCVAL_BASE_100    3200
+#define IXGBE_INCVAL_SHIFT_10GB  28
+#define IXGBE_INCVAL_SHIFT_1GB   24
+#define IXGBE_INCVAL_SHIFT_100   21
+#define IXGBE_INCVAL_DIVISOR     5
+#define IXGBE_INCVAL_SHIFT_82599 7
+#define IXGBE_INCPER_SHIFT_82599 24
+
 /*
  * microsecond values for various ITR rates shifted by 2 to fit itr register
  * with the first 3 bits reserved 0
@@ -409,6 +424,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 #define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
 #define IXGBE_FLAG2_FDIR_REQUIRES_REINIT        (u32)(1 << 7)
+#define IXGBE_FLAG2_CYCLECOUNTER_RUNNING        (u32)(1 << 8)
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
@@ -464,6 +480,11 @@ struct ixgbe_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 
+	struct cyclecounter cycles;
+	struct timecounter clock;
+	struct timecompare compare;
+	struct hwtstamp_config hwtstamp_config;
+
 	u32 test_icr;
 	struct ixgbe_ring test_tx_ring;
 	struct ixgbe_ring test_rx_ring;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fb7d884..c92c3a7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -135,6 +135,220 @@ MODULE_VERSION(DRV_VERSION);
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
+static cycle_t ixgbe_read_clock(const struct cyclecounter *tc)
+{
+	struct ixgbe_adapter *adapter =
+		container_of(tc, struct ixgbe_adapter, cycles);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 stamp = 0;
+
+
+	stamp |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIML);
+	stamp |= (u64)IXGBE_READ_REG(hw, IXGBE_SYSTIMH) << 32;
+
+	return stamp;
+}
+
+/**
+ * ixgbe_init_cyclecounter - initialize the systim cyclecounter
+ * @adapter: pointer to private adapter structure
+ *
+ * We need to call this function every time that the link goes up
+ * because the frequency of the DMA clock changes when the link
+ * speed changes.
+ */
+static void ixgbe_init_cyclecounter(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 incval = 0;
+
+	/*
+	 * (re)initialize hardware cycle counter
+	 * we keep this running just in case someone wants it
+	 * enabled in the future. However, we disable the flag
+	 * just in case so that no one tries to read during
+	 * the process of initializing.
+	 */
+	adapter->flags2 &= ~IXGBE_FLAG2_CYCLECOUNTER_RUNNING;
+
+	/*
+	 * 82598EB hardware does not support timestamping,
+	 * so we return after making sure the disable
+	 * the cyclecounter.
+	 */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+
+	memset(&adapter->cycles, 0, sizeof(adapter->cycles));
+	adapter->cycles.read = ixgbe_read_clock;
+	adapter->cycles.mask = CLOCKSOURCE_MASK(64);
+	adapter->cycles.mult = 1;
+
+	/**
+	 * Scale the NIC cycle counter by a large factor so that
+	 * relatively small corrections to the frequency can be added
+	 * or subtracted. The drawbacks of a large factor include
+	 * (a) the clock register overflows more quickly, (b) the cycle
+	 * counter structure must be able to convert the systim value
+	 * to nanoseconds using only a multiplier and a right-shift,
+	 * and (c) the value must fit within the timinca register space
+	 * => math based on internal DMA clock rate and available bits
+	 */
+	switch (adapter->link_speed) {
+	case IXGBE_LINK_SPEED_100_FULL:
+		incval = IXGBE_INCVAL_BASE_100;
+		incval <<= IXGBE_INCVAL_SHIFT_100;
+		incval /= IXGBE_INCVAL_DIVISOR;
+
+		adapter->cycles.shift = IXGBE_INCVAL_SHIFT_100;
+		break;
+	case IXGBE_LINK_SPEED_1GB_FULL:
+		incval = IXGBE_INCVAL_BASE_1GB;
+		incval <<= IXGBE_INCVAL_SHIFT_1GB;
+		incval /= IXGBE_INCVAL_DIVISOR;
+
+		adapter->cycles.shift = IXGBE_INCVAL_SHIFT_1GB;
+		break;
+	case IXGBE_LINK_SPEED_10GB_FULL:
+	default:
+		incval = IXGBE_INCVAL_BASE_10GB;
+		incval <<= IXGBE_INCVAL_SHIFT_10GB;
+		incval /= IXGBE_INCVAL_DIVISOR;
+
+		adapter->cycles.shift = IXGBE_INCVAL_SHIFT_10GB;
+		break;
+	}
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_X540:
+		IXGBE_WRITE_REG(hw, IXGBE_TIMINCA, (u32)incval);
+		break;
+	case ixgbe_mac_82599EB:
+		incval >>= IXGBE_INCVAL_SHIFT_82599;
+		adapter->cycles.shift -= IXGBE_INCVAL_SHIFT_82599;
+		IXGBE_WRITE_REG(hw, IXGBE_TIMINCA,
+			    (1 << IXGBE_INCPER_SHIFT_82599) |
+				(u32)incval);
+		break;
+	default:
+		/* other devices aren't supported */
+		return;
+	}
+
+	/* reset the system time registers */
+	IXGBE_WRITE_REG(hw, IXGBE_SYSTIML, 0x00000000);
+	IXGBE_WRITE_REG(hw, IXGBE_SYSTIMH, 0x00000000);
+	IXGBE_WRITE_FLUSH(hw);
+
+	/* Enable the watchdog task to decect cycle counter overflow */
+	adapter->flags2 |= IXGBE_FLAG2_CYCLECOUNTER_RUNNING;
+
+	/* reset the ns time counter */
+	timecounter_init(&adapter->clock,
+			 &adapter->cycles,
+			 ktime_to_ns(ktime_get_real()));
+}
+
+/**
+ * ixgbe_systim_to_hwtstamp - convert system time value to hw timestamp
+ * @adapter: board private structure
+ * @shhwtstamps: timestamp structure to update
+ * @regval: unsigned 64bit system time value.
+ *
+ * We need to convert the system time value stored in the RX/TXSTMP registers
+ * into a hwtstamp which can be used by the upper level timestamping functions
+ */
+static void ixgbe_systim_to_hwtstamp(struct ixgbe_adapter *adapter,
+				     struct skb_shared_hwtstamps *shhwtstamps,
+				     u64 regval)
+{
+	u64 ns;
+
+	/* timestamps aren't valid if the cyclecounter isn't initialized */
+	if (!(adapter->flags2 & IXGBE_FLAG2_CYCLECOUNTER_RUNNING))
+		return;
+
+	ns = timecounter_cyc2time(&adapter->clock, regval);
+
+	/*
+	 * force the timecompare structure to detect skew here in
+	 * order to prevent the case where the wall clock has been
+	 * adjusted by a factor which makes the previous skew
+	 * invalid. this prevents us from giving invalid timestamps to
+	 * the kernel stack.
+	 */
+	timecompare_update(&adapter->compare, 0);
+	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamps->hwtstamp = ns_to_ktime(ns);
+	shhwtstamps->syststamp = timecompare_transform(&adapter->compare, ns);
+}
+
+/**
+ * ixgbe_tx_hwtstamp - utility function which checks for TX time stamp
+ * @q_vector: pointer to q_vector containing needed info
+ * @buffer: pointer to ixgbe_tx_buffer structure
+ *
+ * If we were asked to do hardware stamping and such a time stamp is
+ * available, then it must have been for this skb here because we only
+ * allow only one such packet into the queue.
+ */
+static void ixgbe_tx_hwtstamp(struct ixgbe_q_vector *q_vector,
+			      struct ixgbe_tx_buffer *buffer_info)
+{
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct skb_shared_hwtstamps shhwtstamps;
+	u64 regval = 0;
+
+	/* if skb does not support hw timestamp or TX stamp not valid exit */
+	if (likely(!(buffer_info->tx_flags & IXGBE_TX_FLAGS_TSTAMP)) ||
+	    !(IXGBE_READ_REG(hw, IXGBE_TSYNCTXCTL) & IXGBE_TSYNCTXCTL_VALID))
+		return;
+
+	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_TXSTMPL);
+	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_TXSTMPH) << 32;
+
+	ixgbe_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
+	skb_tstamp_tx(buffer_info->skb, &shhwtstamps);
+}
+
+/**
+ * ixgbe_rx_hwtstamp - utility function which checks for RX time stamp
+ * @q_vector: pointer to q_vector containing needed info
+ * @skb: pointer to the skb
+ *
+ * If we were asked to do hardware stamping and such a time stamp is
+ * available, then it must have been for this skb here because we only
+ * allow only one such packet into the queue.
+ */
+static void ixgbe_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
+			      struct sk_buff *skb)
+{
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 regval = 0;
+
+	/*
+	 * If this bit is set, then the RX registers contain the time stamp. No
+	 * other packet will be time stamped until we read these registers, so
+	 * read the registers to make them available again. Because only one
+	 * packet can be time stamped at a time, we know that the register
+	 * values must belong to this one here and therefore we don't need to
+	 * compare any of the additional attributes stored for it.
+	 *
+	 * If nothing went wrong, then it should have a skb_shared_tx that we
+	 * can turn into a skb_shared_hwtstamps.
+	 */
+	if (!(IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL) & IXGBE_TSYNCRXCTL_VALID))
+		return;
+
+	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPL);
+	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPH) << 32;
+
+	ixgbe_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
+}
+
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -773,6 +987,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			tx_desc->wb.status = 0;
 			if (likely(tx_desc == eop_desc)) {
 				eop_desc = NULL;
+
+				ixgbe_tx_hwtstamp(q_vector, tx_buffer);
+
 				dev_kfree_skb_any(tx_buffer->skb);
 				tx_buffer->skb = NULL;
 
@@ -1399,6 +1616,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (adapter->netdev->features & NETIF_F_RXHASH)
 			ixgbe_rx_hash(rx_desc, skb);
 
+		if (unlikely(staterr & IXGBE_RXDADV_STAT_TS))
+			ixgbe_rx_hwtstamp(q_vector, skb);
+
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -5841,6 +6061,24 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_check_cycle_overflow_subtask - read the clock every
+ * few seconds to prevent the timecounter from losing cycles
+ * due to cycle counter overflow.
+ * @adapter - pointer to the device adapter structure
+ */
+static void ixgbe_check_cycle_overflow_subtask(struct ixgbe_adapter *adapter)
+{
+	u64 ns;
+
+	if (!(adapter->flags2 & IXGBE_FLAG2_CYCLECOUNTER_RUNNING))
+		return;
+
+	/* read the cycle counter and update the clock skew. */
+	ns = timecounter_read(&adapter->clock);
+	timecompare_update(&adapter->compare, ns);
+}
+
+/**
  * ixgbe_watchdog_update_link - update the link status
  * @adapter - pointer to the device adapter structure
  * @link_speed - pointer to a u32 to store the link_speed
@@ -5922,6 +6160,9 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 		flow_rx = false;
 		break;
 	}
+
+	ixgbe_init_cyclecounter(adapter);
+
 	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
 	       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
 	       "10 Gbps" :
@@ -6268,6 +6509,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_watchdog_subtask(adapter);
 	ixgbe_fdir_reinit_subtask(adapter);
 	ixgbe_check_hang_subtask(adapter);
+	ixgbe_check_cycle_overflow_subtask(adapter);
 
 	ixgbe_service_event_complete(adapter);
 }
@@ -6425,6 +6667,9 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 	if (tx_flags & IXGBE_TX_FLAGS_HW_VLAN)
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
 
+	if (tx_flags & IXGBE_TX_FLAGS_TSTAMP)
+		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_MAC_TSTAMP);
+
 	/* set segmentation enable bits for TSO/FSO */
 #ifdef IXGBE_FCOE
 	if ((tx_flags & IXGBE_TX_FLAGS_TSO) || (tx_flags & IXGBE_TX_FLAGS_FSO))
@@ -6800,6 +7045,11 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
+	}
+
 #ifdef CONFIG_PCI_IOV
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		tx_flags |= IXGBE_TX_FLAGS_TXSW;
@@ -6952,11 +7202,187 @@ static int ixgbe_mdio_write(struct net_device *netdev, int prtad, int devad,
 	return hw->phy.ops.write_reg(hw, addr, devad, value);
 }
 
+/**
+ * ixgbe_hwtstamp_ioctl - control hardware time stamping
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ *
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
+ **/
+static int ixgbe_hwtstamp_ioctl(struct net_device *netdev,
+				struct ifreq *ifr, int cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct hwtstamp_config config;
+	u32 tsync_tx_ctl = IXGBE_TSYNCTXCTL_ENABLED;
+	u32 tsync_rx_ctl = IXGBE_TSYNCRXCTL_ENABLED;
+	u32 tsync_rx_mtrl = 0;
+	bool is_l4 = false;
+	bool is_l2 = false;
+	u32 regval;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		tsync_tx_ctl = 0;
+	case HWTSTAMP_TX_ON:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		tsync_rx_ctl = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
+		tsync_rx_mtrl = IXGBE_RXMTRL_V1_SYNC_MSG;
+		is_l4 = true;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L4_V1;
+		tsync_rx_mtrl = IXGBE_RXMTRL_V1_DELAY_REQ_MSG;
+		is_l4 = true;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L2_L4_V2;
+		tsync_rx_mtrl = IXGBE_RXMTRL_V2_SYNC_MSG;
+		is_l2 = true;
+		is_l4 = true;
+		config.rx_filter = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_L2_L4_V2;
+		tsync_rx_mtrl = IXGBE_RXMTRL_V2_DELAY_REQ_MSG;
+		is_l2 = true;
+		is_l4 = true;
+		config.rx_filter = HWTSTAMP_FILTER_SOME;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+		tsync_rx_ctl |= IXGBE_TSYNCRXCTL_TYPE_EVENT_V2;
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		is_l2 = true;
+		is_l4 = true;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+	default:
+		/*
+		 * register RXMTRL must be set, therefore it is not
+		 * possible to time stamp both V1 Sync and Delay_Req messages
+		 * and hardware does not support timestamping all packets
+		 * => return error
+		 */
+		return -ERANGE;
+	}
+
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		if (tsync_rx_ctl | tsync_tx_ctl)
+			return -ERANGE;
+		return 0;
+	}
+
+	/* define ethertype filter for timestamped packets */
+	if (is_l2)
+		IXGBE_WRITE_REG(hw, IXGBE_ETQF(3),
+				(IXGBE_ETQF_FILTER_EN | /* enable filter */
+				 IXGBE_ETQF_1588 | /* enable timestamping */
+				 ETH_P_1588));     /* 1588 eth protocol type */
+	else
+		IXGBE_WRITE_REG(hw, IXGBE_ETQF(3), 0);
+
+#define PTP_PORT 319
+	/* L4 Queue Filter[3]: filter by destination port and protocol */
+	if (is_l4) {
+		u32 ftqf = (IXGBE_FTQF_PROTOCOL_UDP /* UDP */
+			    | IXGBE_FTQF_POOL_MASK_EN /* Pool not compared */
+			    | IXGBE_FTQF_QUEUE_ENABLE);
+
+		ftqf |= ((IXGBE_FTQF_PROTOCOL_COMP_MASK /* protocol check */
+			  & IXGBE_FTQF_DEST_PORT_MASK /* dest check */
+			  & IXGBE_FTQF_SOURCE_PORT_MASK) /* source check */
+			 << IXGBE_FTQF_5TUPLE_MASK_SHIFT);
+
+		IXGBE_WRITE_REG(hw, IXGBE_L34T_IMIR(3),
+				(3 << IXGBE_IMIR_RX_QUEUE_SHIFT_82599 |
+				 IXGBE_IMIR_SIZE_BP_82599));
+
+		/* enable port check */
+		IXGBE_WRITE_REG(hw, IXGBE_SDPQF(3),
+				(htons(PTP_PORT) |
+				 htons(PTP_PORT) << 16));
+
+		IXGBE_WRITE_REG(hw, IXGBE_FTQF(3), ftqf);
+
+		tsync_rx_mtrl |= PTP_PORT << 16;
+	} else {
+		IXGBE_WRITE_REG(hw, IXGBE_FTQF(3), 0);
+	}
+
+	/* enable/disable TX */
+	regval = IXGBE_READ_REG(hw, IXGBE_TSYNCTXCTL);
+	regval &= ~IXGBE_TSYNCTXCTL_ENABLED;
+	regval |= tsync_tx_ctl;
+	IXGBE_WRITE_REG(hw, IXGBE_TSYNCTXCTL, regval);
+
+	/* enable/disable RX */
+	regval = IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL);
+	regval &= ~(IXGBE_TSYNCRXCTL_ENABLED | IXGBE_TSYNCRXCTL_TYPE_MASK);
+	regval |= tsync_rx_ctl;
+	IXGBE_WRITE_REG(hw, IXGBE_TSYNCRXCTL, regval);
+
+	/* define which PTP packets are time stamped */
+	IXGBE_WRITE_REG(hw, IXGBE_RXMTRL, tsync_rx_mtrl);
+
+	IXGBE_WRITE_FLUSH(hw);
+
+	adapter->hwtstamp_config = config;
+
+	/* clear TX/RX time stamp registers, just to be sure */
+	regval = IXGBE_READ_REG(hw, IXGBE_TXSTMPH);
+	regval = IXGBE_READ_REG(hw, IXGBE_RXSTMPH);
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+
 static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return ixgbe_hwtstamp_ioctl(netdev, req, cmd);
+	default:
+		return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
+	}
 }
 
 /**
@@ -7643,6 +8069,23 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* pick up the PCI bus settings for reporting later */
 	hw->mac.ops.get_bus_info(hw);
 
+	/* initialize the cycle counter */
+	ixgbe_init_cyclecounter(adapter);
+
+	/*
+	 * Provide a timestamp synchronized against the system wall
+	 * clock. NIC time stamp reading requires ~3us per sample,
+	 * each sample was pretty stable even under load
+	 * => only require 10 samples for each offset comparison.
+	 */
+	if (adapter->flags2 & IXGBE_FLAG2_CYCLECOUNTER_RUNNING) {
+		memset(&adapter->compare, 0, sizeof(adapter->compare));
+		adapter->compare.source = &adapter->clock;
+		adapter->compare.target = ktime_get_real;
+		adapter->compare.num_samples = 10;
+		timecompare_update(&adapter->compare, 0);
+	}
+
 	/* print bus type/speed/width info */
 	e_dev_info("(PCI Express:%s:%s) %pM\n",
 		   (hw->bus.speed == ixgbe_bus_speed_5000 ? "5.0GT/s" :
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6c5cca8..8692672 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1837,6 +1837,36 @@ enum {
 #define IXGBE_RXDCTL_RLPML_EN   0x00008000
 #define IXGBE_RXDCTL_VME        0x40000000  /* VLAN mode enable */
 
+#define IXGBE_TSYNCTXCTL_VALID     0x00000001 /* Tx timestamp valid */
+#define IXGBE_TSYNCTXCTL_ENABLED   0x00000010 /* Tx timestamping enabled */
+
+#define IXGBE_TSYNCRXCTL_VALID     0x00000001 /* Rx timestamp valid */
+#define IXGBE_TSYNCRXCTL_TYPE_MASK 0x0000000E /* Rx type mask */
+#define IXGBE_TSYNCRXCTL_TYPE_L2_V2      0x00
+#define IXGBE_TSYNCRXCTL_TYPE_L4_V1      0x02
+#define IXGBE_TSYNCRXCTL_TYPE_L2_L4_V2   0x04
+#define IXGBE_TSYNCRXCTL_TYPE_EVENT_V2   0x0A
+#define IXGBE_TSYNCRXCTL_ENABLED   0x00000010 /* Rx Timestamping enabled */
+
+#define IXGBE_RXMTRL_V1_CTRLT_MASK 0x000000FF
+#define IXGBE_RXMTRL_V1_SYNC_MSG         0x00
+#define IXGBE_RXMTRL_V1_DELAY_REQ_MSG    0x01
+#define IXGBE_RXMTRL_V1_FOLLOWUP_MSG     0x02
+#define IXGBE_RXMTRL_V1_DELAY_RESP_MSG   0x03
+#define IXGBE_RXMTRL_V1_MGMT_MSG         0x04
+
+#define IXGBE_RXMTRL_V2_MSGID_MASK      0x0000FF00
+#define IXGBE_RXMTRL_V2_SYNC_MSG            0x0000
+#define IXGBE_RXMTRL_V2_DELAY_REQ_MSG       0x0100
+#define IXGBE_RXMTRL_V2_PDELAY_REQ_MSG      0x0200
+#define IXGBE_RXMTRL_V2_PDELAY_RESP_MSG     0x0300
+#define IXGBE_RXMTRL_V2_FOLLOWUP_MSG        0x0800
+#define IXGBE_RXMTRL_V2_DELAY_RESP_MSG      0x0900
+#define IXGBE_RXMTRL_V2_PDELAY_FOLLOWUP_MSG 0x0A00
+#define IXGBE_RXMTRL_V2_ANNOUNCE_MSG        0x0B00
+#define IXGBE_RXMTRL_V2_SIGNALLING_MSG      0x0C00
+#define IXGBE_RXMTRL_V2_MGMT_MSG            0x0D00
+
 #define IXGBE_FCTRL_SBP 0x00000002 /* Store Bad Packet */
 #define IXGBE_FCTRL_MPE 0x00000100 /* Multicast Promiscuous Ena*/
 #define IXGBE_FCTRL_UPE 0x00000200 /* Unicast Promiscuous Ena */
@@ -1966,6 +1996,7 @@ enum {
 #define IXGBE_RXDADV_STAT_FCSTAT_NODDP  0x00000010 /* 01: Ctxt w/o DDP */
 #define IXGBE_RXDADV_STAT_FCSTAT_FCPRSP 0x00000020 /* 10: Recv. FCP_RSP */
 #define IXGBE_RXDADV_STAT_FCSTAT_DDP    0x00000030 /* 11: Ctxt w/ DDP */
+#define IXGBE_RXDADV_STAT_TS            0x00010000 /* IEEE1588 Time Stamp */
 
 /* PSRTYPE bit definitions */
 #define IXGBE_PSRTYPE_TCPHDR    0x00000010
@@ -2243,6 +2274,7 @@ struct ixgbe_adv_tx_context_desc {
 /* Adv Transmit Descriptor Config Masks */
 #define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF /* Data buf length(bytes) */
 #define IXGBE_ADVTXD_MAC_LINKSEC      0x00040000 /* Insert LinkSec */
+#define IXGBE_ADVTXD_MAC_TSTAMP       0x00080000 /* IEEE1588 time stamp */
 #define IXGBE_ADVTXD_IPSEC_SA_INDEX_MASK   0x000003FF /* IPSec SA index */
 #define IXGBE_ADVTXD_IPSEC_ESP_LEN_MASK    0x000001FF /* IPSec ESP length */
 #define IXGBE_ADVTXD_DTYP_MASK  0x00F00000 /* DTYP mask */
-- 
1.7.6.4
