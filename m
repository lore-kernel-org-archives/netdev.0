From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 2/2] net: skbuff: do not allocate emergency
 memory if flags is not __GFP_MEMALLOC
Date: Sat, 23 Aug 2014 16:53:49 -0700
Message-ID: <1408838029.5604.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408829839-20742-1-git-send-email-_govind@gmx.com>
	 <1408829839-20742-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	mgorman@suse.de
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35093 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaHWXxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 19:53:52 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so17387918pdj.26
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 16:53:52 -0700 (PDT)
In-Reply-To: <1408829839-20742-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-08-24 at 03:07 +0530, Govindarajulu Varadarajan wrote:
> It is possible that nc->frag.page is previously allocated from emergency memory.
> For new alloc call, if the flags does not contain __GFP_MEMALLOC, do not
> return pfmemalloc memory.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  net/core/skbuff.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 51a3328..792ce89 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -364,6 +364,13 @@ recycle:
>  		atomic_set(&nc->frag.page->_count, NETDEV_PAGECNT_MAX_BIAS);
>  		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
>  		nc->frag.offset = 0;
> +	} else if (nc->frag.page->pfmemalloc && !(gfp_mask & __GFP_MEMALLOC)) {
> +		if (atomic_sub_and_test(nc->pagecnt_bias,
> +					&nc->frag.page->_count)) {
> +			atomic_set(&nc->frag.page->_count, 1);
> +			kfree(page_address(nc->frag.page));

No idea of what you think you do.

How have you tested this patch ?

> +		}
> +		goto refill;
>  	}
>  
>  	if (nc->frag.offset + fragsz > nc->frag.size) {
