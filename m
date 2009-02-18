From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 11:07:58 +0100
Message-ID: <499BDDFE.5010101@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090218092041.GC3294@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
>> -extern int __mod_timer(struct timer_list *timer, unsigned long expires);
>> +extern int __mod_timer(struct timer_list *timer, unsigned long expires, int activate);
> 
> This is not really acceptable, it slows down every single 
> add_timer() and mod_timer() call in the kernel with a flag that 
> has one specific value in all but your case. There's more than 
> 2000 such callsites in the kernel.
> 
> Why dont you use something like this instead:
> 
> 	if (del_timer(timer))
> 		add_timer(timer);

We need to avoid having a timer that was deleted by one CPU
getting re-added by another, but want to avoid taking the
conntrack lock for every timer update. The timer-internal
locking is enough for this as long as we have a mod_timer
variant that forwards a timer, but doesn't activate it in
case it isn't active already.
