From: Kenny Chang <kchang@athenacr.com>
Subject: Re: Multicast packet loss
Date: Thu, 26 Feb 2009 12:15:37 -0500
Message-ID: <49A6CE39.5050200@athenacr.com>
References: <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org> <loom.20090202T194942-55@post.gmane.org> <498757AA.8010101@cosmosbay.com> <4987610D.6040902@athenacr.com> <4987663D.6080802@cosmosbay.com> <4988803E.2020009@athenacr.com> <20090204012144.GC3650@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1029 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755423AbZBZRPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 12:15:45 -0500
Received: from [192.168.14.21] (fiji.em.in.athenacr.com [192.168.14.21])
	by sprinkles.inp.in.athenacr.com (Postfix) with ESMTP id A900DEE98C
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 12:15:39 -0500 (EST)
In-Reply-To: <20090204012144.GC3650@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Tue, Feb 03, 2009 at 12:34:54PM -0500, Kenny Chang wrote:
>> Eric Dumazet wrote:
>>> Wes Chow a =E9crit :
>>>  =20
>>>> Eric Dumazet wrote:
>>>>    =20
>>>>> Wes Chow a =E9crit :
>>>>>      =20
>>>>>> (I'm Kenny's colleague, and I've been doing the kernel builds)
>>>>>>
>>>>>> First I'd like to note that there were a lot of bnx2 NAPI change=
s
>>>>>> between 2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amou=
nts
>>>>>> of packet loss,
>>>>>> whereas loss in 2.6.22 is significant.
>>>>>>
>>>>>> Second, some CPU affinity info: if I do like Eric and pin all of=
 the
>>>>>> apps onto a single CPU, I see no packet loss. Also, I do *not* s=
ee
>>>>>> ksoftirqd show up on top at all!
>>>>>>
>>>>>> If I pin half the processes on one CPU and the other half on ano=
ther
>>>>>> CPU, one ksoftirqd processes shows up in top and completely pegs=
 one
>>>>>> CPU. My packet loss
>>>>>> in that case is significant (25%).
>>>>>>
>>>>>> Now, the strange case: if I pin 3 processes to one CPU and 1 pro=
cess
>>>>>> to another, I get about 25% packet loss and ksoftirqd pins one C=
PU.
>>>>>> However, one
>>>>>> of the apps takes significantly less CPU than the others, and al=
l
>>>>>> apps lose the
>>>>>> *exact same number of packets*. In all other situations where we=
 see
>>>>>> packet
>>>>>> loss, the actual number lost per application instance appears ra=
ndom.
>>>>>>        =20
>>>>> You see same number of packet lost because they are lost at NIC l=
evel
>>>>>      =20
>>>> Understood.
>>>>
>>>> I have a new observation: if I pin processes to just CPUs 0 and 1,=
 I see
>>>> no packet loss. Pinning to 0 and 2, I do see packet loss. Pinning =
2 and
>>>> 3, no packet loss. 4 & 5 - no packet loss, 6 & 7 - no packet loss.=
 Any
>>>> other combination appears to produce loss (though I have not tried=
 all
>>>> 28 combinations, this seems to be the case).
>>>>
>>>> At first I thought maybe it had to do with processes pinned to the=
 same
>>>> CPU, but different cores. The machine is a dual quad core, which m=
eans
>>>> that CPUs 0-3 should be a physical CPU, correct? Pinning to 0/2 an=
d 0/3
>>>> produce packet loss.
>>>>    =20
>>> a quad core is really a 2 x 2 core
>>>
>>> L2 cache is splited on two blocks, one block used by CPU0/1, other =
by=20
>>> CPU2/3=20
>>>
>>> You are at the limit of the machine with such workload, so as soon =
as your
>>> CPUs have to transfert 64 bytes lines between those two L2 blocks, =
you loose.
>>>
>>>
>>>  =20
>>>> I've also noticed that it does not matter which of the working pai=
rs I
>>>> pin to. For example, pinning 5 processes in any combination on eit=
her
>>>> 0/1 produce no packet loss, pinning all 5 to just CPU 0 also produ=
ces no
>>>> packet loss.
>>>>
>>>> The failures are also sudden. In all of the working cases mentione=
d
>>>> above, I don't see ksoftirqd on top at all. But when I run 6 proce=
sses
>>>> on a single CPU, ksoftirqd shoots up to 100% and I lose a huge num=
ber of
>>>> packets.
>>>>
>>>>    =20
>>>>> Normaly, softirq runs on same cpu (the one handling hard irq)
>>>>>      =20
>>>> What determines which CPU the hard irq occurs on?
>>>>
>>>>    =20
>>> Check /proc/irq/{irqnumber}/smp_affinity
>>>
>>> If you want IRQ16 only served by CPU0 :
>>>
>>> echo 1 >/proc/irq/16/smp_affinity
>>>
>>>  =20
>> Hi everyone,
>>
>> -snip-
>> Correct me if I'm wrong, from what we've seen, it looks like its =20
>> pointing to some inefficiency in the softirq handling.  The question=
 is =20
>> whether it's something in the driver or the kernel.  If we can isola=
te =20
>> that, maybe we can take some action to have it fixed.
>>
> I don't think its sofirq ineffeciencies (oprofile would have shown th=
at).  I
> know I keep harping on this, but I still think irq affininty is your =
problem.
> I'd be interested in knowning what your /proc/interrupts file looked =
like on
> each of the above kenrels.  Perhaps its not that the bnx2 card you ha=
ve can't
> handle the setting of MSI interrupt affinities, but rather that somet=
hing
> changeed to break irq affinity on this card.
>
> Neil
>
>
It's been a while since I updated this thread.  We've been running=20
through the different suggestions and tabulating their effects, as well=
=20
as trying out an Intel card.  The short story is that setting affinity=20
and MSI works to some extent, and the Intel card doesn't seem to change=
=20
things significantly.  The results don't seem consistent enough for us=20
to be able to point to a smoking gun.

