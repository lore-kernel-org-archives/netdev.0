From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2/3]S2io: Enable msi-x link interrupts.
Date: Wed, 9 Jul 2008 23:49:21 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10807092347550.5252-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37598 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbYGJEJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 00:09:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Enable msi-x link interrupts because the timer based scheduler was getting 
cancelled causing the link state to be lost with repetitive card up/downs 
when changing the mtu.
- Unmask mac_rmac_link interrupts only for Xframe I and prevent a spurious 
link interrupt in Xframe II.
- Stop the tx queue and indicate link down when card is down

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.25P1/drivers/net/s2io.c 2.0.26.25P2/drivers/net/s2io.c
--- 2.0.26.25P1/drivers/net/s2io.c	2008-06-30 13:41:25.000000000 -0700
+++ 2.0.26.25P2/drivers/net/s2io.c	2008-07-02 14:51:37.000000000 -0700
@@ -1909,8 +1909,6 @@ static int init_nic(struct s2io_nic *nic
 
 static int s2io_link_fault_indication(struct s2io_nic *nic)
 {
-	if (nic->config.intr_type != INTA)
-		return MAC_RMAC_ERR_TIMER;
 	if (nic->device_type == XFRAME_II_DEVICE)
 		return LINK_UP_DOWN_INTERRUPT;
 	else
@@ -1943,7 +1941,9 @@ static void en_dis_err_alarms(struct s2i
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 gen_int_mask = 0;
+	u64 interruptible;
 
+	writeq(DISABLE_ALL_INTRS, &bar0->general_int_mask);
 	if (mask & TX_DMA_INTR) {
 
 		gen_int_mask |= TXDMA_INT_M;
@@ -2033,10 +2033,12 @@ static void en_dis_err_alarms(struct s2i
 		gen_int_mask |= RXMAC_INT_M;
 		do_s2io_write_bits(MAC_INT_STATUS_RMAC_INT, flag,
 				&bar0->mac_int_mask);
-		do_s2io_write_bits(RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
+		interruptible = RMAC_RX_BUFF_OVRN | RMAC_RX_SM_ERR |
 				RMAC_UNUSED_INT | RMAC_SINGLE_ECC_ERR |
-				RMAC_DOUBLE_ECC_ERR |
-				RMAC_LINK_STATE_CHANGE_INT,
+				RMAC_DOUBLE_ECC_ERR;
+		if (s2io_link_fault_indication(nic) == MAC_RMAC_ERR_TIMER)
+			interruptible |= RMAC_LINK_STATE_CHANGE_INT;
+		do_s2io_write_bits(interruptible,
 				flag, &bar0->mac_rmac_err_mask);
 	}
 
@@ -4397,18 +4399,24 @@ static irqreturn_t s2io_msix_fifo_handle
 		/* Nothing much can be done. Get out */
 		return IRQ_HANDLED;
 
-	writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+	if (reason & (GEN_INTR_TXPIC | GEN_INTR_TXTRAFFIC)) {
+		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
 
-	if (reason & GEN_INTR_TXTRAFFIC)
-		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+		if (reason & GEN_INTR_TXPIC)
+			s2io_txpic_intr_handle(sp);
 
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&fifos[i]);
+		if (reason & GEN_INTR_TXTRAFFIC)
+			writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
 
-	writeq(sp->general_int_mask, &bar0->general_int_mask);
-	readl(&bar0->general_int_status);
+		for (i = 0; i < config->tx_fifo_num; i++)
+			tx_intr_handler(&fifos[i]);
 
-	return IRQ_HANDLED;
+		writeq(sp->general_int_mask, &bar0->general_int_mask);
+		readl(&bar0->general_int_status);
+		return IRQ_HANDLED;
+	}
+	/* The interrupt was not raised by us */
+	return IRQ_NONE;
 }
 
 static void s2io_txpic_intr_handle(struct s2io_nic *sp)
@@ -7135,6 +7143,9 @@ static void do_s2io_card_down(struct s2i
 		stop_nic(sp);
 
 	s2io_rem_isr(sp);
+
+	/* stop the tx queue, indicate link down */
+	s2io_link(sp, LINK_DOWN);
 
 	/* Check if the device is Quiescent and then Reset the NIC */
 	while(do_io) {
@@ -7268,17 +7279,19 @@ static int s2io_card_up(struct s2io_nic 
 
 	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
 
+	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
+
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
-	if (sp->config.intr_type != INTA)
-		en_dis_able_nic_intrs(sp, TX_TRAFFIC_INTR, ENABLE_INTRS);
-	else {
+	if (sp->config.intr_type != INTA) {
+		interruptible = TX_TRAFFIC_INTR | TX_PIC_INTR;
+		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
+	} else {
 		interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 		interruptible |= TX_PIC_INTR;
 		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
 	}
 
-	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
 	return 0;
 }
 
diff -Nurp 2.0.26.25P1/drivers/net/s2io.h 2.0.26.25P2/drivers/net/s2io.h
--- 2.0.26.25P1/drivers/net/s2io.h	2008-06-30 13:41:25.000000000 -0700
+++ 2.0.26.25P2/drivers/net/s2io.h	2008-06-30 13:41:50.000000000 -0700
@@ -1107,6 +1107,7 @@ static int init_shared_mem(struct s2io_n
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
 static int rx_intr_handler(struct ring_info *ring_data, int budget);
+static void s2io_txpic_intr_handle(struct s2io_nic *sp);
 static void tx_intr_handler(struct fifo_info *fifo_data);
 static void s2io_handle_errors(void * dev_id);
 

