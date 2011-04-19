From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 12:43:07 +0200
Message-ID: <1303209787.3480.9.camel@edumazet-laptop>
References: <4DAD5753.4040108@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37088 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423Ab1DSKnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 06:43:12 -0400
Received: by wya21 with SMTP id 21so4683148wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 03:43:11 -0700 (PDT)
In-Reply-To: <4DAD5753.4040108@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 11:35 +0200, Michal Simek a =C3=A9crit :
> Hi,
>=20
> I would like to try to add NAPI support for ll_temac and look if help=
 us to=20
> improve performance on Microblaze system. I would expect that bandwid=
th should=20
> be increased.
> We have the second non mainline driver which use tasklets and it prov=
ides better=20
>   performance than mainline driver but not so big that's why I think =
that NAPI=20
> can increase performance.
>=20
> Can you please point me to any driver which I could use as a template=
?
> Or any developer guide to do so.
>=20
> Do you know any other option how to improve driver performance on low=
 speed cpu?
>=20
> I have found that driver spends a lot of time on skb allocation and p=
reallocated=20
> SKBs help a little bit. I have done a test where I increased number o=
f=20
> preallocated BDs(SKBs) for rx to 35000 and disable new BD(SKB) alloca=
tion in=20
> rx_irq. 35000 BDs is setup because I need them to successfully finish=
 netperf=20
> test. I have got 25% bandwidth increasing.
>=20
> It will be also nice to be able to allocate several BDs(SKBs) which c=
ould be=20
> faster than allocate them in sequence.

Depends if your cpu has some cache. The best performance is to try to
get high cache hit ratios.

One possible way to get better performance is to change driver to
allocate skbs only right before calling netif_rx(), so that you dont
have to access cold sk_buff data twice (once when allocating skb and pu=
t
it in ring buffer, a second time when receiving frame)

drivers/net/niu.c is a good example for this (NAPI + netdev_alloc_skb()
just in time + pull in skbhead only first cache line of packet)

drivers/net/ftmac100.c is also a recent driver (and probably a better
start with less complex hardware than NIU) using these tricks

{ skb =3D netdev_alloc_skb_ip_align(netdev, 128);
 __pskb_pull_tail(skb, min(length, 64));=20
}


