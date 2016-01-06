From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key
Date: Wed, 6 Jan 2016 15:45:11 +0800
Message-ID: <568CC607.2040305@oracle.com>
References: <1452059368-7527-1-git-send-email-wen.gang.wang@oracle.com>
 <568CB1FD.4030907@gmail.com> <568CBCEA.20702@oracle.com>
 <568CC3B2.9020106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: zhuyj <zyjzyj2000@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26436 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFHlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 02:41:51 -0500
In-Reply-To: <568CC3B2.9020106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 15:35, zhuyj =E5=86=99=E9=
=81=93:
> IMHO, "The path MTU is set to the active slave device, not the bondin=
g=20
> master."
> Can we set PMTU to bonding master when path MTU is set to the active=20
> slave device?
>
Actually the route is set on bonding master, not on any slave, the=20
trying to set PMTU to the active slave failed(it didn't found a route o=
n=20
slave).
So "set PMTU to bonding master when path MTU is set to the active slave=
=20
device" is lacking a base.

thanks,
wengang

> If not appropriate, you can ignore it.
>
> Best Regards!
> Zhu Yanjun
>
> On 01/06/2016 03:06 PM, Wengang Wang wrote:
>> Hi Yanjun,
>>
>> Thanks for your review.
>> Master MTU is same as that for slaves.
>> Maybe fixing in bonding driver is a good idea, but I don't find a=20
>> good place to do that.
>> Let's go through the simplified follow:
>>
>> ...
>> 1) Fragmentation.
>>    --This is is done is against the bonding master device(device MTU=
=20
>> and path MTU)
>> 2) bond_start_xmit
>> 3) ipoib_start_xmit(slaves are IPoIB interfaces)
>>
>> For the first send
>> 1) fragment size is 7000(in my case)
>> 2) bond_start_xmit its self is fine
>> 3) ipoib_start_xmit sees the packet size 7000 is larger than the=20
>> internal limit 2044, drops the packet and try to update PMTU.
>>     without the patch, it tried update PMTU on slave device(no=20
>> changes to master).
>>
>> the seconds send comes, since no changes happen on bonding=20
>> master(PMTU), the fragment size is still 7000 and the behavior is=20
>> just the same as the first send.
>>
>> With the patch, the bonding master PMTU is changed to 2044 after the=
=20
>> first send(hopefully), for the seconds send the fragment size is set=
=20
>> to 2044.
>>
>> To fix in bonding code, I don't find where we can.
>>
>> thanks,
>> wengang
>>
>> =E5=9C=A8 2016=E5=B9=B401=E6=9C=8806=E6=97=A5 14:19, zhuyj =E5=86=99=
=E9=81=93:
>>>
>>> IMHO, this should fix in bonding driver because the active slave mt=
u=20
>>> should be the same with the master.
>>> bonding master's mtu is changed to path MTU, then slave dev's MTU=20
>>> should be changed, too.
>>>
>>> Zhu Yanjun
>>> On 01/06/2016 01:49 PM, Wengang Wang wrote:
>>>> A problem is found that we are looking for route basing a bonding=20
>>>> device and
>>>> deal with path MTU there: The path MTU is set to the active slave=20
>>>> device, not
>>>> the bonding master.
>>>>
>>>> The patch tries to fix the issue by letting build_skb_flow_key()=20
>>>> take care
>>>> of the transition of device index from bonding slave to the master=
=2E
>>>>
>>>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>>>> ---
>>>>   net/ipv4/route.c | 11 ++++++++++-
>>>>   1 file changed, 10 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>>> index 85f184e..3053f10 100644
>>>> --- a/net/ipv4/route.c
>>>> +++ b/net/ipv4/route.c
>>>> @@ -523,11 +523,20 @@ static void build_skb_flow_key(struct flowi4=
=20
>>>> *fl4, const struct sk_buff *skb,
>>>>                      const struct sock *sk)
>>>>   {
>>>>       const struct iphdr *iph =3D ip_hdr(skb);
>>>> -    int oif =3D skb->dev->ifindex;
>>>> +    int oif;
>>>> +    struct net_device *master =3D NULL;
>>>> +
>>>>       u8 tos =3D RT_TOS(iph->tos);
>>>>       u8 prot =3D iph->protocol;
>>>>       u32 mark =3D skb->mark;
>>>>   +    if (skb->dev->flags & IFF_SLAVE)
>>>> +        master =3D netdev_master_upper_dev_get(skb->dev);
>>>> +    if (master)
>>>> +        oif =3D master->ifindex;
>>>> +    else
>>>> +        oif =3D skb->dev->ifindex;
>>>> +
>>>>       __build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>>>>   }
>>>
>>
>
