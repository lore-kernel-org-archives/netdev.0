From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 6 Jan 2016 15:35:14 +0800
Message-ID: <568CC3B2.9020106@gmail.com>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
 <568CB1FD.4030907@gmail.com> <568CBCEA.20702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36620 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbcAFHfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 02:35:21 -0500
Received: by mail-pa0-f45.google.com with SMTP id yy13so136647885pab.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 23:35:20 -0800 (PST)
In-Reply-To: <568CBCEA.20702@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IMHO, "The path MTU is set to the active slave device, not the bonding=20
master."
Can we set PMTU to bonding master when path MTU is set to the active=20
slave device?

If not appropriate, you can ignore it.

Best Regards!
Zhu Yanjun

On 01/06/2016 03:06 PM, Wengang Wang wrote:
> Hi Yanjun,
>
> Thanks for your review.
> Master MTU is same as that for slaves.
> Maybe fixing in bonding driver is a good idea, but I don't find a goo=
d=20
> place to do that.
> Let's go through the simplified follow:
>
> ...
> 1) Fragmentation.
>    --This is is done is against the bonding master device(device MTU=20
> and path MTU)
> 2) bond_start_xmit
> 3) ipoib_start_xmit(slaves are IPoIB interfaces)
>
> For the first send
> 1) fragment size is 7000(in my case)
> 2) bond_start_xmit its self is fine
> 3) ipoib_start_xmit sees the packet size 7000 is larger than the=20
> internal limit 2044, drops the packet and try to update PMTU.
>     without the patch, it tried update PMTU on slave device(no change=
s=20
> to master).
>
> the seconds send comes, since no changes happen on bonding=20
> master(PMTU), the fragment size is still 7000 and the behavior is jus=
t=20
> the same as the first send.
>
> With the patch, the bonding master PMTU is changed to 2044 after the=20
> first send(hopefully), for the seconds send the fragment size is set=20
> to 2044.
>
> To fix in bonding code, I don't find where we can.
>
> thanks,
> wengang
>
> =E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 14:19, zhuyj =E5=86=99=E9=
=81=93:
>>
>> IMHO, this should fix in bonding driver because the active slave mtu=
=20
>> should be the same with the master.
>> bonding master's mtu is changed to path MTU, then slave dev's MTU=20
>> should be changed, too.
>>
>> Zhu Yanjun
>> On 01/06/2016 01:49 PM, Wengang Wang wrote:
>>> A problem is found that we are looking for route basing a bonding=20
>>> device and
>>> deal with path MTU there: The path MTU is set to the active slave=20
>>> device, not
>>> the bonding master.
>>>
>>> The patch tries to fix the issue by letting build_skb_flow_key()=20
>>> take care
>>> of the transition of device index from bonding slave to the master.
>>>
>>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>>> ---
>>>   net/ipv4/route.c | 11 ++++++++++-
>>>   1 file changed, 10 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>> index 85f184e..3053f10 100644
>>> --- a/net/ipv4/route.c
>>> +++ b/net/ipv4/route.c
>>> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4=20
>>> *fl4, const struct sk_buff *skb,
>>>                      const struct sock *sk)
>>>   {
>>>       const struct iphdr *iph =3D ip_hdr(skb);
>>> -    int oif =3D skb->dev->ifindex;
>>> +    int oif;
>>> +    struct net_device *master =3D NULL;
>>> +
>>>       u8 tos =3D RT_TOS(iph->tos);
>>>       u8 prot =3D iph->protocol;
>>>       u32 mark =3D skb->mark;
>>>   +    if (skb->dev->flags & IFF_SLAVE)
>>> +        master =3D netdev_master_upper_dev_get(skb->dev);
>>> +    if (master)
>>> +        oif =3D master->ifindex;
>>> +    else
>>> +        oif =3D skb->dev->ifindex;
>>> +
>>>       __build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>>>   }
>>
>
