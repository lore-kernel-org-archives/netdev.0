From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 2/6] skbuff: add an api to orphan frags
Date: Tue, 8 May 2012 15:47:24 +0300
Message-ID: <20120508124723.GB17900@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <3a000e3075bb234d628191be748423433d49a97c.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25483 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292Ab2EHMrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 08:47:22 -0400
Content-Disposition: inline
In-Reply-To: <3a000e3075bb234d628191be748423433d49a97c.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 07, 2012 at 04:54:36PM +0300, Michael S. Tsirkin wrote:
> Many places do
>        if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY))
> 		skb_copy_ubufs(skb, gfp_mask);
> to copy and invoke frag destructors if necessary.
> Add an inline helper for this.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/skbuff.h |   24 ++++++++++++++++++++++++
>  1 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index bb78f70..28d842e 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1711,6 +1711,30 @@ static inline void skb_orphan(struct sk_buff *skb)
>  }
>  
>  /**
> + *	skb_orphan_frags - orphan the frags contained in a buffer
> + *	@skb: buffer to orphan frags from
> + *	@gfp_mask: allocation mask for replacement pages
> + *
> + *	For each frag in the SKB which needs a destructor (i.e. has an
> + *	owner) create a copy of that frag and release the original
> + *	page by calling the destructor.
> + */
> +static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
> +{
> +	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
> +		return 0;
> +	return skb_copy_ubufs(skb, gfp_mask);
> +}
> +
> +
> +static inline void skb_copy_frag_destructor(struct sk_buff *to,
> +					    struct sk_buff *from)
> +{
> +	skb_shinfo(to)->tx_flags |= skb_shinfo(from)->tx_flags &
> +		SKBTX_DEV_ZEROCOPY;
> +}
> +
> +/**
>   *	__skb_queue_purge - empty a list
>   *	@list: list to empty
>   *
> -- 
> MST
> 

This last chunk should actually be part of 6/6.
squashed it here mistakenly.
