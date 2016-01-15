From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v6 3/9] Add correlated clocksource relating aliased
 auxiliary and system clocks
Date: Thu, 14 Jan 2016 16:24:18 -0800
Message-ID: <CALAqxLXZhpGUv2UAPLmSboW=nhyW+eXvrMaUkZCy7JQh=WgkLQ@mail.gmail.com>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
	<1452687149-11281-4-git-send-email-christopher.s.hall@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:32998 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbcAOAYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 19:24:19 -0500
Received: by mail-yk0-f170.google.com with SMTP id k129so503998004yke.0
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 16:24:19 -0800 (PST)
In-Reply-To: <1452687149-11281-4-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 4:12 AM, Christopher S. Hall
<christopher.s.hall@intel.com> wrote:
> ACKNOWLEDGMENT: The original correlated clock source and cross
> timestamp code was developed by Thomas Gleixner
> <tglx@linutronix.de>. It has changed considerably and any mistakes are
> mine.
>
> The timekeeping and clocksource code don't currently comprehend two
> clocks that are aliases of one another. That is clocks that are
> *exactly* related. The correlated_cs struct encapsulated this
> relationship between a clocksource and its alias clock. Modern Intel
> hardware provides an Always Running Timer (ART) which is exactly
> related to TSC through a known frequency ratio. The ART is an example
> of a correlated clocksource.
>
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> ---
>  include/linux/clocksource.h | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>
> diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
> index 4542293..726ca68 100644
> --- a/include/linux/clocksource.h
> +++ b/include/linux/clocksource.h
> @@ -267,4 +267,18 @@ struct system_counterval_t {
>         struct clocksource      *cs;
>  };
>
> +/*
> + * struct correlated_cs - Descriptor for a clocksource correlated to another
> + *     clocksource
> + * @related_cs:                Pointer to the related timekeeping clocksource
> + * @convert:           Conversion function to convert a timestamp from
> + *                     the correlated clocksource to cycles of the related
> + *                     timekeeping clocksource
> + */
> +struct correlated_cs {
> +       struct clocksource      *related_cs;
> +       cycle_t                 (*convert)(struct correlated_cs *cs,
> +                                          cycle_t cycles);
> +};
> +

So.. In reworking your patch set, I've preserved this, but I'm still
not totally convinced. Its a generic structure, but not used by any
generic code and its only used by hardware specific implementations
(ie: the tsc and e1000e_hwts logic). It seems like this could be a
tsc.h specific structure w/o a real issue.

And really this doesn't seem to be a generic thing. The e1000e hwts is
always the ART based. Its not likely these sorts of cross hardware
timestamps are going to be completely abstract and interchangeable,
is it?

thanks
-john
