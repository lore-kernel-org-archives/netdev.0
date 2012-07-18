From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbevf: Consolidate Tx context descriptor creation code
Date: Wed, 18 Jul 2012 13:31:51 -0700
Message-ID: <1342643516-2696-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896Ab2GRUcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:02 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There is a good bit of redundancy between the Tx checksum and segmentation
offloads.  In order to reduce some of this I am moving the code for
creating a context descriptor into a separate function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  342 ++++++++++-----------
 2 files changed, 163 insertions(+), 180 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 10cede5..418af82 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -251,6 +251,7 @@ struct ixgbe_adv_tx_context_desc {
 #define IXGBE_ADVTXD_TUCMD_L4T_TCP   0x00000800  /* L4 Packet TYPE of TCP */
 #define IXGBE_ADVTXD_TUCMD_L4T_SCTP  0x00001000  /* L4 Packet TYPE of SCTP */
 #define IXGBE_ADVTXD_IDX_SHIFT  4 /* Adv desc Index shift */
+#define IXGBE_ADVTXD_CC		0x00000080 /* Check Context */
 #define IXGBE_ADVTXD_POPTS_SHIFT      8  /* Adv desc POPTS shift */
 #define IXGBE_ADVTXD_POPTS_IXSM (IXGBE_TXD_POPTS_IXSM << \
 				 IXGBE_ADVTXD_POPTS_SHIFT)
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1c53e13..ce81ce0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -42,6 +42,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/sctp.h>
 #include <linux/ipv6.h>
 #include <linux/slab.h>
 #include <net/checksum.h>
@@ -144,18 +145,18 @@ static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 	}
 }
 
-static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_adapter *adapter,
+static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
 					       struct ixgbevf_tx_buffer
 					       *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		if (tx_buffer_info->mapped_as_page)
