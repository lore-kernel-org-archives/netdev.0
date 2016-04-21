From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] fm10k: drop 1588 support
Date: Wed, 20 Apr 2016 23:09:18 -0700
Message-ID: <1461218969-68578-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbcDUGJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:33 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The 1588 support within fm10k does not work correctly with the current
version of the switch management software, and likely never worked
correctly to begin with. Remove support for PTP/1588. Update copyright
year for all these files while we're touching them.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile        |   3 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  34 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c |  30 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  22 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  22 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 110 +-----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 101 +----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      |  17 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     | 462 -----------------------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  17 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  57 +--
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      |  12 +-
 12 files changed, 11 insertions(+), 876 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index b006ff6..2aeaa39 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel Ethernet Switch Host Interface Driver
-# Copyright(c) 2013 - 2015 Intel Corporation.
+# Copyright(c) 2013 - 2016 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
@@ -30,7 +30,6 @@ obj-$(CONFIG_FM10K) += fm10k.o
 fm10k-y := fm10k_main.o \
 	   fm10k_common.o \
 	   fm10k_pci.o \
-	   fm10k_ptp.o \
 	   fm10k_netdev.o \
 	   fm10k_ethtool.o \
 	   fm10k_pf.o \
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 9c7fafe..c21fa86 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -27,9 +27,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
-#include <linux/net_tstamp.h>
-#include <linux/clocksource.h>
-#include <linux/ptp_clock_kernel.h>
 
 #include "fm10k_pf.h"
 #include "fm10k_vf.h"
@@ -342,22 +339,8 @@ struct fm10k_intfc {
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbg_intfc;
-
 #endif /* CONFIG_DEBUG_FS */
-	struct ptp_clock_info ptp_caps;
-	struct ptp_clock *ptp_clock;
-
-	struct sk_buff_head ts_tx_skb_queue;
-	u32 tx_hwtstamp_timeouts;
 
-	struct hwtstamp_config ts_config;
-	/* We are unable to actually adjust the clock beyond the frequency
-	 * value.  Once the clock is started there is no resetting it.  As
-	 * such we maintain a separate offset from the actual hardware clock
-	 * to allow for offset adjustment.
-	 */
-	s64 ptp_adjust;
-	rwlock_t systime_lock;
 #ifdef CONFIG_DCB
 	u8 pfc_en;
 #endif
@@ -546,21 +529,6 @@ static inline void fm10k_dbg_init(void) {}
 static inline void fm10k_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS */
 
-/* Time Stamping */
-void fm10k_systime_to_hwtstamp(struct fm10k_intfc *interface,
-			       struct skb_shared_hwtstamps *hwtstamp,
-			       u64 systime);
-void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb);
-void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
-			  u64 systime);
-void fm10k_ts_reset(struct fm10k_intfc *interface);
-void fm10k_ts_init(struct fm10k_intfc *interface);
-void fm10k_ts_tx_subtask(struct fm10k_intfc *interface);
-void fm10k_ptp_register(struct fm10k_intfc *interface);
-void fm10k_ptp_unregister(struct fm10k_intfc *interface);
-int fm10k_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
-int fm10k_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
-
 /* DCB */
 #ifdef CONFIG_DCB
 void fm10k_dcbnl_set_ops(struct net_device *dev);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 6ab9df5..ca276c0 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -77,8 +77,6 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("mac_rules_avail", hw.swapi.mac.avail),
 
 	FM10K_STAT("tx_hang_count", tx_timeout_count),
-
-	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
 static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
@@ -1140,31 +1138,6 @@ static int fm10k_set_channels(struct net_device *dev,
 	return fm10k_setup_tc(dev, netdev_get_num_tc(dev));
 }
 
-static int fm10k_get_ts_info(struct net_device *dev,
-			     struct ethtool_ts_info *info)
-{
-	struct fm10k_intfc *interface = netdev_priv(dev);
-
-	info->so_timestamping =
-		SOF_TIMESTAMPING_TX_SOFTWARE |
-		SOF_TIMESTAMPING_RX_SOFTWARE |
-		SOF_TIMESTAMPING_SOFTWARE |
-		SOF_TIMESTAMPING_TX_HARDWARE |
-		SOF_TIMESTAMPING_RX_HARDWARE |
-		SOF_TIMESTAMPING_RAW_HARDWARE;
-
-	if (interface->ptp_clock)
-		info->phc_index = ptp_clock_index(interface->ptp_clock);
-	else
-		info->phc_index = -1;
-
-	info->tx_types = BIT(HWTSTAMP_TX_OFF) | BIT(HWTSTAMP_TX_ON);
-
-	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE) | BIT(HWTSTAMP_FILTER_ALL);
-
-	return 0;
-}
-
 static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_strings		= fm10k_get_strings,
 	.get_sset_count		= fm10k_get_sset_count,
@@ -1192,7 +1165,6 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.set_rxfh		= fm10k_set_rssh,
 	.get_channels		= fm10k_get_channels,
 	.set_channels		= fm10k_set_channels,
-	.get_ts_info            = fm10k_get_ts_info,
 };
 
 void fm10k_set_ethtool_ops(struct net_device *dev)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index ca5b9d7..58092e5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -424,19 +424,6 @@ static inline void fm10k_rx_hash(struct fm10k_ring *ring,
 		     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 }
 
