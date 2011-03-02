From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in handle_frame
Date: Thu, 3 Mar 2011 00:13:23 +0800
Message-ID: <AANLkTikvJ3n0mSabakpBOiLJZd55ZJUGz7wM2wm0th5C@mail.gmail.com>
References: <20110301062250.GB2855@psychotron.redhat.com> <20110301092907.GG2855@psychotron.redhat.com>
 <AANLkTimk_jyTYO8=8LRgY3C1un38qb1q9C-DbKWHirPS@mail.gmail.com> <4D6D52F1.6020407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Herbert Xu <herbert@gondor.apana.org.au>
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42345 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063Ab1CBQPy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 11:15:54 -0500
Received: by fxm17 with SMTP id 17so136608fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 08:15:52 -0800 (PST)
In-Reply-To: <4D6D52F1.6020407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2011 at 4:11 AM, Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> wrote:
> Le 01/03/2011 16:12, Changli Gao a =E9crit :
>>
>> On Tue, Mar 1, 2011 at 5:29 PM, Jiri Pirko<jpirko@redhat.com> =A0wro=
te:
>>>
>>> Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>>>
>>> Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in
>>> handle_frame
>>>
>>> No need to do share check here.
>>>
>>
>> I don't think so. Although you avoid netif_rx(), you can't avoid
>> ptype_all handlers. In fact, all the RX handlers should has this
>> check(), if they may modify the skb.
>
> Can you please develop your explanation?
>
> In current __netif_receive_skb() (after the recent patch from Jiri), =
we
> deliver the skb to ptype_all handlers inside a loop, while possibly c=
hanging
> skb->dev inside this loop.
>
> Then, at the end of __netif_receive_skb(), we loop on ptype_base, wit=
hout
> changing anything in skb.
>
> Should we consider ptype_*->func() to be called in a pure sequential =
way?
> Should we consider that when a ptype_*->func() returns, nothing from =
this
> handler will use the skb in anyway later, in a parallel way?
>
> Or should we, instead, consider that special precautions must be take=
n,
> because protocol handlers may run in parallel for the same skb? Which=
 kind
> of precautions?
>

If the packets gotten by __netif_receive_skb() are unshared, the skb
gotten by bond should be unshared, as we call prev_pt before calling
bond. I don't see there is any  relationship with the previous patch
from Jiri. The bridge is in the same condition with bond here, and it
checks if the skb is shared or not. Does it imply that dev->rx_handler
may see shared skbs?

BTW: bond may change skb and packet data. But before change the packet
data, it doesn't check if the packet data is shared or not.

1519         if (bond_dev->priv_flags & IFF_MASTER_ALB &&
1520             bond_dev->priv_flags & IFF_BRIDGE_PORT &&
1521             skb->pkt_type =3D=3D PACKET_HOST) {
1522                 u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;

skb_cow_head() should be added, otherwise the previous ptype handler
may get the unexpected dset MAC address.

1523
1524                 memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
1525         }

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
