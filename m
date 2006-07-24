From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 2/2] s2io driver bug fixes
Date: Mon, 24 Jul 2006 19:55:09 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10607241952540.24957-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, ananda.raju@neterion.com,
	alicia.pena@neterion.com, sivakumar.subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60046 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932338AbWGXXzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 19:55:11 -0400
To: netdev@vger.kernel.org, jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
	This patch contains some of the bug fixes and enhancements done to
	s2io driver. Following are the brief description of changes

	1. code cleanup to handle gso modification better
	2. Move repeated code in rx path, to a common function 
	   s2io_chk_rx_buffers()
	3. Bug fix in MSI interrupt 
	4. clear statistics when card is down
	5. Avoid linked list traversing in lro aggregation.
	6. Use pci_dma_sync_single_for_cpu for buffer0 in case of 2/3
	   buffer mode.
	7. ethtool tso get/set functions to set clear NETIF_F_TSO6
	8. Stop LRO aggregation when we receive ECN notification

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr bug_fixes_1/drivers/net/s2io.c bug_fixes_2/drivers/net/s2io.c
--- bug_fixes_1/drivers/net/s2io.c	2006-07-14 09:26:09.000000000 -0700
+++ bug_fixes_2/drivers/net/s2io.c	2006-07-21 05:22:19.000000000 -0700
@@ -76,7 +76,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.14.2"
+#define DRV_VERSION "2.0.15.2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -2383,9 +2383,14 @@ static int fill_rx_buffers(struct s2io_n
 			skb->data = (void *) (unsigned long)tmp;
 			skb->tail = (void *) (unsigned long)tmp;
 
-			((RxD3_t*)rxdp)->Buffer0_ptr =
-			    pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
+			if (!(((RxD3_t*)rxdp)->Buffer0_ptr))
+				((RxD3_t*)rxdp)->Buffer0_ptr =
+				   pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
 					   PCI_DMA_FROMDEVICE);
+			else
+				pci_dma_sync_single_for_device(nic->pdev,
+				    (dma_addr_t) ((RxD3_t*)rxdp)->Buffer0_ptr,
+				    BUF0_LEN, PCI_DMA_FROMDEVICE);
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
 				/* Two buffer mode */
