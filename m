From: Cong Wang <amwang@redhat.com>
Subject: Re: [Bonding-devel] [v3 Patch 2/3] bridge: make bridge support netpoll
Date: Tue, 13 Apr 2010 16:57:56 +0800
Message-ID: <4BC43214.6030009@redhat.com>
References: <20100408062234.4499.17042.sendpatchset@localhost.localdomain>	<20100408062246.4499.5670.sendpatchset@localhost.localdomain>	<20100408083710.2b61ee44@nehalam>	<4BC2F7E2.7020309@redhat.com>	<1271068737.16881.18.camel@edumazet-laptop> <20100412083842.26d71bda@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jeff Moyer <jmoyer@redhat.com>,
	Andy Gospodarek <gospo@redhat.com>,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567Ab0DMIzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 04:55:38 -0400
In-Reply-To: <20100412083842.26d71bda@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 12 Apr 2010 12:38:57 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le lundi 12 avril 2010 =C3=A0 18:37 +0800, Cong Wang a =C3=A9crit :
>>> Stephen Hemminger wrote:
>>>> There is no protection on dev->priv_flags for SMP access.
>>>> It would better bit value in dev->state if you are using it as con=
trol flag.
>>>>
>>>> Then you could use=20
>>>> 			if (unlikely(test_and_clear_bit(__IN_NETPOLL, &skb->dev->state)=
))
>>>> 				netpoll_send_skb(...)
>>>>
>>>>
>>> Hmm, I think we can't use ->state here, it is not for this kind of =
purpose,
>>> according to its comments.
>>>
>>> Also, I find other usages of IFF_XXX flags of ->priv_flags are also=
 using
>>> &, | to set or clear the flags. So there must be some other things =
preventing
>>> the race...
>> Yes, its RTNL that protects priv_flags changes, hopefully...
>>
>=20
> The patch was not protecting priv_flags with RTNL.
> For example..
>=20
>=20
> @@ -308,7 +312,9 @@ static void netpoll_send_skb(struct netp
>  		     tries > 0; --tries) {
>  			if (__netif_tx_trylock(txq)) {
>  				if (!netif_tx_queue_stopped(txq)) {
> +					dev->priv_flags |=3D IFF_IN_NETPOLL;
>  					status =3D ops->ndo_start_xmit(skb, dev);
> +					dev->priv_flags &=3D ~IFF_IN_NETPOLL;
>  					if (status =3D=3D NETDEV_TX_OK)
>  						txq_trans_update(txq);

Hmm, but I checked the bonding case (IFF_BONDING), it doesn't
hold rtnl_lock. Strange.

