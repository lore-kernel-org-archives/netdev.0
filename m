From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [Patch] qla3xxx: Add support for Qlogic ISP4032 chipset.
Date: Wed, 15 Nov 2006 09:39:00 -0800
Message-ID: <1163612340.29146.3.camel@linux-7mw0.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18260 "EHLO
	avexch1.qlogic.com") by vger.kernel.org with ESMTP id S1030739AbWKORZa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 12:25:30 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index ec640f6..b23ab70 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -22,6 +22,7 @@ #include <linux/interrupt.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/ip.h>
+#include <linux/in.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
@@ -38,7 +39,7 @@ #include "qla3xxx.h"
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.02.00-k36"
+#define DRV_VERSION	"v2.03.00-k2"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
@@ -61,8 +62,9 @@ static int msi;
 module_param(msi, int, 0);
 MODULE_PARM_DESC(msi, "Turn on Message Signaled Interrupts.");
 
-static struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
+static const struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3022_DEVICE_ID)},
+	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3032_DEVICE_ID)},
 	/* required last entry */
 	{0,}
 };
@@ -1466,6 +1468,9 @@ static int ql_mii_setup(struct ql3_adapt
 			 2) << 7))
 		return -1;
 
+	if (qdev->device_id == QL3032_DEVICE_ID)
+		ql_write_page0_reg(qdev, &port_regs->macMIIMgmtControlReg, 0x0f00000);	/* clear bits 4-7 */
+
 	/* Divide 125MHz clock by 28 to meet PHY timing requirements */
 	reg = MAC_MII_CONTROL_CLK_SEL_DIV28;
 
@@ -1697,18 +1702,43 @@ static void ql_process_mac_tx_intr(struc
 				   struct ob_mac_iocb_rsp *mac_rsp)
 {
 	struct ql_tx_buf_cb *tx_cb;
+	int i;
 
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
+
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(tx_cb, mapaddr),
-			 pci_unmap_len(tx_cb, maplen), PCI_DMA_TODEVICE);
-	dev_kfree_skb_irq(tx_cb->skb);
+			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
+			 pci_unmap_len(&tx_cb->map[0], maplen),
+			 PCI_DMA_TODEVICE);
+	tx_cb->seg_count--;
+	if (tx_cb->seg_count) {
+		for (i = 1; i < tx_cb->seg_count; i++) {
+			pci_unmap_page(qdev->pdev,
+				       pci_unmap_addr(&tx_cb->map[i],
+						      mapaddr),
+				       pci_unmap_len(&tx_cb->map[i], maplen),
+				       PCI_DMA_TODEVICE);
+		}
+	}
 	qdev->stats.tx_packets++;
 	qdev->stats.tx_bytes += tx_cb->skb->len;
+	dev_kfree_skb_irq(tx_cb->skb);
 	tx_cb->skb = NULL;
 	atomic_inc(&qdev->tx_count);
 }
 
+/*
+ * The difference between 3022 and 3032 for inbound completions:
+ * 3022 uses two buffers per completion.  The first buffer contains 
+ * (some) header info, the second the remainder of the headers plus 
+ * the data.  For this chip we reserve some space at the top of the 
+ * receive buffer so that the header info in buffer one can be 
+ * prepended to the buffer two.  Buffer two is the sent up while 
+ * buffer one is returned to the hardware to be reused.
+ * 3032 receives all of it's data and headers in one buffer for a 
+ * simpler process.  3032 also supports checksum verification as
+ * can be seen in ql_process_macip_rx_intr().
+ */
 static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 				   struct ib_mac_iocb_rsp *ib_mac_rsp_ptr)
 {
@@ -1731,14 +1761,17 @@ static void ql_process_mac_rx_intr(struc
 	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
 	qdev->small_buf_release_cnt++;
 
-	/* start of first buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
-		qdev->lrg_buf_index = 0;
-	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
-	curr_ial_ptr++;
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/* start of first buffer (3022 only) */
+		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
+		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
+		qdev->lrg_buf_release_cnt++;
+		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+			qdev->lrg_buf_index = 0;
+		}
+		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
+		curr_ial_ptr++;
+	}
 
 	/* start of second buffer */
 	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
@@ -1769,7 +1802,8 @@ static void ql_process_mac_rx_intr(struc
 	qdev->ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
-	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
 }
 
