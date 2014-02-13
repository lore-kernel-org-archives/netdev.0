From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] sch_netem: replace spin_(un)lock_bh with
 sch_tree_(un)lock
Date: Thu, 13 Feb 2014 17:46:06 -0500 (EST)
Message-ID: <20140213.174606.334208738068503053.davem@davemloft.net>
References: <1392173895-5012-1-git-send-email-yangyingliang@huawei.com>
	<1392173895-5012-5-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbaBMWqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:46:08 -0500
In-Reply-To: <1392173895-5012-5-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 12 Feb 2014 10:58:15 +0800

> spin_(un)lock_bh(root_lock) is same as sch_tree_(un)lock.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
 ...
> @@ -684,11 +683,9 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
>  	for (i = 0; i < n; i++)
>  		d->table[i] = data[i];
>  
> -	root_lock = qdisc_root_sleeping_lock(sch);
> -
> -	spin_lock_bh(root_lock);
> +	sch_tree_lock(sch);
>  	swap(q->delay_dist, d);
> -	spin_unlock_bh(root_lock);
> +	sch_tree_unlock(sch);
>  
>  	dist_free(d);
>  	return 0;

This is more expensive than the existing code.

We will now calculate qdisc_root_sleeping_lock() twice which is at
least two pointer dereferences each.

Without explicitly open-coding this, the compiler cannot cache the
result, because the spin lock operations have memory barriers (if
implemented inline) or are considered to potentially modify all memory
(if implemented as function calls).
