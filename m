From: John Lumby <johnlumby@hotmail.com>
Subject: r8169 :  always copying the rx buffer to new skb
Date: Mon, 27 Jun 2011 18:54:11 -0400
Message-ID: <COL116-W30238D0821823E764BBB53A3570@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from col0-omc1-s10.col0.hotmail.com ([65.55.34.20]:29018 "EHLO
	col0-omc1-s10.col0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754792Ab1F0W7n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 18:59:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Summary of some results since previous posts in April :

Previously I suggested re-introducing the rx_copybreak parameter to pro=
vide the option of un-hooking the receive buffer rather than copying it=
,=A0 in order to save the overhead of the memcpy,=A0=A0 which shows as =
the highest tick-count in oprofile.=A0 All buffer memcpy'ing is done on=
 CPU0 on my system.

I then found that,=A0 without the memcpy,=A0 the driver and net stack c=
onsume other overhead elsewhere,=A0 particularly in too-frequent pollin=
g/interrupting.

Eric D pointed out that :
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Doing the copy of data and building a=
n exact size skb has benefit of
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 providing 'right' skb->truesize (migh=
t reduce RCVBUF contention and
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 avoid backlog drops) and already cach=
ed data (hot in cpu caches).
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Next 'copy' is almost free (L1 cache =
access)

There was also some discussion off-line about using larger MTU size.

Since then,=A0 I have explored some ideas for dealing with the too-freq=
uent polling/interrupting and the cache aspect,=A0 with some success on=
 the first and no success on the second.=A0=A0 In summary of results:
=A0=A0 .=A0 With MTU of 1500 and "normal" workload,=A0=A0 I see an impr=
ovement of between 4% - 6% in throughput,=A0 depending on kernel releas=
e and kernel .config.=A0=A0=A0 Specifically,=A0 with the heaviest workl=
oad and most tuned kernel .config:
=A0=A0=A0=A0=A0=A0 no changes=A0 -=A0 ~=A0 1440 Megabits/sec bi-directi=
onal
=A0=A0=A0=A0 with changes=A0 -=A0 ~=A0 1530 Megabits/sec bi-directional
=A0=A0 (same .config for each of course)
=A0=A0=A0=A0=A0 All 4 of my atom 330's (2 physical x 2SMt per physical)=
 were at 100% on both without and with changes for this workload,=A0 bu=
t with very different profiles.
=A0=A0=A0=A0=A0 These throughput numbers are higher than I reported bef=
ore,=A0=A0 and % improvement lower,=A0 because of the tuning to the bas=
e system and workload.

=A0=A0 .=A0 With MTU of 6144,=A0 I see a more dramatic effect=A0 -=A0 t=
he same workload runs at 1725 Megabit/sec on both kernels,=A0 (which ma=
y be a practical hardware limit on one of the adapters,=A0 since it hit=
s exactly this rate almost every time no matter what else I change),=A0=
 but overall CPU utilization drops from ~ 80% without changes to ~60% w=
ith changes.=A0=A0=A0 I feel this is significant but of course its use =
limited to networks that can support this segment size everywhere.

Notes on the changes:

=A0Too-frequent polling/interrupting:
=A0These two are highly interrelated by NAPI.
=A0=A0=A0=A0 Too-frequent polling:
=A0=A0=A0=A0=A0=A0=A0=A0 The NAPI weight is a double-duty parameter,=A0=
 controlling both the dynamic choice between continuing a NAPI polling =
session versus leaving and resuming interrupts,=A0 and also the maximum=
 number of receive buffers to be passed up per poll.=A0=A0 It's also no=
t configurable (set to 64).=A0=A0=A0 I split it into two numbers,=A0 on=
e for each purpose,=A0 and made them configurable,=A0 and tried tuning =
them.=A0=A0=A0 A good value for the poll/int choice was 16,=A0=A0 while=
 the max-size number was best left at 64.=A0=A0=A0 This helps a bit,=A0=
 but polling is still too frequent.
=A0=A0=A0=A0=A0=A0=A0=A0 I then made an interface up into the softirqd =
to let the driver tell the softirqd :
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 "keep my napi session alive but=
 sched_yield to other runnable processes before running another poll"
=A0=A0=A0=A0=A0=A0=A0=A0 I added a check to __do_softirq that if the *o=
nly* pending softirq is NET_RX_SOFTIRQ and the rx_action routine reques=
ted this, then it exits and tells the deamon to yield.
=A0=A0=A0=A0=A0=A0=A0=A0 I borrowed a bit in local_softirq_pending for =
this.=A0 This helped a lot for certain workloads.=A0=A0=A0 I saw consid=
erable drop in system CPU% on CPU0 and higher user CPU% there.

=A0=A0=A0=A0 Too-frequent interrupting:
=A0=A0=A0=A0=A0=A0=A0=A0 I made use of the r8169's Interrupt Mitigation=
 feature,=A0=A0 setting it to the maximum multiplied by a factor betwee=
n 0-1 based inversely on tx queue size=A0 (large qsize,=A0 short delay =
and vice versa).=A0=A0=A0=A0 This also helped a lot.=A0 The current dri=
ver sets these registers but only once per "up" session,=A0 during rtl8=
169_open of the NIC;=A0 But Hayes explained that the regs must be set o=
n each enabling of interrupts.=A0=A0=A0 This is the one case where (I t=
hink) I corrected a bug present in the current driver.=A0=A0 Harmless b=
ut not doing what was intended.

=A0=A0=A0=A0=A0 The effect of these two changes was to reduce the rate =
of hardware interrupts down to less than 1/20 of before,=A0 and also ho=
ld the polling rate down (around 4-5 packets per poll on average on a t=
ypical run,=A0 sometimes much higher).


=A0 memory and caching:
=A0 Here I failed to achieve anything.=A0=A0=A0 Based on Eric's point a=
bout memcpy giving a "free" next copy, I thought possibly memory prefet=
ching might provide something equivalent.=A0=A0 Specifically,=A0 prefet=
ch the skb and its databuff immediately after un-dma'ing.
=A0 For example,=A0=A0 with my changes and no memcpy,=A0 I see eth_type=
_trans() high in oprofile tick score on CPU0.
=A0 This small function does very little work but is the first (I think=
) to access a field in the skb->data buffer - the ethernet header.=A0 P=
refetching ought to do better than memcpy'ing since only one copy of th=
e data will enter L1,=A0 not two.=A0=A0=A0 But my attempts at this achi=
eved nothing or negative.
=A0 Note=A0 -=A0 the current driver does issue a prefetch of the origin=
al buffer prior to the memcpy.=A0 But,=A0 on my system (atom CPUs),=A0 =
gdb of the object file r8169.o indicates no prefetch instructions are g=
enerated,=A0=A0 only lea of the address to be prefetched.=A0=A0=A0=A0 I=
 tried changing the prefetch call to an asm generated prefetcht0/prefet=
chnta instruction with disappointing results.=A0=A0 I noticed some disc=
ussion of memory prefetch in this list earlier and maybe it is not usef=
ul.

=A0 I tried to explore Eric's other point about skb->truesize but ran o=
ut of time researching.=A0=A0=A0=A0 I guess my current results are nega=
tively impacted by these memory and skb issues that Eric mentions,=A0 b=
ut I could not find any answer.


=A0 There was a question of how this changed driver handles memory pres=
sure :
=A0 Along with the rx_copybreak change,=A0 I made the number of rx and =
tx ring buffers configurable and dynamically replenishable.=A0=A0=A0 Th=
e changed driver can tolerate occasional or even bursty alloc failures =
without exposing any effects outside itself,=A0=A0=A0 whereas the curre=
nt driver drops packets.=A0=A0 However,=A0 under extreme consecutive fa=
ilures,=A0 the changed driver will eventually run too low and stop comp=
letely,=A0 whereas the current driver will (I assume) stay up.=A0=A0=A0=
=A0 I was unable to cause either of these in my tests.=A0=A0=A0 Measure=
ments with concurrent memory hogs confirmed this but did show heavy dro=
p in throughput for the changed driver.


=A0 I've tried these changes out on all kernel release levels from 2.6.=
36 to 3.0-rc3 and see roughly comparable deltas on all,=A0 but with sli=
ghtly different tuning required to hit the optimum,=A0 and some variabi=
lity on all after 2.6.37.=A0=A0=A0=A0 2.6.37 seemed to be slightly the =
"best".=A0=A0 Not sure why although I see some relevant changes to the =
scheduler between 2.6.37 - 38.=A0=A0=A0 There is also a strange effect =
with the old RTC in 3.0=A0 -=A0 I had to remove it from the kernel to g=
et good results,=A0=A0=A0 whereas it was a module in 2.6 levels (which =
I did not load for the tests).=A0=A0=A0=A0 I don't need it on my system=
 except for one ancient utility.=A0=A0=A0=A0 I also found major impact =
from iptables and cleared all tables for the tests.=A0=A0=A0 That is th=
e one item that would normally be needed in a production setup that I t=
urned off.=A0 The overhead of iptables is presumably highly dependent o=
n how many rules in the filter chains.=A0=A0=A0 (I have rather a lot in=
 INPUT)


I don't plan to do any more on this but can provide my patch (currently=
 one monolithic one based on DaveM 3.0.0-rc1netnext-110615) and detaile=
d results if anyone wants.

Cheers,=A0=A0 John Lumby
 		 	   		  