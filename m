From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbe: Cleanup FCOE and VLAN handling in xmit_frame_ring
Date: Fri, 19 Aug 2011 06:11:26 -0700
Message-ID: <1313759486-23575-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30602 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab1HSNLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:11:31 -0400
In-Reply-To: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to further cleanup the transmit path by streamlining
some of the VLAN and FCOE/DCB tasks in the transmit path.  In addition it
adds code for support software VLANs in the event that they are used in
conjunction with DCB and/or FCOE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   16 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  108 +++++++++++++++----------
 2 files changed, 73 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a12fd9f..378ce46 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -91,14 +91,16 @@
 #define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
 #define IXGBE_TX_FLAGS_CSUM		(u32)(1)
-#define IXGBE_TX_FLAGS_VLAN		(u32)(1 << 1)
-#define IXGBE_TX_FLAGS_TSO		(u32)(1 << 2)
-#define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
-#define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 4)
-#define IXGBE_TX_FLAGS_FSO		(u32)(1 << 5)
-#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 6)
+#define IXGBE_TX_FLAGS_HW_VLAN		(u32)(1 << 1)
+#define IXGBE_TX_FLAGS_SW_VLAN		(u32)(1 << 2)
+#define IXGBE_TX_FLAGS_TSO		(u32)(1 << 3)
+#define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 4)
+#define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 5)
+#define IXGBE_TX_FLAGS_FSO		(u32)(1 << 6)
+#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 7)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
-#define IXGBE_TX_FLAGS_VLAN_PRIO_MASK   0x0000e000
+#define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
+#define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
 #define IXGBE_MAX_RSC_INT_RATE          162760
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9a2d2d4..44ded0c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6369,7 +6369,7 @@ static bool ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-	    if (!(tx_flags & IXGBE_TX_FLAGS_VLAN))
+	    if (!(tx_flags & IXGBE_TX_FLAGS_HW_VLAN))
 			return false;
 	} else {
 		u8 l4_hdr = 0;
@@ -6434,7 +6434,7 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 				      IXGBE_ADVTXD_DCMD_DEXT);
 
 	/* set HW vlan bit if vlan is present */
-	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
+	if (tx_flags & IXGBE_TX_FLAGS_HW_VLAN)
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
 
 	/* set segmentation enable bits for TSO/FSO */
