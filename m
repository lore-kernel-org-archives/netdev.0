From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Wed, 02 Mar 2011 12:03:15 +0100
Message-ID: <4D6E23F3.4010402@trash.net>
References: <20110221150710.GA5651@nord.niifaq.ru>	 <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru>	 <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>	 <4D6A6A5F.4030707@free.fr> <1298836236.8726.109.camel@edumazet-laptop>	 <4D6AB578.3010704@free.fr> <1298879114.8726.131.camel@edumazet-laptop> <4D6CF4A8.6000205@free.fr> <4D6D2402.6020705@trash.net> <4D6D515A.8060707@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64246 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169Ab1CBLDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 06:03:17 -0500
In-Reply-To: <4D6D515A.8060707@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.03.2011 21:04, schrieb Daniel Lezcano:
> On 03/01/2011 05:51 PM, Patrick McHardy wrote:
>>> Patrick, do you have any suggestions to fix this ?
>> Since the frames are only looped back locally, I suppose the easiest
>> fix would be to mark them with CHECKSUM_UNNECESSARY. Alternatively
>> we need to complete the checksum manually, similar to what
>> dev_hard_start_xmit() does.
> 
> That sounds very simple to fix, maybe too much simple :)
> 
> I did the following change:
> 
> --- linux-next.orig/drivers/net/macvlan.c
> +++ linux-next/drivers/net/macvlan.c
> @@ -222,6 +222,7 @@ static int macvlan_queue_xmit(struct sk_
> 
>         if (vlan->mode == MACVLAN_MODE_BRIDGE) {
>                 const struct ethhdr *eth = (void *)skb->data;
> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
> 
>                 /* send to other bridge ports directly */
>                 if (is_multicast_ether_addr(eth->h_dest)) {
> 
> 
> and that fixed the problem. Do you think it is acceptable ?

The only problem I see is if the packets are bridged to a
different networking device (or redirected using the mirred
action), in this case the checksum will not be completed.
This would be a very strange setup though and probably wouldn't
be using dummy as lower device, so I'm not sure we have to
worry about this case.
