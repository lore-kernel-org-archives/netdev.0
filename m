From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/16] ixgbe: add VXLAN offload support for X550 devices
Date: Thu,  5 Feb 2015 20:31:19 -0800
Message-ID: <1423197085-32270-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	kernel-team@fb.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31696 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673AbbBFEbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 23:31:41 -0500
In-Reply-To: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Add support VXLAN receive checksum offload in X550 hardware.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig            | 11 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 98 ++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  5 ++
 4 files changed, 113 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 4d61ef5..f4ff465 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -192,6 +192,17 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_VXLAN
+	bool "Virtual eXtensible Local Area Network Support"
+	default n
+	depends on IXGBE && VXLAN && !(IXGBE=y && VXLAN=m)
+	---help---
+	  This allows one to create VXLAN virtual interfaces that provide
+	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
+	  to tunnel virtual network infrastructure in virtualized environments.
+	  Say Y here if you want to use Virtual eXtensible Local Area Network
+	  (VXLAN) in the driver.
+
 config IXGBE_HWMON
 	bool "Intel(R) 10GbE PCI Express adapters HWMON support"
 	default y
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 38fc64c..699117af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -753,6 +753,7 @@ struct ixgbe_adapter {
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
 	struct ixgbe_mac_addr *mac_table;
+	u16 vxlan_port;
 	struct kobject *info_kobj;
 #ifdef CONFIG_IXGBE_HWMON
 	struct hwmon_buff *ixgbe_hwmon_buff;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e9e3a1e..6aa9b96 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -50,6 +50,7 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <net/vxlan.h>
 
 #ifdef CONFIG_OF
 #include <linux/of_net.h>
@@ -1396,12 +1397,23 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 				     union ixgbe_adv_rx_desc *rx_desc,
 				     struct sk_buff *skb)
 {
+	__le16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
+	__le16 hdr_info = rx_desc->wb.lower.lo_dword.hs_rss.hdr_info;
+	bool encap_pkt = false;
+
 	skb_checksum_none_assert(skb);
 
 	/* Rx csum disabled */
 	if (!(ring->netdev->features & NETIF_F_RXCSUM))
 		return;
 
+	if ((pkt_info & cpu_to_le16(IXGBE_RXDADV_PKTTYPE_VXLAN)) &&
+	    (hdr_info & cpu_to_le16(IXGBE_RXDADV_PKTTYPE_TUNNEL >> 16))) {
+		encap_pkt = true;
+		skb->encapsulation = 1;
+		skb->ip_summed = CHECKSUM_NONE;
+	}
+
 	/* if IP and error */
 	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_IPCS) &&
 	    ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_IPE)) {
@@ -1413,8 +1425,6 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 		return;
 
 	if (ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_TCPE)) {
-		__le16 pkt_info = rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
-
 		/*
 		 * 82599 errata, UDP frames with a 0 checksum can be marked as
 		 * checksum errors.
@@ -1429,6 +1439,17 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 
 	/* It must be a TCP or UDP packet with a valid checksum */
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	if (encap_pkt) {
+		if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_OUTERIPCS))
+			return;
+
+		if (ixgbe_test_staterr(rx_desc, IXGBE_RXDADV_ERR_OUTERIPER)) {
+			ring->rx_stats.csum_err++;
+			return;
+		}
+		/* If we checked the outer header let the stack know */
+		skb->csum_level = 1;
+	}
 }
 
 static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
@@ -5627,6 +5648,10 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_up_complete(adapter);
 
+#if IS_ENABLED(CONFIG_IXGBE_VXLAN)
+	vxlan_get_rx_port(netdev);
+
+#endif
 	return 0;
 
 err_set_queues:
@@ -7771,6 +7796,64 @@ static int ixgbe_set_features(struct net_device *netdev,
 	return 0;
 }
 
