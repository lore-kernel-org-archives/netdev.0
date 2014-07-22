From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Mon, 21 Jul 2014 22:31:40 -0700 (PDT)
Message-ID: <20140721.223140.1559817699583180859.davem@davemloft.net>
References: <1406006448-14624-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbaGVFbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 01:31:49 -0400
In-Reply-To: <1406006448-14624-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Tue, 22 Jul 2014 13:20:48 +0800

> +static int bfin_mac_poll(struct napi_struct *napi, int budget)
> +{
 ...
> +	if (i < budget) {
> +		napi_complete(napi);
> +		if (lp->rx_irq_disabled) {
> +			lp->rx_irq_disabled--;
> +			enable_irq(IRQ_MAC_RX);
> +		}
 ...
>  /* interrupt routine to handle rx and error signal */
>  static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
>  {
 ...
> +
> +	bfin_write_DMA1_IRQ_STATUS(status | DMA_DONE | DMA_ERR);
> +	if ((status & DMA_DONE) && napi_schedule_prep(&lp->napi)) {
> +		disable_irq_nosync(IRQ_MAC_RX);
> +		lp->rx_irq_disabled++;
> +		__napi_schedule(&lp->napi);
>  	}

How in the world does this work?

You should only IRQ disable when rx_irq_disabled is zero before the
increment, and you should only do the IRQ enable when decrementing
rx_irq_disabled will cause it to become zero.
