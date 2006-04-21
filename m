From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [patch 5/5] s2io driver updates
Date: Fri, 21 Apr 2006 19:23:26 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10604211920270.16549-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, alicia.pena@neterion.com,
	ananda.raju@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:18891 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1750757AbWDUXXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 19:23:35 -0400
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 
	The following patch contains fix related to init and shutdown of adapter
	as per user guide.  The list of changes include

	1. shutdown gracefully.
	2. Need to mask/unmask interrupts in ISR required fro Xframe-E
	3. Tx FIFO should be enabled after WRR calender programming

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr stat_enhancement/drivers/net/s2io.c bug_fixes2/drivers/net/s2io.c
--- stat_enhancement/drivers/net/s2io.c	2006-04-13 09:04:10.000000000 -0700
+++ bug_fixes2/drivers/net/s2io.c	2006-04-20 03:27:03.000000000 -0700
@@ -77,7 +77,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.11.2"
+#define DRV_VERSION "2.0.14.2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -1036,11 +1036,6 @@ static int init_nic(struct s2io_nic *nic
 		}
 	}
 
-	/* Enable Tx FIFO partition 0. */
-	val64 = readq(&bar0->tx_fifo_partition_0);
-	val64 |= BIT(0);	/* To enable the FIFO partition. */
-	writeq(val64, &bar0->tx_fifo_partition_0);
-
 	/*
 	 * Disable 4 PCCs for Xena1, 2 and 3 as per H/W bug
 	 * SXE-008 TRANSMIT DMA ARBITRATION ISSUE.
@@ -1219,6 +1214,11 @@ static int init_nic(struct s2io_nic *nic
 		break;
 	}
 
+	/* Enable Tx FIFO partition 0. */
+	val64 = readq(&bar0->tx_fifo_partition_0);
+	val64 |= (TX_FIFO_PARTITION_EN);
+	writeq(val64, &bar0->tx_fifo_partition_0);
+
 	/* Filling the Rx round robin registers as per the
 	 * number of Rings and steering based on QoS.
          */
@@ -2188,7 +2188,7 @@ static void stop_nic(struct s2io_nic *ni
 {
 	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
-	u16 interruptible, i;
+	u16 interruptible;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -2201,12 +2201,10 @@ static void stop_nic(struct s2io_nic *ni
 	interruptible |= TX_MAC_INTR | RX_MAC_INTR;
 	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);
 
-	/*  Disable PRCs */
-	for (i = 0; i < config->rx_ring_num; i++) {
-		val64 = readq(&bar0->prc_ctrl_n[i]);
-		val64 &= ~((u64) PRC_CTRL_RC_ENABLED);
-		writeq(val64, &bar0->prc_ctrl_n[i]);
-	}
+	/* Clearing Adapter_En bit of ADAPTER_CONTROL Register */
+	val64 = readq(&bar0->adapter_control);
+	val64 &= ~(ADAPTER_CNTL_EN);
+	writeq(val64, &bar0->adapter_control);
 }
 
 static int fill_rxd_3buf(nic_t *nic, RxD_t *rxdp, struct sk_buff *skb)
@@ -2285,7 +2283,7 @@ static int fill_rx_buffers(struct s2io_n
 	alloc_cnt = mac_control->rings[ring_no].pkt_cnt -
 	    atomic_read(&nic->rx_bufs_left[ring_no]);
 
-        block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
+	block_no1 = mac_control->rings[ring_no].rx_curr_get_info.block_index;
 	off1 = mac_control->rings[ring_no].rx_curr_get_info.offset;
 	while (alloc_tab < alloc_cnt) {
 		block_no = mac_control->rings[ring_no].rx_curr_put_info.
@@ -4232,7 +4230,7 @@ static irqreturn_t s2io_isr(int irq, voi
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int i;
-	u64 reason = 0, val64;
+	u64 reason = 0, val64, org_mask;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -4257,6 +4255,10 @@ static irqreturn_t s2io_isr(int irq, voi
 	}
 
 	val64 = 0xFFFFFFFFFFFFFFFFULL;
+	/* Store current mask before masking all interrupts */
+	org_mask = readq(&bar0->general_int_mask);
+	writeq(val64, &bar0->general_int_mask);
+
 #ifdef CONFIG_S2IO_NAPI
 	if (reason & GEN_INTR_RXTRAFFIC) {
 		if (netif_rx_schedule_prep(dev)) {
@@ -4312,6 +4314,7 @@ static irqreturn_t s2io_isr(int irq, voi
 					DBG_PRINT(ERR_DBG, " in ISR!!\n");
 					clear_bit(0, (&sp->tasklet_status));
 					atomic_dec(&sp->isr_cnt);
+					writeq(org_mask, &bar0->general_int_mask);
 					return IRQ_HANDLED;
 				}
 				clear_bit(0, (&sp->tasklet_status));
@@ -4327,7 +4330,7 @@ static irqreturn_t s2io_isr(int irq, voi
 		}
 	}
 #endif
-
+	writeq(org_mask, &bar0->general_int_mask);
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
@@ -6011,6 +6014,165 @@ static void s2io_set_link(unsigned long 
 	clear_bit(0, &(nic->link_state));
 }
 
+static int set_rxd_buffer_pointer(nic_t *sp, RxD_t *rxdp, buffAdd_t *ba,
+			   struct sk_buff **skb, u64 *temp0, u64 *temp1,
+			   u64 *temp2, int size)
+{
+	struct net_device *dev = sp->dev;
+	struct sk_buff *frag_list;
+
+	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
+		/* allocate skb */
+		if (*skb) {
+			DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
+			/*
+			 * As Rx frame are not going to be processed,
+			 * using same mapped address for the Rxd
+			 * buffer pointer
+			 */
+			((RxD1_t*)rxdp)->Buffer0_ptr = *temp0;
+		} else {
+			*skb = dev_alloc_skb(size);
+			if (!(*skb)) {
+				DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
+				return -ENOMEM ;
+			}
+			/* storing the mapped addr in a temp variable
+			 * such it will be used for next rxd whose
+			 * Host Control is NULL
+			 */
+			((RxD1_t*)rxdp)->Buffer0_ptr = *temp0 =
+				pci_map_single( sp->pdev, (*skb)->data,
+					size - NET_IP_ALIGN,
+					PCI_DMA_FROMDEVICE);
+			rxdp->Host_Control = (unsigned long) (*skb);
+		}
+	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
+		/* Two buffer Mode */
+		if (*skb) {
+			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2;
+			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0;
+			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1;
+		} else {
+			*skb = dev_alloc_skb(size);
+			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
+				pci_map_single(sp->pdev, (*skb)->data,
+					       dev->mtu + 4,
+					       PCI_DMA_FROMDEVICE);
+			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0 =
+				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
+						PCI_DMA_FROMDEVICE);
+			rxdp->Host_Control = (unsigned long) (*skb);
+
+			/* Buffer-1 will be dummy buffer not used */
+			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1 =
+				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
+					       PCI_DMA_FROMDEVICE);
+		}
+	} else if ((rxdp->Host_Control == 0)) {
+		/* Three buffer mode */
+		if (*skb) {
+			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0;
+			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1;
+			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2;
+		} else {
+			*skb = dev_alloc_skb(size);
+
+			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0 =
+				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
+					       PCI_DMA_FROMDEVICE);
+			/* Buffer-1 receives L3/L4 headers */
+			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1 =
+				pci_map_single( sp->pdev, (*skb)->data,
+						l3l4hdr_size + 4,
+						PCI_DMA_FROMDEVICE);
+			/*
+			 * skb_shinfo(skb)->frag_list will have L4
+			 * data payload
+			 */
+			skb_shinfo(*skb)->frag_list = dev_alloc_skb(dev->mtu +
+								   ALIGN_SIZE);
+			if (skb_shinfo(*skb)->frag_list == NULL) {
+				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
+					  failed\n ", dev->name);
+				return -ENOMEM ;
+			}
+			frag_list = skb_shinfo(*skb)->frag_list;
+			frag_list->next = NULL;
+			/*
+			 * Buffer-2 receives L4 data payload
+			 */
+			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
+				pci_map_single( sp->pdev, frag_list->data,
+						dev->mtu, PCI_DMA_FROMDEVICE);
+		}
+	}
+	return 0;
+}
+static void set_rxd_buffer_size(nic_t *sp, RxD_t *rxdp, int size)
+{
+	struct net_device *dev = sp->dev;
+	if (sp->rxd_mode == RXD_MODE_1) {
+		rxdp->Control_2 = SET_BUFFER0_SIZE_1( size - NET_IP_ALIGN);
+	} else if (sp->rxd_mode == RXD_MODE_3B) {
+		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
+		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
+		rxdp->Control_2 |= SET_BUFFER2_SIZE_3( dev->mtu + 4);
+	} else {
+		rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
+		rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
+		rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
+	}
+}
+
+static  int rxd_owner_bit_reset(nic_t *sp)
+{
+	int i, j, k, blk_cnt = 0, size;
+	mac_info_t * mac_control = &sp->mac_control;
+	struct config_param *config = &sp->config;
+	struct net_device *dev = sp->dev;
+	RxD_t *rxdp = NULL;
+	struct sk_buff *skb = NULL;
+	buffAdd_t *ba = NULL;
+	u64 temp0_64 = 0, temp1_64 = 0, temp2_64 = 0;
+
+	/* Calculate the size based on ring mode */
+	size = dev->mtu + HEADER_ETHERNET_II_802_3_SIZE +
+		HEADER_802_2_SIZE + HEADER_SNAP_SIZE;
+	if (sp->rxd_mode == RXD_MODE_1)
+		size += NET_IP_ALIGN;
+	else if (sp->rxd_mode == RXD_MODE_3B)
+		size = dev->mtu + ALIGN_SIZE + BUF0_LEN + 4;
+	else
+		size = l3l4hdr_size + ALIGN_SIZE + BUF0_LEN + 4;
+
+	for (i = 0; i < config->rx_ring_num; i++) {
+		blk_cnt = config->rx_cfg[i].num_rxd /
+			(rxd_count[sp->rxd_mode] +1);
+
+		for (j = 0; j < blk_cnt; j++) {
+			for (k = 0; k < rxd_count[sp->rxd_mode]; k++) {
+				rxdp = mac_control->rings[i].
+					rx_blocks[j].rxds[k].virt_addr;
+				if(sp->rxd_mode >= RXD_MODE_3A)
+					ba = &mac_control->rings[i].ba[j][k];
+				set_rxd_buffer_pointer(sp, rxdp, ba,
+						       &skb,(u64 *)&temp0_64,
+						       (u64 *)&temp1_64,
+						       (u64 *)&temp2_64, size);
+
+				set_rxd_buffer_size(sp, rxdp, size);
+				wmb();
+				/* flip the Ownership bit to Hardware */
+				rxdp->Control_1 |= RXD_OWN_XENA;
+			}
+		}
+	}
+	return 0;
+
+}
+
 static void s2io_card_down(nic_t * sp, int flag)
 {
 	int cnt = 0;
@@ -6064,6 +6226,15 @@ static void s2io_card_down(nic_t * sp, i
 
 	/* Check if the device is Quiescent and then Reset the NIC */
 	do {
+		/* As per the HW requirement we need to replenish the
+		 * receive buffer to avoid the ring bump. Since there is
+		 * no intention of processing the Rx frame at this pointwe are
+		 * just settting the ownership bit of rxd in Each Rx
+		 * ring to HW and set the appropriate buffer size
+		 * based on the ring mode
+		 */
+		rxd_owner_bit_reset(sp);
+
 		val64 = readq(&bar0->adapter_status);
 		if (verify_xena_quiescence(sp, val64, sp->device_enabled_once)) {
 			break;

