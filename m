From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] perf_counter: change cpu frequencies
Date: Mon, 04 May 2009 12:39:29 +0200
Message-ID: <49FEC5E1.4040900@cosmosbay.com>
References: <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com> <20090429091130.GA27857@elte.hu> <49F9821C.5010802@cosmosbay.com> <20090430115736.GA24349@elte.hu> <49F9B0F0.40306@cosmosbay.com> <49F9CCD0.2080005@cosmosbay.com> <49FD347F.6030306@cosmosbay.com> <20090503072535.GA9455@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38921 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbZEDKkl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 06:40:41 -0400
In-Reply-To: <20090503072535.GA9455@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Eric Dumazet a =E9crit :
>>> Eric Dumazet a =E9crit :
>>> =20
>>>> But if I use plain "perf stat -a sleep 10"
>>>> it seems I get wrong values again (16 G cycles/sec) for all next p=
erf sessions
>>>>
>>> Well, I confirm all my cpus switched from 3GHz to 2GHz, after
>>>
>>> "perf stat -a sleep 10"
>>>
>>> (but "perf stat -e instructions -e cycles -a sleep 10" doesnt trigg=
er this problem)
>>>
>>> Nothing logged, and /proc/cpuinfo stills reports 3 GHz frequencies
>>>
>>> # cat unit.c
>>> main() {
>>>   int i;
>>>   for (i =3D 0 ; i < 10000000; i++)
>>>         getppid();
>>> }
>>> # time ./unit
>>>
>>> real    0m0.818s
>>> user    0m0.289s
>>> sys     0m0.529s
>>> # perf stat -a sleep 10 2>/dev/null
>>> # time ./unit
>>>
>>> real    0m1.122s
>>> user    0m0.482s
>>> sys     0m0.640s
>>>
>>> # tail -n 27 /proc/cpuinfo
>>> processor       : 7
>>> vendor_id       : GenuineIntel
>>> cpu family      : 6
>>> model           : 23
>>> model name      : Intel(R) Xeon(R) CPU           E5450  @ 3.00GHz
>>> stepping        : 6
>>> cpu MHz         : 3000.102
>>> cache size      : 6144 KB
>>> physical id     : 1
>>> siblings        : 1
>>> core id         : 3
>>> cpu cores       : 4
>>> apicid          : 7
>>> initial apicid  : 7
>>> fdiv_bug        : no
>>> hlt_bug         : no
>>> f00f_bug        : no
>>> coma_bug        : no
>>> fpu             : yes
>>> fpu_exception   : yes
>>> cpuid level     : 10
>>> wp              : yes
>>> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr =
pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe =
lm constant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est=
 tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriori=
ty
>>> bogomips        : 6000.01
>>> clflush size    : 64
>>> power management:
>>>
>>> # grep CPU_FREQ .config
>>> # CONFIG_CPU_FREQ is not set
>>>
>>>
>>> perf_counter seems promising, but still... needs some bug hunting :=
)
>>>
>> Update :
>>
>> Mike Galbraith suggested me to try various things, and finally, I di=
scovered
>> this frequency change was probably a BIOS problem on my HP BL460c G1
>>
>> System Options -> Power regulator for Proliant
>>
>> [*] HP Dynamic Power Savings Mode
>> [ ] HP Static Low Power Mode
>> [ ] HP Static High Performance Mode
>> [ ] OS Control Mode
>>
>>
>> I switched it to 'OS Control Mode'
>>
>> Then acpi-cpufreq could load, and no more frequencies changes on a "=
perf -a sleep 10"=20
>> session, using or not cpufreq.
>> (Supported cpufreq speeds on these cpus : 1999 & 2999 MHz)
>>
>> So it was a BIOS issue
>=20
> ah! That makes quite a bit of sense. The BIOS interfering with an OS=20
> feature ... Was that the default setting in the BIOS?

This was default setting in BIOS, yes.

>=20
>> # perf stat -a sleep 10
>>
>>  Performance counter stats for 'sleep':
>>
>>    80005.418223  task clock ticks     (msecs)
>>           80266  context switches     (events)
>>               3  CPU migrations       (events)
>>             486  pagefaults           (events)
>>    240013851624  CPU cycles           (events) << good >>
>>    239076501419  instructions         (events)
>>          679464  cache references     (events)
>>   <not counted>  cache misses
>>
>>  Wall-clock time elapsed: 10000.468808 msecs
>=20
> That looks perfect now.
>=20
> It would also be really nice to have a sysrq-p dump of your PMU=20
> state before you've done any profiling. Is there any trace of the=20
> BIOS meddling with them, that we could detect (and warn about)=20
> during bootup?

Difference is that on BIOS set to 'OS Control Mode' I see one more entr=
y in ACPI list :

[    0.000000] ACPI: SSDT cfe5b000 004C9 (v01 HP        SSDTP 00000001 =
INTL 20030228)

=2E..
And these 8 additional lines after (one per cpu)
[    0.706697] ACPI: SSDT cfe5c000 002DA (v01 HP        SSDT0 00000001 =
INTL 20030228)
[    0.707250] ACPI: SSDT cfe5c300 002DA (v01 HP        SSDT1 00000001 =
INTL 20030228)
[    0.707768] ACPI: SSDT cfe5c600 002DA (v01 HP        SSDT2 00000001 =
INTL 20030228)
[    0.708376] ACPI: SSDT cfe5c900 002DF (v01 HP        SSDT3 00000001 =
INTL 20030228)
[    0.708964] ACPI: SSDT cfe5cc00 002DA (v01 HP        SSDT4 00000001 =
INTL 20030228)
[    0.709567] ACPI: SSDT cfe5cf00 002DA (v01 HP        SSDT5 00000001 =
INTL 20030228)
[    0.710122] ACPI: SSDT cfe5d200 002DA (v01 HP        SSDT6 00000001 =
INTL 20030228)
[    0.710713] ACPI: SSDT cfe5d500 002DA (v01 HP        SSDT7 00000001 =
INTL 20030228)

Also, if this option is set to default (HP Dynamic Power Savings Mode) =
I get :

# modprobe acpi-cpufreq
=46ATAL: Error inserting acpi_cpufreq (/lib/modules/2.6.30-rc4-tip-0156=
0-gdd5fa92/kernel/arch/x86/kernel/cpu/cpufreq/acpi-cpufreq.ko): No such=
 device

but no kernel message logged.

Might be possible to add some kind of warning yes, I can test a patch i=
f you want.


