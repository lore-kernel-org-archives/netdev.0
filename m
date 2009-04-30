From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Thu, 30 Apr 2009 13:57:36 +0200
Message-ID: <20090430115736.GA24349@elte.hu>
References: <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com> <20090429091130.GA27857@elte.hu> <49F9821C.5010802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54734 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760236AbZD3L6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 07:58:19 -0400
Content-Disposition: inline
In-Reply-To: <49F9821C.5010802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Ingo Molnar a =E9crit :
> > * Eric Dumazet <dada1@cosmosbay.com> wrote:
> >=20
> >> On uddpping, I had prior to the patch about 49000 wakeups per=20
> >> second, and after patch about 26000 wakeups per second (matches=20
> >> number of incoming udp messages per second)
> >=20
> > very nice. It might not show up as a real performance difference if=
=20
> > the CPUs are not fully saturated during the test - but it could sho=
w=20
> > up as a decrease in CPU utilization.
> >=20
> > Also, if you run the test via 'perf stat -a ./test.sh' you should=20
> > see a reduction in instructions executed:
> >=20
> > aldebaran:~/linux/linux> perf stat -a sleep 1
> >=20
> >  Performance counter stats for 'sleep':
> >=20
> >    16128.045994  task clock ticks     (msecs)
> >           12876  context switches     (events)
> >             219  CPU migrations       (events)
> >          186144  pagefaults           (events)
> >     20911802763  CPU cycles           (events)
> >     19309416815  instructions         (events)
> >       199608554  cache references     (events)
> >        19990754  cache misses         (events)
> >=20
> >  Wall-clock time elapsed:  1008.882282 msecs
> >=20
> > With -a it's measured system-wide, from start of test to end of tes=
t=20
> > - the results will be a lot more stable (and relevant) statisticall=
y=20
> > than wall-clock time or CPU usage measurements. (both of which are=20
> > rather imprecise in general)
>=20
> I tried this perf stuff and got strange results on a cpu burning=20
> bench, saturating my 8 cpus with a "while (1) ;" loop
>=20
>=20
> # perf stat -a sleep 10
>=20
>  Performance counter stats for 'sleep':
>=20
>    80334.709038  task clock ticks     (msecs)
>           80638  context switches     (events)
>               4  CPU migrations       (events)
>             468  pagefaults           (events)
>    160694681969  CPU cycles           (events)
>    160127154810  instructions         (events)
>          686393  cache references     (events)
>          230117  cache misses         (events)
>=20
>  Wall-clock time elapsed: 10041.531644 msecs
>=20
> So its about 16069468196 cycles per second for 8 cpus
> Divide by 8 to get 2008683524 cycles per second per cpu,
> which is not       3000000000  (E5450  @ 3.00GHz)

What does "perf stat -l -a sleep 10" show? I suspect your counters=20
are scaled by about 67%, due to counter over-commit. -l will show=20
the scaling factor (and will scale up the results).

If so then i think this behavior is confusing, and i'll make -l=20
default-enabled. (in fact i just committed this change to latest=20
-tip and pushed it out)

To get only instructions and cycles, do:

   perf stat -e instructions -e cycles

> It seems strange a "jmp myself" uses one unhalted cycle per=20
> instruction and 0.5 halted cycle ...
>=20
> Also, after using "perf stat", tbench results are 1778 MB/S=20
> instead of 2610 MB/s. Even if no perf stat running.

Hm, that would be a bug. Could you send the dmesg output of:

   echo p > /proc/sysrq-trigger=20
   echo p > /proc/sysrq-trigger=20

with counters running it will show something like:

[  868.105712] SysRq : Show Regs
[  868.106544]=20
[  868.106544] CPU#1: ctrl:       ffffffffffffffff
[  868.106544] CPU#1: status:     0000000000000000
[  868.106544] CPU#1: overflow:   0000000000000000
[  868.106544] CPU#1: fixed:      0000000000000000
[  868.106544] CPU#1: used:       0000000000000000
[  868.106544] CPU#1:   gen-PMC0 ctrl:  00000000001300c0
[  868.106544] CPU#1:   gen-PMC0 count: 000000ffee889194
[  868.106544] CPU#1:   gen-PMC0 left:  0000000011e1791a
[  868.106544] CPU#1:   gen-PMC1 ctrl:  000000000013003c
[  868.106544] CPU#1:   gen-PMC1 count: 000000ffd2542438
[  868.106544] CPU#1:   gen-PMC1 left:  000000002dd17a8e

the counts should stay put (i.e. all counters should be disabled).=20
If they move around - despite there being no 'perf stat -a' session=20
running, that would be a bug.

Also, the overhead might be profile-able, via:

	perf record -m 1024 sleep 10

(this records the profile into output.perf.)

followed by:

	./perf-report | tail -20

to display a histogram, with kernel-space and user-space symbols=20
mixed into a single profile.

(Pick up latest -tip to get perf-report built by default.)

	Ingo
