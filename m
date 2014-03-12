From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] igb: Add support for debugfs
Date: Tue, 11 Mar 2014 22:53:30 -0700
Message-ID: <1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Josh Hay <hayja@mail.uc.edu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755009AbaCLFxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:42 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds the necessary defines, variables, and stats updating
procedures to use the commands implemented in debugfs.

Signed-off-by: Josh Hay <hayja@mail.uc.edu>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper  <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h   | 12 +++++++
 drivers/net/ethernet/intel/igb/e1000_defines.h |  4 ++-
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  2 ++
 drivers/net/ethernet/intel/igb/igb.h           | 15 +++++++++
 drivers/net/ethernet/intel/igb/igb_main.c      | 45 ++++++++++++++++++++++++++
 5 files changed, 77 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 2a721a1..806e730 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -116,6 +116,18 @@ union e1000_adv_rx_desc {
 #define E1000_RXDADV_STAT_TS             0x10000 /* Pkt was time stamped */
 #define E1000_RXDADV_STAT_TSIP           0x08000 /* timestamp in packet */
 
+#define E1000_RXDADV_PKTTYPE_ILMASK	0x00F0
+#define E1000_RXDADV_PKTTYPE_TLMASK	0x0F00
+#define E1000_RXDADV_PKTTYPE_NONE	0x0000
+#define E1000_RXDADV_PKTTYPE_IPV4	0x0010 /* IPV4 hdr present */
+#define E1000_RXDADV_PKTTYPE_IPV4_EX	0x0020 /* IPV4 hdr + extensions */
+#define E1000_RXDADV_PKTTYPE_IPV6	0x0040 /* IPV6 hdr present */
+#define E1000_RXDADV_PKTTYPE_IPV6_EX	0x0080 /* IPV6 + extensions */
+#define E1000_RXDADV_PKTTYPE_TCP	0x0100 /* TCP hdr present */
+#define E1000_RXDADV_PKTTYPE_UDP	0x0200 /* UDP hdr present */
+#define E1000_RXDADV_PKTTYPE_SCTP	0x0400 /* SCTP hdr present */
+#define E1000_RXDADV_PKTTYPE_NFS	0x0800 /* NDS hdr present */
+
 /* Transmit Descriptor - Advanced */
 union e1000_adv_tx_desc {
 	struct {
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 393c896..59303ef 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -430,7 +430,7 @@
 /* Extended Interrupt Cause Set */
 /* E1000_EITR_CNT_IGNR is only for 82576 and newer */
 #define E1000_EITR_CNT_IGNR     0x80000000 /* Don't reset counters on write */
-
+#define E1000_EITR_INTERVAL	0x00007FFC
 
 /* Transmit Descriptor Control */
 /* Enable the counting of descriptors still to be processed. */
@@ -920,6 +920,8 @@
 #define E1000_EEER_LPI_FC            0x00040000  /* EEE Enable on FC */
 #define E1000_EEE_SU_LPI_CLK_STP     0X00800000  /* EEE LPI Clock Stop */
 #define E1000_EEER_EEE_NEG           0x20000000  /* EEE capability nego */
+#define E1000_EEER_RX_LPI_STATUS     0x40000000  /* RX in LPI state */
+#define E1000_EEER_TX_LPI_STATUS     0x80000000  /* TX in LPI state */
 #define E1000_EEE_LP_ADV_ADDR_I350   0x040F      /* EEE LP Advertisement */
 #define E1000_EEE_LP_ADV_DEV_I210    7           /* EEE LP Adv Device */
 #define E1000_EEE_LP_ADV_ADDR_I210   61          /* EEE LP Adv Register */
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index abdd935..7e17181 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -368,6 +368,8 @@
 #define E1000_IPCNFG	0x0E38 /* Internal PHY Configuration */
 #define E1000_EEER	0x0E30 /* Energy Efficient Ethernet */
 #define E1000_EEE_SU	0X0E34 /* EEE Setup */
+#define E1000_TLPIC	0x4148 /* EEE TX LPI count */
+#define E1000_RLPIC	0x414C /* EEE RX LPI count */
 #define E1000_EMIADD	0x10   /* Extended Memory Indirect Address */
 #define E1000_EMIDATA	0x11   /* Extended Memory Indirect Data */
 #define E1000_MMDAC	13     /* MMD Access Control */
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 68b32d4a..a8c4fca 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -224,6 +224,18 @@ struct igb_rx_queue_stats {
 	u64 alloc_failed;
 };
 
+struct igb_rx_pkt_stats {
+	u64 ipv4_packets;		/* IPv4 headers processed */
+	u64 ipv4e_packets;		/* IPv4E headers processed */
+	u64 ipv6_packets;		/* IPv6 headers processed */
+	u64 ipv6e_packets;		/* IPv6e headers processed */
+	u64 tcp_packets;		/* TCP headers processed */
+	u64 udp_packets;		/* UDP headers processed */
+	u64 sctp_packets;		/* SCTP headers processed */
+	u64 nfs_packets;		/* NFS headers processed */
+	u64 other_packets;
+};
+
 struct igb_ring_container {
 	struct igb_ring *ring;		/* pointer to linked list of rings */
 	unsigned int total_bytes;	/* total bytes processed this int */
@@ -268,6 +280,7 @@ struct igb_ring {
 		struct {
 			struct sk_buff *skb;
 			struct igb_rx_queue_stats rx_stats;
+			struct igb_rx_pkt_stats pkt_stats;
 			struct u64_stats_sync rx_syncp;
 		};
 	};
@@ -460,6 +473,8 @@ struct igb_adapter {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *igb_dbg_adapter;
 #endif /* CONFIG_DEBUG_FS */
+
+	int devrc;
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a709caf..6cc9487 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2012,6 +2012,8 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_ptp_reset(adapter);
 
 	igb_get_phy_info(hw);
+
+	adapter->devrc++;
 }
 
 static netdev_features_t igb_fix_features(struct net_device *netdev,
@@ -2498,6 +2500,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* reset the hardware with the new settings */
 	igb_reset(adapter);
+	adapter->devrc = 0;
 
 	/* Init the I2C interface */
 	err = igb_init_i2c(adapter);
@@ -6923,11 +6926,53 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 				   struct sk_buff *skb)
 {
 	struct net_device *dev = rx_ring->netdev;
+	__le16 pkt_info = rx_desc->wb.lower.lo_dword.pkt_info;
+	bool other = false;
 
 	igb_rx_hash(rx_ring, rx_desc, skb);
 
 	igb_rx_checksum(rx_ring, rx_desc, skb);
 
+	switch (pkt_info & E1000_RXDADV_PKTTYPE_ILMASK) {
+	case E1000_RXDADV_PKTTYPE_IPV4:
+		rx_ring->pkt_stats.ipv4_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_IPV4_EX:
+		rx_ring->pkt_stats.ipv4e_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_IPV6:
+		rx_ring->pkt_stats.ipv6_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_IPV6_EX:
+		rx_ring->pkt_stats.ipv6e_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_NONE:
+		other = true;
+	default:
+		break;
+	}
+
+	switch (pkt_info & E1000_RXDADV_PKTTYPE_TLMASK) {
+	case E1000_RXDADV_PKTTYPE_TCP:
+		rx_ring->pkt_stats.tcp_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_UDP:
+		rx_ring->pkt_stats.udp_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_SCTP:
+		rx_ring->pkt_stats.sctp_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_NFS:
+		rx_ring->pkt_stats.nfs_packets++;
+		break;
+	case E1000_RXDADV_PKTTYPE_NONE:
+		if (other)
+			rx_ring->pkt_stats.other_packets++;
+		break;
+	default:
+		break;
+	}
+
 	igb_ptp_rx_hwtstamp(rx_ring, rx_desc, skb);
 
 	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
-- 
1.8.3.1
