From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 2/2] x86: add prefetching to do_csum
Date: Thu, 7 Nov 2013 16:23:41 -0500
Message-ID: <20131107212341.GA9709@hmsreliant.think-freely.org>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <1383751399-10298-1-git-send-email-nhorman@tuxdriver.com>
 <1383751399-10298-3-git-send-email-nhorman@tuxdriver.com>
 <87iow58eqf.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33204 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763Ab3KGVX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:23:56 -0500
Content-Disposition: inline
In-Reply-To: <87iow58eqf.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 12:19:52PM -0800, Andi Kleen wrote:
> Neil Horman <nhorman@tuxdriver.com> writes:
> 
> > do_csum was identified via perf recently as a hot spot when doing
> > receive on ip over infiniband workloads.  After alot of testing and
> > ideas, we found the best optimization available to us currently is to
> > prefetch the entire data buffer prior to doing the checksum
> 
> On what CPU? Most modern CPUs should not have any trouble at all
> prefetching a linear access.
> 
> Also for large buffers it is unlikely that all the prefetches
> are actually executed, there is usually some limit.
> 
> As a minimum you would need:
> - run it with a range of buffer sizes
> - run this on a range of different CPUs and show no major regressions
> - describe all of this actually in the description
> 
> But I find at least this patch very dubious.
> 
> -Andi
> 
Well, if you look back in the thread, you can see several tests done with
various forms of prefetching, that show performance improvements, but if you
want them all collected, heres what I have, using the perf bench from patch 1.

As you can see, you're right, on newer hardware theres negligible advantage (but
no regression that I can see).  On older hardware however, we see a definate
improvement (up to 3%).  I'm afraid I don't have a wide variety of hardware
handy at the moment to do any large scale testing on multiple cpu's.  But if you
have them available, please share your results


Regards
Neil



vendor_id       : AuthenticAMD
cpu family      : 16
model           : 8
model name      : AMD Opteron(tm) Processor 4130
stepping        : 0
microcode       : 0x10000da
cpu MHz         : 800.000
cache size      : 512 KB
physical id     : 1
siblings        : 4
core id         : 3
cpu cores       : 4
apicid          : 11
initial apicid  : 11
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp
lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid pni monitor
cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse
3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv svm_lock
nrip_save pausefilter
bogomips        : 5200.49
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

Without prefecth:
length	| Set Sz| iterations	| cycles/byte
1500B	| 64MB  | 1000000       | 1.432338
1500B   | 128MB | 1000000       | 1.426212
1500B   | 256MB | 1000000       | 1.425988
1500B   | 512MB | 1000000       | 1.517873
9000B   | 64MB  | 1000000       | 0.897998
9000B   | 128MB | 1000000       | 0.884120
9000B   | 256MB | 1000000       | 0.881770
9000B   | 512MB | 1000000       | 0.883644
64KB    | 64MB  | 1000000       | 0.813054
64KB    | 128MB | 1000000       | 0.801859
64KB    | 256MB | 1000000       | 0.796415
64KB    | 512MB | 1000000       | 0.793869

With prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B	| 64MB	| 1000000	| 1.442855
1500B	| 128MB	| 1000000	| 1.438841
1500B	| 256MB	| 1000000	| 1.427324
1500B	| 512MB	| 1000000	| 1.462715 
9000B	| 64MB	| 1000000	| 0.894097 
9000B	| 128MB	| 1000000	| 0.884738 
9000B	| 256MB	| 1000000	| 0.881370  
9000B	| 512MB	| 1000000	| 0.884799 
64KB	| 64MB	| 1000000	| 0.813512 
64KB	| 128MB	| 1000000	| 0.801596 
64KB	| 256MB	| 1000000	| 0.795575  
64KB	| 512MB	| 1000000	| 0.793927 


==========================================================================================

vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz
stepping        : 7
microcode       : 0x29
cpu MHz         : 2754.000
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
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm
constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc
aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3
cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx
lahf_lm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept
vpid
bogomips        : 6784.46
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual


Without prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 1.343645
1500B   | 128MB | 1000000       | 1.345782
1500B   | 256MB | 1000000       | 1.353145
1500B   | 512MB | 1000000       | 1.354844
9000B   | 64MB  | 1000000       | 0.856552
9000B   | 128MB | 1000000       | 0.852786
9000B   | 256MB | 1000000       | 0.854705
9000B   | 512MB | 1000000       | 0.863308
64KB    | 64MB  | 1000000       | 0.771888
64KB    | 128MB | 1000000       | 0.773453
64KB    | 256MB | 1000000       | 0.771728
64KB    | 512MB | 1000000       | 0.771390

