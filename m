From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND][PATCH 2.6.28] myri10ge: Add multiqueue TX support
Date: Wed, 24 Sep 2008 20:51:51 -0400
Message-ID: <48DAE0A7.7020400@garzik.org>
References: <48D536CF.5030503@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47072 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbYIYAv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:51:56 -0400
In-Reply-To: <48D536CF.5030503@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Add multiqueue TX support to myri10ge.
>     
> Signed-off-by: Brice Goglin <brice@myri.com>
> 
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -102,6 +102,9 @@ MODULE_LICENSE("Dual BSD/GPL");
>  #define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
>  #define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
>  
> +#define MYRI10GE_MAX_SLICES 32
> +
>  struct myri10ge_rx_buffer_state {
>  	struct page *page;
>  	int page_offset;
> @@ -138,6 +141,8 @@ struct myri10ge_rx_buf {
>  
>  struct myri10ge_tx_buf {
>  	struct mcp_kreq_ether_send __iomem *lanai;	/* lanai ptr for sendq */
> +	__be32 __iomem *send_go;	/* "go" doorbell ptr */
> +	__be32 __iomem *send_stop;	/* "stop" doorbell ptr */
>  	struct mcp_kreq_ether_send *req_list;	/* host shadow of sendq */
>  	char *req_bytes;
>  	struct myri10ge_tx_buffer_state *info;
> @@ -149,6 +154,7 @@ struct myri10ge_tx_buf {
>  	int done ____cacheline_aligned;	/* transmit slots completed     */
>  	int pkt_done;		/* packets completed */
>  	int wake_queue;
> +	int queue_active;
>  };
>  
>  struct myri10ge_rx_done {
> @@ -420,6 +426,12 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
>  			return -ENOSYS;
>  		} else if (result == MXGEFW_CMD_ERROR_UNALIGNED) {
>  			return -E2BIG;
> +		} else if (result == MXGEFW_CMD_ERROR_RANGE &&
> +			   cmd == MXGEFW_CMD_ENABLE_RSS_QUEUES &&
> +			   (data->
> +			    data1 & MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES) !=
> +			   0) {
> +			return -ERANGE;
>  		} else {
>  			dev_err(&mgp->pdev->dev,
>  				"command %d failed, result = %d\n",
> @@ -949,9 +961,24 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
>  		 */
>  
>  		cmd.data0 = mgp->num_slices;
> -		cmd.data1 = 1;	/* use MSI-X */
> +		cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
> +		if (mgp->dev->real_num_tx_queues > 1)
> +			cmd.data1 |= MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES;
>  		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
>  					   &cmd, 0);
> +
> +		/* Firmware older than 1.4.32 only supports multiple
> +		 * RX queues, so if we get an error, first retry using a
> +		 * single TX queue before giving up */
> +		if (status != 0 && mgp->dev->real_num_tx_queues > 1) {
> +			mgp->dev->real_num_tx_queues = 1;
> +			cmd.data0 = mgp->num_slices;
> +			cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
> +			status = myri10ge_send_cmd(mgp,
> +						   MXGEFW_CMD_ENABLE_RSS_QUEUES,
> +						   &cmd, 0);
> +		}
> +
>  		if (status != 0) {
>  			dev_err(&mgp->pdev->dev,
>  				"failed to set number of slices\n");
> @@ -1319,6 +1346,7 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
>  {
>  	struct pci_dev *pdev = ss->mgp->pdev;
>  	struct myri10ge_tx_buf *tx = &ss->tx;
> +	struct netdev_queue *dev_queue;
>  	struct sk_buff *skb;
>  	int idx, len;
>  
> @@ -1352,11 +1380,31 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
>  					       PCI_DMA_TODEVICE);
>  		}
>  	}
> +
> +	dev_queue = netdev_get_tx_queue(ss->dev, ss - ss->mgp->ss);
> +	/*
> +	 * Make a minimal effort to prevent the NIC from polling an
> +	 * idle tx queue.  If we can't get the lock we leave the queue
> +	 * active. In this case, either a thread was about to start
> +	 * using the queue anyway, or we lost a race and the NIC will
> +	 * waste some of its resources polling an inactive queue for a
> +	 * while.
> +	 */
> +
> +	if ((ss->mgp->dev->real_num_tx_queues > 1) &&
> +	    __netif_tx_trylock(dev_queue)) {
> +		if (tx->req == tx->done) {
> +			tx->queue_active = 0;
> +			put_be32(htonl(1), tx->send_stop);
> +		}
> +		__netif_tx_unlock(dev_queue);
> +	}
> +
>  	/* start the queue if we've stopped it */
> -	if (netif_queue_stopped(ss->dev)
> +	if (netif_tx_queue_stopped(dev_queue)
>  	    && tx->req - tx->done < (tx->mask >> 1)) {
>  		tx->wake_queue++;
> -		netif_wake_queue(ss->dev);
> +		netif_tx_wake_queue(dev_queue);
>  	}
>  }
>  
> @@ -1484,9 +1532,9 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
>  	u32 send_done_count;
>  	int i;
>  
> -	/* an interrupt on a non-zero slice is implicitly valid
> -	 * since MSI-X irqs are not shared */
> -	if (ss != mgp->ss) {
> +	/* an interrupt on a non-zero receive-only slice is implicitly
> +	 * valid  since MSI-X irqs are not shared */
> +	if ((mgp->dev->real_num_tx_queues == 1) && (ss != mgp->ss)) {
>  		netif_rx_schedule(ss->dev, &ss->napi);
>  		return (IRQ_HANDLED);
>  	}
> @@ -1528,7 +1576,9 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
>  		barrier();
>  	}
>  
> -	myri10ge_check_statblock(mgp);
> +	/* Only slice 0 updates stats */
> +	if (ss == mgp->ss)
> +		myri10ge_check_statblock(mgp);
>  
>  	put_be32(htonl(3), ss->irq_claim + 1);
>  	return (IRQ_HANDLED);
> @@ -1886,6 +1936,7 @@ static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
>  	/* ensure req_list entries are aligned to 8 bytes */
>  	ss->tx.req_list = (struct mcp_kreq_ether_send *)
>  	    ALIGN((unsigned long)ss->tx.req_bytes, 8);
> +	ss->tx.queue_active = 0;
>  
>  	bytes = rx_ring_entries * sizeof(*ss->rx_small.shadow);
>  	ss->rx_small.shadow = kzalloc(bytes, GFP_KERNEL);
> @@ -2366,11 +2417,14 @@ static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
>  	int status;
>  
>  	ss = &mgp->ss[slice];
> -	cmd.data0 = 0;		/* single slice for now */
> -	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
> -	ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
> -	    (mgp->sram + cmd.data0);
> -
> +	status = 0;
> +	if (slice == 0 || (mgp->dev->real_num_tx_queues > 1)) {
> +		cmd.data0 = slice;
> +		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET,
> +					   &cmd, 0);
> +		ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
> +		    (mgp->sram + cmd.data0);
> +	}
>  	cmd.data0 = slice;
>  	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET,
>  				    &cmd, 0);
> @@ -2382,6 +2436,10 @@ static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
>  	ss->rx_big.lanai = (struct mcp_kreq_ether_recv __iomem *)
>  	    (mgp->sram + cmd.data0);
>  
> +	ss->tx.send_go = (__iomem __be32 *)
> +	    (mgp->sram + MXGEFW_ETH_SEND_GO + 64 * slice);
> +	ss->tx.send_stop = (__iomem __be32 *)
> +	    (mgp->sram + MXGEFW_ETH_SEND_STOP + 64 * slice);
>  	return status;
>  
>  }
> @@ -2395,7 +2453,7 @@ static int myri10ge_set_stats(struct myri10ge_priv *mgp, int slice)
>  	ss = &mgp->ss[slice];
>  	cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->fw_stats_bus);
>  	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->fw_stats_bus);
> -	cmd.data2 = sizeof(struct mcp_irq_data);
> +	cmd.data2 = sizeof(struct mcp_irq_data) | (slice << 16);
>  	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
>  	if (status == -ENOSYS) {
>  		dma_addr_t bus = ss->fw_stats_bus;
> @@ -2436,7 +2494,9 @@ static int myri10ge_open(struct net_device *dev)
>  
>  	if (mgp->num_slices > 1) {
>  		cmd.data0 = mgp->num_slices;
> -		cmd.data1 = 1;	/* use MSI-X */
> +		cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
> +		if (mgp->dev->real_num_tx_queues > 1)
> +			cmd.data1 |= MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES;
>  		status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ENABLE_RSS_QUEUES,
>  					   &cmd, 0);
>  		if (status != 0) {
> @@ -2457,6 +2517,7 @@ static int myri10ge_open(struct net_device *dev)
>  			printk(KERN_ERR
>  			       "myri10ge: %s: failed to setup rss tables\n",
>  			       dev->name);
> +			goto abort_with_nothing;
>  		}
>  
>  		/* just enable an identity mapping */
> @@ -2527,7 +2602,11 @@ static int myri10ge_open(struct net_device *dev)
>  		status = myri10ge_allocate_rings(ss);
>  		if (status != 0)
>  			goto abort_with_rings;
> -		if (slice == 0)
> +
> +		/* only firmware which supports multiple TX queues
> +		 * supports setting up the tx stats on non-zero
> +		 * slices */
> +		if (slice == 0 || mgp->dev->real_num_tx_queues > 1)
>  			status = myri10ge_set_stats(mgp, slice);
>  		if (status) {
>  			printk(KERN_ERR
> @@ -2593,7 +2672,8 @@ static int myri10ge_open(struct net_device *dev)
>  	mgp->running = MYRI10GE_ETH_RUNNING;
>  	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
>  	add_timer(&mgp->watchdog_timer);
> -	netif_wake_queue(dev);
> +	netif_tx_wake_all_queues(dev);
> +
>  	return 0;
>  
>  abort_with_rings:
> @@ -2620,13 +2705,15 @@ static int myri10ge_close(struct net_device *dev)
>  	if (mgp->ss[0].tx.req_bytes == NULL)
>  		return 0;
>  
> +	dev->select_queue = NULL;
>  	del_timer_sync(&mgp->watchdog_timer);
>  	mgp->running = MYRI10GE_ETH_STOPPING;
>  	for (i = 0; i < mgp->num_slices; i++) {
>  		napi_disable(&mgp->ss[i].napi);
>  	}
>  	netif_carrier_off(dev);
> -	netif_stop_queue(dev);
> +
> +	netif_tx_stop_all_queues(dev);
>  	old_down_cnt = mgp->down_cnt;
>  	mb();
>  	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_DOWN, &cmd, 0);
> @@ -2731,18 +2823,23 @@ static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct mcp_kreq_ether_send *req;
>  	struct myri10ge_tx_buf *tx;
>  	struct skb_frag_struct *frag;
> +	struct netdev_queue *netdev_queue;
>  	dma_addr_t bus;
>  	u32 low;
>  	__be32 high_swapped;
>  	unsigned int len;
>  	int idx, last_idx, avail, frag_cnt, frag_idx, count, mss, max_segments;
> -	u16 pseudo_hdr_offset, cksum_offset;
> +	u16 pseudo_hdr_offset, cksum_offset, queue;
>  	int cum_len, seglen, boundary, rdma_count;
>  	u8 flags, odd_flag;
>  
> -	/* always transmit through slot 0 */
> -	ss = mgp->ss;
> +	queue = skb_get_queue_mapping(skb);
> +	queue &= (mgp->num_slices - 1);
> +
> +	ss = &mgp->ss[queue];
> +	netdev_queue = netdev_get_tx_queue(mgp->dev, queue);
>  	tx = &ss->tx;
> +
>  again:
>  	req = tx->req_list;
>  	avail = tx->mask - 1 - (tx->req - tx->done);
> @@ -2758,7 +2855,7 @@ again:
>  	if ((unlikely(avail < max_segments))) {
>  		/* we are out of transmit resources */
>  		tx->stop_queue++;
> -		netif_stop_queue(dev);
> +		netif_tx_stop_queue(netdev_queue);
>  		return 1;
>  	}
>  
> @@ -2951,10 +3048,16 @@ again:
>  	idx = ((count - 1) + tx->req) & tx->mask;
>  	tx->info[idx].last = 1;
>  	myri10ge_submit_req(tx, tx->req_list, count);
> +	/* if using multiple tx queues, make sure NIC polls the
> +	 * current slice */
> +	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
> +		tx->queue_active = 1;
> +		put_be32(htonl(1), tx->send_go);
> +	}
>  	tx->pkt_start++;
>  	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
>  		tx->stop_queue++;
> -		netif_stop_queue(dev);
> +		netif_tx_stop_queue(netdev_queue);
>  	}
>  	dev->trans_start = jiffies;
>  	return 0;
> @@ -3532,20 +3635,21 @@ static void myri10ge_watchdog(struct work_struct *work)
>  		for (i = 0; i < mgp->num_slices; i++) {
>  			tx = &mgp->ss[i].tx;
>  			printk(KERN_INFO
> -			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
> -			       mgp->dev->name, i, tx->req, tx->done,
> -			       tx->pkt_start, tx->pkt_done,
> +			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
> +			       mgp->dev->name, i, tx->queue_active, tx->req,
> +			       tx->done, tx->pkt_start, tx->pkt_done,
>  			       (int)ntohl(mgp->ss[i].fw_stats->
>  					  send_done_count));
>  			msleep(2000);
>  			printk(KERN_INFO
> -			       "myri10ge: %s: (%d): %d %d %d %d %d\n",
> -			       mgp->dev->name, i, tx->req, tx->done,
> -			       tx->pkt_start, tx->pkt_done,
> +			       "myri10ge: %s: (%d): %d %d %d %d %d %d\n",
> +			       mgp->dev->name, i, tx->queue_active, tx->req,
> +			       tx->done, tx->pkt_start, tx->pkt_done,
>  			       (int)ntohl(mgp->ss[i].fw_stats->
>  					  send_done_count));
>  		}
>  	}
> +
>  	rtnl_lock();
>  	myri10ge_close(mgp->dev);
>  	status = myri10ge_load_firmware(mgp, 1);
> @@ -3600,10 +3704,14 @@ static void myri10ge_watchdog_timer(unsigned long arg)
>  			/* nic seems like it might be stuck.. */
>  			if (rx_pause_cnt != mgp->watchdog_pause) {
>  				if (net_ratelimit())
> -					printk(KERN_WARNING "myri10ge %s:"
> +					printk(KERN_WARNING
> +					       "myri10ge %s slice %d:"
>  					       "TX paused, check link partner\n",
> -					       mgp->dev->name);
> +					       mgp->dev->name, i);
>  			} else {
> +				printk(KERN_WARNING
> +				       "myri10ge %s slice %d stuck:",
> +				       mgp->dev->name, i);
>  				reset_needed = 1;
>  			}
>  		}
> @@ -3789,6 +3897,9 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
>  					 mgp->num_slices);
>  		if (status == 0) {
>  			pci_disable_msix(pdev);
> +#ifdef CONFIG_NETDEVICES_MULTIQUEUE
> +			mgp->features |= NETIF_F_MULTI_QUEUE;
> +#endif
>  			return;
>  		}
>  		if (status > 0)
> @@ -3818,7 +3929,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	int status = -ENXIO;
>  	int dac_enabled;
>  
> -	netdev = alloc_etherdev(sizeof(*mgp));
> +	netdev = alloc_etherdev_mq(sizeof(*mgp), MYRI10GE_MAX_SLICES);
>  	if (netdev == NULL) {
>  		dev_err(dev, "Could not allocate ethernet device\n");
>  		return -ENOMEM;
> @@ -3923,7 +4034,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		dev_err(&pdev->dev, "failed to alloc slice state\n");
>  		goto abort_with_firmware;
>  	}
> -
> +	netdev->real_num_tx_queues = mgp->num_slices;
>  	status = myri10ge_reset(mgp);
>  	if (status != 0) {
>  		dev_err(&pdev->dev, "failed reset\n");
> @@ -3947,6 +4058,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	netdev->set_multicast_list = myri10ge_set_multicast_list;
>  	netdev->set_mac_address = myri10ge_set_mac_address;
>  	netdev->features = mgp->features;
> +
>  	if (dac_enabled)
>  		netdev->features |= NETIF_F_HIGHDMA;
>  
> @@ -4102,8 +4214,7 @@ static __init int myri10ge_init_module(void)
>  	printk(KERN_INFO "%s: Version %s\n", myri10ge_driver.name,
>  	       MYRI10GE_VERSION_STR);
>  
> -	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_SRC_PORT ||
> -	    myri10ge_rss_hash < MXGEFW_RSS_HASH_TYPE_IPV4) {
> +	if (myri10ge_rss_hash > MXGEFW_RSS_HASH_TYPE_MAX) {
>  		printk(KERN_ERR
>  		       "%s: Illegal rssh hash type %d, defaulting to source port\n",
>  		       myri10ge_driver.name, myri10ge_rss_hash);
> @@ -4112,6 +4223,8 @@ static __init int myri10ge_init_module(void)
>  #ifdef CONFIG_DCA
>  	dca_register_notify(&myri10ge_dca_notifier);
>  #endif
> +	if (myri10ge_max_slices > MYRI10GE_MAX_SLICES)
> +		myri10ge_max_slices = MYRI10GE_MAX_SLICES;
>  
>  	return pci_register_driver(&myri10ge_driver);
>  }
> 

doesn't seem to apply to net-next...


