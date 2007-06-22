From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 3/3] NetXen: Fix the rmmod error on PBlades due incorrect cleanup
Date: Fri, 22 Jun 2007 12:50:17 +0200
Message-ID: <200706221250.18194.mb@bu3sch.de>
References: <200706220842.l5M8gcsD021825@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47063
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbXFVKuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 06:50:44 -0400
In-Reply-To: <200706220842.l5M8gcsD021825@dut39.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 22 June 2007 10:42:38 Mithlesh Thukral wrote:
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index 4e958c9..f0df6fb 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -378,6 +378,7 @@ int netxen_nic_hw_resources(struct netxe
>  						   crb_rcvpeg_state));
>  		while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
>  			udelay(100);
> +			schedule();
>  			/* Window 1 call */
>  			state = readl(NETXEN_CRB_NORMALIZE(adapter,
>  							   recv_crb_registers

Better do msleep(1); instead of udelay+schedule.

> @@ -700,7 +701,7 @@ void netxen_nic_pci_change_crbwindow(str
>  		adapter->curr_window = 0;
>  }
>  
> -void netxen_load_firmware(struct netxen_adapter *adapter)
> +int netxen_load_firmware(struct netxen_adapter *adapter)
>  {
>  	int i;
>  	u32 data, size = 0;
> @@ -712,15 +713,25 @@ void netxen_load_firmware(struct netxen_
>  	writel(1, NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_CAS_RST));
>  
>  	for (i = 0; i < size; i++) {
> -		if (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
> -			DPRINTK(ERR,
> -				"Error in netxen_rom_fast_read(). Will skip"
> -				"loading flash image\n");
> -			return;
> +		while (netxen_rom_fast_read(adapter, flashaddr, (int *)&data) != 0) {
> +			long timeout = 2 * HZ;
> +			while (timeout) {
> +			    if (signal_pending(current)) {
> +				printk( "%s: Got a signal, exiting\n", __FUNCTION__ );
> +				return -1;
> +			    }
> +			    set_current_state(TASK_INTERRUPTIBLE);
> +			    timeout = schedule_timeout(timeout);
> +			}

You're opencoding msleep_interruptible() here?
And this sleeps two seconds between each rom-read attempt. Is that
really your intention?
I'd say better attempt to read more often and sleep less each time.

>  		off = netxen_nic_pci_set_window(adapter, memaddr);
>  		addr = pci_base_offset(adapter, off);
>  		writel(data, addr);
> +		while (readl(addr) != data) {
> +			mdelay(100);
> +			writel(data, addr);
> +		}

Add a timeout. Else this will result in a system hang, if the hardware is faulty.

> diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
> index 15f6dc5..8f5f4f8 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -408,8 +408,12 @@ static inline int
>  do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>  {
>  	if (jiffies > (last_schedule_time + (8 * HZ))) {
> -		last_schedule_time = jiffies;
> -		schedule();
> +		if (last_schedule_time) {
> +			last_schedule_time = jiffies;
> +			schedule();
> +		} else {
> +			last_schedule_time = jiffies;
> +		}

Why this strange thing?
I'd simply call cond_resched() instead of all this custom
schedule timekeeping. That's best for system latency.

> -void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
> +int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
>  {
>  	u32 val = 0;
> -	int loops = 0;
>  
>  	if (!pegtune_val) {
> -		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
> -		while (val != PHAN_INITIALIZE_COMPLETE && 
> -			val != PHAN_INITIALIZE_ACK && loops < 200000) {
> -			udelay(100);
> -			schedule();
> -			val =
> -			    readl(NETXEN_CRB_NORMALIZE
> +		do {
> +			long timeout = 10 * HZ;
> +			while (timeout) {
> +				if (signal_pending(current)) {
> +					printk(KERN_INFO"%s: Got a signal, exiting\n", __FUNCTION__ );
> +					printk(KERN_INFO"%s: val=0x%x, pegtune_val=0x%x\n", __FUNCTION__,
> +						val, pegtune_val );
> +					return -1;
> +				}
> +				set_current_state(TASK_INTERRUPTIBLE);
> +				timeout = schedule_timeout(timeout);
> +			}
> +			val = readl(NETXEN_CRB_NORMALIZE
>  				  (adapter, CRB_CMDPEG_STATE));

msleep_interruptible()?

> @@ -1278,11 +1285,13 @@ int netxen_process_cmd_ring(unsigned lon
>  		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
>  			pci_unmap_single(pdev, frag->dma, frag->length,
>  					 PCI_DMA_TODEVICE);
> +			frag->dma = (u64) NULL;

??? Cast the NULL pointer to u64?

>  			for (i = 1; i < buffer->frag_count; i++) {
>  				DPRINTK(INFO, "getting fragment no %d\n", i);
>  				frag++;	/* Get the next frag */
>  				pci_unmap_page(pdev, frag->dma, frag->length,
>  					       PCI_DMA_TODEVICE);
> +				frag->dma = (u64) NULL;

???

> @@ -547,13 +546,7 @@ #endif
>  				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
>  		/* Handshake with the card before we register the devices. */
>  		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
> -
> -	       /* leave the hw in the same state as reboot */
> -	       writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
> -	       netxen_pinit_from_rom(adapter, 0);
> -	       udelay(500);
> -	       netxen_load_firmware(adapter);
> -	       netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
> +		mdelay(2000);

Two seconds delay? No! Too long, sleep.

> @@ -653,30 +646,21 @@ static void __devexit netxen_nic_remove(
>  
>  	netdev = adapter->netdev;
>  
> -	netxen_nic_disable_int(adapter);
> -	if (adapter->irq)
> -		free_irq(adapter->irq, adapter);
> -	
> +	unregister_netdev(netdev);
> +	mdelay(3000);

Toooo long, sleep.

> @@ -696,17 +680,73 @@ static void __devexit netxen_nic_remove(
>  		}
>  	}
>  
> -	unregister_netdev(netdev);
> +	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
> +		pci_disable_msi(pdev);
>  
>  	vfree(adapter->cmd_buf_arr);
>  
> +	pci_disable_device(pdev);
> +
> +	if (adapter->portnum == 0) {
> +		if (init_firmware_done) {
> +			dma_watchdog_shutdown_request(adapter);
> +			mdelay(100);
> +			i = 100;	
> +			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
> +				printk(KERN_INFO"dma_watchdog_shutdown_poll still in progress\n");
> +				mdelay(100);

0.1 seconds delay is too long IMO, too. Sleep!

> +		dma_watchdog_shutdown_request(adapter);
> +		mdelay(100);
> +		i = 100;	
> +		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
> +			printk(KERN_INFO"dma_watchdog_shutdown_poll still in progress\n");
> +			mdelay(100);

same...


-- 
Greetings Michael.