-			dma_unmap_page(&adapter->pdev->dev,
+			dma_unmap_page(tx_ring->dev,
 				       tx_buffer_info->dma,
 				       tx_buffer_info->length,
 				       DMA_TO_DEVICE);
 		else
-			dma_unmap_single(&adapter->pdev->dev,
+			dma_unmap_single(tx_ring->dev,
 					 tx_buffer_info->dma,
 					 tx_buffer_info->length,
 					 DMA_TO_DEVICE);
@@ -222,7 +223,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 				total_bytes += bytecount;
 			}
 
-			ixgbevf_unmap_and_free_tx_resource(adapter,
+			ixgbevf_unmap_and_free_tx_resource(tx_ring,
 							   tx_buffer_info);
 
 			tx_desc->wb.status = 0;
@@ -1443,7 +1444,7 @@ static void ixgbevf_clean_tx_ring(struct ixgbevf_adapter *adapter,
 
 	for (i = 0; i < tx_ring->count; i++) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbevf_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+		ixgbevf_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 	}
 
 	size = sizeof(struct ixgbevf_tx_buffer) * tx_ring->count;
@@ -2389,172 +2390,153 @@ static int ixgbevf_close(struct net_device *netdev)
 	return 0;
 }
 
-static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
-		       struct ixgbevf_ring *tx_ring,
-		       struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+static void ixgbevf_tx_ctxtdesc(struct ixgbevf_ring *tx_ring,
+				u32 vlan_macip_lens, u32 type_tucmd,
+				u32 mss_l4len_idx)
 {
 	struct ixgbe_adv_tx_context_desc *context_desc;
-	unsigned int i;
-	int err;
-	struct ixgbevf_tx_buffer *tx_buffer_info;
-	u32 vlan_macip_lens = 0, type_tucmd_mlhl;
-	u32 mss_l4len_idx, l4len;
+	u16 i = tx_ring->next_to_use;
 
-	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
-		l4len = tcp_hdrlen(skb);
-		*hdr_len += l4len;
-
-		if (skb->protocol == htons(ETH_P_IP)) {
-			struct iphdr *iph = ip_hdr(skb);
-			iph->tot_len = 0;
-			iph->check = 0;
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
-			adapter->hw_tso_ctxt++;
-		} else if (skb_is_gso_v6(skb)) {
-			ipv6_hdr(skb)->payload_len = 0;
-			tcp_hdr(skb)->check =
-			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-					     &ipv6_hdr(skb)->daddr,
-					     0, IPPROTO_TCP, 0);
-			adapter->hw_tso6_ctxt++;
-		}
+	context_desc = IXGBEVF_TX_CTXTDESC(tx_ring, i);
 
-		i = tx_ring->next_to_use;
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
 
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBEVF_TX_CTXTDESC(tx_ring, i);
-
-		/* VLAN MACLEN IPLEN */
-		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
-			vlan_macip_lens |=
-				(tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
-		vlan_macip_lens |= ((skb_network_offset(skb)) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
-		*hdr_len += skb_network_offset(skb);
-		vlan_macip_lens |=
-			(skb_transport_header(skb) - skb_network_header(skb));
-		*hdr_len +=
-			(skb_transport_header(skb) - skb_network_header(skb));
-		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
-		context_desc->seqnum_seed = 0;
-
-		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
-		type_tucmd_mlhl = (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
-
-		if (skb->protocol == htons(ETH_P_IP))
-			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
-		type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
-		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
-
-		/* MSS L4LEN IDX */
-		mss_l4len_idx =
-			(skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
-		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
-		/* use index 1 for TSO */
-		mss_l4len_idx |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
-		context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
-
-		tx_buffer_info->time_stamp = jiffies;
-		tx_buffer_info->next_to_watch = i;
+	/* set bits to identify this as an advanced context descriptor */
+	type_tucmd |= IXGBE_TXD_CMD_DEXT | IXGBE_ADVTXD_DTYP_CTXT;
 
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-		tx_ring->next_to_use = i;
+	context_desc->vlan_macip_lens	= cpu_to_le32(vlan_macip_lens);
+	context_desc->seqnum_seed	= 0;
+	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);
+	context_desc->mss_l4len_idx	= cpu_to_le32(mss_l4len_idx);
+}
+
+static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
+		       struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+{
+	u32 vlan_macip_lens, type_tucmd;
+	u32 mss_l4len_idx, l4len;
+
+	if (!skb_is_gso(skb))
+		return 0;
 
-		return true;
+	if (skb_header_cloned(skb)) {
+		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (err)
+			return err;
 	}
 
-	return false;
+	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
+	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+		iph->tot_len = 0;
+		iph->check = 0;
+		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
+							 iph->daddr, 0,
+							 IPPROTO_TCP,
+							 0);
+		type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
+	} else if (skb_is_gso_v6(skb)) {
+		ipv6_hdr(skb)->payload_len = 0;
+		tcp_hdr(skb)->check =
+		    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+				     &ipv6_hdr(skb)->daddr,
+				     0, IPPROTO_TCP, 0);
+	}
+
+	/* compute header lengths */
+	l4len = tcp_hdrlen(skb);
+	*hdr_len += l4len;
+	*hdr_len = skb_transport_offset(skb) + l4len;
+
+	/* mss_l4len_id: use 1 as index for TSO */
+	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
+	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
+	mss_l4len_idx |= 1 << IXGBE_ADVTXD_IDX_SHIFT;
+
+	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
+	vlan_macip_lens = skb_network_header_len(skb);
+	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens |= tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
+
+	ixgbevf_tx_ctxtdesc(tx_ring, vlan_macip_lens,
+			    type_tucmd, mss_l4len_idx);
+
+	return 1;
 }
 
-static bool ixgbevf_tx_csum(struct ixgbevf_adapter *adapter,
-			    struct ixgbevf_ring *tx_ring,
+static bool ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 			    struct sk_buff *skb, u32 tx_flags)
 {
-	struct ixgbe_adv_tx_context_desc *context_desc;
-	unsigned int i;
-	struct ixgbevf_tx_buffer *tx_buffer_info;
-	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL ||
-	    (tx_flags & IXGBE_TX_FLAGS_VLAN)) {
-		i = tx_ring->next_to_use;
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		context_desc = IXGBEVF_TX_CTXTDESC(tx_ring, i);
-
-		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
-			vlan_macip_lens |= (tx_flags &
-					    IXGBE_TX_FLAGS_VLAN_MASK);
-		vlan_macip_lens |= (skb_network_offset(skb) <<
-				    IXGBE_ADVTXD_MACLEN_SHIFT);
-		if (skb->ip_summed == CHECKSUM_PARTIAL)
-			vlan_macip_lens |= (skb_transport_header(skb) -
-					    skb_network_header(skb));
-
-		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
-		context_desc->seqnum_seed = 0;
-
-		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
-				    IXGBE_ADVTXD_DTYP_CTXT);
-
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
-				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
-				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
-					type_tucmd_mlhl |=
-					    IXGBE_ADVTXD_TUCMD_L4T_TCP;
-				break;
-			case __constant_htons(ETH_P_IPV6):
-				/* XXX what about other V6 headers?? */
-				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
-					type_tucmd_mlhl |=
-						IXGBE_ADVTXD_TUCMD_L4T_TCP;
-				break;
-			default:
-				if (unlikely(net_ratelimit())) {
-					pr_warn("partial checksum but "
-						"proto=%x!\n", skb->protocol);
-				}
-				break;
-			}
-		}
 
