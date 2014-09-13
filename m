From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Freeing dst when the reference count <0 causes general
 protection fault, it could be a major security flaw as rogue app can modify
 dst to crash kernel.
Date: Sat, 13 Sep 2014 04:50:22 -0700
Message-ID: <1410609022.7106.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410596833-2548-1-git-send-email-shakilk1729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net
To: Shakil A Khan <shakilk1729@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410596833-2548-1-git-send-email-shakilk1729@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-09-13 at 01:27 -0700, Shakil A Khan wrote:
> Signed-off-by: Shakil A Khan <shakilk1729@gmail.com>
> ---
>  net/core/dst.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index a028409..6a848b0 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -284,7 +284,10 @@ void dst_release(struct dst_entry *dst)
>  		int newrefcnt;
>  
>  		newrefcnt = atomic_dec_return(&dst->__refcnt);
> -		WARN_ON(newrefcnt < 0);
> +
> +		if (WARN(newrefcnt < 0, "dst reference count less than zero"))
> +			return;
> +
>  		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
>  			call_rcu(&dst->rcu_head, dst_destroy_rcu);
>  	}


A rogue application can not do trigger this, unless a major bug in the
kernel exists.

Instead of trying to hide the kernel bug, we need to fix it.

Can you describe how this could trigger with a pristine kernel ?
