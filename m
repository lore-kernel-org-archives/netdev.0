From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Fixes entry of short packets
Date: Tue, 24 Jun 2008 09:20:57 +1000
Message-ID: <1214263257.8011.278.camel@pasglop>
References: <1214225705-25850-1-git-send-email-sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43082 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbYFWXVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 19:21:09 -0400
In-Reply-To: <1214225705-25850-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-23 at 14:55 +0200, Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> Short packets has to be discarded by the driver. So this patch addresses the
> issue of discarding the short packets of size lesser then ethernet header
> size.

You are freeing the skb, why ? Shouldn't we just keep the skb in the
ring for further rx ?

> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index 6dfc2c9..aa407b2 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -1652,6 +1652,13 @@ static int emac_poll_rx(void *param, int budget)
>  
>  		skb_put(skb, len);
>  	push_packet:
> +		if (skb->len < ETH_HLEN) {
> +			dev_kfree_skb(skb);
> +			printk(KERN_WARNING "%s: short packets dropped\n",
> +			       dev->ndev->name);
> +			++dev->estats.rx_dropped_stack;
> +			goto next;
> +		}
>  		skb->dev = dev->ndev;
>  		skb->protocol = eth_type_trans(skb, dev->ndev);
>  		emac_rx_csum(dev, skb, ctrl);

