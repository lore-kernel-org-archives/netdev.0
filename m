From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2.6.37-rc1] net-next: Add multiqueue support to vmxnet3
 driver v3
Date: Wed, 17 Nov 2010 17:23:38 +0000
Message-ID: <1290014618.2588.50.camel@bwh-desktop>
References: <20101013145732.7d69d0f3@nehalam>
	 <1287073868.2258.13.camel@achroite.uk.solarflarecom.com>
	 <89E2752CFA8EC044846EB8499819134102BF0F3B1D@EXCH-MBX-4.vmware.com>
	 <20101015.092327.193701886.davem@davemloft.net>
	 <alpine.LRH.2.00.1011011522020.12306@sbhatewara-dev1.eng.vmware.com>
	 <alpine.LRH.2.00.1011101426410.816@sbhatewara-dev1.eng.vmware.com>
	 <alpine.LRH.2.00.1011161939500.25227@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1011161939500.25227@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-11-16 at 21:14 -0800, Shreyas Bhatewara wrote:
[...]
> Okay. I am resending the patch with no module params what-so-ever. The default
> is no-multiqueue though. Single queue code has matured and is optimized for
> performance. Multiqueue code has got relatively lesser performance tuning. Since
> there is no way to switch between the two modes as of now, it only makes sense
> to keep the best known as default. When configuration knobs are introduced 
> later, multiqueue can be made default.

But so far as I can see there is currently *no* way to enable multiqueue
without editing the code.  Perhaps there could be an experimental config
option that people can use to enable and test it now, before we sort out
the proper API?

[...]
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 21314e0..6f3f905 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
[...]
> @@ -176,16 +186,18 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
>  		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>  				       VMXNET3_CMD_GET_QUEUE_STATUS);
>  
> -		if (adapter->tqd_start->status.stopped) {
> -			printk(KERN_ERR "%s: tq error 0x%x\n",
> -			       adapter->netdev->name,
> -			       le32_to_cpu(adapter->tqd_start->status.error));
> -		}
> -		if (adapter->rqd_start->status.stopped) {
> -			printk(KERN_ERR "%s: rq error 0x%x\n",
> -			       adapter->netdev->name,
> -			       adapter->rqd_start->status.error);
> -		}
> +		for (i = 0; i < adapter->num_tx_queues; i++)
> +			if (adapter->tqd_start[i].status.stopped)
> +				dev_dbg(&adapter->netdev->dev,
> +					"%s: tq[%d] error 0x%x\n",
> +					adapter->netdev->name, i, le32_to_cpu(
> +					adapter->tqd_start[i].status.error));
> +		for (i = 0; i < adapter->num_rx_queues; i++)
> +			if (adapter->rqd_start[i].status.stopped)
> +				dev_dbg(&adapter->netdev->dev,
> +					"%s: rq[%d] error 0x%x\n",
> +					adapter->netdev->name, i,
> +					adapter->rqd_start[i].status.error);

Why are these being downgraded from 'err' to 'dbg' severity?

[...]
> @@ -1000,8 +1042,8 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
>  	if (le32_to_cpu(tq->shared->txNumDeferred) >=
>  					le32_to_cpu(tq->shared->txThreshold)) {
>  		tq->shared->txNumDeferred = 0;
> -		VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_TXPROD,
> -				       tq->tx_ring.next2fill);
> +		VMXNET3_WRITE_BAR0_REG(adapter, (VMXNET3_REG_TXPROD +
> +				       tq->qid * 8), tq->tx_ring.next2fill);

This line-wrapping is strange and could be misleading.  I suggest you
put the whole of the expression 'VMXNET3_REG_TXPROD + tq->qid * 8' on
one line.

Similarly in vmxnet3_activate_dev().

>  	}
>  
>  	return NETDEV_TX_OK;
> @@ -1020,7 +1062,10 @@ vmxnet3_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  {
>  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
>  
> -	return vmxnet3_tq_xmit(skb, &adapter->tx_queue, adapter, netdev);
> +		BUG_ON(skb->queue_mapping > adapter->num_tx_queues);
> +		return vmxnet3_tq_xmit(skb,
> +				       &adapter->tx_queue[skb->queue_mapping],
> +				       adapter, netdev);

This is indented wrongly.

[...] 
>  static int
>  vmxnet3_request_irqs(struct vmxnet3_adapter *adapter)
>  {
> -	int err;
> +	struct vmxnet3_intr *intr = &adapter->intr;
> +	int err = 0, i;
> +	int vector = 0;
>  
>  #ifdef CONFIG_PCI_MSI
>  	if (adapter->intr.type == VMXNET3_IT_MSIX) {
> -		/* we only use 1 MSI-X vector */
> -		err = request_irq(adapter->intr.msix_entries[0].vector,
> -				  vmxnet3_intr, 0, adapter->netdev->name,
> -				  adapter->netdev);
> -	} else if (adapter->intr.type == VMXNET3_IT_MSI) {
> +		for (i = 0; i < adapter->num_tx_queues; i++) {
> +			sprintf(adapter->tx_queue[i].name, "%s:v%d-%s",
> +				adapter->netdev->name, vector, "Tx");

The naming convention for IRQs on a multiqueue device is
<devname>[-<type>]-<index> (and <type> is all lower-case).  So this
should be:

			sprintf(adapter->tx_queue[i].name, "%s-tx-%d",
				adapter->netdev->name, i);

Similarly for the RX and other-event interrupts.

[...] 
> @@ -2343,6 +2800,7 @@ vmxnet3_tx_timeout(struct net_device *netdev)
>  
>  	printk(KERN_ERR "%s: tx hang\n", adapter->netdev->name);
>  	schedule_work(&adapter->work);
> +	netif_wake_queue(adapter->netdev);

This hunk doesn't seem relevant to the description of the patch.

[...]
> @@ -2399,8 +2857,32 @@ vmxnet3_probe_device(struct pci_dev *pdev,
>  	struct net_device *netdev;
>  	struct vmxnet3_adapter *adapter;
>  	u8 mac[ETH_ALEN];
> +	int size;
> +	int num_tx_queues = enable_mq == 0 ? 1 : 0;
> +	int num_rx_queues = enable_mq == 0 ? 1 : 0;
> +
> +#ifdef VMXNET3_RSS
> +	if (num_rx_queues == 0)
> +		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
> +				    (int)num_online_cpus());
> +	else
> +		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
> +				    num_rx_queues);
> +#else
> +	num_rx_queues = 1;
> +#endif
> +
> +	if (num_tx_queues <= 0)
> +		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
> +				    (int)num_online_cpus());
> +	else
> +		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
> +				    num_tx_queues);

This is a bit opaque; the following would be clearer:

	int num_tx_queues, num_rx_queues;

ifdef VMXNET3_RSS
	if (enable_mq)
		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
				    (int)num_online_cpus());
	else
