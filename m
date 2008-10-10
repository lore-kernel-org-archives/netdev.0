From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 12:13:43 +0200
Message-ID: <1223633623.4138.86.camel@marge.simson.net>
References: <20081009231759.GA8664@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37742 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752714AbYJJKNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 06:13:49 -0400
In-Reply-To: <20081009231759.GA8664@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-10 at 03:17 +0400, Evgeniy Polyakov wrote:=20
> Hi.

Greetings.  Glad to see someone pursuing this.

> It was reported recently that tbench has a long history of regression=
s,
> starting at least from 2.6.23 kernel. I verified that in my test
> environment tbench 'lost' more than 100 MB/s from 470 down to 355
> between at least 2.6.24 and 2.6.27. 2.6.26-2.6.27 performance regress=
ion
> in my machines is rougly corresponds to 375 down to 355 MB/s.
>=20
> I spent several days in various tests and bisections (unfortunately
> bisect can not always point to the 'right' commit), and found followi=
ng
> problems.
>=20
> First, related to the network, as lots of people expected: TSO/GSO ov=
er
> loopback with tbench workload eats about 5-10 MB/s, since TSO/GSO fra=
me
> creation overhead is not paid by the optimized super-frame processing
> gains. Since it brings really impressive improvement in big-packet
> workload, it was (likely) decided not to add a patch for this, but
> instead one can disable TSO/GSO via ethtool. This patch was added in
> 2.6.27 window, so it has its part in its regression.

Part, disabling TSO/GSO doesn't do enough here.  See test log below.

> Second part in the 26-27 window regression (I remind, it is about 20
> MB/s) is related to the scheduler changes, which was expected by anot=
her
> group of people. I tracked it down to the
> a7be37ac8e1565e00880531f4e2aff421a21c803 commit, which, if being
> reverted, returns 2.6.27 tbench perfromance to the highest (for
> 2.6.26-2.6.27) 365 MB/s mark. I also tested tree, stopped at above
> commit itself, i.e. not 2.6.27, and got 373 MB/s, so likely another
> changes in that merge ate couple of megs. Attached patch against 2.6.=
27.

a7be37a adds some math overhead, calls to calc_delta_mine() per
wakeup/context switch for all weight tasks, whereas previously these
calls were only made for tasks which were not nice 0.  It also shifts
performance a bit in favor of loads which dislike wakeup preemption,
this effect lessens as task count increases.  Per testing, overhead is
not the primary factor in throughput loss.  I believe clock accuracy to
be a more important factor than overhead by a very large margin.

Reverting a7be37a (and the two asym fixes) didn't do a whole lot for me
either.  I'm still ~8% down from 2.6.26 for netperf, and ~3% for tbench=
,
and the 2.6.26 numbers are gcc-4.1, which are a little lower than
gcc-4.3.  Along the way, I've reverted 100% of scheduler and ilk 26->27
and been unable to recover throughput.  (Too bad I didn't know about
that TSO/GSO thingy, would have been nice.)

I can achieve nearly the same improvement for tbench with a little
tinker, and _more_ for netperf than reverting these changes delivers,=EF=
=BB=BF
see last log entry, experiment cut math overhead by less than 1/3.

=46or the full cfs history, even with those three reverts, I'm ~6% down=
 on
tbench, and ~14% for netperf, and haven't found out where it went.

> Curious reader can ask, where did we lost another 100 MB/s? This smal=
l
> issue was not detected (or at least reported in netdev@ with provocat=
ive
> enough subject), and it happend to live somehere in 2.6.24-2.6.25 cha=
nges.
> I was so lucky to 'guess' (just after couple of hundreds of compilati=
ons),
> that it corresponds to 8f4d37ec073c17e2d4aa8851df5837d798606d6f commi=
t about
> high-resolution timers, attached patch against 2.6.25 brings tbench
> performance for the 2.6.25 kernel tree to 455 MB/s.

I have highres timers disabled in my kernels because per testing it doe=
s
cost a lot at high frequency, but primarily because it's not available
throughout test group, same for nohz.  A patchlet went into 2.6.27 to
neutralized the cost of hrtick when it's not active.  Per re-test,
2.6.27 should be zero impact with hrtick disabled.=20

> There are still somewhat missed 20 MB/s, but 2.6.24 has 475 MB/s, so
> likely bug lives between 2.6.24 and above 8f4d37ec073 commit.

I lost some at 24, got it back at 25 etc.  Some of it is fairness /
preemption differences, but there's a bunch I can't find, and massive
amounts of time spent bisecting were a waste of time.

My annotated test log.  File under fwiw.

Note:  2.6.23 cfs was apparently a bad-hair day for high frequency
switchers.  Anyone entering the way-back-machine to test 2.6.23, should
probably use cfs-24.1, which is 2.6.24 scheduler minus on zero impact
for nice 0 loads line.

-----------------------------------------------------------------------=
--
UP config, no nohz or highres timers except as noted.

60 sec localhost network tests, tbench 1 and 1 netperf TCP_RR pair.
use ring-test -t 2 -w 0 -s 0 to see roughly how heavy the full ~0 work
fast path is, vmstat 10 ctx/s fed to bc (close enough for gvt work).=20
ring-test args: -t NR tasks -w work_ms -s sleep_ms

sched_wakeup_granularity_ns always set to 0 for all tests to maximize
context switches.

