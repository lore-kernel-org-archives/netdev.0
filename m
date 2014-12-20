From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: Detect drivers that reschedule NAPI and exhaust budget
Date: Fri, 19 Dec 2014 17:34:48 -0800
Message-ID: <1419039288.11185.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
	 <20141220002327.GA31975@gondor.apana.org.au>
	 <20141220003636.GA32187@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, edumazet@google.com,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33720 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaLTBeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 20:34:50 -0500
Received: by mail-ie0-f178.google.com with SMTP id vy18so15531iec.37
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 17:34:50 -0800 (PST)
In-Reply-To: <20141220003636.GA32187@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-12-20 at 11:36 +1100, Herbert Xu wrote:
> On Sat, Dec 20, 2014 at 11:23:27AM +1100, Herbert Xu wrote:
> >
> > A similar bug exists in virtio_net.
> 
> In order to detect other drivers doing this we should add something
> like this.
> 
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
> index f411c28..88f9725 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4620,7 +4620,11 @@ static void net_rx_action(struct softirq_action *h)
>  					 */
>  					napi_gro_flush(n, HZ >= 1000);
>  				}
> -				list_add_tail(&n->poll_list, &repoll);
> +				/* Some drivers may have called napi_schedule
> +				 * prior to exhausting their budget.
> +				 */
> +				if (!WARN_ON_ONCE(!list_empty(&n->poll_list)))
> +					list_add_tail(&n->poll_list, &repoll);
>  			}
>  		}
>  

I do not think stack trace will point to the buggy driver ?

IMO it would be better to print a single line with the netdev name ?
