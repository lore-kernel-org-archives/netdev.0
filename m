From: Michal Simek <monstr@monstr.eu>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 14:26:56 +0200
Message-ID: <4DAD7F90.5000704@monstr.eu>
References: <4DAD5753.4040108@monstr.eu> <1303209787.3480.9.camel@edumazet-laptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47099 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab1DSM07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 08:26:59 -0400
Received: by bwz15 with SMTP id 15so4478780bwz.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 05:26:58 -0700 (PDT)
In-Reply-To: <1303209787.3480.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 19 avril 2011 =C3=A0 11:35 +0200, Michal Simek a =C3=A9crit =
:
>> Hi,
>>
>> I would like to try to add NAPI support for ll_temac and look if hel=
p us to=20
>> improve performance on Microblaze system. I would expect that bandwi=
dth should=20
>> be increased.
>> We have the second non mainline driver which use tasklets and it pro=
vides better=20
>>   performance than mainline driver but not so big that's why I think=
 that NAPI=20
>> can increase performance.
>>
>> Can you please point me to any driver which I could use as a templat=
e?
>> Or any developer guide to do so.
>>
>> Do you know any other option how to improve driver performance on lo=
w speed cpu?
>>
>> I have found that driver spends a lot of time on skb allocation and =
preallocated=20
>> SKBs help a little bit. I have done a test where I increased number =
of=20
>> preallocated BDs(SKBs) for rx to 35000 and disable new BD(SKB) alloc=
ation in=20
>> rx_irq. 35000 BDs is setup because I need them to successfully finis=
h netperf=20
>> test. I have got 25% bandwidth increasing.
>>
>> It will be also nice to be able to allocate several BDs(SKBs) which =
could be=20
>> faster than allocate them in sequence.
>=20
> Depends if your cpu has some cache. The best performance is to try to
> get high cache hit ratios.

Yes it has icache and dcache (write-back or write-through).


>=20
> One possible way to get better performance is to change driver to
> allocate skbs only right before calling netif_rx(), so that you dont
> have to access cold sk_buff data twice (once when allocating skb and =
put
> it in ring buffer, a second time when receiving frame)

ok. But I need to allocate BD for dma with pointer to skb where dma sho=
uld copy=20
data to. I could do it in irq but I would have to wait till dma copy da=
ta from=20
ethernet controller to memory. I haven't measure how slow/fast is that =
copying.

>=20
> drivers/net/niu.c is a good example for this (NAPI + netdev_alloc_skb=
()
> just in time + pull in skbhead only first cache line of packet)
>=20
> drivers/net/ftmac100.c is also a recent driver (and probably a better
> start with less complex hardware than NIU) using these tricks
>=20
> { skb =3D netdev_alloc_skb_ip_align(netdev, 128);
>  __pskb_pull_tail(skb, min(length, 64));=20
> }

I have change rx for napi but need to debug it a little bit. It works f=
or some=20
packets but I am not able to run any test right now.

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
