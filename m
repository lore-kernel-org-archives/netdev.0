From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v6 4/9] Always Running Timer (ART) correlated clocksource
Date: Thu, 14 Jan 2016 14:00:18 -0800
Message-ID: <CALAqxLXaRwbmPLcWgxuDxY6MaQw_65nDzP_ELZ=5GeHm8cgEBw@mail.gmail.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
	<1452687149-11281-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452687149-11281-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 4:12 AM, Christopher S. Hall
<christopher.s.hall@intel.com> wrote:
> diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
> index c7c4d9c..26dcf63 100644
> --- a/arch/x86/kernel/tsc.c
> +++ b/arch/x86/kernel/tsc.c
> @@ -949,10 +949,36 @@ static struct notifier_block time_cpufreq_notifier_block = {
>         .notifier_call  = time_cpufreq_notifier
>  };
>
> +#define ART_CPUID_LEAF (0x15)
> +/* The denominator will never be less that 2 */
> +#define ART_MIN_DENOMINATOR (2)
> +
> +static u32 art_to_tsc_numerator;
> +static u32 art_to_tsc_denominator;

This is declared in a #ifdef CONFIG_CPU_FREQ


> @@ -1071,6 +1097,24 @@ int unsynchronized_tsc(void)
>         return 0;
>  }
>
> +/*
> + * Convert ART to TSC given numerator/denominator found in detect_art()
> + */
> +static u64 convert_art_to_tsc(struct correlated_cs *cs, u64 cycles)
> +{
> +       u64 tmp, res;
> +
> +       res = (cycles / art_to_tsc_denominator) * art_to_tsc_numerator;
> +       tmp = (cycles % art_to_tsc_denominator) * art_to_tsc_numerator;
> +       res += tmp / art_to_tsc_denominator;

Then used outside of that block.

So this won't build if CPU_FREQ is disabled.

But don't bother to fix that, as I've already done so and I've got a
bunch of tweaks I'm making to the code (I figured I'd done enough
nit-picking reviews, and probably should just roll my sleeves up and
take a swing at how I'd prefer the code look - including Richard's
suggestions as well).

I'll send you my revisions here shortly and hopefully you can let me
know if anything goes too far and hopefully do some testing with it.

thanks
-john
