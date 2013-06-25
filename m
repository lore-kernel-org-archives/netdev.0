From: Ricardo Landim <ricardolan@gmail.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 21:04:04 -0300
Message-ID: <CACYKsS5tF1KLV10nz7j_QWdZu_k-Z-od80oJP6H=0=sWtkQNzA@mail.gmail.com>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	<1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	<20130624155154.GD10413@order.stressinduktion.org>
	<1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
	<20130624170119.GE10413@order.stressinduktion.org>
	<CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
	<1372096418.3301.75.camel@edumazet-glaptop>
	<CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
	<51C8BB3E.8090701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:44865 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab3FYAEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 20:04:05 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so11389532obq.35
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 17:04:05 -0700 (PDT)
In-Reply-To: <51C8BB3E.8090701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/6/24 Rick Jones <rick.jones2@hp.com>:
> On 06/24/2013 11:08 AM, Ricardo Landim wrote:
>>
>> Help in zero copy and improve in cost of syscalls.
>>
>> In my intel xeon(3.3ghz), read udp socket and write udp socket (proxy)
>> spends ~40000 cycles (~12 us).
>
>
> Are you quite certain your Xeon was actually running at 3.3GHz at the time?
> I just did a quick netperf UDP_RR test between an old Centrino-based laptop
> (HP 8510w) pegged at 1.6 GHz (cpufreq-set) and it was reporting a service
> demand of 12.2 microseconds per transaction, which is, basically, a send and
> recv pair plus stack:
>
> root@raj-8510w:~# netperf -t UDP_RR -c -i 30,3 -H tardy.usa.hp.com -- -r
> 140,1MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to
> tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  : demo : first
> burst 0
> !!! WARNING
> !!! Desired confidence was not achieved within the specified iterations.
> !!! This implies that there was variability in the test environment that
> !!! must be investigated before going further.
> !!! Confidence intervals: Throughput      : 1.120%
> !!!                       Local CPU util  : 6.527%
> !!!                       Remote CPU util : 0.000%
>
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 180224 180224 140     1      10.00   12985.58   7.93   -1.00  12.221 -1.000
> 212992 212992
>
> (Don't fret too much about the confidence intervals bit, it almost made it.)
>
> Also, my 1400 byte test didn't have all that different a service demand:
>
> root@raj-8510w:~# netperf -t UDP_RR -c -i 30,3 -H tardy.usa.hp.com -- -r
> 1400,1
> MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to
> tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  : demo : first
> burst 0
> !!! WARNING
> !!! Desired confidence was not achieved within the specified iterations.
> !!! This implies that there was variability in the test environment that
> !!! must be investigated before going further.
> !!! Confidence intervals: Throughput      : 1.123%
> !!!                       Local CPU util  : 6.991%
> !!!                       Remote CPU util : 0.000%
>
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 180224 180224 1400    1      10.00   10055.33   6.27   -1.00  12.469 -1.000
> 212992 212992
>
> Of course I didn't try very hard to force cache misses (eg using a big
> send/recv ring) and there may have been other things happening on the system
> causing a change between the two tests (separated by an hour or so).  I
> didn't make sure that interrupts stayed assigned to a specific CPU, nor that
> netperf did.  The kernel:
>
> root@raj-8510w:~# uname -a
> Linux raj-8510w 3.8.0-25-generic #37-Ubuntu SMP Thu Jun 6 20:47:30 UTC 2013
> i686 i686 i686 GNU/Linux
>
> In general, I suppose if you want to quantify the overhead of copies, you
> can try something like the two tests above, but for longer run times and
> with more intermediate data points, as you walk the request or response size
> up.  Watch the change in service demand as you go.  So long as you stay
> below 1472 bytes (assuming IPv4 over a "standard" 1500 byte MTU Ethernet)
> you won't generate fragments, and so will still have the same number of
> packets per transaction.
>
> Or you could "perf" profile and look for copy routines.
>
> happy benchmarking,
>
> rick jones

I make some tests with read/write operations....

fd: fd_in and fd_out are udp sockets
events: epoll


1) read
code:
...
cycles = rdtsc();
r = recvfrom(fd_in, rtp_buf, 8192, 0, si, &soi);
cycles = rdtsc() - cycles;
...
result:
Cycles best: 2715
Cycles worst: 59771
Cycles middle: 11587

2) write
code:
...
cycles = rdtsc();
w = sendto(fd_out, rtp_buf, r, 0, so, soo);
cycles = rdtsc() - cycles;
....

result:
Cycles best: 6501
Cycles worst: 75455
Cycles middle: 25496

Kernel:
# uname -a
Linux host49-250 3.2.0-29-generic #46-Ubuntu SMP Fri Jul 27 17:03:23
UTC 2012 x86_64 x86_64 x86_64 GNU/Linux

CPU:
vendor_id       : GenuineIntel
cpu family      : 6
model           : 58
model name      : Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
stepping        : 9
microcode       : 0x12
cpu MHz         : 1600.000
cache size      : 8192 KB
physical id     : 0
siblings        : 8
core id         : 3
cpu cores       : 4
apicid          : 7
initial apicid  : 7
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl
xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl
vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida arat epb
xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase
smep erms
bogomips        : 6599.78
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:
