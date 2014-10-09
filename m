From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] niu: remove unnecessary atomic operation
Date: Thu, 09 Oct 2014 16:40:18 -0700
Message-ID: <1412898018.3751.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412875428.18196.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:43401 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaJIXkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 19:40:21 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so568736pde.14
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 16:40:20 -0700 (PDT)
In-Reply-To: <1412875428.18196.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-09 at 10:23 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> We allocate single page, compound_head() is not needed.
> 
> We own the page, we can simply set page->_count to the
> needed value instead of doing a locked addition.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/sun/niu.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
> index 904fd1ab5f6e..ec2cd8a6d5bc 100644
> --- a/drivers/net/ethernet/sun/niu.c
> +++ b/drivers/net/ethernet/sun/niu.c
> @@ -3340,9 +3340,8 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
>  	}
>  
>  	niu_hash_page(rp, page, addr);
> -	if (rp->rbr_blocks_per_page > 1)
> -		atomic_add(rp->rbr_blocks_per_page - 1,
> -			   &compound_head(page)->_count);
> +
> +	atomic_set(&page->_count, rp->rbr_blocks_per_page);
>  
>  	for (i = 0; i < rp->rbr_blocks_per_page; i++) {
>  		__le32 *rbr = &rp->rbr[start_index + i];
> 

Please disregard this patch.

We need to fix all usages of atomic_set() on page->_count as they are
racy.

I'll send fixes.
