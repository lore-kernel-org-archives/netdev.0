From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [RFC PATCH]: Fix a warning in the niu driver
Date: Wed, 14 Jul 2010 09:18:31 -0400
Message-ID: <4C3DB927.2060106@redhat.com>
References: <4C3514ED.2060904@redhat.com> <20100707.170820.146356362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873Ab0GNNUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 09:20:51 -0400
In-Reply-To: <20100707.170820.146356362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Your patch would corrupt the list state, since we'd leave
> pages in the rx page hash which have only externally references
> and thus will be freed up.
>
>   

Ah ... I totally missed that.  Thanks for clarifying that Dave.

> Just BUG() if the loop terminates without finding a page.
>
> --------------------
> niu: BUG on inability to find page in rx page hashes.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 3d523cb..5d36531 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
> @@ -3330,10 +3330,12 @@ static struct page *niu_find_rxpage(struct rx_ring_info *rp, u64 addr,
>  	for (; (p = *pp) != NULL; pp = (struct page **) &p->mapping) {
>  		if (p->index == addr) {
>  			*link = pp;
> -			break;
> +			goto found;
>  		}
>  	}
> +	BUG();
>  
> +found:
>  	return p;
>  }
>   

Dave, would it be acceptable if I then wrapped link in
uninitialized_var() to get rid of the warning I'm trying to resolve?  It
seems that your patch then checks for a valid page value so it should be
okay.

P.

