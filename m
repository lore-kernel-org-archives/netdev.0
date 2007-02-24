From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] use ktime for packet scheduling
Date: Sat, 24 Feb 2007 15:17:37 +0100
Message-ID: <45E04901.1040505@trash.net>
References: <20070222143047.1631b93e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932864AbXBXORj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 09:17:39 -0500
In-Reply-To: <20070222143047.1631b93e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is an experimental patch that changes the packet scheduler to use
> ktime instead of gettimeofday. This should be faster on 64 bit and avoid some of
> the math overhead issues with previous code.
> 
> Also since it uses monotonic clock, it won't cause timing glitches when NTP
> adjusts the clock.

This looks like a good idea, even if we can't take full advantage
of the higher precision for now.

BTW, any news on the iproute patches I sent you for this?

> --- netem.orig/include/net/pkt_sched.h	2007-02-22 12:08:53.000000000 -0800
> +++ netem/include/net/pkt_sched.h	2007-02-22 14:21:57.000000000 -0800
> @@ -56,19 +56,48 @@
>  
>  #ifdef CONFIG_NET_SCH_CLK_GETTIMEOFDAY
>  
> -typedef struct timeval	psched_time_t;
> -typedef long		psched_tdiff_t;
> +typedef ktime_t psched_time_t;
> +typedef long	psched_tdiff_t;
> +
> +/* Avoid doing 64 bit divide by 1000 */
> +#define PSCHED_US2NS(x)	((s64)(x) << 10)
> +#define PSCHED_NS2US(x)	((x) >> 10)

Since you use this for PSCHED_TDIFF etc, the resulting values
are not exactly microseconds anymore. You need to adjust
psched_us_per_tick/psched_tick_per_us so userspace can
correctly calculate time values.

> -#define PSCHED_GET_TIME(stamp) do_gettimeofday(&(stamp))
> +#define PSCHED_GET_TIME(stamp)  ((stamp) = ktime_get())
>  #define PSCHED_US2JIFFIE(usecs) usecs_to_jiffies(usecs)
>  #define PSCHED_JIFFIE2US(delay) jiffies_to_usecs(delay)

Both of these need to take into account that its not real
microseconds anymore.

Please also fix up the HFSC PSCHED_GET_TIME redefinition,
it expects the results to be usable with these macros.

> +static inline psched_tdiff_t psched_diff(const psched_time_t tv1,
> +					 const psched_time_t tv2)
> +{
> +	return PSCHED_NS2US(ktime_to_ns(ktime_sub(tv1, tv2)));
> +}
> +
> +#define PSCHED_TDIFF(tv1, tv2) psched_diff(tv1, tv2)
> +#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
> +	min_t(long, psched_diff((tv1),(tv2)), bound)
> +
> +static inline psched_time_t psched_add(const psched_time_t tv1, u32 usec)
> +{
> +	u64 ns = PSCHED_US2NS(usec);
> +	return ktime_add_ns(tv1, ns);
> +}
> +
> +#define PSCHED_TLESS(tv1, tv2) ((tv1).tv64 < (tv2).tv64)
> +#define PSCHED_TADD(tv, delta) psched_add((tv), (delta))
> +#define PSCHED_TADD2(tv, delta, tv_res) ((tv_res) = psched_add((tv), (delta)))
> +
> +/* Set/check that time is in the "past perfect" */
> +
> +#define PSCHED_SET_PASTPERFECT(t)	((t).tv64 = 0)
> +#define PSCHED_IS_PASTPERFECT(t)	((t).tv64 == 0)

Maybe use one of the 32 bit members, I guess that will generate
better code on 32 bit.
