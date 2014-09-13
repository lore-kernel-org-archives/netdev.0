From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] Freeing dst when the reference count <0 causes general
 protection fault, it could be a major security flaw as rogue app can modify
 dst to crash kernel.
Date: Sat, 13 Sep 2014 12:13:34 +0200
Message-ID: <1410603214.25850.5.camel@localhost>
References: <1410596833-2548-1-git-send-email-shakilk1729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, davem@davemloft.net
To: Shakil A Khan <shakilk1729@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbaIMKNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 06:13:42 -0400
In-Reply-To: <1410596833-2548-1-git-send-email-shakilk1729@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sa, 2014-09-13 at 01:27 -0700, Shakil A Khan wrote:
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

So change this to a memory leak which also has reliable concerns...

You could just change this to a BUG_ON, but this will also allow a rogue
app to kill the kernel.
