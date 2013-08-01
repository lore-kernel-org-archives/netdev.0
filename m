From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Refactor xfrm_state timer management
Date: Thu, 01 Aug 2013 15:35:12 -0700 (PDT)
Message-ID: <20130801.153512.307039655614237376.davem@davemloft.net>
References: <1375342790-2852-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565Ab3HAWfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:35:13 -0400
In-Reply-To: <1375342790-2852-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Thu, 1 Aug 2013 15:39:50 +0800

> Current xfrm_state timer management is vulnerable in below several ways:
> 
> - Use hrtimer for timer, the timer handler use wall clock checking expire events
>   commit e3c0d047 "Fix unexpected SA hard expiration after changing date" fix
>   the partial problem by notify IKED with soft -> expire sequence when user
>   changing system time forward. But it didn't fix the issue when use changing
>   system time backwards, which is most crucial as SAs lifetime will be a *bigger*
>   one when doing so, thus buy much time for cracker.
> 
>   In short words, changing system time forward/backward can either result in
>   long long lifetime SAs or sudden SA hard expired first.
> 
>   It actually can be fixed this by adding more flags, and with more complicated
>   checking whether system time is being turned forward or backward. I did it and
>   eventually works well. But it's only for "add time expire", taking care of
>   "use time expire" will add more logic into timer handler, and much more
>   complicated.
> 
> - When user give "use lifetime" by xfrm user configuration
>   interface, current xfrm_state timer management will actually turn the timer on
>   even when no IP packet hit policy, and the "use lifetime" eventually become
>   "add lifetime".
> 
> The culprit is: with one timer for both "add lifetime" and "use lifetime", at the
> same time using wall clock to check two expire events. This patch tries to solve
> it by:
> - Switch real time timer with monotonic timer against any system time changing
> - Use "add lifetime" to override "use lifetime" when both applied, as most popular
>   IKED like Racoon2/StrongSwan use "add lifetime" only.
> - Start "add lifetime" timer only when xfrm_state is updated/added
> - Start "use lifetime" timer when actually SAs is used.
> - Start the timer with soft lifetime interval first, and then in timer handler
>   rearm timer with hard lifetime to get rid of using wall clock.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

This is getting way too complicated, there must be a much better way
to handle this.

I suspect the thing to do is to have system time changes generate a
notifier when clock_was_set() is called.

The XFRM code would walk the rules and pretend that we hit the soft
timeout for every rule that we haven't hit the soft timeout yet
already.

If a rule hit the soft timeout, force a hard timeout.

When forcing a soft timeout, adjust the hard timeout to be
(hard_timeout - soft_timeout) into the future.

Because these other approaches are extremely fragile and
unmaintainable.
