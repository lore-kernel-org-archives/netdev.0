From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet addresses
Date: Thu, 19 Apr 2007 22:29:28 +0200
Message-ID: <4627D128.7060707@cosmosbay.com>
References: <20070418074439.1ba41718@localhost.localdomain>	<20070418.130422.88477383.davem@davemloft.net>	<20070419161423.a8f5c4f0.dada1@cosmosbay.com> <20070419.130101.91442981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, xemul@sw.ru,
	netdev@vger.kernel.org, bridge@lists.osdl.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35823 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767027AbXDSUaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:30:17 -0400
In-Reply-To: <20070419.130101.91442981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 19 Apr 2007 16:14:23 +0200
>=20
>> On Wed, 18 Apr 2007 13:04:22 -0700 (PDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> Although I don't think gcc does anything fancy since we don't
>>> use memcmp().  It's a tradeoff, we'd like to use unsigned long
>>> comparisons when both objects are aligned correctly but we also
>>> don't want it to use any more than one potentially mispredicted
>>> branch.
>> Again, memcmp() *cannot* be optimized, because its semantic is to co=
mpare bytes.
>>
>> memcpy() can take into account alignement if known at compile time, =
not memcmp()
>>
>> http://lists.openwall.net/netdev/2007/03/13/31
>=20
> I was prehaps thinking about strlen() where I know several
> implementations work a word at a time even though it is
> a byte-based operation:
>=20
> --------------------
> #define LO_MAGIC 0x01010101
> #define HI_MAGIC 0x80808080
>  ...
> 	 sethi	%hi(HI_MAGIC), %o4
>  ...
> 	 or	%o4, %lo(HI_MAGIC), %o3
>  ...
> 	 sethi	%hi(LO_MAGIC), %o4
>  ...
> 	 or	%o4, %lo(LO_MAGIC), %o2
>  ...
> 8:
> 	ld	[%o0], %o5
> 2:
> 	sub	%o5, %o2, %o4
> 	andcc	%o4, %o3, %g0
> 	be,pt	%icc, 8b
> 	 add	%o0, 4, %o0
> --------------------
>=20
> I figured some similar trick could be done with strcmp() and
> memcmp().
>=20
>=20

Hum, I was refering to IA64 (or the more spreaded x86 arches), that is =
litle=20
endian AFAIK.

On big endian machines, a compiler can indeed perform some word tricks =
for=20
memcmp() if it knows at compile time both pointers are word aligned.

PowerPc example (xlc compiler)

int func(const unsigned int *a, const unsigned int *b)
{
return memcmp(a, b, 6);
}

=2Efunc:                                  # 0x00000000 (H.10.NO_SYMBOL)
         l       r5,0(r3)
         l       r0,0(r4)
         cmp     0,r5,r0
         bc      BO_IF_NOT,CR0_EQ,__L2c
         lhz     r3,4(r3)
         lhz     r0,4(r4)
         sf      r0,r0,r3
         sfze    r3,r0
         a       r0,r3,r0
         aze     r3,r0
         bcr     BO_ALWAYS,CR0_LT
__L2c:                                  # 0x0000002c (H.10.NO_SYMBOL+0x=
2c)
         sf      r0,r0,r5
         sfze    r3,r0
         a       r0,r3,r0
         aze     r3,r0
         bcr     BO_ALWAYS,CR0_LT


But to compare 6 bytes, known to be aligned to even addresses, current =
code is=20
just fine and portable. We *could* use arch/endian specific tricks to s=
ave one=20
or two cycles, but who really wants that ?


