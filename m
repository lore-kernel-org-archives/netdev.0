From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 2/6] e100: Render e100 NAPI state
 machine
Date: Thu, 28 Apr 2005 19:17:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281912350.29008-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Render e100 NAPI state machine to be similar to the non-NAPI one.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
+++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
@@ -269,6 +269,12 @@ enum scb_status {
 	rus_mask         = 0x3C,
 };
 
+enum ru_state  {
+	RU_SUSPENDED = 0,
+	RU_RUNNING	 = 1,
+	RU_UNINITIALIZED = -1,
+};
+
 enum scb_stat_ack {
 	stat_ack_not_ours    = 0x00,
 	stat_ack_sw_gen      = 0x04,
@@ -510,7 +515,7 @@ struct nic {
 	struct rx *rx_to_use;
 	struct rx *rx_to_clean;
 	struct rfd blank_rfd;
-	int ru_running;
+	enum ru_state ru_running;
 
 	spinlock_t cb_lock			____cacheline_aligned;
 	spinlock_t cmd_lock;
@@ -1204,7 +1210,9 @@ static void e100_update_stats(struct nic
 		}
 	}
 
-	e100_exec_cmd(nic, cuc_dump_reset, 0);
+	
+	if(e100_exec_cmd(nic, cuc_dump_reset, 0))
+		DPRINTK(TX_ERR, DEBUG, "exec cuc_dump_reset failed\n");
 }
 
 static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
@@ -1298,7 +1306,8 @@ static int e100_xmit_frame(struct sk_buf
 		/* SW workaround for ICH[x] 10Mbps/half duplex Tx hang.
 		   Issue a NOP command followed by a 1us delay before
 		   issuing the Tx command. */
-		e100_exec_cmd(nic, cuc_nop, 0);
+		if(e100_exec_cmd(nic, cuc_nop, 0))
+			DPRINTK(TX_ERR, DEBUG, "exec cuc_nop failed\n");
 		udelay(1);
 	}
 
@@ -1416,12 +1425,18 @@ static int e100_alloc_cbs(struct nic *ni
 	return 0;
 }
 
