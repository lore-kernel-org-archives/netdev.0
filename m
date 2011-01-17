From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Mon, 17 Jan 2011 23:47:21 +0000
Message-ID: <1295308041.6264.22.camel@bwh-desktop>
References: <1295307669.3362.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27961 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1AQXrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 18:47:24 -0500
In-Reply-To: <1295307669.3362.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 00:41 +0100, Eric Dumazet wrote:
> Oh well, my dev machine, with bnx2 and tg3 NICs, isnt working at all
> with current linux-2.6 tree (I need vlans on my setup)
> 
> tg3 : vlan not working
> 
> bnx2 : vlan + TSO not working (or very slowly, since only non GSO frames
> are OK)
> 
> I suspect recent commits from Jesse are the problem.
> (bnx2_xmit() is feeded with zeroed vlan_tci skbs)
> 
> Maybe f01a5236bd4b1401 (net offloading: Generalize
> netif_get_vlan_features().) ?
> 
> I dont see NETIF_F_HW_VLAN_TX being set in vlan_features in net drivers.
> They only set this flag in dev->features
> 
> I dont think changing all drivers to also set vlan_features makes sense.
> 
> Is following patch the right path ? (It does solve my problem)

This isn't right.  NETIF_F_HW_VLAN_TX in vlan_features would mean that
the hardware can do two levels of VLAN tag insertion, which is generally
not true.

Ben.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 54277df..5c13e55 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5265,6 +5265,9 @@ int register_netdevice(struct net_device *dev)
>  	 */
>  	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
>  
> +	/* allow netif_skb_features() not mask this bit from dev->features */
> +	dev->vlan_features |= NETIF_F_HW_VLAN_TX;
> +
>  	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
>  	ret = notifier_to_errno(ret);
>  	if (ret)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

