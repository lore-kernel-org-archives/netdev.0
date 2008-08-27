From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Wed, 27 Aug 2008 21:09:57 +0400
Message-ID: <48B58A65.5060906@openvz.org>
References: <48B5815D.4010005@openvz.org> <Pine.LNX.4.64.0808271948000.4539@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33518 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbYH0RKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 13:10:05 -0400
In-Reply-To: <Pine.LNX.4.64.0808271948000.4539@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 27 Aug 2008, Pavel Emelyanov wrote:
>=20
>> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
>> macros into functions the net/ipv4/built-in.o shrank significantly:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
>>
>> Turning the CONFIG_NET_NS option on makes this shrink even larger:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
>=20
> Is there perhaps some DEBUG related config that could bloat these num=
bers?

Nope. I only had a DEBUG_BUG_VERBOSE turned on in my experiments.

> ...I didn't come up with anything obvious when I quickly looked the=20
> definations but I might have missed something.

Well, looking at NET_INC_STATS_BH as a function

000000a9 <NET_INC_STATS_BH>:
      a9:       8b 40 74                mov    0x74(%eax),%eax
      ac:       64 8b 0d 00 00 00 00    mov    %fs:0x0,%ecx
                        af: R_386_32    per_cpu__cpu_number
      b3:       f7 d0                   not    %eax
      b5:       8b 04 88                mov    (%eax,%ecx,4),%eax
      b8:       ff 04 90                incl   (%eax,%edx,4)
      bb:       c3                      ret

I guess that the heaviest thing there is smp_processor_id, which=20
is 7 bytes out of 19 total.

Actually the complete bloat-o-meter.sh output showed that there were=20
~10 functions, that became 8 bytes liter, ~10 that became 12-16 bytes
liter and so on. This makes me think, that the code in the macro
itself is pretty small, but is used widely in the networking code,
and this spread makes such a big bloat.

>> So the question is - what was the reason to keep those as macros?
>> I thought about the possible performance questions, but netperf
>> didn't show any (I admit I just cannot cook it properly).
>=20
> IMHO, even if there would be some performance regression, only the
> most hottest paths would need to have it inlined, the rest would be
> quite fine having it as a function.

OK, thanks Ilpo. I'll then look at how to make this more beautiful=20
and send to Dave.

> --
>  i.
>=20

