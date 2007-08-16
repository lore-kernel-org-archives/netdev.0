From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 5/5]S2io: Optimize isr fast path
Date: 15 Aug 2007 17:12:38 -0700
Message-ID: <1187223158.23940.339.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49020 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760923AbXHOWVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:21:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Optimized interrupt routine fast path.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch4/drivers/net/s2io.c patch5/drivers/net/s2io.c
--- patch4/drivers/net/s2io.c	2007-08-15 08:42:14.000000000 -0700
+++ patch5/drivers/net/s2io.c	2007-08-15 08:42:51.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.1"
+#define DRV_VERSION "2.0.26.2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -4917,71 +4917,76 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * 1. Rx of packet.
 	 * 2. Tx complete.
 	 * 3. Link down.
-	 * 4. Error in any functional blocks of the NIC.
 	 */
 	reason = readq(&bar0->general_int_status);
 
-	if (!reason) {
-		/* The interrupt was not raised by us. */
+	if (unlikely(reason == S2IO_MINUS_ONE) ) {
+		/* Nothing much can be done. Get out */
 		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
-	}
-	else if (unlikely(reason == S2IO_MINUS_ONE) ) {
-		/* Disable device and get out */
-		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 	}
 
-	if (napi) {
-		if (reason & GEN_INTR_RXTRAFFIC) {
-			if ( likely ( netif_rx_schedule_prep(dev)) ) {
-				__netif_rx_schedule(dev);
-				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
+	if (reason & (GEN_INTR_RXTRAFFIC |
+		GEN_INTR_TXTRAFFIC | GEN_INTR_TXPIC))
+	{
+		writeq(S2IO_MINUS_ONE, &bar0->general_int_mask);
+
+		if (config->napi) {
+			if (reason & GEN_INTR_RXTRAFFIC) {
+				if ( likely (netif_rx_schedule_prep(dev)) ) {
+					__netif_rx_schedule(dev);
+					writeq(S2IO_MINUS_ONE,
+						&bar0->rx_traffic_mask);
+				} else
+					writeq(S2IO_MINUS_ONE,
+						&bar0->rx_traffic_int);
 			}
-			else
+		} else {
+			/*
+			 * rx_traffic_int reg is an R1 register, writing all 1's
+			 * will ensure that the actual interrupt causing bit
+			 * get's cleared and hence a read can be avoided.
+			 */
+			if (reason & GEN_INTR_RXTRAFFIC)
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+
+			for (i = 0; i < config->rx_ring_num; i++)
+				rx_intr_handler(&mac_control->rings[i]);
 		}
-	} else {
+
 		/*
-		 * Rx handler is called by default, without checking for the
-		 * cause of interrupt.
-		 * rx_traffic_int reg is an R1 register, writing all 1's
+		 * tx_traffic_int reg is an R1 register, writing all 1's
 		 * will ensure that the actual interrupt causing bit get's
 		 * cleared and hence a read can be avoided.
 		 */
-		if (reason & GEN_INTR_RXTRAFFIC)
-			writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+		if (reason & GEN_INTR_TXTRAFFIC)
+			writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
 
-		for (i = 0; i < config->rx_ring_num; i++) {
-			rx_intr_handler(&mac_control->rings[i]);
-		}
-	}
+		for (i = 0; i < config->tx_fifo_num; i++)
+			tx_intr_handler(&mac_control->fifos[i]);
 
-	/*
-	 * tx_traffic_int reg is an R1 register, writing all 1's
-	 * will ensure that the actual interrupt causing bit get's
-	 * cleared and hence a read can be avoided.
-	 */
-	if (reason & GEN_INTR_TXTRAFFIC)
-		writeq(S2IO_MINUS_ONE, &bar0->tx_traffic_int);
+		if (reason & GEN_INTR_TXPIC)
+			s2io_txpic_intr_handle(sp);
 
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&mac_control->fifos[i]);
+		/*
+		 * Reallocate the buffers from the interrupt handler itself.
+		 */
+		if (!config->napi) {
+			for (i = 0; i < config->rx_ring_num; i++)
+				s2io_chk_rx_buffers(sp, i);
+		}
+		writeq(sp->general_int_mask, &bar0->general_int_mask);
+		readl(&bar0->general_int_status);
 
-	if (reason & GEN_INTR_TXPIC)
-		s2io_txpic_intr_handle(sp);
-	/*
-	 * If the Rx buffer count is below the panic threshold then
-	 * reallocate the buffers from the interrupt handler itself,
-	 * else schedule a tasklet to reallocate the buffers.
-	 */
-	if (!napi) {
-		for (i = 0; i < config->rx_ring_num; i++)
-			s2io_chk_rx_buffers(sp, i);
-	}
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
 
-	writeq(0, &bar0->general_int_mask);
-	readl(&bar0->general_int_status);
+	}
+	else if (!reason) {
+		/* The interrupt was not raised by us */
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
 
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -7109,6 +7114,14 @@ static void s2io_rem_isr(struct s2io_nic
 	struct net_device *dev = sp->dev;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
+	/* Waiting till all Interrupt handlers are complete */
+	do {
+		if (!atomic_read(&sp->isr_cnt))
+			break;
+		msleep(10);
+		cnt++;
+	} while(cnt < 5);
+
 	if (sp->config.intr_type == MSI_X) {
 		int i;
 		u16 msi_control;
@@ -7138,14 +7151,6 @@ static void s2io_rem_isr(struct s2io_nic
 	} else {
 		free_irq(sp->pdev->irq, dev);
 	}
-	/* Waiting till all Interrupt handlers are complete */
-	cnt = 0;
-	do {
-		msleep(10);
-		if (!atomic_read(&sp->isr_cnt))
-			break;
-		cnt++;
-	} while(cnt < 5);
 }
 
 static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
@@ -7676,19 +7681,12 @@ static int s2io_verify_parm(struct pci_d
 	if (*dev_intr_type != INTA)
 		napi = 0;
 
-#ifndef CONFIG_PCI_MSI
-	if (*dev_intr_type != INTA) {
-		DBG_PRINT(ERR_DBG, "s2io: This kernel does not support"
-			  "MSI/MSI-X. Defaulting to INTA\n");
-		*dev_intr_type = INTA;
-	}
-#else
 	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
-#endif
+
 	if ((*dev_intr_type == MSI_X) &&
 			((pdev->device != PCI_DEVICE_ID_HERC_WIN) &&
 			(pdev->device != PCI_DEVICE_ID_HERC_UNI))) {
@@ -7846,6 +7844,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
+	config->napi = napi;
+
 	/* Tx side parameters. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {



