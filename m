From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 05/10] atl1: simplify tx packet descriptor
Date: Sat,  2 Feb 2008 19:50:07 -0600
Message-ID: <1202003412-4028-5-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:57481 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756AbYBCBuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:20 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The transmit packet descriptor consists of four 32-bit words, with word 3
upper bits overloaded depending upon the condition of its bits 3 and 4.
The driver currently duplicates all word 2 and some word 3 register bit
definitions unnecessarily and also uses a set of nested structures in its
definition of the TPD without good cause. This patch adds a lengthy
comment describing the TPD, eliminates duplicate TPD bit definitions,
and simplifies the TPD structure itself. It also expands the TSO check
to correctly handle custom checksum versus TSO processing using the revised
TPD definitions. Finally, shorten some variable names in the transmit
processing path to reduce line lengths, rename some variables to better
describe their purpose (e.g., nseg versus m), and add a comment or two
to better describe what the code is doing.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Acked-by: Chris Snook <csnook@redhat.com>
---
 drivers/net/atlx/atl1.c |  265 +++++++++++++++++++++++++----------------------
 drivers/net/atlx/atl1.h |  201 +++++++++++++++++++-----------------
 2 files changed, 246 insertions(+), 220 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 1f564f0..f4add3c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1259,8 +1259,6 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 			dev_kfree_skb_irq(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
-		tpd->buffer_addr = 0;
-		tpd->desc.data = 0;
 
 		if (++sw_tpd_next_to_clean == tpd_ring->count)
 			sw_tpd_next_to_clean = 0;
@@ -1282,48 +1280,69 @@ static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
-			 struct tso_param *tso)
+	struct tx_packet_desc *ptpd)
 {
-	/* We enter this function holding a spinlock. */
-	u8 ipofst;
+	/* spinlock held */
+	u8 hdr_len, ip_off;
+	u32 real_len;
 	int err;
 
 	if (skb_shinfo(skb)->gso_size) {
 		if (skb_header_cloned(skb)) {
 			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 			if (unlikely(err))
-				return err;
+				return -1;
 		}
 
 		if (skb->protocol == ntohs(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
 
-			iph->tot_len = 0;
+			real_len = (((unsigned char *)iph - skb->data) +
+				ntohs(iph->tot_len));
+			if (real_len < skb->len)
+				pskb_trim(skb, real_len);
+			hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
+			if (skb->len == hdr_len) {
+				iph->check = 0;
+				tcp_hdr(skb)->check =
+					~csum_tcpudp_magic(iph->saddr,
+					iph->daddr, tcp_hdrlen(skb),
+					IPPROTO_TCP, 0);
+				ptpd->word3 |= (iph->ihl & TPD_IPHL_MASK) <<
+					TPD_IPHL_SHIFT;
+				ptpd->word3 |= ((tcp_hdrlen(skb) >> 2) &
+					TPD_TCPHDRLEN_MASK) <<
+					TPD_TCPHDRLEN_SHIFT;
+				ptpd->word3 |= 1 << TPD_IP_CSUM_SHIFT;
+				ptpd->word3 |= 1 << TPD_TCP_CSUM_SHIFT;
+				return 1;
+			}
+
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-				iph->daddr, 0, IPPROTO_TCP, 0);
-			ipofst = skb_network_offset(skb);
-			if (ipofst != ETH_HLEN) /* 802.3 frame */
-				tso->tsopl |= 1 << TSO_PARAM_ETHTYPE_SHIFT;
-
-			tso->tsopl |= (iph->ihl &
-				TSO_PARAM_IPHL_MASK) << TSO_PARAM_IPHL_SHIFT;
-			tso->tsopl |= ((tcp_hdrlen(skb) >> 2) &
-				TSO_PARAM_TCPHDRLEN_MASK) <<
-				TSO_PARAM_TCPHDRLEN_SHIFT;
-			tso->tsopl |= (skb_shinfo(skb)->gso_size &
-				TSO_PARAM_MSS_MASK) << TSO_PARAM_MSS_SHIFT;
-			tso->tsopl |= 1 << TSO_PARAM_IPCKSUM_SHIFT;
-			tso->tsopl |= 1 << TSO_PARAM_TCPCKSUM_SHIFT;
-			tso->tsopl |= 1 << TSO_PARAM_SEGMENT_SHIFT;
-			return true;
+					iph->daddr, 0, IPPROTO_TCP, 0);
+			ip_off = (unsigned char *)iph -
+				(unsigned char *) skb_network_header(skb);
+			if (ip_off == 8) /* 802.3-SNAP frame */
+				ptpd->word3 |= 1 << TPD_ETHTYPE_SHIFT;
+			else if (ip_off != 0)
+				return -2;
+
+			ptpd->word3 |= (iph->ihl & TPD_IPHL_MASK) <<
+				TPD_IPHL_SHIFT;
+			ptpd->word3 |= ((tcp_hdrlen(skb) >> 2) &
+				TPD_TCPHDRLEN_MASK) << TPD_TCPHDRLEN_SHIFT;
+			ptpd->word3 |= (skb_shinfo(skb)->gso_size &
+				TPD_MSS_MASK) << TPD_MSS_SHIFT;
+			ptpd->word3 |= 1 << TPD_SEGMENT_EN_SHIFT;
+			return 3;
 		}
 	}
 	return false;
 }
 
 static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
