From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netem: dont call vfree() under spinlock and BH disabled
Date: Sat, 24 Dec 2011 11:18:54 -0800
Message-ID: <20111224111854.479d497e@nehalam.linuxnetplumber.net>
References: <1324704531.2915.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56079 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab1LXTS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 14:18:57 -0500
In-Reply-To: <1324704531.2915.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 Dec 2011 06:28:51 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> commit 6373a9a286 (netem: use vmalloc for distribution table) added a
> regression, since vfree() is called while holding a spinlock and BH
> being disabled.
> 
> Fix this by doing the pointers swap in critical section, and freeing
> after spinlock release.
> 
> Also add __GFP_NOWARN to the kmalloc() try, since we fallback to
> vmalloc().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/sched/sch_netem.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index eb3b9a8..a4ab207 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -488,7 +488,7 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
>  		return -EINVAL;
>  
>  	s = sizeof(struct disttable) + n * sizeof(s16);
> -	d = kmalloc(s, GFP_KERNEL);
> +	d = kmalloc(s, GFP_KERNEL | __GFP_NOWARN);
>  	if (!d)
>  		d = vmalloc(s);
>  	if (!d)
> @@ -501,9 +501,10 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
>  	root_lock = qdisc_root_sleeping_lock(sch);
>  
>  	spin_lock_bh(root_lock);
> -	dist_free(q->delay_dist);
> -	q->delay_dist = d;
> +	swap(q->delay_dist, d);
>  	spin_unlock_bh(root_lock);
> +
> +	dist_free(d);
>  	return 0;
>  }

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
