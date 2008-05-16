From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/15] BE NIC driver - header and initialization functions
Date: Fri, 16 May 2008 12:54:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805161146110.1888@wrl-59.cs.helsinki.fi>
References: <20080515090240.5ecbd2e3@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38040 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755402AbYEPJyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 05:54:15 -0400
In-Reply-To: <20080515090240.5ecbd2e3@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Subbu Seetharaman wrote:

> Thanks to everyone who reviewed the first submission of the NIC driver
> for BladeEngine (ServerEngines' 10Gb NIC) driver. I am submitting the driver
> with all changes for another round of review. 


> diff --git a/drivers/net/benet/be_init.c b/drivers/net/benet/be_init.c
> new file mode 100644
> index 0000000..0de2d22
> --- /dev/null
> +++ b/drivers/net/benet/be_init.c

> +	adapter = (struct be_adapter *) OSM_NOB(pnob)->adapter;
> +	SA_ASSERT(adapter);
> +
> +	/* Only if this netdev is up */

...We can well figure this out without such comments, same goes for couple 
of other here below, please remove obvious comments as they just waste 
screen space and thereby make the logic harder to follow (please remove 
such comments elsewhere too, not just in this function):

> +	if (netif_running(netdev)) {
> +		/*
> +		 * Let us stop the dev queue for the
> +		 * interface associated with this netobj.
> +		 */
> +		netif_stop_queue(netdev);
> +
> +		/* Wait until no more pending transmits  */
> +		wait_nic_tx_cmpl(pnob);
> +
> +		/* Disable this EQ's interrupt  */
> +		bni_disable_eq_intr(pnob);
> +	}

> +	if (OSM_NOB(pnob))
> +		kfree(OSM_NOB(pnob));

kfree does NULL checks already for you.

> +		 * Event queue
> +		 */
> +		pnob->event_q_len = EVENT_Q_LEN;
> +		n = pnob->event_q_len * sizeof(struct EQ_ENTRY_AMAP);
> +		n = MAX(n, (2 * PAGE_SIZE));
> +		/* Get number of pages */
> +		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);

See what linux/kernel.h provides for you already and use it.

I would rewrite it to something like this:

	len = pnob->event_q_len * sizeof(struct EQ_ENTRY_AMAP);
	n = max(DIV_ROUND_UP(len, PAGE_SIZE), 2);

n is then obviously a number of pages, no need to comment that anymore.

> +		pnob->event_q = (struct EQ_ENTRY_AMAP *)
> +		    __get_free_pages(GFP_KERNEL, sa_log2(m));
> +		if (pnob->event_q == NULL)
> +			goto err_ret1;
> +		pnob->event_q_pa = virt_to_phys(pnob->event_q);
> +		pnob->event_q_pa = cpu_to_le64(pnob->event_q_pa);

...First of all, points from using standard converters instead of 
inventing your own :-).

But alas, it won't be accepted by sparse. You need to use appropriate 
le/be8/16/32/64 types when dealing with endianesses and then make sparse 
happy too by using conversion in proper places. 

> +		pnob->event_q_pages = m;
> +		/*
> +		 * Eth TX queue
> +		 */
> +		pnob->tx_q_len = ETH_TXQ_LEN;
> +		pnob->tx_q_port = 0;	/* No port binding */
> +		n = pnob->tx_q_len * sizeof(struct ETH_WRB_AMAP);
> +		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
> +		/* Get number of pages */
> +		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);

Ditto.

> +		pnob->tx_q = (struct ETH_WRB_AMAP *)
> +		    __get_free_pages(GFP_KERNEL, sa_log2(m));
> +		if (pnob->tx_q == NULL)
> +			goto err_ret1;
> +		pnob->tx_q_pa = virt_to_phys(pnob->tx_q);
> +		pnob->tx_q_pa = cpu_to_le64(pnob->tx_q_pa);
> +		pnob->tx_q_pages = m;
> +		/*
> +		 * Eth TX Compl queue
> +		 */
> +		pnob->txcq_len = ETH_TXCQ_LEN;
> +		n = pnob->txcq_len * sizeof(struct ETH_TX_COMPL_AMAP);
> +		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
> +		/* Get number of pages */
> +		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);

...ditto, please fix the rest as well. Though I would consider some kind 
of way to avoid all this code duplication.

> +/*
> + * This function is called by the PCI sub-system when it finds a PCI
> + * device with dev/vendor IDs that match with one of our devices.
> + * All of the driver initialization is done in this function.
> + */
> +static int
> +be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
> +{
> +	int status = 0;
> +	struct be_adapter *adapter = NULL;
> +	u32 r;
> +	u32 adapt_num = 0;
> +	struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD ioctl_pload;
> +	struct bni_net_object *pnob = NULL;
> +
> +	status = pci_enable_device(pdev);
> +	if (status) {
> +		printk(KERN_ERR "pci_enable_device() for BE adapter %d failed",
> +		       adapt_num);
> +		return status;
> +	}
> +
> +	status = pci_request_regions(pdev, be_driver_name);
> +	if (status)
> +		return status;
> +
> +	pci_set_master(pdev);
> +
> +	adapter = kzalloc(sizeof(struct be_adapter), GFP_KERNEL);
> +	if (adapter == NULL) {
> +		pci_release_regions(pdev);
> +		goto err_ret;
> +	}
> +
> +	pci_set_drvdata(pdev, adapter);
> +	/*
> +	 * Adapative interrupt coalescing limits in usecs.
> +	 * should be a multiple of 8.
> +	 */
> +	adapter->enable_aic = 1;
> +	adapter->max_eqd = MAX_EQD;
> +	adapter->min_eqd = 0;
> +	adapter->cur_eqd = 0;	/* start with no EQ delay */
> +	r = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
> +	if (!r) {
> +		/* Device is DAC Capable.  */
> +		adapter->dma_64bit_cap = TRUE;
> +	} else {
> +		adapter->dma_64bit_cap = FALSE;
> +		r = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
> +		if (r) {
> +			printk(KERN_ERR "Could not set PCI DMA Mask\n");
> +			return r;

Doesn't this leak something?

> +		}
> +	}
> +
> +	status = init_pci_be_function(adapter, pdev);
> +	if (status < 0) {
> +		printk(KERN_ERR "Failed to map PCI BARS\n");
> +		status = -ENOMEM;
> +		goto cleanup1;
> +	}
> +
> +	(void)sa_trace_set_level((DL_ALWAYS | DL_ERR));
> +
> +	r = bni_init(&adapter->chip_object);
> +	if (r != 0) {
> +		printk(KERN_ERR "bni_init() failed - Error %d\n", r);
> +		goto cleanup1;
> +	}
> +
> +	/* Allocate Memory for getting the Link status */
> +	adapter->be_link_sts = (struct BE_LINK_STATUS *)
> +	    kmalloc(sizeof(struct BE_LINK_STATUS), GFP_KERNEL);
> +	if (adapter->be_link_sts == NULL) {
> +		printk(KERN_ERR "Memory allocation for link status "
> +				"buffer failed\n");
> +		goto cleanup1;
> +	}
> +	spin_lock_init(&adapter->txq_lock);
> +
> +	status = be_prepare_interface(adapter);
> +	if (status < 0)
> +		goto cleanup1;
> +
> +	pnob = adapter->net_obj;
> +
> +	/* if the rx_frag size if 2K, one page is shared as two RX frags */
> +	OSM_NOB(pnob)->rx_pg_shared =
> +			(pnob->rx_buf_size <= PAGE_SIZE / 2) ? TRUE : FALSE;
> +	if (pnob->rx_buf_size != rxbuf_size) {
> +		printk(KERN_WARNING
> +		       "Could not set Rx buffer size to %d. Using %d\n",
> +		       rxbuf_size, pnob->rx_buf_size);
> +		rxbuf_size = pnob->rx_buf_size;
> +	}
> +
> +	tasklet_init(&(adapter->sts_handler), osm_process_sts,
> +		     (unsigned long)adapter);
> +	adapter->tasklet_started = 1;	/* indication to cleanup */
> +	spin_lock_init(&(adapter->int_lock));
> +
> +
> +	if (be_register_isr(adapter, pnob) != 0)
> +		goto cleanup;
> +
> +	adapter->isr_registered = 1;
> +	adapter->rx_csum = 1;	/* enable RX checksum check */
> +	adapter->max_rx_coal = BE_LRO_MAX_PKTS;
> +
> +	/* print the version numbers */
> +	memset(&ioctl_pload, 0,
> +	       sizeof(struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD));
> +	printk(KERN_INFO "BladeEngine Driver version:%s. "
> +	       "Copyright ServerEngines, Corporation 2005 - 2008\n",
> +		be_drvr_ver);
> +	status = be_function_get_fw_version(&pnob->fn_obj, &ioctl_pload, NULL,
> +				       NULL);
> +	if (status == BE_SUCCESS) {
> +		strncpy(be_fw_ver, ioctl_pload.firmware_version_string, 32);
> +		printk(KERN_INFO "BladeEngine Firmware Version:%s\n",
> +		       ioctl_pload.firmware_version_string);
> +	} else {
> +		printk(KERN_WARNING "Unable to get BE Firmware Version\n");
> +	}
> +
> +	sema_init(&adapter->get_eth_stat_sem, 0);
> +
> +	init_timer(&adapter->timer_ctxt.get_stats_timer);
> +	atomic_set(&adapter->timer_ctxt.get_stat_flag, 0);
> +	adapter->timer_ctxt.get_stats_timer.function = &get_stats_timer_handler;
> +
> +	status = be_mcc_init(adapter);
> +	if (status < 0)
> +		goto cleanup;
> +	be_update_link_status(adapter);
> +
> +	/* Register async call back function to handle link status updates */
> +	status = be_mcc_add_async_event_callback(&adapter->net_obj->mcc_q_obj,
> +			    be_link_status_async_callback, (void *) adapter);
> +	if (status != BE_SUCCESS) {
> +		printk(KERN_WARNING "add_async_event_callback failed");
> +		printk(KERN_WARNING
> +		       "Link status changes may not be reflected\n");
> +	}
> +
> +	/* Enable ChipInterrupt and EQ Interrupt */
> +	bni_enable_intr(adapter->net_obj);
> +	bni_enable_eq_intr(adapter->net_obj);
> +	adapter->dev_state = BE_DEV_STATE_INIT;
> +	return 0;		/* successful return */
> +
> +cleanup1:
> +	pci_release_regions(pdev);
> +	pci_disable_device(pdev);
> +	kfree(adapter);
> +	goto err_ret;
> +
> +cleanup:
> +	be_remove(pdev);
> +
> +err_ret:
> +	printk(KERN_ERR "BladeEngine init failed\n");
> +	return -ENOMEM;
> +}

