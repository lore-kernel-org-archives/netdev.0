From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v2 1/2] ipv6: Re-arrange code in rt6_probe()
Date: Tue, 28 Jul 2015 09:07:21 +0900
Message-ID: <55B6C7B9.5000000@miraclelinux.com>
References: <1437757063-1186401-1-git-send-email-kafai@fb.com> <1437757063-1186401-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36738 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750AbbG1AHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 20:07:25 -0400
Received: by pdjr16 with SMTP id r16so61037261pdj.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 17:07:25 -0700 (PDT)
In-Reply-To: <1437757063-1186401-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin KaFai Lau wrote:
> It is a prep work for the next patch to remove write_lock
> from rt6_probe().
> 
> 1. Reduce the number of if(neigh) check.  From 4 to 1.
> 2. Bring the write_(un)lock() closer to the operations that the
>    lock is protecting.
> 
> Hopefully, the above make rt6_probe() more readable.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>

Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>

--yoshfuji

> ---
>  net/ipv6/route.c | 44 ++++++++++++++++++++------------------------
>  1 file changed, 20 insertions(+), 24 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 7f2214f..6d503db 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -545,6 +545,7 @@ static void rt6_probe_deferred(struct work_struct *w)
>  
>  static void rt6_probe(struct rt6_info *rt)
>  {
> +	struct __rt6_probe_work *work;
>  	struct neighbour *neigh;
>  	/*
>  	 * Okay, this does not seem to be appropriate
> @@ -559,34 +560,29 @@ static void rt6_probe(struct rt6_info *rt)
>  	rcu_read_lock_bh();
>  	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
>  	if (neigh) {
> +		work = NULL;
>  		write_lock(&neigh->lock);
> -		if (neigh->nud_state & NUD_VALID)
> -			goto out;
> -	}
> -
> -	if (!neigh ||
> -	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
> -		struct __rt6_probe_work *work;
> -
> -		work = kmalloc(sizeof(*work), GFP_ATOMIC);
> -
> -		if (neigh && work)
> -			__neigh_set_probe_once(neigh);
> -
> -		if (neigh)
> -			write_unlock(&neigh->lock);
> -
> -		if (work) {
> -			INIT_WORK(&work->work, rt6_probe_deferred);
> -			work->target = rt->rt6i_gateway;
> -			dev_hold(rt->dst.dev);
> -			work->dev = rt->dst.dev;
> -			schedule_work(&work->work);
> +		if (!(neigh->nud_state & NUD_VALID) &&
> +		    time_after(jiffies,
> +			       neigh->updated +
> +			       rt->rt6i_idev->cnf.rtr_probe_interval)) {
> +			work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +			if (work)
> +				__neigh_set_probe_once(neigh);
>  		}
> -	} else {
> -out:
>  		write_unlock(&neigh->lock);
> +	} else {
> +		work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +	}
> +
> +	if (work) {
> +		INIT_WORK(&work->work, rt6_probe_deferred);
> +		work->target = rt->rt6i_gateway;
> +		dev_hold(rt->dst.dev);
> +		work->dev = rt->dst.dev;
> +		schedule_work(&work->work);
>  	}
> +
>  	rcu_read_unlock_bh();
>  }
>  #else
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部