-static void fm10k_rx_hwtstamp(struct fm10k_ring *rx_ring,
-			      union fm10k_rx_desc *rx_desc,
-			      struct sk_buff *skb)
-{
-	struct fm10k_intfc *interface = rx_ring->q_vector->interface;
-
-	FM10K_CB(skb)->tstamp = rx_desc->q.timestamp;
-
-	if (unlikely(interface->flags & FM10K_FLAG_RX_TS_ENABLED))
-		fm10k_systime_to_hwtstamp(interface, skb_hwtstamps(skb),
-					  le64_to_cpu(rx_desc->q.timestamp));
-}
-
 static void fm10k_type_trans(struct fm10k_ring *rx_ring,
 			     union fm10k_rx_desc __maybe_unused *rx_desc,
 			     struct sk_buff *skb)
@@ -486,8 +473,6 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 
 	fm10k_rx_checksum(rx_ring, rx_desc, skb);
 
-	fm10k_rx_hwtstamp(rx_ring, rx_desc, skb);
-
 	FM10K_CB(skb)->fi.w.vlan = rx_desc->w.vlan;
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
@@ -912,11 +897,6 @@ static u8 fm10k_tx_desc_flags(struct sk_buff *skb, u32 tx_flags)
 	/* set type for advanced descriptor with frame checksum insertion */
 	u32 desc_flags = 0;
 
-	/* set timestamping bits */
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-	    likely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
-		desc_flags |= FM10K_TXD_FLAG_TIME;
-
 	/* set checksum offload bits */
 	desc_flags |= FM10K_SET_FLAG(tx_flags, FM10K_TX_FLAGS_CSUM,
 				     FM10K_TXD_FLAG_CSUM);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 1d0f058..32778dd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -243,9 +243,6 @@ void fm10k_clean_all_tx_rings(struct fm10k_intfc *interface)
 
 	for (i = 0; i < interface->num_tx_queues; i++)
 		fm10k_clean_tx_ring(interface->tx_ring[i]);
-
-	/* remove any stale timestamp buffers and free them */
-	skb_queue_purge(&interface->ts_tx_skb_queue);
 }
 
 /**
@@ -660,10 +657,6 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 		__skb_put(skb, pad_len);
 	}
 
-	/* prepare packet for hardware time stamping */
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
-		fm10k_ts_tx_enqueue(interface, skb);
-
 	if (r_idx >= interface->num_tx_queues)
 		r_idx %= interface->num_tx_queues;
 
@@ -1213,18 +1206,6 @@ static int __fm10k_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	return fm10k_setup_tc(dev, tc->tc);
 }
 
-static int fm10k_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	switch (cmd) {
-	case SIOCGHWTSTAMP:
-		return fm10k_get_ts_config(netdev, ifr);
-	case SIOCSHWTSTAMP:
-		return fm10k_set_ts_config(netdev, ifr);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
 static void fm10k_assign_l2_accel(struct fm10k_intfc *interface,
 				  struct fm10k_l2_accel *l2_accel)
 {
@@ -1402,7 +1383,6 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
 	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
 	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
-	.ndo_do_ioctl		= fm10k_ioctl,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index a604513..29e9402 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -209,9 +209,6 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 			netdev->features |= NETIF_F_HW_VLAN_CTAG_RX;
 	}
 
-	/* reset clock */
-	fm10k_ts_reset(interface);
-
 	err = netif_running(netdev) ? fm10k_open(netdev) : 0;
 	if (err)
 		goto err_open;
@@ -559,7 +556,6 @@ static void fm10k_service_task(struct work_struct *work)
 	/* tasks only run when interface is up */
 	fm10k_watchdog_subtask(interface);
 	fm10k_check_hang_subtask(interface);
-	fm10k_ts_tx_subtask(interface);
 
 	/* release lock on service events to allow scheduling next event */
 	fm10k_service_event_complete(interface);
@@ -1204,25 +1200,6 @@ static s32 fm10k_mbx_mac_addr(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
-static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
-			     struct fm10k_mbx_info __always_unused *mbx)
-{
-	struct fm10k_intfc *interface;
-	u64 timestamp;
-	s32 err;
-
-	err = fm10k_tlv_attr_get_u64(results[FM10K_1588_MSG_TIMESTAMP],
-				     &timestamp);
-	if (err)
-		return err;
-
-	interface = container_of(hw, struct fm10k_intfc, hw);
-
-	fm10k_ts_tx_hwtstamp(interface, 0, timestamp);
-
-	return 0;
-}
-
 /* generic error handler for mailbox issues */
 static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
 			   struct fm10k_mbx_info __always_unused *mbx)
@@ -1243,7 +1220,6 @@ static const struct fm10k_msg_data vf_mbx_data[] = {
 	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
 	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_mbx_mac_addr),
 	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_msg_lport_state_vf),
-	FM10K_VF_MSG_1588_HANDLER(fm10k_1588_msg_vf),
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
 };
 
