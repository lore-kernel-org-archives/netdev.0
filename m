From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Thu, 12 Jan 2017 09:43:25 +0100
Message-ID: <20170112084325.GC2264@dhcp22.suse.cz>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, 3chas3@gmail.com,
        andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38823 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbdALIn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 03:43:28 -0500
Content-Disposition: inline
In-Reply-To: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed 11-01-17 21:02:01, Cong Wang wrote:
> alloc_tx() is already inside a wait loop for a successful skb
> allocation, this loop inside alloc_tx() is quite unnecessary
> and actually problematic.

I am not familiar with this code at all but vcc_sendmsg seems to be one
of those cases where open coding __GFP_NOFAIL semantic makes sense as
there is an allocation fallback strategy implemented.

> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I cannot give my reviewed-by because I am not familiar with the code but
this looks like an improvement to me.

> ---
>  net/atm/common.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
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
>  
> -- 
> 2.5.5

-- 
Michal Hocko
SUSE Labs
