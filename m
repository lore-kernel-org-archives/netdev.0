From: Stuart Menefy <stuart.menefy@st.com>
Subject: Re: [PATCH (sh-2.6) 1/4] clksource: Generic timer infrastructure
Date: Tue, 1 Mar 2011 15:20:03 +0000
Message-ID: <4D6D0EA3.9000504@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com> <1298369864-24429-2-git-send-email-peppe.cavallaro@st.com> <201102241820.55873.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Stultz <johnstul@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:35144 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756694Ab1CAPqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 10:46:18 -0500
In-Reply-To: <201102241820.55873.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd

Thanks for the comments.

On 24/02/11 17:20, Arnd Bergmann wrote:
> On Tuesday 22 February 2011, Peppe CAVALLARO wrote:
>> From: Stuart Menefy <stuart.menefy@st.com>
>>
>> Many devices targeted at the embedded market provide a number of
>> generic timers which are capable of generating interrupts at a
>> requested rate. These can then be used in the implementation of drivers
>> for other peripherals which require a timer interrupt, without having
>> to provide an additional timer as part of that peripheral.
>>
>> A code provides a simple abstraction layer which allows a timer to be
>> registered, and for a driver to request a timer.
>>
>> Currently this doesn't provide any of the additional information, such
>> as precision or position in clock framework which might be required
>> for a fully featured driver.
> 
> This code should probably be discussed on a more broader
> platform than the netdev and linux-sh mailing lists,
> as the scope is neither sh nor network specific.
> 
> You should at least add linux-kernel@vger.kernel.org, possibly
> also linux-arch@vger.kernel.org.
> 
> Further, John and Thomas are responsible for the timekeeping
> infrastructure, and they are probably interested in this
> as well.
> 
> Why is this code useful to you? In the scenarios I've seen, the
> board can always assign a timer to a specific device in a fixed
> way that can be describe in a board file or device tree.

What we were trying to do was separate the code which actually manipulates
the timer hardware from the code which wants that timer service. In this
case it was a network device driver which is used on multiple SoC devices,
while the timer hardware tends to differ from device to device.

The other user of this code which we have is an OProfile driver, which
with this change can now be independent of the hardware it is running on,
while the previous version manipulated the timer hardware directly.

> Also, what is the difference between this and clkdev?

clkdev can be used to find a struct clk, which is fine if you just want to
read the time. In this instance we want to get interrupts from the timer
hardware, which isn't supported by the clk infrastructure.

If anything this duplicates clockevents. The main reason for not using
clockevents was that nobody else does! Currently clockevents are
used strictly for time keeping within the kernel, and most architectures
only register those which are intended to be used for this purpose.
We felt a bit nervous about adding code to register all the device's timers
as clockevents, and having the network device driver pick up one of those
for its own use.

>> Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
>> Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  drivers/clocksource/Makefile       |    1 +
>>  drivers/clocksource/generictimer.c |   60 ++++++++++++++++++++++++++++++++++++
>>  include/linux/generictimer.h       |   41 ++++++++++++++++++++++++
>>  3 files changed, 102 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/clocksource/generictimer.c
>>  create mode 100644 include/linux/generictimer.h
> 
> I don't think it fits that well into the drivers/clocksource directory,
> because you don't actually register a struct clock_event_device or
> struct clocksource.

True. The intent was that this would be a third interface onto timer
hardware, alongside clocksources and clockevents.

> I don't know if this could also be merged with the clocksource infrastructure,
> but your code currently doesn't do that.

It would probably be clockevent rather than clocksource, but it could be if
people felt that was a better way to go.

>> +struct generic_timer *generic_timer_claim(void (*handler) (void *), void *data)
>> +{
>> +	struct generic_timer *gt = NULL;
>> +
>> +	if (!handler) {
>> +		pr_err("%s: invalid handler\n", __func__);
>> +		return NULL;
>> +	}
>> +
>> +	mutex_lock(&gt_mutex);
>> +	if (!list_empty(&gt_list)) {
>> +		struct list_head *list = gt_list.next;
>> +		list_del(list);
>> +		gt = container_of(list, struct generic_timer, list);
>> +	}
>> +	mutex_unlock(&gt_mutex);
>> +
>> +	if (!gt)
>> +		return NULL;
>> +
>> +	/* Prepare the new handler */
>> +	gt->priv_handler = handler;
>> +	gt->data = data;
>> +
>> +	return gt;
>> +}
> 
> This does not seem very generic. You put timers into the list and take
> them out again, but don't have any way to deal with timers that match
> specific purposes. It obviously works for your specific use case where
> you register exactly one timer, and use that in exactly one driver.
> 
> If more drivers were converted to generic_timer, which is obviously
> the intention, then you might have a situation with very different
> timers (fixed/variable tick, high/low frequencies, accurate/inaccurate),
> or you might have fewer timers than users.

Agreed, this was a first 'keep it simple' pass, maybe its too simple.
