From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 1/4] ixgbe: Add support for generic Tx checksums
Date: Mon, 11 Jan 2016 09:53:56 -0800
Message-ID: <20160111175356.4101.8327.stgit@localhost.localdomain>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35461 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758757AbcAKRx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:53:58 -0500
Received: by mail-pa0-f51.google.com with SMTP id ho8so63876253pac.2
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:53:57 -0800 (PST)
In-Reply-To: <20160111173724.4101.35798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for generic Tx checksums to the ixgbe driver.  It
turns out this is actually pretty easy after going over the datasheet as we
were doing a number of steps we didn't need to.

In order to perform a Tx checksum for an L4 header we need to fill in the
following fields in the Tx descriptor:
  MACLEN (maximum of 127), retrieved from:
		skb_network_offset()
  IPLEN  (maximum of 511), retrieved from:
		skb_checksum_start_offset() - skb_network_offset()
  TUCMD.L4T indicates offset and if checksum or crc32c, based on:
		skb->csum_offset

The added advantage to doing this is that we can support inner checksum
offloads for tunnels and MPLS while still being able to transparently insert
VLAN tags.

I also took the opportunity to clean-up many of the feature flag
configuration bits to make them a bit more consistent between drivers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  163 +++++++++----------------
 1 file changed, 59 insertions(+), 104 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 77cdaed6de90..1e3a548cc612 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7207,103 +7207,61 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	return 1;
 }
 
+static inline bool ixgbe_ipv6_csum_is_sctp(struct sk_buff *skb)
+{
+	unsigned int offset = 0;
+
+	ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL);
+
+	return offset == skb_checksum_start_offset(skb);
+}
+
 static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 			  struct ixgbe_tx_buffer *first)
 {
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens = 0;
-	u32 mss_l4len_idx = 0;
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
-		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
+csum_failed:
+		if (!(first->tx_flags & (IXGBE_TX_FLAGS_HW_VLAN |
+					 IXGBE_TX_FLAGS_CC)))
 			return;
-		vlan_macip_lens = skb_network_offset(skb) <<
-				  IXGBE_ADVTXD_MACLEN_SHIFT;
-	} else {
-		u8 l4_hdr = 0;
-		union {
-			struct iphdr *ipv4;
-			struct ipv6hdr *ipv6;
-			u8 *raw;
-		} network_hdr;
-		union {
-			struct tcphdr *tcphdr;
-			u8 *raw;
-		} transport_hdr;
-		__be16 frag_off;
-
-		if (skb->encapsulation) {
-			network_hdr.raw = skb_inner_network_header(skb);
-			transport_hdr.raw = skb_inner_transport_header(skb);
-			vlan_macip_lens = skb_inner_network_offset(skb) <<
-					  IXGBE_ADVTXD_MACLEN_SHIFT;
-		} else {
-			network_hdr.raw = skb_network_header(skb);
-			transport_hdr.raw = skb_transport_header(skb);
-			vlan_macip_lens = skb_network_offset(skb) <<
-					  IXGBE_ADVTXD_MACLEN_SHIFT;
-		}
-
-		/* use first 4 bits to determine IP version */
-		switch (network_hdr.ipv4->version) {
-		case IPVERSION:
-			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
-			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
-			l4_hdr = network_hdr.ipv4->protocol;
-			break;
-		case 6:
-			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
-			l4_hdr = network_hdr.ipv6->nexthdr;
-			if (likely((transport_hdr.raw - network_hdr.raw) ==
-				   sizeof(struct ipv6hdr)))
-				break;
-			ipv6_skip_exthdr(skb, network_hdr.raw - skb->data +
-					      sizeof(struct ipv6hdr),
-					 &l4_hdr, &frag_off);
-			if (unlikely(frag_off))
-				l4_hdr = NEXTHDR_FRAGMENT;
-			break;
-		default:
-			break;
-		}
+		goto no_csum;
+	}
 
