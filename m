From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 01:07:00 +0100
Message-ID: <20170113000700.GA1482@electric-eye.fr.zoreil.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mhocko@kernel.org, 3chas3@gmail.com,
        andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38384 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdAMAIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 19:08:11 -0500
Content-Disposition: inline
In-Reply-To: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> :
[...]
> diff --git a/net/atm/common.c b/net/atm/common.c
> index a3ca922..7ec3bbc 100644
> --- a/net/atm/common.c
> +++ b/net/atm/common.c
> @@ -72,10 +72,11 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
>  			 sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
>  		return NULL;
>  	}
> -	while (!(skb = alloc_skb(size, GFP_KERNEL)))
> -		schedule();
> -	pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
> -	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
> +	skb = alloc_skb(size, GFP_KERNEL);
> +	if (skb) {
> +		pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
> +		atomic_add(skb->truesize, &sk->sk_wmem_alloc);
> +	}
>  	return skb;
>  }

Were alloc_skb moved one level up in the call stack, there would be
no need to use the new wait api in the subsequent page, thus easing
pre 3.19 longterm kernel maintenance (at least those on korg page).

But it tastes a tad bit too masochistic.

-- 
Ueimor
