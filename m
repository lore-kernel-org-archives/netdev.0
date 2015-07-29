From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH 3/5] Add calls to translate Always Running Timer (ART)
 to system time
Date: Wed, 29 Jul 2015 01:18:43 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A909CECC@ORSMSX109.amr.corp.intel.com>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
 <1438044416-15588-4-git-send-email-christopher.s.hall@intel.com>
 <55B6DBAA.6020902@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Borislav Petkov <bp@alien8.de>
To: 'Andy Lutomirski' <luto@kernel.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B6DBAA.6020902@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andy Lutomirski [mailto:luto@kernel.org]
> Sent: Monday, July 27, 2015 6:32 PM
> To: Hall, Christopher S; john.stultz@linaro.org; tglx@linutronix.de;
> richardcochran@gmail.com; mingo@redhat.com; Kirsher, Jeffrey T; Ronciak,
> John; hpa@zytor.com; x86@kernel.org
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Borislav
> Petkov
> Subject: Re: [PATCH 3/5] Add calls to translate Always Running Timer
> (ART) to system time
> 
> On 07/27/2015 05:46 PM, Christopher Hall wrote:
> > * art_to_mono64
> > * art_to_rawmono64
> > * art_to_realtime64
> >
> > Intel audio and PCH ethernet devices use the Always Running Timer
> (ART) to
> > relate their device clock to system time
> >
> > Signed-off-by: Christopher Hall <christopher.s.hall@intel.com>
> > ---
> >   arch/x86/Kconfig           |  12 ++++
> >   arch/x86/include/asm/art.h |  42 ++++++++++++++
> >   arch/x86/kernel/Makefile   |   1 +
> >   arch/x86/kernel/art.c      | 134
> +++++++++++++++++++++++++++++++++++++++++++++
> >   arch/x86/kernel/tsc.c      |   4 ++
> >   5 files changed, 193 insertions(+)
> >   create mode 100644 arch/x86/include/asm/art.h
> >   create mode 100644 arch/x86/kernel/art.c
> >
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index b3a1a5d..1ef9985 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -1175,6 +1175,18 @@ config X86_CPUID
> >   	  with major 203 and minors 0 to 31 for /dev/cpu/0/cpuid to
> >   	  /dev/cpu/31/cpuid.
> >
> > +config X86_ART
> > +	bool "Always Running Timer"
> > +	default y
> > +	depends on X86_TSC
> > +	---help---
> > +	  This option provides functionality to drivers and devices that
> use
> > +	  the always-running-timer (ART) to correlate their device clock
> > +	  counter with the system clock counter. The TSC is *exactly*
> related
> > +	  to the ART by a ratio m/n specified by CPUID leaf 0x15
> > +	  (n=EAX,m=EBX). If ART is unused or unavailable there isn't any
> > +	  performance impact. It's safe to say Y.
> > +
> 
> Is there a good reason to make this optional?

If there aren't any objections, it sound OK to me.  So no, I don't know
of any good reasons.

> 
> Also, is there *still* no way to ask the thing for its nominal
> frequnency?  Or can we expect CPUID leaf 16H to work on CPUs that
> support this and can we expect it to actually work?  

There isn't any way to query nominal frequency.  CPUID leaf 0x15 only
exposes the relationship between ART and TSC.  CPUID leaf 0x16 stays
the more or less the same and isn't related to ART.

The SDM says "The
> returned information should not be used for any other purpose as the
> returned information does not accurately correlate to information /
> counters returned by other processor interfaces."
> 
> Also, does this thing let us learn the real time base?  SDM 17.14.4
> suggests that the ART value isn't affected by "privileged software" (aka
> buggy/malicious firmware).  Or, alternatively, how do we learn the
> offset K between ART and scaled TSC?

ART isn't affected by software.  The determination of K used to convert ART to
TSC is in a footnote (2) in that section of the SDM.  I'm not going to risk
repeating it here and possibly altering its meaning.

