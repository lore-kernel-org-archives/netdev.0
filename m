From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Sat, 01 Oct 2011 11:56:21 -0400
Message-ID: <6.2.5.6.2.20111001115006.039f0608@binnacle.cx>
References: <6.2.5.6.2.20111001012019.05c05b80@flumedata.com>
 <1317451442.3802.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317451442.3802.18.camel@edumazet-laptop>
References: <6.2.5.6.2.20111001012019.05c05b80@flumedata.com>
 <1317451442.3802.18.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 08:44 AM 10/1/2011 +0200, Eric Dumazet wrote:
>Le samedi 01 octobre 2011 =C3  01:30 -0400, starlight@binnacle.cx=20
>a =C3=A9crit :
>> Hello,
>>=20
>> I'm hoping someone can provide a brief big-picture
>> perspective on the dramatic UDP/IP multicast
>> receive performance reduction from 2.6.18 to
>> 2.6.32 that I just benchmarked.
>>=20
>> Have helped out in the past, mainly by identifying
>> a bug in hugepage handling and providing a solid
>> testcase that helped in quickly identifying and
>> correcting the problem.
>>=20
>> Have a very-high-volume UDP multicast receiver
>> application.  Just finished benchmarking latest RH
>> variant of 2.6.18 against latest RH 2.6.32 and
>> vanilla 2.6.32.27 on the same 12 core Opteron
>> 6174 processor system, one CPU.
>>=20
>> Application reads on 250 sockets with large socket
>> buffer maximums.  Zero data loss.  Four Intel
>> 'e1000e' 82571 gigabit NICs, or two Intel 'igb'
>> 82571 gigabit NICs or two Intel 82599 10 gigabit
>> NICs.  Results similar on all.
>>=20
>> With 2.6.18, system CPU is reported in
>> /proc/<pid>/stat as 25% of total.  With 2.6.32,
>> system consumption is 45% with the same exact data
>> playback test.  Jiffy count for user CPU is same
>> for both kernels, but .32 system CPU is double
>> .18 system CPU.
>>=20
>> Overall maximum performance capacity is reduced in
>> proportion to the increased system overhead.
>>=20
>> ------
>>=20
>> My question is why is the performance significantly
>> worse in the more recent kernels?  Apparently
>> network performance is worse for TCP by about the
>> same amount--double the system overhead for the
>> same amount of work.
>>=20
>>=20
>http://www.phoronix.com/scan.php?page=3Darticle&item=3Dlinux_2612_2637=
&num=3D6
>>=20
>> Is there any chance that network performance will
>> improve in future kernels?  Or is the situation
>> a permanent trade-off for security, reliability
>> or scalability reasons?
>>=20
>
>CC netdev
>
>Since you have 2.6.32, you could use perf tool and
>provide us a performance report.
>
>In my experience, I have the exact opposite :
>performance greatly improved in recent
>kernels. Unless you compile your kernel to include
>new features that might reduce performance
>(namespaces, cgroup, ...)
>
>It can vary a lot depending on many parameters,
>like cpu affinities, device parameters
>(coalescing, interrupt mitigation...).
>
>You cant expect switching from 2.6.18 to 2.6.32
>and have exactly same system behavior.
>
>If your app is performance sensitive, you'll have
>to make some analysis to find out what needs to be
>tuned.

The application and kernel were both substantially
tuned in the test that was just run.  Socket
buffers are set to 64MB and NIC IRQs are hand-mapped
to specific cores.  Both Intel and korg drivers
were tested.  Default Intel coalescing is applied
since that generally works the best.  Maximum receive
ring queues of 4096 are set.  Data arrives on four
NICs with the workload balanced evenly across twelve
cores.  For multi-queue NICs the number of queues
is set to match the number of cores and the IRQs
hand-mapped.  Tests were run at 50% CPU utilization
and at maximum zero-data-loss utilization of
about 95% (on all cores).

