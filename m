From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 2/4] ixgbevf: Add support for generic Tx checksums
Date: Mon, 11 Jan 2016 09:54:02 -0800
Message-ID: <20160111175402.4101.60720.stgit@localhost.localdomain>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36000 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760940AbcAKRyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:54:04 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so232026784pab.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:54:04 -0800 (PST)
In-Reply-To: <20160111173724.4101.35798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for generic Tx checksums to the ixgbevf driver.  It
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
configuration bits to make them a bit more consistent between drivers.  In
the case of the VF drivers this meant adding support for SCTP CRCs, and
inner checksum offloads for MPLS and various tunnel types.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  104 +++++++++------------
 1 file changed, 43 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0b451d9eddb0..e58bebf6ea1d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3334,76 +3334,55 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	return 1;
 }
 
+static inline bool ixgbevf_ipv6_csum_is_sctp(struct sk_buff *skb)
+{
+	unsigned int offset = 0;
+
+	ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL);
+
+	return offset == skb_checksum_start_offset(skb);
+}
+
 static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 			    struct ixgbevf_tx_buffer *first)
 {
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens = 0;
-	u32 mss_l4len_idx = 0;
 	u32 type_tucmd = 0;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		u8 l4_hdr = 0;
-		__be16 frag_off;
-
-		switch (first->protocol) {
-		case htons(ETH_P_IP):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
-			l4_hdr = ip_hdr(skb)->protocol;
-			break;
-		case htons(ETH_P_IPV6):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			l4_hdr = ipv6_hdr(skb)->nexthdr;
-			if (likely(skb_network_header_len(skb) ==
-				   sizeof(struct ipv6hdr)))
-				break;
-			ipv6_skip_exthdr(skb, skb_network_offset(skb) +
-					      sizeof(struct ipv6hdr),
-					 &l4_hdr, &frag_off);
-			if (unlikely(frag_off))
-				l4_hdr = NEXTHDR_FRAGMENT;
-			break;
-		default:
-			break;
-		}
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		goto no_csum;
 
-		switch (l4_hdr) {
-		case IPPROTO_TCP:
-			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
-			mss_l4len_idx = tcp_hdrlen(skb) <<
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
+		     ixgbevf_ipv6_csum_is_sctp(skb))) {
+			type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 			break;
-		default:
-			if (unlikely(net_ratelimit())) {
-				dev_warn(tx_ring->dev,
-					 "partial checksum, l3 proto=%x, l4 proto=%x\n",
-					 first->protocol, l4_hdr);
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
+		goto no_csum;
 	}
-
+	/* update TX checksum flag */
+	first->tx_flags |= IXGBE_TX_FLAGS_CSUM;
+	vlan_macip_lens = skb_checksum_start_offset(skb) -
+			  skb_network_offset(skb);
 no_csum:
 	/* vlan_macip_lens: MACLEN, VLAN tag */
 	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
-	ixgbevf_tx_ctxtdesc(tx_ring, vlan_macip_lens,
-			    type_tucmd, mss_l4len_idx);
+	ixgbevf_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, 0);
 }
 
 static __le32 ixgbevf_tx_cmd_type(u32 tx_flags)
@@ -4006,22 +3985,25 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	netdev->hw_features = NETIF_F_SG |
-			      NETIF_F_IP_CSUM |
-			      NETIF_F_IPV6_CSUM |
 			      NETIF_F_TSO |
 			      NETIF_F_TSO6 |
-			      NETIF_F_RXCSUM;
+			      NETIF_F_RXCSUM |
+			      NETIF_F_HW_CSUM |
+			      NETIF_F_SCTP_CRC;
 
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
 			   NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	netdev->vlan_features |= NETIF_F_TSO |
+	netdev->vlan_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
 				 NETIF_F_TSO6 |
-				 NETIF_F_IP_CSUM |
-				 NETIF_F_IPV6_CSUM |
-				 NETIF_F_SG;
+				 NETIF_F_HW_CSUM |
+				 NETIF_F_SCTP_CRC;
+
+	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
 
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
