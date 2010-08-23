From: Jon Mason <jon.mason@exar.com>
Subject: Re: [Patch 1/2] s2io: remove lro parameter
Date: Mon, 23 Aug 2010 10:41:11 -0500
Message-ID: <20100823154111.GA11861@exar.com>
References: <20100818075530.5926.67960.sendpatchset@localhost.localdomain>
 <20100818153626.GC9202@exar.com>
 <4C6E42AC.4070401@redhat.com>
 <4C72346C.9020606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58960 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab0HWPkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 11:40:07 -0400
Received: by pzk26 with SMTP id 26so2322442pzk.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 08:40:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C72346C.9020606@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 01:42:20AM -0700, Cong Wang wrote:
> On 08/20/10 16:54, Cong Wang wrote:
> > On 08/18/10 23:36, Jon Mason wrote:
> >> On Wed, Aug 18, 2010 at 12:51:09AM -0700, Amerigo Wang wrote:
> >>>
> >>> As suggested by David, this parameter can die, we can use ethtool
> >>> to turn LRO on/off. Compile tests only.
> >>
> >> Needs some additional removal
> >>
> >> Line 41 and 42 " * lro: Specifies whether to enable Large Receive ..."
> >> As you have removed the modparm
> >>
> >> Line 8286 "if (sp->lro)"
> >> As it will always be on in this instance
> >>
> >>
> >> Also, all references to "sp->lro" can be converted to "(dev->features
> >> & NETIF_F_LRO)", removing an unnecessary variable.
> >>
> >
> > Thanks for pointing these out.
> > I will fix them later.
> >
> 
> Done, please review the patch below.

Looks good to me.  Push it formally, and I'll ack it.

Thanks,
Jon

> 
> Thanks!
> 
> -- 
> 
> Remove "lro" parameter of s2io driver.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 18bc5b7..b3a30ac 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -38,8 +38,6 @@
>   * Tx descriptors that can be associated with each corresponding FIFO.
>   * intr_type: This defines the type of interrupt. The values can be 0(INTA),
>   *     2(MSI_X). Default value is '2(MSI_X)'
> - * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
> - *     Possible values '1' for enable '0' for disable. Default is '0'
>   * lro_max_pkts: This parameter defines maximum number of packets can be
>   *     aggregated as a single large packet
>   * napi: This parameter used to enable/disable NAPI (polling Rx)
> @@ -496,8 +494,6 @@ S2IO_PARM_INT(rxsync_frequency, 3);
>  /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
>  S2IO_PARM_INT(intr_type, 2);
>  /* Large receive offload feature */
> -static unsigned int lro_enable = 1;
> -module_param_named(lro, lro_enable, uint, 0);
>  
>  /* Max pkts to be aggregated by LRO at one time. If not specified,
>   * aggregation happens until we hit max IP pkt size(64K)
> @@ -6735,13 +6731,10 @@ static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
>  		return -EINVAL;
>  
>  	if (data & ETH_FLAG_LRO) {
> -		if (lro_enable) {
> -			if (!(dev->features & NETIF_F_LRO)) {
> -				dev->features |= NETIF_F_LRO;
> -				changed = 1;
> -			}
> -		} else
> -			rc = -EINVAL;
> +		if (!(dev->features & NETIF_F_LRO)) {
> +			dev->features |= NETIF_F_LRO;
> +			changed = 1;
> +		}
>  	} else if (dev->features & NETIF_F_LRO) {
>  		dev->features &= ~NETIF_F_LRO;
>  		changed = 1;
> @@ -6750,7 +6743,6 @@ static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
>  	if (changed && netif_running(dev)) {
>  		s2io_stop_all_tx_queue(sp);
>  		s2io_card_down(sp);
> -		sp->lro = !!(dev->features & NETIF_F_LRO);
>  		rc = s2io_card_up(sp);
>  		if (rc)
>  			s2io_reset(sp);
> @@ -7307,7 +7299,7 @@ static int s2io_card_up(struct s2io_nic *sp)
>  		struct ring_info *ring = &mac_control->rings[i];
>  
>  		ring->mtu = dev->mtu;
> -		ring->lro = sp->lro;
> +		ring->lro = !!(dev->features & NETIF_F_LRO);
>  		ret = fill_rx_buffers(sp, ring, 1);
>  		if (ret) {
>  			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
> @@ -7341,7 +7333,7 @@ static int s2io_card_up(struct s2io_nic *sp)
>  	/* Setting its receive mode */
>  	s2io_set_multicast(dev);
>  
> -	if (sp->lro) {
> +	if (dev->features & NETIF_F_LRO) {
>  		/* Initialize max aggregatable pkts per session based on MTU */
>  		sp->lro_max_aggr_per_sess = ((1<<16) - 1) / dev->mtu;
>  		/* Check if we can use (if specified) user provided value */
> @@ -7911,7 +7903,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
>  	else
>  		sp->device_type = XFRAME_I_DEVICE;
>  
> -	sp->lro = lro_enable;
>  
>  	/* Initialize some PCI/PCI-X fields of the NIC. */
>  	s2io_init_pci(sp);
> @@ -8047,8 +8038,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
>  	dev->netdev_ops = &s2io_netdev_ops;
>  	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
>  	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> -	if (lro_enable)
> -		dev->features |= NETIF_F_LRO;
> +	dev->features |= NETIF_F_LRO;
>  	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
>  	if (sp->high_dma_flag == true)
>  		dev->features |= NETIF_F_HIGHDMA;
> @@ -8283,9 +8273,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
>  			  dev->name);
>  	}
>  
> -	if (sp->lro)
> -		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
> -			  dev->name);
> +	DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
> +		  dev->name);
>  	if (ufo)
>  		DBG_PRINT(ERR_DBG,
>  			  "%s: UDP Fragmentation Offload(UFO) enabled\n",
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 0af0335..26c7884 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -971,7 +971,6 @@ struct s2io_nic {
>  
>  	unsigned long	clubbed_frms_cnt;
>  	unsigned long	sending_both;
> -	u8		lro;
>  	u16		lro_max_aggr_per_sess;
>  	volatile unsigned long state;
>  	u64		general_int_mask;

