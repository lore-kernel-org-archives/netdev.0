From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
 est_timer() fixed
Date: Sun, 20 Jan 2008 15:55:44 -0800
Message-ID: <20080120155544.0a071675@deepthought>
References: <20080120234959.GB2691@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59688 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754351AbYATX7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 18:59:03 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JGk41-0004rQ-0Q
	for netdev@vger.kernel.org; Sun, 20 Jan 2008 23:58:57 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:58:56 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 23:58:56 +0000
In-Reply-To: <20080120234959.GB2691@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jan 2008 00:49:59 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> This patch changes the method of checking for empty list in est_timer():
> list_empty() is not recommended for RCU protected lists. Now, it's simply
> a variable used for this.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
> diff -Nurp 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c
> --- 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c	2008-01-20 20:58:35.000000000 +0100
> +++ 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c	2008-01-20 21:07:42.000000000 +0100
> @@ -106,6 +106,7 @@ static void est_timer(unsigned long arg)
>  {
>  	int idx = (int)arg;
>  	struct gen_estimator *e;
> +	int list_not_empty = 0;

Using a negative name for what is a boolean value leads
to code that reads like a double negative sentence. Better to choose
a variable name that is direct, can't use list_empty because that
is a macro, so how about "estimator_found".

>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(e, &elist[idx].list, list) {
> @@ -118,6 +119,9 @@ static void est_timer(unsigned long arg)
>  		if (e->bstats == NULL)
>  			goto skip;
>  
> +		if (list_not_empty == 0)
> +			list_not_empty = 1;
> +
>  		nbytes = e->bstats->bytes;
>  		npackets = e->bstats->packets;
>  		rate = (nbytes - e->last_bytes)<<(7 - idx);
> @@ -134,7 +138,7 @@ skip:
>  		spin_unlock(e->stats_lock);
>  	}
>  
> -	if (!list_empty(&elist[idx].list))
> +	if (list_not_empty)
>  		mod_timer(&elist[idx].timer, jiffies + ((HZ/4) << idx));
>  	rcu_read_unlock();
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