With prefetching:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 1.344733
1500B   | 128MB | 1000000       | 1.342285
1500B   | 256MB | 1000000       | 1.344818
1500B   | 512MB | 1000000       | 1.342632
9000B   | 64MB  | 1000000       | 0.851043
9000B   | 128MB | 1000000       | 0.850629
9000B   | 256MB | 1000000       | 0.852207
9000B   | 512MB | 1000000       | 0.851927
64KB    | 64MB  | 1000000       | 0.768549
64KB    | 128MB | 1000000       | 0.768623
64KB    | 256MB | 1000000       | 0.768938
64KB    | 512MB | 1000000       | 0.768824

==========================================================================================
vendor_id       : AuthenticAMD
cpu family      : 16
model           : 9
model name      : AMD Opteron(tm) Processor 6172
stepping        : 1
microcode       : 0x10000d9
cpu MHz         : 800.000
cache size      : 512 KB
physical id     : 1
siblings        : 12
core id         : 5
cpu cores       : 12
apicid          : 43
initial apicid  : 27
fpu             : yes
fpu_exception   : yes
cpuid level     : 5
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp
lm 3dnowext 3dnow constant_tsc rep_good nopl nonstop_tsc extd_apicid amd_dcm pni
monitor cx16 popcnt lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a
misalignsse 3dnowprefetch osvw ibs skinit wdt nodeid_msr hw_pstate npt lbrv
svm_lock nrip_save pausefilter
bogomips        : 4189.63
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 48 bits physical, 48 bits virtual
power management: ts ttp tm stc 100mhzsteps hwpstate

Without prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 1.415370
1500B   | 128MB | 1000000       | 1.437025
1500B   | 256MB | 1000000       | 1.424822
1500B   | 512MB | 1000000       | 1.442021
9000B   | 64MB  | 1000000       | 0.891699
9000B   | 128MB | 1000000       | 0.884261
9000B   | 256MB | 1000000       | 0.880179
9000B   | 512MB | 1000000       | 0.882190
64KB    | 64MB  | 1000000       | 0.813047
64KB    | 128MB | 1000000       | 0.800755
64KB    | 256MB | 1000000       | 0.795207
64KB    | 512MB | 1000000       | 0.792065

With prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 1.424003
1500B   | 128MB | 1000000       | 1.435567
1500B   | 256MB | 1000000       | 1.446858
1500B   | 512MB | 1000000       | 1.459407
9000B   | 64MB  | 1000000       | 0.899858
9000B   | 128MB | 1000000       | 0.885170
9000B   | 256MB | 1000000       | 0.883936
9000B   | 512MB | 1000000       | 0.886158
64KB    | 64MB  | 1000000       | 0.814136
64KB    | 128MB | 1000000       | 0.802202
64KB    | 256MB | 1000000       | 0.796140
64KB    | 512MB | 1000000       | 0.793792



==========================================================================================
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 10
model name      : AMD Athlon(tm) XP 2800+
stepping        : 0
cpu MHz         : 2079.461
cache size      : 512 KB
fdiv_bug        : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow
bogomips        : 4158.92
clflush size    : 32
cache_alignment : 32
address sizes   : 34 bits physical, 32 bits virtual
power management: ts

Without prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 3.335217
1500B   | 128MB | 1000000       | 3.403103
1500B   | 256MB | 1000000       | 3.445059
1500B   | 512MB | 1000000       | 3.742008
9000B   | 64MB  | 1000000       | 47.466255
9000B   | 128MB | 1000000       | 47.742751
9000B   | 256MB | 1000000       | 47.965001
9000B   | 512MB | 1000000       | 48.589349
64KB    | 64MB  | 1000000       | 118.088638
64KB    | 128MB | 1000000       | 118.261744
64KB    | 256MB | 1000000       | 118.349641
64KB    | 512MB | 1000000       | 118.695321

With prefetch:
length	| Set Sz| iterations	| cycles/byte
1500B   | 64MB  | 1000000       | 3.231086
1500B   | 128MB | 1000000       | 3.423485
1500B   | 256MB | 1000000       | 3.278899
1500B   | 512MB | 1000000       | 3.545504
9000B   | 64MB  | 1000000       | 46.907795
9000B   | 128MB | 1000000       | 47.321743
9000B   | 256MB | 1000000       | 47.306189
9000B   | 512MB | 1000000       | 48.144320
64KB    | 64MB  | 1000000       | 117.897735
64KB    | 128MB | 1000000       | 118.122266
64KB    | 256MB | 1000000       | 118.126397
64KB    | 512MB | 1000000       | 118.546901
