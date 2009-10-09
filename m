From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 09 Oct 2009 03:07:56 +0200
Message-ID: <4ACE8CEC.3020905@gmail.com>
References: <4ACE023D.9030208@gmail.com> <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60448 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760157AbZJIBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 21:08:40 -0400
In-Reply-To: <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vegard Nossum a =C3=A9crit :
> Hm, no, this looks wrong to me, because sk_protocol and sk_type
> _aren't_ in fact part of the bitfield.

What looks wrong to me is the original commit :)

>=20
> We don't want to affect the kernel _at all_ when CONFIG_KMEMCHECK=3Dn=
,
> so I guess we should make the kmemcheck_bitfield_{begin|end}() macros
> empty instead for that case? (And for kmemcheck kernels, we don't
> really care about the lost 8 bytes anyway.)

Point is we should not lose 8 bytes with kmemcheck on or off.
I believe kmemcheck macros are fine as they are.

When we have a structure with

        unsigned char           sk_shutdown : 2,
                                sk_no_check : 2,
                                sk_userlocks : 4;
        unsigned char           sk_protocol;
        unsigned short          sk_type;

Its pretty clear its *logically* a bitfield aggregation, or if you pref=
er :

        unsigned int            sk_shutdown : 2,
                                sk_no_check : 2,
                                sk_userlocks : 4,
                                sk_protocol : 8,
                                sk_type : 16;

Only difference is that in the second form, you cannot use
offsetof(struct sock, sk_type)

I am currently writing a tool to re-organize 'struct sock' fields,
for net-next-2.6 using offsetof() macro, this is how I spot the problem=
=2E

Thanks
