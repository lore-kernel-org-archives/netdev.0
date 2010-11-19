From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 17:55:59 +0100
Message-ID: <1290185759.3034.179.camel@edumazet-laptop>
References: <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
	 <1290160467.3034.33.camel@edumazet-laptop>
	 <1290165472.3034.109.camel@edumazet-laptop>
	 <20101119.082125.193710226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, netdev@vger.kernel.org, xiaosuo@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58946 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab0KSQ4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 11:56:04 -0500
Received: by wwa36 with SMTP id 36so4843850wwa.1
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 08:56:03 -0800 (PST)
In-Reply-To: <20101119.082125.193710226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 08:21 -0800, David Miller a =C3=A9c=
rit :

> -EFIX_THE_DAMN_COMPILER
>=20
> We never make calls out of this function or touch volatile memory or
> create a full memory barrier between the assignment of f_k and it's
> uses.
>=20
> Therefore if common sub-expression elimination is working the compile=
r
> will be able to decide properly whether to access things via memory o=
r
> use a register for the value.
>=20
> Remember this is why we have that ACCESS_ONCE() thing.
>=20
> We can't have it both ways, either ACCESS_ONCE() should be removed or
> we should never make changes like your's and instead should submit
> compiler bug reports :-)

Compiler is OK IMHO in this case. It does exactly what is required.

Compiler cannot load fentry->k before the switch() if some expression
dont use it, as it could trigger a fault.

After the "f_k =3D fentry->k;" commit, it was requested to do so.

Unfortunatly on x86_32 it also chose that f_k was more valuable in a cp=
u
register and accumulator A lost its register to get a stack slot
instead.

Not many BPF instructions use K, and if used, its used _once_ per BPF
instruction. There is no real gain to put it on a register, but code
size if (and only if) it is held in a cpu register, because each
assembler instruction using a register instead of stack is a bit
shorter.

In the end, I believe the "f_k =3D fentry->k;" was a good looking idea,
and good for some arches, but we forgot x86_32 (and probably some other=
s)
have few available registers to play with.

Have a good week end !



