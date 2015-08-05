From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e/i40evf: Add TX/RX outer UDP checksum support for X722
Date: Wed,  5 Aug 2015 16:52:07 -0700
Message-ID: <1438818735-38115-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11984 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672AbbHEXwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:19 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 supports offloading of outer UDP TX and RX checksum for tunneled
packets. This patch exposes the support and leaves it enabled by
default.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 16 +++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 10 ++++++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 13 +++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 10 ++++++++--
 7 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 28f547c..d9cb87f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7073,6 +7073,8 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 		tx_ring->dcb_tc = 0;
 		if (vsi->back->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
 			tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
+		if (vsi->back->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
+			tx_ring->flags |= I40E_TXR_FLAGS_OUTER_UDP_CSUM;
 		vsi->tx_rings[i] = tx_ring;
 
 		rx_ring = &tx_ring[1];
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 7d0a5ea..57dc5d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1429,7 +1429,8 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	 * so the total length of IPv4 header is IHL*4 bytes
 	 * The UDP_0 bit *may* bet set if the *inner* header is UDP
 	 */
-	if (ipv4_tunnel) {
+	if (!(vsi->back->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE) &&
+	    (ipv4_tunnel)) {
 		skb->transport_header = skb->mac_header +
 					sizeof(struct ethhdr) +
 					(ip_hdr(skb)->ihl * 4);
@@ -2301,11 +2302,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	struct iphdr *this_ip_hdr;
 	u32 network_hdr_len;
 	u8 l4_hdr = 0;
+	struct udphdr *oudph;
+	struct iphdr *oiph;
 	u32 l4_tunnel = 0;
 
 	if (skb->encapsulation) {
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
+			oudph = udp_hdr(skb);
+			oiph = ip_hdr(skb);
 			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
@@ -2342,6 +2347,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 			*tx_flags &= ~I40E_TX_FLAGS_IPV4;
 			*tx_flags |= I40E_TX_FLAGS_IPV6;
 		}
+		if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
+		    (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
+		    (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
+			oudph->check = ~csum_tcpudp_magic(oiph->saddr,
+					oiph->daddr,
+					(skb->len - skb_transport_offset(skb)),
+					IPPROTO_UDP, 0);
+			*cd_tunneling |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
+		}
 	} else {
 		network_hdr_len = skb_network_header_len(skb);
 		this_ip_hdr = ip_hdr(skb);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 0e40994..f1385a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -267,6 +267,8 @@ struct i40e_ring {
 
 	u16 flags;
 #define I40E_TXR_FLAGS_WB_ON_ITR	BIT(0)
+#define I40E_TXR_FLAGS_OUTER_UDP_CSUM	BIT(1)
+
 	/* stats structs */
 	struct i40e_queue_stats	stats;
 	struct u64_stats_sync syncp;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 1ffd271..b93357d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -607,14 +607,18 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_CRCP_SHIFT		= 4,
 	I40E_RX_DESC_STATUS_TSYNINDX_SHIFT	= 5, /* 2 BITS */
 	I40E_RX_DESC_STATUS_TSYNVALID_SHIFT	= 7,
-	I40E_RX_DESC_STATUS_PIF_SHIFT		= 8,
+	/* Note: Bit 8 is reserved in X710 and XL710 */
+	I40E_RX_DESC_STATUS_EXT_UDP_0_SHIFT	= 8,
 	I40E_RX_DESC_STATUS_UMBCAST_SHIFT	= 9, /* 2 BITS */
 	I40E_RX_DESC_STATUS_FLM_SHIFT		= 11,
 	I40E_RX_DESC_STATUS_FLTSTAT_SHIFT	= 12, /* 2 BITS */
 	I40E_RX_DESC_STATUS_LPBK_SHIFT		= 14,
 	I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT	= 15,
 	I40E_RX_DESC_STATUS_RESERVED_SHIFT	= 16, /* 2 BITS */
-	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18,
+	/* Note: For non-tunnel packets INT_UDP_0 is the right status for
+	 * UDP header
+	 */
+	I40E_RX_DESC_STATUS_INT_UDP_0_SHIFT	= 18,
 	I40E_RX_DESC_STATUS_LAST /* this entry must be last!!! */
 };
 
@@ -955,6 +959,8 @@ enum i40e_tx_ctx_desc_eipt_offload {
 #define I40E_TXD_CTX_QW0_DECTTL_MASK	(0xFULL << \
 					 I40E_TXD_CTX_QW0_DECTTL_SHIFT)
 
+#define I40E_TXD_CTX_QW0_L4T_CS_SHIFT	23
+#define I40E_TXD_CTX_QW0_L4T_CS_MASK	BIT_ULL(I40E_TXD_CTX_QW0_L4T_CS_SHIFT)
 struct i40e_filter_program_desc {
 	__le32 qindex_flex_ptype_vsi;
 	__le32 rsvd;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 6dbcbca..7309479 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1528,11 +1528,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 	struct iphdr *this_ip_hdr;
 	u32 network_hdr_len;
 	u8 l4_hdr = 0;
+	struct udphdr *oudph;
+	struct iphdr *oiph;
 	u32 l4_tunnel = 0;
 
 	if (skb->encapsulation) {
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
+			oudph = udp_hdr(skb);
+			oiph = ip_hdr(skb);
 			l4_tunnel = I40E_TXD_CTX_UDP_TUNNELING;
 			*tx_flags |= I40E_TX_FLAGS_VXLAN_TUNNEL;
 			break;
@@ -1571,6 +1575,15 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		}
 
 
+		if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
+		    (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
+		    (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
+			oudph->check = ~csum_tcpudp_magic(oiph->saddr,
+					oiph->daddr,
+					(skb->len - skb_transport_offset(skb)),
+					IPPROTO_UDP, 0);
+			*cd_tunneling |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
+		}
 	} else {
 		network_hdr_len = skb_network_header_len(skb);
 		this_ip_hdr = ip_hdr(skb);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 17bb59d..9a30f5d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -264,6 +264,8 @@ struct i40e_ring {
 
 	u16 flags;
 #define I40E_TXR_FLAGS_WB_ON_ITR	BIT(0)
+#define I40E_TXR_FLAGS_OUTER_UDP_CSUM	BIT(1)
+
 	/* stats structs */
 	struct i40e_queue_stats	stats;
 	struct u64_stats_sync syncp;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 627bf76..e32dc0b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -601,14 +601,18 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_CRCP_SHIFT		= 4,
 	I40E_RX_DESC_STATUS_TSYNINDX_SHIFT	= 5, /* 2 BITS */
 	I40E_RX_DESC_STATUS_TSYNVALID_SHIFT	= 7,
-	I40E_RX_DESC_STATUS_PIF_SHIFT		= 8,
+	/* Note: Bit 8 is reserved in X710 and XL710 */
+	I40E_RX_DESC_STATUS_EXT_UDP_0_SHIFT	= 8,
 	I40E_RX_DESC_STATUS_UMBCAST_SHIFT	= 9, /* 2 BITS */
 	I40E_RX_DESC_STATUS_FLM_SHIFT		= 11,
 	I40E_RX_DESC_STATUS_FLTSTAT_SHIFT	= 12, /* 2 BITS */
 	I40E_RX_DESC_STATUS_LPBK_SHIFT		= 14,
 	I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT	= 15,
 	I40E_RX_DESC_STATUS_RESERVED_SHIFT	= 16, /* 2 BITS */
-	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18,
+	/* Note: For non-tunnel packets INT_UDP_0 is the right status for
+	 * UDP header
+	 */
+	I40E_RX_DESC_STATUS_INT_UDP_0_SHIFT	= 18,
 	I40E_RX_DESC_STATUS_LAST /* this entry must be last!!! */
 };
 
@@ -949,6 +953,8 @@ enum i40e_tx_ctx_desc_eipt_offload {
 #define I40E_TXD_CTX_QW0_DECTTL_MASK	(0xFULL << \
 					 I40E_TXD_CTX_QW0_DECTTL_SHIFT)
 
+#define I40E_TXD_CTX_QW0_L4T_CS_SHIFT	23
+#define I40E_TXD_CTX_QW0_L4T_CS_MASK	BIT_ULL(I40E_TXD_CTX_QW0_L4T_CS_SHIFT)
 struct i40e_filter_program_desc {
 	__le32 qindex_flex_ptype_vsi;
 	__le32 rsvd;
-- 
2.4.3
