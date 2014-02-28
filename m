From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: switch rtt estimations to usec
 resolution
Date: Fri, 28 Feb 2014 05:51:12 -0800
Message-ID: <1393595472.26794.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87fvn3dd9i.fsf@tassilo.jf.intel.com>
	 <1393568072.26794.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140228133127.GT22728@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:42314 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbaB1NvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 08:51:16 -0500
Received: by mail-pd0-f182.google.com with SMTP id g10so765328pdj.27
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 05:51:15 -0800 (PST)
In-Reply-To: <20140228133127.GT22728@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 14:31 +0100, Andi Kleen wrote:
> > Right, so I cooked this instead :
> > 
> > http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=363ec392352e55c61ce2799c3f15f89f9429bba7
> > 
> > Is this OK or do you see a problem with this ?
> 
> It seems mostly ok. I assume the compiler optimizes the constant do_div to a
> multiplication?
> 

Yep, its a reciprocal.

> I'm not sure it's better than ktime() if it works. So it may be still
> better to have some global flag that says "ktime is slow" and
> qualify it on that.  But that would need changing the timer
> subsystem.

It seems to use ktime_get() on x86 if tsc runs at constant rate.

There is already a static key switch.

int sched_clock_stable(void)
{
	return static_key_false(&__sched_clock_stable);
}

...
	if (sched_clock_stable())
		return sched_clock();

And set_sched_clock_stable() is called from early_init_intel()

        /*
         * c->x86_power is 8000_0007 edx. Bit 8 is TSC runs at constant rate
         * with P/T states and does not stop in deep C-states.
         *
         * It is also reliable across cores and sockets. (but not across
         * cabinets - we turn it off in that case explicitly.)
         */
        if (c->x86_power & (1 << 8)) {
                set_cpu_cap(c, X86_FEATURE_CONSTANT_TSC);
                set_cpu_cap(c, X86_FEATURE_NONSTOP_TSC);
                if (!check_tsc_unstable())
                        set_sched_clock_stable();
        }
