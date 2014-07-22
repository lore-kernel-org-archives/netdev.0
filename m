From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Wed, 23 Jul 2014 00:16:06 +0200
Message-ID: <20140722221606.GA16444@electric-eye.fr.zoreil.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59489 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563AbaGVWQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:16:28 -0400
Content-Disposition: inline
In-Reply-To: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sonic Zhang <sonic.adi@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index 7ae74d4..8924802 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
[...]
> @@ -1302,41 +1303,53 @@ out:
>  	current_rx_ptr = current_rx_ptr->next;
>  }
>  
> +static int bfin_mac_poll(struct napi_struct *napi, int budget)
> +{
> +	int i = 0;
> +	struct bfin_mac_local *lp = container_of(napi,
> +						 struct bfin_mac_local,
> +						 napi);
> +
> +	while (current_rx_ptr->status.status_word != 0 && i < budget) {
> +		bfin_mac_rx(lp, budget);
> +		i++;
> +	}
> +
> +	if (i < budget) {
> +		napi_complete(napi);
> +		if (lp->rx_irq_disabled--)
> +			if (!lp->rx_irq_disabled)
> +				enable_irq(IRQ_MAC_RX);
> +	}
[...]
>  static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
>  {
> +	struct bfin_mac_local *lp = netdev_priv(dev_id);
> +	u32 status;
> +
> +	status = bfin_read_DMA1_IRQ_STATUS();
> +
> +	bfin_write_DMA1_IRQ_STATUS(status | DMA_DONE | DMA_ERR);
> +	if ((status & DMA_DONE) && napi_schedule_prep(&lp->napi)) {
> +		if (!lp->rx_irq_disabled++)
> +			disable_irq_nosync(IRQ_MAC_RX);
> +		__napi_schedule(&lp->napi);

If netpoll scavenges between napi_schedule_prep and lp->rx_irq_disabled++
on a different CPU, bfin_mac_interrupt may later __napi_schedule while
already napi_completed in netpoll...bfin_mac_poll(): bfin_mac_poll won't
be run in net_rx_action and IRQ_MAC_RX will stay disabled.

I don't know if something on the blackfin arch prevents the window to
widen and makes it moot.

As the bfin_mac driver requests the single non shared IRQ_MAC_RX irq,
couldn't we instead:

static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
[...]
	if (status & DMA_DONE) {
		disable_irq_nosync(IRQ_MAC_RX);
		/* Code won't return here until a scheduled poll enables irq. */
		set_bit(BFIN_IRQ_DISABLED, &lp->flags);
		napi_schedule(&lp->napi);
	}

static int bfin_mac_poll(struct napi_struct *napi, int budget)
[...]
	if (i < budget) {
		napi_complete(napi);
		if (test_and_clear_bit(BFIN_IRQ_DISABLED, &lp->flags))
			enable_irq(IRQ_MAC_RX);
	}

Comments ?

-- 
Ueimor
