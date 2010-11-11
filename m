From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-2.6 v2 3/3] ixgbe: Look inside vlan when determining offload protocol.
Date: Thu, 11 Nov 2010 15:47:59 -0800
Message-ID: <1289519279-20641-3-git-send-email-jesse@nicira.com>
References: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, Hao Zheng <hzheng@nicira.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49442 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099Ab0KKXsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 18:48:11 -0500
Received: by mail-vw0-f46.google.com with SMTP id 13so732754vws.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 15:48:10 -0800 (PST)
In-Reply-To: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hao Zheng <hzheng@nicira.com>

Currently the skb->protocol field is used to setup various
offloading parameters on transmit for the correct protocol.
However, if vlan offloading is disabled or otherwise not used,
the protocol field will be ETH_P_8021Q, not the actual protocol.
This will cause the offloading to be not performed correctly,
even though the hardware is capable of looking inside vlan tags.
Instead, look inside the header if necessary to determine the
correct protocol type.

To some extent this fixes a regression from 2.6.36 because it
was previously not possible to disable vlan offloading and this
error case was not exposed.

Signed-off-by: Hao Zheng <hzheng@nicira.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Alex Duyck <alexander.h.duyck@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
--
Unchanged from v1.
---
 drivers/net/ixgbe/ixgbe_main.c |   60 +++++++++++++++++++++------------------
 1 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2bd3eb4..fbad4d8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -764,8 +764,9 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 #ifdef IXGBE_FCOE
 				/* adjust for FCoE Sequence Offload */
 				if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
-				    && (skb->protocol == htons(ETH_P_FCOE)) &&
-				    skb_is_gso(skb)) {
+				    && skb_is_gso(skb)
+				    && vlan_get_protocol(skb) ==
+				    htons(ETH_P_FCOE)) {
 					hlen = skb_transport_offset(skb) +
 						sizeof(struct fc_frame_header) +
 						sizeof(struct fcoe_crc_eof);
@@ -5823,7 +5824,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
-		     u32 tx_flags, u8 *hdr_len)
+		     u32 tx_flags, u8 *hdr_len, __be16 protocol)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -5841,7 +5842,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		l4len = tcp_hdrlen(skb);
 		*hdr_len += l4len;
 
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
 			iph->tot_len = 0;
 			iph->check = 0;
@@ -5880,7 +5881,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
 				   IXGBE_ADVTXD_DTYP_CTXT);
 
-		if (skb->protocol == htons(ETH_P_IP))
+		if (protocol == htons(ETH_P_IP))
 			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 		type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
@@ -5906,16 +5907,10 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 	return false;
 }
 
-static u32 ixgbe_psum(struct ixgbe_adapter *adapter, struct sk_buff *skb)
+static u32 ixgbe_psum(struct ixgbe_adapter *adapter, struct sk_buff *skb,
+		      __be16 protocol)
 {
 	u32 rtn = 0;
-	__be16 protocol;
-
-	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
-		protocol = ((const struct vlan_ethhdr *)skb->data)->
-					h_vlan_encapsulated_proto;
-	else
-		protocol = skb->protocol;
 
 	switch (protocol) {
 	case cpu_to_be16(ETH_P_IP):
@@ -5943,7 +5938,7 @@ static u32 ixgbe_psum(struct ixgbe_adapter *adapter, struct sk_buff *skb)
 	default:
 		if (unlikely(net_ratelimit()))
 			e_warn(probe, "partial checksum but proto=%x!\n",
-			       skb->protocol);
+			       protocol);
 		break;
 	}
 
@@ -5952,7 +5947,8 @@ static u32 ixgbe_psum(struct ixgbe_adapter *adapter, struct sk_buff *skb)
 
 static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring,
-			  struct sk_buff *skb, u32 tx_flags)
+			  struct sk_buff *skb, u32 tx_flags,
+			  __be16 protocol)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -5981,7 +5977,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			type_tucmd_mlhl |= ixgbe_psum(adapter, skb);
+			type_tucmd_mlhl |= ixgbe_psum(adapter, skb, protocol);
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
 		/* use index zero for tx checksum offload */
@@ -6179,7 +6175,7 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 }
 
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
-		      int queue, u32 tx_flags)
+		      int queue, u32 tx_flags, __be16 protocol)
 {
 	struct ixgbe_atr_input atr_input;
 	struct tcphdr *th;
@@ -6190,7 +6186,7 @@ static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
 	u8 l4type = 0;
 
 	/* Right now, we support IPv4 only */
-	if (skb->protocol != htons(ETH_P_IP))
+	if (protocol != htons(ETH_P_IP))
 		return;
 	/* check if we're UDP or TCP */
 	if (iph->protocol == IPPROTO_TCP) {
@@ -6257,10 +6253,13 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	int txq = smp_processor_id();
-
 #ifdef IXGBE_FCOE
-	if ((skb->protocol == htons(ETH_P_FCOE)) ||
-	    (skb->protocol == htons(ETH_P_FIP))) {
+	__be16 protocol;
+
+	protocol = vlan_get_protocol(skb);
+
+	if ((protocol == htons(ETH_P_FCOE)) ||
+	    (protocol == htons(ETH_P_FIP))) {
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 			txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
 			txq += adapter->ring_feature[RING_F_FCOE].mask;
@@ -6303,6 +6302,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 	int tso;
 	int count = 0;
 	unsigned int f;
+	__be16 protocol;
+
+	protocol = vlan_get_protocol(skb);
 
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
@@ -6323,8 +6325,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 	/* for FCoE with DCB, we force the priority to what
 	 * was specified by the switch */
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
-	    (skb->protocol == htons(ETH_P_FCOE) ||
-	     skb->protocol == htons(ETH_P_FIP))) {
+	    (protocol == htons(ETH_P_FCOE) ||
+	     protocol == htons(ETH_P_FIP))) {
 #ifdef CONFIG_IXGBE_DCB
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
@@ -6334,7 +6336,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 		}
 #endif
 		/* flag for FCoE offloads */
-		if (skb->protocol == htons(ETH_P_FCOE))
+		if (protocol == htons(ETH_P_FCOE))
 			tx_flags |= IXGBE_TX_FLAGS_FCOE;
 	}
 #endif
@@ -6368,9 +6370,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 			tx_flags |= IXGBE_TX_FLAGS_FSO;
 #endif /* IXGBE_FCOE */
 	} else {
-		if (skb->protocol == htons(ETH_P_IP))
+		if (protocol == htons(ETH_P_IP))
 			tx_flags |= IXGBE_TX_FLAGS_IPV4;
-		tso = ixgbe_tso(adapter, tx_ring, skb, tx_flags, &hdr_len);
+		tso = ixgbe_tso(adapter, tx_ring, skb, tx_flags, &hdr_len,
+				protocol);
 		if (tso < 0) {
 			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
@@ -6378,7 +6381,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 
 		if (tso)
 			tx_flags |= IXGBE_TX_FLAGS_TSO;
-		else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
+		else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags,
+				       protocol) &&
 			 (skb->ip_summed == CHECKSUM_PARTIAL))
 			tx_flags |= IXGBE_TX_FLAGS_CSUM;
 	}
@@ -6392,7 +6396,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 			     test_bit(__IXGBE_FDIR_INIT_DONE,
 				      &tx_ring->reinit_state)) {
 				ixgbe_atr(adapter, skb, tx_ring->queue_index,
-					  tx_flags);
+					  tx_flags, protocol);
 				tx_ring->atr_count = 0;
 			}
 		}
-- 
1.7.1

