From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 11:56:23 +0100
Message-ID: <4D5FA1D7.4050801@gmail.com>
References: <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com> <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47238 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab1BSK4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 05:56:32 -0500
Received: by fxm17 with SMTP id 17so39395fxm.19
        for <netdev@vger.kernel.org>; Sat, 19 Feb 2011 02:56:31 -0800 (PST)
In-Reply-To: <20110219080523.GB2782@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/02/2011 09:05, Jiri Pirko a =E9crit :
> This patch converts bonding to use rx_handler. Results in cleaner
> __netif_receive_skb() with much less exceptions needed. Also
> bond-specific work is moved into bond code.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
> v1->v2:
>          using skb_iif instead of new input_dev to remember original
> 	device
> v2->v3:
> 	set orig_dev =3D skb->dev if skb_iif is set
>

Why do we need to let the rx_handlers call netif_rx() or __netif_receiv=
e_skb()?

Bonding used to be handled with very few overhead, simply replacing skb=
->dev with skb->dev->master.=20
Time has passed and we eventually added many special processing for bon=
ding into=20
__netif_receive_skb(), but the overhead remained very light.

Calling netif_rx() (or __netif_receive_skb()) to allow nesting would pr=
obably lead to some overhead.

Can't we, instead, loop inside __netif_receive_skb(), and deliver whate=
ver need to be delivered, to=20
whoever need, inside the loop ?

rx_handler =3D rcu_dereference(skb->dev->rx_handler);
while (rx_handler) {
	/* ...  */
	orig_dev =3D skb->dev;
	skb =3D rx_handler(skb);
	/* ... */
	rx_handler =3D (skb->dev !=3D orig_dev) ? rcu_dereference(skb->dev->rx=
_handler) : NULL;
}

This would reduce the overhead, while still allowing nesting: vlan on t=
op on bonding, bridge on top=20
on bonding, ...

That way, we can probably keep the list of crossed devices inside a loc=
al array, and call=20
deliver_skb() with the current "orig_dev" when appropriate. No need to =
overload sk_buff nor to use a=20
global variable.

Of course, this might be a very simplistic view.

Any comments?

	Nicolas.
