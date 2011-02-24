From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Thu, 24 Feb 2011 18:20:55 +0100
Message-ID: <201102241820.55873.arnd@arndb.de>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com> <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stuart MENEFY <stuart.menefy@st.com>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 February 2011, Peppe CAVALLARO wrote:
> From: Stuart Menefy <stuart.menefy@st.com>
> 
> Many devices targeted at the embedded market provide a number of
> generic timers which are capable of generating interrupts at a
> requested rate. These can then be used in the implementation of drivers
> for other peripherals which require a timer interrupt, without having
> to provide an additional timer as part of that peripheral.
> 
> A code provides a simple abstraction layer which allows a timer to be
> registered, and for a driver to request a timer.
> 
> Currently this doesn't provide any of the additional information, such
> as precision or position in clock framework which might be required
> for a fully featured driver.

This code should probably be discussed on a more broader
platform than the netdev and linux-sh mailing lists,
as the scope is neither sh nor network specific.

You should at least add linux-kernel@vger.kernel.org, possibly
also linux-arch@vger.kernel.org.

Further, John and Thomas are responsible for the timekeeping
infrastructure, and they are probably interested in this
as well.

Why is this code useful to you? In the scenarios I've seen, the
board can always assign a timer to a specific device in a fixed
way that can be describe in a board file or device tree.

Also, what is the difference between this and clkdev?

> Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/clocksource/Makefile       |    1 +
>  drivers/clocksource/generictimer.c |   60 ++++++++++++++++++++++++++++++++++++
>  include/linux/generictimer.h       |   41 ++++++++++++++++++++++++
>  3 files changed, 102 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/clocksource/generictimer.c
>  create mode 100644 include/linux/generictimer.h

I don't think it fits that well into the drivers/clocksource directory,
because you don't actually register a struct clock_event_device or
struct clocksource.

I don't know if this could also be merged with the clocksource infrastructure,
but your code currently doesn't do that.

> +struct generic_timer *generic_timer_claim(void (*handler) (void *), void *data)
> +{
> +	struct generic_timer *gt = NULL;
> +
> +	if (!handler) {
> +		pr_err("%s: invalid handler\n", __func__);
> +		return NULL;
> +	}
> +
> +	mutex_lock(&gt_mutex);
> +	if (!list_empty(&gt_list)) {
> +		struct list_head *list = gt_list.next;
> +		list_del(list);
> +		gt = container_of(list, struct generic_timer, list);
> +	}
> +	mutex_unlock(&gt_mutex);
> +
> +	if (!gt)
> +		return NULL;
> +
> +	/* Prepare the new handler */
> +	gt->priv_handler = handler;
> +	gt->data = data;
> +
> +	return gt;
> +}

This does not seem very generic. You put timers into the list and take
them out again, but don't have any way to deal with timers that match
specific purposes. It obviously works for your specific use case where
you register exactly one timer, and use that in exactly one driver.

If more drivers were converted to generic_timer, which is obviously
the intention, then you might have a situation with very different
timers (fixed/variable tick, high/low frequencies, accurate/inaccurate),
or you might have fewer timers than users.

> +static inline void generic_timer_set_rate(struct generic_timer *gt,
> +		unsigned long rate)
> +{
> +	gt->set_rate(gt, rate);
> +}
> +
> +#endif /* __STM_GENERIC_TIMER_H */

Shouldn't this one allow a return code?

	Arnd
