From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable
 parameter.
Date: Wed, 31 Jan 2007 13:28:08 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10701311325570.23100-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, alicia.pena@neterion.com,
	ramkrishna.vepa@neterion.com, ananda.raju@neterion.com,
	sreenivasa.honnur@neterion.com, sriram.rapuru@neterion.com,
	sivakumar.subramani@neterion.com, santosh.rastapur@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47642 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030517AbXAaS2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 13:28:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds two load parameters napi and ufo. Previously NAPI was
compilation option with these changes wan enable disable NAPI using load
parameter. Also we are introducing ufo load parameter to enable/disable
ufo feature

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-01-31 23:29:43.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-01-31 21:02:31.000000000 +0530
@@ -401,9 +401,10 @@ S2IO_PARM_INT(lro, 0);
  * aggregation happens until we hit max IP pkt size(64K)
  */
 S2IO_PARM_INT(lro_max_pkts, 0xFFFF);
-#ifndef CONFIG_S2IO_NAPI
 S2IO_PARM_INT(indicate_max_pkts, 0);
-#endif
+
+S2IO_PARM_INT(napi, 1);
+S2IO_PARM_INT(ufo, 0);
 
 static unsigned int tx_fifo_len[MAX_TX_FIFOS] =
     {DEFAULT_FIFO_0_LEN, [1 ...(MAX_TX_FIFOS - 1)] = DEFAULT_FIFO_1_7_LEN};
@@ -2274,9 +2275,7 @@ static int fill_rx_buffers(struct s2io_n
 	struct config_param *config;
 	u64 tmp;
 	buffAdd_t *ba;
-#ifndef CONFIG_S2IO_NAPI
 	unsigned long flags;
-#endif
 	RxD_t *first_rxdp = NULL;
 
 	mac_control = &nic->mac_control;
@@ -2320,12 +2319,15 @@ static int fill_rx_buffers(struct s2io_n
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
 				  dev->name, rxdp);
 		}
