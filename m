From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: receive-side performance issue (ixgbe, core-i7, softirq cpu%)
Date: Fri, 29 Jan 2010 00:02:19 -0800
Message-ID: <606676311001290002n60e58a4bp778dea6df7ae08ab@mail.gmail.com>
References: <606676311001280023j77b8b96aj556706f3e49bcc13@mail.gmail.com>
	 <alpine.WNT.2.00.1001281135110.360@jbrandeb-desk1.amr.corp.intel.com>
	 <606676311001282206q113f6bbbq776996b67fd18adb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f189.google.com ([209.85.222.189]:40451 "EHLO
	mail-pz0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab0A2ICW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 03:02:22 -0500
Received: by pzk27 with SMTP id 27so1308682pzk.33
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 00:02:20 -0800 (PST)
In-Reply-To: <606676311001282206q113f6bbbq776996b67fd18adb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I might have mis-spoken about HPET.

The 4.6Mpps is with 2.6.32.4 vanilla, HPET on.

Either way, I'm happy now ;-P

-A

On Thu, Jan 28, 2010 at 10:06 PM, Andrew Dickinson <andrew@whydna.net> =
wrote:
> Short response: CONFIG_HPET was the dirty little bastard!
>
> Answering your questions below in case somebody else stumbles across
> this thread...
>
> On Thu, Jan 28, 2010 at 4:18 PM, Brandeburg, Jesse
> <jesse.brandeburg@intel.com> wrote:
>>
>>
>> On Thu, 28 Jan 2010, Andrew Dickinson wrote:
>>> I'm running into some unexpected performance issues. =A0I say
>>> "unexpected" because I was running the same tests on this same box =
5
>>> months ago and getting very different (and much better) results.
>>
>>
>> can you try turning off cpuspeed service, C-States in BIOS, and GV3 =
(aka
>> speedstep) support in BIOS?
>
> Yup, everything's on "maximum performance" in my BIOS's vernacular (H=
P
> GL360g6) no C-states, etc.
>
>> Have you upgraded your BIOS since before?
>
> Not that I'm aware of, but our provisioning folks might have done
> something crazy.
>
>> I agree you should be able to see better numbers, I suspect that you=
 are
>> getting cross-cpu traffic that is limiting your throughput.
>
> That's what I would have suspected as well.
>
>> How many flows are you pushing?
>
> I'm pushing two streams of traffic, one in each direction. =A0Each
> stream is defined as follows:
> =A0 =A0North-bound:
> =A0 =A0 =A0 =A0L2: a0a0a0a0a0a0 -> b0b0b0b0b0b0
> =A0 =A0 =A0 =A0L3: RAND(10.0.0.0/16) -> RAND(100.0.0.0/16)
> =A0 =A0 =A0 =A0L4: UDP with random data
> =A0 =A0South-bound is the reverse.
>
> =A0 =A0where "RAND(CIDR)" is a random address within that CIDR (I'm u=
sing
> an hardware traffic generator).
>
>> Another idea is to compile the "perf" tool in the tools/perf directo=
ry of
>> the kernel and run "perf record -a -- sleep 10" while running at ste=
ady
>> state. =A0then show output of perf report to get an idea of which fu=
nctions
>> are eating all the cpu time.
>>
>> did you change to the "tickless" kernel? =A0We've also found that ro=
uting
>> performance improves dramatically by disabling tickless, preemptive =
kernel
>> and setting HZ=3D100. =A0What about CONFIG_HPET?
>
> yes, yes, yes, and no...
>
> changed CONFIG_HPET to n, rebooted and retested....
>
> ta-da!
>
>> You should try the kernel that the scheduler fixes went into (maybe =
31?)
>> or at least try 2.6.32.6 so you've tried something fully up to date.
>
> I'll give it a whirl :D
>
>>> =3D=3D=3D Background =3D=3D=3D
>>>
>>> The box is a dual Core i7 box with a pair of Intel 82598EB's. =A0I'=
m
>>> running 2.6.30 with the in-kernel ixgbe driver. =A0My tests 5 month=
s ago
>>> were using 2.6.30-rc3 (with a tiny patch from David Miller as seen
>>> here: http://kerneltrap.org/mailarchive/linux-netdev/2009/4/30/5605=
924).
>>> =A0The box is configured with both NICs in a bridge; normally I'm d=
oing
>>> some packet processing using ebtables, but for the sake of keeping
>>> things simple, I'm not doing anything special.. just straight bridg=
ing
>>> (no ebtables rules, etc). =A0I'm not running irqbalance and instead
>>> pinning my interrupts, one per core. =A0I've re-read and double che=
cked
>>> various settings based on Intel's README (i.e. gso off, tso off, et=
c).
>>>
>>> In my previous tests, i was able to pass 3+Mpps regardless of how t=
hat
>>> was divided across the two NICS (i.e. 3Mpps all in one direction,
>>> 1.5Mpps in each direction simultaneously, etc). =A0Now, I'm hardly =
able
>>> to exceed about 750kpps x 2 (i.e. 750k in both directions), and I
>>> can't do more than 750kpps in one direction even with the other
>>> direction having no traffic).
>>>
>>> Unfortunately, I didn't take very good notes when I did this last t=
ime
>>> so I don't have my previous .config and I'm not 100% positive I've =
got
>>> identical ethtool settings, etc. =A0That being said, I've worked th=
rough
>>> seemingly every combination of factors that I can think of and I'm
>>> still unable to see the old performance (NUMA on/off, Hyperthreadin=
g
>>> on/off, various irq coelescing settings, etc).
>>>
>>> I have two identical boxes, they both see the same thing; so a
>>> hardware issue seems unlikely. =A0My next step is to grab 2.6.30-rc=
3 and
>>> see if I can repro the good performance with that kernel again and
>>> determine if there was a regression between 2.6.30-rc3 and 2.6.30..=
=2E
>>> but I'm skeptical that that's the issue since I'm sure other people
>>> would have noticed this as well.
>>>
>>>
>>> =3D=3D=3D What I'm seeing =3D=3D=3D
>>>
>>> CPU% (almost entirely softirq time, which is expected) ramps extrem=
ely
>>> quickly as packet rate increases. =A0The following table show the p=
acket
>>> rate ("150 x 2" means 150kpps in each direction simultaneously), th=
e
>>> right side is the cpu utilization (as measured by %si in top).
>>>
>>> 150 x 2: =A0 4%
>>> 300 x 2: =A0 8%
>>> 450 x 2: =A018%
>>> 483 x 2: =A050%
>>> 525 x 2: =A066%
>>> 600 x 2: =A085%
>>> 750 x 2: 100% (and dropping frames)
>>>
>>> I _am_ seeing interrupts getting spread nicely across cores, so in =
the
>>> "150 x 2" case, that's about 4% soft-interrupt time per each of the=
 16
