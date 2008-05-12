From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 2/3]S2io: Added napi support when MSIX is enabled.
Date: Mon, 12 May 2008 13:42:17 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10805121341350.18446-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:41288 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251AbYELRmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:42:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Added napi support when MSIX is enabled.
- Moved test_msi function from s2io_open to probe function.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.24-P1/drivers/net/s2io.c 2.0.26.24-P2/drivers/net/s2io.c
--- 2.0.26.24-P1/drivers/net/s2io.c	2008-05-08 10:38:04.000000000 -0700
+++ 2.0.26.24-P2/drivers/net/s2io.c	2008-05-08 15:37:57.000000000 -0700
@@ -2831,6 +2831,15 @@ static void free_rx_buffers(struct s2io_
 	}
 }
 
+static int s2io_chk_rx_buffers(struct ring_info *ring)
+{
+	if (fill_rx_buffers(ring) == -ENOMEM) {
+		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
+		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
+	}
+	return 0;
+}
+
 /**
  * s2io_poll - Rx interrupt handler for NAPI support
  * @napi : pointer to the napi structure.
@@ -2844,57 +2853,72 @@ static void free_rx_buffers(struct s2io_
  * 0 on success and 1 if there are No Rx packets to be processed.
  */
 
-static int s2io_poll(struct napi_struct *napi, int budget)
+static int s2io_poll_msix(struct napi_struct *napi, int budget)
 {
-	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
-	struct net_device *dev = nic->dev;
-	int pkt_cnt = 0, org_pkts_to_process;
-	struct mac_info *mac_control;
+	struct ring_info *ring = container_of(napi, struct ring_info, napi);
+	struct net_device *dev = ring->dev;
 	struct config_param *config;
+	struct mac_info *mac_control;
+	int pkts_processed = 0;
+	u8 *addr = NULL, val8 = 0;
+	struct s2io_nic *nic = dev->priv;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	int i;
+	int budget_org = budget;
 
-	mac_control = &nic->mac_control;
 	config = &nic->config;
+	mac_control = &nic->mac_control;
 
-	nic->pkts_to_process = budget;
-	org_pkts_to_process = nic->pkts_to_process;
+	if (unlikely(!is_s2io_card_up(nic)))
+		return 0;
 
-	writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
-	readl(&bar0->rx_traffic_int);
+	pkts_processed = rx_intr_handler(ring, budget);
+	s2io_chk_rx_buffers(ring);
 
-	for (i = 0; i < config->rx_ring_num; i++) {
-		rx_intr_handler(&mac_control->rings[i]);
-		pkt_cnt = org_pkts_to_process - nic->pkts_to_process;
-		if (!nic->pkts_to_process) {
-			/* Quota for the current iteration has been met */
-			goto no_rx;
-		}
+	if (pkts_processed < budget_org) {
+		netif_rx_complete(dev, napi);
+		/*Re Enable MSI-Rx Vector*/
+		addr = (u8 *)&bar0->xmsi_mask_reg;
+		addr += 7 - ring->ring_no;
+		val8 = (ring->ring_no == 0) ? 0x3f : 0xbf;
+		writeb(val8, addr);
+		val8 = readb(addr);
 	}
+	return pkts_processed;
+}
+static int s2io_poll_inta(struct napi_struct *napi, int budget)
+{
+	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
+	struct ring_info *ring;
+	struct net_device *dev = nic->dev;
+	struct config_param *config;
+	struct mac_info *mac_control;
+	int pkts_processed = 0;
+	int ring_pkts_processed, i;
+	struct XENA_dev_config __iomem *bar0 = nic->bar0;
+	int budget_org = budget;
 
-	netif_rx_complete(dev, napi);
+	config = &nic->config;
+	mac_control = &nic->mac_control;
 
-	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
-			break;
-		}
-	}
-	/* Re enable the Rx interrupts. */
-	writeq(0x0, &bar0->rx_traffic_mask);
-	readl(&bar0->rx_traffic_mask);
-	return pkt_cnt;
+	if (unlikely(!is_s2io_card_up(nic)))
+		return 0;
 
