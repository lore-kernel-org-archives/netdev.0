From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] e1000e: add Receive Packet Steering (RPS) support
Date: Tue,  3 Jan 2012 11:19:13 -0800
Message-ID: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48412 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754754Ab2ACTTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 14:19:48 -0500
In-Reply-To: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Enable RPS by default.  Disallow jumbo frames when both receive checksum
and receive hashing are enabled because the hardware cannot do both IP
payload checksum (enabled when receive checksum is enabled when using
packet split which is used for jumbo frames) and provide RSS hash at the
same time.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |    7 ++
 drivers/net/ethernet/intel/e1000e/hw.h      |    5 ++
 drivers/net/ethernet/intel/e1000e/netdev.c  |   93 +++++++++++++++++++++++++--
 3 files changed, 100 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index c516a74..efa0310 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -126,6 +126,12 @@
     E1000_RXDEXT_STATERR_CXE |            \
     E1000_RXDEXT_STATERR_RXE)
 
+#define E1000_MRQC_RSS_FIELD_IPV4_TCP          0x00010000
+#define E1000_MRQC_RSS_FIELD_IPV4              0x00020000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP_EX       0x00040000
+#define E1000_MRQC_RSS_FIELD_IPV6              0x00100000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP          0x00200000
+
 #define E1000_RXDPS_HDRSTAT_HDRSP              0x00008000
 
 /* Management Control */
@@ -326,6 +332,7 @@
 /* Receive Checksum Control */
 #define E1000_RXCSUM_TUOFL     0x00000200   /* TCP / UDP checksum offload */
 #define E1000_RXCSUM_IPPCSE    0x00001000   /* IP payload checksum enable */
+#define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
 
 /* Header split receive */
 #define E1000_RFCTL_NFSW_DIS            0x00000040
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 2967039..93c349e 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -204,6 +204,7 @@ enum e1e_registers {
 	E1000_WUC      = 0x05800, /* Wakeup Control - RW */
 	E1000_WUFC     = 0x05808, /* Wakeup Filter Control - RW */
 	E1000_WUS      = 0x05810, /* Wakeup Status - RO */
+	E1000_MRQC     = 0x05818, /* Multiple Receive Control - RW */
 	E1000_MANC     = 0x05820, /* Management Control - RW */
 	E1000_FFLT     = 0x05F00, /* Flexible Filter Length Table - RW Array */
 	E1000_HOST_IF  = 0x08800, /* Host Interface */
@@ -219,6 +220,10 @@ enum e1e_registers {
 	E1000_SWSM      = 0x05B50, /* SW Semaphore */
 	E1000_FWSM      = 0x05B54, /* FW Semaphore */
 	E1000_SWSM2     = 0x05B58, /* Driver-only SW semaphore */
+	E1000_RETA_BASE = 0x05C00, /* Redirection Table - RW */
+#define E1000_RETA(_n)	(E1000_RETA_BASE + ((_n) * 4))
+	E1000_RSSRK_BASE = 0x05C80, /* RSS Random Key - RW */
+#define E1000_RSSRK(_n)	(E1000_RSSRK_BASE + ((_n) * 4))
 	E1000_FFLT_DBG  = 0x05F04, /* Debug Register */
 	E1000_PCH_RAICC_BASE = 0x05F50, /* Receive Address Initial CRC */
 #define E1000_PCH_RAICC(_n)	(E1000_PCH_RAICC_BASE + ((_n) * 4))
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e01ffce..fa7bf63 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -845,6 +845,13 @@ check_page:
 	}
 }
 
