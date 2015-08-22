From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Sat, 22 Aug 2015 22:17:00 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1508222143530.3873@nanos>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com> <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, richardcochran@gmail.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:42767 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbbHVURr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 16:17:47 -0400
In-Reply-To: <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Aug 2015, Christopher S. Hall wrote:

> Add struct correlated_cs with pointer to original clocksource and
> 	function pointer to convert correlated clocksource to the original
> 
> Add get_correlated_timestamp() function which given specific correlated_cs
> 	and correlated_ts convert correlated counter value to system time

This is not a proper changelog.

1) The subject line lacks a subsystem prefix

   timekeeping:

   Is the proper choice here

2) The subject line should be short and precise

   timekeeping: Add mechanism to gather correlated timestamps

   Might be an informative one.

3) The changelog itself should describe the reason why we want this
   change, the purpose of the change etc.

   Add foo
   Add bar

   Is pointless because we can see that from the patch itself.

   What the patch cannot not explain is the WHY. That's what the
   changelog is for.

4) You dropped the authorship

   The proper way to do this is to add a 'FROM: author' at the top of
   the changelog body.

As I wrote the patch, so I give you a changelog along with it:

<---
Subject: timekeeping: Add mechanism to gather correlated timestamps

From: Thomas Gleixner <tglx@linutronix.de>

Modern Intel hardware provides the so called Always Running Timer
(ART). The TSC which is usually used for timekeeping is derived from
ART and runs with a fixed frequency ratio to it. ART is routed to
devices and allows to take atomic timestamp samples from the device
clock and the ART. One use case is PTP timestamps on network cards. We
want to utilize this feature as it allows us to better correlate the
PTP timestamp to the system time.

In order to gather precise timestamps we need to make sure that the
conversion from ART to TSC and the following conversion from TSC to
clock realtime happens synchronized with the ongoing timekeeping
updates. Otherwise we might convert an ART timestamp from point A in
time with the conversion factors of point B in time. These conversion
factors can differ due to NTP/PTP frequency adjustments and therefor
the resulting clock realtime timestamp would be slightly off, which is
contrary to the whole purpose of synchronized hardware timestamps.

Provide data structures which describe the correlation between two
clocksources and a function to gather correlated and convert
timestamps from a device. The function is as any other timekeeping
function protected against current timekeeper updates via the
timekeeper sequence lock. It calls the device function to gather the
hardware timestamps and converts them to clock real time and clock
monotonic raw.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

---->

Can you see the difference?

> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> ---
>  include/linux/clocksource.h | 33 +++++++++++++++++++++++
>  include/linux/timekeeping.h |  4 +++
>  kernel/time/timekeeping.c   | 65 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 102 insertions(+)
> 
> diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
> index 278dd27..4bedadb 100644
> --- a/include/linux/clocksource.h
> +++ b/include/linux/clocksource.h
> @@ -258,4 +258,37 @@ void acpi_generic_timer_init(void);
>  static inline void acpi_generic_timer_init(void) { }
>  #endif
>  
> +/*
> + * struct correlated_cs - Descriptor for a clocksource correlated to another
> + *	clocksource

Don't believe checkpatch here. KernelDoc requires that this is one
line, 80 char limit or not.

>  /**
> + * get_correlated_timestamp - Get a correlated timestamp
> + *

Lacks the parameter documentation:

* @crt: Pointer to a correlated timestamp structure which provides
*	the device specific timestamp function and is used to store
*	the raw and the correlated timestamps.
* @crs:	Pointer to a correlated clocksource structure which describes 
* 	the correlated clocksource and provides a conversion function
*	to the timekeeping clocksource

> +	return 0;
> +}
> +EXPORT_SYMBOL(get_correlated_timestamp);

EXPORT_SYMBOL_GPL please.

Thanks,

	tglx