> +#ifdef CONFIG_PM
> +static void
> +be_pm_cleanup(struct be_adapter *adapter,
> +		  struct bni_net_object *pnob, struct net_device *netdev)
> +{
> +	u32 i;
> +
> +	netif_carrier_off(netdev);
> +	netif_stop_queue(netdev);
> +
> +	wait_nic_tx_cmpl(pnob);
> +	bni_disable_eq_intr(pnob);

...Cool, this time they are without dead obvious comments :-).

> diff --git a/drivers/net/benet/bni.h b/drivers/net/benet/bni.h
> new file mode 100644
> index 0000000..073c76d
> --- /dev/null
> +++ b/drivers/net/benet/bni.h

> +#define TOU32(_struct_) *((u32 *)(&(_struct_)))

What is this?

> +	/*
> +	 * MCC Ring - used to send ioctl cmds to embedded ARM processor
> +	 */
> +	struct MCC_WRB_AMAP *mcc_q;	/* VA of the start of the ring */
> +	u32 mcc_q_len;			/* # of WRB entries in this ring */
> +	u32 mcc_q_hd;			/* MCC ring head */
> +	u8 mcc_q_created;		/* flag to help cleanup */
> +	u8 mcc_q_pages;			/* Num of pages allocacted by OSM */
> +	struct BE_MCC_OBJECT mcc_q_obj;	/* BECLIB's MCC ring Object */
> +	u64 mcc_q_pa;			/* Physical address in LE order */

...Use appropriate type here then.

> +	/*
> +	 * MCC Completion Ring - ARM's responses to ioctls sent from MCC ring
> +	 */
> +	struct MCC_CQ_ENTRY_AMAP *mcc_cq; /* VA of the start of the ring */
> +	u32 mcc_cq_len;			/* # of compl. entries in this ring */
> +	u32 mcc_cq_tl;			/* compl. ring tail */
> +	u8 mcc_cq_created;		/* flag to help cleanup */
> +	u8 mcc_cq_pages;		/* Num of pages allocacted by OSM */
> +	struct BE_CQ_OBJECT mcc_cq_obj;	/* BECLIB's MCC compl. ring object */
> +	u32 mcc_cq_id;			/* MCC ring ID */
> +	u64 mcc_cq_pa;			/* Physical address in LE order */

...ditto + rest I cut.


-- 
 i.
