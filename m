From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] skb align patch
Date: Tue, 22 Sep 2009 05:20:53 +0200
Message-ID: <4AB84295.3050509@gmail.com>
References: <20090920142212.1106d2a1@s6510>	<4AB71980.4020208@gmail.com> <20090921213011.704e0594@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43379 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322AbZIVFUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:20:53 -0400
In-Reply-To: <20090921213011.704e0594@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Mon, 21 Sep 2009 08:13:20 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephen Hemminger a =C3=A9crit :
>>> Based on the Intel suggestion that PCI-express overhead is
>>> a significant cost.
>>>
>>> Would people doing performance please measure the impact of
>>> changing SKB alignment (64 bit only).
>> I had this idea some time ago when I hit a limit on bnx2 adapter
>> (Giga bit link, BCM5708S), with small packets. pktgen was able
>> to send ~500 Mbps 'only', or 700kps if I remember well.
>> So I tried to align the pktgen build packet to a cache line,
>> it gave no difference at all, but it was on a 32 bit kernel.
>> (Thus my patch was for pktgen only, not a generic one as yours)
>>
>> Could you elaborate why this change could be useful on 64bit ?
>>
>=20
> It is useful on all architecture where unaligned CPU access is
> relatively cheap.
>=20
> The issue is that a unaligned DMA requires a read/modify/write
> cache line access versus just a write access. I am not a bus
> expert, but writes are probably more pipelined as well.
>=20

Oh I see, you want to optimize the rx (NIC has to do a DMA
to write packet into host memory and this DMA could be a read
/modify/write if address is not aligned, instead of a pure write),
 while I tried to align skb to optimize the pktgen tx=20
(NIC has to do a DMA to  read packet from host), and align the skb
had no effect.

Maybe we should separate the rx/tx, and try your idea only
for skb allocated for rx.

Also/Or we might try=20
__builtin_prefetch (addr, 0, 0);
to instruct cpu to commit to memory cache lines that are
going to be modified by NIC.


