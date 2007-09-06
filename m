From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 5/5]S2io: code Optimization of isr function
Date: Thu, 6 Sep 2007 06:53:20 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709060651180.19944-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:36892 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbXIFKxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 06:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Code Optimization of s2io_isr function.
- Isr check using per device napi variable instead of driver global.
- Reduced from 3 to 1 if condition before check for processing packet receive
  packets.
- Implemented Jeff's comment to use synchronize_irq. Removed the isr_cnt
  variable as it became redundant.
- One time de assert the interrupts by writing all F's to the general_int_mask
  register instead of de asserting by clearing the source of interrupts with
  multiple writes which causes loss of interrupts (race conditions). It is
  entirely possible that before the driver has a chance to mask the asserted
  alarm bit, another alarm/traffic interrupt bit gets asserted as well. In
  this case Herc will keep the INTA line asserted and the bridge will not
  send a new Assert_INTA message upstream.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.2-4/drivers/net/s2io.c 2.0.26.2-5/drivers/net/s2io.c
--- 2.0.26.2-4/drivers/net/s2io.c	2007-09-05 09:24:07.000000000 -0700
+++ 2.0.26.2-5/drivers/net/s2io.c	2007-09-05 10:14:38.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.1"
+#define DRV_VERSION "2.0.26.2"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -2714,12 +2714,8 @@ static int s2io_poll(struct net_device *
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int i;
 
-	atomic_inc(&nic->isr_cnt);
-
-	if (!is_s2io_card_up(nic)) {
-		atomic_dec(&nic->isr_cnt);
+	if (!is_s2io_card_up(nic)) 
 		return 0;
-	}
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2757,7 +2753,6 @@ static int s2io_poll(struct net_device *
 	/* Re enable the Rx interrupts. */
 	writeq(0x0, &bar0->rx_traffic_mask);
 	readl(&bar0->rx_traffic_mask);
-	atomic_dec(&nic->isr_cnt);
 	return 0;
 
 no_rx:
@@ -2771,7 +2766,6 @@ no_rx:
 			break;
 		}
 	}
-	atomic_dec(&nic->isr_cnt);
 	return 1;
 }
 
@@ -2799,7 +2793,6 @@ static void s2io_netpoll(struct net_devi
 
 	disable_irq(dev->irq);
 
-	atomic_inc(&nic->isr_cnt);
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
@@ -2824,7 +2817,6 @@ static void s2io_netpoll(struct net_devi
 			break;
 		}
 	}
-	atomic_dec(&nic->isr_cnt);
 	enable_irq(dev->irq);
 	return;
 }
@@ -4191,17 +4183,12 @@ static irqreturn_t s2io_msix_ring_handle
 	struct ring_info *ring = (struct ring_info *)dev_id;
 	struct s2io_nic *sp = ring->nic;
 
-	atomic_inc(&sp->isr_cnt);
-
-	if (!is_s2io_card_up(sp)) {
-		atomic_dec(&sp->isr_cnt);
+	if (!is_s2io_card_up(sp)) 
 		return IRQ_HANDLED;
-	}
 
 	rx_intr_handler(ring);
 	s2io_chk_rx_buffers(sp, ring->ring_no);
 
-	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
 
@@ -4210,15 +4197,10 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct fifo_info *fifo = (struct fifo_info *)dev_id;
 	struct s2io_nic *sp = fifo->nic;
 
-	atomic_inc(&sp->isr_cnt);
-
-	if (!is_s2io_card_up(sp)) {
-		atomic_dec(&sp->isr_cnt);
+	if (!is_s2io_card_up(sp)) 
 		return IRQ_HANDLED;
-	}
 
 	tx_intr_handler(fifo);
-	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
 static void s2io_txpic_intr_handle(struct s2io_nic *sp)
@@ -4594,12 +4576,8 @@ static irqreturn_t s2io_isr(int irq, voi
 	if (pci_channel_offline(sp->pdev))
 		return IRQ_NONE;
 
-	atomic_inc(&sp->isr_cnt);
-
-	if (!is_s2io_card_up(sp)) {
-		atomic_dec(&sp->isr_cnt);
+	if (!is_s2io_card_up(sp)) 
 		return IRQ_NONE;
-	}
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -4610,73 +4588,74 @@ static irqreturn_t s2io_isr(int irq, voi
 	 * 1. Rx of packet.
 	 * 2. Tx complete.
 	 * 3. Link down.
-	 * 4. Error in any functional blocks of the NIC.
 	 */
 	reason = readq(&bar0->general_int_status);
 
-	if (!reason) {
-		/* The interrupt was not raised by us. */
-		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
-	}
-	else if (unlikely(reason == S2IO_MINUS_ONE) ) {
-		/* Disable device and get out */
-		atomic_dec(&sp->isr_cnt);
-		return IRQ_NONE;
+	if (unlikely(reason == S2IO_MINUS_ONE) ) {
+		/* Nothing much can be done. Get out */
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
+		return IRQ_HANDLED;
 
-	writeq(0, &bar0->general_int_mask);
-	readl(&bar0->general_int_status);
+	}
+	else if (!reason) {
+		/* The interrupt was not raised by us */
+		return IRQ_NONE;
+	}
 
-	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
 
@@ -6798,7 +6777,6 @@ static int s2io_add_isr(struct s2io_nic 
 }
 static void s2io_rem_isr(struct s2io_nic * sp)
 {
-	int cnt = 0;
 	struct net_device *dev = sp->dev;
 	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
 
@@ -6811,6 +6789,7 @@ static void s2io_rem_isr(struct s2io_nic
 			int vector = sp->entries[i].vector;
 			void *arg = sp->s2io_entries[i].arg;
 
+			synchronize_irq(vector);
 			free_irq(vector, arg);
 		}
 
@@ -6829,16 +6808,9 @@ static void s2io_rem_isr(struct s2io_nic
 
 		pci_disable_msix(sp->pdev);
 	} else {
+		synchronize_irq(sp->pdev->irq);
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
@@ -7368,19 +7340,12 @@ static int s2io_verify_parm(struct pci_d
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
@@ -7538,6 +7503,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
+	config->napi = napi;
+
 	/* Tx side parameters. */
 	config->tx_fifo_num = tx_fifo_num;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
@@ -7585,9 +7552,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	for (i = 0; i < config->rx_ring_num; i++)
 		atomic_set(&sp->rx_bufs_left[i], 0);
 
-	/* Initialize the number of ISRs currently running */
-	atomic_set(&sp->isr_cnt, 0);
-
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
diff -Nurp 2.0.26.2-4/drivers/net/s2io.h 2.0.26.2-5/drivers/net/s2io.h
--- 2.0.26.2-4/drivers/net/s2io.h	2007-09-05 09:24:10.000000000 -0700
+++ 2.0.26.2-5/drivers/net/s2io.h	2007-09-05 09:31:30.000000000 -0700
@@ -910,7 +910,6 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 	volatile unsigned long state;
 	spinlock_t	rx_lock;
-	atomic_t	isr_cnt;
 	u64		general_int_mask;
 	u64 *ufo_in_band_v;
 #define VPD_STRING_LEN 80

