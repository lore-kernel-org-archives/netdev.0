From: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v7 6/8] x86: tsc: Always Running Timer (ART) correlated
 clocksource
Date: Thu, 18 Feb 2016 13:11:33 -0800
Message-ID: <56C63385.9050703@kernel.org>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-7-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: x86@kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	tglx@linutronix.de, richardcochran@gmail.com, mingo@redhat.com,
	john.stultz@linaro.org, hpa@zytor.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455308729-6280-7-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/12/2016 12:25 PM, Christopher S. Hall wrote:
> On modern Intel systems TSC is derived from the new Always Running Ti=
mer
> (ART). ART can be captured simultaneous to the capture of
> audio and network device clocks, allowing a correlation between timeb=
ases
> to be constructed. Upon capture, the driver converts the captured ART
> value to the appropriate system clock using the correlated clocksourc=
e
> mechanism.
>
> On systems that support ART a new CPUID leaf (0x15) returns parameter=
s
> =E2=80=9Cm=E2=80=9D and =E2=80=9Cn=E2=80=9D such that:
>
> TSC_value =3D (ART_value * m) / n + k [n >=3D 2]
>
> [k is an offset that can adjusted by a privileged agent. The
> IA32_TSC_ADJUST MSR is an example of an interface to adjust k.
> See 17.14.4 of the Intel SDM for more details]
>
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> [jstultz: Tweaked to fix build issue, also reworked math for
> 64bit division on 32bit systems]
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>   arch/x86/include/asm/cpufeature.h |  3 ++-
>   arch/x86/include/asm/tsc.h        |  2 ++
>   arch/x86/kernel/cpu/scattered.c   |  1 +
>   arch/x86/kernel/tsc.c             | 50 ++++++++++++++++++++++++++++=
+++++++++++
>   4 files changed, 55 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm=
/cpufeature.h
> index 7ad8c94..111b892 100644
> --- a/arch/x86/include/asm/cpufeature.h
> +++ b/arch/x86/include/asm/cpufeature.h
> @@ -85,7 +85,7 @@
>   #define X86_FEATURE_P4		( 3*32+ 7) /* "" P4 */
>   #define X86_FEATURE_CONSTANT_TSC ( 3*32+ 8) /* TSC ticks at a const=
ant rate */
>   #define X86_FEATURE_UP		( 3*32+ 9) /* smp kernel running on up */
> -/* free, was #define X86_FEATURE_FXSAVE_LEAK ( 3*32+10) * "" FXSAVE =
leaks FOP/FIP/FOP */
> +#define X86_FEATURE_ART		(3*32+10) /* Platform has always running ti=
mer (ART) */
>   #define X86_FEATURE_ARCH_PERFMON ( 3*32+11) /* Intel Architectural =
PerfMon */
>   #define X86_FEATURE_PEBS	( 3*32+12) /* Precise-Event Based Sampling=
 */
>   #define X86_FEATURE_BTS		( 3*32+13) /* Branch Trace Store */
> @@ -188,6 +188,7 @@
>
>   #define X86_FEATURE_CPB		( 7*32+ 2) /* AMD Core Performance Boost *=
/
>   #define X86_FEATURE_EPB		( 7*32+ 3) /* IA32_ENERGY_PERF_BIAS suppor=
t */
> +#define X86_FEATURE_INVARIANT_TSC (7*32+4) /* Intel Invariant TSC */

How is this related to the rest of the patch?

> +/*
> + * Convert ART to TSC given numerator/denominator found in detect_ar=
t()
> + */
> +struct system_counterval_t convert_art_to_tsc(cycle_t art)
> +{
> +	u64 tmp, res, rem;
> +
> +	rem =3D do_div(art, art_to_tsc_denominator);
> +
> +	res =3D art * art_to_tsc_numerator;
> +	tmp =3D rem * art_to_tsc_numerator;
> +
> +	do_div(tmp, art_to_tsc_denominator);
> +	res +=3D tmp;
> +
> +	return (struct system_counterval_t) {.cs =3D art_related_clocksourc=
e,
> +			.cycles =3D res};

The SDM and the patch description both mention an offset "k".  Shouldn'=
t=20
this code at least have a comment about how it deals with the k !=3D 0 =
case?

--Andy
