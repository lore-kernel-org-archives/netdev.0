From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 28/42] dmfe: convert to new API
Date: Thu, 8 Jan 2009 14:16:08 -0700
Message-ID: <20090108211608.GA20506@colo.lackof.org>
References: <20090107003316.784424362@vyatta.com> <20090107003348.502777359@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:58784 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755956AbZAHVQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 16:16:22 -0500
Content-Disposition: inline
In-Reply-To: <20090107003348.502777359@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 04:33:44PM -0800, Stephen Hemminger wrote:
> Convert to internal net_device-stats and net_device_ops
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

Davem - this one get overlooked?
I didn't see an "applied" email like the others in the series.

thanks,
grant

> 
> 
> --- a/drivers/net/tulip/dmfe.c	2009-01-06 16:08:31.169364168 -0800
> +++ b/drivers/net/tulip/dmfe.c	2009-01-06 16:13:50.841110201 -0800
> @@ -257,9 +257,6 @@ struct dmfe_board_info {
>  	u8 wol_mode;			/* user WOL settings */
>  	struct timer_list timer;
>  
> -	/* System defined statistic counter */
> -	struct net_device_stats stats;
> -
>  	/* Driver defined statistic counter */
>  	unsigned long tx_fifo_underrun;
>  	unsigned long tx_loss_carrier;
> @@ -316,7 +313,6 @@ static u8 SF_mode;		/* Special Function:
>  static int dmfe_open(struct DEVICE *);
>  static int dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
>  static int dmfe_stop(struct DEVICE *);
> -static struct net_device_stats * dmfe_get_stats(struct DEVICE *);
>  static void dmfe_set_filter_mode(struct DEVICE *);
>  static const struct ethtool_ops netdev_ethtool_ops;
>  static u16 read_srom_word(long ,int);
> @@ -351,6 +347,19 @@ static void dmfe_set_phyxcer(struct dmfe
>  
>  /* DM910X network board routine ---------------------------- */
>  
> +static const struct net_device_ops netdev_ops = {
> +	.ndo_open 		= dmfe_open,
> +	.ndo_stop		= dmfe_stop,
> +	.ndo_start_xmit		= dmfe_start_xmit,
> +	.ndo_set_multicast_list = dmfe_set_filter_mode,
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	= poll_dmfe,
> +#endif
> +};
> +
>  /*
>   *	Search DM910X board ,allocate space and register it
>   */
> @@ -442,14 +451,7 @@ static int __devinit dmfe_init_one (stru
>  	dev->base_addr = db->ioaddr;
>  	dev->irq = pdev->irq;
>  	pci_set_drvdata(pdev, dev);
> -	dev->open = &dmfe_open;
> -	dev->hard_start_xmit = &dmfe_start_xmit;
> -	dev->stop = &dmfe_stop;
> -	dev->get_stats = &dmfe_get_stats;
> -	dev->set_multicast_list = &dmfe_set_filter_mode;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	dev->poll_controller = &poll_dmfe;
> -#endif
> +	dev->netdev_ops = &netdev_ops;
>  	dev->ethtool_ops = &netdev_ethtool_ops;
>  	netif_carrier_off(dev);
>  	spin_lock_init(&db->lock);
> @@ -867,15 +869,15 @@ static void dmfe_free_tx_pkt(struct DEVI
>  
>  		/* A packet sent completed */
>  		db->tx_packet_cnt--;
> -		db->stats.tx_packets++;
> +		dev->stats.tx_packets++;
>  
>  		/* Transmit statistic counter */
>  		if ( tdes0 != 0x7fffffff ) {
>  			/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
> -			db->stats.collisions += (tdes0 >> 3) & 0xf;
> -			db->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
> +			dev->stats.collisions += (tdes0 >> 3) & 0xf;
> +			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
>  			if (tdes0 & TDES0_ERR_MASK) {
> -				db->stats.tx_errors++;
> +				dev->stats.tx_errors++;
>  
>  				if (tdes0 & 0x0002) {	/* UnderRun */
>  					db->tx_fifo_underrun++;
> @@ -969,13 +971,13 @@ static void dmfe_rx_packet(struct DEVICE
>  			if (rdes0 & 0x8000) {
>  				/* This is a error packet */
>  				//printk(DRV_NAME ": rdes0: %lx\n", rdes0);
> -				db->stats.rx_errors++;
> +				dev->stats.rx_errors++;
>  				if (rdes0 & 1)
> -					db->stats.rx_fifo_errors++;
> +					dev->stats.rx_fifo_errors++;
>  				if (rdes0 & 2)
> -					db->stats.rx_crc_errors++;
> +					dev->stats.rx_crc_errors++;
>  				if (rdes0 & 0x80)
> -					db->stats.rx_length_errors++;
> +					dev->stats.rx_length_errors++;
>  			}
>  
>  			if ( !(rdes0 & 0x8000) ||
> @@ -1008,8 +1010,8 @@ static void dmfe_rx_packet(struct DEVICE
>  
>  					skb->protocol = eth_type_trans(skb, dev);
>  					netif_rx(skb);
> -					db->stats.rx_packets++;
> -					db->stats.rx_bytes += rxlen;
> +					dev->stats.rx_packets++;
> +					dev->stats.rx_bytes += rxlen;
>  				}
>  			} else {
>  				/* Reuse SKB buffer when the packet is error */
> @@ -1024,20 +1026,6 @@ static void dmfe_rx_packet(struct DEVICE
>  	db->rx_ready_ptr = rxptr;
>  }
>  
> -
> -/*
> - *	Get statistics from driver.
> - */
> -
> -static struct net_device_stats * dmfe_get_stats(struct DEVICE *dev)
> -{
> -	struct dmfe_board_info *db = netdev_priv(dev);
> -
> -	DMFE_DBUG(0, "dmfe_get_stats", 0);
> -	return &db->stats;
> -}
> -
> -
>  /*
>   * Set DM910X multicast address
>   */
> @@ -1161,7 +1149,7 @@ static void dmfe_timer(unsigned long dat
>  
>  	/* Operating Mode Check */
>  	if ( (db->dm910x_chk_mode & 0x1) &&
> -		(db->stats.rx_packets > MAX_CHECK_PACKET) )
> +		(dev->stats.rx_packets > MAX_CHECK_PACKET) )
>  		db->dm910x_chk_mode = 0x4;
>  
>  	/* Dynamic reset DM910X : system error or transmit time-out */
> 
> -- 
