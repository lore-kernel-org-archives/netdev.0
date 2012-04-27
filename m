From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4 net-next] tg3: provide frags as skb head
Date: Fri, 27 Apr 2012 17:33:06 +0100
Message-ID: <1335544386.2618.50.camel@bwh-desktop.uk.solarflarecom.com>
References: <1335522889.2775.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9341 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754460Ab2D0QdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 12:33:12 -0400
In-Reply-To: <1335522889.2775.231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 12:34 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> This patch converts tg3 driver, one of our reference drivers, to use new
> build_skb() api in frag mode.
> 
> Instead of using kmalloc() to allocate the memory block that will be
> used by build_skb() as skb->head, we use a page fragment.
> 
> This is a followup of patch "net: allow skb->head to be a page fragment"
> 
> This allows GRO, TCP coalescing, and splice() to be more efficient.
> 
> Incidentally, this also removes SLUB slow path contention in kfree()
[...]
> @@ -5617,17 +5626,48 @@ static void tg3_tx(struct tg3_napi *tnapi)
>  	}
>  }
>  
> +static void *tg3_frag_alloc(struct tg3_rx_prodring_set *tpr)
> +{
> +	void *data;
> +
> +	if (tpr->rx_page_size < TG3_FRAGSIZE) {
> +		struct page *page = alloc_page(GFP_ATOMIC);
> +
> +		if (!page)
> +			return NULL;
> +		atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count); 
> +		tpr->rx_page_addr = page_address(page);
[...]

page_address() may return NULL if CONFIG_HIGHMEM is enabled.  And that's
going to be a general problem with this scheme on 32-bit machines.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