@@ -1341,68 +1317,6 @@ static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
-static s32 fm10k_1588_msg_pf(struct fm10k_hw *hw, u32 **results,
-			     struct fm10k_mbx_info __always_unused *mbx)
-{
-	struct fm10k_swapi_1588_timestamp timestamp;
-	struct fm10k_iov_data *iov_data;
-	struct fm10k_intfc *interface;
-	u16 sglort, vf_idx;
-	s32 err;
-
-	err = fm10k_tlv_attr_get_le_struct(
-				results[FM10K_PF_ATTR_ID_1588_TIMESTAMP],
-				&timestamp, sizeof(timestamp));
-	if (err)
-		return err;
-
-	interface = container_of(hw, struct fm10k_intfc, hw);
-
-	if (timestamp.dglort) {
-		fm10k_ts_tx_hwtstamp(interface, timestamp.dglort,
-				     le64_to_cpu(timestamp.egress));
-		return 0;
-	}
-
-	/* either dglort or sglort must be set */
-	if (!timestamp.sglort)
-		return FM10K_ERR_PARAM;
-
-	/* verify GLORT is at least one of the ones we own */
-	sglort = le16_to_cpu(timestamp.sglort);
-	if (!fm10k_glort_valid_pf(hw, sglort))
-		return FM10K_ERR_PARAM;
-
-	if (sglort == interface->glort) {
-		fm10k_ts_tx_hwtstamp(interface, 0,
-				     le64_to_cpu(timestamp.ingress));
-		return 0;
-	}
-
-	/* if there is no iov_data then there is no mailbox to process */
-	if (!ACCESS_ONCE(interface->iov_data))
-		return FM10K_ERR_PARAM;
-
-	rcu_read_lock();
-
-	/* notify VF if this timestamp belongs to it */
-	iov_data = interface->iov_data;
-	vf_idx = (hw->mac.dglort_map & FM10K_DGLORTMAP_NONE) - sglort;
-
-	if (!iov_data || vf_idx >= iov_data->num_vfs) {
-		err = FM10K_ERR_PARAM;
-		goto err_unlock;
-	}
-
-	err = hw->iov.ops.report_timestamp(hw, &iov_data->vf_info[vf_idx],
-					   le64_to_cpu(timestamp.ingress));
-
-err_unlock:
-	rcu_read_unlock();
-
-	return err;
-}
-
 static const struct fm10k_msg_data pf_mbx_data[] = {
 	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
@@ -1410,7 +1324,6 @@ static const struct fm10k_msg_data pf_mbx_data[] = {
 	FM10K_PF_MSG_ERR_HANDLER(LPORT_CREATE, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(LPORT_DELETE, fm10k_msg_err_pf),
 	FM10K_PF_MSG_UPDATE_PVID_HANDLER(fm10k_update_pvid),
-	FM10K_PF_MSG_1588_TIMESTAMP_HANDLER(fm10k_1588_msg_pf),
 	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
 };
 
@@ -1789,18 +1702,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		return -EIO;
 	}
 
-	/* assign BAR 4 resources for use with PTP */
-	if (fm10k_read_reg(hw, FM10K_CTRL) & FM10K_CTRL_BAR4_ALLOWED)
-		interface->sw_addr = ioremap(pci_resource_start(pdev, 4),
-					     pci_resource_len(pdev, 4));
-	hw->sw_addr = interface->sw_addr;
-
 	/* initialize DCBNL interface */
 	fm10k_dcbnl_set_ops(netdev);
 
-	/* Intitialize timestamp data */
-	fm10k_ts_init(interface);
-
 	/* set default ring sizes */
 	interface->tx_ring_count = FM10K_DEFAULT_TXD;
 	interface->rx_ring_count = FM10K_DEFAULT_RXD;
@@ -2018,9 +1922,6 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* kick off service timer now, even when interface is down */
 	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
 
-	/* Register PTP interface */
-	fm10k_ptp_register(interface);
-
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
 
@@ -2077,9 +1978,6 @@ static void fm10k_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
-	/* cleanup timestamp handling */
-	fm10k_ptp_unregister(interface);
-
 	/* release VFs */
 	fm10k_iov_disable(pdev);
 
@@ -2152,9 +2050,6 @@ static int fm10k_resume(struct pci_dev *pdev)
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
 
-	/* reset clock */
-	fm10k_ts_reset(interface);
-
 	rtnl_lock();
 
 	err = fm10k_init_queueing_scheme(interface);
@@ -2365,9 +2260,6 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reassociate interrupts */
 	fm10k_mbx_request_irq(interface);
 
-	/* reset clock */
-	fm10k_ts_reset(interface);
-
 	if (netif_running(netdev))
 		err = fm10k_open(netdev);
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index ecc99f9..c8e8ce5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1140,19 +1140,6 @@ static void fm10k_iov_update_stats_pf(struct fm10k_hw *hw,
 	fm10k_update_hw_stats_q(hw, q, idx, qpp);
 }
 
-static s32 fm10k_iov_report_timestamp_pf(struct fm10k_hw *hw,
-					 struct fm10k_vf_info *vf_info,
-					 u64 timestamp)
-{
-	u32 msg[4];
-
-	/* generate port state response to notify VF it is not ready */
-	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_1588);
-	fm10k_tlv_attr_put_u64(msg, FM10K_1588_MSG_TIMESTAMP, timestamp);
-
-	return vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
-}
-
 /**
  *  fm10k_iov_msg_msix_pf - Message handler for MSI-X request from VF
  *  @hw: Pointer to hardware structure
@@ -1773,89 +1760,6 @@ s32 fm10k_msg_err_pf(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
-const struct fm10k_tlv_attr fm10k_1588_timestamp_msg_attr[] = {
-	FM10K_TLV_ATTR_LE_STRUCT(FM10K_PF_ATTR_ID_1588_TIMESTAMP,
-				 sizeof(struct fm10k_swapi_1588_timestamp)),
-	FM10K_TLV_ATTR_LAST
-};
-
-/* currently there is no shared 1588 timestamp handler */
-
-/**
- *  fm10k_adjust_systime_pf - Adjust systime frequency
- *  @hw: pointer to hardware structure
- *  @ppb: adjustment rate in parts per billion
- *
- *  This function will adjust the SYSTIME_CFG register contained in BAR 4
- *  if this function is supported for BAR 4 access.  The adjustment amount
- *  is based on the parts per billion value provided and adjusted to a
- *  value based on parts per 2^48 clock cycles.
- *
- *  If adjustment is not supported or the requested value is too large
- *  we will return an error.
- **/
-static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
-{
-	u64 systime_adjust;
-
-	/* if sw_addr is not set we don't have switch register access */
-	if (!hw->sw_addr)
-		return ppb ? FM10K_ERR_PARAM : 0;
-
-	/* we must convert the value from parts per billion to parts per
-	 * 2^48 cycles.  In addition I have opted to only use the 30 most
-	 * significant bits of the adjustment value as the 8 least
-	 * significant bits are located in another register and represent
-	 * a value significantly less than a part per billion, the result
-	 * of dropping the 8 least significant bits is that the adjustment
-	 * value is effectively multiplied by 2^8 when we write it.
-	 *
-	 * As a result of all this the math for this breaks down as follows:
-	 *	ppb / 10^9 == adjust * 2^8 / 2^48
-	 * If we solve this for adjust, and simplify it comes out as:
-	 *	ppb * 2^31 / 5^9 == adjust
-	 */
-	systime_adjust = (ppb < 0) ? -ppb : ppb;
-	systime_adjust <<= 31;
-	do_div(systime_adjust, 1953125);
-
-	/* verify the requested adjustment value is in range */
-	if (systime_adjust > FM10K_SW_SYSTIME_ADJUST_MASK)
-		return FM10K_ERR_PARAM;
-
-	if (ppb > 0)
-		systime_adjust |= FM10K_SW_SYSTIME_ADJUST_DIR_POSITIVE;
-
-	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_ADJUST, (u32)systime_adjust);
-
-	return 0;
-}
-
-/**
- *  fm10k_read_systime_pf - Reads value of systime registers
- *  @hw: pointer to the hardware structure
- *
- *  Function reads the content of 2 registers, combined to represent a 64 bit
- *  value measured in nanosecods.  In order to guarantee the value is accurate
- *  we check the 32 most significant bits both before and after reading the
- *  32 least significant bits to verify they didn't change as we were reading
- *  the registers.
- **/
-static u64 fm10k_read_systime_pf(struct fm10k_hw *hw)
-{
-	u32 systime_l, systime_h, systime_tmp;
-
-	systime_h = fm10k_read_reg(hw, FM10K_SYSTIME + 1);
-
-	do {
-		systime_tmp = systime_h;
-		systime_l = fm10k_read_reg(hw, FM10K_SYSTIME);
-		systime_h = fm10k_read_reg(hw, FM10K_SYSTIME + 1);
-	} while (systime_tmp != systime_h);
-
-	return ((u64)systime_h << 32) | systime_l;
-}
-
 static const struct fm10k_msg_data fm10k_msg_data_pf[] = {
 	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
 	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
@@ -1885,8 +1789,6 @@ static const struct fm10k_mac_ops mac_ops_pf = {
 	.set_dma_mask		= fm10k_set_dma_mask_pf,
 	.get_fault		= fm10k_get_fault_pf,
 	.get_host_state		= fm10k_get_host_state_pf,
-	.adjust_systime		= fm10k_adjust_systime_pf,
-	.read_systime		= fm10k_read_systime_pf,
 };
 
 static const struct fm10k_iov_ops iov_ops_pf = {
@@ -1898,7 +1800,6 @@ static const struct fm10k_iov_ops iov_ops_pf = {
 	.set_lport			= fm10k_iov_set_lport_pf,
 	.reset_lport			= fm10k_iov_reset_lport_pf,
 	.update_stats			= fm10k_iov_update_stats_pf,
-	.report_timestamp		= fm10k_iov_report_timestamp_pf,
 };
 
 static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index b2d96b4..b78210d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -42,8 +42,6 @@ enum fm10k_pf_tlv_msg_id_v1 {
 	FM10K_PF_MSG_ID_UPDATE_FLOW		= 0x503,
 	FM10K_PF_MSG_ID_DELETE_FLOW		= 0x504,
 	FM10K_PF_MSG_ID_SET_FLOW_STATE		= 0x505,
-	FM10K_PF_MSG_ID_GET_1588_INFO		= 0x506,
-	FM10K_PF_MSG_ID_1588_TIMESTAMP		= 0x701,
 };
 
 enum fm10k_pf_tlv_attr_id_v1 {
@@ -61,7 +59,6 @@ enum fm10k_pf_tlv_attr_id_v1 {
 	FM10K_PF_ATTR_ID_DELETE_FLOW		= 0x0B,
 	FM10K_PF_ATTR_ID_PORT			= 0x0C,
 	FM10K_PF_ATTR_ID_UPDATE_PVID		= 0x0D,
-	FM10K_PF_ATTR_ID_1588_TIMESTAMP		= 0x10,
 };
 
 #define FM10K_MSG_LPORT_MAP_GLORT_SHIFT	0
@@ -100,13 +97,6 @@ struct fm10k_swapi_error {
 	struct fm10k_global_table_data	ffu;
 } __aligned(4) __packed;
 
-struct fm10k_swapi_1588_timestamp {
-	__le64 egress;
-	__le64 ingress;
-	__le16 dglort;
-	__le16 sglort;
-} __aligned(4) __packed;
-
 s32 fm10k_msg_lport_map_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
 extern const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[];
 #define FM10K_PF_MSG_LPORT_MAP_HANDLER(func) \
@@ -122,11 +112,6 @@ extern const struct fm10k_tlv_attr fm10k_err_msg_attr[];
 #define FM10K_PF_MSG_ERR_HANDLER(msg, func) \
 	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_##msg, fm10k_err_msg_attr, func)
 
-extern const struct fm10k_tlv_attr fm10k_1588_timestamp_msg_attr[];
-#define FM10K_PF_MSG_1588_TIMESTAMP_HANDLER(func) \
-	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_1588_TIMESTAMP, \
-			  fm10k_1588_timestamp_msg_attr, func)
-
 s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
 s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *, u32 **,
 			      struct fm10k_mbx_info *);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
deleted file mode 100644
index 1c1ccad..0000000
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ /dev/null
@@ -1,462 +0,0 @@
-/* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * The full GNU General Public License is included in this distribution in
- * the file called "COPYING".
- *
- * Contact Information:
- * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
- * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
- */
-
-#include <linux/ptp_classify.h>
-#include <linux/ptp_clock_kernel.h>
-
-#include "fm10k.h"
-
-#define FM10K_TS_TX_TIMEOUT		(HZ * 15)
-
-void fm10k_systime_to_hwtstamp(struct fm10k_intfc *interface,
-			       struct skb_shared_hwtstamps *hwtstamp,
-			       u64 systime)
-{
-	unsigned long flags;
-
-	read_lock_irqsave(&interface->systime_lock, flags);
-	systime += interface->ptp_adjust;
-	read_unlock_irqrestore(&interface->systime_lock, flags);
-
-	hwtstamp->hwtstamp = ns_to_ktime(systime);
-}
-
-static struct sk_buff *fm10k_ts_tx_skb(struct fm10k_intfc *interface,
-				       __le16 dglort)
-{
-	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
-	struct sk_buff *skb;
-
-	skb_queue_walk(list, skb) {
-		if (FM10K_CB(skb)->fi.w.dglort == dglort)
-			return skb;
-	}
-
-	return NULL;
-}
-
-void fm10k_ts_tx_enqueue(struct fm10k_intfc *interface, struct sk_buff *skb)
-{
-	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
-	struct sk_buff *clone;
-	unsigned long flags;
-
-	/* create clone for us to return on the Tx path */
-	clone = skb_clone_sk(skb);
-	if (!clone)
-		return;
-
-	FM10K_CB(clone)->ts_tx_timeout = jiffies + FM10K_TS_TX_TIMEOUT;
-	spin_lock_irqsave(&list->lock, flags);
-
-	/* attempt to locate any buffers with the same dglort,
-	 * if none are present then insert skb in tail of list
-	 */
-	skb = fm10k_ts_tx_skb(interface, FM10K_CB(clone)->fi.w.dglort);
-	if (!skb) {
-		skb_shinfo(clone)->tx_flags |= SKBTX_IN_PROGRESS;
-		__skb_queue_tail(list, clone);
-	}
-
-	spin_unlock_irqrestore(&list->lock, flags);
-
-	/* if list is already has one then we just free the clone */
-	if (skb)
-		dev_kfree_skb(clone);
-}
-
-void fm10k_ts_tx_hwtstamp(struct fm10k_intfc *interface, __le16 dglort,
-			  u64 systime)
-{
-	struct skb_shared_hwtstamps shhwtstamps;
-	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
-	struct sk_buff *skb;
-	unsigned long flags;
-
-	spin_lock_irqsave(&list->lock, flags);
-
-	/* attempt to locate and pull the sk_buff out of the list */
-	skb = fm10k_ts_tx_skb(interface, dglort);
-	if (skb)
-		__skb_unlink(skb, list);
-
-	spin_unlock_irqrestore(&list->lock, flags);
-
-	/* if not found do nothing */
-	if (!skb)
-		return;
-
-	/* timestamp the sk_buff and free out copy */
-	fm10k_systime_to_hwtstamp(interface, &shhwtstamps, systime);
-	skb_tstamp_tx(skb, &shhwtstamps);
-	dev_kfree_skb_any(skb);
-}
-
-void fm10k_ts_tx_subtask(struct fm10k_intfc *interface)
-{
-	struct sk_buff_head *list = &interface->ts_tx_skb_queue;
-	struct sk_buff *skb, *tmp;
-	unsigned long flags;
-
-	/* If we're down or resetting, just bail */
-	if (test_bit(__FM10K_DOWN, &interface->state) ||
-	    test_bit(__FM10K_RESETTING, &interface->state))
-		return;
-
-	spin_lock_irqsave(&list->lock, flags);
-
-	/* walk though the list and flush any expired timestamp packets */
-	skb_queue_walk_safe(list, skb, tmp) {
-		if (!time_is_after_jiffies(FM10K_CB(skb)->ts_tx_timeout))
-			continue;
-		__skb_unlink(skb, list);
-		kfree_skb(skb);
-		interface->tx_hwtstamp_timeouts++;
-	}
-
-	spin_unlock_irqrestore(&list->lock, flags);
-}
-
-static u64 fm10k_systime_read(struct fm10k_intfc *interface)
-{
-	struct fm10k_hw *hw = &interface->hw;
-
-	return hw->mac.ops.read_systime(hw);
-}
-
-void fm10k_ts_reset(struct fm10k_intfc *interface)
-{
-	s64 ns = ktime_to_ns(ktime_get_real());
-	unsigned long flags;
-
-	/* reinitialize the clock */
-	write_lock_irqsave(&interface->systime_lock, flags);
-	interface->ptp_adjust = fm10k_systime_read(interface) - ns;
-	write_unlock_irqrestore(&interface->systime_lock, flags);
-}
-
-void fm10k_ts_init(struct fm10k_intfc *interface)
-{
-	/* Initialize lock protecting systime access */
-	rwlock_init(&interface->systime_lock);
-
-	/* Initialize skb queue for pending timestamp requests */
-	skb_queue_head_init(&interface->ts_tx_skb_queue);
-
-	/* reset the clock to current kernel time */
-	fm10k_ts_reset(interface);
-}
-
-/**
- * fm10k_get_ts_config - get current hardware timestamping configuration
- * @netdev: network interface device structure
- * @ifreq: ioctl data
- *
- * This function returns the current timestamping settings. Rather than
- * attempt to deconstruct registers to fill in the values, simply keep a copy
- * of the old settings around, and return a copy when requested.
- */
-int fm10k_get_ts_config(struct net_device *netdev, struct ifreq *ifr)
-{
-	struct fm10k_intfc *interface = netdev_priv(netdev);
-	struct hwtstamp_config *config = &interface->ts_config;
-
-	return copy_to_user(ifr->ifr_data, config, sizeof(*config)) ?
-		-EFAULT : 0;
-}
-
-/**
- * fm10k_set_ts_config - control hardware time stamping
- * @netdev: network interface device structure
- * @ifreq: ioctl data
- *
- * Outgoing time stamping can be enabled and disabled. Play nice and
- * disable it when requested, although it shouldn't cause any overhead
- * when no packet needs it. At most one packet in the queue may be
- * marked for time stamping, otherwise it would be impossible to tell
- * for sure to which packet the hardware time stamp belongs.
- *
- * Incoming time stamping has to be configured via the hardware
- * filters. Not all combinations are supported, in particular event
- * type has to be specified. Matching the kind of event packet is
- * not supported, with the exception of "all V2 events regardless of
- * level 2 or 4".
- *
- * Since hardware always timestamps Path delay packets when timestamping V2
- * packets, regardless of the type specified in the register, only use V2
- * Event mode. This more accurately tells the user what the hardware is going
- * to do anyways.
- */
-int fm10k_set_ts_config(struct net_device *netdev, struct ifreq *ifr)
-{
-	struct fm10k_intfc *interface = netdev_priv(netdev);
-	struct hwtstamp_config ts_config;
-
-	if (copy_from_user(&ts_config, ifr->ifr_data, sizeof(ts_config)))
-		return -EFAULT;
-
-	/* reserved for future extensions */
-	if (ts_config.flags)
-		return -EINVAL;
-
-	switch (ts_config.tx_type) {
-	case HWTSTAMP_TX_OFF:
-		break;
-	case HWTSTAMP_TX_ON:
-		/* we likely need some check here to see if this is supported */
-		break;
-	default:
-		return -ERANGE;
-	}
-
-	switch (ts_config.rx_filter) {
-	case HWTSTAMP_FILTER_NONE:
-		interface->flags &= ~FM10K_FLAG_RX_TS_ENABLED;
-		break;
-	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
-	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
-	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
-	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
-	case HWTSTAMP_FILTER_PTP_V2_EVENT:
-	case HWTSTAMP_FILTER_PTP_V2_SYNC:
-	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-	case HWTSTAMP_FILTER_ALL:
-		interface->flags |= FM10K_FLAG_RX_TS_ENABLED;
-		ts_config.rx_filter = HWTSTAMP_FILTER_ALL;
-		break;
-	default:
-		return -ERANGE;
-	}
-
-	/* save these settings for future reference */
-	interface->ts_config = ts_config;
-
-	return copy_to_user(ifr->ifr_data, &ts_config, sizeof(ts_config)) ?
-		-EFAULT : 0;
-}
-
-static int fm10k_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
-{
-	struct fm10k_intfc *interface;
-	struct fm10k_hw *hw;
-	int err;
-
-	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
-	hw = &interface->hw;
-
-	err = hw->mac.ops.adjust_systime(hw, ppb);
-
-	/* the only error we should see is if the value is out of range */
-	return (err == FM10K_ERR_PARAM) ? -ERANGE : err;
-}
-
-static int fm10k_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
-{
-	struct fm10k_intfc *interface;
-	unsigned long flags;
-
-	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
-
-	write_lock_irqsave(&interface->systime_lock, flags);
-	interface->ptp_adjust += delta;
-	write_unlock_irqrestore(&interface->systime_lock, flags);
-
-	return 0;
-}
-
-static int fm10k_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
-{
-	struct fm10k_intfc *interface;
-	unsigned long flags;
-	u64 now;
-
-	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
-
-	read_lock_irqsave(&interface->systime_lock, flags);
-	now = fm10k_systime_read(interface) + interface->ptp_adjust;
-	read_unlock_irqrestore(&interface->systime_lock, flags);
-
-	*ts = ns_to_timespec64(now);
-
-	return 0;
-}
-
-static int fm10k_ptp_settime(struct ptp_clock_info *ptp,
-			     const struct timespec64 *ts)
-{
-	struct fm10k_intfc *interface;
-	unsigned long flags;
-	u64 ns = timespec64_to_ns(ts);
-
-	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
-
-	write_lock_irqsave(&interface->systime_lock, flags);
-	interface->ptp_adjust = fm10k_systime_read(interface) - ns;
-	write_unlock_irqrestore(&interface->systime_lock, flags);
-
-	return 0;
-}
-
-static int fm10k_ptp_enable(struct ptp_clock_info *ptp,
-			    struct ptp_clock_request *rq,
-			    int __always_unused on)
-{
-	struct ptp_clock_time *t = &rq->perout.period;
-	struct fm10k_intfc *interface;
-	struct fm10k_hw *hw;
-	u64 period;
-	u32 step;
-
-	/* we can only support periodic output */
-	if (rq->type != PTP_CLK_REQ_PEROUT)
-		return -EINVAL;
-
-	/* verify the requested channel is there */
-	if (rq->perout.index >= ptp->n_per_out)
-		return -EINVAL;
-
-	/* we cannot enforce start time as there is no
-	 * mechanism for that in the hardware, we can only control
-	 * the period.
-	 */
-
-	/* we cannot support periods greater than 4 seconds due to reg limit */
-	if (t->sec > 4 || t->sec < 0)
-		return -ERANGE;
-
-	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
-	hw = &interface->hw;
-
-	/* we simply cannot support the operation if we don't have BAR4 */
-	if (!hw->sw_addr)
-		return -ENOTSUPP;
-
-	/* convert to unsigned 64b ns, verify we can put it in a 32b register */
-	period = t->sec * 1000000000LL + t->nsec;
-
-	/* determine the minimum size for period */
-	step = 2 * (fm10k_read_reg(hw, FM10K_SYSTIME_CFG) &
-		    FM10K_SYSTIME_CFG_STEP_MASK);
-
-	/* verify the value is in range supported by hardware */
-	if ((period && (period < step)) || (period > U32_MAX))
-		return -ERANGE;
-
-	/* notify hardware of request to being sending pulses */
-	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_PULSE(rq->perout.index),
-			   (u32)period);
-
-	return 0;
-}
-
-static struct ptp_pin_desc fm10k_ptp_pd[2] = {
-	{
-		.name = "IEEE1588_PULSE0",
-		.index = 0,
-		.func = PTP_PF_PEROUT,
-		.chan = 0
-	},
-	{
-		.name = "IEEE1588_PULSE1",
-		.index = 1,
-		.func = PTP_PF_PEROUT,
-		.chan = 1
-	}
-};
-
-static int fm10k_ptp_verify(struct ptp_clock_info *ptp, unsigned int pin,
-			    enum ptp_pin_function func, unsigned int chan)
-{
-	/* verify the requested pin is there */
-	if (pin >= ptp->n_pins || !ptp->pin_config)
-		return -EINVAL;
-
-	/* enforce locked channels, no changing them */
-	if (chan != ptp->pin_config[pin].chan)
-		return -EINVAL;
-
-	/* we want to keep the functions locked as well */
-	if (func != ptp->pin_config[pin].func)
-		return -EINVAL;
-
-	return 0;
-}
-
-void fm10k_ptp_register(struct fm10k_intfc *interface)
-{
-	struct ptp_clock_info *ptp_caps = &interface->ptp_caps;
-	struct device *dev = &interface->pdev->dev;
-	struct ptp_clock *ptp_clock;
-
-	snprintf(ptp_caps->name, sizeof(ptp_caps->name),
-		 "%s", interface->netdev->name);
-	ptp_caps->owner		= THIS_MODULE;
-	/* This math is simply the inverse of the math in
-	 * fm10k_adjust_systime_pf applied to an adjustment value
-	 * of 2^30 - 1 which is the maximum value of the register:
-	 *	max_ppb == ((2^30 - 1) * 5^9) / 2^31
-	 */
-	ptp_caps->max_adj	= 976562;
-	ptp_caps->adjfreq	= fm10k_ptp_adjfreq;
-	ptp_caps->adjtime	= fm10k_ptp_adjtime;
-	ptp_caps->gettime64	= fm10k_ptp_gettime;
-	ptp_caps->settime64	= fm10k_ptp_settime;
-
-	/* provide pins if BAR4 is accessible */
-	if (interface->sw_addr) {
-		/* enable periodic outputs */
-		ptp_caps->n_per_out = 2;
-		ptp_caps->enable	= fm10k_ptp_enable;
-
-		/* enable clock pins */
-		ptp_caps->verify	= fm10k_ptp_verify;
-		ptp_caps->n_pins = 2;
-		ptp_caps->pin_config = fm10k_ptp_pd;
-	}
-
-	ptp_clock = ptp_clock_register(ptp_caps, dev);
-	if (IS_ERR(ptp_clock)) {
-		ptp_clock = NULL;
-		dev_err(dev, "ptp_clock_register failed\n");
-	} else {
-		dev_info(dev, "registered PHC device %s\n", ptp_caps->name);
-	}
-
-	interface->ptp_clock = ptp_clock;
-}
-
-void fm10k_ptp_unregister(struct fm10k_intfc *interface)
-{
-	struct ptp_clock *ptp_clock = interface->ptp_clock;
-	struct device *dev = &interface->pdev->dev;
-
-	if (!ptp_clock)
-		return;
-
-	interface->ptp_clock = NULL;
-
-	ptp_clock_unregister(ptp_clock);
-	dev_info(dev, "removed PHC %s\n", interface->ptp_caps.name);
-}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index 5c05330..995dcee 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -225,11 +225,6 @@ struct fm10k_hw;
 #define FM10K_STATS_LOOPBACK_DROP	0x3806
 #define FM10K_STATS_NODESC_DROP		0x3807
 
