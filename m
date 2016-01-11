From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 4/4] igbvf: Add support for generic Tx checksums
Date: Mon, 11 Jan 2016 09:54:15 -0800
Message-ID: <20160111175415.4101.60735.stgit@localhost.localdomain>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35341 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932895AbcAKRyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:54:18 -0500
Received: by mail-pf0-f176.google.com with SMTP id 65so48036407pff.2
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:54:18 -0800 (PST)
In-Reply-To: <20160111173724.4101.35798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for generic Tx checksums to the igbvf driver.  It
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
 drivers/net/ethernet/intel/igbvf/netdev.c |  142 +++++++++++++++++------------
 drivers/net/ethernet/intel/igbvf/vf.h     |    1 
 2 files changed, 82 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 297af801f051..ee6a75ee916c 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -43,6 +43,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <linux/sctp.h>
 
 #include "igbvf.h"
 
@@ -1908,6 +1909,31 @@ static void igbvf_watchdog_task(struct work_struct *work)
 #define IGBVF_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IGBVF_TX_FLAGS_VLAN_SHIFT	16
 
+static void igbvf_tx_ctxtdesc(struct igbvf_ring *tx_ring, u32 vlan_macip_lens,
+			      u32 type_tucmd, u32 mss_l4len_idx)
+{
+	struct e1000_adv_tx_context_desc *context_desc;
+	struct igbvf_buffer *buffer_info;
+	u16 i = tx_ring->next_to_use;
+
+	context_desc = IGBVF_TX_CTXTDESC_ADV(*tx_ring, i);
+	buffer_info = &tx_ring->buffer_info[i];
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
+
+	/* set bits to identify this as an advanced context descriptor */
+	type_tucmd |= E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT;
+
+	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
+	context_desc->seqnum_seed	= 0;
+	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);
+	context_desc->mss_l4len_idx	= cpu_to_le32(mss_l4len_idx);
+
+	buffer_info->time_stamp = jiffies;
+	buffer_info->dma = 0;
+}
+
 static int igbvf_tso(struct igbvf_adapter *adapter,
 		     struct igbvf_ring *tx_ring,
 		     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len,
@@ -1987,65 +2013,56 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 	return true;
 }
 
-static inline bool igbvf_tx_csum(struct igbvf_adapter *adapter,
-				 struct igbvf_ring *tx_ring,
-				 struct sk_buff *skb, u32 tx_flags,
-				 __be16 protocol)
+static inline bool igbvf_ipv6_csum_is_sctp(struct sk_buff *skb)
 {
-	struct e1000_adv_tx_context_desc *context_desc;
-	unsigned int i;
-	struct igbvf_buffer *buffer_info;
-	u32 info = 0, tu_cmd = 0;
-
-	if ((skb->ip_summed == CHECKSUM_PARTIAL) ||
-	    (tx_flags & IGBVF_TX_FLAGS_VLAN)) {
-		i = tx_ring->next_to_use;
-		buffer_info = &tx_ring->buffer_info[i];
-		context_desc = IGBVF_TX_CTXTDESC_ADV(*tx_ring, i);
+	unsigned int offset = 0;
 
-		if (tx_flags & IGBVF_TX_FLAGS_VLAN)
-			info |= (tx_flags & IGBVF_TX_FLAGS_VLAN_MASK);
+	ipv6_find_hdr(skb, &offset, IPPROTO_SCTP, NULL, NULL);
 
-		info |= (skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT);
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			info |= (skb_transport_header(skb) -
-				 skb_network_header(skb));
+	return offset == skb_checksum_start_offset(skb);
+}
 
-		context_desc->vlan_macip_lens = cpu_to_le32(info);
+static bool igbvf_tx_csum(struct igbvf_ring *tx_ring, struct sk_buff *skb,
+			  u32 tx_flags, __be16 protocol)
+{
+	u32 vlan_macip_lens = 0;
+	u32 type_tucmd = 0;
 
-		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+csum_failed:
+		if (!(tx_flags & IGBVF_TX_FLAGS_VLAN))
+			return false;
+		goto no_csum;
+	}
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			switch (protocol) {
-			case htons(ETH_P_IP):
-				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
-				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
-					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
-				break;
-			case htons(ETH_P_IPV6):
-				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
-					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
-				break;
-			default:
-				break;
-			}
+	switch (skb->csum_offset) {
+	case offsetof(struct tcphdr, check):
+		type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
+		/* fall through */
+	case offsetof(struct udphdr, check):
+		break;
+	case offsetof(struct sctphdr, checksum):
+		/* validate that this is actually an SCTP request */
+		if (((protocol == htons(ETH_P_IP)) &&
+		     (ip_hdr(skb)->protocol == IPPROTO_SCTP)) ||
+		    ((protocol == htons(ETH_P_IPV6)) &&
+		     igbvf_ipv6_csum_is_sctp(skb))) {
+			type_tucmd = E1000_ADVTXD_TUCMD_L4T_SCTP;
+			break;
 		}
-
-		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
-		context_desc->seqnum_seed = 0;
-		context_desc->mss_l4len_idx = 0;
-
-		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = 0;
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-		tx_ring->next_to_use = i;
-
-		return true;
+	default:
+		skb_checksum_help(skb);
+		goto csum_failed;
 	}
 
-	return false;
+	vlan_macip_lens = skb_checksum_start_offset(skb) -
+			  skb_network_offset(skb);
+no_csum:
+	vlan_macip_lens |= skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens |= tx_flags & IGBVF_TX_FLAGS_VLAN_MASK;
+
+	igbvf_tx_ctxtdesc(tx_ring, vlan_macip_lens, type_tucmd, 0);
+	return true;
 }
 
 static int igbvf_maybe_stop_tx(struct net_device *netdev, int size)
