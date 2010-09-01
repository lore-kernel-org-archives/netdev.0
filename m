From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [v1 PATCH] ucc_geth: fix ethtool set ring param bug
Date: Wed, 01 Sep 2010 14:42:30 +0100
Message-ID: <1283348550.2268.7.camel@achroite.uk.solarflarecom.com>
References: <1283179677-21262-1-git-send-email-liang.li@windriver.com>
	 <1283305429-8426-1-git-send-email-liang.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, davem@davemloft.net, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Liang Li <liang.li@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab0IANmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 09:42:33 -0400
In-Reply-To: <1283305429-8426-1-git-send-email-liang.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 09:43 +0800, Liang Li wrote:
> It's common sense that when we should do change to driver ring
> desc/buffer etc only after 'stop/shutdown' the device. When we
> do change while devices/driver is running, kernel oops occur:
[...]
> -	ug_info->bdRingLenRx[queue] = ring->rx_pending;
> -	ug_info->bdRingLenTx[queue] = ring->tx_pending;
> -
>  	if (netif_running(netdev)) {
> -		/* FIXME: restart automatically */
> -		printk(KERN_INFO
> -			"Please re-open the interface.\n");
> +		u16 rx_t;
> +		u16 tx_t;
> +		printk(KERN_INFO "Stopping interface %s.\n", netdev->name);
> +		ucc_geth_close(netdev);
> +
> +		rx_t = ug_info->bdRingLenRx[queue];
> +		tx_t = ug_info->bdRingLenTx[queue];
> +
> +		ug_info->bdRingLenRx[queue] = ring->rx_pending;
> +		ug_info->bdRingLenTx[queue] = ring->tx_pending;
> +
> +		printk(KERN_INFO "Reactivating interface %s.\n", netdev->name);
> +		ret = ucc_geth_open(netdev);
> +		if (ret) {
> +			printk(KERN_WARNING "uec_set_ringparam: set ring param for running"
> +					" interface %s failed. Please try to make the interface "
> +					" down, then try again.\n", netdev->name);
> +			ug_info->bdRingLenRx[queue] = rx_t;
> +			ug_info->bdRingLenTx[queue] = tx_t;
> +		}
[...]

Bringing the interface down will call ucc_geth_close(), which will try
to free resources that have not been allocated!

If you cannot roll back a failed change then at least use dev_close()
and dev_open() rather than calling ucc_geth_{close,open}() directly, so
that the interface state is updated correctly.  Or just refuse to make
the change if the interface is up.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

