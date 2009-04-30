From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Thu, 30 Apr 2009 16:08:48 +0200
Message-ID: <49F9B0F0.40306@cosmosbay.com>
References: <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com> <20090429091130.GA27857@elte.hu> <49F9821C.5010802@cosmosbay.com> <20090430115736.GA24349@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47320 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763999AbZD3OKO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 10:10:14 -0400
In-Reply-To: <20090430115736.GA24349@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Ingo Molnar a =E9crit :
>>> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>>>
>>>> On uddpping, I had prior to the patch about 49000 wakeups per=20
>>>> second, and after patch about 26000 wakeups per second (matches=20
>>>> number of incoming udp messages per second)
>>> very nice. It might not show up as a real performance difference if=
=20
>>> the CPUs are not fully saturated during the test - but it could sho=
w=20
>>> up as a decrease in CPU utilization.
>>>
>>> Also, if you run the test via 'perf stat -a ./test.sh' you should=20
>>> see a reduction in instructions executed:
>>>
>>> aldebaran:~/linux/linux> perf stat -a sleep 1
>>>
>>>  Performance counter stats for 'sleep':
>>>
>>>    16128.045994  task clock ticks     (msecs)
>>>           12876  context switches     (events)
>>>             219  CPU migrations       (events)
>>>          186144  pagefaults           (events)
>>>     20911802763  CPU cycles           (events)
>>>     19309416815  instructions         (events)
>>>       199608554  cache references     (events)
>>>        19990754  cache misses         (events)
>>>
>>>  Wall-clock time elapsed:  1008.882282 msecs
>>>
>>> With -a it's measured system-wide, from start of test to end of tes=
t=20
>>> - the results will be a lot more stable (and relevant) statisticall=
y=20
>>> than wall-clock time or CPU usage measurements. (both of which are=20
>>> rather imprecise in general)
>> I tried this perf stuff and got strange results on a cpu burning=20
>> bench, saturating my 8 cpus with a "while (1) ;" loop
>>
>>
>> # perf stat -a sleep 10
>>
>>  Performance counter stats for 'sleep':
>>
>>    80334.709038  task clock ticks     (msecs)
>>           80638  context switches     (events)
>>               4  CPU migrations       (events)
>>             468  pagefaults           (events)
>>    160694681969  CPU cycles           (events)
>>    160127154810  instructions         (events)
>>          686393  cache references     (events)
>>          230117  cache misses         (events)
>>
>>  Wall-clock time elapsed: 10041.531644 msecs
>>
>> So its about 16069468196 cycles per second for 8 cpus
>> Divide by 8 to get 2008683524 cycles per second per cpu,
>> which is not       3000000000  (E5450  @ 3.00GHz)
>=20
> What does "perf stat -l -a sleep 10" show? I suspect your counters=20
> are scaled by about 67%, due to counter over-commit. -l will show=20
> the scaling factor (and will scale up the results).

Only difference I see with '-l' is cache misses not counted.

(tbench 8 running, so not one instruction per cycle)

# perf stat -l -a sleep 10

 Performance counter stats for 'sleep':

   80007.128844  task clock ticks     (msecs)
        6754642  context switches     (events)
              2  CPU migrations       (events)
            474  pagefaults           (events)
   160925719143  CPU cycles           (events)
   108482003620  instructions         (events)
     7584035056  cache references     (events)
  <not counted>  cache misses

 Wall-clock time elapsed: 10000.595448 msecs

# perf stat -a sleep 10

 Performance counter stats for 'sleep':

   80702.908287  task clock ticks     (msecs)
        6792588  context switches     (events)
             24  CPU migrations       (events)
           4867  pagefaults           (events)
   161957342744  CPU cycles           (events)
   109147553984  instructions         (events)
     7633190481  cache references     (events)
       22996234  cache misses         (events)

 Wall-clock time elapsed: 10087.502391 msecs



>=20
> If so then i think this behavior is confusing, and i'll make -l=20
> default-enabled. (in fact i just committed this change to latest=20
> -tip and pushed it out)
>=20
> To get only instructions and cycles, do:
>=20
>    perf stat -e instructions -e cycles
>=20

# perf stat -e instructions -e cycles -a sleep 10

 Performance counter stats for 'sleep':

   109469842392  instructions         (events)
   162012922122  CPU cycles           (events)

 Wall-clock time elapsed: 10124.943544 msecs

I am wondering if cpus are not running at 2 GHz ;)


