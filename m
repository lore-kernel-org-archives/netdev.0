From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Multicast packet loss
Date: Tue, 3 Feb 2009 20:21:44 -0500
Message-ID: <20090204012144.GC3650@localhost.localdomain>
References: <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com> <4987663D.6080802@cosmosbay.com> <4988803E.2020009@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40967 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110AbZBDBVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:21:47 -0500
Content-Disposition: inline
In-Reply-To: <4988803E.2020009@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 12:34:54PM -0500, Kenny Chang wrote:
> Eric Dumazet wrote:
>> Wes Chow a =E9crit :
>>  =20
>>> Eric Dumazet wrote:
>>>    =20
>>>> Wes Chow a =E9crit :
>>>>      =20
>>>>> (I'm Kenny's colleague, and I've been doing the kernel builds)
>>>>>
>>>>> First I'd like to note that there were a lot of bnx2 NAPI changes
>>>>> between 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amoun=
ts
>>>>> of packet loss,
>>>>> whereas loss in 2.6.22 is significant.
>>>>>
>>>>> Second, some CPU affinity info: if I do like Eric and pin all of =
the
>>>>> apps onto a single CPU, I see no packet loss. Also, I do *not* se=
e
>>>>> ksoftirqd show up on top at all!
>>>>>
>>>>> If I pin half the processes on one CPU and the other half on anot=
her
>>>>> CPU, one ksoftirqd processes shows up in top and completely pegs =
one
>>>>> CPU. My packet loss
>>>>> in that case is significant (25%).
>>>>>
>>>>> Now, the strange case: if I pin 3 processes to one CPU and 1 proc=
ess
>>>>> to another, I get about 25% packet loss and ksoftirqd pins one CP=
U.
>>>>> However, one
>>>>> of the apps takes significantly less CPU than the others, and all
>>>>> apps lose the
>>>>> *exact same number of packets*. In all other situations where we =
see
>>>>> packet
>>>>> loss, the actual number lost per application instance appears ran=
dom.
>>>>>        =20
>>>> You see same number of packet lost because they are lost at NIC le=
vel
>>>>      =20
>>> Understood.
>>>
>>> I have a new observation: if I pin processes to just CPUs 0 and 1, =
I see
>>> no packet loss. Pinning to 0 and 2, I do see packet loss. Pinning 2=
 and
>>> 3, no packet loss. 4 & 5 - no packet loss, 6 & 7 - no packet loss. =
Any
>>> other combination appears to produce loss (though I have not tried =
all
>>> 28 combinations, this seems to be the case).
>>>
>>> At first I thought maybe it had to do with processes pinned to the =
same
>>> CPU, but different cores. The machine is a dual quad core, which me=
ans
>>> that CPUs 0-3 should be a physical CPU, correct? Pinning to 0/2 and=
 0/3
>>> produce packet loss.
>>>    =20
>>
>> a quad core is really a 2 x 2 core
>>
>> L2 cache is splited on two blocks, one block used by CPU0/1, other b=
y=20
>> CPU2/3=20
>>
>> You are at the limit of the machine with such workload, so as soon a=
s your
>> CPUs have to transfert 64 bytes lines between those two L2 blocks, y=
ou loose.
>>
>>
>>  =20
>>> I've also noticed that it does not matter which of the working pair=
s I
>>> pin to. For example, pinning 5 processes in any combination on eith=
er
>>> 0/1 produce no packet loss, pinning all 5 to just CPU 0 also produc=
es no
>>> packet loss.
>>>
>>> The failures are also sudden. In all of the working cases mentioned
>>> above, I don't see ksoftirqd on top at all. But when I run 6 proces=
ses
>>> on a single CPU, ksoftirqd shoots up to 100% and I lose a huge numb=
er of
>>> packets.
>>>
>>>    =20
>>>> Normaly, softirq runs on same cpu (the one handling hard irq)
>>>>      =20
>>> What determines which CPU the hard irq occurs on?
>>>
>>>    =20
>>
>> Check /proc/irq/{irqnumber}/smp_affinity
>>
>> If you want IRQ16 only served by CPU0 :
>>
>> echo 1 >/proc/irq/16/smp_affinity
>>
>>  =20
> Hi everyone,
>
> First, thanks for all the effort so far, I think we've learned so muc=
h =20
> more about the problem in the last couple of days than we had previou=
sly =20
> in a month.
>
> Just to summarize where we are:
>
> * pinning processes to specific cores/CPUs alleviate the problem
> * issues exist from 2.6.22 up to 2.6.29-rc3
> * issue does not appear to be isolated to 64-bit, 32-bits have proble=
ms =20
> too.
> * I'm attaching an updated test program with the PR_SET_TIMERSTACK ca=
ll =20
> added.
> * on troubled machines, we are seeing high number of context switches=
 =20
> and interrupts.
> * we've ordered an Intel card to try in our machine to see if we can =
=20
> circumvent the issue with a different driver.
>
> Kernel Version         Has Problem?     Notes
> ----------             ----------       ----------
> 2.6.15.x                N    2.6.16.x                -
> 2.6.17.x                -               Doesn't build on Hardy
> 2.6.18.x                -               Doesn't boot (kernel panic)
> 2.6.19.7                N               ksoftirqd is up there, but no=
t =20
> pegging a CPU.
>                                        Takes roughly same amount of C=
PU =20
> as the other
>                                        processes, all of which are fr=
om =20
> 20-40%
> 2.6.20.21               N
> 2.6.21.7                N               sort of lopsided load, but no=
 =20
> load from
>                                        ksoftirqd -- strange
> 2.6.22.19               Y               First broken kernel
> 2.6.23.x                -
> 2.6.24-19               Y               (from Hardy)
> 2.6.25.x                -
> 2.6.26.x                -
> 2.6.27.x                Y               (from Intrepid)
> 2.6.28.1                Y
> 2.6.29-rc               Y
>
>
> Correct me if I'm wrong, from what we've seen, it looks like its =20
> pointing to some inefficiency in the softirq handling.  The question =
is =20
> whether it's something in the driver or the kernel.  If we can isolat=
e =20
> that, maybe we can take some action to have it fixed.
>
I don't think its sofirq ineffeciencies (oprofile would have shown that=
).  I
know I keep harping on this, but I still think irq affininty is your pr=
oblem.
I'd be interested in knowning what your /proc/interrupts file looked li=
ke on
each of the above kenrels.  Perhaps its not that the bnx2 card you have=
 can't
handle the setting of MSI interrupt affinities, but rather that somethi=
ng
changeed to break irq affinity on this card.

Neil

>

