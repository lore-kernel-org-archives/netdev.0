From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v4 4/5] ixgbe: Adding tx encapsulation capability
Date: Fri,  7 Dec 2012 16:14:17 -0800
Message-ID: <1354925658-24115-5-git-send-email-joseph.gasparakis@intel.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com,
	bhutchings@solarflare.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows ixgbe to recognize encapsulated packets and do the tx
checksum offload in hardware. This patch is only for demonstration
purposes and should not be applied.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 46 +++++++++++++++++++++------
 1 file changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fb165b6..62a7d6e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5972,17 +5972,42 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 			if (!(first->tx_flags & IXGBE_TX_FLAGS_TXSW))
 				return;
 		}
+		vlan_macip_lens |= skb_network_offset(skb)
+				   << IXGBE_ADVTXD_MACLEN_SHIFT;
 	} else {
 		u8 l4_hdr = 0;
-		switch (first->protocol) {
-		case __constant_htons(ETH_P_IP):
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
+			vlan_macip_lens |= skb_inner_network_offset(skb) <<
+					   IXGBE_ADVTXD_MACLEN_SHIFT;
+		} else {
+			network_hdr.raw = skb_network_header(skb);
+			transport_hdr.raw = skb_transport_header(skb);
+			vlan_macip_lens |= skb_network_offset(skb) <<
+					   IXGBE_ADVTXD_MACLEN_SHIFT;
+		}
+
+		/* use first 4 bits to determine IP version */
+		switch (network_hdr.ipv4->version) {
+		case 4:
+			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
-			l4_hdr = ip_hdr(skb)->protocol;
+			l4_hdr = network_hdr.ipv4->protocol;
 			break;
-		case __constant_htons(ETH_P_IPV6):
-			vlan_macip_lens |= skb_network_header_len(skb);
-			l4_hdr = ipv6_hdr(skb)->nexthdr;
+		case 6:
+			vlan_macip_lens |= transport_hdr.raw - network_hdr.raw;
+			l4_hdr = network_hdr.ipv6->nexthdr;
 			break;
 		default:
 			if (unlikely(net_ratelimit())) {
@@ -5996,7 +6021,7 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		switch (l4_hdr) {
 		case IPPROTO_TCP:
 			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
-			mss_l4len_idx = tcp_hdrlen(skb) <<
+			mss_l4len_idx = (transport_hdr.tcphdr->doff * 4) <<
 					IXGBE_ADVTXD_L4LEN_SHIFT;
 			break;
 		case IPPROTO_SCTP:
@@ -6022,7 +6047,6 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	}
 
 	/* vlan_macip_lens: MACLEN, VLAN tag */
-	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
 	vlan_macip_lens |= first->tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
 
 	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, 0,
@@ -7383,6 +7407,10 @@ static int ixgbe_probe(struct pci_dev *pdev,
 
 	netdev->hw_features = netdev->features;
 
+	netdev->hw_enc_features = NETIF_F_IP_CSUM |
+				  NETIF_F_IPV6_CSUM |
+				  NETIF_F_SG;
+
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-- 
1.7.11.7
