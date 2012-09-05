From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Wed,  5 Sep 2012 16:35:01 -0700
Message-ID: <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759921Ab2IEXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 19:35:09 -0400
In-Reply-To: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

For users without CONFIG_IGB_PTP=y, we should not be compiling any PTP
code into the driver. Tidy up the wrapping in igb to support this.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Jeff Pieper  <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  8 ++++++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    | 23 +++++++++++++++++------
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 0c9f62c..a3b5b90 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -34,9 +34,11 @@
 #include "e1000_mac.h"
 #include "e1000_82575.h"
 
+#ifdef CONFIG_IGB_PTP
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#endif /* CONFIG_IGB_PTP */
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 
@@ -376,12 +378,15 @@ struct igb_adapter {
 	int node;
 	u32 *shadow_vfta;
 
+#ifdef CONFIG_IGB_PTP
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info caps;
 	struct delayed_work overflow_work;
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
+#endif /* CONFIG_IGB_PTP */
+
 	char fw_version[32];
 };
 
@@ -436,12 +441,11 @@ extern void igb_set_fw_version(struct igb_adapter *);
 #ifdef CONFIG_IGB_PTP
 extern void igb_ptp_init(struct igb_adapter *adapter);
 extern void igb_ptp_remove(struct igb_adapter *adapter);
-
 extern void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 				   struct skb_shared_hwtstamps *hwtstamps,
 				   u64 systim);
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.reset)
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a294441..0c4e29a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2338,8 +2338,8 @@ static int igb_ethtool_get_ts_info(struct net_device *dev,
 
 	return 0;
 }
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2370,7 +2370,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.complete		= igb_ethtool_complete,
 #ifdef CONFIG_IGB_PTP
 	.get_ts_info		= igb_ethtool_get_ts_info,
-#endif
+#endif /* CONFIG_IGB_PTP */
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 73cc273..03477d7 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2180,11 +2180,12 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 
 #endif
+
 #ifdef CONFIG_IGB_PTP
 	/* do hw tstamp init after resetting */
 	igb_ptp_init(adapter);
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
@@ -2260,8 +2261,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	pm_runtime_get_noresume(&pdev->dev);
 #ifdef CONFIG_IGB_PTP
 	igb_ptp_remove(adapter);
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 	/*
 	 * The watchdog timer may be rescheduled, so explicitly
 	 * disable watchdog from being rescheduled.
@@ -3184,8 +3185,10 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	srrctl |= (PAGE_SIZE / 2) >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 #endif
 	srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+#ifdef CONFIG_IGB_PTP
 	if (hw->mac.type >= e1000_82580)
 		srrctl |= E1000_SRRCTL_TIMESTAMP;
+#endif /* CONFIG_IGB_PTP */
 	/* Only set Drop Enable if we are supporting multiple queues */
 	if (adapter->vfs_allocated_count || adapter->num_rx_queues > 1)
 		srrctl |= E1000_SRRCTL_DROP_EN;
@@ -4229,9 +4232,11 @@ static __le32 igb_tx_cmd_type(u32 tx_flags)
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
 		cmd_type |= cpu_to_le32(E1000_ADVTXD_DCMD_VLE);
 
+#ifdef CONFIG_IGB_PTP
 	/* set timestamp bit if present */
 	if (tx_flags & IGB_TX_FLAGS_TSTAMP)
 		cmd_type |= cpu_to_le32(E1000_ADVTXD_MAC_TSTAMP);
+#endif /* CONFIG_IGB_PTP */
 
 	/* set segmentation bits for TSO */
 	if (tx_flags & IGB_TX_FLAGS_TSO)
@@ -4462,10 +4467,12 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	first->bytecount = skb->len;
 	first->gso_segs = 1;
 
+#ifdef CONFIG_IGB_PTP
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IGB_TX_FLAGS_TSTAMP;
 	}
+#endif /* CONFIG_IGB_PTP */
 
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
@@ -5772,8 +5779,8 @@ static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
 	igb_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
 	skb_tstamp_tx(buffer_info->skb, &shhwtstamps);
 }
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 /**
  * igb_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: pointer to q_vector containing needed info
@@ -5821,8 +5828,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 #ifdef CONFIG_IGB_PTP
 		/* retrieve hardware timestamp */
 		igb_tx_hwtstamp(q_vector, tx_buffer);
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 		/* free the skb */
 		dev_kfree_skb_any(tx_buffer->skb);
 		tx_buffer->skb = NULL;
@@ -6033,8 +6040,8 @@ static void igb_rx_hwtstamp(struct igb_q_vector *q_vector,
 
 	igb_systim_to_hwtstamp(adapter, skb_hwtstamps(skb), regval);
 }
+#endif /* CONFIG_IGB_PTP */
 
-#endif
 static void igb_rx_vlan(struct igb_ring *ring,
 			union e1000_adv_rx_desc *rx_desc,
 			struct sk_buff *skb)
@@ -6147,7 +6154,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 
 #ifdef CONFIG_IGB_PTP
 		igb_rx_hwtstamp(q_vector, rx_desc, skb);
-#endif
+#endif /* CONFIG_IGB_PTP */
 		igb_rx_hash(rx_ring, rx_desc, skb);
 		igb_rx_checksum(rx_ring, rx_desc, skb);
 		igb_rx_vlan(rx_ring, rx_desc, skb);
@@ -6340,6 +6347,7 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return 0;
 }
 
+#ifdef CONFIG_IGB_PTP
 /**
  * igb_hwtstamp_ioctl - control hardware time stamping
  * @netdev:
@@ -6514,6 +6522,7 @@ static int igb_hwtstamp_ioctl(struct net_device *netdev,
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
 		-EFAULT : 0;
 }
+#endif /* CONFIG_IGB_PTP */
 
 /**
  * igb_ioctl -
@@ -6528,8 +6537,10 @@ static int igb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
 		return igb_mii_ioctl(netdev, ifr, cmd);
+#ifdef CONFIG_IGB_PTP
 	case SIOCSHWTSTAMP:
 		return igb_hwtstamp_ioctl(netdev, ifr, cmd);
+#endif /* CONFIG_IGB_PTP */
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.7.11.4
