From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v3)
Date: Wed, 20 Jan 2016 17:56:40 +0800
Message-ID: <569F59D8.2060200@gmail.com>
References: <1453267933-25381-1-git-send-email-wen.gang.wang@oracle.com>
 <569F2806.70608@gmail.com> <569F397B.7010808@oracle.com>
 <569F3D19.8020307@gmail.com> <569F579F.1060708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jay.vosburgh@canonical.com
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33551 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbcATJ4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 04:56:12 -0500
Received: by mail-pa0-f45.google.com with SMTP id cy9so2331595pac.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 01:56:12 -0800 (PST)
In-Reply-To: <569F579F.1060708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2016 05:47 PM, Wengang Wang wrote:
>
>
> =E5=9C=A8 2016=E5=B9=B401=E6=9C=8820=E6=97=A5 15:54, zhuyj =E5=86=99=E9=
=81=93:
>> On 01/20/2016 03:38 PM, Wengang Wang wrote:
>>>
>>>
>>> =E5=9C=A8 2016=E5=B9=B401=E6=9C=8820=E6=97=A5 14:24, zhuyj =E5=86=99=
=E9=81=93:
>>>> On 01/20/2016 01:32 PM, Wengang Wang wrote:
>>>>> In a bonding setting, we determines fragment size according to MT=
U=20
>>>>> and
>>>>> PMTU associated to the bonding master. If the slave finds the=20
>>>>> fragment
>>>>> size is too big, it drops the fragment and calls ip_rt_update_pmt=
u(),
>>>>> passing _skb_ and _pmtu_, trying to update the path MTU.
>>>>> Problem is that the target device that function ip_rt_update_pmtu=
=20
>>>>> actually
>>>>> tries to update is the slave (skb->dev), not the master. Thus=20
>>>>> since no
>>>>> PMTU change happens on master, the fragment size for later packet=
s=20
>>>>> doesn't
>>>>> change so all later fragments/packets are dropped too.
>>>>>
>>>>> The fix is letting build_skb_flow_key() take care of the=20
>>>>> transition of
>>>>> device index from bonding slave to the master. That makes the=20
>>>>> master become
>>>>> the target device that ip_rt_update_pmtu tries to update PMTU to.
>>>>>
>>>>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>>>>> ---
>>>>>   net/ipv4/route.c | 13 ++++++++++++-
>>>>>   1 file changed, 12 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>>>> index 85f184e..c59fb0d 100644
>>>>> --- a/net/ipv4/route.c
>>>>> +++ b/net/ipv4/route.c
>>>>> @@ -523,10 +523,21 @@ static void build_skb_flow_key(struct flowi=
4=20
>>>>> *fl4, const struct sk_buff *skb,
>>>>>                      const struct sock *sk)
>>>>>   {
>>>>>       const struct iphdr *iph =3D ip_hdr(skb);
>>>>> -    int oif =3D skb->dev->ifindex;
>>>>> +    struct net_device *master =3D NULL;
>>>>>       u8 tos =3D RT_TOS(iph->tos);
>>>>>       u8 prot =3D iph->protocol;
>>>>>       u32 mark =3D skb->mark;
>>>>> +    int oif;
>>>>> +
>>>>> +    if (skb->dev->flags & IFF_SLAVE) {
>>>>> +        rtnl_lock();
>>>>> +        master =3D netdev_master_upper_dev_get(skb->dev);
>>>>> +        rtnl_unlock();
>>>> update_pmtu is called very frequently. Is it appropriate to use=20
>>>> rtnl_lock here?
>>> By "very frequently", how frequently it is expected? And what=20
>>> situation can cause that?
>>> For my case, the update_pmtu is called only once.
>> ip_tunnel_xmit
>>
> Can you please explain with more details?

dev_queue_xmit->ipip_tunnel_xmit->ip_tunnel_xmit->tnl_update_pmtu->=20
skb_dst(skb)->ops->update_pmtu

>
> thanks,
> wengang
>
>
>> Zhu Yanjun
>>
>>>
>>> thanks,
>>> wengang
>>>
>>>> That is, rtnl_lock is called frequently. Maybe other functions hav=
e=20
>>>> little chance to call rtnl_lock.
>>>>
>>>> Best Regards!
>>>> Zhu Yanjun
>>>>> +    }
>>>>> +    if (master)
>>>>> +        oif =3D master->ifindex;
>>>>> +    else
>>>>> +        oif =3D skb->dev->ifindex;
>>>>>         __build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>>>>>   }
>>>>
>>>
>>
>
