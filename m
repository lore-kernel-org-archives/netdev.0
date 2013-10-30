From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Wed, 30 Oct 2013 11:01:44 -0700
Message-ID: <1383156104.4857.49.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131030172341.19203.93490.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:53932 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab3J3SBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:01:46 -0400
Received: by mail-pb0-f41.google.com with SMTP id um1so1736312pbc.14
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 11:01:45 -0700 (PDT)
In-Reply-To: <20131030172341.19203.93490.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> 
> As described in commit 5a581b367 (jiffies: Avoid undefined
> behavior from signed overflow), according to the C standard
> 3.4.3p3, overflow of a signed integer results in undefined
> behavior.
> 
> To fix this, do as the above commit, and do an unsigned
> subtraction, and interpreting the result as a signed
> two's-complement number.  This is based on the theory from
> RFC 1982 and is nicely described in wikipedia here:
>  https://en.wikipedia.org/wiki/Serial_number_arithmetic#General_Solution
> 
> A side-note, I have seen practical issues with the previous logic
> when dealing with 16-bit, on a 64-bit machine (gcc version
> 4.4.5). This were 32-bit, which I have not observed issues with.
> 
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> ---
> 
>  include/net/codel.h |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/codel.h b/include/net/codel.h
> index 389cf62..700fcdf 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -72,10 +72,10 @@ static inline codel_time_t codel_get_time(void)
>  	return ns >> CODEL_SHIFT;
>  }
>  
> -#define codel_time_after(a, b)		((s32)(a) - (s32)(b) > 0)
> -#define codel_time_after_eq(a, b)	((s32)(a) - (s32)(b) >= 0)
> -#define codel_time_before(a, b)		((s32)(a) - (s32)(b) < 0)
> -#define codel_time_before_eq(a, b)	((s32)(a) - (s32)(b) <= 0)
> +#define codel_time_after(a, b)		((s32)((a) - (b)) > 0)
> +#define codel_time_after_eq(a, b)	((s32)((a) - (b)) >= 0)
> +#define codel_time_before(a, b) 	((s32)((a) - (b)) < 0)
> +#define codel_time_before_eq(a, b)	((s32)((a) - (b)) <= 0)
>  

I see nothing enforcing an unsigned subtraction as claimed in your
changelog.

a / b could be signed.

Paul commit 5a581b367b5 was OK because of existing typecheck(unsigned
long, ....)
