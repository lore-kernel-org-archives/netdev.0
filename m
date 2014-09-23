From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 29/29] fm10k: Add support for PTP
Date: Tue, 23 Sep 2014 04:16:57 -0700
Message-ID: <1411471017-28213-30-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57261 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbaIWLRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:32 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for the Linux PTP Hardware clock and timestamping
functionality provided by the hardware.  There are actually two cases that
this timestamping is meant to support.

The first case would be an ordinary clock scenario.  In this configuration
the host interface does not have access to BAR 4.  However all of the host
interfaces should be locked into the same boundary clock region and as such
they are all on the same clock anyway.  With this being the case they can
synchronize among themselves and only need to adjust the offset since they
are all on the same clock with the same frequency.

The second case is a boundary clock scenario.  This is a special case and
would require both BAR 4 access, and a means of presenting a netdev per
boundary region.  The current plan is to use DSA at some point in the
future to provide these interfaces, but the DSA portion is still under
development.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile        |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  37 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  30 ++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  20 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  20 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 112 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     | 463 +++++++++++++++++++++++
 7 files changed, 683 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index fbc0e09..08859dd 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -30,4 +30,4 @@ obj-$(CONFIG_FM10K) += fm10k.o
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
 	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o fm10k_vf.o \
 	      fm10k_mbx.o fm10k_iov.o fm10k_tlv.o \
-	      fm10k_debugfs.o fm10k_dcbnl.o
+	      fm10k_debugfs.o fm10k_ptp.o fm10k_dcbnl.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 1045483..0565827 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -26,6 +26,9 @@
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
+#include <linux/net_tstamp.h>
+#include <linux/clocksource.h>
+#include <linux/ptp_clock_kernel.h>
 
 #include "fm10k_pf.h"
 #include "fm10k_vf.h"
@@ -293,6 +296,7 @@ struct fm10k_intfc {
 	struct fm10k_hw_stats stats;
 	struct fm10k_hw hw;
 	u32 __iomem *uc_addr;
+	u32 __iomem *sw_addr;
 	u16 msg_enable;
 	u16 tx_ring_count;
 	u16 rx_ring_count;
@@ -314,6 +318,20 @@ struct fm10k_intfc {
 	struct dentry *dbg_intfc;
 
 #endif /* CONFIG_DEBUG_FS */
+	struct ptp_clock_info ptp_caps;
+	struct ptp_clock *ptp_clock;
+
+	struct sk_buff_head ts_tx_skb_queue;
+	u32 tx_hwtstamp_timeouts;
+
+	struct hwtstamp_config ts_config;
+	/* We are unable to actually adjust the clock beyond the frequency
+	 * value.  Once the clock is started there is no resetting it.  As
+	 * such we maintain a separate offset from the actual hardware clock
+	 * to allow for offset adjustment.
+	 */
+	s64 ptp_adjust;
+	rwlock_t systime_lock;
 #ifdef CONFIG_DCB
 	u8 pfc_en;
 #endif
@@ -411,6 +429,10 @@ union fm10k_ftag_info {
 };
 
 struct fm10k_cb {
+	union {
+		__le64 tstamp;
+		unsigned long ts_tx_timeout;
+	};
 	union fm10k_ftag_info fi;
 };
 
@@ -492,6 +514,21 @@ static inline void fm10k_dbg_init(void) {}
 static inline void fm10k_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS */
 
+/* Time Stamping */
+void fm10k_systime_to_hwtstamp(struct fm10k_intfc *interface,
+			       struct skb_shared_hwtstamps *hwtstamp,
+			       u64 systime);
+void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb);
+void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
+			  u64 systime);
+void fm10k_ts_reset(struct fm10k_intfc *interface);
+void fm10k_ts_init(struct fm10k_intfc *interface);
+void fm10k_ts_tx_subtask(struct fm10k_intfc *interface);
+void fm10k_ptp_register(struct fm10k_intfc *interface);
+void fm10k_ptp_unregister(struct fm10k_intfc *interface);
+int fm10k_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
+int fm10k_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
+
 /* DCB */
 void fm10k_dcbnl_set_ops(struct net_device *dev);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 42beb89..a9bbe60 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -91,6 +91,8 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 	FM10K_STAT("mbx_rx_messages", hw.mbx.rx_messages),
 	FM10K_STAT("mbx_rx_dwords", hw.mbx.rx_dwords),
 	FM10K_STAT("mbx_rx_parse_err", hw.mbx.rx_parse_err),
