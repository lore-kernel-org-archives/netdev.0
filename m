From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Tue, 04 Jul 2006 12:07:15 +0200
Message-ID: <44AA3DD3.1090106@trash.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:12466 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932183AbWGDKHR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 06:07:17 -0400
To: stefan@loplof.de
In-Reply-To: <200603211829.k2LITMNR029085@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> commit ddd7bf9fe4e59afc0a041378f82b6e1aa88f714b
> tree 98764adba1bae7d128d2e7db7d9fc1e2fe5826d8
> parent b00055aacdb172c05067612278ba27265fcd05ce
> author Stefan Rompf <stefan@loplof.de> Tue, 21 Mar 2006 09:11:41 -0800
> committer David S. Miller <davem@davemloft.net> Tue, 21 Mar 2006 09:11:41 -0800
> 
> [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index fa76220..3948949 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -69,7 +69,7 @@ static struct packet_type vlan_packet_ty
>  
>  /* Bits of netdev state that are propagated from real device to virtual */
>  #define VLAN_LINK_STATE_MASK \
> -	((1<<__LINK_STATE_PRESENT)|(1<<__LINK_STATE_NOCARRIER))
> +	((1<<__LINK_STATE_PRESENT)|(1<<__LINK_STATE_NOCARRIER)|(1<<__LINK_STATE_DORMANT))
>  
>  /* End of global variables definitions. */
>  
> @@ -450,7 +470,7 @@ static struct net_device *register_vlan_
>  	new_dev->flags = real_dev->flags;
>  	new_dev->flags &= ~IFF_UP;
>  
> -	new_dev->state = real_dev->state & VLAN_LINK_STATE_MASK;
> +	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
>  
>  	/* need 4 bytes for extra VLAN header info,
>  	 * hope the underlying device can handle it.

This introduced a regression by propagating the __LINK_STATE_XOFF flag,
when the queue of the underlying device is stopped it will be stopped
for the VLAN device too and never be woken up. Since you changed
VLAN_LINK_STATE_MASK, I assume the intention was to just add
__LINK_STATE_DORMANT to the propagated flags and keep using it here?

