From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 17:57:58 +0100
Message-ID: <200702201757.58406.dada1@cosmosbay.com>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44430 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030266AbXBTQ6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:58:09 -0500
In-Reply-To: <20070220162714.GA3245@outpost.ds9a.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 17:27, bert hubert wrote:
> On Tue, Feb 20, 2007 at 11:50:13AM +0100, Andi Kleen wrote:
> > P4s are pretty slow at taking locks (or rather doing atomical operations)
> > and there are several of them in this path. You could try it with a UP
> > kernel. Actually hotunplugging the other virtual CPU should be sufficient
> > with recent kernels.
>
> This is on a UP kernel, on a single CPU. It does have hyperthreading, but
> the kernel is uniprocessor, non-preempt. No frequency scaling. Linux
> 2.6.20-rc4, 2.6.19, 2.6.18, P4, P-M, Athlon 64. Ubunty Edgy Eft on the P4.
>
> > Also BTW RDTSC on P4 is not very accurate for small measurements
> > because it has a quite high overhead by itself, i would suggest
> > running it in a loop.
>
> I've done so, with some interesting results. Source on
> http://ds9a.nl/tmp/recvtimings.c - be careful to adjust the '3000' divider
> to your CPU frequency if you care about absolute numbers!
>
> These are two groups, each consisting of 10 consecutive nonblocking UDP
> recvfroms, with 10 packets preloaded. Reported is the number of
> microseconds per recvfrom call which yielded a packet:
>
> $ ./recvtimings
> 4.142333
> 2.237667
> 1.927333
> 1.580000
> 1.770000
> 1.632333
> 1.712667
> 1.685000
> 1.620000
> 2.415000
> 1.347333
> 1.545000
> 1.492667
> 1.902333
> 1.485000
> 1.532667
> 1.460000
> 1.517667
> 1.492333
> 1.580000
>
> This in a nearly quiet P4 - I've removed the first line:
> $ vmstat 1
> procs -----------memory---------- ---swap-- -----io---- -system--
> ----cpu---- r  b   swpd   free   buff  cache   si   so    bi    bo   in  
> cs us sy id wa 0  0      0 290064 307036 296036    0    0     0     0  124 
>  58  0  0 100  0 0  0      0 289972 307036 296036    0    0     0     4 
> 139   95  0  0 100  0 0  0      0 289972 307036 296036    0    0     0    
> 0  119   55  0  0 100  0 1  0      0 289972 307036 296036    0    0     0  
>   0  135   71  0  0 100  0
>
> HZ is clearly 100. If I usleep in between, timings for each recvfrom call
> become higher. If I sleep for a full second, I get nearly flat results:
> 4.250000
> 5.317667
> 3.525000
> 4.147333
> 3.360000
> 3.552667
> 3.087667
>
> Various differing CPUs report more or less the same results. Now I know we
> have caching effects, but these effects are HUGE.
>
> Is this supposed to be the case? I'm on an up to date system, glibc 2.4.
>
> 	Bert

Here are my results :

(I did change your program, to have the /1600.0 divide)
(my kernel is SMP, but my machine is UP)

$ uname -a
Linux ubuntu 2.6.20 #5 SMP Wed Feb 7 18:32:11 CET 2007 i686 GNU/Linux
$ cat /proc/cpuinfo 
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 13
model name      : Intel(R) Pentium(R) M processor 1.60GHz
stepping        : 8
cpu MHz         : 1596.065
cache size      : 2048 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat clflush dts acpi mmx fxsr sse sse2 ss tm pbe nx up est tm2
bogomips        : 3195.41
clflush size    : 64

$ ./recvtimings
4.175625
1.398125
1.264375
1.288125
1.102500
1.106875
1.318750
1.276250
1.237500
1.408750
0.971250
1.075625
1.083750
1.075625
1.098125
1.112500
1.109375
1.072500
1.114375
1.080625

For info, getppid() system call gives : 0.156250, and umask(0) gives 0.191875
1.102500 for a much more complex syscall seems OK for me.