+
+	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
 #define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_stats)
@@ -1006,6 +1008,33 @@ static int fm10k_set_channels(struct net_device *dev,
 	return fm10k_setup_tc(dev, netdev_get_num_tc(dev));
 }
 
+static int fm10k_get_ts_info(struct net_device *dev,
+			   struct ethtool_ts_info *info)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (interface->ptp_clock)
+		info->phc_index = ptp_clock_index(interface->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types = (1 << HWTSTAMP_TX_OFF) |
+			 (1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			   (1 << HWTSTAMP_FILTER_ALL);
+
+	return 0;
+}
+
 static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_strings		= fm10k_get_strings,
 	.get_sset_count		= fm10k_get_sset_count,
@@ -1031,6 +1060,7 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.set_rxfh		= fm10k_set_rssh,
 	.get_channels		= fm10k_get_channels,
 	.set_channels		= fm10k_set_channels,
+	.get_ts_info            = fm10k_get_ts_info,
 };
 
 void fm10k_set_ethtool_ops(struct net_device *dev)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index d998733..6c800a3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -399,6 +399,19 @@ static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 }
 
+static void fm10k_rx_hwtstamp(struct fm10k_ring *rx_ring,
+			      union fm10k_rx_desc *rx_desc,
+			      struct sk_buff *skb)
+{
+	struct fm10k_intfc *interface = rx_ring->q_vector->interface;
+
+	FM10K_CB(skb)->tstamp = rx_desc->q.timestamp;
+
+	if (unlikely(interface->flags & FM10K_FLAG_RX_TS_ENABLED))
+		fm10k_systime_to_hwtstamp(interface, skb_hwtstamps(skb),
+					  le64_to_cpu(rx_desc->q.timestamp));
+}
+
 static void fm10k_type_trans(struct fm10k_ring *rx_ring,
 			     union fm10k_rx_desc *rx_desc,
 			     struct sk_buff *skb)
@@ -448,6 +461,8 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 
 	fm10k_rx_checksum(rx_ring, rx_desc, skb);
 
+	fm10k_rx_hwtstamp(rx_ring, rx_desc, skb);
+
 	FM10K_CB(skb)->fi.w.vlan = rx_desc->w.vlan;
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
@@ -886,6 +901,11 @@ static u8 fm10k_tx_desc_flags(struct sk_buff *skb, u32 tx_flags)
 	/* set type for advanced descriptor with frame checksum insertion */
 	u32 desc_flags = 0;
 
+	/* set timestamping bits */
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+	    likely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
+			desc_flags |= FM10K_TXD_FLAG_TIME;
+
 	/* set checksum offload bits */
 	desc_flags |= FM10K_SET_FLAG(tx_flags, FM10K_TX_FLAGS_CSUM,
 				     FM10K_TXD_FLAG_CSUM);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 991abb2..dcec000 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -243,6 +243,9 @@ void fm10k_clean_all_tx_rings(struct fm10k_intfc *interface)
 
 	for (i = 0; i < interface->num_tx_queues; i++)
 		fm10k_clean_tx_ring(interface->tx_ring[i]);
+
+	/* remove any stale timestamp buffers and free them */
+	skb_queue_purge(&interface->ts_tx_skb_queue);
 }
 
 /**
@@ -651,6 +654,10 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 		__skb_put(skb, pad_len);
 	}
 
+	/* prepare packet for hardware time stamping */
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
+		fm10k_ts_tx_enqueue(interface, skb);
+
 	if (r_idx >= interface->num_tx_queues)
 		r_idx %= interface->num_tx_queues;
 
