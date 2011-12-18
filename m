From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sun, 18 Dec 2011 17:26:47 +0400
Message-ID: <4EEDEA17.4040006@mvista.com>
References: <4EED3A3D.9080503@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
To: Joshua Kinard <kumba@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64762 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab1LRN1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 08:27:49 -0500
Received: by werm1 with SMTP id m1so857957wer.19
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2011 05:27:48 -0800 (PST)
In-Reply-To: <4EED3A3D.9080503@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-12-2011 4:56, Joshua Kinard wrote:

> SGI IP32 (O2)'s ethernet driver (meth) lacks a set_rx_mode function, which
> prevents IPv6 from working completely because any ICMPv6 neighbor
> solicitation requests aren't picked up by the driver.  So the machine can
> ping out and connect to other systems, but other systems will have a very
> hard time connecting to the O2.

> Signed-off-by: Joshua Kinard<kumba@gentoo.org>
> ---

    Some minor nits below...

>   drivers/net/ethernet/sgi/meth.c |   60 +++++++++++++++++++++++++++++++++++-----
>   1 file changed, 53 insertions(+), 7 deletions(-)

> --- a/drivers/net/ethernet/sgi/meth.c	2011-12-17 15:51:44.569166824 -0500
> +++ b/drivers/net/ethernet/sgi/meth.c	2011-12-17 15:51:20.259167050 -0500
[...]
> @@ -57,6 +58,12 @@ static const char *meth_str="SGI O2 Fast
>   static int timeout = TX_TIMEOUT;
>   module_param(timeout, int, 0);
>
> +/* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
> + * MACE Ethernet uses a 64 element hash table based on the Ethernet CRC.
> + */
> +static int multicast_filter_limit = 32;
> +
> +

    On empty oine would be enough...

>   /*
>    * This structure is private to each device. It is used to pass
>    * packets in and out, so there is place for a packet
> @@ -765,15 +775,51 @@ static int meth_ioctl(struct net_device
>   	}
>   }
>
> +static void meth_set_rx_mode(struct net_device *dev)
> +{
> +	struct meth_private *priv = netdev_priv(dev);
> +	unsigned long flags;
> +
> +	netif_stop_queue(dev);
> +	spin_lock_irqsave(&priv->meth_lock, flags);
> +	priv->mac_ctrl&= ~(METH_PROMISC);

    Parens not needed here.

> +
> +	if (dev->flags & IFF_PROMISC) {
> +		priv->mac_ctrl |= METH_PROMISC;
> +		priv->mcast_filter = 0xffffffffffffffffUL;
> +		mace->eth.mac_ctrl = priv->mac_ctrl;
> +		mace->eth.mcast_filter = priv->mcast_filter;
> +	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
> +			   (dev->flags & IFF_ALLMULTI)) {
> +			priv->mac_ctrl |= METH_ACCEPT_AMCAST;
> +			priv->mcast_filter = 0xffffffffffffffffUL;
> +			mace->eth.mac_ctrl = priv->mac_ctrl;
> +			mace->eth.mcast_filter = priv->mcast_filter;

     This block is over-indented.

> +	} else {
> +		struct netdev_hw_addr *ha;
> +		priv->mac_ctrl |= METH_ACCEPT_MCAST;
> +
> +		netdev_for_each_mc_addr(ha, dev)
> +			set_bit((ether_crc(ETH_ALEN, ha->addr) >> 26),
> +				    (volatile long unsigned int *)&priv->mcast_filter);
> +
> +		mace->eth.mcast_filter = priv->mcast_filter;

    This last statement is common between all branches, so could be moved out 
of *if*...

> +	}
> +
> +	spin_unlock_irqrestore(&priv->meth_lock, flags);
> +	netif_wake_queue(dev);
> +}
> +
>   static const struct net_device_ops meth_netdev_ops = {
> -	.ndo_open		= meth_open,
> -	.ndo_stop		= meth_release,
> -	.ndo_start_xmit		= meth_tx,
> -	.ndo_do_ioctl		= meth_ioctl,
> -	.ndo_tx_timeout		= meth_tx_timeout,
> -	.ndo_change_mtu		= eth_change_mtu,
> -	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_open				= meth_open,
> +	.ndo_stop				= meth_release,
> +	.ndo_start_xmit			= meth_tx,
> +	.ndo_do_ioctl			= meth_ioctl,
> +	.ndo_tx_timeout			= meth_tx_timeout,
> +	.ndo_change_mtu			= eth_change_mtu,
> +	.ndo_validate_addr		= eth_validate_addr,
>   	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_set_rx_mode    	= meth_set_rx_mode,

    The intializer values are not aligned now, and they were before the patch.

WBR, Sergei
