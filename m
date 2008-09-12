From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 23/29] ixgbe: xmit frame refactor
Date: Thu, 11 Sep 2008 20:03:35 -0700
Message-ID: <20080912030326.6234.755.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:44217 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbYILDDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:03:39 -0400
Received: by wa-out-1112.google.com with SMTP id j37so394015waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:03:39 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgbe_xmit_frame can be refactored to use fewer locals and better
utilize common kernel macros.

also fixed minor buglet with internal to driver vlan flag variable being
passed incorrectly.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   42 ++++++++++++++++------------------------
 1 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a215350..41aede5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3213,8 +3213,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 	unsigned int i;
 	int err;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
-	u32 mss_l4len_idx = 0, l4len;
+	u32 vlan_macip_lens = 0, type_tucmd_mlhl;
+	u32 mss_l4len_idx, l4len;
 
 	if (skb_is_gso(skb)) {
 		if (skb_header_cloned(skb)) {
@@ -3263,7 +3263,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->seqnum_seed = 0;
 
 		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
-		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
+		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->protocol == htons(ETH_P_IP))
@@ -3272,7 +3272,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
 
 		/* MSS L4LEN IDX */
-		mss_l4len_idx |=
+		mss_l4len_idx =
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
 		/* use index 1 for TSO */
@@ -3330,14 +3330,12 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 					type_tucmd_mlhl |=
 						IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
-
 			case __constant_htons(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
 						IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
-
 			default:
 				if (unlikely(net_ratelimit())) {
 					DPRINTK(PROBE, WARNING,
@@ -3354,6 +3352,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
+
 		adapter->hw_csum_tx_good++;
 		i++;
 		if (i == tx_ring->count)
@@ -3362,6 +3361,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		return true;
 	}
+
 	return false;
 }
 
@@ -3533,43 +3533,35 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
-	unsigned int len = skb->len;
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
 	int r_idx = 0, tso;
-	unsigned int mss = 0;
 	int count = 0;
 	unsigned int f;
-	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
-	len -= skb->data_len;
+
 	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
 	tx_ring = &adapter->tx_ring[r_idx];
 
-
-	if (skb->len <= 0) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		tx_flags |= vlan_tx_tag_get(skb);
+		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
-	mss = skb_shinfo(skb)->gso_size;
-
-	if (mss)
-		count++;
-	else if (skb->ip_summed == CHECKSUM_PARTIAL)
+	/* three things can cause us to need a context descriptor */
+	if (skb_is_gso(skb) ||
+	    (skb->ip_summed == CHECKSUM_PARTIAL) ||
+	    (tx_flags & IXGBE_TX_FLAGS_VLAN))
 		count++;
 
-	count += TXD_USE_COUNT(len);
-	for (f = 0; f < nr_frags; f++)
+	count += TXD_USE_COUNT(skb_headlen(skb));
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
 	if (ixgbe_maybe_stop_tx(netdev, tx_ring, count)) {
 		adapter->tx_busy++;
 		return NETDEV_TX_BUSY;
 	}
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
-		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
-	}
 
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= IXGBE_TX_FLAGS_IPV4;