@@ -2264,7 +2281,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	if (tso)
 		tx_flags |= IGBVF_TX_FLAGS_TSO;
-	else if (igbvf_tx_csum(adapter, tx_ring, skb, tx_flags, protocol) &&
+	else if (igbvf_tx_csum(tx_ring, skb, tx_flags, protocol) &&
 		 (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IGBVF_TX_FLAGS_CSUM;
 
@@ -2717,11 +2734,11 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->bd_number = cards_found++;
 
 	netdev->hw_features = NETIF_F_SG |
-			   NETIF_F_IP_CSUM |
-			   NETIF_F_IPV6_CSUM |
-			   NETIF_F_TSO |
-			   NETIF_F_TSO6 |
-			   NETIF_F_RXCSUM;
+			      NETIF_F_TSO |
+			      NETIF_F_TSO6 |
+			      NETIF_F_RXCSUM |
+			      NETIF_F_HW_CSUM |
+			      NETIF_F_SCTP_CRC; 
 
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_CTAG_TX |
@@ -2731,11 +2748,14 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_TSO6;
-	netdev->vlan_features |= NETIF_F_IP_CSUM;
-	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
-	netdev->vlan_features |= NETIF_F_SG;
+	netdev->vlan_features |= NETIF_F_SG |
+				 NETIF_F_TSO |
+				 NETIF_F_TSO6 |
+				 NETIF_F_HW_CSUM |
+			         NETIF_F_SCTP_CRC;
+
+	netdev->mpls_features |= NETIF_F_HW_CSUM;
+	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
 
 	/*reset the controller to put the device in a known good state */
 	err = hw->mac.ops.reset_hw(hw);
diff --git a/drivers/net/ethernet/intel/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
index 0f1eca639f68..f00a41d9a1ca 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.h
+++ b/drivers/net/ethernet/intel/igbvf/vf.h
@@ -126,6 +126,7 @@ struct e1000_adv_tx_context_desc {
 #define E1000_ADVTXD_MACLEN_SHIFT	9  /* Adv ctxt desc mac len shift */
 #define E1000_ADVTXD_TUCMD_IPV4		0x00000400 /* IP Packet Type: 1=IPv4 */
 #define E1000_ADVTXD_TUCMD_L4T_TCP	0x00000800 /* L4 Packet TYPE of TCP */
+#define E1000_ADVTXD_TUCMD_L4T_SCTP	0x00001000 /* L4 packet TYPE of SCTP */
 #define E1000_ADVTXD_L4LEN_SHIFT	8  /* Adv ctxt L4LEN shift */
 #define E1000_ADVTXD_MSS_SHIFT		16 /* Adv ctxt MSS shift */
 
