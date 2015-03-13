From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix statistics locking scheme
Date: Fri, 13 Mar 2015 12:38:22 -0400 (EDT)
Message-ID: <20150313.123822.1761706097366192562.davem@davemloft.net>
References: <1426253565-10302-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbbCMQiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:38:23 -0400
In-Reply-To: <1426253565-10302-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 13 Mar 2015 15:32:45 +0200

> -	spin_lock_bh(&bp->stats_lock);
> -	state = bp->stats_state;
> +	/* Statistics update run from timer context, and we don't want to stop
> +	 * that context in case someone is in the middle of a transition.
> +	 * For other events, wait a bit until lock is taken.
> +	 */
> +	if (down_trylock(&bp->stats_lock)) {
> +		if (event == STATS_EVENT_UPDATE)
> +			return;
> +
> +		if (down_timeout(&bp->stats_lock, HZ / 10))
> +			BNX2X_ERR("Unable to acquire stats lock\n");
> +	}
> +
> +	bnx2x_stats_stm[state][event].action(bp);

You run the action even if you can't get the semaphore.

> +{
> +	int cnt = 10;
> +
> +	if (down_timeout(&bp->stats_lock, HZ / 10))
>  		BNX2X_ERR("Unable to acquire stats lock\n");
> +
> +	/* Wait for statistics to end, then run supplied function 'safely' */
>  	bnx2x_stats_comp(bp);
> +	while (bp->stats_pending && cnt) {
> +		if (bnx2x_storm_stats_update(bp)) {
> +			usleep_range(1000, 2000);
> +			cnt--;
> +		}
> +	}
> +	if (bp->stats_pending)
> +		BNX2X_ERR("Failed to wait for stats pending to stop; Continuing anyway\n");

Here again, same thing, if you timeout trying to wait for the pending
counter to clear, you still execute the protected section of code.

This is terrible.

Either you use locking to protect critical sections, or you don't.

I do not want to see any code that enters the critical section when
the locked state cannot be acquired.
