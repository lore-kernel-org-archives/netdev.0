From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6] e100: remove reference to NAPI config option
Date: Tue, 1 Feb 2005 09:25:33 -0500
Message-ID: <20050201142533.GB15056@tuxdriver.com>
References: <1107220952.3366.4.camel@sfeldma-mobl.dsl-verizon.net> <20050201014358.GD15786@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@pobox.com>, jgarzik@pobox.com, netdev@oss.sgi.com,
        lunz@falooley.org
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20050201014358.GD15786@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2005 at 12:43:58PM +1100, Anton Blanchard wrote:
> 
> Hi Scott,
> 
> > e100 is NAPI all the time, so the Kconfig option is wasting space.
> 
> Speaking of NAPI...
> 
> We have seen issues with NAPI on ppc64 on various cards in the past.

Just curious...wanna try this patch I got from Intel?  I think it
may help...

John

--- linux-2.6.9/drivers/net/e100.c.napifix	2005-01-25 15:54:28.830937362 -0500
+++ linux-2.6.9/drivers/net/e100.c	2005-01-25 15:54:56.350257693 -0500
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
@@ -510,7 +516,7 @@ struct nic {
 	struct rx *rx_to_use;
 	struct rx *rx_to_clean;
 	struct rfd blank_rfd;
-	int ru_running;
+	enum ru_state ru_running;
 
 	spinlock_t cb_lock			____cacheline_aligned;
 	spinlock_t cmd_lock;
@@ -1417,12 +1423,18 @@ static int e100_alloc_cbs(struct nic *ni
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
 
@@ -1473,7 +1485,7 @@ static inline int e100_rx_indicate(struc
 
 	/* If data isn't ready, nothing to indicate */
 	if(unlikely(!(rfd_status & cb_complete)))
-		return -EAGAIN;
+		return -ENODATA;
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1484,6 +1496,10 @@ static inline int e100_rx_indicate(struc
 	pci_unmap_single(nic->pdev, rx->dma_addr,
 		RFD_BUF_LEN, PCI_DMA_FROMDEVICE);
 
+	/* this allows for a fast restart without re-enabling interrupts */
+	if(le16_to_cpu(rfd->command) & cb_el)
+		nic->ru_running = RU_SUSPENDED;
+
 	/* Pull off the RFD and put the actual data (minus eth hdr) */
 	skb_reserve(skb, sizeof(struct rfd));
 	skb_put(skb, actual_size);
@@ -1516,20 +1532,45 @@ static inline void e100_rx_clean(struct 
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
@@ -1537,6 +1578,8 @@ static void e100_rx_clean_list(struct ni
 	struct rx *rx;
 	unsigned int i, count = nic->params.rfds.count;
 
+	nic->ru_running = RU_UNINITIALIZED;
+
 	if(nic->rxs) {
 		for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 			if(rx->skb) {
@@ -1550,7 +1593,6 @@ static void e100_rx_clean_list(struct ni
 	}
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
-	nic->ru_running = 0;
 }
 
 static int e100_rx_alloc_list(struct nic *nic)
@@ -1559,6 +1601,7 @@ static int e100_rx_alloc_list(struct nic
 	unsigned int i, count = nic->params.rfds.count;
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
+	nic->ru_running = RU_UNINITIALIZED;
 
 	if(!(nic->rxs = kmalloc(sizeof(struct rx) * count, GFP_ATOMIC)))
 		return -ENOMEM;
@@ -1574,6 +1617,7 @@ static int e100_rx_alloc_list(struct nic
 	}
 
 	nic->rx_to_use = nic->rx_to_clean = nic->rxs;
+	nic->ru_running = RU_SUSPENDED;
 
 	return 0;
 }
@@ -1595,7 +1639,7 @@ static irqreturn_t e100_intr(int irq, vo
 
 	/* We hit Receive No Resource (RNR); restart RU after cleaning */
 	if(stat_ack & stat_ack_rnr)
-		nic->ru_running = 0;
+		nic->ru_running = RU_SUSPENDED;
 
 	e100_disable_irq(nic);
 	netif_rx_schedule(netdev);
@@ -1611,6 +1655,7 @@ static int e100_poll(struct net_device *
 	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, work_to_do);
+	// should we be quota on tx?
 	tx_cleaned = e100_tx_clean(nic);
 
 	/* If no Rx and Tx cleanup work was done, exit polling mode. */
@@ -1684,7 +1729,7 @@ static int e100_up(struct nic *nic)
 	if((err = e100_hw_init(nic)))
 		goto err_clean_cbs;
 	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, 0);
 	mod_timer(&nic->watchdog, jiffies);
 	if((err = request_irq(nic->pdev->irq, e100_intr, SA_SHIRQ,
 		nic->netdev->name, nic->netdev)))
@@ -1759,7 +1804,7 @@ static int e100_loopback_test(struct nic
 		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
 			BMCR_LOOPBACK);
 
-	e100_start_receiver(nic);
+	e100_start_receiver(nic, 0);
 
 	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
 		err = -ENOMEM;
-- 
John W. Linville
linville@tuxdriver.com