@@ -1781,7 +1815,7 @@ static void ql_process_macip_rx_intr(str
 	struct ql_rcv_buf_cb *lrg_buf_cb1 = NULL;
 	struct ql_rcv_buf_cb *lrg_buf_cb2 = NULL;
 	u32 *curr_ial_ptr;
-	struct sk_buff *skb1, *skb2;
+	struct sk_buff *skb1 = NULL, *skb2;
 	struct net_device *ndev = qdev->ndev;
 	u16 length = le16_to_cpu(ib_ip_rsp_ptr->length);
 	u16 size = 0;
@@ -1797,16 +1831,20 @@ static void ql_process_macip_rx_intr(str
 	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
 	qdev->small_buf_release_cnt++;
 
-	/* start of first buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
-		qdev->lrg_buf_index = 0;
-	skb1 = lrg_buf_cb1->skb;
-	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
-	curr_ial_ptr++;
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/* start of first buffer on 3022 */
+		lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
+		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
+		qdev->lrg_buf_release_cnt++;
+		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
+			qdev->lrg_buf_index = 0;
+		skb1 = lrg_buf_cb1->skb;
+		curr_ial_ptr++;	/* 64-bit pointers require two incs. */
+		curr_ial_ptr++;
+		size = ETH_HLEN;
+		if (*((u16 *) skb1->data) != 0xFFFF)
+			size += VLAN_ETH_HLEN - ETH_HLEN;
+	}
 
 	/* start of second buffer */
 	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
@@ -1816,18 +1854,6 @@ static void ql_process_macip_rx_intr(str
 	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
 
-	qdev->stats.rx_packets++;
-	qdev->stats.rx_bytes += length;
-
-	/*
-	 * Copy the ethhdr from first buffer to second. This
-	 * is necessary for IP completions.
-	 */
-	if (*((u16 *) skb1->data) != 0xFFFF)
-		size = VLAN_ETH_HLEN;
-	else
-		size = ETH_HLEN;
-
 	skb_put(skb2, length);	/* Just the second buffer length here. */
 	pci_unmap_single(qdev->pdev,
 			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
@@ -1835,16 +1861,45 @@ static void ql_process_macip_rx_intr(str
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb2->data);
 
-	memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/*
+		 * Copy the ethhdr from first buffer to second. This
+		 * is necessary for 3022 IP completions.
+		 */
+		memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+		skb2->ip_summed = CHECKSUM_NONE;
+	} else {
+		skb2->ip_summed = CHECKSUM_COMPLETE;
+		if (ib_ip_rsp_ptr->checksum & IB_IP_IOCB_RSP_3032_ICE) {
+			skb2->ip_summed = CHECKSUM_NONE;
+			printk(KERN_ERR
+			       "%s: Bad checksum for this IP packet.\n",
+			       __func__);
+		} else if ((ib_ip_rsp_ptr->
+			 checksum & (IB_IP_IOCB_RSP_3032_TCP |
+				     IB_IP_IOCB_RSP_3032_UDP))
+			&& (ib_ip_rsp_ptr->
+			    checksum & (IB_IP_IOCB_RSP_3032_NUC |
+					IB_IP_IOCB_RSP_3032_CE))) {
+			skb2->ip_summed = CHECKSUM_NONE;	// Forward the pack up and let the stack figure out the checksum is bad.
+			printk(KERN_ERR
+			       "%s: Bad checksum for this %s packet.\n",
+			       __func__,
+			       ((ib_ip_rsp_ptr->
+				 checksum & IB_IP_IOCB_RSP_3032_TCP) ? "TCP" :
+				"UDP"));
+		} 
+	}
 	skb2->dev = qdev->ndev;
-	skb2->ip_summed = CHECKSUM_NONE;
 	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
-
 	netif_receive_skb(skb2);
+	qdev->stats.rx_packets++;
+	qdev->stats.rx_bytes += length;
 	ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
-	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
 }
 
@@ -1871,16 +1926,19 @@ static int ql_tx_rx_clean(struct ql3_ada
 			break;
 
 		case OPCODE_IB_MAC_IOCB:
+		case OPCODE_IB_3032_MAC_IOCB:
 			ql_process_mac_rx_intr(qdev, (struct ib_mac_iocb_rsp *)
 					       net_rsp);
 			(*rx_cleaned)++;
 			break;
 
 		case OPCODE_IB_IP_IOCB:
+		case OPCODE_IB_3032_IP_IOCB:
 			ql_process_macip_rx_intr(qdev, (struct ib_ip_iocb_rsp *)
 						 net_rsp);
 			(*rx_cleaned)++;
 			break;
+
 		default:
 			{
 				u32 *tmp = (u32 *) net_rsp;
@@ -2023,13 +2081,96 @@ static irqreturn_t ql3xxx_isr(int irq, v
 	return IRQ_RETVAL(handled);
 }
 
+/*
+ * Get the total number of segments needed for the 
+ * given number of fragments.  This is necessary because
+ * outbound address lists (OAL) will be used when more than
+ * two frags are given.  Each address list has 5 addr/len 
+ * pairs.  The 5th pair in each AOL is used to  point to
+ * the next AOL if more frags are coming.  
+ * That is why the frags:segment count  ratio is not linear.
+ */
+static int ql_get_seg_count(unsigned short frags)
+{
+	switch(frags) {
+	case 0:	return 1;	/* just the skb->data seg */
+	case 1:	return 2;	/* skb->data + 1 frag */
+	case 2:	return 3;	/* skb->data + 2 frags */
+	case 3:	return 5;	/* skb->data + 1 frag + 1 AOL containting 2 frags */
+	case 4:	return 6;
+	case 5:	return 7;
+	case 6:	return 8;
+	case 7:	return 10;
+	case 8:	return 11;
+	case 9:	return 12;
+	case 10: return 13;
+	case 11: return 15;
+	case 12: return 16;
+	case 13: return 17;
+	case 14: return 18;
+	case 15: return 20;
+	case 16: return 21;
+	case 17: return 22;
+	case 18: return 23;
+	}
+	return -1;
+}
+
+static void ql_hw_csum_setup(struct sk_buff *skb,
+			     struct ob_mac_iocb_req *mac_iocb_ptr)
+{
+	struct ethhdr *eth;
+	struct iphdr *ip = NULL;
+	u8 offset = ETH_HLEN;
+
+	eth = (struct ethhdr *)(skb->data);
+
+	if (eth->h_proto == __constant_htons(ETH_P_IP)) {
+		ip = (struct iphdr *)&skb->data[ETH_HLEN];
+	} else if (eth->h_proto == htons(ETH_P_8021Q) &&
+		   ((struct vlan_ethhdr *)skb->data)->
+		   h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP)) {
+		ip = (struct iphdr *)&skb->data[VLAN_ETH_HLEN];
+		offset = VLAN_ETH_HLEN;
+	}
+
+	if (ip) {
+		if (ip->protocol == IPPROTO_TCP) {
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC;
+			mac_iocb_ptr->ip_hdr_off = offset;
+			mac_iocb_ptr->ip_hdr_len = ip->ihl;
+		} else if (ip->protocol == IPPROTO_UDP) {
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC;
+			mac_iocb_ptr->ip_hdr_off = offset;
+			mac_iocb_ptr->ip_hdr_len = ip->ihl;
+		}
+	}
+}
+
+/*
+ * The difference between 3022 and 3032 sends:
+ * 3022 only supports a simple single segment transmission.
+ * 3032 supports checksumming and scatter/gather lists (fragments).
+ * The 3032 supports sglists by using the 3 addr/len pairs (ALP) 
+ * in the IOCB plus a chain of outbound address lists (OAL) that 
+ * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th) 
+ * will used to point to an OAL when more ALP entries are required.  
+ * The IOCB is always the top of the chain followed by one or more 
+ * OALs (when necessary).
+ */
 static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
 	struct ql_tx_buf_cb *tx_cb;
+	u32 tot_len = skb->len;
+	struct oal *oal;
+	struct oal_entry *oal_entry;
+	int len;
 	struct ob_mac_iocb_req *mac_iocb_ptr;
 	u64 map;
+	int seg_cnt, seg = 0;
+	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
 	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
 		if (!netif_queue_stopped(ndev))
@@ -2037,21 +2178,79 @@ static int ql3xxx_send(struct sk_buff *s
 		return NETDEV_TX_BUSY;
 	}
 	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
+	seg_cnt = tx_cb->seg_count = ql_get_seg_count((skb_shinfo(skb)->nr_frags));
+	if(seg_cnt == -1) {
+		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
+		return NETDEV_TX_OK;
+
+	}
 	mac_iocb_ptr = tx_cb->queue_entry;
 	memset((void *)mac_iocb_ptr, 0, sizeof(struct ob_mac_iocb_req));
 	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
 	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
 	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
-	mac_iocb_ptr->data_len = cpu_to_le16((u16) skb->len);
+	mac_iocb_ptr->data_len = cpu_to_le16((u16) tot_len);
 	tx_cb->skb = skb;
-	map = pci_map_single(qdev->pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
-	mac_iocb_ptr->buf_addr0_low = cpu_to_le32(LS_64BITS(map));
-	mac_iocb_ptr->buf_addr0_high = cpu_to_le32(MS_64BITS(map));
-	mac_iocb_ptr->buf_0_len = cpu_to_le32(skb->len | OB_MAC_IOCB_REQ_E);
-	pci_unmap_addr_set(tx_cb, mapaddr, map);
-	pci_unmap_len_set(tx_cb, maplen, skb->len);
-	atomic_dec(&qdev->tx_count);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		ql_hw_csum_setup(skb, mac_iocb_ptr);
+	len = skb_headlen(skb);
+	map = pci_map_single(qdev->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
+	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+	oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+	oal_entry->len = cpu_to_le32(len);
+	pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+	pci_unmap_len_set(&tx_cb->map[seg], maplen, len);
+	seg++;
+
+	if (!skb_shinfo(skb)->nr_frags) {
+		/* Terminate the last segment. */
+		oal_entry->len =
+		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+	} else {
+		int i;
+		oal = tx_cb->oal;
+		for (i=0; i<frag_cnt; i++,seg++) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			oal_entry++;
+			if ((seg == 2 && seg_cnt > 3) ||	/* Check for continuation */
+			    (seg == 7 && seg_cnt > 8) ||	/* requirements. It's strange */
+			    (seg == 12 && seg_cnt > 13) ||	/* but necessary. */
+			    (seg == 17 && seg_cnt > 18)) {
+				/* Continuation entry points to outbound address list. */
+				map = pci_map_single(qdev->pdev, oal,
+						     sizeof(struct oal),
+						     PCI_DMA_TODEVICE);
+				oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+				oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+				oal_entry->len =
+				    cpu_to_le32(sizeof(struct oal) |
+						OAL_CONT_ENTRY);
+				pci_unmap_addr_set(&tx_cb->map[seg], mapaddr,
+						   map);
+				pci_unmap_len_set(&tx_cb->map[seg], maplen,
+						  len);
+				oal_entry = (struct oal_entry *)oal;
+				oal++;
+				seg++;
+			}
 
+			map =
+			    pci_map_page(qdev->pdev, frag->page,
+					 frag->page_offset, frag->size,
+					 PCI_DMA_TODEVICE);
+			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+			oal_entry->len = cpu_to_le32(frag->size);
+			pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+			pci_unmap_len_set(&tx_cb->map[seg], maplen,
+					  frag->size);
+		}
+		/* Terminate the last segment. */
+		oal_entry->len =
+		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+	}
+	wmb();
 	qdev->req_producer_index++;
 	if (qdev->req_producer_index == NUM_REQ_Q_ENTRIES)
 		qdev->req_producer_index = 0;
@@ -2065,8 +2264,10 @@ static int ql3xxx_send(struct sk_buff *s
 		printk(KERN_DEBUG PFX "%s: tx queued, slot %d, len %d\n",
 		       ndev->name, qdev->req_producer_index, skb->len);
 
+	atomic_dec(&qdev->tx_count);
 	return NETDEV_TX_OK;
 }
+
 static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
 	qdev->req_q_size =
@@ -2350,7 +2551,22 @@ static int ql_alloc_large_buffers(struct
 	return 0;
 }
 
-static void ql_create_send_free_list(struct ql3_adapter *qdev)
+static void ql_free_send_free_list(struct ql3_adapter *qdev)
+{
+	struct ql_tx_buf_cb *tx_cb;
+	int i;
+
+	tx_cb = &qdev->tx_buf[0];
+	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+		if (tx_cb->oal) {
+			kfree(tx_cb->oal);
+			tx_cb->oal = NULL;
+		}
+		tx_cb++;
+	}
+}
+
+static int ql_create_send_free_list(struct ql3_adapter *qdev)
 {
 	struct ql_tx_buf_cb *tx_cb;
 	int i;
@@ -2359,11 +2575,16 @@ static void ql_create_send_free_list(str
 
 	/* Create free list of transmit buffers */
 	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+
 		tx_cb = &qdev->tx_buf[i];
 		tx_cb->skb = NULL;
 		tx_cb->queue_entry = req_q_curr;
 		req_q_curr++;
+		tx_cb->oal = kmalloc(512, GFP_KERNEL);
+		if (tx_cb->oal == NULL)
+			return -1;
 	}
+	return 0;
 }
 
 static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
@@ -2438,12 +2659,14 @@ static int ql_alloc_mem_resources(struct
 
 	/* Initialize the large buffer queue. */
 	ql_init_large_buffers(qdev);
-	ql_create_send_free_list(qdev);
+	if (ql_create_send_free_list(qdev))
+		goto err_free_list;
 
 	qdev->rsp_current = qdev->rsp_q_virt_addr;
 
 	return 0;
-
+err_free_list:
+	ql_free_send_free_list(qdev);
 err_small_buffers:
 	ql_free_buffer_queues(qdev);
 err_buffer_queues:
@@ -2459,6 +2682,7 @@ err_req_rsp:
 
 static void ql_free_mem_resources(struct ql3_adapter *qdev)
 {
+	ql_free_send_free_list(qdev);
 	ql_free_large_buffers(qdev);
 	ql_free_small_buffers(qdev);
 	ql_free_buffer_queues(qdev);
@@ -2673,7 +2897,6 @@ static int ql_adapter_initialize(struct 
 
 		value = qdev->nvram_data.tcpMaxWindowSize;
 		ql_write_page0_reg(qdev, &port_regs->tcpMaxWindow, value);
-
 		value = (0xFFFF << 16) | qdev->nvram_data.extHwConfig;
 
 		if(ql_sem_spinlock(qdev, QL_FLASH_SEM_MASK,
@@ -2757,11 +2980,20 @@ static int ql_adapter_initialize(struct 
 	}
 
 	/* Enable Ethernet Function */
-	value =
-	    (PORT_CONTROL_EF | PORT_CONTROL_ET | PORT_CONTROL_EI |
-	     PORT_CONTROL_HH);
-	ql_write_page0_reg(qdev, &port_regs->portControl,
-			   ((value << 16) | value));
+	if (qdev->device_id == QL3032_DEVICE_ID) {
+		value =
+		    (QL3032_PORT_CONTROL_EF | QL3032_PORT_CONTROL_KIE |
+		     QL3032_PORT_CONTROL_EIv6 | QL3032_PORT_CONTROL_EIv4);
+		ql_write_page0_reg(qdev, &port_regs->functionControl,
+				   ((value << 16) | value));
+	} else {
+		value =
+		    (PORT_CONTROL_EF | PORT_CONTROL_ET | PORT_CONTROL_EI |
+		     PORT_CONTROL_HH);
+		ql_write_page0_reg(qdev, &port_regs->portControl,
+				   ((value << 16) | value));
+	}
+
 
 out:
 	return status;
@@ -2908,8 +3140,10 @@ static void ql_display_dev_info(struct n
 	struct pci_dev *pdev = qdev->pdev;
 
 	printk(KERN_INFO PFX
-	       "\n%s Adapter %d RevisionID %d found on PCI slot %d.\n",
-	       DRV_NAME, qdev->index, qdev->chip_rev_id, qdev->pci_slot);
+	       "\n%s Adapter %d RevisionID %d found %s on PCI slot %d.\n",
+	       DRV_NAME, qdev->index, qdev->chip_rev_id,
+	       (qdev->device_id == QL3032_DEVICE_ID) ? "QLA3032" : "QLA3022",
+	       qdev->pci_slot);
 	printk(KERN_INFO PFX
 	       "%s Interface.\n",
 	       test_bit(QL_LINK_OPTICAL,&qdev->flags) ? "OPTICAL" : "COPPER");
@@ -3201,15 +3435,22 @@ static void ql_reset_work(struct ql3_ada
 		 * Loop through the active list and return the skb.
 		 */
 		for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+			int j;
 			tx_cb = &qdev->tx_buf[i];
 			if (tx_cb->skb) {
-
 				printk(KERN_DEBUG PFX
 				       "%s: Freeing lost SKB.\n",
 				       qdev->ndev->name);
 				pci_unmap_single(qdev->pdev,
-					pci_unmap_addr(tx_cb, mapaddr),
-					pci_unmap_len(tx_cb, maplen), PCI_DMA_TODEVICE);
+					 pci_unmap_addr(&tx_cb->map[0], mapaddr),
+					 pci_unmap_len(&tx_cb->map[0], maplen),
+					 PCI_DMA_TODEVICE);
+				for(j=1;j<tx_cb->seg_count;j++) {
+					pci_unmap_page(qdev->pdev,
+					       pci_unmap_addr(&tx_cb->map[j],mapaddr),
+					       pci_unmap_len(&tx_cb->map[j],maplen),
+					       PCI_DMA_TODEVICE);
+				}
 				dev_kfree_skb(tx_cb->skb);
 				tx_cb->skb = NULL;
 			}
@@ -3365,22 +3606,25 @@ static int __devinit ql3xxx_probe(struct
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	ndev->features = NETIF_F_LLTX;
-	if (pci_using_dac)
-		ndev->features |= NETIF_F_HIGHDMA;
-
 	pci_set_drvdata(pdev, ndev);
 
 	qdev = netdev_priv(ndev);
 	qdev->index = cards_found;
 	qdev->ndev = ndev;
 	qdev->pdev = pdev;
+	qdev->device_id = pci_entry->device;
 	qdev->port_link_state = LS_DOWN;
 	if (msi)
 		qdev->msi = 1;
 
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 
+	ndev->features |= NETIF_F_LLTX;
+	if (pci_using_dac)
+		ndev->features |= NETIF_F_HIGHDMA;
+	if (qdev->device_id == QL3032_DEVICE_ID)
+		ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_SG);
+
 	qdev->mem_map_registers =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
 			    pci_resource_len(qdev->pdev, 1));
@@ -3454,7 +3698,6 @@ static int __devinit ql3xxx_probe(struct
 	}
 
 	/* we're going to reset, so assume we have no link for now */
-
 	netif_carrier_off(ndev);
 	netif_stop_queue(ndev);
 
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 65da2c0..bc357cd 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -21,7 +21,9 @@ #define OPCODE_UPDATE_NCB_IOCB_FN2      
 
 #define OPCODE_UPDATE_NCB_IOCB      0xF0
 #define OPCODE_IB_MAC_IOCB          0xF9
+#define OPCODE_IB_3032_MAC_IOCB     0x09
 #define OPCODE_IB_IP_IOCB           0xFA
+#define OPCODE_IB_3032_IP_IOCB      0x0A
 #define OPCODE_IB_TCP_IOCB          0xFB
 #define OPCODE_DUMP_PROTO_IOCB      0xFE
 #define OPCODE_BUFFER_ALERT_IOCB    0xFB
@@ -37,18 +39,23 @@ #define FN1_MA_BITS_MASK    0x80
 struct ob_mac_iocb_req {
 	u8 opcode;
 	u8 flags;
-#define OB_MAC_IOCB_REQ_MA  0xC0
-#define OB_MAC_IOCB_REQ_F   0x20
-#define OB_MAC_IOCB_REQ_X   0x10
+#define OB_MAC_IOCB_REQ_MA  0xe0
+#define OB_MAC_IOCB_REQ_F   0x10
+#define OB_MAC_IOCB_REQ_X   0x08
 #define OB_MAC_IOCB_REQ_D   0x02
 #define OB_MAC_IOCB_REQ_I   0x01
-	__le16 reserved0;
+	u8 flags1;
+#define OB_3032MAC_IOCB_REQ_IC	0x04
+#define OB_3032MAC_IOCB_REQ_TC	0x02
+#define OB_3032MAC_IOCB_REQ_UC	0x01
+	u8 reserved0;
 
 	__le32 transaction_id;
 	__le16 data_len;
-	__le16 reserved1;
+	u8 ip_hdr_off;
+	u8 ip_hdr_len;
+	__le32 reserved1;
 	__le32 reserved2;
-	__le32 reserved3;
 	__le32 buf_addr0_low;
 	__le32 buf_addr0_high;
 	__le32 buf_0_len;
@@ -58,8 +65,8 @@ #define OB_MAC_IOCB_REQ_I   0x01
 	__le32 buf_addr2_low;
 	__le32 buf_addr2_high;
 	__le32 buf_2_len;
+	__le32 reserved3;
 	__le32 reserved4;
-	__le32 reserved5;
 };
 /*
  * The following constants define control bits for buffer
@@ -74,6 +81,7 @@ struct ob_mac_iocb_rsp {
 	u8 opcode;
 	u8 flags;
 #define OB_MAC_IOCB_RSP_P   0x08
+#define OB_MAC_IOCB_RSP_L   0x04
 #define OB_MAC_IOCB_RSP_S   0x02
 #define OB_MAC_IOCB_RSP_I   0x01
 
@@ -85,6 +93,7 @@ #define OB_MAC_IOCB_RSP_I   0x01
 
 struct ib_mac_iocb_rsp {
 	u8 opcode;
+#define IB_MAC_IOCB_RSP_V   0x80
 	u8 flags;
 #define IB_MAC_IOCB_RSP_S   0x80
 #define IB_MAC_IOCB_RSP_H1  0x40
@@ -138,6 +147,7 @@ #define OB_IP_IOCB_REQ_R    0x10000000
 struct ob_ip_iocb_rsp {
 	u8 opcode;
 	u8 flags;
+#define OB_MAC_IOCB_RSP_H       0x10
 #define OB_MAC_IOCB_RSP_E       0x08
 #define OB_MAC_IOCB_RSP_L       0x04
 #define OB_MAC_IOCB_RSP_S       0x02
@@ -220,6 +230,10 @@ #define OB_TCP_IOCB_RSP_SHIFT   4
 
 struct ib_ip_iocb_rsp {
 	u8 opcode;
+#define IB_IP_IOCB_RSP_3032_V   0x80
+#define IB_IP_IOCB_RSP_3032_O   0x40
+#define IB_IP_IOCB_RSP_3032_I   0x20
+#define IB_IP_IOCB_RSP_3032_R   0x10
 	u8 flags;
 #define IB_IP_IOCB_RSP_S        0x80
 #define IB_IP_IOCB_RSP_H1       0x40
@@ -230,6 +244,12 @@ #define IB_IP_IOCB_RSP_MA       0x07
 
 	__le16 length;
 	__le16 checksum;
+#define IB_IP_IOCB_RSP_3032_ICE		0x01
+#define IB_IP_IOCB_RSP_3032_CE		0x02
+#define IB_IP_IOCB_RSP_3032_NUC		0x04
+#define IB_IP_IOCB_RSP_3032_UDP		0x08
+#define IB_IP_IOCB_RSP_3032_TCP		0x10
+#define IB_IP_IOCB_RSP_3032_IPE		0x20
 	__le16 reserved;
 #define IB_IP_IOCB_RSP_R        0x01
 	__le32 ial_low;
@@ -524,6 +544,23 @@ enum {
 	IP_ADDR_INDEX_REG_FUNC_2_SEC = 0x0005,
 	IP_ADDR_INDEX_REG_FUNC_3_PRI = 0x0006,
 	IP_ADDR_INDEX_REG_FUNC_3_SEC = 0x0007,
+	/* 3032 addition start */
+	IP_ADDR_INDEX_REG_6 = 0x0008,
+	IP_ADDR_INDEX_REG_OFFSET_MASK = 0x0030,
+	IP_ADDR_INDEX_REG_E = 0x0040, 
+	    /* 3032 addition end */
+};
+enum {
+	QL3032_PORT_CONTROL_DS = 0x0001,
+	QL3032_PORT_CONTROL_HH = 0x0002,
+	QL3032_PORT_CONTROL_EIv6 = 0x0004,
+	QL3032_PORT_CONTROL_EIv4 = 0x0008,
+	QL3032_PORT_CONTROL_ET = 0x0010,
+	QL3032_PORT_CONTROL_EF = 0x0020,
+	QL3032_PORT_CONTROL_DRM = 0x0040,
+	QL3032_PORT_CONTROL_RLB = 0x0080,
+	QL3032_PORT_CONTROL_RCB = 0x0100,
+	QL3032_PORT_CONTROL_KIE = 0x0200,
 };
 
 enum {
@@ -657,7 +694,10 @@ struct ql3xxx_port_registers {
 	u32 internalRamWDataReg;
 	u32 reclaimedBufferAddrRegLow;
 	u32 reclaimedBufferAddrRegHigh;
-	u32 reserved[2];
+	/* 3032 addition start */
+	u32 tcpConfiguration;
+	u32 functionControl;
+	/* 3032 addition end */
 	u32 fpgaRevID;
 	u32 localRamAddr;
 	u32 localRamDataAutoIncr;
@@ -831,7 +871,7 @@ enum {
 };
 enum {
 /* Auburn Bits */
-	    AUBURN_EEPROM_DI = 0x8,
+	AUBURN_EEPROM_DI = 0x8,
 	AUBURN_EEPROM_DI_0 = 0x0,
 	AUBURN_EEPROM_DI_1 = 0x8,
 	AUBURN_EEPROM_DO = 0x4,
@@ -843,7 +883,7 @@ enum {
 	AUBURN_EEPROM_CLK_RISE = 0x1,
 	AUBURN_EEPROM_CLK_FALL = 0x0,
 };
-enum {EEPROM_SIZE = FM93C86A_SIZE_16,
+enum { EEPROM_SIZE = FM93C86A_SIZE_16,
 	EEPROM_NO_ADDR_BITS = FM93C86A_NO_ADDR_BITS_16,
 	EEPROM_NO_DATA_BITS = FM93C56A_DATA_BITS_16,
 };
@@ -851,7 +891,7 @@ enum {EEPROM_SIZE = FM93C86A_SIZE_16,
 /*
  *  MAC Config data structure
  */
-    struct eeprom_port_cfg {
+struct eeprom_port_cfg {
 	u16 etherMtu_mac;
 	u16 pauseThreshold_mac;
 	u16 resumeThreshold_mac;
@@ -963,6 +1003,7 @@ #define IPSEC_CONFIG_PRESENT 0x0001
 
 #define QL3XXX_VENDOR_ID    0x1077
 #define QL3022_DEVICE_ID    0x3022
+#define QL3032_DEVICE_ID    0x3032
 
 /* MTU & Frame Size stuff */
 #define NORMAL_MTU_SIZE 		ETH_DATA_LEN
@@ -1038,11 +1079,41 @@ struct ql_rcv_buf_cb {
 	int index;
 };
 
+/*
+ * Original IOCB has 3 sg entries:
+ * first points to skb-data area
+ * second points to first frag
+ * third points to next oal.
+ * OAL has 5 entries:
+ * 1 thru 4 point to frags
+ * fifth points to next oal.
+ */ 
+#define MAX_OAL_CNT ((MAX_SKB_FRAGS-1)/4 + 1)
+
+struct oal_entry {
+	u32 dma_lo;
+	u32 dma_hi;
+	u32 len;
+#define OAL_LAST_ENTRY   0x80000000	/* Last valid buffer in list. */
+#define OAL_CONT_ENTRY   0x40000000	/* points to an OAL. (continuation) */
+//	u32 reserved;
+};
+
+struct oal {
+	struct oal_entry oal_entry[5];
+};
+
+struct map_list {
+	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
+	 DECLARE_PCI_UNMAP_LEN(maplen);
+};
+
 struct ql_tx_buf_cb {
 	struct sk_buff *skb;
 	struct ob_mac_iocb_req *queue_entry ;
-	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	 DECLARE_PCI_UNMAP_LEN(maplen);
+	int seg_count;
+	struct oal *oal;
+	struct map_list map[MAX_SKB_FRAGS+1]; 
 };
 
 /* definitions for type field */
@@ -1176,7 +1247,6 @@ struct ql3_adapter {
 	u32 port_link_state;
 	u32 last_rsp_offset;
 
-	/* 4022 specific */
 	u32 mac_index;		/* Driver's MAC number can be 0 or 1 for first and second networking functions respectively */
 	u32 PHYAddr;		/* Address of PHY 0x1e00 Port 0 and 0x1f00 Port 1 */
 	u32 mac_ob_opcode;	/* Opcode to use on mac transmission */
@@ -1189,6 +1259,7 @@ struct ql3_adapter {
 	struct work_struct reset_work;
 	struct work_struct tx_timeout_work;
 	u32 max_frame_size;
+	u32 device_id;
 };
 
 #endif				/* _QLA3XXX_H_ */