>One known problem of old kernels and UDP is that
>they was no memory accouting, so an application
>could easily consume all kernel memory and crash
>the machine.
>
>So in 2.6.25, Hideo Aoki added memory limiting to
>UDP, slowing down a lot of UDP operations because
>of added socket locking, both on transmit and
>receive path.

In this case RH has backported the memory accounting
logic to the older kernel tested, 2.6.18-194.8.1.el5
which comes from their RHEL 5.5 release.  I recently
reported that the defaults were incorrect in both
vanilla and RH and that without adjustment to
'net.ipv4.udp_mem' the system can hang or crash.

The test system has this value tuned and
was enforcing the limit during the test,
though the limit was never hit or packet
loss would have resulted.  There was none.

Also have tested 2.6.18-274.3.1.el5 from
RHEL 5.7 with identical results.

>If your application is multithreaded and use a
>single socket, you can hit lock contention since
>2.6.25.

Each multicast has a dedicated socket and a
thread that reads each packet and performs some
computational work in a forever loop.  Two
very-low-contention mutexs (there are large
arrays for each) are taken briefly and then
released by the application.  No other work
is performed in the benchmarked scenario.

>Step by step, we tried to remove part of the
>scalability problems introduced in 2.6.25
>
>In 2.6.35, we speedup receive path a bit (avoiding
>backlog processing)
>
>In 2.6.39, transmit path became lockless again,
>thanks to Herbert Xu.
>
>I advise you to try a recent kernel if you need
>UDP performance, 2.6.32 is quite old

I can run this test, but the problem is the
application must run on a commercially supported
kernel.  2.6.32 was chosen by RH for their
RHEL 6 release.  The motivation for the
benchmark was to test RHEL 6 against RHEL 5.

>Multicast is quite a stress for process scheduler,
>so we experimented a way to group all wakeups at
>the end of softirq handler.

If this is present in 2.6.32, I am concerned it
could have had an unintended negative impact on
performance.  This sort of adjustment is tricky
in my experience.  Seemingly great tuning ideas
are a bust more often than a success.  L2 and
L3 cache dynamics introduce all kinds of
non-intuitive effects.

>Work is in progress in this area : Peter Zijlstra
>named this "delayed wakeup". A further idea would
>be to be able to delegate the wakeups to another
>cpu, since I suspect you have one CPU busy in
>softirq processing, and other cpus are idle.

Actually no.  'top' shows a perfectly even CPU/core
load distribution.  To minimize latency and maximize
performance we map IRQs carefully to as many cores
as possible.  User-space threads are allowed to
float and the Linux scheduler usually wakes a
worker thread up on the same core that the
bottom-half processing is completed on, which
usually is the core the interrupt arrived on.  In
the case of the single-queue 82571 'e1000e', four
cores (one for each NIC) do all the bottom half
processing (as seen in top), and userspace work is
completed on the same or nearby cores.  It should
be said that the 'e1000e' driver is substantially
more efficient that the newer 'igb' and 'ixgbe'
multi-queue drivers and the the benchmarks runs
the best with 'e1000e'.  So the cost of moving
work from one core to another during the
transition from kernel to user-space is apparently
very low when present.

-----

Thanks for all the info.  I'll keep an eye on
upcoming kernels and benchmark them on occasion.
RH often backports significant improvements.
Or perhaps they'll break with tradition and
advance to a newer kernel at some point for
RHEL 6.

=46ortunately RHEL 5 will be supported for some
time so the older kernel can continue to be
used.

Should mention in closing that the tests were
also run using PACKET sockets, one per interface.
The results with PACKET sockets and with UDP
sockets are quite close.  System overhead is
exactly the same with the same kernel, and a
10% user-space penalty is incurred because
data must be copied to an array of queues
for proper fan-out to a worker pool, and worker
threads woken-up.  This test only make sense
with the single-queue 'e1000e' NICs so it was
not performed with multi-queue NICs.