-		switch (l4_hdr) {
-		case IPPROTO_TCP:
-			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
-			mss_l4len_idx = (transport_hdr.tcphdr->doff * 4) <<
-					IXGBE_ADVTXD_L4LEN_SHIFT;
-			break;
-		case IPPROTO_SCTP:
-			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_SCTP;
-			mss_l4len_idx = sizeof(struct sctphdr) <<
-					IXGBE_ADVTXD_L4LEN_SHIFT;
-			break;
-		case IPPROTO_UDP:
-			mss_l4len_idx = sizeof(struct udphdr) <<
-					IXGBE_ADVTXD_L4LEN_SHIFT;
+	switch (skb->csum_offset) {
+	case offsetof(struct tcphdr, check):
+		type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
+		/* fall through */
+	case offsetof(struct udphdr, check):
+		break;
+	case offsetof(struct sctphdr, checksum):
+		/* validate that this is actually an SCTP request */
+		if (((first->protocol == htons(ETH_P_IP)) &&
+		     (ip_hdr(skb)->protocol == IPPROTO_SCTP)) ||
+		    ((first->protocol == htons(ETH_P_IPV6)) &&
+		     ixgbe_ipv6_csum_is_sctp(skb))) {
+			type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 			break;
-		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum, version=%d, l4 proto=%x\n",
-					 network_hdr.ipv4->version, l4_hdr);
-			}
-			skb_checksum_help(skb);
-			goto no_csum;
 		}
-
-		/* update TX checksum flag */
-		first->tx_flags |= IXGBE_TX_FLAGS_CSUM;
+		/* fall through */
+	default:
+		skb_checksum_help(skb);
+		goto csum_failed;
 	}
 
+	/* update TX checksum flag */
+	first->tx_flags |= IXGBE_TX_FLAGS_CSUM;
+	vlan_macip_lens = skb_checksum_start_offset(skb) -
+			  skb_network_offset(skb);
 no_csum:
 	/* vlan_macip_lens: MACLEN, VLAN tag */
+	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
-	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0,
-			  type_tucmd, mss_l4len_idx);
+	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0, type_tucmd, 0);
 }
 
 #define IXGBE_SET_FLAG(_input, _flag, _result) \
@@ -9012,40 +8970,37 @@ skip_sriov:
 
 #endif
 	netdev->features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_IPV6_CSUM |
-			   NETIF_F_HW_VLAN_CTAG_TX |
-			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
-			   NETIF_F_RXCSUM;
-
-	netdev->hw_features = netdev->features | NETIF_F_HW_L2FW_DOFFLOAD;
+			   NETIF_F_RXCSUM |
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_SCTP_CRC |
+			   NETIF_F_HW_VLAN_CTAG_TX |
+			   NETIF_F_HW_VLAN_CTAG_RX;
 
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-	case ixgbe_mac_X550:
-	case ixgbe_mac_X550EM_x:
+	if (hw->mac.type >= ixgbe_mac_82599EB)
 		netdev->features |= NETIF_F_SCTP_CRC;
-		netdev->hw_features |= NETIF_F_SCTP_CRC |
-				       NETIF_F_NTUPLE;
-		break;
-	default:
-		break;
-	}
 
-	netdev->hw_features |= NETIF_F_RXALL;
+	/* copy netdev features into list of user selectable features */
+	netdev->hw_features |= netdev->features;
+	netdev->hw_features |= NETIF_F_RXALL |
+			       NETIF_F_HW_L2FW_DOFFLOAD;
+
+	if (hw->mac.type >= ixgbe_mac_82599EB)
+		netdev->hw_features |= NETIF_F_NTUPLE;
+
+	/* set this bit last since it cannot be part of hw_features */
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_IP_CSUM;
-	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
-	netdev->vlan_features |= NETIF_F_SG;
+	netdev->vlan_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_HW_CSUM |
+				 NETIF_F_SCTP_CRC;
 
-	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
