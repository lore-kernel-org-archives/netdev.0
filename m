From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: rocker: Add basic netdev counters
Date: Wed, 14 Jan 2015 14:57:00 -0800
Message-ID: <54B6F43C.4030207@gmail.com>
References: <1421275161-99434-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33435 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbANW5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 17:57:07 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so13444696pab.2
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 14:57:07 -0800 (PST)
In-Reply-To: <1421275161-99434-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/15 14:39, David Ahern wrote:
> Add packet and byte counters for RX and TX paths.
> 
> $ ifconfig eth1
> eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>         inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
>         ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
>         RX packets 63  bytes 15813 (15.4 KiB)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 79  bytes 17991 (17.5 KiB)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 2f398fa4b9e6..9743279d9121 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3557,6 +3557,9 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (!desc_info)
>  		netif_stop_queue(dev);
>  
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;

Potential use after free, the skb pointer is certainly not valid anymore
here.

BTW, increasing statistics here is valid because this is a driver for a
virtual piece of HW, which does not have TX reclaim/completion logic,
but if it did, statistics update should occur there, not in the
ndo_start_xmit() function.

> +
>  	return NETDEV_TX_OK;
>  
>  unmap_frags:
> @@ -3565,6 +3568,8 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
>  	rocker_tlv_nest_cancel(desc_info, frags);
>  out:
>  	dev_kfree_skb(skb);
> +	dev->stats.tx_dropped++;
> +
>  	return NETDEV_TX_OK;
>  }
>  
> @@ -3890,6 +3895,9 @@ static int rocker_port_rx_proc(struct rocker *rocker,
>  	skb->protocol = eth_type_trans(skb, rocker_port->dev);
>  	netif_receive_skb(skb);
>  
> +	rocker_port->dev->stats.rx_packets++;
> +	rocker_port->dev->stats.rx_bytes += skb->len;

Same here, past netif_receive_skb() you should not assume that this skb
reference is valid.

> +
>  	return rocker_dma_rx_ring_skb_alloc(rocker, rocker_port, desc_info);
>  }
>  
> 


-- 
Florian
