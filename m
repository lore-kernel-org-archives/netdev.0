From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] perf_counter: change cpu frequencies
Date: Sun, 03 May 2009 08:06:55 +0200
Message-ID: <49FD347F.6030306@cosmosbay.com>
References: <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com> <20090429091130.GA27857@elte.hu> <49F9821C.5010802@cosmosbay.com> <20090430115736.GA24349@elte.hu> <49F9B0F0.40306@cosmosbay.com> <49F9CCD0.2080005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752836AbZECGIT@vger.kernel.org>
In-Reply-To: <49F9CCD0.2080005@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
> =20
>> But if I use plain "perf stat -a sleep 10"
>> it seems I get wrong values again (16 G cycles/sec) for all next per=
f sessions
>>
>=20
> Well, I confirm all my cpus switched from 3GHz to 2GHz, after
>=20
> "perf stat -a sleep 10"
>=20
> (but "perf stat -e instructions -e cycles -a sleep 10" doesnt trigger=
 this problem)
>=20
> Nothing logged, and /proc/cpuinfo stills reports 3 GHz frequencies
>=20
> # cat unit.c
> main() {
>   int i;
>   for (i =3D 0 ; i < 10000000; i++)
>         getppid();
> }
> # time ./unit
>=20
> real    0m0.818s
> user    0m0.289s
> sys     0m0.529s
> # perf stat -a sleep 10 2>/dev/null
> # time ./unit
>=20
> real    0m1.122s
> user    0m0.482s
> sys     0m0.640s
>=20
> # tail -n 27 /proc/cpuinfo
> processor       : 7
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Xeon(R) CPU           E5450  @ 3.00GHz
> stepping        : 6
> cpu MHz         : 3000.102
> cache size      : 6144 KB
> physical id     : 1
> siblings        : 1
> core id         : 3
> cpu cores       : 4
> apicid          : 7
> initial apicid  : 7
> fdiv_bug        : no
> hlt_bug         : no
> f00f_bug        : no
> coma_bug        : no
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pg=
e mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe lm=
 constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est t=
m2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
> bogomips        : 6000.01
> clflush size    : 64
> power management:
>=20
> # grep CPU_FREQ .config
> # CONFIG_CPU_FREQ is not set
>=20
>=20
> perf_counter seems promising, but still... needs some bug hunting :)
>=20

Update :

Mike Galbraith suggested me to try various things, and finally, I disco=
vered
this frequency change was probably a BIOS problem on my HP BL460c G1

System Options -> Power regulator for Proliant

[*] HP Dynamic Power Savings Mode
[ ] HP Static Low Power Mode
[ ] HP Static High Performance Mode
[ ] OS Control Mode


I switched it to 'OS Control Mode'

Then acpi-cpufreq could load, and no more frequencies changes on a "per=
f -a sleep 10"=20
session, using or not cpufreq.
(Supported cpufreq speeds on these cpus : 1999 & 2999 MHz)

So it was a BIOS issue

# perf stat -a sleep 10

 Performance counter stats for 'sleep':

   80005.418223  task clock ticks     (msecs)
          80266  context switches     (events)
              3  CPU migrations       (events)
            486  pagefaults           (events)
   240013851624  CPU cycles           (events) << good >>
   239076501419  instructions         (events)
         679464  cache references     (events)
  <not counted>  cache misses

 Wall-clock time elapsed: 10000.468808 msecs

Thank you
