From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Tue, 10 Apr 2012 17:05:01 +0200
Message-ID: <1334070301.5300.65.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59857 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab2DJPFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:05:09 -0400
Received: by bkcik5 with SMTP id ik5so4309040bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 08:05:07 -0700 (PDT)
In-Reply-To: <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> As of the previous patch we align the end (rather than the start) of the struct
> to a cache line and so, with 32 and 64 byte cache lines and the shinfo size
> increase from the next patch, the first 8 bytes of the struct end up on a
> different cache line to the rest of it so make sure it is something relatively
> unimportant to avoid hitting an extra cache line on hot operations such as
> kfree_skb.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/linux/skbuff.h |   15 ++++++++++-----
>  net/core/skbuff.c      |    5 ++++-
>  2 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0ad6a46..f0ae39c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -265,6 +265,15 @@ struct ubuf_info {
>   * the end of the header data, ie. at skb->end.
>   */
>  struct skb_shared_info {
> +	/* Intermediate layers must ensure that destructor_arg
> +	 * remains valid until skb destructor */
> +	void		*destructor_arg;
> +
> +	/*
> +	 * Warning: all fields from here until dataref are cleared in
> +	 * __alloc_skb()
> +	 *
> +	 */
>  	unsigned char	nr_frags;
>  	__u8		tx_flags;
>  	unsigned short	gso_size;
> @@ -276,14 +285,10 @@ struct skb_shared_info {
>  	__be32          ip6_frag_id;
>  
>  	/*
> -	 * Warning : all fields before dataref are cleared in __alloc_skb()
> +	 * Warning: all fields before dataref are cleared in __alloc_skb()
>  	 */
>  	atomic_t	dataref;
>  
> -	/* Intermediate layers must ensure that destructor_arg
> -	 * remains valid until skb destructor */
> -	void *		destructor_arg;
> -
>  	/* must be last field, see pskb_expand_head() */
>  	skb_frag_t	frags[MAX_SKB_FRAGS];
>  };
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d4e139e..b8a41d6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -214,7 +214,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
> -	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> +
> +	memset(&shinfo->nr_frags, 0,
> +	       offsetof(struct skb_shared_info, dataref)
> +	       - offsetof(struct skb_shared_info, nr_frags));
>  	atomic_set(&shinfo->dataref, 1);
>  	kmemcheck_annotate_variable(shinfo->destructor_arg);
>  

Not sure if we can do the same in build_skb()
