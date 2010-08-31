From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ucc_geth: fix ethtool set ring param bug
Date: Tue, 31 Aug 2010 15:41:22 +0100
Message-ID: <1283265682.2244.0.camel@achroite.uk.solarflarecom.com>
References: <1283179677-21262-1-git-send-email-liang.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, davem@davemloft.net, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Liang Li <liang.li@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38806 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757491Ab0HaOl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 10:41:26 -0400
In-Reply-To: <1283179677-21262-1-git-send-email-liang.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-30 at 22:47 +0800, Liang Li wrote:
> It's common sense that when we should do change to driver ring
> desc/buffer etc only after 'stop/shutdown' the device. When we
> do change while devices/driver is running, kernel oops occur:
[...]
> diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
> index 6f92e48..1b37aaa 100644
> --- a/drivers/net/ucc_geth_ethtool.c
> +++ b/drivers/net/ucc_geth_ethtool.c
> @@ -255,13 +255,18 @@ uec_set_ringparam(struct net_device *netdev,
>  		return -EINVAL;
>  	}
>  
> -	ug_info->bdRingLenRx[queue] = ring->rx_pending;
> -	ug_info->bdRingLenTx[queue] = ring->tx_pending;
> -
>  	if (netif_running(netdev)) {
> -		/* FIXME: restart automatically */
> -		printk(KERN_INFO
> -			"Please re-open the interface.\n");
> +		printk(KERN_INFO "Stopping interface %s.\n", netdev->name);
> +		ucc_geth_close(netdev);
> +
> +		ug_info->bdRingLenRx[queue] = ring->rx_pending;
> +		ug_info->bdRingLenTx[queue] = ring->tx_pending;
> +
> +		printk(KERN_INFO "Reactivating interface %s.\n", netdev->name);
> +		ucc_geth_open(netdev);

What if ucc_geth_open() fails?

Ben.

> +	} else {
> +		ug_info->bdRingLenRx[queue] = ring->rx_pending;
> +		ug_info->bdRingLenTx[queue] = ring->tx_pending;
>  	}
>  
>  	return ret;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