+static inline void e1000_rx_hash(struct net_device *netdev, __le32 rss,
+				 struct sk_buff *skb)
+{
+	if (netdev->features & NETIF_F_RXHASH)
+		skb->rxhash = le32_to_cpu(rss);
+}
+
 /**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -964,6 +971,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		e1000_rx_checksum(adapter, staterr,
 				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
+		e1000_rx_hash(netdev, rx_desc->wb.lower.hi_dword.rss, skb);
+
 		e1000_receive_skb(adapter, netdev, skb, staterr,
 				  rx_desc->wb.upper.vlan);
 
@@ -1325,6 +1334,8 @@ copydone:
 		e1000_rx_checksum(adapter, staterr,
 				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
+		e1000_rx_hash(netdev, rx_desc->wb.lower.hi_dword.rss, skb);
+
 		if (rx_desc->wb.upper.header_status &
 			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP))
 			adapter->rx_hdr_split++;
@@ -1497,6 +1508,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		e1000_rx_checksum(adapter, staterr,
 				  rx_desc->wb.lower.hi_dword.csum_ip.csum, skb);
 
+		e1000_rx_hash(netdev, rx_desc->wb.lower.hi_dword.rss, skb);
+
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -3271,6 +3284,49 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
 		e1000e_vlan_strip_disable(adapter);
 }
 
+static void e1000e_setup_rss_hash(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 mrqc, rxcsum;
+	int j;
+	static const u8 rsshash[40] = {
+		0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2, 0x41, 0x67,
+		0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0, 0xd0, 0xca, 0x2b, 0xcb,
+		0xae, 0x7b, 0x30, 0xb4, 0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30,
+		0xf2, 0x0c, 0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa
+	};
+
+	/* Fill out hash function seeds */
+	for (j = 0; j < 10; j++) {
+		u32 rsskey = rsshash[(j * 4)];
+		rsskey |= rsshash[(j * 4) + 1] << 8;
+		rsskey |= rsshash[(j * 4) + 2] << 16;
+		rsskey |= rsshash[(j * 4) + 3] << 24;
+		E1000_WRITE_REG_ARRAY(hw, E1000_RSSRK(0), j, rsskey);
+	}
+
+	/* Direct all traffic to queue 0 */
+	for (j = 0; j < 32; j++)
+		ew32(RETA(j), 0);
+
+	/*
+	 * Disable raw packet checksumming so that RSS hash is placed in
+	 * descriptor on writeback.
+	 */
+	rxcsum = er32(RXCSUM);
+	rxcsum |= E1000_RXCSUM_PCSD;
+
+	ew32(RXCSUM, rxcsum);
+
+	mrqc = (E1000_MRQC_RSS_FIELD_IPV4 |
+		E1000_MRQC_RSS_FIELD_IPV4_TCP |
+		E1000_MRQC_RSS_FIELD_IPV6 |
+		E1000_MRQC_RSS_FIELD_IPV6_TCP |
+		E1000_MRQC_RSS_FIELD_IPV6_TCP_EX);
+
+	ew32(MRQC, mrqc);
+}
+
 /**
  * e1000_configure - configure the hardware for Rx and Tx
  * @adapter: private board structure
@@ -3283,6 +3339,9 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	e1000_init_manageability_pt(adapter);
 
 	e1000_configure_tx(adapter);
+
+	if (adapter->netdev->features & NETIF_F_RXHASH)
+		e1000e_setup_rss_hash(adapter);
 	e1000_setup_rctl(adapter);
 	e1000_configure_rx(adapter);
 	adapter->alloc_rx_buf(adapter, e1000_desc_unused(adapter->rx_ring),
@@ -5168,10 +5227,22 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* Jumbo frame support */
-	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
-	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-		e_err("Jumbo Frames not supported.\n");
-		return -EINVAL;
+	if (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) {
+		if (!(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
+			e_err("Jumbo Frames not supported.\n");
+			return -EINVAL;
+		}
+
+		/*
+		 * IP payload checksum (enabled with jumbos/packet-split when
+		 * Rx checksum is enabled) and generation of RSS hash is
+		 * mutually exclusive in the hardware.
+		 */
+		if ((netdev->features & NETIF_F_RXCSUM) &&
+		    (netdev->features & NETIF_F_RXHASH)) {
+			e_err("Jumbo frames cannot be enabled when both receive checksum offload and receive hashing are enabled.  Disable one of the receive offload features before enabling jumbos.\n");
+			return -EINVAL;
+		}
 	}
 
 	/* Supported frame sizes */
@@ -5943,9 +6014,20 @@ static int e1000_set_features(struct net_device *netdev,
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-			 NETIF_F_RXCSUM)))
+			 NETIF_F_RXCSUM | NETIF_F_RXHASH)))
 		return 0;
 
+	/*
+	 * IP payload checksum (enabled with jumbos/packet-split when Rx
+	 * checksum is enabled) and generation of RSS hash is mutually
+	 * exclusive in the hardware.
+	 */
+	if (adapter->rx_ps_pages &&
+	    (features & NETIF_F_RXCSUM) && (features & NETIF_F_RXHASH)) {
+		e_err("Enabling both receive checksum offload and receive hashing is not possible with jumbo frames.  Disable jumbos or enable only one of the receive offload features.\n");
+		return -EINVAL;
+	}
+
 	if (netif_running(netdev))
 		e1000e_reinit_locked(adapter);
 	else
@@ -6136,6 +6218,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 			    NETIF_F_HW_VLAN_TX |
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
+			    NETIF_F_RXHASH |
 			    NETIF_F_RXCSUM |
 			    NETIF_F_HW_CSUM);
 
-- 
1.7.7.4
