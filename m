From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 12:27:57 +0200
Message-ID: <1273228077.2261.61.camel@edumazet-laptop>
References: <20100506.220221.90798296.davem@davemloft.net>
	 <1273209321.2222.36.camel@edumazet-laptop>	<4BE3C70C.4060705@monstr.eu>
	 <20100507.013216.133893678.davem@davemloft.net> <4BE3E1D6.30907@monstr.eu>
	 <1273226114.2261.42.camel@edumazet-laptop> <4BE3E6F5.5050601@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com,
	microblaze-uclinux@itee.uq.edu.au
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44409 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab0EGK2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 06:28:02 -0400
Received: by bwz19 with SMTP id 19so481953bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 03:28:01 -0700 (PDT)
In-Reply-To: <4BE3E6F5.5050601@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 12:09 +0200, Michal Simek a =C3=A9crit :
> Eric Dumazet wrote:
> > Le vendredi 07 mai 2010 =C3=A0 11:48 +0200, Michal Simek a =C3=A9cr=
it :
> >> David Miller wrote:
> >>> From: Michal Simek <monstr@monstr.eu>
> >>> Date: Fri, 07 May 2010 09:53:48 +0200
> >>>
> >>>> I will add this Microblaze patch to my repo for testing and anyw=
ay
> >>>> should go through my repo.
> >>> It's already in the net-next-2.6 tree.
> >> Anyway.
> >>
> >> I am ok with removing NET_IP_ALIGN because it is already defined i=
n=20
> >> skbuff.h to 2.
> >> But increasing NET_SKB_PAD to 64 caused that Microblaze extends sk=
b=20
> >> buffers for some bytes.
> >> I measured it by iperf and netperf and I see regression around 1-2=
Mbit/s=20
> >> that's why I would like to ask you to revert this patch or keep at=
 least=20
> >> NET_SKB_PAD part.
> >=20
> > Interesting.
> >=20
> > Increasing NET_SKB_PAD to say 128 or 256 should not have performanc=
e
> > impact, but reserve a bit more ram. (truesize...)
>=20
> yes. Microblaze is very sensitive on it. I have spent a couple of day=
s=20
> to find out why bandwidth is so bad and I found that truesize is the=20
> problem. Whole driver allocated skb buffer to max mtu size (9000).
>=20
> But if mtu is 1500 the driver still worked with max skb buffers size
> Please correct me if I am wrong but if truesize is setup to 9000 then=
=20
> net code is working with that size even if mtu is 1500.
> The next thing is that cache operations take a lot of cpu cycles.

Allocating space <before> data doesnt mean we touch it. In fact we dont=
,
this is why I said increasing SKB_PAD from 32 to 64 should not make a
difference on perfs.

But yes, udp/tcp pacing is sensitive to truesize, since truesize is use=
d
to limit socket receive buffer (bytes limit, not packets)

If you hit socket limit (or global limit), tcp will try to coalesce
buffers to reduce the 'truesize'. This involves very expensive
operations. UDP dont have such slow path, but might drop frames one
socket limit is reached.

So David patch (or mine if you prefer) only points an underlying proble=
m
(truesize changed from 9056 to 9088, a very small increase...)

Using 9000 bytes buffers is very risky in the long term (if PAGE_SIZE i=
s
4096), because after a while, your driver wont be able to allocate new
skbs.

>=20
> I create a patch which allocated aligned skb buffers where size depen=
ds=20
> on current mtu size and this change rapidly increase bandwidth for=20
> mtu=3D1500 from 8Mb/s to 35Mb/s (depends on setting). There is no=20
> difference if jumbo frames are used (I means for driver with/without =
my=20
> patch).
>=20
> >=20
> > Investigation is needed. Maybe your NIC now allocates high order pa=
ges ?
> >=20
> > What driver are you using ?
> >=20
>=20
> I am using non-mainline ll_temac driver.
> drivers/net/xilinx_lltemac/
>=20
> http://developer.petalogix.com/git/gitweb.cgi?p=3Dlinux-2.6-microblaz=
e.git;a=3Dshortlog
>=20
> Regards,
> Michal
>=20
>=20
>=20
>=20


