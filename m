From: Patrick McHardy <kaber@trash.net>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 19:16:30 +0200
Message-ID: <465476EE.3090103@trash.net>
References: <20070517174533.GA538@elte.hu> <200705221147.56571.kernel@prachanda.hub> <20070522062233.GA20002@elte.hu> <200705231110.44526.kernel@prachanda.hub> <20070523063052.GB26814@elte.hu> <46541DC4.4090501@trash.net> <20070523112559.GA24604@gondor.apana.org.au> <4654269C.4040809@trash.net> <alpine.LFD.0.98.0705230752040.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ingo Molnar <mingo@elte.hu>,
	Anant Nitya <kernel@prachanda.info>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46465 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935175AbXEWRTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 13:19:36 -0400
In-Reply-To: <alpine.LFD.0.98.0705230752040.3890@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> There appear to be other obvious problems in the recent "cleanups" in this 
> area..
> 
> Look at
> 
> 	psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
> 	{
> 		return min(tv1 - tv2, bound);
> 	}
> 
> and compare it to the previous code:
> 
> 	#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
> 		min_t(long long, (tv1) - (tv2), bound)
> 
> and ponder how that "trivial cleanup" totally broke the thing. 
> 
> Hint: "psched_time_t" is an "u64". What does that mean for
> 
> 	min(tv1 - tv2, bound);
> 
> again, when "tv2" is larger than tv1. It _used_ to return a negative 
> value. Now it returns a positive "bound" upper bound, because "tv1-tv2" 
> will be used as a huge unsigned (and thus _positive_) integer. And was 
> that accidental, or done on purpose?
> 
> Sounds accidental to me, since you then want to return a "psched_tdiff_t", 
> which is typedeffed to be "long".
>
> Doesn't sound very safe to me, especially since the commit message for 
> this is "[NET_SCHED]: turn PSCHED_TDIFF_SAFE into inline function", and 
> there's no indication that anybody realized that it changed semantics in 
> the process.


I did realize it, but tv2 > tv1 can't happen and makes no sense for
the users of this function. I probably should have provided a more
detailed changelog entry.

> Hmm? What _should_ that thing do?


It is used to calculate the amount of tokens a tocken bucket has
accumulated since the last refill, thus we always have tv1 >= tv2
(modulo ktime wraps). In fact tv2 > tv1 was never properly
supported. This macro would have returned the negative long long
value, but all users assign it to a psched_tdiff_t (long), so
depending on the exact values, it might still be interpreted as a
large positive value. Additionally there was a second implementation
for the gettimeofday clocksource that didn't return the negative
difference but the bound value.

