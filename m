From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v2 2/2] ipv6: Avoid rt6_probe() taking writer
 lock in the fast path
Date: Tue, 28 Jul 2015 09:17:41 +0900
Message-ID: <55B6CA25.4040909@miraclelinux.com>
References: <1437757063-1186401-1-git-send-email-kafai@fb.com> <1437757063-1186401-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33736 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbbG1ARr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 20:17:47 -0400
Received: by pdbnt7 with SMTP id nt7so60019219pdb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 17:17:46 -0700 (PDT)
In-Reply-To: <1437757063-1186401-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Martin KaFai Lau wrote:
> The patch checks neigh->nud_state before acquiring the writer lock.
> Note that rt6_probe() is only used in CONFIG_IPV6_ROUTER_PREF.
> 
> 40 udpflood processes and a /64 gateway route are used.
> The gateway has NUD_PERMANENT.  Each of them is run for 30s.
> At the end, the total number of finished sendto():
> 
> Before: 55M
> After: 95M

I think it is better to describe why it is okay without any locks.

--yoshfuji

> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> CC: Julian Anastasov <ja@ssi.bg>
> CC: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> ---
>  net/ipv6/route.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 6d503db..76dcff8 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -560,6 +560,9 @@ static void rt6_probe(struct rt6_info *rt)
>  	rcu_read_lock_bh();
>  	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
>  	if (neigh) {
> +		if (neigh->nud_state & NUD_VALID)
> +			goto out;
> +
>  		work = NULL;
>  		write_lock(&neigh->lock);
>  		if (!(neigh->nud_state & NUD_VALID) &&
> @@ -583,6 +586,7 @@ static void rt6_probe(struct rt6_info *rt)
>  		schedule_work(&work->work);
>  	}
>  
> +out:
>  	rcu_read_unlock_bh();
>  }
>  #else
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
