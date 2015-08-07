From: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2 1/4] Add generic correlated clocksource code and ART to
 TSC conversion code
Date: Fri, 7 Aug 2015 16:44:37 -0700
Message-ID: <55C542E5.2000100@kernel.org>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
 <1438988495-9942-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>,
	john.stultz@linaro.org, tglx@linutronix.de,
	richardcochran@gmail.com, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58853 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946338AbbHGXok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 19:44:40 -0400
In-Reply-To: <1438988495-9942-2-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2015 04:01 PM, Christopher Hall wrote:
> Original patch description:
>
> Subject: ptp: Get sync timestamps
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Wed, 29 Jul 2015 10:52:06 +0200
>
> The ART stuff wants to be splitted out.
>
> ======== Changes =======
>
> Add struct correlated_cs (clocksource) with pointer to original clocksource
> 	and function pointer to convert correlated clocksource to the original
>
> Add struct correlated_ts (timestamp) with function pointer to read correlated
> 	clocksource, device and system (in terms of correlated clocksource)
> 	counter values (input) with resulting converted real and monotonic raw
> 	system times (output)
>
> Add get_correlated_timestamp() function which given specific correlated_cs
> 	and correlated_ts convert correlated counter value to system time
>
> Add art_to_tsc conversion function translated Always Running Timer (ART) to
> 	TSC value
> ---
>   arch/x86/kernel/tsc.c       | 31 ++++++++++++++++++++++
>   include/linux/clocksource.h | 30 +++++++++++++++++++++
>   include/linux/timekeeping.h |  4 +++
>   kernel/time/timekeeping.c   | 63 +++++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 128 insertions(+)
>
> diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
> index 7437b41..a90aa6a 100644
> --- a/arch/x86/kernel/tsc.c
> +++ b/arch/x86/kernel/tsc.c
> @@ -1059,6 +1059,27 @@ int unsynchronized_tsc(void)
>   	return 0;
>   }
>
> +static u32 tsc_numerator;
> +static u32 tsc_denominator;
> +/*
> + * CHECKME: Do we need the adjust value? It should be 0, but if we run
> + * in a VM this might be a different story.
> + */
> +static u64 tsc_adjust;
> +
> +static u64 art_to_tsc(u64 cycles)
> +{
> +	u64 tmp, res = tsc_adjust;
> +
> +	res += (cycles / tsc_denominator) * tsc_numerator;
> +	tmp = (cycles % tsc_denominator) * tsc_numerator;
> +	res += tmp / tsc_denominator;
> +	return res;

Nice trick!

> diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
> index 278dd27..2ed3d0c 100644
> --- a/include/linux/clocksource.h
> +++ b/include/linux/clocksource.h
> @@ -258,4 +258,34 @@ void acpi_generic_timer_init(void);
>   static inline void acpi_generic_timer_init(void) { }
>   #endif
>
> +/**
> + * struct correlated_cs - Descriptor for a clocksource correlated to another clocksource
> + * @related_cs:		Pointer to the related timekeeping clocksource
> + * @convert:		Conversion function to convert a timestamp from
> + *			the correlated clocksource to cycles of the related
> + *			timekeeping clocksource
> + */
> +struct correlated_cs {
> +	struct clocksource	*related_cs;
> +	u64			(*convert)(u64 cycles);

Should the name make it clearer which way it converts?  For example, 
convert_to_related?  We might also want convert_from_related.

--Andy
