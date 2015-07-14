From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: stop endless flood about dst entry refcount
 underflow or overflow
Date: Tue, 14 Jul 2015 14:04:14 +0200
Message-ID: <1436875454.1374.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150714114305.17434.53731.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37736 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbGNMET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 08:04:19 -0400
Received: by wibud3 with SMTP id ud3so12496528wib.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 05:04:18 -0700 (PDT)
In-Reply-To: <20150714114305.17434.53731.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-14 at 14:43 +0300, Konstantin Khlebnikov wrote:
> Kernel generates a lot of warnings when dst entry reference counter
> overflows and becomes negative. This patch prints address of dst entry,
> its refcount and then resets reference counter to INT_MAX/2.
> 
> That bug was seen several times at machines with outdated 3.10.y kernels.
> Most like it's already fixed in upstream. Anyway flood of that warnings
> completely kills machine and makes further debugging impossible.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  net/core/dst.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index e956ce6d1378..2ed91082b3cf 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -284,7 +284,8 @@ void dst_release(struct dst_entry *dst)
>  		int newrefcnt;
>  
>  		newrefcnt = atomic_dec_return(&dst->__refcnt);
> -		WARN_ON(newrefcnt < 0);
> +		if (WARN(newrefcnt < 0, "dst: %p refcnt: %d\n", dst, newrefcnt))
> +			atomic_set(&dst->__refcnt, INT_MAX / 2);
>  		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
>  			call_rcu(&dst->rcu_head, dst_destroy_rcu);
>  	}


WARN_ON_ONCE() if you want, but setting __refcnt like this is absolutely
a dirty hack.
