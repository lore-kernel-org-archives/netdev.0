From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 09:52:00 -0800 (PST)
Message-ID: <20101119.095200.59681766.davem@davemloft.net>
References: <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
	<1290172607.3034.124.camel@edumazet-laptop>
	<AANLkTimiMRL+DM+XzxLoK_zdHv_KGhbxyBRCazStpZ6c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, hagen@jauu.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755318Ab0KSRvf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 12:51:35 -0500
In-Reply-To: <AANLkTimiMRL+DM+XzxLoK_zdHv_KGhbxyBRCazStpZ6c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Nov 2010 22:13:07 +0800

> On Fri, Nov 19, 2010 at 9:16 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
>>
>> Remove pc variable to avoid arithmetic to compute fentry at each fil=
ter
>> instruction. Jumps directly manipulate fentry pointer.
>>
>> As the last instruction of filter[] is guaranteed to be a RETURN, an=
d
>> all jumps are before the last instruction, we dont need to check fil=
ter
>> bounds (number of instructions in filter array) at each iteration, s=
o we
>> remove it from sk_run_filter() params.
>>
>> On x86_32 remove f_k var introduced in commit 57fe93b374a6b871
>> (filter: make sure filters dont read uninitialized memory)
>>
>> Note : We could use a CONFIG_ARCH_HAS_{FEW|MANY}_REGISTERS in order =
to
>> avoid too many ifdefs in this code.
>>
>> This helps compiler to use cpu registers to hold fentry and A
>> accumulator.
>>
>> On x86_32, this saves 401 bytes, and more important, sk_run_filter()
>> runs much faster because less register pressure (One less conditiona=
l
>> branch per BPF instruction)
>>
>> # size net/core/filter.o net/core/filter_pre.o
>> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
>> =A0 2948 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A02948 =A0 =A0 b84 net/cor=
e/filter.o
>> =A0 3349 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A03349 =A0 =A0 d15 net/cor=
e/filter_pre.o
>>
>> on x86_64 :
>> # size net/core/filter.o net/core/filter_pre.o
>> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
>> =A0 5173 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A05173 =A0 =A01435 net/cor=
e/filter.o
>> =A0 5224 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A05224 =A0 =A01468 net/cor=
e/filter_pre.o
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Changli Gao <xiaosuo@gmail.com>
>> Cc: Hagen Paul Pfeifer <hagen@jauu.net>
>=20
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Ok, I'm applying this to net-next-2.6 for now.  It keeps the
"f_k" situation optimal for all cases, on every platform I've
taken a look at the asm output (sparc64, x86-32, x86-64).

I can't currently think of a way to get rid of that ifdef,
so for now it's a small price to pay to get this optimal.

Thanks Eric!