Why?  O(1) preempts very aggressively with dissimilar task loads, as
both tbench and netperf are.  With O(1), sleepier component preempts
less sleepy component on each and every wakeup.  CFS preempts based on
lag (sleepiness) as well, but it's short vs long term.  Granularity of
zero was as close to apple/apple as I could get.. apple/pineapple.

2.6.22.19-up
ring-test   - 1.204 us/cycle  =3D 830 KHz  (gcc-4.1)
ring-test   - doorstop                   (gcc-4.3)
netperf     - 147798.56 rr/s  =3D 295 KHz  (hmm, a bit unstable, 140K..=
147K rr/s)
tbench      - 374.573 MB/sec

2.6.22.19-cfs-v24.1-up
ring-test   - 1.098 us/cycle  =3D 910 KHz  (gcc-4.1)
ring-test   - doorstop                   (gcc-4.3)
netperf     - 140039.03 rr/s  =3D 280 KHz =3D 3.57us - 1.10us sched =3D=
 2.47us/packet network
tbench      - 364.191 MB/sec

2.6.23.17-up
ring-test   - 1.252 us/cycle  =3D 798 KHz  (gcc-4.1)
ring-test   - 1.235 us/cycle  =3D 809 KHz  (gcc-4.3)
netperf     - 123736.40 rr/s  =3D 247 KHz  sb 268 KHZ / 134336.37 rr/s
tbench      - 355.906 MB/sec

2.6.23.17-cfs-v24.1-up
ring-test   - 1.100 us/cycle  =3D 909 KHz  (gcc-4.1)
ring-test   - 1.074 us/cycle  =3D 931 KHz  (gcc-4.3)
netperf     - 135847.14 rr/s  =3D 271 KHz  sb 280 KHz / 140039.03 rr/s
tbench      - 364.511 MB/sec

2.6.24.7-up
ring-test   - 1.100 us/cycle  =3D 909 KHz  (gcc-4.1)
ring-test   - 1.068 us/cycle  =3D 936 KHz  (gcc-4.3)
netperf     - 122300.66 rr/s  =3D 244 KHz  sb 280 KHz / 140039.03 rr/s
tbench      - 341.523 MB/sec

2.6.25.17-up
ring-test   - 1.163 us/cycle  =3D 859 KHz  (gcc-4.1)
ring-test   - 1.129 us/cycle  =3D 885 KHz  (gcc-4.3)
netperf     - 132102.70 rr/s  =3D 264 KHz  sb 275 KHz / 137627.30 rr/s
tbench      - 361.71 MB/sec

retest 2.6.25.18-up, gcc =3D 4.3

2.6.25.18-up
push patches/revert_hrtick.diff
ring-test   - 1.127 us/cycle  =3D 887 KHz
netperf     - 132123.42 rr/s
tbench      - 358.964 361.538 361.164 MB/sec
(all is well, zero impact as expected, enable highres timers)

2.6.25.18-up
pop patches/revert_hrtick.diff
push patches/hrtick.diff (cut overhead when hrtick disabled patchlet in=
 .27)

echo 7 > sched_features =3D nohrtick
ring-test   - 1.183 us/cycle  =3D 845 KHz
netperf     - 131976.23 rr/s
tbench      - 361.17 360.468 361.721 MB/sec

echo 15 > sched_features =3D default =3D hrtick
ring-test   - 1.333 us/cycle  =3D 750 KHz        - .887
netperf     - 120520.67 rr/s                   - .913
tbench      - 344.092 344.569 344.839 MB/sec   - .953

(yeah, why i turned highres timers off while testing high frequency thr=
oughput)

2.6.26.5-up
ring-test   - 1.195 us/cycle  =3D 836 KHz  (gcc-4.1)
ring-test   - 1.179 us/cycle  =3D 847 KHz  (gcc-4.3)
netperf     - 131289.73 rr/s  =3D 262 KHZ  sb 272 KHz / 136425.64 rr/s
tbench      - 354.07 MB/sec

2.6.27-rc8-up
ring-test   - 1.225 us/cycle  =3D 816 KHz  (gcc-4.1)
ring-test   - 1.196 us/cycle  =3D 836 KHz  (gcc-4.3)
netperf     - 118090.27 rr/s  =3D 236 KHz  sb 270 KHz / 135317.99 rr/s
tbench      - 329.856 MB/sec

retest of 2.6.27-final-up, gcc =3D 4.3.  tbench/netperf numbers above h=
ere
are all gcc-4.1 except for 2.6.25 retest.

2.6.27-final-up
ring-test   - 1.193 us/cycle  =3D 838 KHz  (gcc-4.3)
tbench      - 337.377 MB/sec           tso/gso on
tbench      - 340.362 MB/sec           tso/gso off
netperf     - TCP_RR 120751.30 rr/s    tso/gso on
netperf     - TCP_RR 121293.48 rr/s    tso/gso off

2.6.27-final-up
push revert_weight_and_asym_stuff.diff
ring-test   - 1.133 us/cycle  =3D 882 KHz  (gcc-4.3)
tbench      - 340.481 MB/sec           tso/gso on
tbench      - 343.472 MB/sec           tso/gso off
netperf     - 119486.14 rr/s           tso/gso on
netperf     - 121035.56 rr/s           tso/gso off

2.6.27-final-up-tinker
ring-test   - 1.141 us/cycle  =3D 876 KHz  (gcc-4.3)
tbench      - 339.095 MB/sec           tso/gso on
tbench      - 340.507 MB/sec           tso/gso off
netperf     - 122371.59 rr/s           tso/gso on
netperf     - 124650.09 rr/s           tso/gso off