@@ -1177,6 +1184,18 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
+static int fm10k_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCGHWTSTAMP:
+		return fm10k_get_ts_config(netdev, ifr);
+	case SIOCSHWTSTAMP:
+		return fm10k_set_ts_config(netdev, ifr);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static void fm10k_assign_l2_accel(struct fm10k_intfc *interface,
 				  struct fm10k_l2_accel *l2_accel)
 {
@@ -1345,6 +1364,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
 	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
 	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
+	.ndo_do_ioctl		= fm10k_ioctl,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
 };
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 74d7d47..e02036c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -170,6 +170,9 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
+	/* reset clock */
+	fm10k_ts_reset(interface);
+
 	if (netif_running(netdev))
 		fm10k_open(netdev);
 
@@ -490,6 +493,7 @@ static void fm10k_service_task(struct work_struct *work)
 	/* tasks only run when interface is up */
 	fm10k_watchdog_subtask(interface);
 	fm10k_check_hang_subtask(interface);
+	fm10k_ts_tx_subtask(interface);
 
 	/* release lock on service events to allow scheduling next event */
 	fm10k_service_event_complete(interface);
@@ -1064,6 +1068,25 @@ static s32 fm10k_mbx_mac_addr(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
+static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
+			     struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_intfc *interface;
+	u64 timestamp;
+	s32 err;
+
+	err = fm10k_tlv_attr_get_u64(results[FM10K_1588_MSG_TIMESTAMP],
+				     &timestamp);
+	if (err)
+		return err;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	fm10k_ts_tx_hwtstamp(interface, 0, timestamp);
+
+	return 0;
+}
+
 /* generic error handler for mailbox issues */
 static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
 			   struct fm10k_mbx_info *mbx)
@@ -1084,6 +1107,7 @@ static const struct fm10k_msg_data vf_mbx_data[] = {
 	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
 	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_mbx_mac_addr),
 	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_msg_lport_state_vf),
+	FM10K_VF_MSG_1588_HANDLER(fm10k_1588_msg_vf),
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
 };
 
