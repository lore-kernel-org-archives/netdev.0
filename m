From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 23/24] ixgbe: xmit frame refactor
Date: Mon, 08 Sep 2008 21:48:33 -0700
Message-ID: <20080909044833.18904.36431.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:15187 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYIIEsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:35 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1350307waf.23
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:35 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
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
index 3f529b9..5efb072 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3219,8 +3219,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 	unsigned int i;
 	int err;
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
-	u32 mss_l4len_idx = 0, l4len;
+	u32 vlan_macip_lens = 0, type_tucmd_mlhl;
+	u32 mss_l4len_idx, l4len;
 
 	if (skb_is_gso(skb)) {
 		if (skb_header_cloned(skb)) {
@@ -3269,7 +3269,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->seqnum_seed = 0;
 
 		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
-		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
+		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->protocol == htons(ETH_P_IP))
@@ -3278,7 +3278,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
 
 		/* MSS L4LEN IDX */
-		mss_l4len_idx |=
+		mss_l4len_idx =
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
 		/* use index 1 for TSO */
@@ -3336,14 +3336,12 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
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
@@ -3360,6 +3358,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
+
 		adapter->hw_csum_tx_good++;
 		i++;
 		if (i == tx_ring->count)
@@ -3368,6 +3367,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		return true;
 	}
+
 	return false;
 }
 
@@ -3539,43 +3539,35 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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

