From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/16] i40e: Add support for ATR w/ IPv6 extension headers
Date: Thu, 18 Feb 2016 16:31:21 -0800
Message-ID: <1455841881-128892-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965728AbcBSAbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:39 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch updates the code for determining the L4 protocol and L3 header
length so that when IPv6 extension headers are being used we can determine
the offset and type of the L4 protocol.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 159fb6e..1d3afa7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2044,7 +2044,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	struct tcphdr *th;
 	unsigned int hlen;
 	u32 flex_ptype, dtype_cmd;
-	u8 l4_proto;
+	int l4_proto;
 	u16 i;
 
 	/* make sure ATR is enabled */
@@ -2062,25 +2062,23 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (!(tx_flags & (I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6)))
 		return;
 
-	if (!(tx_flags & I40E_TX_FLAGS_UDP_TUNNEL)) {
-		/* snag network header to get L4 type and address */
-		hdr.network = skb_network_header(skb);
+	/* snag network header to get L4 type and address */
+	hdr.network = (tx_flags & I40E_TX_FLAGS_UDP_TUNNEL) ?
+		      skb_inner_network_header(skb) : skb_network_header(skb);
 
+	/* Note: tx_flags gets modified to reflect inner protocols in
+	 * tx_enable_csum function if encap is enabled.
+	 */
+	if (tx_flags & I40E_TX_FLAGS_IPV4) {
 		/* access ihl as u8 to avoid unaligned access on ia64 */
-		if (tx_flags & I40E_TX_FLAGS_IPV4)
-			hlen = (hdr.network[0] & 0x0F) << 2;
-		else
-			hlen = sizeof(struct ipv6hdr);
+		hlen = (hdr.network[0] & 0x0F) << 2;
+		l4_proto = hdr.ipv4->protocol;
 	} else {
-		hdr.network = skb_inner_network_header(skb);
-		hlen = skb_inner_network_header_len(skb);
+		hlen = hdr.network - skb->data;
+		l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
+		hlen -= hdr.network - skb->data;
 	}
 
-	/* Note: tx_flags gets modified to reflect inner protocols in
-	 * tx_enable_csum function if encap is enabled.
-	 */
-	l4_proto = (tx_flags & I40E_TX_FLAGS_IPV4) ? hdr.ipv4->protocol :
-						     hdr.ipv6->nexthdr;
 	if (l4_proto != IPPROTO_TCP)
 		return;
 
-- 
2.5.0
