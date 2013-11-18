From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Mon, 18 Nov 2013 16:21:15 -0500 (EST)
Message-ID: <20131118.162115.407611651189468804.davem@davemloft.net>
References: <20131112085714.GU31491@secunet.com>
	<20131114.022356.1095983243221745109.davem@davemloft.net>
	<20131118100843.GY31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab3KRVVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 16:21:17 -0500
In-Reply-To: <20131118100843.GY31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 18 Nov 2013 11:08:43 +0100

> Subject: [PATCH RFC] neigh: Fix garbage collection if the cached entries are
>  below the threshold
> 
> Since git commit 2724680 ("neigh: Keep neighbour cache entries if number
> of them is small enough."), we keep all neighbour cache entries if the
> number is below a threshold. But if we now delete an entry administratively
> and then try to replace this by a permanent one, we get -EEXIST because the
> old entry ist still in the table (in NUD_FAILED state).
> 
> So remove the threshold check in neigh_periodic_work() and schedule the
> gc_work only when needed, i.e. if gc_thresh1 is reached or if there is
> an administrative change. We reschedule gc_work either if the number of
> cache entries is still above gc_thresh1 or if there are invalid entries
> with "refcnt != 1" cached.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I think the main issue is that after this patch, the problem is really
still there.

Let's say some device holds onto the neigh for a long time, then during
this time an administrative replacement will still get that -EEXIST
failure.

My conclusion is that the management of the state is the problem.
Specifically, if we invalidate an entry then we should remove it's
visisbility.  This means the table should operate by unhashing the
entry unconditionally during such operations.

If some stray references exist, that's fine, the entity holding the
reference will perform the final neigh cleanup at release time.

Does this make sense to you?