> 
> >   choice
> >   	prompt "High Memory Support"
> >   	default HIGHMEM4G
> > diff --git a/arch/x86/include/asm/art.h b/arch/x86/include/asm/art.h
> > new file mode 100644
> > index 0000000..da58ce4
> > --- /dev/null
> > +++ b/arch/x86/include/asm/art.h
> > @@ -0,0 +1,42 @@
> > +/*
> > + * x86 ART related functions
> > + */
> > +#ifndef _ASM_X86_ART_H
> > +#define _ASM_X86_ART_H
> > +
> > +#ifndef CONFIG_X86_ART
> > +
> > +static inline int setup_art(void)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline bool has_art(void)
> > +{
> > +	return false;
> > +}
> > +
> > +static inline int art_to_rawmono64(struct timespec64 *rawmono,
> cycle_t art)
> > +{
> > +	return -ENXIO;
> > +}
> > +static inline int art_to_realtime64(struct timespec64 *realtime,
> cycle_t art)
> > +{
> > +	return -ENXIO;
> > +}
> > +static inline int art_to_mono64(struct timespec64 *mono, cycle_t art)
> > +{
> > +	return -ENXIO;
> > +}
> > +
> > +#else
> > +
> > +extern int setup_art(void);
> > +extern bool has_art(void);
> > +extern int art_to_rawmono64(struct timespec64 *rawmono, cycle_t art);
> > +extern int art_to_realtime64(struct timespec64 *realtime, cycle_t
> art);
> > +extern int art_to_mono64(struct timespec64 *mono, cycle_t art);
> > +
> > +#endif
> > +
> > +#endif/*_ASM_X86_ART_H*/
> > diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> > index 0f15af4..0908311 100644
> > --- a/arch/x86/kernel/Makefile
> > +++ b/arch/x86/kernel/Makefile
> > @@ -109,6 +109,7 @@ obj-$(CONFIG_PERF_EVENTS)		+=
> perf_regs.o
> >   obj-$(CONFIG_TRACING)			+= tracepoint.o
> >   obj-$(CONFIG_IOSF_MBI)			+= iosf_mbi.o
> >   obj-$(CONFIG_PMC_ATOM)			+= pmc_atom.o
> > +obj-$(CONFIG_X86_ART)			+= art.o
> >
> >   ###
> >   # 64 bit specific files
> > diff --git a/arch/x86/kernel/art.c b/arch/x86/kernel/art.c
> > new file mode 100644
> > index 0000000..1906cf0
> > --- /dev/null
> > +++ b/arch/x86/kernel/art.c
> > @@ -0,0 +1,134 @@
> > +#include <asm/tsc.h>
> > +#include <asm/cpufeature.h>
> > +#include <asm/processor.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/seqlock.h>
> > +
> > +#define CPUID_ART_LEAF 0x15
> > +
> > +static bool art_present;
> > +
> > +static struct art_state {
> > +	seqcount_t seq;
> > +	u32 art_ratio_numerator;
> > +	u32 art_ratio_denominator;
> > +
> 
> This needs much better comments, IMO, including some discussion of how
> the locking works.

I'll work on the comments for version 2.

> 
> > +	cycle_t prev_art;
> > +	cycle_t prev_tsc_corr_art; /*This is the TSC value corresponding
> to
> > +				     prev_art */
> > +	u32 tsc_remainder;
> > +} art_state ____cacheline_aligned;
> > +
> > +static DEFINE_RAW_SPINLOCK(art_lock);
> > +
> > +#define MIN_DENOMINATOR 2
> > +int setup_art(void)
> > +{
> > +	if (boot_cpu_data.cpuid_level < CPUID_ART_LEAF)
> > +		return 0;
> > +	art_state.art_ratio_denominator = cpuid_eax(CPUID_ART_LEAF);
> > +	if (art_state.art_ratio_denominator < MIN_DENOMINATOR)
> > +		return 0;
> > +	art_state.art_ratio_numerator = cpuid_ebx(CPUID_ART_LEAF);
> > +
> > +	art_present = true;
> > +	return 0;
> > +}
> > +
> > +static bool has_art(void)
> > +{
> > +	return art_present;
> > +}
> > +EXPORT_SYMBOL(has_art);
> 
> IMO this should be a pseudo-feature X86_FEATURE_ART.

Good idea.

> 
> > +
> > +#define ROLLOVER_THRESHOLD (2ULL << 23)
> > +
> > +static u32 art_scale(struct art_state *art_state, cycle_t *art)
> > +{
> > +	u32 rem;
> > +
> > +	*art *= art_state->art_ratio_numerator;
> 
> This seems very likely to overflow.

I don't think it would.  The art (u64) value is a delta:

tsc_next = art - art_state.prev_art;
rem_next = art_scale(&art_state, &tsc_next);

The time to overflow would depend upon the TSC frequency and m, n
values, but it should handle 10+ years of delta.

I think you should be using the
> equivalent of mul_u128_u64_shr (which probably doesn't exist, but
> mul_u64_u32_shr does) or just open-code it using __uint128_t if this
> thing is x86_64-only.
> 
> > +static cycle_t art_to_tsc(cycle_t art)
> > +{
> 
> This function needs some kind of description of what it does.

More descriptive comments for v2.

> 
> Also, I don't think it's okay to have a pure-sounding thing like
> art_to_xyz actually be stateful and rely on a current value being
> passed.

I guess I see your point, but I'm not sure how to change it.  Would
a more descriptive verb (e.g. "convert") address this?

> 
> Also, how does this code account for the unspecified ART-to-TSC offset?
>   I don't see it in the code on a quick reading.

It's not there.  The assumption is that the TSC adjust registers is 0.

Thanks for your comments.

Chris

> 
> --Andy
