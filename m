From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Thu, 31 Oct 2013 21:40:10 +0100
Message-ID: <20131031214010.1ca961ac@redhat.com>
References: <20131030172341.19203.93490.stgit@dragon>
	<1383156104.4857.49.camel@edumazet-glaptop.roam.corp.google.com>
	<20131031151551.675ab908@redhat.com>
	<1383232241.4857.73.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710Ab3JaUkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 16:40:20 -0400
In-Reply-To: <1383232241.4857.73.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Oct 2013 08:10:41 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2013-10-31 at 15:15 +0100, Jesper Dangaard Brouer wrote:
> 
> > Okay, I'll cook up another patch, after work.
> > 
> > Adding all the typecheck() stuff, just bloats the code.
> > 
> > Would it be better/okay just to do?:
> >  (s32)((u32)(a) - (u32)(b)) > 0)
> > 
> > 
> 
> What about using the existing codel types ?

Hmm, I would be okay to use codel types for typecheck(), but I don't
like the approach below, because we are hiding a typecast.  This just
makes the code harder to read/understand. An explicit cast shows that
we are doing something nasty, on purpose here.

I would rather keep as close as possible to include/linux/jiffies.h,
because I want readers to be-able to spot this pattern.


> diff --git a/include/net/codel.h b/include/net/codel.h
> index 389cf62..89a7781 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -72,7 +72,12 @@ static inline codel_time_t codel_get_time(void)
>  	return ns >> CODEL_SHIFT;
>  }
>  
> -#define codel_time_after(a, b)		((s32)(a) - (s32)(b) > 0)
> +static inline bool codel_time_after(codel_time_t a, codel_time_t b)
> +{
> +	codel_tdiff_t delta = a - b;
> +
> +	return delta >= 0;
> +}
>  #define codel_time_after_eq(a, b)	((s32)(a) - (s32)(b) >= 0)
>  #define codel_time_before(a, b)		((s32)(a) - (s32)(b) < 0)
>  #define codel_time_before_eq(a, b)	((s32)(a) - (s32)(b) <= 0)
> 
> 
> You need of course something similar for all variants.
> 
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
