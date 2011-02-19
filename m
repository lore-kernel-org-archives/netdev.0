From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 12:08:31 +0100
Message-ID: <20110219110830.GD2782@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
 <20110218205832.GE2602@psychotron.redhat.com>
 <21593.1298070371@death>
 <20110219080523.GB2782@psychotron.redhat.com>
 <4D5FA1D7.4050801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab1BSLIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 06:08:52 -0500
Content-Disposition: inline
In-Reply-To: <4D5FA1D7.4050801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 19, 2011 at 11:56:23AM CET, nicolas.2p.debian@gmail.com wrote:
>Le 19/02/2011 09:05, Jiri Pirko a =E9crit :
>>This patch converts bonding to use rx_handler. Results in cleaner
>>__netif_receive_skb() with much less exceptions needed. Also
>>bond-specific work is moved into bond code.
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>
>>v1->v2:
>>         using skb_iif instead of new input_dev to remember original
>>	device
>>v2->v3:
>>	set orig_dev =3D skb->dev if skb_iif is set
>>
>
>Why do we need to let the rx_handlers call netif_rx() or __netif_recei=
ve_skb()?
>
>Bonding used to be handled with very few overhead, simply replacing
>skb->dev with skb->dev->master. Time has passed and we eventually
>added many special processing for bonding into __netif_receive_skb(),
>but the overhead remained very light.
>
>Calling netif_rx() (or __netif_receive_skb()) to allow nesting would p=
robably lead to some overhead.
>
>Can't we, instead, loop inside __netif_receive_skb(), and deliver
>whatever need to be delivered, to whoever need, inside the loop ?
>
>rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>while (rx_handler) {
>	/* ...  */
>	orig_dev =3D skb->dev;
>	skb =3D rx_handler(skb);
>	/* ... */
>	rx_handler =3D (skb->dev !=3D orig_dev) ? rcu_dereference(skb->dev->r=
x_handler) : NULL;
>}
>
>This would reduce the overhead, while still allowing nesting: vlan on
>top on bonding, bridge on top on bonding, ...

I see your point. Makes sense to me. But the loop would have to include
at least processing of ptype_all too. I'm going to cook a follow-up
patch.

>
>That way, we can probably keep the list of crossed devices inside a
>local array, and call deliver_skb() with the current "orig_dev" when
>appropriate. No need to overload sk_buff nor to use a global
>variable.
>
>Of course, this might be a very simplistic view.
>
>Any comments?
>
>	Nicolas.
