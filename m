From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 2/4] Added ART correlated clocksource and ART CPU
 feature
Date: Sat, 22 Aug 2015 22:26:34 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1508222217040.3873@nanos>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com> <1440183128-1384-3-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, richardcochran@gmail.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440183128-1384-3-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Aug 2015, Christopher S. Hall wrote:

> Add detect_art() call to early TSC initialization which reads ART->TSC
> 	numerator/denominator and sets CPU feature if present
> 
> Add convert_art_to_tsc() function performing conversion ART to TSC
> 
> Add art_timestamp referencing art_to_tsc() and clocksource_tsc enabling
> 	driver conversion of ART to TSC

That changelog needs a rewrite. See patch 1/4

> @@ -352,6 +352,7 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
>  #define cpu_has_de		boot_cpu_has(X86_FEATURE_DE)
>  #define cpu_has_pse		boot_cpu_has(X86_FEATURE_PSE)
>  #define cpu_has_tsc		boot_cpu_has(X86_FEATURE_TSC)
> +#define cpu_has_art		boot_cpu_has(X86_FEATURE_ART)

Please do not add more cpu_has macros. There is nothing wrong to write
boot_cpu_has(X86_FEATURE_ART) in the code.

> +#define ART_CPUID_LEAF (0x15)
> +#define ART_MIN_DENOMINATOR (2)

#define ART_CPUID_LEAF	       0x15
#define ART_MIN_DENOMINATOR    2

Why is the minimum denominator 2? That wants a comment.

> +static u32 art_to_tsc_numerator;
> +static u32 art_to_tsc_denominator;

Both want to be read_mostly

> +/*
> + * If ART is present detect the numberator:denominator to convert to TSC
> + */
> +void detect_art(void)
> +{
> +	unsigned int unused[2];
> +
> +	if (boot_cpu_data.cpuid_level >= ART_CPUID_LEAF) {
> +		cpuid(ART_CPUID_LEAF, &art_to_tsc_denominator,
> +		      &art_to_tsc_numerator, unused, unused+1);
> +
> +		if (art_to_tsc_denominator >= ART_MIN_DENOMINATOR) {
> +			set_cpu_cap(&boot_cpu_data, X86_FEATURE_ART);
> +		}

No parentheses around one liners please.

> +	}
> +}
> +
>  static int __init cpufreq_tsc(void)
>  {
>  	if (!cpu_has_tsc)
>  		return 0;
> +
> +	detect_art();
> +
>  	if (boot_cpu_has(X86_FEATURE_CONSTANT_TSC))
>  		return 0;
>  	cpufreq_register_notifier(&time_cpufreq_notifier_block,
> @@ -1059,6 +1085,32 @@ int unsynchronized_tsc(void)
>  	return 0;
>  }
>  
> +/*
> + * Convert ART to TSC given numerator/denominator found in detect_art()
> + */
> +static u64 convert_art_to_tsc(struct correlated_cs *cs, u64 cycles)
> +{
> +	u64 tmp, res;
> +
> +	switch (art_to_tsc_denominator) {
> +	default:
> +		res = (cycles / art_to_tsc_denominator) * art_to_tsc_numerator;
> +		tmp = (cycles % art_to_tsc_denominator) * art_to_tsc_numerator;
> +		res += tmp / art_to_tsc_denominator;
> +		break;
> +	case 2:
> +	       res = (cycles >> 1) * art_to_tsc_numerator;
> +	       tmp = (cycles & 0x1) * art_to_tsc_numerator;
> +	       res += tmp >> 1;
> +	       break;

Is it really worth do do this optimization? And if we do it we
shouldn't special case it for 2. You can check at ART detection time
whether the denominator is a power of two and have a flag which
selects a div/mod base or a shift based conversion.

Thanks,

	tglx
