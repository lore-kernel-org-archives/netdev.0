From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40e: Fix ATR in relation to tunnels
Date: Thu, 18 Feb 2016 16:31:17 -0800
Message-ID: <1455841881-128892-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965705AbcBSAbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:37 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch contains a number of fixes to make certain that we are using
the correct protocols when parsing both the inner and outer headers of a
frame that is mixed between IPv4 and IPv6 for inner and outer.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Acked-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1955c84..159fb6e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2030,10 +2030,9 @@ tx_only:
  * @tx_ring:  ring to add programming descriptor to
  * @skb:      send buffer
  * @tx_flags: send tx flags
- * @protocol: wire protocol
  **/
 static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		     u32 tx_flags, __be16 protocol)
+		     u32 tx_flags)
 {
 	struct i40e_filter_program_desc *fdir_desc;
 	struct i40e_pf *pf = tx_ring->vsi->back;
@@ -2045,6 +2044,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	struct tcphdr *th;
 	unsigned int hlen;
 	u32 flex_ptype, dtype_cmd;
+	u8 l4_proto;
 	u16 i;
 
 	/* make sure ATR is enabled */
@@ -2058,6 +2058,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	if (!tx_ring->atr_sample_rate)
 		return;
 
+	/* Currently only IPv4/IPv6 with TCP is supported */
 	if (!(tx_flags & (I40E_TX_FLAGS_IPV4 | I40E_TX_FLAGS_IPV6)))
 		return;
 
@@ -2065,29 +2066,22 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		/* snag network header to get L4 type and address */
 		hdr.network = skb_network_header(skb);
 
-		/* Currently only IPv4/IPv6 with TCP is supported
-		 * access ihl as u8 to avoid unaligned access on ia64
-		 */
+		/* access ihl as u8 to avoid unaligned access on ia64 */
 		if (tx_flags & I40E_TX_FLAGS_IPV4)
 			hlen = (hdr.network[0] & 0x0F) << 2;
-		else if (protocol == htons(ETH_P_IPV6))
-			hlen = sizeof(struct ipv6hdr);
 		else
-			return;
+			hlen = sizeof(struct ipv6hdr);
 	} else {
 		hdr.network = skb_inner_network_header(skb);
 		hlen = skb_inner_network_header_len(skb);
 	}
 
-	/* Currently only IPv4/IPv6 with TCP is supported
-	 * Note: tx_flags gets modified to reflect inner protocols in
+	/* Note: tx_flags gets modified to reflect inner protocols in
 	 * tx_enable_csum function if encap is enabled.
 	 */
-	if ((tx_flags & I40E_TX_FLAGS_IPV4) &&
-	    (hdr.ipv4->protocol != IPPROTO_TCP))
-		return;
-	else if ((tx_flags & I40E_TX_FLAGS_IPV6) &&
-		 (hdr.ipv6->nexthdr != IPPROTO_TCP))
+	l4_proto = (tx_flags & I40E_TX_FLAGS_IPV4) ? hdr.ipv4->protocol :
+						     hdr.ipv6->nexthdr;
+	if (l4_proto != IPPROTO_TCP)
 		return;
 
 	th = (struct tcphdr *)(hdr.network + hlen);
@@ -2124,7 +2118,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	flex_ptype = (tx_ring->queue_index << I40E_TXD_FLTR_QW0_QINDEX_SHIFT) &
 		      I40E_TXD_FLTR_QW0_QINDEX_MASK;
-	flex_ptype |= (protocol == htons(ETH_P_IP)) ?
+	flex_ptype |= (tx_flags & I40E_TX_FLAGS_IPV4) ?
 		      (I40E_FILTER_PCTYPE_NONF_IPV4_TCP <<
 		       I40E_TXD_FLTR_QW0_PCTYPE_SHIFT) :
 		      (I40E_FILTER_PCTYPE_NONF_IPV6_TCP <<
@@ -2992,7 +2986,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	 *
 	 * NOTE: this must always be directly before the data descriptor.
 	 */
-	i40e_atr(tx_ring, skb, tx_flags, protocol);
+	i40e_atr(tx_ring, skb, tx_flags);
 
 	i40e_tx_map(tx_ring, skb, first, tx_flags, hdr_len,
 		    td_cmd, td_offset);
-- 
2.5.0
