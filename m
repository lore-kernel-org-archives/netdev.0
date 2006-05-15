From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] pcnet32.c: modify RX ring size through module parameter
Date: Mon, 15 May 2006 10:58:56 -0500
Message-ID: <20060515155856.GA17646@us.ibm.com>
References: <4467F63E.5060401@tw.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	tsbogend@alpha.franken.de, brazilnut@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:63666 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751601AbWEOQBF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 12:01:05 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4FG151u004685
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 12:01:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4FG15r2192858
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 10:01:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k4FG123k024056
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 10:01:04 -0600
To: Wen Hsin Chang <whchang@tw.ibm.com>
Content-Disposition: inline
In-Reply-To: <4467F63E.5060401@tw.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why is this necessary?  There is already an ethtool function to set
the rx ring size (pcnet32_set_ringparam).  Since module parameters
are being phased out in favor of the ethtool functions, why not use
the existing ethtool infrastructure for this?

Thanks,
Jon

On Mon, May 15, 2006 at 11:32:14AM +0800, Wen Hsin Chang wrote:
> This patch is created from pcnet32.c v1.32. it will allow users to 
> specify RX ring size upon module
> insertion via module parameter 'rx_log_size'. This is needed in some 
> cases where too small the rx ring
> size will cause RX errors upon remote installation via pcnet32 NIC card.
> 
> Signed-off-by: Wen Hsin Chang <whchang@tw.ibm.com>
> ----------------------------------------------------------------------------------------------------
> 
> --- a/drivers/net/pcnet32.c    2006-03-30 09:49:10.000000000 +0800
> +++ b/drivers/net/pcnet32.c    2006-05-15 11:14:45.000000000 +0800
> @@ -93,6 +93,9 @@ static struct net_device *pcnet32_dev;
> static int max_interrupt_work = 2;
> static int rx_copybreak = 200;
> 
> +/* Module parameter to specify RX ring size at module insertion */
> +static int rx_log_size = 0;
> +
> #define PCNET32_PORT_AUI      0x00
> #define PCNET32_PORT_10BT     0x01
> #define PCNET32_PORT_GPSI     0x02
> @@ -1264,7 +1267,10 @@ pcnet32_probe1(unsigned long ioaddr, int
>     lp->name = chipname;
>     lp->shared_irq = shared;
>     lp->tx_ring_size = TX_RING_SIZE;    /* default tx ring size */
> -    lp->rx_ring_size = RX_RING_SIZE;    /* default rx ring size */
> +    if (!rx_log_size)
> +        lp->rx_ring_size = RX_RING_SIZE;    /* default rx ring size */
> +    else
> +        lp->rx_ring_size = (1 << (rx_log_size));
>     lp->tx_mod_mask = lp->tx_ring_size - 1;
>     lp->rx_mod_mask = lp->rx_ring_size - 1;
>     lp->tx_len_bits = (PCNET32_LOG_TX_BUFFERS << 12);
> @@ -2707,6 +2713,11 @@ module_param(tx_start_pt, int, 0);
> MODULE_PARM_DESC(tx_start_pt, DRV_NAME " transmit start point (0-3)");
> module_param(pcnet32vlb, int, 0);
> MODULE_PARM_DESC(pcnet32vlb, DRV_NAME " Vesa local bus (VLB) support 
> (0/1)");
> +
> +/* Module parameter to specify RX ring size at module insertion */
> +module_param(rx_log_size, int, 0);
> +MODULE_PARM_DESC(rx_log_size, DRV_NAME " RX Ring Buffer Size (log_2 
> #BUF) ");
> +
> module_param_array(options, int, NULL, 0);
> MODULE_PARM_DESC(options, DRV_NAME " initial option setting(s) (0-15)");
> module_param_array(full_duplex, int, NULL, 0);
> @@ -2731,6 +2742,12 @@ static int __init pcnet32_init_module(vo
> 
>     if ((tx_start_pt >= 0) && (tx_start_pt <= 3))
>         tx_start = tx_start_pt;
> +       
> +    /* validating rx_log_size */
> +    if ((rx_log_size <= 0) ||
> +        (rx_log_size > PCNET32_LOG_MAX_RX_BUFFERS))
> +        rx_log_size = 0;
> +       
> 
>     /* find the PCI devices */
>     if (!pci_module_init(&pcnet32_driver))
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
