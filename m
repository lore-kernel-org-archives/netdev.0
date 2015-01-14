From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour: fix base_reachable_time(_ms) not effective
 immediatly when changed
Date: Tue, 13 Jan 2015 22:04:38 -0500 (EST)
Message-ID: <20150113.220438.1470978767602235254.davem@davemloft.net>
References: <1421135479-15952-1-git-send-email-jeff@melix.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@melix.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbANDEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 22:04:40 -0500
In-Reply-To: <1421135479-15952-1-git-send-email-jeff@melix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Francois Remy <jeff@melix.org>
Date: Tue, 13 Jan 2015 08:51:19 +0100

> When setting base_reachable_time or base_reachable_time_ms through
> sysctl or netlink, the reachable_time value is not updated.
> This means that neighbour entries will continue to be updated using the
> old value until it is recomputed in neigh_period_work (which
>     recomputes the value every 300*HZ).
> On systems with HZ equal to 1000 for instance, it means 5mins before
> the change is effective.
> 
> This patch changes this behavior by recomputing reachable_time after
> each set on base_reachable_time or base_reachable_time_ms.
> The new value will become effective the next time the neighbour's timer
> is triggered.
> 
> Changes are made in two places: the netlink code for set and the sysctl
> handling code. For sysctl, I use a proc_handler. The ipv6 network
> code does provide its own handler but it already refreshes
> reachable_time correctly so it's not an issue.
> Any other user of neighbour which provide its own handlers must
> refresh reachable_time.
> 
> Signed-off-by: Jean-Francois Remy <jeff@melix.org>

Your change is correct but there are some coding style issues to
deal with:

> +				/*
> +				 * update reachable_time as well, otherwise, the change will
> +				 * only be effective after the next time neigh_periodic_work
> +				 * decides to recompute it (can be multiple minutes)
> +				 */

Comments in the networking should be:

	/* Of this
	 * form.
	 */


> +	if (write && ret == 0 ) {

No space between '0' and the closing parenthesis please.

> +		/*
> +		 * update reachable_time as well, otherwise, the change will
> +		 * only be effective after the next time neigh_periodic_work
> +		 * decides to recompute it
> +		 */

Please fix this comment's layout as per above.

> +		/*
> +		 * Those handlers will update p->reachable_time after
> +		 * base_reachable_time(_ms) is set to ensure the new timer starts being
> +		 * applied after the next neighbour update instead of waiting for
> +		 * neigh_periodic_work to update its value (can be multiple minutes)
> +		 * So any handler that replaces them should do this as well
> +		 */

Likewise.
