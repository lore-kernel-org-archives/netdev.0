From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 8 Feb 2010 15:26:06 -0800
Message-ID: <20100208152606.91c55722.akpm@linux-foundation.org>
References: <4B700EC2.5090207@itcare.pl>
	<1265635690.3048.8.camel@edumazet-laptop>
	<4B7012BC.9000702@itcare.pl>
	<1265637067.3048.14.camel@edumazet-laptop>
	<4B7018DF.8060600@itcare.pl>
	<1265638014.3048.20.camel@edumazet-laptop>
	<4B701CA8.7050205@itcare.pl>
	<1265639549.3048.33.camel@edumazet-laptop>
	<1265657560.4236.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	David Miller <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51567 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751820Ab0BHX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:27:10 -0500
In-Reply-To: <1265657560.4236.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Feb 2010 20:32:40 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH] dst: call cond_resched() in dst_gc_task()
> 
> On some workloads, it is quite possible to get a huge dst list to
> process in dst_gc_task(), and trigger soft lockup detection.
> 
> Fix is to call cond_resched(), as we run in process context.
> 
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 57bc4d5..cb1b348 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -17,6 +17,7 @@
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <net/net_namespace.h>
> +#include <linux/sched.h>
>  
>  #include <net/dst.h>
>  
> @@ -79,6 +80,7 @@ loop:
>  	while ((dst = next) != NULL) {
>  		next = dst->next;
>  		prefetch(&next->next);
> +		cond_resched();
>  		if (likely(atomic_read(&dst->__refcnt))) {
>  			last->next = dst;
>  			last = dst;

Gad.  Am I understanding this right?  The softlockup threshold is sixty
seconds!

I assume that this function spends most of its time walking over busy
entries?  Is a more powerful data structure needed?