@@ -2398,10 +2403,13 @@ static int fill_rx_buffers(struct s2io_n
 				(nic->pdev, skb->data, dev->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
-				/* Buffer-1 will be dummy buffer not used */
-				((RxD3_t*)rxdp)->Buffer1_ptr =
-				pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,
-					PCI_DMA_FROMDEVICE);
+				/* Buffer-1 will be dummy buffer. Not used */
+				if (!(((RxD3_t*)rxdp)->Buffer1_ptr)) {
+					((RxD3_t*)rxdp)->Buffer1_ptr =
+						pci_map_single(nic->pdev, 
+						ba->ba_1, BUF1_LEN,
+						PCI_DMA_FROMDEVICE);
+				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
 								(dev->mtu + 4);
@@ -2728,7 +2736,7 @@ static void rx_intr_handler(ring_info_t 
 		/* If your are next to put index then it's FIFO full condition */
 		if ((get_block == put_block) &&
 		    (get_info.offset + 1) == put_info.offset) {
-			DBG_PRINT(ERR_DBG, "%s: Ring Full\n",dev->name);
+			DBG_PRINT(INTR_DBG, "%s: Ring Full\n",dev->name);
 			break;
 		}
 		skb = (struct sk_buff *) ((unsigned long)rxdp->Host_Control);
@@ -2748,18 +2756,15 @@ static void rx_intr_handler(ring_info_t 
 				 HEADER_SNAP_SIZE,
 				 PCI_DMA_FROMDEVICE);
 		} else if (nic->rxd_mode == RXD_MODE_3B) {
-			pci_unmap_single(nic->pdev, (dma_addr_t)
+			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
 				 ((RxD3_t*)rxdp)->Buffer0_ptr,
 				 BUF0_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((RxD3_t*)rxdp)->Buffer1_ptr,
-				 BUF1_LEN, PCI_DMA_FROMDEVICE);
-			pci_unmap_single(nic->pdev, (dma_addr_t)
 				 ((RxD3_t*)rxdp)->Buffer2_ptr,
 				 dev->mtu + 4,
 				 PCI_DMA_FROMDEVICE);
 		} else {
-			pci_unmap_single(nic->pdev, (dma_addr_t)
+			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
 					 ((RxD3_t*)rxdp)->Buffer0_ptr, BUF0_LEN,
 					 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
@@ -3548,7 +3553,7 @@ static void restore_xmsi_data(nic_t *nic
 	u64 val64;
 	int i;
 
-	for (i=0; i< nic->avail_msix_vectors; i++) {
+	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
 		val64 = (BIT(7) | BIT(15) | vBIT(i, 26, 6));
@@ -3567,7 +3572,7 @@ static void store_xmsi_data(nic_t *nic)
 	int i;
 
 	/* Store and display */
-	for (i=0; i< nic->avail_msix_vectors; i++) {
+	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
 		val64 = (BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
@@ -3828,13 +3833,11 @@ static int s2io_xmit(struct sk_buff *skb
 	TxD_t *txdp;
 	TxFIFO_element_t __iomem *tx_fifo;
 	unsigned long flags;
-#ifdef NETIF_F_TSO
-	int mss;
-#endif
 	u16 vlan_tag = 0;
 	int vlan_priority = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
+	int offload_type;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -3882,13 +3885,11 @@ static int s2io_xmit(struct sk_buff *skb
 		return 0;
 	}
 
-	txdp->Control_1 = 0;
-	txdp->Control_2 = 0;
+	offload_type = s2io_offload_type(skb);
 #ifdef NETIF_F_TSO
-	mss = skb_shinfo(skb)->gso_size;
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
+	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
-		txdp->Control_1 |= TXD_TCP_LSO_MSS(mss);
+		txdp->Control_1 |= TXD_TCP_LSO_MSS(s2io_tcp_mss(skb));
 	}
 #endif
 	if (skb->ip_summed == CHECKSUM_HW) {
@@ -3906,10 +3907,10 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	frg_len = skb->len - skb->data_len;
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP) {
+	if (offload_type == SKB_GSO_UDP) {
 		int ufo_size;
 
-		ufo_size = skb_shinfo(skb)->gso_size;
+		ufo_size = s2io_udp_mss(skb);
 		ufo_size &= ~7;
 		txdp->Control_1 |= TXD_UFO_EN;
 		txdp->Control_1 |= TXD_UFO_MSS(ufo_size);
@@ -3926,16 +3927,13 @@ static int s2io_xmit(struct sk_buff *skb
 					sp->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
 		txdp++;
-		txdp->Control_1 = 0;
-		txdp->Control_2 = 0;
 	}
 
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
-
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
+	if (offload_type == SKB_GSO_UDP)
 		txdp->Control_1 |= TXD_UFO_EN;
 
 	frg_cnt = skb_shinfo(skb)->nr_frags;
@@ -3950,12 +3948,12 @@ static int s2io_xmit(struct sk_buff *skb
 		    (sp->pdev, frag->page, frag->page_offset,
 		     frag->size, PCI_DMA_TODEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
-		if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
+		if (offload_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_LAST;
 
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
+	if (offload_type == SKB_GSO_UDP)
 		frg_cnt++; /* as Txd0 was used for inband header */
 
 	tx_fifo = mac_control->tx_FIFO_start[queue];
@@ -3964,13 +3962,9 @@ static int s2io_xmit(struct sk_buff *skb
 
 	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
 		 TX_FIFO_LAST_LIST);
-
-#ifdef NETIF_F_TSO
-	if (mss)
-		val64 |= TX_FIFO_SPECIAL_FUNC;
-#endif
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
+	if (offload_type)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
+
 	writeq(val64, &tx_fifo->List_Control);
 
 	mmiowb();
@@ -4004,13 +3998,41 @@ s2io_alarm_handle(unsigned long data)
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
 
+static int s2io_chk_rx_buffers(nic_t *sp, int rng_n)
+{
+	int rxb_size, level;
+
+	if (!sp->lro) {
+		rxb_size = atomic_read(&sp->rx_bufs_left[rng_n]);
+		level = rx_buffer_level(sp, rxb_size, rng_n);
+
+		if ((level == PANIC) && (!TASKLET_IN_USE)) {
+			int ret;
+			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
+			DBG_PRINT(INTR_DBG, "PANIC levels\n");
+			if ((ret = fill_rx_buffers(sp, rng_n)) == -ENOMEM) {
+				DBG_PRINT(ERR_DBG, "Out of memory in %s",
+					  __FUNCTION__);
+				clear_bit(0, (&sp->tasklet_status));
+				return -1;
+			}
+			clear_bit(0, (&sp->tasklet_status));
+		} else if (level == LOW)
+			tasklet_schedule(&sp->task);
+
+	} else if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", sp->dev->name);
+			DBG_PRINT(ERR_DBG, " in Rx Intr!!\n");
+	}
+	return 0;
+}
+
 static irqreturn_t
 s2io_msi_handle(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
 	int i;
-	int ret;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -4032,35 +4054,8 @@ s2io_msi_handle(int irq, void *dev_id, s
 	 * reallocate the buffers from the interrupt handler itself,
 	 * else schedule a tasklet to reallocate the buffers.
 	 */
-	for (i = 0; i < config->rx_ring_num; i++) {
-		if (!sp->lro) {
-			int rxb_size = atomic_read(&sp->rx_bufs_left[i]);
-			int level = rx_buffer_level(sp, rxb_size, i);
-
-			if ((level == PANIC) && (!TASKLET_IN_USE)) {
-				DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", 
-							dev->name);
-				DBG_PRINT(INTR_DBG, "PANIC levels\n");
-				if ((ret = fill_rx_buffers(sp, i)) == -ENOMEM) {
-					DBG_PRINT(ERR_DBG, "%s:Out of memory",
-						  dev->name);
-					DBG_PRINT(ERR_DBG, " in ISR!!\n");
-					clear_bit(0, (&sp->tasklet_status));
-					atomic_dec(&sp->isr_cnt);
-					return IRQ_HANDLED;
-				}
-				clear_bit(0, (&sp->tasklet_status));
-			} else if (level == LOW) {
-				tasklet_schedule(&sp->task);
-			}
-		}
-		else if (fill_rx_buffers(sp, i) == -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "%s:Out of memory",
-							dev->name);
-				DBG_PRINT(ERR_DBG, " in Rx Intr!!\n");
-				break;
-		}
-	}
+	for (i = 0; i < config->rx_ring_num; i++)
+		s2io_chk_rx_buffers(sp, i);
 
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -4071,39 +4066,13 @@ s2io_msix_ring_handle(int irq, void *dev
 {
 	ring_info_t *ring = (ring_info_t *)dev_id;
 	nic_t *sp = ring->nic;
-	struct net_device *dev = (struct net_device *) dev_id;
-	int rxb_size, level, rng_n;
 
 	atomic_inc(&sp->isr_cnt);
-	rx_intr_handler(ring);
-
-	rng_n = ring->ring_no;
-	if (!sp->lro) {
-		rxb_size = atomic_read(&sp->rx_bufs_left[rng_n]);
-		level = rx_buffer_level(sp, rxb_size, rng_n);
 
-		if ((level == PANIC) && (!TASKLET_IN_USE)) {
-			int ret;
-			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
-			DBG_PRINT(INTR_DBG, "PANIC levels\n");
-			if ((ret = fill_rx_buffers(sp, rng_n)) == -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "Out of memory in %s",
-					  __FUNCTION__);
-				clear_bit(0, (&sp->tasklet_status));
-				return IRQ_HANDLED;
-			}
-			clear_bit(0, (&sp->tasklet_status));
-		} else if (level == LOW) {
-			tasklet_schedule(&sp->task);
-		}
-	}
-	else if (fill_rx_buffers(sp, rng_n) == -ENOMEM) {
-			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(ERR_DBG, " in Rx Intr!!\n");
-	}
+	rx_intr_handler(ring);
+	s2io_chk_rx_buffers(sp, ring->ring_no);
 
 	atomic_dec(&sp->isr_cnt);
-
 	return IRQ_HANDLED;
 }
 
@@ -4268,37 +4237,8 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * else schedule a tasklet to reallocate the buffers.
 	 */
 #ifndef CONFIG_S2IO_NAPI
-	for (i = 0; i < config->rx_ring_num; i++) {
-		if (!sp->lro) {
-			int ret;
-			int rxb_size = atomic_read(&sp->rx_bufs_left[i]);
-			int level = rx_buffer_level(sp, rxb_size, i);
-
-			if ((level == PANIC) && (!TASKLET_IN_USE)) {
-				DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", 
-							dev->name);
-				DBG_PRINT(INTR_DBG, "PANIC levels\n");
-				if ((ret = fill_rx_buffers(sp, i)) == -ENOMEM) {
-					DBG_PRINT(ERR_DBG, "%s:Out of memory",
-						  dev->name);
-					DBG_PRINT(ERR_DBG, " in ISR!!\n");
-					clear_bit(0, (&sp->tasklet_status));
-					atomic_dec(&sp->isr_cnt);
-					writeq(org_mask, &bar0->general_int_mask);
-					return IRQ_HANDLED;
-				}
-				clear_bit(0, (&sp->tasklet_status));
-			} else if (level == LOW) {
-				tasklet_schedule(&sp->task);
-			}
-		}
-		else if (fill_rx_buffers(sp, i) == -ENOMEM) {
-				DBG_PRINT(ERR_DBG, "%s:Out of memory",
-							dev->name);
-				DBG_PRINT(ERR_DBG, " in Rx intr!!\n");
-				break;
-		}
-	}
+	for (i = 0; i < config->rx_ring_num; i++)
+		s2io_chk_rx_buffers(sp, i);
 #endif
 	writeq(org_mask, &bar0->general_int_mask);
 	atomic_dec(&sp->isr_cnt);
@@ -4328,6 +4268,8 @@ static void s2io_updt_stats(nic_t *sp)
 			if (cnt == 5)
 				break; /* Updt failed */
 		} while(1);
+	} else {
+		memset(sp->mac_control.stats_info, 0, sizeof(StatInfo_t));
 	}
 }
 
@@ -5779,6 +5721,19 @@ static int s2io_ethtool_op_set_tx_csum(s
 	return 0;
 }
 
+static u32 s2io_ethtool_op_get_tso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_TSO) != 0;
+}
+static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	else
+		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
+
+	return 0;
+}
 
 static struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings = s2io_ethtool_gset,
@@ -5799,8 +5754,8 @@ static struct ethtool_ops netdev_ethtool
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
-	.get_tso = ethtool_op_get_tso,
-	.set_tso = ethtool_op_set_tso,
+	.get_tso = s2io_ethtool_op_get_tso,
+	.set_tso = s2io_ethtool_op_set_tso,
 #endif
 	.get_ufo = ethtool_op_get_ufo,
 	.set_ufo = ethtool_op_set_ufo,
@@ -7438,8 +7393,13 @@ static int verify_l3_l4_lro_capable(lro_
 	if (ip->ihl != 5) /* IP has options */
 		return -1;
 
+	/* If we see CE codepoint in IP header, packet is not mergeable */
+	if (INET_ECN_is_ce(ipv4_get_dsfield(ip)))
+		return -1;
+
+	/* If we see ECE or CWR flags in TCP header, packet is not mergeable */
 	if (tcp->urg || tcp->psh || tcp->rst || tcp->syn || tcp->fin ||
-								!tcp->ack) {
+				    tcp->ece || tcp->cwr || !tcp->ack) {
 		/*
 		 * Currently recognize only the ack control word and
 		 * any other control field being set would result in
@@ -7593,18 +7553,16 @@ static void queue_rx_frame(struct sk_buf
 static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff *skb,
 			   u32 tcp_len)
 {
-	struct sk_buff *tmp, *first = lro->parent;
+	struct sk_buff *first = lro->parent;
 
 	first->len += tcp_len;
 	first->data_len = lro->frags_len;
 	skb_pull(skb, (skb->len - tcp_len));
-	if ((tmp = skb_shinfo(first)->frag_list)) {
-		while (tmp->next)
-			tmp = tmp->next;
-		tmp->next = skb;
-	}
+	if (skb_shinfo(first)->frag_list)
+		lro->last_frag->next = skb;
 	else
 		skb_shinfo(first)->frag_list = skb;
+	lro->last_frag = skb;
 	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
 	return;
 }
diff -upNr bug_fixes_1/drivers/net/s2io.h bug_fixes_2/drivers/net/s2io.h
--- bug_fixes_1/drivers/net/s2io.h	2006-07-14 08:05:05.000000000 -0700
+++ bug_fixes_2/drivers/net/s2io.h	2006-07-17 02:13:23.000000000 -0700
@@ -719,6 +719,7 @@ struct msix_info_st {
 /* Data structure to represent a LRO session */
 typedef struct lro {
 	struct sk_buff	*parent;
+	struct sk_buff  *last_frag;
 	u8		*l2h;
 	struct iphdr	*iph;
 	struct tcphdr	*tcph;
@@ -1012,6 +1013,10 @@ static void queue_rx_frame(struct sk_buf
 static void update_L3L4_header(nic_t *sp, lro_t *lro);
 static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff *skb, u32 tcp_len);
 
+#define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size
+#define s2io_udp_mss(skb) skb_shinfo(skb)->gso_size
+#define s2io_offload_type(skb) skb_shinfo(skb)->gso_type
+
 #define S2IO_PARM_INT(X, def_val) \
 	static unsigned int X = def_val;\
 		module_param(X , uint, 0);

