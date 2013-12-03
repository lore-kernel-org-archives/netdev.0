From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for
 neigh_timer_handler()
Date: Tue, 03 Dec 2013 11:37:37 -0500 (EST)
Message-ID: <20131203.113737.729256753956074289.davem@davemloft.net>
References: <529DE13D.2070509@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, yoshfuji@linux-ipv6.org, joe@perches.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab3LCQhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:37:42 -0500
In-Reply-To: <529DE13D.2070509@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 3 Dec 2013 21:48:45 +0800

> @@ -888,6 +888,11 @@ static void neigh_timer_handler(unsigned long arg)
>  
>  	write_lock(&neigh->lock);
>  
> +	if (neigh->dead) {
> +		pr_warn("neighbour is dead and should be destroyed\n");
> +		goto out;
> +	}
> +


I agree with Eric, if the neigh has been freed at this point you
cannot touch any member of it.

This means you cannot take neigh->lock.

This means you can't even test neigh->dead because it could be
arbitrary garbage, it's freed memory after all.

Worse yet, the neigh->timer is implicitly referenced by the timer
subsystem, the caller of neigh_timer_handler().  It is referencing
freed memory if it is touching neigh->timer members at all.

You can't avoid things by pretending that you can leave this timer
pending or potentially running asynchronously.

You must guarentee that all pending timer instances are complete
and no longer scheduled before you allow kfree(neigh) to execute.
