From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v1] mv643xx_eth: only account for work done in
 rxq_process in poll callback.
Date: Fri, 6 Mar 2015 22:49:08 +0100
Message-ID: <20150306214908.GA15939@electric-eye.fr.zoreil.com>
References: <1425492124-5033-1-git-send-email-nschichan@freebox.fr>
 <20150304213235.GA20596@electric-eye.fr.zoreil.com>
 <54F9D590.5000406@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54F9D590.5000406@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Schichan <nschichan@freebox.fr> :
[...]
> I was trying to minimize the code changes wrt the current source, but if you
> want that change to be in the same patch, I can certainly respin a V2 with it.

No need to respin, you elegantly minimized the changes. The body of the
while loop could be more spartan, especially with bql in sight. Say:

@@ -1041,52 +1041,37 @@ out:
 	mp->work_tx_end &= ~(1 << txq->index);
 }
 
-static int txq_reclaim(struct tx_queue *txq, int budget, int force)
+static void txq_reclaim(struct tx_queue *txq, int force)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
-	int reclaimed;
+	struct net_device *dev = mp->dev;
+	struct netdev_queue *nq = netdev_get_tx_queue(dev, txq->index);
+	int used = txq->tx_used_desc;
+	int count;
 
-	__netif_tx_lock_bh(nq);
+	mp->work_tx &= ~(1 << txq->index);
 
-	reclaimed = 0;
-	while (reclaimed < budget && txq->tx_desc_count > 0) {
-		int tx_index;
-		struct tx_desc *desc;
-		u32 cmd_sts;
-		char desc_dma_map;
-
-		tx_index = txq->tx_used_desc;
-		desc = &txq->tx_desc_area[tx_index];
-		desc_dma_map = txq->tx_desc_mapping[tx_index];
+	__netif_tx_lock(nq, smp_processor_id());
 
-		cmd_sts = desc->cmd_sts;
+	for (count = txq->tx_desc_count; count > 0; count--) {
+		struct tx_desc *desc = &txq->tx_desc_area[used];
+		char desc_dma_map = txq->tx_desc_mapping[used];
 
-		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+		if (desc->cmd_sts & BUFFER_OWNED_BY_DMA) {
 			if (!force)
 				break;
-			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+			desc->cmd_sts &= ~BUFFER_OWNED_BY_DMA;
 		}
 
-		txq->tx_used_desc = tx_index + 1;
-		if (txq->tx_used_desc == txq->tx_ring_size)
-			txq->tx_used_desc = 0;
-
-		reclaimed++;
-		txq->tx_desc_count--;
+		used = (used + 1) % txq->tx_ring_size;
 
 		if (!IS_TSO_HEADER(txq, desc->buf_ptr)) {
-
 			if (desc_dma_map == DESC_DMA_MAP_PAGE)
-				dma_unmap_page(mp->dev->dev.parent,
-					       desc->buf_ptr,
-					       desc->byte_cnt,
-					       DMA_TO_DEVICE);
+				dma_unmap_page(dev->dev.parent, desc->buf_ptr,
+					       desc->byte_cnt, DMA_TO_DEVICE);
 			else
-				dma_unmap_single(mp->dev->dev.parent,
-						 desc->buf_ptr,
-						 desc->byte_cnt,
-						 DMA_TO_DEVICE);
+				dma_unmap_single(dev->dev.parent, desc->buf_ptr,
+						 desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
 		if (cmd_sts & TX_ENABLE_INTERRUPT) {
@@ -1097,18 +1082,15 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		}
 
 		if (cmd_sts & ERROR_SUMMARY) {
-			netdev_info(mp->dev, "tx error\n");
-			mp->dev->stats.tx_errors++;
+			netdev_info(dev, "tx error\n");
+			dev->stats.tx_errors++;
 		}
-
 	}
 
-	__netif_tx_unlock_bh(nq);
-
-	if (reclaimed < budget)
-		mp->work_tx &= ~(1 << txq->index);
+	txq->tx_used_desc = used;
+	txq->tx_desc_count = count;
 
-	return reclaimed;
+	__netif_tx_unlock(nq);
 }
 
Nobody uses txq_reclaim return status code. You can turn it void.

[...]
> > work_tx is also updated in irq context. I'd rather see "clear_flag() then
> > reclaim()" than "reclaim() then clear_flag()" in a subsequent patch.
> 
> Just to be sure that I understand the issue here, under normal conditions,
> work_tx is updated in irq context via mv643xx_eth_collect_events() and then
> the mv643xx interrupts are masked and napi_schedule() is called. Only once all
> the work has been completed in the poll callback and the work flags have been
> cleared, are the interrupt unmasked and napi_complete() is called. As far as I
> can see there should be no issue here.

IRQF_SHARED and mv643xx_eth_netpoll make me marginally nervous.

My concern was mostly stylistic given the current code. Things get
easier - call me lazy - if the bit is cleared before reclaiming.

> The only problem I can see is in OOM condition when napi_schedule is called
> from a timer callback (oom_timer_wrapper()) which will result in the poll
> callback being called with the interrupts unmasked and if an interrupt fires
> (possibly in an other CPU) at the wrong time, mv643xx_eth_collect_events()
> will race with the various flags clear in txq_reclaim, rxq_process and
> rxq_refill ?

<knee jerk>
You can ignore OOM: the driver should drop received packets immediately
instead of poking holes in its receive descriptor ring.
</knee jerk>

> In that case wouldn't be something like clear_bit/set_bit preferred compared
> to the direct bitwise operations ?

I don't have any strong feeling about it.

Thanks.

-- 
Ueimor
