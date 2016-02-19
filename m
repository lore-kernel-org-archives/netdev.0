From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40e/i40evf: Enable support for SKB_GSO_UDP_TUNNEL_CSUM
Date: Thu, 18 Feb 2016 16:31:16 -0800
Message-ID: <1455841881-128892-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36360 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965714AbcBSAbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:36 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The XL722 has support for providing the outer UDP tunnel checksum on
transmits.  Make use of this feature to support segmenting UDP tunnels with
outer checksums enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 19 ++++++++++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 19 ++++++++++++++++++-
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index ded73c0..1955c84 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2272,6 +2272,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	} ip;
 	union {
 		struct tcphdr *tcp;
+		struct udphdr *udp;
 		unsigned char *hdr;
 	} l4;
 	u32 paylen, l4_offset;
@@ -2298,7 +2299,18 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) {
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+					 SKB_GSO_UDP_TUNNEL_CSUM)) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+			/* determine offset of outer transport header */
+			l4_offset = l4.hdr - skb->data;
+
+			/* remove payload length from outer checksum */
+			paylen = (__force u16)l4.udp->check;
+			paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+			l4.udp->check = ~csum_fold((__force __wsum)paylen);
+		}
+
 		/* reset pointers to inner headers */
 		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
@@ -2460,6 +2472,11 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
 			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
 
+		/* indicate if we need to offload outer UDP header */
+		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
+			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
+
 		/* record tunnel offload values */
 		*cd_tunneling |= tunnel;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 3f40e0e..6d66fcd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1532,6 +1532,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	} ip;
 	union {
 		struct tcphdr *tcp;
+		struct udphdr *udp;
 		unsigned char *hdr;
 	} l4;
 	u32 paylen, l4_offset;
@@ -1558,7 +1559,18 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) {
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+					 SKB_GSO_UDP_TUNNEL_CSUM)) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+			/* determine offset of outer transport header */
+			l4_offset = l4.hdr - skb->data;
+
+			/* remove payload length from outer checksum */
+			paylen = (__force u16)l4.udp->check;
+			paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+			l4.udp->check = ~csum_fold((__force __wsum)paylen);
+		}
+
 		/* reset pointers to inner headers */
 		ip.hdr = skb_inner_network_header(skb);
 		l4.hdr = skb_inner_transport_header(skb);
@@ -1678,6 +1690,11 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 		tunnel |= ((ip.hdr - l4.hdr) / 2) <<
 			  I40E_TXD_CTX_QW0_NATLEN_SHIFT;
 
+		/* indicate if we need to offload outer UDP header */
+		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
+			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
+
 		/* record tunnel offload values */
 		*cd_tunneling |= tunnel;
 
-- 
2.5.0