@@ -6670,8 +6670,8 @@ static void ixgbe_atr(struct ixgbe_ring *ring, struct sk_buff *skb,
 
 	th = tcp_hdr(skb);
 
-	/* skip this packet since the socket is closing */
-	if (th->fin)
+	/* skip this packet since it is invalid or the socket is closing */
+	if (!th || th->fin)
 		return;
 
 	/* sample on all syn packets or once every atr sample count */
@@ -6696,7 +6696,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring, struct sk_buff *skb,
 	 * since src port and flex bytes occupy the same word XOR them together
 	 * and write the value to source port portion of compressed dword
 	 */
-	if (vlan_id)
+	if (tx_flags & (IXGBE_TX_FLAGS_SW_VLAN | IXGBE_TX_FLAGS_HW_VLAN))
 		common.port.src ^= th->dest ^ __constant_htons(ETH_P_8021Q);
 	else
 		common.port.src ^= th->dest ^ protocol;
@@ -6785,7 +6785,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	unsigned short f;
 #endif
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
-	__be16 protocol;
+	__be16 protocol = skb->protocol;
 	u8 hdr_len = 0;
 
 	/*
@@ -6806,59 +6806,79 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	protocol = vlan_get_protocol(skb);
-
+	/* if we have a HW VLAN tag being added default to the HW one */
 	if (vlan_tx_tag_present(skb)) {
-		tx_flags |= vlan_tx_tag_get(skb);
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
-			tx_flags |= tx_ring->dcb_tc << 13;
+		tx_flags |= vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_HW_VLAN;
+	/* else if it is a SW VLAN check the next protocol and store the tag */
+	} else if (protocol == __constant_htons(ETH_P_8021Q)) {
+		struct vlan_hdr *vhdr, _vhdr;
+		vhdr = skb_header_pointer(skb, ETH_HLEN, sizeof(_vhdr), &_vhdr);
+		if (!vhdr)
+			goto out_drop;
+
+		protocol = vhdr->h_vlan_encapsulated_proto;
+		tx_flags |= ntohs(vhdr->h_vlan_TCI) << IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
+	}
+
+	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+	    skb->priority != TC_PRIO_CONTROL) {
+		tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
+		tx_flags |= tx_ring->dcb_tc <<
+			    IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT;
+		if (tx_flags & IXGBE_TX_FLAGS_SW_VLAN) {
+			struct vlan_ethhdr *vhdr;
+			if (skb_header_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto out_drop;
+			vhdr = (struct vlan_ethhdr *)skb->data;
+			vhdr->h_vlan_TCI = htons(tx_flags >>
+						 IXGBE_TX_FLAGS_VLAN_SHIFT);
+		} else {
+			tx_flags |= IXGBE_TX_FLAGS_HW_VLAN;
 		}
-		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED &&
-		   skb->priority != TC_PRIO_CONTROL) {
-		tx_flags |= tx_ring->dcb_tc << 13;
-		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
 
-#ifdef IXGBE_FCOE
-	/* for FCoE with DCB, we force the priority to what
-	 * was specified by the switch */
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
-	    (protocol == htons(ETH_P_FCOE)))
-		tx_flags |= IXGBE_TX_FLAGS_FCOE;
-
-#endif
 	/* record the location of the first descriptor for this packet */
 	first = &tx_ring->tx_buffer_info[tx_ring->next_to_use];
 
-	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
 #ifdef IXGBE_FCOE
-		/* setup tx offload for FCoE */
+	/* setup tx offload for FCoE */
+	if ((protocol == __constant_htons(ETH_P_FCOE)) &&
+	    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
 		tso = ixgbe_fso(tx_ring, skb, tx_flags, &hdr_len);
 		if (tso < 0)
 			goto out_drop;
 		else if (tso)
-			tx_flags |= IXGBE_TX_FLAGS_FSO;
-#endif /* IXGBE_FCOE */
-	} else {
-		if (protocol == htons(ETH_P_IP))
-			tx_flags |= IXGBE_TX_FLAGS_IPV4;
-		tso = ixgbe_tso(tx_ring, skb, tx_flags, protocol, &hdr_len);
-		if (tso < 0)
-			goto out_drop;
-		else if (tso)
-			tx_flags |= IXGBE_TX_FLAGS_TSO;
-		else if (ixgbe_tx_csum(tx_ring, skb, tx_flags, protocol))
-			tx_flags |= IXGBE_TX_FLAGS_CSUM;
+			tx_flags |= IXGBE_TX_FLAGS_FSO |
+				    IXGBE_TX_FLAGS_FCOE;
+		else
+			tx_flags |= IXGBE_TX_FLAGS_FCOE;
 
-		/* add the ATR filter if ATR is on */
-		if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
-			ixgbe_atr(tx_ring, skb, tx_flags, protocol);
+		goto xmit_fcoe;
 	}
 
+#endif /* IXGBE_FCOE */
+	/* setup IPv4/IPv6 offloads */
+	if (protocol == __constant_htons(ETH_P_IP))
+		tx_flags |= IXGBE_TX_FLAGS_IPV4;
+
+	tso = ixgbe_tso(tx_ring, skb, tx_flags, protocol, &hdr_len);
+	if (tso < 0)
+		goto out_drop;
+	else if (tso)
+		tx_flags |= IXGBE_TX_FLAGS_TSO;
+	else if (ixgbe_tx_csum(tx_ring, skb, tx_flags, protocol))
+		tx_flags |= IXGBE_TX_FLAGS_CSUM;
+
+	/* add the ATR filter if ATR is on */
+	if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
+		ixgbe_atr(tx_ring, skb, tx_flags, protocol);
+
+#ifdef IXGBE_FCOE
+xmit_fcoe:
+#endif /* IXGBE_FCOE */
 	ixgbe_tx_map(tx_ring, skb, first, tx_flags, hdr_len);
 
 	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
-- 
1.7.6

