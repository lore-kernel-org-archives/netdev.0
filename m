From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 1/3]S2io: Move all the transmit completions to a single
 msi-x (alarm) vector
Date: Mon, 12 May 2008 13:41:32 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10805121340300.18446-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:41273 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998AbYELRle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Move all the transmit completions to a single msi-x (alarm) vector.
- Enable the continuous timer interrupt for only one transmit fifo.

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.23/drivers/net/s2io.c 2.0.26.24P1/drivers/net/s2io.c
--- 2.0.26.23/drivers/net/s2io.c	2008-04-29 17:07:22.000000000 -0700
+++ 2.0.26.24P1/drivers/net/s2io.c	2008-04-30 09:57:47.000000000 -0700
@@ -1219,15 +1219,33 @@ static int init_tti(struct s2io_nic *nic
 				TTI_DATA1_MEM_TX_URNG_B(0x10) |
 				TTI_DATA1_MEM_TX_URNG_C(0x30) |
 				TTI_DATA1_MEM_TX_TIMER_AC_EN;
-
-		if (use_continuous_tx_intrs && (link == LINK_UP))
-			val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
+		if (i == 0)
+			if (use_continuous_tx_intrs && (link == LINK_UP))
+				val64 |= TTI_DATA1_MEM_TX_TIMER_CI_EN;
 		writeq(val64, &bar0->tti_data1_mem);
 
-		val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
-				TTI_DATA2_MEM_TX_UFC_B(0x20) |
-				TTI_DATA2_MEM_TX_UFC_C(0x40) |
-				TTI_DATA2_MEM_TX_UFC_D(0x80);
+		if (nic->config.intr_type == MSI_X) {
+			val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
+				TTI_DATA2_MEM_TX_UFC_B(0x100) |
+				TTI_DATA2_MEM_TX_UFC_C(0x200) |
+				TTI_DATA2_MEM_TX_UFC_D(0x300);
+		} else {
+			if ((nic->config.tx_steering_type ==
+				TX_DEFAULT_STEERING) &&
+				(config->tx_fifo_num > 1) &&
+				(i >= nic->udp_fifo_idx) &&
+				(i < (nic->udp_fifo_idx +
+				nic->total_udp_fifos)))
+				val64 = TTI_DATA2_MEM_TX_UFC_A(0x50) |
+					TTI_DATA2_MEM_TX_UFC_B(0x80) |
+					TTI_DATA2_MEM_TX_UFC_C(0x100) |
+					TTI_DATA2_MEM_TX_UFC_D(0x120);
+			else
+				val64 = TTI_DATA2_MEM_TX_UFC_A(0x10) |
+					TTI_DATA2_MEM_TX_UFC_B(0x20) |
+					TTI_DATA2_MEM_TX_UFC_C(0x40) |
+					TTI_DATA2_MEM_TX_UFC_D(0x80);
+		}
 
 		writeq(val64, &bar0->tti_data2_mem);
 
@@ -3770,7 +3788,7 @@ static void store_xmsi_data(struct s2io_
 static int s2io_enable_msi_x(struct s2io_nic *nic)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	u64 tx_mat, rx_mat;
+	u64 rx_mat;
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 
@@ -3800,22 +3818,19 @@ static int s2io_enable_msi_x(struct s2io
 	 nic->mac_control.stats_info->sw_stat.mem_allocated
 		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
-	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
+	nic->entries[0].entry = 0;
+	nic->s2io_entries[0].entry = 0;
+	nic->s2io_entries[0].in_use = MSIX_FLG;
+	nic->s2io_entries[0].type = MSIX_ALARM_TYPE;
+	nic->s2io_entries[0].arg = &nic->mac_control.fifos;
+
+	for (i = 1; i < MAX_REQUESTED_MSI_X; i++) {
 		nic->entries[i].entry = i;
 		nic->s2io_entries[i].entry = i;
 		nic->s2io_entries[i].arg = NULL;
 		nic->s2io_entries[i].in_use = 0;
 	}
 
-	tx_mat = readq(&bar0->tx_mat0_n[0]);
-	for (i=0; i<nic->config.tx_fifo_num; i++, msix_indx++) {
-		tx_mat |= TX_MAT_SET(i, msix_indx);
-		nic->s2io_entries[msix_indx].arg = &nic->mac_control.fifos[i];
-		nic->s2io_entries[msix_indx].type = MSIX_FIFO_TYPE;
-		nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
-	}
-	writeq(tx_mat, &bar0->tx_mat0_n[0]);
-
 	rx_mat = readq(&bar0->rx_mat);
 	for (j = 0; j < nic->config.rx_ring_num; j++, msix_indx++) {
 		rx_mat |= RX_MAT_SET(j, msix_indx);
@@ -4352,15 +4367,35 @@ static irqreturn_t s2io_msix_ring_handle
 
 static irqreturn_t s2io_msix_fifo_handle(int irq, void *dev_id)
 {
-	struct fifo_info *fifo = (struct fifo_info *)dev_id;
-	struct s2io_nic *sp = fifo->nic;
+	int i;
+	struct fifo_info *fifos = (struct fifo_info *)dev_id;
+	struct s2io_nic *sp = fifos->nic;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+	struct config_param *config  = &sp->config;
+	u64 reason;
 
-	if (!is_s2io_card_up(sp))
+	if (unlikely(!is_s2io_card_up(sp)))
+		return IRQ_NONE;
+
+	reason = readq(&bar0->general_int_status);
+	if (unlikely(reason == S2IO_MINUS_ONE))
+		/* Nothing much can be done. Get out */
 		return IRQ_HANDLED;
 
-	tx_intr_handler(fifo);
+	writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+
+	if (reason & GEN_INTR_TXTRAFFIC)
+		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+
+	for (i = 0; i < config->tx_fifo_num; i++)
+		tx_intr_handler(&fifos[i]);
+
+	writeq(sp->general_int_mask, &bar0->general_int_mask);
+	readl(&bar0->general_int_status);
+
 	return IRQ_HANDLED;
 }
+
 static void s2io_txpic_intr_handle(struct s2io_nic *sp)
 {
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
@@ -6984,62 +7019,61 @@ static int s2io_add_isr(struct s2io_nic 
 
 	/* After proper initialization of H/W, register ISR */
 	if (sp->config.intr_type == MSI_X) {
-		int i, msix_tx_cnt=0,msix_rx_cnt=0;
+		int i, msix_rx_cnt = 0;
 
-		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
-			if (sp->s2io_entries[i].type == MSIX_FIFO_TYPE) {
-				sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
+		for (i = 0; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
+			if (sp->s2io_entries[i].type ==
+					MSIX_RING_TYPE) {
+					sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
+						dev->name, i);
+					err = request_irq(sp->entries[i].vector,
+						s2io_msix_ring_handle, 0,
+						sp->desc[i],
+						sp->s2io_entries[i].arg);
+				} else if (sp->s2io_entries[i].type ==
+					MSIX_ALARM_TYPE) {
+					sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
 					dev->name, i);
-				err = request_irq(sp->entries[i].vector,
-					  s2io_msix_fifo_handle, 0, sp->desc[i],
-						  sp->s2io_entries[i].arg);
-				/* If either data or addr is zero print it */
-				if(!(sp->msix_info[i].addr &&
-					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%llx\n",sp->desc[i],
-						(unsigned long long)
-						sp->msix_info[i].addr,
-						(unsigned long long)
-						sp->msix_info[i].data);
-				} else {
-					msix_tx_cnt++;
+					err = request_irq(sp->entries[i].vector,
+						s2io_msix_fifo_handle, 0,
+						sp->desc[i],
+						sp->s2io_entries[i].arg);
+
 				}
-			} else {
-				sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
-					dev->name, i);
-				err = request_irq(sp->entries[i].vector,
-					  s2io_msix_ring_handle, 0, sp->desc[i],
-						  sp->s2io_entries[i].arg);
-				/* If either data or addr is zero print it */
-				if(!(sp->msix_info[i].addr &&
+				/* if either data or addr is zero print it. */
+				if (!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
-						"Data:0x%llx\n",sp->desc[i],
+					DBG_PRINT(ERR_DBG,
+						"%s @Addr:0x%llx Data:0x%llx\n",
+						sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
 						(unsigned long long)
-						sp->msix_info[i].data);
-				} else {
+						ntohl(sp->msix_info[i].data));
+				} else
 					msix_rx_cnt++;
+				if (err) {
+					remove_msix_isr(sp);
+
+					DBG_PRINT(ERR_DBG,
+						"%s:MSI-X-%d registration "
+						"failed\n", dev->name, i);
+
+					DBG_PRINT(ERR_DBG,
+						"%s: Defaulting to INTA\n",
+						dev->name);
+					sp->config.intr_type = INTA;
+					break;
 				}
-			}
-			if (err) {
-				remove_msix_isr(sp);
-				DBG_PRINT(ERR_DBG,"%s:MSI-X-%d registration "
-					  "failed\n", dev->name, i);
-				DBG_PRINT(ERR_DBG, "%s: defaulting to INTA\n",
-						 dev->name);
-				sp->config.intr_type = INTA;
-				break;
-			}
-			sp->s2io_entries[i].in_use = MSIX_REGISTERED_SUCCESS;
+				sp->s2io_entries[i].in_use =
+					MSIX_REGISTERED_SUCCESS;
+
 		}
 		if (!err) {
-			printk(KERN_INFO "MSI-X-TX %d entries enabled\n",
-				msix_tx_cnt);
 			printk(KERN_INFO "MSI-X-RX %d entries enabled\n",
-				msix_rx_cnt);
+				--msix_rx_cnt);
+			DBG_PRINT(INFO_DBG, "MSI-X-TX entries enabled"
+						" through alarm vector\n");
 		}
 	}
 	if (sp->config.intr_type == INTA) {
@@ -7217,7 +7251,7 @@ static int s2io_card_up(struct s2io_nic 
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
 	if (sp->config.intr_type != INTA)
-		en_dis_able_nic_intrs(sp, ENA_ALL_INTRS, DISABLE_INTRS);
+		en_dis_able_nic_intrs(sp, TX_TRAFFIC_INTR, ENABLE_INTRS);
 	else {
 		interruptible = TX_TRAFFIC_INTR | RX_TRAFFIC_INTR;
 		interruptible |= TX_PIC_INTR;
diff -Nurp 2.0.26.23/drivers/net/s2io.h 2.0.26.24P1/drivers/net/s2io.h
--- 2.0.26.23/drivers/net/s2io.h	2008-04-29 17:07:22.000000000 -0700
+++ 2.0.26.24P1/drivers/net/s2io.h	2008-04-30 09:57:47.000000000 -0700
@@ -849,8 +849,8 @@ struct s2io_msix_entry
 	void *arg;
 
 	u8 type;
-#define	MSIX_FIFO_TYPE	1
-#define	MSIX_RING_TYPE	2
+#define        MSIX_ALARM_TYPE         1
+#define        MSIX_RING_TYPE          2
 
 	u8 in_use;
 #define MSIX_REGISTERED_SUCCESS	0xAA
@@ -982,6 +982,7 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 	volatile unsigned long state;
 	u64		general_int_mask;
+
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
 	u8  serial_num[VPD_STRING_LEN];