-/* Timesync registers */
-#define FM10K_SYSTIME		0x3814
-#define FM10K_SYSTIME_CFG	0x3818
-#define FM10K_SYSTIME_CFG_STEP_MASK		0x0000000F
-
 /* PCIe state registers */
 #define FM10K_PHYADDR		0x381C
 
@@ -381,12 +376,6 @@ struct fm10k_hw;
 #define FM10K_VFSYSTIME		0x00040
 #define FM10K_VFITR(_n)		((_n) + 0x00060)
 
-/* Registers contained in BAR 4 for Switch management */
-#define FM10K_SW_SYSTIME_ADJUST	0x0224D
-#define FM10K_SW_SYSTIME_ADJUST_MASK		0x3FFFFFFF
-#define FM10K_SW_SYSTIME_ADJUST_DIR_POSITIVE	0x80000000
-#define FM10K_SW_SYSTIME_PULSE(_n)	((_n) + 0x02252)
-
 enum fm10k_int_source {
 	fm10k_int_mailbox		= 0,
 	fm10k_int_pcie_fault		= 1,
@@ -550,8 +539,6 @@ struct fm10k_mac_ops {
 				    struct fm10k_dglort_cfg *);
 	void (*set_dma_mask)(struct fm10k_hw *, u64);
 	s32 (*get_fault)(struct fm10k_hw *, int, struct fm10k_fault *);
-	s32 (*adjust_systime)(struct fm10k_hw *, s32 ppb);
-	u64 (*read_systime)(struct fm10k_hw *);
 };
 
 enum fm10k_mac_type {
@@ -643,7 +630,6 @@ struct fm10k_iov_ops {
 	s32 (*set_lport)(struct fm10k_hw *, struct fm10k_vf_info *, u16, u8);
 	void (*reset_lport)(struct fm10k_hw *, struct fm10k_vf_info *);
 	void (*update_stats)(struct fm10k_hw *, struct fm10k_hw_stats_q *, u16);
-	s32 (*report_timestamp)(struct fm10k_hw *, struct fm10k_vf_info *, u64);
 };
 
 struct fm10k_iov_info {
@@ -667,7 +653,6 @@ struct fm10k_info {
 
 struct fm10k_hw {
 	u32 __iomem *hw_addr;
-	u32 __iomem *sw_addr;
 	void *back;
 	struct fm10k_mac_info mac;
 	struct fm10k_bus_info bus;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 91f8d73..86c358c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -451,13 +451,6 @@ static s32 fm10k_update_xcast_mode_vf(struct fm10k_hw *hw, u16 glort, u8 mode)
 	return mbx->ops.enqueue_tx(hw, mbx, msg);
 }
 
-const struct fm10k_tlv_attr fm10k_1588_msg_attr[] = {
-	FM10K_TLV_ATTR_U64(FM10K_1588_MSG_TIMESTAMP),
-	FM10K_TLV_ATTR_LAST
-};
-
-/* currently there is no shared 1588 timestamp handler */
-
 /**
  *  fm10k_update_hw_stats_vf - Updates hardware related statistics of VF
  *  @hw: pointer to hardware structure
@@ -509,52 +502,6 @@ static s32 fm10k_configure_dglort_map_vf(struct fm10k_hw *hw,
 	return 0;
 }
 
-/**
- *  fm10k_adjust_systime_vf - Adjust systime frequency
- *  @hw: pointer to hardware structure
- *  @ppb: adjustment rate in parts per billion
- *
- *  This function takes an adjustment rate in parts per billion and will
- *  verify that this value is 0 as the VF cannot support adjusting the
- *  systime clock.
- *
- *  If the ppb value is non-zero the return is ERR_PARAM else success
- **/
-static s32 fm10k_adjust_systime_vf(struct fm10k_hw *hw, s32 ppb)
-{
-	/* The VF cannot adjust the clock frequency, however it should
-	 * already have a syntonic clock with whichever host interface is
-	 * running as the master for the host interface clock domain so
-	 * there should be not frequency adjustment necessary.
-	 */
-	return ppb ? FM10K_ERR_PARAM : 0;
-}
-
-/**
- *  fm10k_read_systime_vf - Reads value of systime registers
- *  @hw: pointer to the hardware structure
- *
- *  Function reads the content of 2 registers, combined to represent a 64 bit
- *  value measured in nanoseconds.  In order to guarantee the value is accurate
- *  we check the 32 most significant bits both before and after reading the
- *  32 least significant bits to verify they didn't change as we were reading
- *  the registers.
- **/
-static u64 fm10k_read_systime_vf(struct fm10k_hw *hw)
-{
-	u32 systime_l, systime_h, systime_tmp;
-
-	systime_h = fm10k_read_reg(hw, FM10K_VFSYSTIME + 1);
-
-	do {
-		systime_tmp = systime_h;
-		systime_l = fm10k_read_reg(hw, FM10K_VFSYSTIME);
-		systime_h = fm10k_read_reg(hw, FM10K_VFSYSTIME + 1);
-	} while (systime_tmp != systime_h);
-
-	return ((u64)systime_h << 32) | systime_l;
-}
-
 static const struct fm10k_msg_data fm10k_msg_data_vf[] = {
 	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
 	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_msg_mac_vlan_vf),
@@ -579,8 +526,6 @@ static const struct fm10k_mac_ops mac_ops_vf = {
 	.rebind_hw_stats	= fm10k_rebind_hw_stats_vf,
 	.configure_dglort_map	= fm10k_configure_dglort_map_vf,
 	.get_host_state		= fm10k_get_host_state_generic,
-	.adjust_systime		= fm10k_adjust_systime_vf,
-	.read_systime		= fm10k_read_systime_vf,
 };
 
 static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
index c4439f1..f0932f9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -29,7 +29,6 @@ enum fm10k_vf_tlv_msg_id {
 	FM10K_VF_MSG_ID_MSIX,
 	FM10K_VF_MSG_ID_MAC_VLAN,
 	FM10K_VF_MSG_ID_LPORT_STATE,
-	FM10K_VF_MSG_ID_1588,
 	FM10K_VF_MSG_ID_MAX,
 };
 
@@ -49,11 +48,6 @@ enum fm10k_tlv_lport_state_attr_id {
 	FM10K_LPORT_STATE_MSG_MAX
 };
 
-enum fm10k_tlv_1588_attr_id {
-	FM10K_1588_MSG_TIMESTAMP,
-	FM10K_1588_MSG_MAX
-};
-
 #define FM10K_VF_MSG_MSIX_HANDLER(func) \
 	 FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_MSIX, NULL, func)
 
@@ -70,9 +64,5 @@ extern const struct fm10k_tlv_attr fm10k_lport_state_msg_attr[];
 	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_LPORT_STATE, \
 			  fm10k_lport_state_msg_attr, func)
 
-extern const struct fm10k_tlv_attr fm10k_1588_msg_attr[];
-#define FM10K_VF_MSG_1588_HANDLER(func) \
-	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_1588, fm10k_1588_msg_attr, func)
-
 extern const struct fm10k_info fm10k_vf_info;
 #endif /* _FM10K_VF_H */
-- 
2.5.5
