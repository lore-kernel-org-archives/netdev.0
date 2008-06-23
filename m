From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Fixes memory leak in ibm_newemac ethernet
	driver
Date: Tue, 24 Jun 2008 09:21:50 +1000
Message-ID: <1214263310.8011.280.camel@pasglop>
References: <1214225712-25882-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43101 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbYFWXWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 19:22:04 -0400
In-Reply-To: <1214225712-25882-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> This patch addresses the memory leak happenning in drivers transmit queue
> under heavy load condition. Once the transmit queue becomes full, driver
> does an automatic wrapup of queue. During which the untransmitted SKB's are
> lost without getting freed up.

This would be a bug. We should stop the queue when full instead.

> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index aa407b2..ee868b6 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -1328,6 +1328,13 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  
>  	DBG2(dev, "xmit(%u) %d" NL, len, slot);
>  
> +	if (dev->tx_skb[slot] && dev->tx_desc[slot].data_ptr) {
> +		dev_kfree_skb(dev->tx_skb[slot]);
> +		dev->tx_skb[slot] = NULL;
> +		dev->tx_cnt--;
> +		++dev->estats.tx_dropped;
> +	}
> +
>  	dev->tx_skb[slot] = skb;
>  	dev->tx_desc[slot].data_ptr = dma_map_single(&dev->ofdev->dev,
>  						     skb->data, len,

