From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Detect drivers that reschedule NAPI and exhaust budget
Date: Sat, 20 Dec 2014 10:00:12 -0800
Message-ID: <1419098412.11185.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141220002327.GA31975@gondor.apana.org.au>
	 <20141220003636.GA32187@gondor.apana.org.au>
	 <1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141219.214000.819506179607476836.davem@davemloft.net>
	 <20141220065529.GA2033@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:63764 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaLTSAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 13:00:14 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so3231890pab.21
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 10:00:13 -0800 (PST)
In-Reply-To: <20141220065529.GA2033@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-12-20 at 17:55 +1100, Herbert Xu wrote:

> -- >8 --
> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) required drivers to leave poll_list
> empty if the entire budget is consumed.
> 
> We have already had two broken drivers so let's add a check for
> this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f411c28..47fdc5c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4620,7 +4620,13 @@ static void net_rx_action(struct softirq_action *h)
>  					 */
>  					napi_gro_flush(n, HZ >= 1000);
>  				}
> -				list_add_tail(&n->poll_list, &repoll);
> +				/* Some drivers may have called napi_schedule
> +				 * prior to exhausting their budget.
> +				 */
> +				if (unlikely(!list_empty(&n->poll_list)))
> +					pr_warn("%s: Budget exhausted after napi rescheduled\n", n->dev ? n->dev->name : "backlog");
> +				else
> +					list_add_tail(&n->poll_list, &repoll);
>  			}
>  		}
>  
> Thanks,

OK, but could you :
1) use pr_warn_once()
2) split the too long line
	pr_warn_once("%s: Budget exhausted after napi rescheduled\n",
		     n->dev ? n->dev->name : "backlog");

Thanks Herbert !