@@ -1181,6 +1205,68 @@ static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
+static s32 fm10k_1588_msg_pf(struct fm10k_hw *hw, u32 **results,
+			     struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_swapi_1588_timestamp timestamp;
+	struct fm10k_iov_data *iov_data;
+	struct fm10k_intfc *interface;
+	u16 sglort, vf_idx;
+	s32 err;
+
+	err = fm10k_tlv_attr_get_le_struct(
+				results[FM10K_PF_ATTR_ID_1588_TIMESTAMP],
+				&timestamp, sizeof(timestamp));
+	if (err)
+		return err;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	if (timestamp.dglort) {
+		fm10k_ts_tx_hwtstamp(interface, timestamp.dglort,
+				     le64_to_cpu(timestamp.egress));
+		return 0;
+	}
+
+	/* either dglort or sglort must be set */
+	if (!timestamp.sglort)
+		return FM10K_ERR_PARAM;
+
+	/* verify GLORT is at least one of the ones we own */
+	sglort = le16_to_cpu(timestamp.sglort);
+	if (!fm10k_glort_valid_pf(hw, sglort))
+		return FM10K_ERR_PARAM;
+
+	if (sglort == interface->glort) {
+		fm10k_ts_tx_hwtstamp(interface, 0,
+				     le64_to_cpu(timestamp.ingress));
+		return 0;
+	}
+
+	/* if there is no iov_data then there is no mailboxes to process */
+	if (!ACCESS_ONCE(interface->iov_data))
+		return FM10K_ERR_PARAM;
+
+	rcu_read_lock();
+
+	/* notify VF if this timestamp belongs to it */
+	iov_data = interface->iov_data;
+	vf_idx = (hw->mac.dglort_map & FM10K_DGLORTMAP_NONE) - sglort;
+
+	if (!iov_data || vf_idx >= iov_data->num_vfs) {
+		err = FM10K_ERR_PARAM;
+		goto err_unlock;
+	}
+
+	err = hw->iov.ops.report_timestamp(hw, &iov_data->vf_info[vf_idx],
+					   le64_to_cpu(timestamp.ingress));
+
+err_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
 static const struct fm10k_msg_data pf_mbx_data[] = {
 	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
@@ -1188,6 +1274,7 @@ static const struct fm10k_msg_data pf_mbx_data[] = {
 	FM10K_PF_MSG_ERR_HANDLER(LPORT_CREATE, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(LPORT_DELETE, fm10k_msg_err_pf),
 	FM10K_PF_MSG_UPDATE_PVID_HANDLER(fm10k_update_pvid),
+	FM10K_PF_MSG_1588_TIMESTAMP_HANDLER(fm10k_1588_msg_pf),
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
 };
 
@@ -1549,6 +1636,12 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		return -EIO;
 	}
 
+	/* assign BAR 4 resources for use with PTP */
+	if (fm10k_read_reg(hw, FM10K_CTRL) & FM10K_CTRL_BAR4_ALLOWED)
+		interface->sw_addr = ioremap(pci_resource_start(pdev, 4),
+					     pci_resource_len(pdev, 4));
+	hw->sw_addr = interface->sw_addr;
+
 	/* Only the PF can support VXLAN and NVGRE offloads */
 	if (hw->mac.type != fm10k_mac_pf) {
 		netdev->hw_enc_features = 0;
@@ -1565,6 +1658,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		    (unsigned long)interface);
 	INIT_WORK(&interface->service_task, fm10k_service_task);
 
+	/* Intitialize timestamp data */
+	fm10k_ts_init(interface);
+
 	/* set default ring sizes */
 	interface->tx_ring_count = FM10K_DEFAULT_TXD;
 	interface->rx_ring_count = FM10K_DEFAULT_RXD;
@@ -1716,6 +1812,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	/* stop all the transmit queues from transmitting until link is up */
 	netif_tx_stop_all_queues(netdev);
 
+	/* Register PTP interface */
+	fm10k_ptp_register(interface);
+
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "(PCI Express:%s Width: %s Payload: %s)\n",
 		 (hw->bus.speed == fm10k_bus_speed_8000 ? "8.0GT/s" :
@@ -1747,6 +1846,8 @@ err_register:
 err_mbx_interrupt:
 	fm10k_clear_queueing_scheme(interface);
 err_sw_init:
+	if (interface->sw_addr)
+		iounmap(interface->sw_addr);
 	iounmap(interface->uc_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -1780,6 +1881,9 @@ static void fm10k_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
+	/* cleanup timestamp handling */
+	fm10k_ptp_unregister(interface);
+
 	/* release VFs */
 	fm10k_iov_disable(pdev);
 
@@ -1792,6 +1896,8 @@ static void fm10k_remove(struct pci_dev *pdev)
 	/* remove any debugfs interfaces */
 	fm10k_dbg_intfc_exit(interface);
 
+	if (interface->sw_addr)
+		iounmap(interface->sw_addr);
 	iounmap(interface->uc_addr);
 
 	free_netdev(netdev);
@@ -1848,6 +1954,9 @@ static int fm10k_resume(struct pci_dev *pdev)
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
 
+	/* reset clock */
+	fm10k_ts_reset(interface);
+
 	rtnl_lock();
 
 	err = fm10k_init_queueing_scheme(interface);
@@ -2004,6 +2113,9 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
+	/* reset clock */
+	fm10k_ts_reset(interface);
+
 	if (netif_running(netdev))
 		err = fm10k_open(netdev);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
new file mode 100644
index 0000000..7822809
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -0,0 +1,463 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include <linux/ptp_classify.h>
+#include <linux/ptp_clock_kernel.h>
+
+#include "fm10k.h"
+
+#define FM10K_TS_TX_TIMEOUT		(HZ * 15)
+
+void fm10k_systime_to_hwtstamp(struct fm10k_intfc *interface,
+			       struct skb_shared_hwtstamps *hwtstamp,
+			       u64 systime)
+{
+	unsigned long flags;
+
+	read_lock_irqsave(&interface->systime_lock, flags);
+	systime += interface->ptp_adjust;
+	read_unlock_irqrestore(&interface->systime_lock, flags);
+
+	hwtstamp->hwtstamp = ns_to_ktime(systime);
+}
+
+static struct sk_buff *fm10k_ts_tx_skb(struct fm10k_intfc *interface,
+				       __le16 dglort)
+{
+	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
+	struct sk_buff *skb;
+
+	skb_queue_walk(list, skb) {
+		if (FM10K_CB(skb)->fi.w.dglort == dglort)
+			return skb;
+	}
+
+	return NULL;
+}
+
+void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
+{
+	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
+	struct sk_buff *clone;
+	unsigned long flags;
+	__le16 dglort;
+
+	/* create clone for us to return on the Tx path */
+	clone = skb_clone_sk(skb);
+	if (!clone)
+		return;
+
+	FM10K_CB(clone)->ts_tx_timeout = jiffies + FM10K_TS_TX_TIMEOUT;
+	dglort = FM10K_CB(clone)->fi.w.dglort;
+
+	spin_lock_irqsave(&list->lock, flags);
+
+	/* attempt to locate any buffers with the same dglort,
+	 * if none are present then insert skb in tail of list
+	 */
+	skb = fm10k_ts_tx_skb(interface, FM10K_CB(clone)->fi.w.dglort);
+	if (!skb)
+		__skb_queue_tail(list, clone);
+
+	spin_unlock_irqrestore(&list->lock, flags);
+
+	/* if list is already has one then we just free the clone */
+	if (skb)
+		kfree_skb(skb);
+	else
+		skb_shinfo(clone)->tx_flags |= SKBTX_IN_PROGRESS;
+}
+
+void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
+			  u64 systime)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
+	struct sk_buff *skb;
+	unsigned long flags;
+
+	spin_lock_irqsave(&list->lock, flags);
+
+	/* attempt to locate and pull the sk_buff out of the list */
+	skb = fm10k_ts_tx_skb(interface, dglort);
+	if (skb)
+		__skb_unlink(skb, list);
+
+	spin_unlock_irqrestore(&list->lock, flags);
+
+	/* if not found do nothing */
+	if (!skb)
+		return;
+
+	/* timestamp the sk_buff and return it to the socket */
+	fm10k_systime_to_hwtstamp(interface, &shhwtstamps, systime);
+	skb_complete_tx_timestamp(skb, &shhwtstamps);
+}
+
+void fm10k_ts_tx_subtask(struct fm10k_intfc *interface)
+{
+	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
+	struct sk_buff *skb, *tmp;
+	unsigned long flags;
+
+	/* If we're down or resetting, just bail */
+	if (test_bit(__FM10K_DOWN, &interface->state) ||
+	    test_bit(__FM10K_RESETTING, &interface->state))
+		return;
+
+	spin_lock_irqsave(&list->lock, flags);
+
+	/* walk though the list and flush any expired timestamp packets */
+	skb_queue_walk_safe(list, skb, tmp) {
+		if (!time_is_after_jiffies(FM10K_CB(skb)->ts_tx_timeout))
+			continue;
+		__skb_unlink(skb, list);
+		kfree_skb(skb);
+		interface->tx_hwtstamp_timeouts++;
+	}
+
+	spin_unlock_irqrestore(&list->lock, flags);
+}
+
+static u64 fm10k_systime_read(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+
+	return hw->mac.ops.read_systime(hw);
+}
+
+void fm10k_ts_reset(struct fm10k_intfc *interface)
+{
+	s64 ns = ktime_to_ns(ktime_get_real());
+	unsigned long flags;
+
+	/* reinitialize the clock */
+	write_lock_irqsave(&interface->systime_lock, flags);
+	interface->ptp_adjust = fm10k_systime_read(interface) - ns;
+	write_unlock_irqrestore(&interface->systime_lock, flags);
+}
+
+void fm10k_ts_init(struct fm10k_intfc *interface)
+{
+	/* Initialize lock protecting systime access */
+	rwlock_init(&interface->systime_lock);
+
+	/* Initialize skb queue for pending timestamp requests */
+	skb_queue_head_init(&interface->ts_tx_skb_queue);
+
+	/* reset the clock to current kernel time */
+	fm10k_ts_reset(interface);
+}
+
+/**
+ * fm10k_get_ts_config - get current hardware timestamping configuration
+ * @netdev: network interface device structure
+ * @ifreq: ioctl data
+ *
+ * This function returns the current timestamping settings. Rather than
+ * attempt to deconstruct registers to fill in the values, simply keep a copy
+ * of the old settings around, and return a copy when requested.
+ */
+int fm10k_get_ts_config(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct hwtstamp_config *config = &interface->ts_config;
+
+	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
+		-EFAULT : 0;
+}
+
+/**
+ * fm10k_set_ts_config - control hardware time stamping
+ * @netdev: network interface device structure
+ * @ifreq: ioctl data
+ *
+ * Outgoing time stamping can be enabled and disabled. Play nice and
+ * disable it when requested, although it shouldn't cause any overhead
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
+ * Since hardware always timestamps Path delay packets when timestamping V2
+ * packets, regardless of the type specified in the register, only use V2
+ * Event mode. This more accurately tells the user what the hardware is going
+ * to do anyways.
+ */
+int fm10k_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct hwtstamp_config ts_config;
+
+	if (copy_from_user(&ts_config, ifr->ifr_data, sizeof(ts_config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (ts_config.flags)
+		return -EINVAL;
+
+	switch (ts_config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+	case HWTSTAMP_TX_ON:
+		/* we likely need some check here to see if this is supported */
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (ts_config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		interface->flags &= ~FM10K_FLAG_RX_TS_ENABLED;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_ALL:
+		interface->flags |= FM10K_FLAG_RX_TS_ENABLED;
+		ts_config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	/* save these settings for future reference */
+	interface->ts_config = ts_config;
+
+	return copy_to_user(ifr->ifr_data, &ts_config, sizeof(ts_config)) ?
+		-EFAULT : 0;
+}
+
+static int fm10k_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct fm10k_intfc *interface;
+	struct fm10k_hw *hw;
+	int err;
+
+	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
+	hw = &interface->hw;
+
+	err = hw->mac.ops.adjust_systime(hw, ppb);
+
+	/* the only error we should see is if the value is out of range */
+	return (err == FM10K_ERR_PARAM) ? -ERANGE : err;
+}
+
+static int fm10k_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct fm10k_intfc *interface;
+	unsigned long flags;
+
+	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
+
+	write_lock_irqsave(&interface->systime_lock, flags);
+	interface->ptp_adjust += delta;
+	write_unlock_irqrestore(&interface->systime_lock, flags);
+
+	return 0;
+}
+
+static int fm10k_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct fm10k_intfc *interface;
+	unsigned long flags;
+	u64 now;
+
+	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
+
+	read_lock_irqsave(&interface->systime_lock, flags);
+	now = fm10k_systime_read(interface) + interface->ptp_adjust;
+	read_unlock_irqrestore(&interface->systime_lock, flags);
+
+	*ts = ns_to_timespec(now);
+
+	return 0;
+}
+
+static int fm10k_ptp_settime(struct ptp_clock_info *ptp,
+			     const struct timespec *ts)
+{
+	struct fm10k_intfc *interface;
+	unsigned long flags;
+	u64 ns = timespec_to_ns(ts);
+
+	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
+
+	write_lock_irqsave(&interface->systime_lock, flags);
+	interface->ptp_adjust = fm10k_systime_read(interface) - ns;
+	write_unlock_irqrestore(&interface->systime_lock, flags);
+
+	return 0;
+}
+
+static int fm10k_ptp_enable(struct ptp_clock_info *ptp,
+			    struct ptp_clock_request *rq, int on)
+{
+	struct ptp_clock_time *t = &rq->perout.period;
+	struct fm10k_intfc *interface;
+	struct fm10k_hw *hw;
+	u64 period;
+	u32 step;
+
+	/* we can only support periodic output */
+	if (rq->type != PTP_CLK_REQ_PEROUT)
+		return -EINVAL;
+
+	/* verify the requested channel is there */
+	if (rq->perout.index >= ptp->n_per_out)
+		return -EINVAL;
+
+	/* we cannot enforce start time as there is no
+	 * mechanism for that in the hardware, we can only control
+	 * the period.
+	 */
+
+	/* we cannot support periods greater than 4 seconds due to reg limit */
+	if (t->sec > 4 || t->sec < 0)
+		return -ERANGE;
+
+	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
+	hw = &interface->hw;
+
+	/* we simply cannot support the operation if we don't have BAR4 */
+	if (!hw->sw_addr)
+		return -ENOTSUPP;
+
+	/* convert to unsigned 64b ns, verify we can put it in a 32b register */
+	period = t->sec * 1000000000LL + t->nsec;
+
+	/* determine the minimum size for period */
+	step = 2 * (fm10k_read_reg(hw, FM10K_SYSTIME_CFG) &
+		    FM10K_SYSTIME_CFG_STEP_MASK);
+
+	/* verify the value is in range supported by hardware */
+	if ((period && (period < step)) || (period > U32_MAX))
+		return -ERANGE;
+
+	/* notify hardware of request to being sending pulses */
+	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_PULSE(rq->perout.index),
+			   (u32)period);
+
+	return 0;
+}
+
+static struct ptp_pin_desc fm10k_ptp_pd[2] = {
+	{
+		.name = "IEEE1588_PULSE0",
+		.index = 0,
+		.func = PTP_PF_PEROUT,
+		.chan = 0
+	},
+	{
+		.name = "IEEE1588_PULSE1",
+		.index = 1,
+		.func = PTP_PF_PEROUT,
+		.chan = 1
+	}
+};
+
+static int fm10k_ptp_verify(struct ptp_clock_info *ptp, unsigned int pin,
+			    enum ptp_pin_function func, unsigned int chan)
+{
+	/* verify the requested pin is there */
+	if (pin >= ptp->n_pins || !ptp->pin_config)
+		return -EINVAL;
+
+	/* enforce locked channels, no changing them */
+	if (chan != ptp->pin_config[pin].chan)
+		return -EINVAL;
+
+	/* we want to keep the functions locked as well */
+	if (func != ptp->pin_config[pin].func)
+		return -EINVAL;
+
+	return 0;
+}
+
+void fm10k_ptp_register(struct fm10k_intfc *interface)
+{
+	struct ptp_clock_info *ptp_caps = &interface->ptp_caps;
+	struct device *dev = &interface->pdev->dev;
+	struct ptp_clock *ptp_clock;
+
+	snprintf(ptp_caps->name, sizeof(ptp_caps->name),
+		 "%s", interface->netdev->name);
+	ptp_caps->owner		= THIS_MODULE;
+	/* This math is simply the inverse of the math in
+	 * fm10k_adjust_systime_pf applied to an adjustment value
+	 * of 2^30 - 1 which is the maximum value of the register:
+	 * 	max_ppb == ((2^30 - 1) * 5^9) / 2^31
+	 */
+	ptp_caps->max_adj	= 976562;
+	ptp_caps->adjfreq	= fm10k_ptp_adjfreq;
+	ptp_caps->adjtime	= fm10k_ptp_adjtime;
+	ptp_caps->gettime	= fm10k_ptp_gettime;
+	ptp_caps->settime	= fm10k_ptp_settime;
+
+	/* provide pins if BAR4 is accessible */
+	if (interface->sw_addr) {
+		/* enable periodic outputs */
+		ptp_caps->n_per_out = 2;
+		ptp_caps->enable	= fm10k_ptp_enable;
+
+		/* enable clock pins */
+		ptp_caps->verify	= fm10k_ptp_verify;
+		ptp_caps->n_pins = 2;
+		ptp_caps->pin_config = fm10k_ptp_pd;
+	}
+
+	ptp_clock = ptp_clock_register(ptp_caps, dev);
+	if (IS_ERR(ptp_clock)) {
+		ptp_clock = NULL;
+		dev_err(dev, "ptp_clock_register failed\n");
+	} else {
+		dev_info(dev, "registered PHC device %s\n", ptp_caps->name);
+	}
+
+	interface->ptp_clock = ptp_clock;
+}
+
+void fm10k_ptp_unregister(struct fm10k_intfc *interface)
+{
+	struct ptp_clock *ptp_clock = interface->ptp_clock;
+	struct device *dev = &interface->pdev->dev;
+
+	if (!ptp_clock)
+		return;
+
+	interface->ptp_clock = NULL;
+
+	ptp_clock_unregister(ptp_clock);
+	dev_info(dev, "removed PHC %s\n", interface->ptp_caps.name);
+}
-- 
1.9.3