-no_rx:
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
+		ring = &mac_control->rings[i];
+		ring_pkts_processed = rx_intr_handler(ring, budget);
+		s2io_chk_rx_buffers(ring);
+		pkts_processed += ring_pkts_processed;
+		budget -= ring_pkts_processed;
+		if (budget <= 0)
 			break;
-		}
 	}
-	return pkt_cnt;
+	if (pkts_processed < budget_org) {
+		netif_rx_complete(dev, napi);
+		/* Re enable the Rx interrupts for the ring */
+		writeq(0, &bar0->rx_traffic_mask);
+		readl(&bar0->rx_traffic_mask);
+	}
+	return pkts_processed;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -2936,7 +2960,7 @@ static void s2io_netpoll(struct net_devi
 
 	/* check for received packet and indicate up to network */
 	for (i = 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i]);
+		rx_intr_handler(&mac_control->rings[i], 0);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
@@ -2952,7 +2976,8 @@ static void s2io_netpoll(struct net_devi
 
 /**
  *  rx_intr_handler - Rx interrupt handler
- *  @nic: device private variable.
+ *  @ring_info: per ring structure.
+ *  @budget: budget for napi processing.
  *  Description:
  *  If the interrupt is because of a received frame or if the
  *  receive ring contains fresh as yet un-processed frames,this function is
@@ -2960,15 +2985,15 @@ static void s2io_netpoll(struct net_devi
  *  stopped and sends the skb to the OSM's Rx handler and then increments
  *  the offset.
  *  Return Value:
- *  NONE.
+ *  No. of napi packets processed.
  */
-static void rx_intr_handler(struct ring_info *ring_data)
+static int rx_intr_handler(struct ring_info *ring_data, int budget)
 {
 	int get_block, put_block;
 	struct rx_curr_get_info get_info, put_info;
 	struct RxD_t *rxdp;
 	struct sk_buff *skb;
-	int pkt_cnt = 0;
+	int pkt_cnt = 0, napi_pkts = 0;
 	int i;
 	struct RxD1* rxdp1;
 	struct RxD3* rxdp3;
@@ -2995,7 +3020,7 @@ static void rx_intr_handler(struct ring_
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  ring_data->dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-			return;
+			return 0;
 		}
 		if (ring_data->rxd_mode == RXD_MODE_1) {
 			rxdp1 = (struct RxD1*)rxdp;
@@ -3032,9 +3057,10 @@ static void rx_intr_handler(struct ring_
 			rxdp = ring_data->rx_blocks[get_block].block_virt_addr;
 		}
 
-		if(ring_data->nic->config.napi){
-			ring_data->nic->pkts_to_process -= 1;
-			if (!ring_data->nic->pkts_to_process)
+		if (ring_data->nic->config.napi) {
+			budget--;
+			napi_pkts++;
+			if (!budget)
 				break;
 		}
 		pkt_cnt++;
@@ -3052,6 +3078,7 @@ static void rx_intr_handler(struct ring_
 			}
 		}
 	}
+	return(napi_pkts);
 }
 
 /**
@@ -3748,14 +3775,19 @@ static void restore_xmsi_data(struct s2i
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	u64 val64;
-	int i;
+	int i, msix_index;
+
+
+	if (nic->device_type == XFRAME_I_DEVICE)
+		return;
 
 	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
+		msix_index = (i) ? ((i-1) * 8 + 1): 0;
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
-		val64 = (s2BIT(7) | s2BIT(15) | vBIT(i, 26, 6));
+		val64 = (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
-		if (wait_for_msix_trans(nic, i)) {
+		if (wait_for_msix_trans(nic, msix_index)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
 			continue;
 		}
@@ -3766,13 +3798,17 @@ static void store_xmsi_data(struct s2io_
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	u64 val64, addr, data;
-	int i;
+	int i, msix_index;
+
+	if (nic->device_type == XFRAME_I_DEVICE)
+		return;
 
 	/* Store and display */
 	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
-		val64 = (s2BIT(15) | vBIT(i, 26, 6));
+		msix_index = (i) ? ((i-1) * 8 + 1): 0;
+		val64 = (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
-		if (wait_for_msix_trans(nic, i)) {
+		if (wait_for_msix_trans(nic, msix_index)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
 			continue;
 		}
@@ -3792,7 +3828,7 @@ static int s2io_enable_msi_x(struct s2io
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 
-	nic->entries = kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct msix_entry),
+	nic->entries = kmalloc(nic->num_entries * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
@@ -3801,10 +3837,12 @@ static int s2io_enable_msi_x(struct s2io
 		return -ENOMEM;
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated
-		+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+		+= (nic->num_entries * sizeof(struct msix_entry));
+
+	memset(nic->entries, 0, nic->num_entries * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
-		kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct s2io_msix_entry),
+		kmalloc(nic->num_entries * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
@@ -3812,11 +3850,13 @@ static int s2io_enable_msi_x(struct s2io
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+= (nic->num_entries * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
 	 nic->mac_control.stats_info->sw_stat.mem_allocated
-		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+		+= (nic->num_entries * sizeof(struct s2io_msix_entry));
+	memset(nic->s2io_entries, 0,
+		nic->num_entries * sizeof(struct s2io_msix_entry));
 
 	nic->entries[0].entry = 0;
 	nic->s2io_entries[0].entry = 0;
@@ -3824,45 +3864,38 @@ static int s2io_enable_msi_x(struct s2io
 	nic->s2io_entries[0].type = MSIX_ALARM_TYPE;
 	nic->s2io_entries[0].arg = &nic->mac_control.fifos;
 
-	for (i = 1; i < MAX_REQUESTED_MSI_X; i++) {
-		nic->entries[i].entry = i;
-		nic->s2io_entries[i].entry = i;
+	for (i = 1; i < nic->num_entries; i++) {
+		nic->entries[i].entry = ((i - 1) * 8) + 1;
+		nic->s2io_entries[i].entry = ((i - 1) * 8) + 1;
 		nic->s2io_entries[i].arg = NULL;
 		nic->s2io_entries[i].in_use = 0;
 	}
 
 	rx_mat = readq(&bar0->rx_mat);
-	for (j = 0; j < nic->config.rx_ring_num; j++, msix_indx++) {
+	for (j = 0; j < nic->config.rx_ring_num; j++) {
 		rx_mat |= RX_MAT_SET(j, msix_indx);
-		nic->s2io_entries[msix_indx].arg
-			= &nic->mac_control.rings[j];
-		nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
-		nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
+		nic->s2io_entries[j+1].arg = &nic->mac_control.rings[j];
+		nic->s2io_entries[j+1].type = MSIX_RING_TYPE;
+		nic->s2io_entries[j+1].in_use = MSIX_FLG;
+		msix_indx += 8;
 	}
 	writeq(rx_mat, &bar0->rx_mat);
+	readq(&bar0->rx_mat);
 
-	nic->avail_msix_vectors = 0;
-	ret = pci_enable_msix(nic->pdev, nic->entries, MAX_REQUESTED_MSI_X);
+	ret = pci_enable_msix(nic->pdev, nic->entries, nic->num_entries);
 	/* We fail init if error or we get less vectors than min required */
-	if (ret >= (nic->config.tx_fifo_num + nic->config.rx_ring_num + 1)) {
-		nic->avail_msix_vectors = ret;
-		ret = pci_enable_msix(nic->pdev, nic->entries, ret);
-	}
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+= (nic->num_entries * sizeof(struct msix_entry));
 		kfree(nic->s2io_entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
-		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+			+= (nic->num_entries * sizeof(struct s2io_msix_entry));
 		nic->entries = NULL;
 		nic->s2io_entries = NULL;
-		nic->avail_msix_vectors = 0;
 		return -ENOMEM;
 	}
-	if (!nic->avail_msix_vectors)
-		nic->avail_msix_vectors = MAX_REQUESTED_MSI_X;
 
 	/*
 	 * To enable MSI-X, MSI also needs to be enabled, due to a bug
@@ -3934,7 +3967,7 @@ static void remove_msix_isr(struct s2io_
 	int i;
 	u16 msi_control;
 
-	for (i = 0; i < MAX_REQUESTED_MSI_X; i++) {
+	for (i = 0; i < sp->num_entries; i++) {
 		if (sp->s2io_entries[i].in_use ==
 			MSIX_REGISTERED_SUCCESS) {
 			int vector = sp->entries[i].vector;
@@ -3990,29 +4023,6 @@ static int s2io_open(struct net_device *
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
-	if (sp->config.intr_type == MSI_X) {
-		int ret = s2io_enable_msi_x(sp);
-
-		if (!ret) {
-			ret = s2io_test_msi(sp);
-			/* rollback MSI-X, will re-enable during add_isr() */
-			remove_msix_isr(sp);
-		}
-		if (ret) {
-
-			DBG_PRINT(ERR_DBG,
-			  "%s: MSI-X requested but failed to enable\n",
-			  dev->name);
-			sp->config.intr_type = INTA;
-		}
-	}
-
-	/* NAPI doesn't work well with MSI(X) */
-	 if (sp->config.intr_type != INTA) {
-		if(sp->config.napi)
-			sp->config.napi = 0;
-	}
-
 	/* Initialize H/W and enable interrupts */
 	err = s2io_card_up(sp);
 	if (err) {
@@ -4035,12 +4045,12 @@ hw_init_failed:
 		if (sp->entries) {
 			kfree(sp->entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+			+= (sp->num_entries * sizeof(struct msix_entry));
 		}
 		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
 			sp->mac_control.stats_info->sw_stat.mem_freed
-			+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+			+= (sp->num_entries * sizeof(struct s2io_msix_entry));
 		}
 	}
 	return err;
@@ -4342,25 +4352,29 @@ s2io_alarm_handle(unsigned long data)
 	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 }
 
-static int s2io_chk_rx_buffers(struct ring_info *ring)
-{
-	if (fill_rx_buffers(ring) == -ENOMEM) {
-		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
-		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
-	}
-	return 0;
-}
-
 static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 {
 	struct ring_info *ring = (struct ring_info *)dev_id;
 	struct s2io_nic *sp = ring->nic;
+	struct XENA_dev_config __iomem *bar0 = sp->bar0;
+	struct net_device *dev = sp->dev;
 
-	if (!is_s2io_card_up(sp))
+	if (unlikely(!is_s2io_card_up(sp)))
 		return IRQ_HANDLED;
 
-	rx_intr_handler(ring);
-	s2io_chk_rx_buffers(ring);
+	if (sp->config.napi) {
+		u8 *addr = NULL, val8 = 0;
+
+		addr = (u8 *)&bar0->xmsi_mask_reg;
+		addr += (7 - ring->ring_no);
+		val8 = (ring->ring_no == 0) ? 0x7f : 0xff;
+		writeb(val8, addr);
+		val8 = readb(addr);
+		netif_rx_schedule(dev, &ring->napi);
+	} else {
+		rx_intr_handler(ring, 0);
+		s2io_chk_rx_buffers(ring);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -4797,14 +4811,10 @@ static irqreturn_t s2io_isr(int irq, voi
 
 		if (config->napi) {
 			if (reason & GEN_INTR_RXTRAFFIC) {
-				if (likely(netif_rx_schedule_prep(dev,
-							&sp->napi))) {
-					__netif_rx_schedule(dev, &sp->napi);
-					writeq(S2IO_MINUS_ONE,
-					       &bar0->rx_traffic_mask);
-				} else
-					writeq(S2IO_MINUS_ONE,
-					       &bar0->rx_traffic_int);
+				netif_rx_schedule(dev, &sp->napi);
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
+				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
+				readl(&bar0->rx_traffic_int);
 			}
 		} else {
 			/*
@@ -4816,7 +4826,7 @@ static irqreturn_t s2io_isr(int irq, voi
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 
 			for (i = 0; i < config->rx_ring_num; i++)
-				rx_intr_handler(&mac_control->rings[i]);
+				rx_intr_handler(&mac_control->rings[i], 0);
 		}
 
 		/*
@@ -7021,8 +7031,9 @@ static int s2io_add_isr(struct s2io_nic 
 	if (sp->config.intr_type == MSI_X) {
 		int i, msix_rx_cnt = 0;
 
-		for (i = 0; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
-			if (sp->s2io_entries[i].type ==
+		for (i = 0; i < sp->num_entries; i++) {
+			if (sp->s2io_entries[i].in_use == MSIX_FLG) {
+				if (sp->s2io_entries[i].type ==
 					MSIX_RING_TYPE) {
 					sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
 						dev->name, i);
@@ -7067,7 +7078,7 @@ static int s2io_add_isr(struct s2io_nic 
 				}
 				sp->s2io_entries[i].in_use =
 					MSIX_REGISTERED_SUCCESS;
-
+			}
 		}
 		if (!err) {
 			printk(KERN_INFO "MSI-X-RX %d entries enabled\n",
@@ -7114,8 +7125,15 @@ static void do_s2io_card_down(struct s2i
 	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
 	/* Disable napi */
-	if (config->napi)
-		napi_disable(&sp->napi);
+	if (sp->config.napi) {
+		int off = 0;
+		if (config->intr_type ==  MSI_X) {
+			for (; off < sp->config.rx_ring_num; off++)
+				napi_disable(&sp->mac_control.rings[off].napi);
+			}
+		else
+			napi_disable(&sp->napi);
+	}
 
 	/* disable Tx and Rx traffic on the NIC */
 	if (do_io)
@@ -7207,8 +7225,15 @@ static int s2io_card_up(struct s2io_nic 
 	}
 
 	/* Initialise napi */
-	if (config->napi)
-		napi_enable(&sp->napi);
+	if (config->napi) {
+		int i;
+		if (config->intr_type ==  MSI_X) {
+			for (i = 0; i < sp->config.rx_ring_num; i++)
+				napi_enable(&sp->mac_control.rings[i].napi);
+		} else {
+			napi_enable(&sp->napi);
+		}
+	}
 
 	/* Maintain the state prior to the open */
 	if (sp->promisc_flg)
@@ -7649,9 +7674,6 @@ static int s2io_verify_parm(struct pci_d
 		rx_ring_num = MAX_RX_RINGS;
 	}
 
-	if (*dev_intr_type != INTA)
-		napi = 0;
-
 	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
@@ -7952,8 +7974,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
 	 */
-	netif_napi_add(dev, &sp->napi, s2io_poll, 32);
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = s2io_netpoll;
 #endif
@@ -7997,6 +8017,32 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		}
 	}
 
+	if (sp->config.intr_type == MSI_X) {
+		sp->num_entries = config->rx_ring_num + 1;
+		ret = s2io_enable_msi_x(sp);
+
+		if (!ret) {
+			ret = s2io_test_msi(sp);
+			/* rollback MSI-X, will re-enable during add_isr() */
+			remove_msix_isr(sp);
+		}
+		if (ret) {
+
+			DBG_PRINT(ERR_DBG,
+			  "%s: MSI-X requested but failed to enable\n",
+			  dev->name);
+			sp->config.intr_type = INTA;
+		}
+	}
+
+	if (config->intr_type ==  MSI_X) {
+		for (i = 0; i < config->rx_ring_num ; i++)
+			netif_napi_add(dev, &mac_control->rings[i].napi,
+				s2io_poll_msix, 64);
+	} else {
+		netif_napi_add(dev, &sp->napi, s2io_poll_inta, 64);
+	}
+
 	/* Not needed for Herc */
 	if (sp->device_type & XFRAME_I_DEVICE) {
 		/*
@@ -8047,6 +8093,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	/* store mac addresses from CAM to s2io_nic structure */
 	do_s2io_store_unicast_mc(sp);
 
+	/* Configure MSIX vector for number of rings configured plus one */
+	if ((sp->device_type == XFRAME_II_DEVICE) &&
+		(config->intr_type == MSI_X))
+		sp->num_entries = config->rx_ring_num + 1;
+
 	 /* Store the values of the MSIX table in the s2io_nic structure */
 	store_xmsi_data(sp);
 	/* reset Nic and bring it to known state */
@@ -8112,8 +8163,14 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		    break;
 	}
 
-	if (napi)
+	switch (sp->config.napi) {
+	case 0:
+		DBG_PRINT(ERR_DBG, "%s: NAPI disabled\n", dev->name);
+		break;
+	case 1:
 		DBG_PRINT(ERR_DBG, "%s: NAPI enabled\n", dev->name);
+		break;
+	}
 
 	DBG_PRINT(ERR_DBG, "%s: Using %d Tx fifo(s)\n", dev->name,
 		sp->config.tx_fifo_num);
diff -Nurp 2.0.26.24-P1/drivers/net/s2io.h 2.0.26.24-P2/drivers/net/s2io.h
--- 2.0.26.24-P1/drivers/net/s2io.h	2008-05-08 10:38:04.000000000 -0700
+++ 2.0.26.24-P2/drivers/net/s2io.h	2008-05-08 15:01:13.000000000 -0700
@@ -706,7 +706,7 @@ struct ring_info {
 	/* per-ring buffer counter */
 	u32 rx_bufs_left;
 
-	#define MAX_LRO_SESSIONS	32
+#define MAX_LRO_SESSIONS       32
 	struct lro lro0_n[MAX_LRO_SESSIONS];
 	u8		lro;
 
@@ -725,6 +725,11 @@ struct ring_info {
 	/* copy of sp->pdev pointer */
 	struct pci_dev *pdev;
 
+	/* Per ring napi struct */
+	struct napi_struct napi;
+
+	unsigned long interrupt_count;
+
 	/*
 	 *  Place holders for the virtual and physical addresses of
 	 *  all the Rx Blocks
@@ -841,7 +846,7 @@ struct usr_addr {
  * Structure to keep track of the MSI-X vectors and the corresponding
  * argument registered against each vector
  */
-#define MAX_REQUESTED_MSI_X	17
+#define MAX_REQUESTED_MSI_X	9
 struct s2io_msix_entry
 {
 	u16 vector;
@@ -877,7 +882,6 @@ struct s2io_nic {
 	 */
 	int pkts_to_process;
 	struct net_device *dev;
-	struct napi_struct napi;
 	struct mac_info mac_control;
 	struct config_param config;
 	struct pci_dev *pdev;
@@ -948,6 +952,7 @@ struct s2io_nic {
 	*/
 	u8 other_fifo_idx;
 
+	struct napi_struct napi;
 	/*  after blink, the adapter must be restored with original
 	 *  values.
 	 */
@@ -962,6 +967,7 @@ struct s2io_nic {
 	unsigned long long start_time;
 	struct vlan_group *vlgrp;
 #define MSIX_FLG                0xA5
+	int num_entries;
 	struct msix_entry *entries;
 	int msi_detected;
 	wait_queue_head_t msi_wait;
@@ -1104,7 +1110,7 @@ static void __devexit s2io_rem_nic(struc
 static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
-static void rx_intr_handler(struct ring_info *ring_data);
+static int rx_intr_handler(struct ring_info *ring_data, int budget);
 static void tx_intr_handler(struct fifo_info *fifo_data);
 static void s2io_handle_errors(void * dev_id);
 
@@ -1115,7 +1121,8 @@ static void s2io_set_multicast(struct ne
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
 static void s2io_reset(struct s2io_nic * sp);
-static int s2io_poll(struct napi_struct *napi, int budget);
+static int s2io_poll_msix(struct napi_struct *napi, int budget);
+static int s2io_poll_inta(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr);
 static void s2io_alarm_handle(unsigned long data);
diff -Nurp 2.0.26.24-P1/drivers/net/s2io-regs.h 2.0.26.24-P2/drivers/net/s2io-regs.h
--- 2.0.26.24-P1/drivers/net/s2io-regs.h	2008-05-08 10:37:46.000000000 -0700
+++ 2.0.26.24-P2/drivers/net/s2io-regs.h	2008-05-08 12:21:52.000000000 -0700
@@ -250,7 +250,7 @@ struct XENA_dev_config {
 	u64 tx_mat0_n[0x8];
 #define TX_MAT_SET(fifo, msi)			vBIT(msi, (8 * fifo), 8)
 
-	u8 unused_1[0x8];
+	u64 xmsi_mask_reg;
 	u64 stat_byte_cnt;
 #define STAT_BC(n)                              vBIT(n,4,12)
 