-#ifndef CONFIG_S2IO_NAPI
-		spin_lock_irqsave(&nic->put_lock, flags);
-		mac_control->rings[ring_no].put_pos =
-		    (block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
-		spin_unlock_irqrestore(&nic->put_lock, flags);
-#endif
+		if(!napi) {
+			spin_lock_irqsave(&nic->put_lock, flags);
+			mac_control->rings[ring_no].put_pos =
+			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
+			spin_unlock_irqrestore(&nic->put_lock, flags);
+		} else {
+			mac_control->rings[ring_no].put_pos =
+			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
+		}
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
 			((nic->rxd_mode >= RXD_MODE_3A) &&
 				(rxdp->Control_2 & BIT(0)))) {
@@ -2568,7 +2570,6 @@ static void free_rx_buffers(struct s2io_
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-#if defined(CONFIG_S2IO_NAPI)
 static int s2io_poll(struct net_device *dev, int *budget)
 {
 	nic_t *nic = dev->priv;
@@ -2633,7 +2634,6 @@ no_rx:
 	atomic_dec(&nic->isr_cnt);
 	return 1;
 }
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /**
@@ -2707,9 +2707,7 @@ static void rx_intr_handler(ring_info_t 
 	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
 	struct sk_buff *skb;
-#ifndef CONFIG_S2IO_NAPI
 	int pkt_cnt = 0;
-#endif
 	int i;
 
 	spin_lock(&nic->rx_lock);
@@ -2725,16 +2723,18 @@ static void rx_intr_handler(ring_info_t 
 	put_info = ring_data->rx_curr_put_info;
 	put_block = put_info.block_index;
 	rxdp = ring_data->rx_blocks[get_block].rxds[get_info.offset].virt_addr;
-#ifndef CONFIG_S2IO_NAPI
-	spin_lock(&nic->put_lock);
-	put_offset = ring_data->put_pos;
-	spin_unlock(&nic->put_lock);
-#else
-	put_offset = (put_block * (rxd_count[nic->rxd_mode] + 1)) +
-		put_info.offset;
-#endif
+	if (!napi) {
+		spin_lock(&nic->put_lock);
+		put_offset = ring_data->put_pos;
+		spin_unlock(&nic->put_lock);
+	} else
+		put_offset = ring_data->put_pos;
+
 	while (RXD_IS_UP2DT(rxdp)) {
-		/* If your are next to put index then it's FIFO full condition */
+		/*
+		 * If your are next to put index then it's
+		 * FIFO full condition
+		 */
 		if ((get_block == put_block) &&
 		    (get_info.offset + 1) == put_info.offset) {
 			DBG_PRINT(INTR_DBG, "%s: Ring Full\n",dev->name);
@@ -2792,15 +2792,12 @@ static void rx_intr_handler(ring_info_t 
 			rxdp = ring_data->rx_blocks[get_block].block_virt_addr;
 		}
 
-#ifdef CONFIG_S2IO_NAPI
 		nic->pkts_to_process -= 1;
-		if (!nic->pkts_to_process)
+		if ((napi) && (!nic->pkts_to_process))
 			break;
-#else
 		pkt_cnt++;
 		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
 			break;
-#endif
 	}
 	if (nic->lro) {
 		/* Clear all LRO sessions before exiting */
@@ -4193,26 +4190,26 @@ static irqreturn_t s2io_isr(int irq, voi
 	org_mask = readq(&bar0->general_int_mask);
 	writeq(val64, &bar0->general_int_mask);
 
-#ifdef CONFIG_S2IO_NAPI
-	if (reason & GEN_INTR_RXTRAFFIC) {
-		if (netif_rx_schedule_prep(dev)) {
-			writeq(val64, &bar0->rx_traffic_mask);
-			__netif_rx_schedule(dev);
+	if (napi) {
+		if (reason & GEN_INTR_RXTRAFFIC) {
+			if (netif_rx_schedule_prep(dev)) {
+				writeq(val64, &bar0->rx_traffic_mask);
+				__netif_rx_schedule(dev);
+			}
+		}
+	} else {
+		/*
+		 * Rx handler is called by default, without checking for the
+		 * cause of interrupt.
+		 * rx_traffic_int reg is an R1 register, writing all 1's
+		 * will ensure that the actual interrupt causing bit get's
+		 * cleared and hence a read can be avoided.
+		 */
+		writeq(val64, &bar0->rx_traffic_int);
+		for (i = 0; i < config->rx_ring_num; i++) {
+			rx_intr_handler(&mac_control->rings[i]);
 		}
 	}
-#else
-	/*
-	 * Rx handler is called by default, without checking for the
-	 * cause of interrupt.
-	 * rx_traffic_int reg is an R1 register, writing all 1's
-	 * will ensure that the actual interrupt causing bit get's
-	 * cleared and hence a read can be avoided.
-	 */
-	writeq(val64, &bar0->rx_traffic_int);
-	for (i = 0; i < config->rx_ring_num; i++) {
-		rx_intr_handler(&mac_control->rings[i]);
-	}
-#endif
 
 	/*
 	 * tx_traffic_int reg is an R1 register, writing all 1's
@@ -4231,11 +4228,14 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * reallocate the buffers from the interrupt handler itself,
 	 * else schedule a tasklet to reallocate the buffers.
 	 */
-#ifndef CONFIG_S2IO_NAPI
-	for (i = 0; i < config->rx_ring_num; i++)
-		s2io_chk_rx_buffers(sp, i);
-#endif
-	writeq(org_mask, &bar0->general_int_mask);
+	if (!napi) {
+		for (i = 0; i < config->rx_ring_num; i++)
+			s2io_chk_rx_buffers(sp, i);
+	}
+
+	writeq(0, &bar0->general_int_mask);
+	readl(&bar0->general_int_status);
+
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
@@ -6578,23 +6578,20 @@ static int rx_osm_handler(ring_info_t *r
 
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_S2IO_NAPI
 		if (sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2)) {
 			/* Queueing the vlan frame to the upper layer */
-			vlan_hwaccel_receive_skb(skb, sp->vlgrp,
-				RXD_GET_VLAN_TAG(rxdp->Control_2));
-		} else {
-			netif_receive_skb(skb);
-		}
-#else
-		if (sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2)) {
-			/* Queueing the vlan frame to the upper layer */
-			vlan_hwaccel_rx(skb, sp->vlgrp,
-				RXD_GET_VLAN_TAG(rxdp->Control_2));
+			if (napi)
+				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
+					RXD_GET_VLAN_TAG(rxdp->Control_2));
+			else
+				vlan_hwaccel_rx(skb, sp->vlgrp,
+					RXD_GET_VLAN_TAG(rxdp->Control_2));
 		} else {
-			netif_rx(skb);
+			if (napi)
+				netif_receive_skb(skb);
+			else
+				netif_rx(skb);
 		}
-#endif
 	} else {
 send_up:
 		queue_rx_frame(skb);
@@ -6695,13 +6692,9 @@ static int s2io_verify_parm(struct pci_d
 		DBG_PRINT(ERR_DBG, "s2io: Default to 8 Rx rings\n");
 		rx_ring_num = 8;
 	}
-#ifdef CONFIG_S2IO_NAPI
-	if (*dev_intr_type != INTA) {
-		DBG_PRINT(ERR_DBG, "s2io: NAPI cannot be enabled when "
-			  "MSI/MSI-X is enabled. Defaulting to INTA\n");
-		*dev_intr_type = INTA;
-	}
-#endif
+	if (*dev_intr_type != INTA)
+		napi = 0;
+
 #ifndef CONFIG_PCI_MSI
 	if (*dev_intr_type != INTA) {
 		DBG_PRINT(ERR_DBG, "s2io: This kernel does not support"
@@ -6962,10 +6955,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-#if defined(CONFIG_S2IO_NAPI)
 	dev->poll = s2io_poll;
 	dev->weight = 32;
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = s2io_netpoll;
@@ -6976,7 +6967,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_TSO;
 	dev->features |= NETIF_F_TSO6;
-	if (sp->device_type & XFRAME_II_DEVICE) {
+	if ((sp->device_type & XFRAME_II_DEVICE) && (ufo))  {
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
 	}
@@ -7057,9 +7048,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
-#ifndef CONFIG_S2IO_NAPI
-	spin_lock_init(&sp->put_lock);
-#endif
+
+	if (!napi)
+		spin_lock_init(&sp->put_lock);
 	spin_lock_init(&sp->rx_lock);
 
 	/*
@@ -7120,9 +7111,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 						dev->name);
 		    break;
 	}
-#ifdef CONFIG_S2IO_NAPI
-	DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
-#endif
+
+	if (napi)
+		DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
 	switch(sp->intr_type) {
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
@@ -7137,7 +7128,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (sp->lro)
 		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
 			  dev->name);
-
+	if (ufo)
+		DBG_PRINT(ERR_DBG, "%s: UDP Fragmentation Offload(UFO)"
+					" enabled\n", dev->name);
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
@@ -7539,11 +7532,10 @@ static void queue_rx_frame(struct sk_buf
 	struct net_device *dev = skb->dev;
 
 	skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_S2IO_NAPI
-	netif_receive_skb(skb);
-#else
-	netif_rx(skb);
-#endif
+	if (napi)
+		netif_receive_skb(skb);
+	else
+		netif_rx(skb);
 }
 
 static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff *skb,
diff -urpN orig/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- orig/drivers/net/s2io.h	2006-12-18 11:34:02.000000000 +0530
+++ patch1/drivers/net/s2io.h	2007-01-23 14:50:48.000000000 +0530
@@ -616,10 +616,8 @@ typedef struct ring_info {
 	 */
 	rx_curr_get_info_t rx_curr_get_info;
 
-#ifndef CONFIG_S2IO_NAPI
 	/* Index to the absolute position of the put pointer of Rx ring */
 	int put_pos;
-#endif
 
 	/* Buffer Address store. */
 	buffAdd_t **ba;
@@ -738,13 +736,11 @@ typedef struct lro {
 /* Structure representing one instance of the NIC */
 struct s2io_nic {
 	int rxd_mode;
-#ifdef CONFIG_S2IO_NAPI
 	/*
 	 * Count of packets to be processed in a given iteration, it will be indicated
 	 * by the quota field of the device structure when NAPI is enabled.
 	 */
 	int pkts_to_process;
-#endif
 	struct net_device *dev;
 	mac_info_t mac_control;
 	struct config_param config;
@@ -775,9 +771,7 @@ struct s2io_nic {
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
 	spinlock_t tx_lock;
-#ifndef CONFIG_S2IO_NAPI
 	spinlock_t put_lock;
-#endif
 
 #define PROMISC     1
 #define ALL_MULTI   2
@@ -985,9 +979,7 @@ static void s2io_tasklet(unsigned long d
 static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp);
 static void s2io_link(nic_t * sp, int link);
-#if defined(CONFIG_S2IO_NAPI)
 static int s2io_poll(struct net_device *dev, int *budget);
-#endif
 static void s2io_init_pci(nic_t * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);