-static inline void e100_start_receiver(struct nic *nic)
+static inline void e100_start_receiver(struct nic *nic, struct rx *rx)
 {
+	if(!nic->rxs) return;
+	if(RU_SUSPENDED != nic->ru_running) return;
+
+	/* handle init time starts */
+	if(!rx) rx = nic->rxs;
+
 	/* (Re)start RU if suspended or idle and RFA is non-NULL */
-	if(!nic->ru_running && nic->rx_to_clean->skb) {
-		e100_exec_cmd(nic, ruc_start, nic->rx_to_clean->dma_addr);
-		nic->ru_running = 1;
+	if(rx->skb) {
+		e100_exec_cmd(nic, ruc_start, rx->dma_addr);
+		nic->ru_running = RU_RUNNING;
 	}
 }
 
@@ -1438,6 +1453,13 @@ static inline int e100_rx_alloc_skb(stru
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
+	if(pci_dma_mapping_error(rx->dma_addr)) {
+		dev_kfree_skb_any(rx->skb);
+		rx->skb = 0;
+		rx->dma_addr = 0;
+		return -ENOMEM;
+	}
+
 	/* Link the RFD to end of RFA by linking previous RFD to
 	 * this one, and clearing EL bit of previous.  */
 	if(rx->prev->skb) {
@@ -1472,7 +1494,7 @@ static inline int e100_rx_indicate(struc
 
 	/* If data isn't ready, nothing to indicate */
 	if(unlikely(!(rfd_status & cb_complete)))
-		return -EAGAIN;
+		return -ENODATA;
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1483,6 +1505,10 @@ static inline int e100_rx_indicate(struc
 	pci_unmap_single(nic->pdev, rx->dma_addr,
 		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
 
+	/* this allows for a fast restart without re-enabling interrupts */
+	if(le16_to_cpu(rfd->command) & cb_el)
+		nic->ru_running = RU_SUSPENDED;
+
 	/* Pull off the RFD and put the actual data (minus eth hdr) */
 	skb_reserve(skb, sizeof(struct rfd));
 	skb_put(skb, actual_size);
@@ -1515,20 +1541,45 @@ static inline void e100_rx_clean(struct 
 	unsigned int work_to_do)
 {
 	struct rx *rx;
+	int restart_required = 0;
+	struct rx *rx_to_start = NULL;
+
+	/* are we already rnr? then pay attention!!! this ensures that
+	 * the state machine progression never allows a start with a 
+	 * partially cleaned list, avoiding a race between hardware
+	 * and rx_to_clean when in NAPI mode */
+	if(RU_SUSPENDED == nic->ru_running)
+		restart_required = 1;
 
 	/* Indicate newly arrived packets */
 	for(rx = nic->rx_to_clean; rx->skb; rx = nic->rx_to_clean = rx->next) {
-		if(e100_rx_indicate(nic, rx, work_done, work_to_do))
+		int err = e100_rx_indicate(nic, rx, work_done, work_to_do);
+		if(-EAGAIN == err) {
+			/* hit quota so have more work to do, restart once
+			 * cleanup is complete */
+			restart_required = 0;
+			break;
+		} else if(-ENODATA == err)
 			break; /* No more to clean */
 	}
 
+	/* save our starting point as the place we'll restart the receiver */
+	if(restart_required)
+		rx_to_start = nic->rx_to_clean;
+
 	/* Alloc new skbs to refill list */
 	for(rx = nic->rx_to_use; !rx->skb; rx = nic->rx_to_use = rx->next) {
 		if(unlikely(e100_rx_alloc_skb(nic, rx)))
 			break; /* Better luck next time (see watchdog) */
 	}
 
-	e100_start_receiver(nic);
+	if(restart_required) {
+		// ack the rnr?
+		writeb(stat_ack_rnr, &nic->csr->scb.stat_ack);
+		e100_start_receiver(nic, rx_to_start);
+		if(work_done)
+			(*work_done)++;
+	}
 }
 
 static void e100_rx_clean_list(struct nic *nic)
@@ -1536,6 +1587,8 @@ static void e100_rx_clean_list(struct ni
 	struct rx *rx;
 	unsigned int i, count = nic->params.rfds.count;
 
+	nic->ru_running = RU_UNINITIALIZED;
+
 	if(nic->rxs) {
 		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 			if(rx->skb) {
@@ -1549,7 +1602,6 @@ static void e100_rx_clean_list(struct ni
 	}
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
-	nic->ru_running = 0;
 }
 
 static int e100_rx_alloc_list(struct nic *nic)
@@ -1558,6 +1610,7 @@ static int e100_rx_alloc_list(struct nic
 	unsigned int i, count = nic->params.rfds.count;
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
+	nic->ru_running = RU_UNINITIALIZED;
 
 	if(!(nic->rxs = kmalloc(sizeof(struct rx) * count, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -1573,6 +1626,7 @@ static int e100_rx_alloc_list(struct nic
 	}
 
 	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
+	nic->ru_running = RU_SUSPENDED;
 
 	return 0;
 }
@@ -1594,7 +1648,7 @@ static irqreturn_t e100_intr(int irq, vo
 
 	/* We hit Receive No Resource (RNR); restart RU after cleaning */
 	if(stat_ack & stat_ack_rnr)
-		nic->ru_running = 0;
+		nic->ru_running = RU_SUSPENDED;
 
 	e100_disable_irq(nic);
 	netif_rx_schedule(netdev);
@@ -1684,7 +1700,7 @@ static int e100_up(struct nic *nic)
 	if((err = e100_hw_init(nic)))
 		goto err_clean_cbs;
 	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, 0);
 	mod_timer(&nic->watchdog, jiffies);
 	if((err = request_irq(nic->pdev->irq, e100_intr, SA_SHIRQ,
 		nic->netdev->name, nic->netdev)))
@@ -1759,7 +1813,7 @@ static int e100_loopback_test(struct nic
 		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
 			BMCR_LOOPBACK);
 
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, 0);
 
 	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
 		err = -ENOMEM;
@@ -2233,6 +2287,7 @@ static int __devinit e100_probe(struct p
 
 	e100_get_defaults(nic);
 
+	/* locks must be initialized before calling hw_reset */
 	spin_lock_init(&nic->cb_lock);
 	spin_lock_init(&nic->cmd_lock);
 
@@ -2348,7 +2355,8 @@ static int e100_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	e100_hw_init(nic);
+	if(e100_hw_init(nic))
+		DPRINTK(HW, ERR, "e100_hw_init failed\n");
 
 	netif_device_attach(netdev);
 	if(netif_running(netdev))