>> It seems strange a "jmp myself" uses one unhalted cycle per=20
>> instruction and 0.5 halted cycle ...
>>
>> Also, after using "perf stat", tbench results are 1778 MB/S=20
>> instead of 2610 MB/s. Even if no perf stat running.
>=20
> Hm, that would be a bug. Could you send the dmesg output of:
>=20
>    echo p > /proc/sysrq-trigger=20
>    echo p > /proc/sysrq-trigger=20
>=20
> with counters running it will show something like:
>=20
> [  868.105712] SysRq : Show Regs
> [  868.106544]=20
> [  868.106544] CPU#1: ctrl:       ffffffffffffffff
> [  868.106544] CPU#1: status:     0000000000000000
> [  868.106544] CPU#1: overflow:   0000000000000000
> [  868.106544] CPU#1: fixed:      0000000000000000
> [  868.106544] CPU#1: used:       0000000000000000
> [  868.106544] CPU#1:   gen-PMC0 ctrl:  00000000001300c0
> [  868.106544] CPU#1:   gen-PMC0 count: 000000ffee889194
> [  868.106544] CPU#1:   gen-PMC0 left:  0000000011e1791a
> [  868.106544] CPU#1:   gen-PMC1 ctrl:  000000000013003c
> [  868.106544] CPU#1:   gen-PMC1 count: 000000ffd2542438
> [  868.106544] CPU#1:   gen-PMC1 left:  000000002dd17a8e

They stay fix (but only CPU#0 is displayed)

Is perf able to display per cpu counters, and not aggregated values ?

[ 7894.426787] CPU#0: ctrl:       ffffffffffffffff
[ 7894.426788] CPU#0: status:     0000000000000000
[ 7894.426790] CPU#0: overflow:   0000000000000000
[ 7894.426792] CPU#0: fixed:      0000000000000000
[ 7894.426793] CPU#0: used:       0000000000000000
[ 7894.426796] CPU#0:   gen-PMC0 ctrl:  0000000000134f2e
[ 7894.426798] CPU#0:   gen-PMC0 count: 000000ffb91e31e1
[ 7894.426799] CPU#0:   gen-PMC0 left:  000000007fffffff
[ 7894.426802] CPU#0:   gen-PMC1 ctrl:  000000000013412e
[ 7894.426804] CPU#0:   gen-PMC1 count: 000000ff80312b23
[ 7894.426805] CPU#0:   gen-PMC1 left:  000000007fffffff
[ 7894.426807] CPU#0: fixed-PMC0 count: 000000ffacf54a68
[ 7894.426809] CPU#0: fixed-PMC1 count: 000000ffb71cfe02
[ 7894.426811] CPU#0: fixed-PMC2 count: 0000000000000000
[ 7905.522262] SysRq : Show Regs
[ 7905.522277]
[ 7905.522279] CPU#0: ctrl:       ffffffffffffffff
[ 7905.522281] CPU#0: status:     0000000000000000
[ 7905.522283] CPU#0: overflow:   0000000000000000
[ 7905.522284] CPU#0: fixed:      0000000000000000
[ 7905.522286] CPU#0: used:       0000000000000000
[ 7905.522288] CPU#0:   gen-PMC0 ctrl:  0000000000134f2e
[ 7905.522290] CPU#0:   gen-PMC0 count: 000000ffb91e31e1
[ 7905.522292] CPU#0:   gen-PMC0 left:  000000007fffffff
[ 7905.522294] CPU#0:   gen-PMC1 ctrl:  000000000013412e
[ 7905.522296] CPU#0:   gen-PMC1 count: 000000ff80312b23
[ 7905.522298] CPU#0:   gen-PMC1 left:  000000007fffffff
[ 7905.522299] CPU#0: fixed-PMC0 count: 000000ffacf54a68
[ 7905.522301] CPU#0: fixed-PMC1 count: 000000ffb71cfe02
[ 7905.522303] CPU#0: fixed-PMC2 count: 0000000000000000


>=20
> the counts should stay put (i.e. all counters should be disabled).=20
> If they move around - despite there being no 'perf stat -a' session=20
> running, that would be a bug.

I rebooted my machine then got good results

# perf stat -e instructions -e cycles -a sleep 10

 Performance counter stats for 'sleep':

   240021659058  instructions         (events)
   240997984836  CPU cycles           (events) << OK >>

 Wall-clock time elapsed: 10041.499326 msecs

But if I use plain "perf stat -a sleep 10"
it seems I get wrong values again (16 G cycles/sec) for all next perf s=
essions


# perf stat -a sleep 10

 Performance counter stats for 'sleep':

   80332.718661  task clock ticks     (msecs)
          80602  context switches     (events)
              4  CPU migrations       (events)
            473  pagefaults           (events)
   160665397757  CPU cycles           (events)  << bad >>
   160079277974  instructions         (events)
         793665  cache references     (events)
         226829  cache misses         (events)

 Wall-clock time elapsed: 10041.302969 msecs

# perf stat -e cycles -a sleep 10

 Performance counter stats for 'sleep':

   160665176575  CPU cycles           (events)  << bad >>

 Wall-clock time elapsed: 10041.491503 msecs


>=20
> Also, the overhead might be profile-able, via:
>=20
> 	perf record -m 1024 sleep 10
>=20
> (this records the profile into output.perf.)
>=20
> followed by:
>=20
> 	./perf-report | tail -20
>=20
> to display a histogram, with kernel-space and user-space symbols=20
> mixed into a single profile.
>=20
> (Pick up latest -tip to get perf-report built by default.)

Thanks, this is what I use currently

