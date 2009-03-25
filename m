From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports for
	bridging device
Date: Wed, 25 Mar 2009 16:43:53 +0800
Message-ID: <2a27d3730903250143u58a3c67dp132a8a5755d50d93@mail.gmail.com>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
	 <20090323085122.4c9d21f2@nehalam>
	 <20090323.152028.205335400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:1920 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbZCYInz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:43:55 -0400
Received: by wf-out-1314.google.com with SMTP id 29so3929698wff.4
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 01:43:53 -0700 (PDT)
In-Reply-To: <20090323.152028.205335400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 6:20 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 23 Mar 2009 08:51:22 -0700
>
>> That ensures big enough header for locally generated packets, but
>> any drivers that need bigger headroom still must handle bridged pack=
ets
>> that come in with smaller space. When bridging packets, the skb come=
s
>> from the allocation by the receiving driver. Almost all drivers will
>> use dev_alloc_skb() which will allocate NET_SKB_PAD (16) bytes of
>> additional headroom. This is used to hold copy of ethernet header fo=
r
>> the bridge/netfilter code.
>>
>> So your patch is fine as an optimization but a driver can not safely
>> depend on any additional headroom. The driver must check if there
>> is space, and if no space is available, reallocate and copy.
>
> We had some plans to deal with this kind of issue for wireless
> too. =C2=A0Let me see if I can find the RFC patch from that discussio=
n...
>
> Here it is, similar code would be added to the ipv4/ipv6 forwarding
> paths:
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7c1d446..6c06fba 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -600,6 +600,7 @@ struct net_device
> =C2=A0* Cache line mostly used on receive path (including eth_type_tr=
ans())
> =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 last_rx; =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Time of last Rx =C2=A0 =C2=
=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0rx_alloc_extra;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Interface address info used in eth_type=
_trans() */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 dev_addr[MAX_ADDR_LEN]; /* hw address, (before bcast
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0because most pac=
kets are unicast) */
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index bdd7c35..531e483 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -42,6 +42,22 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nf_bridge_=
maybe_copy_header(skb))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0kfree_skb(skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 unsigned int headroom =3D skb_headroom(skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 unsigned int hh_len =3D LL_RESERVED_SPACE(skb->dev);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (headroom < hh_len) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_device *in_dev;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int extra;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 in_dev =3D __dev_get_by_index(dev_n=
et(skb->dev),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->iif=
);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!in_dev);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 extra =3D hh_len - headroom;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (extra >=3D in_dev->rx_alloc_ext=
ra)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 in_dev-=
>rx_alloc_extra =3D extra;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0skb_push(skb, ETH_HLEN);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0dev_queue_xmit(skb);

Dynamically adjusting is a good idea, but the rx_alloc_extra can only
go up not the other way down in your code.  Another thought is that if
you re-allocate skb here the driver would be saved from checking the
headroom in the fastpath, am I right?

- Leo
