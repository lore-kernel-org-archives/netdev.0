From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 13:33:14 +0100
Message-ID: <499C000A.4040205@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net> <20090218120508.GB4100@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51315 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbZBRMdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 07:33:19 -0500
In-Reply-To: <20090218120508.GB4100@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Patrick McHardy <kaber@trash.net> wrote:
> 
>> We need to avoid having a timer that was deleted by one CPU
>> getting re-added by another, but want to avoid taking the
>> conntrack lock for every timer update. The timer-internal
>> locking is enough for this as long as we have a mod_timer
>> variant that forwards a timer, but doesn't activate it in
>> case it isn't active already.
> 
> that makes sense - but the implementation is still somewhat 
> ugly. How about the one below instead? Not tested.

This seems to fulfill our needs. I also like the mod_timer_pending()
name better than mod_timer_noact().

> One open question is this construct in mod_timer():
> 
> +	/*
> +	 * This is a common optimization triggered by the
> +	 * networking code - if the timer is re-modified
> +	 * to be the same thing then just return:
> +	 */
> +	if (timer->expires == expires && timer_pending(timer))
> +		return 1;
> 
> We've had this for ages, but it seems rather SMP-unsafe. 
> timer_pending(), if used in an unserialized fashion, can be any 
> random value in theory - there's no internal serialization here 
> anywhere.
> 
> We could end up with incorrectly not re-activating a timer in 
> mod_timer() for example - have such things never been observed 
> in practice?

Yes, it seems racy if done for timers that might get activated.
For forwarding only without activation it seems OK, in that case
the timer_pending check doesn't seem necessary at all.

> So the original patch which added this to mod_timer_noact() was 
> racy i think, and we cannot preserve this optimization outside 
> of the timer list lock. (we could do it inside of it.)
