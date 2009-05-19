From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate	counters
 for bps
Date: Tue, 19 May 2009 09:31:36 +0200
Message-ID: <4A126058.7030605@cosmosbay.com>
References: <20090516141430.GB3013@ami.dom.local> <4A118F98.60101@cosmosbay.com> <20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net> <4A11F67B.3050805@cosmosbay.com> <20090519070252.GA4210@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vexwek@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58087 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbZESHbo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 03:31:44 -0400
In-Reply-To: <20090519070252.GA4210@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Tue, May 19, 2009 at 01:59:55AM +0200, Eric Dumazet wrote:
> ...
>> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> ...
>> -		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
>> +		e->avbps +=3D ((s64)(brate - e->avbps)) >> e->ewma_log;
>=20
> Btw., I'm a bit concerned about the syntax here: isn't such shifting
> of signed ints implementation dependant?
>=20

You are right Jarek, I very often forget to never ever use signed quant=
ities
at all ! (But also note original code has same undefined behavior)


Quoting wikipedia : (http://en.wikipedia.org/wiki/Arithmetic_shift)

The (1999) ISO standard for the, C programming language defines the C l=
anguage's=20
right shift operator in terms of divisions by powers of 2. Because of t=
he=20
aforementioned non-equivalence, the standard explicitly excludes from t=
hat
 definition the right shifts of signed numbers that have negative value=
s.
 It doesn't specify the behaviour of the right shift operator in such c=
ircumstances,
 but instead requires each individual C compiler to specify the behavio=
ur of shifting=20
negative values right.

Apparently gcc does the *right* thing on x86_32, but we probably want s=
omething
stronger here. I could not find gcc documentation statement on right sh=
ifts of=20
negative values.


 436:   8b 4b 14                mov    0x14(%ebx),%ecx
 439:   89 73 18                mov    %esi,0x18(%ebx)
 43c:   89 7b 1c                mov    %edi,0x1c(%ebx)
 43f:   8b 73 20                mov    0x20(%ebx),%esi
 442:   8b 7b 24                mov    0x24(%ebx),%edi
 445:   29 f0                   sub    %esi,%eax
 447:   19 fa                   sbb    %edi,%edx
 449:   0f ad d0                shrd   %cl,%edx,%eax
 44c:   d3 fa                   sar    %cl,%edx         << good >>
 44e:   f6 c1 20                test   $0x20,%cl
 451:   74 05                   je     458 <est_timer+0xb8>
 453:   89 d0                   mov    %edx,%eax
 455:   c1 fa 1f                sar    $0x1f,%edx      =20
 458:   01 f0                   add    %esi,%eax
 45a:   8b 4b 0c                mov    0xc(%ebx),%ecx
 45d:   89 43 20                mov    %eax,0x20(%ebx)
 460:   11 fa                   adc    %edi,%edx
 462:   83 c0 0f                add    $0xf,%eax
 465:   89 53 24                mov    %edx,0x24(%ebx)
 468:   83 d2 00                adc    $0x0,%edx
 46b:   0f ac d0 05             shrd   $0x5,%edx,%eax
 46f:   89 01                   mov    %eax,(%ecx)