It does look like the 2.6.29-rc4 kernel performs okay with the Intel=20
card, but this is not a real-time build and it's not likely to be in a=20
supported Ubuntu distribution real soon.  We've reached the point where=
=20
we'd like to look for an expert dedicated to work on this problem for a=
=20
period of time.  The final result being some sort of solution to produc=
e=20
a realtime configuration with a reasonably "aged" kernel (.24~.28) that=
=20
has multicast performance greater than or equal to that of 2.6.15.

If anybody is interested in devoting some compensated time to this=20
issue, we're offering up a bounty:=20
http://www.athenacr.com/bounties/multicast-performance/

=46or completeness, here's the table of our experiment results:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Kernel                 flavor             IRQ       affinity   *4x=20
mcasttest*  *5x mcasttest* *6x mcasttest*  *Mtools2* [4]_=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=
=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Intel=20
e1000e                                                                 =
                                                =20

-----------------------------------------+---------+----------+--------=
-------+--------------+--------------+-----------------
2.6.24.19              rt                |          any       |=20
OK              Maybe          X                            =20
2.6.24.19              rt                |          CPU0      |=20
OK              OK             X                            =20
2.6.24.19              generic           |          any       |=20
X                                                           =20
2.6.24.19              generic           |          CPU0      |=20
OK                                                          =20
2.6.29-rc3             vanilla-server    |          any       |=20
X                                                           =20
2.6.29-rc3             vanilla-server    |          CPU0      |=20
OK                                                          =20
2.6.29-rc4             vanilla-generic   |          any       |=20
X                                             OK            =20
2.6.29-rc4             vanilla-generic   |          CPU0      | OK  =20
           OK             OK [5]_        OK            =20
-----------------------------------------+---------+----------+--------=
-------+--------------+--------------+-----------------
Broadcom=20
BNX2                                                                   =
                                             =20

-----------------------------------------+---------+----------+--------=
-------+--------------+--------------+-----------------
2.6.24-19              rt                | MSI      any       |=20
OK              OK             X                            =20
2.6.24-19              rt                | MSI      CPU0      |=20
OK              Maybe          X                            =20
2.6.24-19              rt                | APIC     any       |=20
OK              OK             X                            =20
2.6.24-19              rt                | APIC     CPU0      |=20
OK              Maybe          X                            =20
2.6.24-19-bnx-latest   rt                | APIC     CPU0      |=20
OK              X                                           =20
2.6.24-19              server            | MSI      any       |=20
X                                                           =20
2.6.24-19              server            | MSI      CPU0      |=20
OK                                                          =20
2.6.24-19              generic           | APIC     any       |=20
X                                                           =20
2.6.24-19              generic           | APIC     CPU0      |=20
OK                                                          =20
2.6.27-11              generic           | APIC     any       |=20
X                                                           =20
2.6.27-11              generic           | APIC     CPU0      |=20
OK              10% drop                                     =20
2.6.28-8               generic           | APIC     any       |=20
OK              X                                            =20
2.6.28-8               generic           | APIC     CPU0      |=20
OK              OK             0.5% drop                     =20
2.6.29-rc3             vanilla-server    | MSI      any       |=20
X                                                           =20
2.6.29-rc3             vanilla-server    | MSI      CPU0      |=20
X                                                           =20
2.6.29-rc3             vanilla-server    | APIC     any       |=20
OK              X                                           =20
2.6.29-rc3             vanilla-server    | APIC     CPU0      |=20
OK              OK                                          =20
2.6.29-rc4             vanilla-generic   | APIC     any       |=20
X                                                           =20
2.6.29-rc4             vanilla-generic   | APIC     CPU0      |=20
OK              3% drop        10% drop       X             =20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=
=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
* [4] MTools2 is a test from 29West: http://www.29west.com/docs/TestNet=
/
* [5] In 5 trials, 1 of the trials dropped 2%, 4 of the trials dropped=20
nothing.

Kenny

