From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 3/4] igb: Add support for generic Tx checksums
Date: Mon, 11 Jan 2016 09:54:09 -0800
Message-ID: <20160111175409.4101.73461.stgit@localhost.localdomain>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34780 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760962AbcAKRyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:54:10 -0500
Received: by mail-pf0-f171.google.com with SMTP id q63so49458612pfb.1
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:54:10 -0800 (PST)
In-Reply-To: <20160111173724.4101.35798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for generic Tx checksums to the igb driver.  It
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
 drivers/net/ethernet/intel/igb/igb_main.c |  114 ++++++++++++-----------------
 1 file changed, 47 insertions(+), 67 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ade8dee55fb8..8cd71cf39001 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2437,37 +2437,35 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * assignment.
 	 */
 	netdev->features |= NETIF_F_SG |
-			    NETIF_F_IP_CSUM |
-			    NETIF_F_IPV6_CSUM |
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
 			    NETIF_F_RXHASH |
 			    NETIF_F_RXCSUM |
+			    NETIF_F_HW_CSUM |
 			    NETIF_F_HW_VLAN_CTAG_RX |
 			    NETIF_F_HW_VLAN_CTAG_TX;
 
+	if (hw->mac.type >= e1000_82576)
+		netdev->features |= NETIF_F_SCTP_CRC;
+
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
 	netdev->hw_features |= NETIF_F_RXALL;
 
+	if (hw->mac.type >= e1000_i350)
+		netdev->hw_features |= NETIF_F_NTUPLE;
+
 	/* set this bit last since it cannot be part of hw_features */
 	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	netdev->vlan_features |= NETIF_F_TSO |
+	netdev->vlan_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
 				 NETIF_F_TSO6 |
-				 NETIF_F_IP_CSUM |
-				 NETIF_F_IPV6_CSUM |
-				 NETIF_F_SG;
+				 NETIF_F_HW_CSUM |
+				 NETIF_F_SCTP_CRC;
 
-	switch (hw->mac.type) {
-	case e1000_i210:
-	case e1000_i211:
-	case e1000_i350:
-		netdev->hw_features |= NETIF_F_NTUPLE;
-		break;
-	default:
-		break;
-	}
+	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
 
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
@@ -2476,11 +2474,6 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
-	if (hw->mac.type >= e1000_82576) {
-		netdev->hw_features |= NETIF_F_SCTP_CRC;
-		netdev->features |= NETIF_F_SCTP_CRC;
-	}
-
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(hw);
@@ -4967,70 +4960,57 @@ static int igb_tso(struct igb_ring *tx_ring,
 	return 1;
 }
 
+static inline bool igb_ipv6_csum_is_sctp(struct sk_buff *skb)
+{
+	unsigned int offset = 0;
+
+	ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL);
+
+	return offset == skb_checksum_start_offset(skb);
+}
+
 static void igb_tx_csum(struct igb_ring *tx_ring, struct igb_tx_buffer *first)
 {
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens = 0;
-	u32 mss_l4len_idx = 0;
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+csum_failed:
 		if (!(first->tx_flags & IGB_TX_FLAGS_VLAN))
 			return;
-	} else {
-		u8 l4_hdr = 0;
-
-		switch (first->protocol) {
-		case htons(ETH_P_IP):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
-			l4_hdr = ip_hdr(skb)->protocol;
-			break;
-		case htons(ETH_P_IPV6):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			l4_hdr = ipv6_hdr(skb)->nexthdr;
-			break;
-		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum but proto=%x!\n",
-					 first->protocol);
-			}
-			break;
-		}
+		goto no_csum;
+	}
 
-		switch (l4_hdr) {
-		case IPPROTO_TCP:
-			type_tucmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
-			mss_l4len_idx = tcp_hdrlen(skb) <<
-					E1000_ADVTXD_L4LEN_SHIFT;
-			break;
-		case IPPROTO_SCTP:
-			type_tucmd |= E1000_ADVTXD_TUCMD_L4T_SCTP;
-			mss_l4len_idx = sizeof(struct sctphdr) <<
-					E1000_ADVTXD_L4LEN_SHIFT;
-			break;
-		case IPPROTO_UDP:
-			mss_l4len_idx = sizeof(struct udphdr) <<
-					E1000_ADVTXD_L4LEN_SHIFT;
-			break;
-		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum but l4 proto=%x!\n",
-					 l4_hdr);
-			}
+	switch (skb->csum_offset) {
+	case offsetof(struct tcphdr, check):
+		type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
+		/* fall through */
+	case offsetof(struct udphdr, check):
+		break;
+	case offsetof(struct sctphdr, checksum):
+		/* validate that this is actually an SCTP request */
+		if (((first->protocol == htons(ETH_P_IP)) &&
+		     (ip_hdr(skb)->protocol == IPPROTO_SCTP)) ||
+		    ((first->protocol == htons(ETH_P_IPV6)) &&
+		     igb_ipv6_csum_is_sctp(skb))) {
+			type_tucmd = E1000_ADVTXD_TUCMD_L4T_SCTP;
 			break;
 		}
-
-		/* update TX checksum flag */
-		first->tx_flags |= IGB_TX_FLAGS_CSUM;
+	default:
+		skb_checksum_help(skb);
+		goto csum_failed;
 	}
 
+	/* update TX checksum flag */
+	first->tx_flags |= IGB_TX_FLAGS_CSUM;
+	vlan_macip_lens = skb_checksum_start_offset(skb) -
+			  skb_network_offset(skb);
+no_csum:
 	vlan_macip_lens |= skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IGB_TX_FLAGS_VLAN_MASK;
 
-	igb_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, mss_l4len_idx);
+	igb_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, 0);
 }
 
 #define IGB_SET_FLAG(_input, _flag, _result) \
