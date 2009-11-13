From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 09:28:45 +0800
Message-ID: <412e6f7f0911121728m76f76754jab8f4d9a0d360f6d@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFADF64.8070601@trash.net>
	 <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
	 <4AFC2563.1020902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:58838 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746AbZKMB2k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 20:28:40 -0500
Received: by pwi3 with SMTP id 3so1703567pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 17:28:45 -0800 (PST)
In-Reply-To: <4AFC2563.1020902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2009 at 11:10 PM, Patrick McHardy <kaber@trash.net> wro=
te:
> Changli Gao wrote:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 rcu_read_lock();
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->dev =3D dev_get_by_index_rcu(&init_net, skb->iif);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (!skb->dev) {
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_kfree_skb(skb);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 txq->tx_dropped++;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 rcu_read_unlock();
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 skb->iif =3D dev->ifindex;
>>> What protects the device from disappearing here and below during
>>> dev_queue_xmit() and netif_rx_ni()?
>>
>> For dev_queue_xmit(), dev is holded by skb->_dst, so there is no
>> problem. But for netif_rx_ni(), I don't know how to prevent the devi=
ce
>> disappearing, and it seems that all the NIC drivers have this proble=
m.
>> Maybe there was the assumption about the execution context of
>> netif_rx() before. Now softirq can't be executed by softirqd, so the
>> packet receiving path maybe interleaved. I don't know how to prevent
>> it happening.
>
> You can either take a reference of move the rcu_read_unlock()
> after the skb submission.

good idea!

>
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>>>> + =C2=A0 =C2=A0 case __constant_htons(ETH_P_IPV6):
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ip_proto =3D ipv6_hdr(=
skb)->nexthdr;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr1 =3D ipv6_hdr(skb=
)->saddr.s6_addr32[3];
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addr2 =3D ipv6_hdr(skb=
)->daddr.s6_addr32[3];
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ihl =3D 10;
>>> Where does 10 come from?
>>
>> It should be 40, after reviewing IPV6, I found that I need to loop
>> until finding the right protocol value.
>
> There is a helper for this (ipv6_skip_exthdr).
>

It is a little late. Thanks all the same, and I'll use it.

>>>> +static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[]=
,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *num_tx_queues,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0unsigned int *real_num_tx_queues)
>>>> +{
>>>> + =C2=A0 =C2=A0 if (tb[IFLA_NTXQ]) {
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *num_tx_queues =3D nla=
_get_u16(tb[IFLA_NTXQ]);
>>> We currently use unsigned ints for the queue number, so please
>>> use an u32 for the attribute as well.
>>>
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *real_num_tx_queues =3D=
 *num_tx_queues;
>>>> + =C2=A0 =C2=A0 } else {
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *num_tx_queues =3D num=
txqs;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *real_num_tx_queues =3D=
 numtxqs;
>>>> + =C2=A0 =C2=A0 }
>>>> +
>>>> + =C2=A0 =C2=A0 return 0;
>>>> +}
>>>> +
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*ndo_select_queue)(struct net_device *=
dev,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *skb);
>> use u16 as the return value so ..., and I think u16 is big enough. I=
f
>> you insist on this, I'll use u32 instead.
>
> Well, get_tx_queues() uses unsigned int, as does struct net_device.
> I agree that it probably won't ever be needed, but there's no harm
> in using the correct type, the attribute encoding doesn't even need
> more room.
>

So, in the last patch, I use it instead. :)

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