-	struct csum_param *csum)
+	struct tx_packet_desc *ptpd)
 {
 	u8 css, cso;
 
@@ -1335,115 +1354,116 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 				"payload offset not an even number\n");
 			return -1;
 		}
-		csum->csumpl |= (cso & CSUM_PARAM_PLOADOFFSET_MASK) <<
-			CSUM_PARAM_PLOADOFFSET_SHIFT;
-		csum->csumpl |= (css & CSUM_PARAM_XSUMOFFSET_MASK) <<
-			CSUM_PARAM_XSUMOFFSET_SHIFT;
-		csum->csumpl |= 1 << CSUM_PARAM_CUSTOMCKSUM_SHIFT;
+		ptpd->word3 |= (cso & TPD_PLOADOFFSET_MASK) <<
+			TPD_PLOADOFFSET_SHIFT;
+		ptpd->word3 |= (css & TPD_CCSUMOFFSET_MASK) <<
+			TPD_CCSUMOFFSET_SHIFT;
+		ptpd->word3 |= 1 << TPD_CUST_CSUM_EN_SHIFT;
 		return true;
 	}
-
-	return true;
+	return 0;
 }
 
 static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
-	bool tcp_seg)
+	struct tx_packet_desc *ptpd)
 {
-	/* We enter this function holding a spinlock. */
+	/* spinlock held */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
+	u16 buf_len = skb->len;
 	struct page *page;
-	int first_buf_len = skb->len;
 	unsigned long offset;
 	unsigned int nr_frags;
 	unsigned int f;
-	u16 tpd_next_to_use;
-	u16 proto_hdr_len;
-	u16 len12;
+	int retval;
+	u16 next_to_use;
+	u16 data_len;
+	u8 hdr_len;
 
-	first_buf_len -= skb->data_len;
+	buf_len -= skb->data_len;
 	nr_frags = skb_shinfo(skb)->nr_frags;
-	tpd_next_to_use = atomic_read(&tpd_ring->next_to_use);
-	buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
+	next_to_use = atomic_read(&tpd_ring->next_to_use);
+	buffer_info = &tpd_ring->buffer_info[next_to_use];
 	if (unlikely(buffer_info->skb))
 		BUG();
 	/* put skb in last TPD */
 	buffer_info->skb = NULL;
 
-	if (tcp_seg) {
-		/* TSO/GSO */
-		proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		buffer_info->length = proto_hdr_len;
+	retval = (ptpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_MASK;
+	if (retval) {
+		/* TSO */
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		buffer_info->length = hdr_len;
 		page = virt_to_page(skb->data);
 		offset = (unsigned long)skb->data & ~PAGE_MASK;
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
-						offset, proto_hdr_len,
+						offset, hdr_len,
 						PCI_DMA_TODEVICE);
 
-		if (++tpd_next_to_use == tpd_ring->count)
-			tpd_next_to_use = 0;
+		if (++next_to_use == tpd_ring->count)
+			next_to_use = 0;
 
-		if (first_buf_len > proto_hdr_len) {
-			int i, m;
+		if (buf_len > hdr_len) {
+			int i, nseg;
 
-			len12 = first_buf_len - proto_hdr_len;
-			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
+			data_len = buf_len - hdr_len;
+			nseg = (data_len + ATL1_MAX_TX_BUF_LEN - 1) /
 				ATL1_MAX_TX_BUF_LEN;
-			for (i = 0; i < m; i++) {
+			for (i = 0; i < nseg; i++) {
 				buffer_info =
-				    &tpd_ring->buffer_info[tpd_next_to_use];
+				    &tpd_ring->buffer_info[next_to_use];
 				buffer_info->skb = NULL;
 				buffer_info->length =
 				    (ATL1_MAX_TX_BUF_LEN >=
-				     len12) ? ATL1_MAX_TX_BUF_LEN : len12;
-				len12 -= buffer_info->length;
+				     data_len) ? ATL1_MAX_TX_BUF_LEN : data_len;
+				data_len -= buffer_info->length;
 				page = virt_to_page(skb->data +
-					(proto_hdr_len +
-					i * ATL1_MAX_TX_BUF_LEN));
+					(hdr_len + i * ATL1_MAX_TX_BUF_LEN));
 				offset = (unsigned long)(skb->data +
-					(proto_hdr_len +
-					i * ATL1_MAX_TX_BUF_LEN)) & ~PAGE_MASK;
+					(hdr_len + i * ATL1_MAX_TX_BUF_LEN)) &
+					~PAGE_MASK;
 				buffer_info->dma = pci_map_page(adapter->pdev,
 					page, offset, buffer_info->length,
 					PCI_DMA_TODEVICE);
-				if (++tpd_next_to_use == tpd_ring->count)
-					tpd_next_to_use = 0;
+				if (++next_to_use == tpd_ring->count)
+					next_to_use = 0;
 			}
 		}
 	} else {
-		/* not TSO/GSO */
-		buffer_info->length = first_buf_len;
+		/* not TSO */
+		buffer_info->length = buf_len;
 		page = virt_to_page(skb->data);
 		offset = (unsigned long)skb->data & ~PAGE_MASK;
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
-			offset, first_buf_len, PCI_DMA_TODEVICE);
-		if (++tpd_next_to_use == tpd_ring->count)
-			tpd_next_to_use = 0;
+			offset, buf_len, PCI_DMA_TODEVICE);
+		if (++next_to_use == tpd_ring->count)
+			next_to_use = 0;
 	}
 
 	for (f = 0; f < nr_frags; f++) {
 		struct skb_frag_struct *frag;
-		u16 lenf, i, m;
+		u16 i, nseg;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		lenf = frag->size;
+		buf_len = frag->size;
 
-		m = (lenf + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
-		for (i = 0; i < m; i++) {
-			buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
+		nseg = (buf_len + ATL1_MAX_TX_BUF_LEN - 1) /
+			ATL1_MAX_TX_BUF_LEN;
+		for (i = 0; i < nseg; i++) {
+			buffer_info = &tpd_ring->buffer_info[next_to_use];
 			if (unlikely(buffer_info->skb))
 				BUG();
 			buffer_info->skb = NULL;
-			buffer_info->length = (lenf > ATL1_MAX_TX_BUF_LEN) ?
-				ATL1_MAX_TX_BUF_LEN : lenf;
-			lenf -= buffer_info->length;
+			buffer_info->length = (buf_len > ATL1_MAX_TX_BUF_LEN) ?
+				ATL1_MAX_TX_BUF_LEN : buf_len;
+			buf_len -= buffer_info->length;
 			buffer_info->dma = pci_map_page(adapter->pdev,
 				frag->page,
 				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
 				buffer_info->length, PCI_DMA_TODEVICE);
 
-			if (++tpd_next_to_use == tpd_ring->count)
-				tpd_next_to_use = 0;
+			if (++next_to_use == tpd_ring->count)
+				next_to_use = 0;
 		}
 	}
 
@@ -1451,39 +1471,44 @@ static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
 	buffer_info->skb = skb;
 }
 
-static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
-       union tpd_descr *descr)
+static void atl1_tx_queue(struct atl1_adapter *adapter, u16 count,
+       struct tx_packet_desc *ptpd)
 {
-	/* We enter this function holding a spinlock. */
+	/* spinlock held */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	int j;
-	u32 val;
 	struct atl1_buffer *buffer_info;
 	struct tx_packet_desc *tpd;
-	u16 tpd_next_to_use = atomic_read(&tpd_ring->next_to_use);
+	u16 j;
+	u32 val;
+	u16 next_to_use = (u16) atomic_read(&tpd_ring->next_to_use);
 
 	for (j = 0; j < count; j++) {
-		buffer_info = &tpd_ring->buffer_info[tpd_next_to_use];
-		tpd = ATL1_TPD_DESC(&adapter->tpd_ring, tpd_next_to_use);
-		tpd->desc.csum.csumpu = descr->csum.csumpu;
-		tpd->desc.csum.csumpl = descr->csum.csumpl;
-		tpd->desc.tso.tsopu = descr->tso.tsopu;
-		tpd->desc.tso.tsopl = descr->tso.tsopl;
+		buffer_info = &tpd_ring->buffer_info[next_to_use];
+		tpd = ATL1_TPD_DESC(&adapter->tpd_ring, next_to_use);
+		if (tpd != ptpd)
+			memcpy(tpd, ptpd, sizeof(struct tx_packet_desc));
 		tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
-		tpd->desc.data = descr->data;
-		tpd->desc.tso.tsopu |= (cpu_to_le16(buffer_info->length) &
-			TSO_PARAM_BUFLEN_MASK) << TSO_PARAM_BUFLEN_SHIFT;
+		tpd->word2 = (cpu_to_le16(buffer_info->length) &
+			TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIFT;
 
-		val = (descr->tso.tsopl >> TSO_PARAM_SEGMENT_SHIFT) &
-			TSO_PARAM_SEGMENT_MASK;
-		if (val && !j)
-			tpd->desc.tso.tsopl |= 1 << TSO_PARAM_HDRFLAG_SHIFT;
+		/*
+		 * if this is the first packet in a TSO chain, set
+		 * TPD_HDRFLAG, otherwise, clear it.
+		 */
+		val = (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) &
+			TPD_SEGMENT_EN_MASK;
+		if (val) {
+			if (!j)
+				tpd->word3 |= 1 << TPD_HDRFLAG_SHIFT;
+			else
+				tpd->word3 &= ~(1 << TPD_HDRFLAG_SHIFT);
+		}
 
 		if (j == (count - 1))
-			tpd->desc.tso.tsopl |= 1 << TSO_PARAM_EOP_SHIFT;
+			tpd->word3 |= 1 << TPD_EOP_SHIFT;
 
-		if (++tpd_next_to_use == tpd_ring->count)
-			tpd_next_to_use = 0;
+		if (++next_to_use == tpd_ring->count)
+			next_to_use = 0;
 	}
 	/*
 	 * Force memory writes to complete before letting h/w
@@ -1493,18 +1518,18 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
 	 */
 	wmb();
 
-	atomic_set(&tpd_ring->next_to_use, (int)tpd_next_to_use);
+	atomic_set(&tpd_ring->next_to_use, next_to_use);
 }
 
 static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	int len = skb->len;
 	int tso;
 	int count = 1;
 	int ret_val;
-	u32 val;
-	union tpd_descr param;
+	struct tx_packet_desc *ptpd;
 	u16 frag_size;
 	u16 vlan_tag;
 	unsigned long flags;
@@ -1515,18 +1540,11 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	len -= skb->data_len;
 
-	if (unlikely(skb->len == 0)) {
+	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
-	param.data = 0;
-	param.tso.tsopu = 0;
-	param.tso.tsopl = 0;
-	param.csum.csumpu = 0;
-	param.csum.csumpl = 0;
-
-	/* nr_frags will be nonzero if we're doing scatter/gather (SG) */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_shinfo(skb)->frags[f].size;
@@ -1535,10 +1553,9 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				ATL1_MAX_TX_BUF_LEN;
 	}
 
-	/* mss will be nonzero if we're doing segment offload (TSO/GSO) */
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (skb->protocol == ntohs(ETH_P_IP)) {
 			proto_hdr_len = (skb_transport_offset(skb) +
 					 tcp_hdrlen(skb));
 			if (unlikely(proto_hdr_len > len)) {
@@ -1567,18 +1584,20 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	param.data = 0;
+	ptpd = ATL1_TPD_DESC(tpd_ring,
+		(u16) atomic_read(&tpd_ring->next_to_use));
+	memset(ptpd, 0, sizeof(struct tx_packet_desc));
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
 		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
-		param.tso.tsopl |= 1 << TSO_PARAM_INSVLAG_SHIFT;
-		param.tso.tsopu |= (vlan_tag & TSO_PARAM_VLANTAG_MASK) <<
-			TSO_PARAM_VLAN_SHIFT;
+		ptpd->word3 |= 1 << TPD_INS_VL_TAG_SHIFT;
+		ptpd->word3 |= (vlan_tag & TPD_VL_TAGGED_MASK) <<
+			TPD_VL_TAGGED_SHIFT;
 	}
 
-	tso = atl1_tso(adapter, skb, &param.tso);
+	tso = atl1_tso(adapter, skb, ptpd);
 	if (tso < 0) {
 		spin_unlock_irqrestore(&adapter->lock, flags);
 		dev_kfree_skb_any(skb);
@@ -1586,7 +1605,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (!tso) {
-		ret_val = atl1_tx_csum(adapter, skb, &param.csum);
+		ret_val = atl1_tx_csum(adapter, skb, ptpd);
 		if (ret_val < 0) {
 			spin_unlock_irqrestore(&adapter->lock, flags);
 			dev_kfree_skb_any(skb);
@@ -1594,13 +1613,11 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	val = (param.tso.tsopl >> TSO_PARAM_SEGMENT_SHIFT) &
-		TSO_PARAM_SEGMENT_MASK;
-	atl1_tx_map(adapter, skb, 1 == val);
-	atl1_tx_queue(adapter, count, &param);
-	netdev->trans_start = jiffies;
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	atl1_tx_map(adapter, skb, ptpd);
+	atl1_tx_queue(adapter, count, ptpd);
 	atl1_update_mailbox(adapter);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+	netdev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
@@ -2759,7 +2776,7 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_ringparam		= atl1_get_ringparam,
 	.set_ringparam		= atl1_set_ringparam,
 	.get_pauseparam		= atl1_get_pauseparam,
-	.set_pauseparam 	= atl1_set_pauseparam,
+	.set_pauseparam		= atl1_set_pauseparam,
 	.get_rx_csum		= atl1_get_rx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_hw_csum,
 	.get_link		= ethtool_op_get_link,
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 30c5a8d..4d3d65b 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -452,106 +452,115 @@ struct rx_free_desc {
 	/* __attribute__ ((packed)) is required */
 } __attribute__ ((packed));
 
-/* tsopu defines */
-#define TSO_PARAM_BUFLEN_MASK		0x3FFF
-#define TSO_PARAM_BUFLEN_SHIFT		0
-#define TSO_PARAM_DMAINT_MASK		0x0001
-#define TSO_PARAM_DMAINT_SHIFT		14
-#define TSO_PARAM_PKTNT_MASK		0x0001
-#define TSO_PARAM_PKTINT_SHIFT		15
-#define TSO_PARAM_VLANTAG_MASK		0xFFFF
-#define TSO_PARAM_VLAN_SHIFT		16
-
-/* tsopl defines */
-#define TSO_PARAM_EOP_MASK		0x0001
-#define TSO_PARAM_EOP_SHIFT		0
-#define TSO_PARAM_COALESCE_MASK		0x0001
-#define TSO_PARAM_COALESCE_SHIFT	1
-#define TSO_PARAM_INSVLAG_MASK		0x0001
-#define TSO_PARAM_INSVLAG_SHIFT		2
-#define TSO_PARAM_CUSTOMCKSUM_MASK	0x0001
-#define TSO_PARAM_CUSTOMCKSUM_SHIFT	3
-#define TSO_PARAM_SEGMENT_MASK		0x0001
-#define TSO_PARAM_SEGMENT_SHIFT		4
-#define TSO_PARAM_IPCKSUM_MASK		0x0001
-#define TSO_PARAM_IPCKSUM_SHIFT		5
-#define TSO_PARAM_TCPCKSUM_MASK		0x0001
-#define TSO_PARAM_TCPCKSUM_SHIFT	6
-#define TSO_PARAM_UDPCKSUM_MASK		0x0001
-#define TSO_PARAM_UDPCKSUM_SHIFT	7
-#define TSO_PARAM_VLANTAGGED_MASK	0x0001
-#define TSO_PARAM_VLANTAGGED_SHIFT	8
-#define TSO_PARAM_ETHTYPE_MASK		0x0001
-#define TSO_PARAM_ETHTYPE_SHIFT		9
-#define TSO_PARAM_IPHL_MASK		0x000F
-#define TSO_PARAM_IPHL_SHIFT		10
-#define TSO_PARAM_TCPHDRLEN_MASK	0x000F
-#define TSO_PARAM_TCPHDRLEN_SHIFT	14
-#define TSO_PARAM_HDRFLAG_MASK		0x0001
-#define TSO_PARAM_HDRFLAG_SHIFT		18
-#define TSO_PARAM_MSS_MASK		0x1FFF
-#define TSO_PARAM_MSS_SHIFT		19
-
-/* csumpu defines */
-#define CSUM_PARAM_BUFLEN_MASK		0x3FFF
-#define CSUM_PARAM_BUFLEN_SHIFT		0
-#define CSUM_PARAM_DMAINT_MASK		0x0001
-#define CSUM_PARAM_DMAINT_SHIFT		14
-#define CSUM_PARAM_PKTINT_MASK		0x0001
-#define CSUM_PARAM_PKTINT_SHIFT		15
-#define CSUM_PARAM_VALANTAG_MASK	0xFFFF
-#define CSUM_PARAM_VALAN_SHIFT		16
-
-/* csumpl defines*/
-#define CSUM_PARAM_EOP_MASK		0x0001
-#define CSUM_PARAM_EOP_SHIFT		0
-#define CSUM_PARAM_COALESCE_MASK	0x0001
-#define CSUM_PARAM_COALESCE_SHIFT	1
-#define CSUM_PARAM_INSVLAG_MASK		0x0001
-#define CSUM_PARAM_INSVLAG_SHIFT	2
-#define CSUM_PARAM_CUSTOMCKSUM_MASK	0x0001
-#define CSUM_PARAM_CUSTOMCKSUM_SHIFT	3
-#define CSUM_PARAM_SEGMENT_MASK		0x0001
-#define CSUM_PARAM_SEGMENT_SHIFT	4
-#define CSUM_PARAM_IPCKSUM_MASK		0x0001
-#define CSUM_PARAM_IPCKSUM_SHIFT	5
-#define CSUM_PARAM_TCPCKSUM_MASK	0x0001
-#define CSUM_PARAM_TCPCKSUM_SHIFT	6
-#define CSUM_PARAM_UDPCKSUM_MASK	0x0001
-#define CSUM_PARAM_UDPCKSUM_SHIFT	7
-#define CSUM_PARAM_VLANTAGGED_MASK	0x0001
-#define CSUM_PARAM_VLANTAGGED_SHIFT	8
-#define CSUM_PARAM_ETHTYPE_MASK		0x0001
-#define CSUM_PARAM_ETHTYPE_SHIFT	9
-#define CSUM_PARAM_IPHL_MASK		0x000F
-#define CSUM_PARAM_IPHL_SHIFT		10
-#define CSUM_PARAM_PLOADOFFSET_MASK	0x00FF
-#define CSUM_PARAM_PLOADOFFSET_SHIFT	16
-#define CSUM_PARAM_XSUMOFFSET_MASK	0x00FF
-#define CSUM_PARAM_XSUMOFFSET_SHIFT	24
-
-/* TPD descriptor */
-struct tso_param {
-	/* The order of these declarations is important -- don't change it */
-	u32 tsopu;	/* tso_param upper word */
-	u32 tsopl;	/* tso_param lower word */
-};
-
-struct csum_param {
-	/* The order of these declarations is important -- don't change it */
-	u32 csumpu;	/* csum_param upper word */
-	u32 csumpl;	/* csum_param lower word */
-};
+/*
+ * The L1 transmit packet descriptor is comprised of four 32-bit words.
+ *
+ *	31					0
+ *	+---------------------------------------+
+ *      |	Word 0: Buffer addr lo 		|
+ *      +---------------------------------------+
+ *      |	Word 1: Buffer addr hi		|
+ *      +---------------------------------------+
+ *      |		Word 2			|
+ *      +---------------------------------------+
+ *      |		Word 3			|
+ *      +---------------------------------------+
+ *
+ * Words 0 and 1 combine to form a 64-bit buffer address.
+ *
+ * Word 2 is self explanatory in the #define block below.
+ *
+ * Word 3 has two forms, depending upon the state of bits 3 and 4.
+ * If bits 3 and 4 are both zero, then bits 14:31 are unused by the
+ * hardware.  Otherwise, if either bit 3 or 4 is set, the definition
+ * of bits 14:31 vary according to the following depiction.
+ *
+ *	0	End of packet			0	End of packet
+ *	1	Coalesce			1	Coalesce
+ *	2	Insert VLAN tag			2	Insert VLAN tag
+ *	3	Custom csum enable = 0		3	Custom csum enable = 1
+ *	4	Segment enable = 1		4	Segment enable = 0
+ *	5	Generate IP checksum		5	Generate IP checksum
+ *	6	Generate TCP checksum		6	Generate TCP checksum
+ *	7	Generate UDP checksum		7	Generate UDP checksum
+ *	8	VLAN tagged			8	VLAN tagged
+ *	9	Ethernet frame type		9	Ethernet frame type
+ *	10-+ 					10-+
+ *	11 |	IP hdr length (10:13)		11 |	IP hdr length (10:13)
+ *	12 |	(num 32-bit words)		12 |	(num 32-bit words)
+ *	13-+					13-+
+ *	14-+					14	Unused
+ *	15 |	TCP hdr length (14:17)		15	Unused
+ *	16 |	(num 32-bit words)		16-+
+ *	17-+					17 |
+ *	18	Header TPD flag			18 |
+ *	19-+					19 |	Payload offset
+ *	20 |					20 |	    (16:23)
+ *	21 |					21 |
+ *	22 |					22 |
+ *	23 |					23-+
+ *	24 |					24-+
+ *	25 |	MSS (19:31)			25 |
+ *	26 |					26 |
+ *	27 |					27 |	Custom csum offset
+ *	28 |					28 |	     (24:31)
+ *	29 |					29 |
+ *	30 |					30 |
+ *	31-+					31-+
+ */
 
-union tpd_descr {
-	u64 data;
-	struct csum_param csum;
-	struct tso_param tso;
-};
+/* tpd word 2 */
+#define TPD_BUFLEN_MASK		0x3FFF
+#define TPD_BUFLEN_SHIFT	0
+#define TPD_DMAINT_MASK		0x0001
+#define TPD_DMAINT_SHIFT	14
+#define TPD_PKTNT_MASK		0x0001
+#define TPD_PKTINT_SHIFT	15
+#define TPD_VLANTAG_MASK	0xFFFF
+#define TPD_VLAN_SHIFT		16
+
+/* tpd word 3 bits 0:13 */
+#define TPD_EOP_MASK		0x0001
+#define TPD_EOP_SHIFT		0
+#define TPD_COALESCE_MASK	0x0001
+#define TPD_COALESCE_SHIFT	1
+#define TPD_INS_VL_TAG_MASK	0x0001
+#define TPD_INS_VL_TAG_SHIFT	2
+#define TPD_CUST_CSUM_EN_MASK	0x0001
+#define TPD_CUST_CSUM_EN_SHIFT	3
+#define TPD_SEGMENT_EN_MASK	0x0001
+#define TPD_SEGMENT_EN_SHIFT	4
+#define TPD_IP_CSUM_MASK	0x0001
+#define TPD_IP_CSUM_SHIFT	5
+#define TPD_TCP_CSUM_MASK	0x0001
+#define TPD_TCP_CSUM_SHIFT	6
+#define TPD_UDP_CSUM_MASK	0x0001
+#define TPD_UDP_CSUM_SHIFT	7
+#define TPD_VL_TAGGED_MASK	0x0001
+#define TPD_VL_TAGGED_SHIFT	8
+#define TPD_ETHTYPE_MASK	0x0001
+#define TPD_ETHTYPE_SHIFT	9
+#define TPD_IPHL_MASK		0x000F
+#define TPD_IPHL_SHIFT		10
+
+/* tpd word 3 bits 14:31 if segment enabled */
+#define TPD_TCPHDRLEN_MASK	0x000F
+#define TPD_TCPHDRLEN_SHIFT	14
+#define TPD_HDRFLAG_MASK	0x0001
+#define TPD_HDRFLAG_SHIFT	18
+#define TPD_MSS_MASK		0x1FFF
+#define TPD_MSS_SHIFT		19
+
+/* tpd word 3 bits 16:31 if custom csum enabled */
+#define TPD_PLOADOFFSET_MASK	0x00FF
+#define TPD_PLOADOFFSET_SHIFT	16
+#define TPD_CCSUMOFFSET_MASK	0x00FF
+#define TPD_CCSUMOFFSET_SHIFT	24
 
 struct tx_packet_desc {
 	__le64 buffer_addr;
-	union tpd_descr desc;
+	__le32 word2;
+	__le32 word3;
 };
 
 /* DMA Order Settings */
-- 
1.5.3.8

