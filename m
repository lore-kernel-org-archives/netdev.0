From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx checksum offload
Date: Tue,  1 Sep 2015 18:13:49 -0700
Message-ID: <1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587AbbIBBOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:07 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

By using GSO for UDP-encapsulated packets, all ixgbe devices can
be directed to generate checksums for the inner headers because
the outer UDP checksum can be zero. So point the machinery at the
inner headers and have the hardware generate the checksum.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 66 ++++++++++++++++++++++-----
 1 file changed, 54 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ab28dc2..900562e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6912,31 +6912,55 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
 		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
 			return;
+		vlan_macip_lens = skb_network_offset(skb) <<
+				  IXGBE_ADVTXD_MACLEN_SHIFT;
 	} else {
 		u8 l4_hdr = 0;
-		switch (first->protocol) {
-		case htons(ETH_P_IP):
-			vlan_macip_lens |= skb_network_header_len(skb);
+		union {
+			struct iphdr *ipv4;
+			struct ipv6hdr *ipv6;
+			u8 *raw;
+		} network_hdr;
+		union {
+			struct tcphdr *tcphdr;
+			u8 *raw;
+		} transport_hdr;
+
+		if (skb->encapsulation) {
+			network_hdr.raw = skb_inner_network_header(skb);
+			transport_hdr.raw = skb_inner_transport_header(skb);
+			vlan_macip_lens = skb_inner_network_offset(skb) <<
+					  IXGBE_ADVTXD_MACLEN_SHIFT;
+		} else {
+			network_hdr.raw = skb_network_header(skb);
+			transport_hdr.raw = skb_transport_header(skb);
+			vlan_macip_lens = skb_network_offset(skb) <<
+					  IXGBE_ADVTXD_MACLEN_SHIFT;
+		}
+
+		/* use first 4 bits to determine IP version */
+		switch (network_hdr.ipv4->version) {
+		case IPVERSION:
+			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
-			l4_hdr = ip_hdr(skb)->protocol;
+			l4_hdr = network_hdr.ipv4->protocol;
 			break;
-		case htons(ETH_P_IPV6):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			l4_hdr = ipv6_hdr(skb)->nexthdr;
+		case 6:
+			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
+			l4_hdr = network_hdr.ipv6->nexthdr;
 			break;
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but proto=%x!\n",
-				 first->protocol);
+					 "partial checksum but version=%d\n",
+					 network_hdr.ipv4->version);
 			}
-			break;
 		}
 
 		switch (l4_hdr) {
 		case IPPROTO_TCP:
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
-			mss_l4len_idx = tcp_hdrlen(skb) <<
+			mss_l4len_idx = (transport_hdr.tcphdr->doff * 4) <<
 					IXGBE_ADVTXD_L4LEN_SHIFT;
 			break;
 		case IPPROTO_SCTP:
@@ -6962,7 +6986,6 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	}
 
 	/* vlan_macip_lens: MACLEN, VLAN tag */
-	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
 	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0,
@@ -8207,6 +8230,21 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
+#define IXGBE_MAX_TUNNEL_HDR_LEN 80
+static netdev_features_t
+ixgbe_features_check(struct sk_buff *skb, struct net_device *dev,
+		     netdev_features_t features)
+{
+	if (!skb->encapsulation)
+		return features;
+
+	if (unlikely(skb_inner_mac_header(skb) - skb_transport_header(skb) >
+		     IXGBE_MAX_TUNNEL_HDR_LEN))
+		return features & ~NETIF_F_ALL_CSUM;
+
+	return features;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -8254,6 +8292,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
 	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
 	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
+	.ndo_features_check	= ixgbe_features_check,
 };
 
 /**
@@ -8613,6 +8652,9 @@ skip_sriov:
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
+	netdev->hw_enc_features |= NETIF_F_SG | NETIF_F_IP_CSUM |
+				   NETIF_F_IPV6_CSUM;
+
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
-- 
2.4.3
