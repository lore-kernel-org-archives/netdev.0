From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [net-next PATCH V2] net: codel: Avoid undefined behavior from
 signed overflow
Date: Fri, 1 Nov 2013 01:50:43 -0700
Message-ID: <20131101085043.GF4067@linux.vnet.ibm.com>
References: <20131031211055.10355.98182.stgit@dragon>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:49142 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217Ab3KAIus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 04:50:48 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 1 Nov 2013 02:50:48 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 32B7C3E40026
	for <netdev@vger.kernel.org>; Fri,  1 Nov 2013 02:50:45 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA18oihr289508
	for <netdev@vger.kernel.org>; Fri, 1 Nov 2013 02:50:44 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rA18rZ8g000694
	for <netdev@vger.kernel.org>; Fri, 1 Nov 2013 02:53:35 -0600
Content-Disposition: inline
In-Reply-To: <20131031211055.10355.98182.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 31, 2013 at 10:10:55PM +0100, Jesper Dangaard Brouer wrote:
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

Looks good to me!

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> ---
> 
>  include/net/codel.h |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/codel.h b/include/net/codel.h
> index 389cf62..3b04ff5 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -72,10 +72,21 @@ static inline codel_time_t codel_get_time(void)
>  	return ns >> CODEL_SHIFT;
>  }
> 
> -#define codel_time_after(a, b)		((s32)(a) - (s32)(b) > 0)
> -#define codel_time_after_eq(a, b)	((s32)(a) - (s32)(b) >= 0)
> -#define codel_time_before(a, b)		((s32)(a) - (s32)(b) < 0)
> -#define codel_time_before_eq(a, b)	((s32)(a) - (s32)(b) <= 0)
> +/* Dealing with timer wrapping, according to RFC 1982, as desc in wikipedia:
> + *  https://en.wikipedia.org/wiki/Serial_number_arithmetic#General_Solution
> + * codel_time_after(a,b) returns true if the time a is after time b.
> + */
> +#define codel_time_after(a, b)						\
> +	(typecheck(codel_time_t, a) &&					\
> +	 typecheck(codel_time_t, b) &&					\
> +	 ((s32)((a) - (b)) > 0))
> +#define codel_time_before(a, b) 	codel_time_after(b, a)
> +
> +#define codel_time_after_eq(a, b)					\
> +	(typecheck(codel_time_t, a) &&					\
> +	 typecheck(codel_time_t, b) &&					\
> +	 ((s32)((a) - (b)) >= 0))
> +#define codel_time_before_eq(a, b)	codel_time_after_eq(b, a)
> 
>  /* Qdiscs using codel plugin must use codel_skb_cb in their own cb[] */
>  struct codel_skb_cb {
> 