#endif
		num_rx_queues = 1;

	if (enable_mq)
		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
				    (int)num_online_cpus());
	else
		num_tx_queues = 1;

> +	netdev = alloc_etherdev_mq(sizeof(struct vmxnet3_adapter),
> +				   num_tx_queues);
> +	printk(KERN_INFO "# of Tx queues : %d, # of Rx queues : %d\n",
> +	       num_tx_queues, num_rx_queues);

If it's possible that num_tx_queues != num_rx_queues then you have to do
something a bit different here:

	netdev = alloc_etherdev_mq(sizeof(struct vmxnet3_adapter),
				   max(num_rx_queues, num_tx_queues));

[...]
> @@ -2482,7 +2994,18 @@ vmxnet3_probe_device(struct pci_dev *pdev,
>  
>  	INIT_WORK(&adapter->work, vmxnet3_reset_work);
>  
> -	netif_napi_add(netdev, &adapter->napi, vmxnet3_poll, 64);
> +	if (adapter->intr.type == VMXNET3_IT_MSIX) {
> +		int i;
> +		for (i = 0; i < adapter->num_rx_queues; i++) {
> +			netif_napi_add(adapter->netdev,
> +				       &adapter->rx_queue[i].napi,
> +				       vmxnet3_poll_rx_only, 64);
> +		}
> +	} else {
> +		netif_napi_add(adapter->netdev, &adapter->rx_queue[0].napi,
> +			       vmxnet3_poll, 64);
> +	}
> +

You need to call netif_set_real_num_{rx,tx}_queues() here (before
register_netdev()) if you have reduced the numbers of queues - e.g. if
there are not enough MSI-X vectors available.

>  	SET_NETDEV_DEV(netdev, &pdev->dev);
>  	err = register_netdev(netdev);
>  
[...]
> @@ -2522,6 +3048,19 @@ vmxnet3_remove_device(struct pci_dev *pdev)
>  {
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +	int size = 0;
> +	int num_rx_queues = enable_mq == 0 ? 1 : 0;
> +
> +#ifdef VMXNET3_RSS
> +	if (num_rx_queues <= 0)
> +		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
> +				    (int)num_online_cpus());
> +	else
> +		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
> +				    num_rx_queues);
> +#else
> +	num_rx_queues = 1;
> +#endif
>
>  	flush_scheduled_work();
>  
> @@ -2529,10 +3068,15 @@ vmxnet3_remove_device(struct pci_dev *pdev)
>  
>  	vmxnet3_free_intr_resources(adapter);
>  	vmxnet3_free_pci_resources(adapter);
> +#ifdef VMXNET3_RSS
> +	kfree(adapter->rss_conf);
> +#endif
>  	kfree(adapter->pm_conf);
> -	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_TxQueueDesc) +
> -			    sizeof(struct Vmxnet3_RxQueueDesc),
> -			    adapter->tqd_start, adapter->queue_desc_pa);
> +
> +	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
> +	size += sizeof(struct Vmxnet3_RxQueueDesc) * num_rx_queues;
> +	pci_free_consistent(adapter->pdev, size, adapter->tqd_start,
> +			    adapter->queue_desc_pa);
>  	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_DriverShared),
>  			    adapter->shared, adapter->shared_pa);
>  	free_netdev(netdev);

Maybe you should store the size of the hypervisor-shared state somewhere
rather than recalculating it here.

[...]
> @@ -2708,6 +3252,7 @@ vmxnet3_init_module(void)
>  {
>  	printk(KERN_INFO "%s - version %s\n", VMXNET3_DRIVER_DESC,
>  		VMXNET3_DRIVER_VERSION_REPORT);
> +	atomic_set(&devices_found, 0);

This hunk doesn't seem relevant to the description of the patch.

[...]
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index b79070b..9a80106 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
[...]
> +static int
> +vmxnet3_set_rss_indir(struct net_device *netdev,
> +		      const struct ethtool_rxfh_indir *p)
> +{
> +	unsigned int i;
> +	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> +	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
> +
> +	if (p->size != rssConf->indTableSize)
> +		return -EINVAL;
> +	for (i = 0; i < rssConf->indTableSize; i++) {
> +		if (p->ring_index[i] >= 0 && p->ring_index[i] <
> +		    adapter->num_rx_queues)
> +			rssConf->indTable[i] = p->ring_index[i];
> +		else
> +			rssConf->indTable[i] = i % adapter->num_rx_queues;
[...]

This should return -EINVAL if any of the queue indices are out of range.
ethtool gets the maximum valid queue index from your get_rxnfc()
implementation.

Ben. 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
