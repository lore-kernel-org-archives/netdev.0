From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/14] i40e/i40evf: Add support for IPIP and SIT offloads
Date: Wed, 27 Apr 2016 13:15:41 -0700
Message-ID: <1461788153-12869-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1226 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbcD0UQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:29 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Looking over the documentation it turns out enabling IPIP and SIT offloads
for i40e is pretty straightforward.  As such I decided to enable them with
this patch.  In my testing I am seeing an improvement of 8 to 10 Gb/s
for IPIP and SIT tunnels with this offload enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 24 ++++++++++++++++--------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 24 ++++++++++++++++--------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  2 ++
 4 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f2e83fe..ec94ad6c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9120,6 +9120,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 				   NETIF_F_TSO_ECN		|
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
+				   NETIF_F_GSO_IPIP		|
+				   NETIF_F_GSO_SIT		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_SCTP_CRC		|
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 39efba0..6e44cf1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2299,7 +2299,10 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_IPIP |
+					 SKB_GSO_SIT |
+					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
 			/* determine offset of outer transport header */
@@ -2442,13 +2445,6 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 						 &l4_proto, &frag_off);
 		}
 
-		/* compute outer L3 header size */
-		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
-			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
-
-		/* switch IP header pointer from outer to inner header */
-		ip.hdr = skb_inner_network_header(skb);
-
 		/* define outer transport */
 		switch (l4_proto) {
 		case IPPROTO_UDP:
@@ -2459,6 +2455,11 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			tunnel |= I40E_TXD_CTX_GRE_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
 			break;
+		case IPPROTO_IPIP:
+		case IPPROTO_IPV6:
+			*tx_flags |= I40E_TX_FLAGS_UDP_TUNNEL;
+			l4.hdr = skb_inner_network_header(skb);
+			break;
 		default:
 			if (*tx_flags & I40E_TX_FLAGS_TSO)
 				return -1;
@@ -2467,6 +2468,13 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			return 0;
 		}
 
+		/* compute outer L3 header size */
+		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
+			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
+
+		/* switch IP header pointer from outer to inner header */
+		ip.hdr = skb_inner_network_header(skb);
+
 		/* compute tunnel header size */
 		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
 			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index fc22818..f101895 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1564,7 +1564,10 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_IPIP |
+					 SKB_GSO_SIT |
+					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
 			/* determine offset of outer transport header */
@@ -1665,13 +1668,6 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 						 &l4_proto, &frag_off);
 		}
 
-		/* compute outer L3 header size */
-		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
-			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
-
-		/* switch IP header pointer from outer to inner header */
-		ip.hdr = skb_inner_network_header(skb);
-
 		/* define outer transport */
 		switch (l4_proto) {
 		case IPPROTO_UDP:
@@ -1682,6 +1678,11 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			tunnel |= I40E_TXD_CTX_GRE_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
+		case IPPROTO_IPIP:
+		case IPPROTO_IPV6:
+			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
+			l4.hdr = skb_inner_network_header(skb);
+			break;
 		default:
 			if (*tx_flags & I40E_TX_FLAGS_TSO)
 				return -1;
@@ -1690,6 +1691,13 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			return 0;
 		}
 
+		/* compute outer L3 header size */
+		tunnel |= ((l4.hdr - ip.hdr) / 4) <<
+			  I40E_TXD_CTX_QW0_EXT_IPLEN_SHIFT;
+
+		/* switch IP header pointer from outer to inner header */
+		ip.hdr = skb_inner_network_header(skb);
+
 		/* compute tunnel header size */
 		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
 			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e3857d8..806da26 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2346,6 +2346,8 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				   NETIF_F_TSO_ECN		|
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
+				   NETIF_F_GSO_IPIP		|
+				   NETIF_F_GSO_SIT		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_SCTP_CRC		|
-- 
2.5.5
