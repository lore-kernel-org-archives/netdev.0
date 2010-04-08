From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Thu, 8 Apr 2010 09:37:28 +0800
Message-ID: <z2h412e6f7f1004071837s88d1cd87yc7667f607dd33b5@mail.gmail.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	<j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>
	<1270193393.1936.52.camel@edumazet-laptop> <4BB622F6.10606@hp.com>
	<g2i65634d661004021045uff7c0e25ge7dfd17929bc9ee9@mail.gmail.com>
	<4BB6367D.9090600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63607 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757547Ab0DHBhv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 21:37:51 -0400
Received: by gyg13 with SMTP id 13so891284gyg.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 18:37:48 -0700 (PDT)
In-Reply-To: <4BB6367D.9090600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 3, 2010 at 2:25 AM, Rick Jones <rick.jones2@hp.com> wrote:
> Tom Herbert wrote:
>> =C2=A0 =C2=A0The progression in HP-UX was IPS (10.20) (aka RPS) then=
 TOPS (11.0)
>> =C2=A0 =C2=A0(aka RFS). We found that IPS was great for
>> =C2=A0 =C2=A0single-flow-per-thread-of-execution stuff and that TOPS=
 was better
>> =C2=A0 =C2=A0for multiple-flow-per-thread-of-execution stuff. =C2=A0=
It was long enough
>> =C2=A0 =C2=A0ago now that I can safely say for one system-level benc=
hmark not
>> =C2=A0 =C2=A0known to be a "networking" benchmark, and without a mas=
sive kernel
>> =C2=A0 =C2=A0component, TOPS was a 10% win. =C2=A0Not too shabby.
>>
>> =C2=A0 =C2=A0It wasn't that IPS wasn't good in its context - just th=
at TOPS was
>> =C2=A0 =C2=A0even better.
>>
>> I would assume that with IPS threads would migrate to where packets =
were
>> being delivered thus giving the same sort of locality TOPS was provi=
ding?
>> =C2=A0That would work great without any other constraints (multiple =
flows per
>> thread, thread CPU bindings, etc.).
>
> Well... that depended - at the time, and still, we were and are also
> encouraging users and app designers to make copious use of
> processor/locality affinity (SMP and NUMA going back far longer in th=
e RISC
> et al space than the x86 space). =C2=A0So, it was and is entirely pos=
sible that
> the application thread of execution is hard-bound to a specific
> core/locality. =C2=A0Also, I do not recall if HP-UX was as aggressive=
 about
> waking a process/thread on the processor from which the wake-up came =
vs on
> the processor on which it last ran.
>

Maybe RPS should be work against process not processor. For packets
forwarding, the process is net_rx softirq.

>> =C2=A0 =C2=A0We also preferred the concept of the scheduler giving n=
etworking
>> =C2=A0 =C2=A0clues as to where to process an application's packets r=
ather than
>> =C2=A0 =C2=A0networking trying to tell the scheduler. =C2=A0There wa=
s some discussion
>> =C2=A0 =C2=A0of out of order worries, but we were willing to trust t=
o the basic
>> =C2=A0 =C2=A0soundness of the scheduler - if it was moving threads a=
round willy
>> =C2=A0 =C2=A0nilly at a rate able to cause big packet reordering it =
had
>> =C2=A0 =C2=A0fundamental problems that would have to be addressed an=
yway.
>>
>>
>> I also think scheduler leading networking, like in RPS, =C2=A0is gen=
erally more
>> scalable. =C2=A0As for OOO packets, I've spent way to much time tryi=
ng to
>> convince the bean-counters that a small number of them aren't proble=
matic
>> :-), in the end it's just easier to not introduce new mechanisms tha=
t will
>> cause them!
>
> So long as it doesn't drive you to produce new mechanisms heavier tha=
n they
> would have otherwise been.
>
> The irony in the case of HP-UX IPS was that it was put in place in re=
sponse
> to the severe out of order packet problems in HP-UX in 10.X before 10=
=2E20 -
> there were multiple netisr processes and only one netisr queue. =C2=A0=
The other
> little tweak that came along in 10.20 with IPS, was inaddition to hav=
ing a
> per processor (well, per core in today's parlance) netisr queue, the =
netisr
> would grab the entire queue under the one spinlock and work off of th=
at.
> =C2=A0That was nice because the code path became more efficient under=
 load - more
> packets processed per spinlock/unlock pair.
>

RPS dispatches packets among all the CPUs permitted fairly, in order
to take full advantage of all the CPU power. The assumption is the cpu
cycles each CPU gives to packet processing are the same. But it isn't
always true as scheduler is mixed in. In this case, scheduler leading
network is a good choice. Maybe we should make softirq threaded under
the control of scheduler. And the number of softirq threads can be
specified by users. By default, the number of the softirq threads are
the same as the number of CPUs, and each thread binds to a special
CPU, to keep the current behavior. If the other tasks aren't
dispatched among the CPUs even, system administrator may increase the
number of softirq thread, and dissolve the thread binding, then there
will be enough schedulable softirq threads for scheduler scheduling.
Oh, maybe there is no need of weighted packets dispatching RPS.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
