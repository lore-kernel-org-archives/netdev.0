From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/1 net-next] net: fec: add napi support to improve
 proformance
Date: Thu, 24 Jan 2013 05:56:08 -0800
Message-ID: <1359035768.12374.2083.camel@edumazet-glaptop>
References: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:34913 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab3AXN4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 08:56:11 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so4244800dak.5
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 05:56:11 -0800 (PST)
In-Reply-To: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 15:58 +0800, Frank Li wrote:
>  
>  static irqreturn_t
> @@ -805,6 +823,7 @@ fec_enet_interrupt(int irq, void *dev_id)
>  	struct net_device *ndev = dev_id;
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	uint int_events;
> +	ulong flags;
>  	irqreturn_t ret = IRQ_NONE;
>  
>  	do {
> @@ -813,7 +832,14 @@ fec_enet_interrupt(int irq, void *dev_id)
>  
>  		if (int_events & FEC_ENET_RXF) {
>  			ret = IRQ_HANDLED;
> -			fec_enet_rx(ndev);
> +
> +			spin_lock_irqsave(&fep->hw_lock, flags);

You already are in a irq safe context, spin_lock() should be ok

> +			/* Disable the RX interrupt */
> +			if (napi_schedule_prep(&fep->napi)) {
> +				fec_enet_rx_int_is_enabled(ndev, false);
> +				__napi_schedule(&fep->napi);
> +			}
> +			spin_unlock_irqrestore(&fep->hw_lock, flags);

       spin_unlock();

>  		}
>  


Same remark for the spin_lock_irqsave(&fep->tmreg_lock, flags) in
fec_enet_tx()
