From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Tue, 19 Jun 2012 18:49:04 -0700
Message-ID: <4FE12C10.7060207@gmail.com>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50324 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab2FTBtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 21:49:14 -0400
Received: by dady13 with SMTP id y13so9150933dad.19
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2012 18:49:14 -0700 (PDT)
In-Reply-To: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/2012 5:43 PM, Alexander Duyck wrote:
> This patch is meant to help improve system performance when
> netdev_alloc_frag is used in scenarios in which buffers are short lived.
> This is accomplished by allowing the page offset to be reset in the event
> that the page count is 1.  I also reordered the direction in which we give
> out sections of the page so that we start at the end of the page and end at
> the start.  The main motivation being that I preferred to have offset
> represent the amount of page remaining to be used.
>
> My primary test case was using ixgbe in combination with TCP.  With this
> patch applied I saw CPU utilization drop from 3.4% to 3.0% for a single
> thread of netperf receiving a TCP stream via ixgbe.
>
> I also tested several scenarios in which the page reuse would not be
> possible such as UDP flows and routing.  In both of these scenarios I saw
> no noticeable performance degradation compared to the kernel without this
> patch.
>
> Cc: Eric Dumazet<edumazet@google.com>
> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
> ---
>
>   net/core/skbuff.c |   15 +++++++++++----
>   1 files changed, 11 insertions(+), 4 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5b21522..eb3853c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -317,15 +317,22 @@ void *netdev_alloc_frag(unsigned int fragsz)
>   	if (unlikely(!nc->page)) {
>   refill:
>   		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> -		nc->offset = 0;
>   	}
>   	if (likely(nc->page)) {
> -		if (nc->offset + fragsz>  PAGE_SIZE) {
> +		unsigned int offset = PAGE_SIZE;
> +
> +		if (page_count(nc->page) != 1)
> +			offset = nc->offset;
> +
> +		if (offset<  fragsz) {
>   			put_page(nc->page);
>   			goto refill;
>   		}
> -		data = page_address(nc->page) + nc->offset;
> -		nc->offset += fragsz;
> +
> +		offset -= fragsz;
> +		nc->offset = offset;
> +
> +		data = page_address(nc->page) + offset;
>   		get_page(nc->page);
>   	}
>   	local_irq_restore(flags);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
It looks like I forgot to add "--auto" to the command line when I sent 
this out via stg mail so I am just adding Eric to the CC list on this 
reply.  Sorry for the extra noise.

Thanks,

Alex