+/**
+ * ixgbe_add_vxlan_port - Get notifications about VXLAN ports that come up
+ * @dev: The port's netdev
+ * @sa_family: Socket Family that VXLAN is notifiying us about
+ * @port: New UDP port number that VXLAN started listening to
+ **/
+static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
+				 __be16 port)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 new_port = ntohs(port);
+
+	if (sa_family == AF_INET6)
+		return;
+
+	if (adapter->vxlan_port == new_port) {
+		netdev_info(dev, "Port %d already offloaded\n", new_port);
+		return;
+	}
+
+	if (adapter->vxlan_port) {
+		netdev_info(dev,
+			    "Hit Max num of UDP ports, not adding port %d\n",
+			    new_port);
+		return;
+	}
+
+	adapter->vxlan_port = new_port;
+	IXGBE_WRITE_REG(hw, IXGBE_VXLANCTRL, new_port);
+}
+
+/**
+ * ixgbe_del_vxlan_port - Get notifications about VXLAN ports that go away
+ * @dev: The port's netdev
+ * @sa_family: Socket Family that VXLAN is notifying us about
+ * @port: UDP port number that VXLAN stopped listening to
+ **/
+static void ixgbe_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
+				 __be16 port)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 new_port = ntohs(port);
+
+	if (sa_family == AF_INET6)
+		return;
+
+	if (adapter->vxlan_port != new_port) {
+		netdev_info(dev, "Port %d was not found, not deleting\n",
+			    new_port);
+		return;
+	}
+
+	adapter->vxlan_port = 0;
+	IXGBE_WRITE_REG(hw, IXGBE_VXLANCTRL, 0);
+}
+
 static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
 			     const unsigned char *addr, u16 vid,
@@ -7982,6 +8065,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
+	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
+	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
 };
 
 /**
@@ -8339,6 +8424,15 @@ skip_sriov:
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_X550:
+	case ixgbe_mac_X550EM_x:
+		netdev->hw_enc_features |= NETIF_F_RXCSUM;
+		break;
+	default:
+		break;
+	}
+
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index d101b25..02b57bf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -399,6 +399,7 @@ struct ixgbe_thermal_sensor_data {
 
 #define IXGBE_WUPL      0x05900
 #define IXGBE_WUPM      0x05A00 /* wake up pkt memory 0x5A00-0x5A7C */
+#define IXGBE_VXLANCTRL	0x0000507C /* Rx filter VXLAN UDPPORT Register */
 #define IXGBE_FHFT(_n)	(0x09000 + ((_n) * 0x100)) /* Flex host filter table */
 #define IXGBE_FHFT_EXT(_n)	(0x09800 + ((_n) * 0x100)) /* Ext Flexible Host
 							    * Filter Table */
@@ -2122,6 +2123,7 @@ enum {
 #define IXGBE_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
 #define IXGBE_RXD_STAT_PIF      0x80    /* passed in-exact filter */
 #define IXGBE_RXD_STAT_CRCV     0x100   /* Speculative CRC Valid */
+#define IXGBE_RXD_STAT_OUTERIPCS  0x100 /* Cloud IP xsum calculated */
 #define IXGBE_RXD_STAT_VEXT     0x200   /* 1st VLAN found */
 #define IXGBE_RXD_STAT_UDPV     0x400   /* Valid UDP checksum */
 #define IXGBE_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
@@ -2139,6 +2141,7 @@ enum {
 #define IXGBE_RXD_ERR_IPE       0x80    /* IP Checksum Error */
 #define IXGBE_RXDADV_ERR_MASK           0xfff00000 /* RDESC.ERRORS mask */
 #define IXGBE_RXDADV_ERR_SHIFT          20         /* RDESC.ERRORS shift */
+#define IXGBE_RXDADV_ERR_OUTERIPER	0x04000000 /* CRC IP Header error */
 #define IXGBE_RXDADV_ERR_FCEOFE         0x80000000 /* FCoEFe/IPE */
 #define IXGBE_RXDADV_ERR_FCERR          0x00700000 /* FCERR/FDIRERR */
 #define IXGBE_RXDADV_ERR_FDIR_LEN       0x00100000 /* FDIR Length error */
@@ -2227,6 +2230,8 @@ enum {
 #define IXGBE_RXDADV_PKTTYPE_UDP        0x00000200 /* UDP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_SCTP       0x00000400 /* SCTP hdr present */
 #define IXGBE_RXDADV_PKTTYPE_NFS        0x00000800 /* NFS hdr present */
+#define IXGBE_RXDADV_PKTTYPE_VXLAN	0x00000800 /* VXLAN hdr present */
+#define IXGBE_RXDADV_PKTTYPE_TUNNEL	0x00010000 /* Tunnel type */
 #define IXGBE_RXDADV_PKTTYPE_IPSEC_ESP  0x00001000 /* IPSec ESP */
 #define IXGBE_RXDADV_PKTTYPE_IPSEC_AH   0x00002000 /* IPSec AH */
 #define IXGBE_RXDADV_PKTTYPE_LINKSEC    0x00004000 /* LinkSec Encap */
-- 
1.9.3
