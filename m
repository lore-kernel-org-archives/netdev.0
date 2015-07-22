From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] ipv6: Avoid rt6_probe() taking writer lock in
 the fast path
Date: Wed, 22 Jul 2015 11:10:59 +0900
Message-ID: <55AEFBB3.1010503@miraclelinux.com>
References: <1437522680-3515872-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33285 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbbGVCLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 22:11:04 -0400
Received: by pdbnt7 with SMTP id nt7so59164692pdb.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 19:11:03 -0700 (PDT)
In-Reply-To: <1437522680-3515872-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Martin KaFai Lau wrote:
> The patch checks neigh->nud_state before acquiring the writer lock.
> Note that rt6_probe() is only used in CONFIG_IPV6_ROUTER_PREF.

You have to take "some" lock when accessing neigh->nud_state
theoretically.

> 
> I also take this chance to re-arrange the code.

No, please do not mix multiple changes.

> 
> 40 udpflood processes and a /64 gateway route are used.
> The gateway has NUD_PERMANENT.  Each of them is run for 30s.
> At the end, the total number of finished sendto():
> 
> Before    After
> 55M	  95M
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/route.c | 41 ++++++++++++++++++++---------------------
>  1 file changed, 20 insertions(+), 21 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 6090969..a6c6b5a 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -544,6 +544,7 @@ static void rt6_probe_deferred(struct work_struct *w)
>  
>  static void rt6_probe(struct rt6_info *rt)
>  {
> +	struct __rt6_probe_work *work;
>  	struct neighbour *neigh;
>  	/*
>  	 * Okay, this does not seem to be appropriate
> @@ -558,34 +559,32 @@ static void rt6_probe(struct rt6_info *rt)
>  	rcu_read_lock_bh();
>  	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
>  	if (neigh) {
> -		write_lock(&neigh->lock);
>  		if (neigh->nud_state & NUD_VALID)
>  			goto out;
> -	}
> -
> -	if (!neigh ||
> -	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
> -		struct __rt6_probe_work *work;
>  
> +		work = NULL;
> +		write_lock(&neigh->lock);
> +		if (!(neigh->nud_state & NUD_VALID) &&
> +		    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
> +			work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +			if (work) {
> +				__neigh_set_probe_once(neigh);
> +			}
> +		}
> +		write_unlock(&neigh->lock);
> +	} else {
>  		work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +	}
>  
> -		if (neigh && work)
> -			__neigh_set_probe_once(neigh);
> -
> -		if (neigh)
> -			write_unlock(&neigh->lock);
> +	if (work) {
> +		INIT_WORK(&work->work, rt6_probe_deferred);
> +		work->target = rt->rt6i_gateway;
> +		dev_hold(rt->dst.dev);
> +		work->dev = rt->dst.dev;
> +		schedule_work(&work->work);
> +	}
>  
> -		if (work) {
> -			INIT_WORK(&work->work, rt6_probe_deferred);
> -			work->target = rt->rt6i_gateway;
> -			dev_hold(rt->dst.dev);
> -			work->dev = rt->dst.dev;
> -			schedule_work(&work->work);
> -		}
> -	} else {
>  out:
> -		write_unlock(&neigh->lock);
> -	}
>  	rcu_read_unlock_bh();
>  }
>  #else
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