>>> cores. =A0 The CPUs are otherwise idle bar a small amount of hardwa=
re
>>> interrupt time (less than 1%).
>>>
>>>
>>> =3D=3D=3D Where it gets weird... =3D=3D=3D
>>>
>>> Trying to isolate the problem, I added an ebtables rule to drop
>>> everything on the forward chain. =A0I was expecting to see the CPU
>>> utilization drop since I'd no longer be dealing with the TX-side...=
 no
>>> change.
>>>
>>> I then decided to switch from a bridge to a route-based solution. =A0=
I
>>> tore down the bridge, enabled ip_forward, setup some IPs and route
>>> entries, etc. =A0Nothing changes. =A0CPU performance is identical t=
o
>>> what's shown above. =A0Additionally, if I add an iptables drop on
>>> FORWARD, the CPU utilization remains unchanged (just like in the
>>> bridging case above).
>>>
>>> The point that [I think] I'm driving to is that there's something
>>> fishy going on with the receive-side of the packets. =A0I wish I co=
uld
>>> point to something more specific or a section of code, but I haven'=
t
>>> been able to par this down to anything more granular in my testing.
>>>
>>>
>>> =3D=3D=3D Questions =3D=3D=3D
>>>
>>> Has anybody seen this before? =A0If so, what was wrong?
>>> Do you have any recommendations on things to try (either as guesses
>>> or, even better, to help eliminate possibilities)
>>> And along those lines... can anybody think of any possible reasons =
for this?
>>
>> hope the above helped.
>>
>>> This is so frustrating since I _know_ this hardware is capable of s=
o
>>> much more. =A0It's relatively painless for me to re-run tests in my=
 lab,
>>> so feel free to throw something at me that you think will stick :D
>>
>> last I checked, I recall with 82599 I was pushing ~4.5 million 64 by=
te
>> packets a second (bidirectional, no drop), after disabling irqbalanc=
e and
>> 16 tx/rx queues set with set_irq_affinity.sh script (available in ou=
r
>> ixgbe-foo.tar.gz from sourceforge). =A082598 should be a bit lower, =
but
>> probably can get close to that number.
>>
>> I haven't run the test lately though, but at that point I was likely=
 on
>> 2.6.30 ish
>>
>> Jesse
>>
>
> Thank you so much... I wish I'd sent this email out a week ago ;-P
>
> -A
>
