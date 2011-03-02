From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Wed, 02 Mar 2011 22:05:11 +0100
Message-ID: <4D6EB107.1060907@gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com> <AANLkTimk_jyTYO8=8LRgY3C1un38qb1q9C-DbKWHirPS@mail.gmail.com> <4D6D52F1.6020407@gmail.com> <AANLkTikvJ3n0mSabakpBOiLJZd55ZJUGz7wM2wm0th5C@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Herbert Xu <herbert@gondor.apana.org.au>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab1CBVFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 16:05:15 -0500
Received: by wyg36 with SMTP id 36so430968wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 13:05:14 -0800 (PST)
In-Reply-To: <AANLkTikvJ3n0mSabakpBOiLJZd55ZJUGz7wM2wm0th5C@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/03/2011 17:13, Changli Gao a =E9crit :
> On Wed, Mar 2, 2011 at 4:11 AM, Nicolas de Peslo=FCan
> <nicolas.2p.debian@gmail.com>  wrote:
>> Le 01/03/2011 16:12, Changli Gao a =E9crit :
>>> I don't think so. Although you avoid netif_rx(), you can't avoid
>>> ptype_all handlers. In fact, all the RX handlers should has this
>>> check(), if they may modify the skb.
>>
>> Can you please develop your explanation?
>>
>> In current __netif_receive_skb() (after the recent patch from Jiri),=
 we
>> deliver the skb to ptype_all handlers inside a loop, while possibly =
changing
>> skb->dev inside this loop.
>>
>> Then, at the end of __netif_receive_skb(), we loop on ptype_base, wi=
thout
>> changing anything in skb.
>>
>> Should we consider ptype_*->func() to be called in a pure sequential=
 way?
>> Should we consider that when a ptype_*->func() returns, nothing from=
 this
>> handler will use the skb in anyway later, in a parallel way?
>>
>> Or should we, instead, consider that special precautions must be tak=
en,
>> because protocol handlers may run in parallel for the same skb? Whic=
h kind
>> of precautions?
>>
>
> If the packets gotten by __netif_receive_skb() are unshared, the skb
> gotten by bond should be unshared, as we call prev_pt before calling
> bond. I don't see there is any  relationship with the previous patch
> from Jiri. The bridge is in the same condition with bond here, and it
> checks if the skb is shared or not. Does it imply that dev->rx_handle=
r
> may see shared skbs?

Thanks for you explanations.

My question is not strictly linked to bonding, but more general to __ne=
tif_receive_skb().

Jiri's patch added a "goto another_round" if the rx_handler changed skb=
->dev. (The idea was from=20
me). The ptype_all list_foreach_entry_rcu delivery loop is between "ano=
ther_round:" and "goto=20
another_round", so some ptype_all handlers will receive an skb where sk=
b->dev will have changed.

I wonder whether this might cause any troubles and if yes, what should =
be done to fix it.

And depending on the answer, I wonder whether we can move the ptype_bas=
e loop to the same place as=20
the ptype_all loop. This would allow for a better handling of orig_dev,=
 I think.

	Nicolas.
