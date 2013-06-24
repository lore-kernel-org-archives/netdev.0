From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 14:33:50 -0700
Message-ID: <51C8BB3E.8090701@hp.com>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com> <1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com> <20130624155154.GD10413@order.stressinduktion.org> <1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com> <20130624170119.GE10413@order.stressinduktion.org> <CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com> <1372096418.3301.75.camel@edumazet-glaptop> <CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Ricardo Landim <ricardolan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:39681 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3FXVdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 17:33:51 -0400
In-Reply-To: <CACYKsS4brDSL4gWGV8Aw455qqa-mdhE_=C7pFS-V=qaA7FBa6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2013 11:08 AM, Ricardo Landim wrote:
> Help in zero copy and improve in cost of syscalls.
>
> In my intel xeon(3.3ghz), read udp socket and write udp socket (proxy)
> spends ~40000 cycles (~12 us).

Are you quite certain your Xeon was actually running at 3.3GHz at the 
time?  I just did a quick netperf UDP_RR test between an old 
Centrino-based laptop (HP 8510w) pegged at 1.6 GHz (cpufreq-set) and it 
was reporting a service demand of 12.2 microseconds per transaction, 
which is, basically, a send and recv pair plus stack:

root@raj-8510w:~# netperf -t UDP_RR -c -i 30,3 -H tardy.usa.hp.com -- -r 
140,1MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET 
to tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  : demo : 
first burst 0
!!! WARNING
!!! Desired confidence was not achieved within the specified iterations.
!!! This implies that there was variability in the test environment that
!!! must be investigated before going further.
!!! Confidence intervals: Throughput      : 1.120%
!!!                       Local CPU util  : 6.527%
!!!                       Remote CPU util : 0.000%

Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr

180224 180224 140     1      10.00   12985.58   7.93   -1.00  12.221 
-1.000
212992 212992

(Don't fret too much about the confidence intervals bit, it almost made it.)

Also, my 1400 byte test didn't have all that different a service demand:

root@raj-8510w:~# netperf -t UDP_RR -c -i 30,3 -H tardy.usa.hp.com -- -r 
1400,1
MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to 
tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  : demo : 
first burst 0
!!! WARNING
!!! Desired confidence was not achieved within the specified iterations.
!!! This implies that there was variability in the test environment that
!!! must be investigated before going further.
!!! Confidence intervals: Throughput      : 1.123%
!!!                       Local CPU util  : 6.991%
!!!                       Remote CPU util : 0.000%

Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr

180224 180224 1400    1      10.00   10055.33   6.27   -1.00  12.469 
-1.000
212992 212992

Of course I didn't try very hard to force cache misses (eg using a big 
send/recv ring) and there may have been other things happening on the 
system causing a change between the two tests (separated by an hour or 
so).  I didn't make sure that interrupts stayed assigned to a specific 
CPU, nor that netperf did.  The kernel:

root@raj-8510w:~# uname -a
Linux raj-8510w 3.8.0-25-generic #37-Ubuntu SMP Thu Jun 6 20:47:30 UTC 
2013 i686 i686 i686 GNU/Linux

In general, I suppose if you want to quantify the overhead of copies, 
you can try something like the two tests above, but for longer run times 
and with more intermediate data points, as you walk the request or 
response size up.  Watch the change in service demand as you go.  So 
long as you stay below 1472 bytes (assuming IPv4 over a "standard" 1500 
byte MTU Ethernet) you won't generate fragments, and so will still have 
the same number of packets per transaction.

Or you could "perf" profile and look for copy routines.

happy benchmarking,

rick jones