-		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
-		/* use index zero for tx checksum offload */
-		context_desc->mss_l4len_idx = 0;
 
-		tx_buffer_info->time_stamp = jiffies;
-		tx_buffer_info->next_to_watch = i;
+	u32 vlan_macip_lens = 0;
+	u32 mss_l4len_idx = 0;
+	u32 type_tucmd = 0;
 
-		adapter->hw_csum_tx_good++;
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-		tx_ring->next_to_use = i;
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u8 l4_hdr = 0;
+		switch (skb->protocol) {
+		case __constant_htons(ETH_P_IP):
+			vlan_macip_lens |= skb_network_header_len(skb);
+			type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
+			l4_hdr = ip_hdr(skb)->protocol;
+			break;
+		case __constant_htons(ETH_P_IPV6):
+			vlan_macip_lens |= skb_network_header_len(skb);
+			l4_hdr = ipv6_hdr(skb)->nexthdr;
+			break;
+		default:
+			if (unlikely(net_ratelimit())) {
+				dev_warn(tx_ring->dev,
+				 "partial checksum but proto=%x!\n",
+				 skb->protocol);
+			}
+			break;
+		}
 
-		return true;
+		switch (l4_hdr) {
+		case IPPROTO_TCP:
+			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+			mss_l4len_idx = tcp_hdrlen(skb) <<
+					IXGBE_ADVTXD_L4LEN_SHIFT;
+			break;
+		case IPPROTO_SCTP:
+			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_SCTP;
+			mss_l4len_idx = sizeof(struct sctphdr) <<
+					IXGBE_ADVTXD_L4LEN_SHIFT;
+			break;
+		case IPPROTO_UDP:
+			mss_l4len_idx = sizeof(struct udphdr) <<
+					IXGBE_ADVTXD_L4LEN_SHIFT;
+			break;
+		default:
+			if (unlikely(net_ratelimit())) {
+				dev_warn(tx_ring->dev,
+				 "partial checksum but l4 proto=%x!\n",
+				 l4_hdr);
+			}
+			break;
+		}
 	}
 
-	return false;
+	/* vlan_macip_lens: MACLEN, VLAN tag */
+	vlan_macip_lens |= skb_network_offset(skb) << IXGBE_ADVTXD_MACLEN_SHIFT;
+	vlan_macip_lens |= tx_flags & IXGBE_TX_FLAGS_VLAN_MASK;
+
+	ixgbevf_tx_ctxtdesc(tx_ring, vlan_macip_lens,
+			    type_tucmd, mss_l4len_idx);
+
+	return (skb->ip_summed == CHECKSUM_PARTIAL);
 }
 
-static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
-			  struct ixgbevf_ring *tx_ring,
+static int ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 			  struct sk_buff *skb, u32 tx_flags,
 			  unsigned int first)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	struct ixgbevf_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
@@ -2573,12 +2555,11 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 
 		tx_buffer_info->length = size;
 		tx_buffer_info->mapped_as_page = false;
-		tx_buffer_info->dma = dma_map_single(&adapter->pdev->dev,
+		tx_buffer_info->dma = dma_map_single(tx_ring->dev,
 						     skb->data + offset,
 						     size, DMA_TO_DEVICE);
-		if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
+		if (dma_mapping_error(tx_ring->dev, tx_buffer_info->dma))
 			goto dma_error;
-		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
 		len -= size;
@@ -2603,12 +2584,12 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 
 			tx_buffer_info->length = size;
 			tx_buffer_info->dma =
-				skb_frag_dma_map(&adapter->pdev->dev, frag,
+				skb_frag_dma_map(tx_ring->dev, frag,
 						 offset, size, DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page = true;
-			if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
+			if (dma_mapping_error(tx_ring->dev,
+					      tx_buffer_info->dma))
 				goto dma_error;
-			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
 			len -= size;
@@ -2629,15 +2610,15 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 		i = i - 1;
 	tx_ring->tx_buffer_info[i].skb = skb;
 	tx_ring->tx_buffer_info[first].next_to_watch = i;
+	tx_ring->tx_buffer_info[first].time_stamp = jiffies;
 
 	return count;
 
 dma_error:
-	dev_err(&pdev->dev, "TX DMA map failed\n");
+	dev_err(tx_ring->dev, "TX DMA map failed\n");
 
 	/* clear timestamp and dma mappings for failed tx_buffer_info map */
 	tx_buffer_info->dma = 0;
-	tx_buffer_info->time_stamp = 0;
 	tx_buffer_info->next_to_watch = 0;
 	count--;
 
@@ -2648,14 +2629,13 @@ dma_error:
 		if (i < 0)
 			i += tx_ring->count;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbevf_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+		ixgbevf_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 	}
 
 	return count;
 }
 
-static void ixgbevf_tx_queue(struct ixgbevf_adapter *adapter,
-			     struct ixgbevf_ring *tx_ring, int tx_flags,
+static void ixgbevf_tx_queue(struct ixgbevf_ring *tx_ring, int tx_flags,
 			     int count, u32 paylen, u8 hdr_len)
 {
 	union ixgbe_adv_tx_desc *tx_desc = NULL;
@@ -2672,21 +2652,24 @@ static void ixgbevf_tx_queue(struct ixgbevf_adapter *adapter,
 	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
 		cmd_type_len |= IXGBE_ADVTXD_DCMD_VLE;
 
+	if (tx_flags & IXGBE_TX_FLAGS_CSUM)
+		olinfo_status |= IXGBE_ADVTXD_POPTS_TXSM;
+
 	if (tx_flags & IXGBE_TX_FLAGS_TSO) {
 		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
 
-		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-			IXGBE_ADVTXD_POPTS_SHIFT;
-
 		/* use index 1 context for tso */
 		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
-			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
-				IXGBE_ADVTXD_POPTS_SHIFT;
+			olinfo_status |= IXGBE_ADVTXD_POPTS_IXSM;
+
+	}
 
-	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
-		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
-			IXGBE_ADVTXD_POPTS_SHIFT;
+	/*
+	 * Check Context must be set if Tx switch is enabled, which it
+	 * always is for case where virtual functions are running
+	 */
+	olinfo_status |= IXGBE_ADVTXD_CC;
 
 	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
@@ -2705,16 +2688,7 @@ static void ixgbevf_tx_queue(struct ixgbevf_adapter *adapter,
 
 	tx_desc->read.cmd_type_len |= cpu_to_le32(txd_cmd);
 
-	/*
-	 * Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64).
-	 */
-	wmb();
-
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tail);
 }
 
 static int __ixgbevf_maybe_stop_tx(struct ixgbevf_ring *tx_ring, int size)
@@ -2788,21 +2762,29 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= IXGBE_TX_FLAGS_IPV4;
-	tso = ixgbevf_tso(adapter, tx_ring, skb, tx_flags, &hdr_len);
+	tso = ixgbevf_tso(tx_ring, skb, tx_flags, &hdr_len);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
 	if (tso)
-		tx_flags |= IXGBE_TX_FLAGS_TSO;
-	else if (ixgbevf_tx_csum(adapter, tx_ring, skb, tx_flags) &&
-		 (skb->ip_summed == CHECKSUM_PARTIAL))
+		tx_flags |= IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_CSUM;
+	else if (ixgbevf_tx_csum(tx_ring, skb, tx_flags))
 		tx_flags |= IXGBE_TX_FLAGS_CSUM;
 
-	ixgbevf_tx_queue(adapter, tx_ring, tx_flags,
-			 ixgbevf_tx_map(adapter, tx_ring, skb, tx_flags, first),
+	ixgbevf_tx_queue(tx_ring, tx_flags,
+			 ixgbevf_tx_map(tx_ring, skb, tx_flags, first),
 			 skb->len, hdr_len);
+	/*
+	 * Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64).
+	 */
+	wmb();
+
+	writel(tx_ring->next_to_use, adapter->hw.hw_addr + tx_ring->tail);
 
 	ixgbevf_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
-- 
1.7.10.4
