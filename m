From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Tue, 10 Apr 2012 11:33:29 -0700
Message-ID: <4F847CF9.3090701@intel.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com> <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9850 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337Ab2DJSdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 14:33:35 -0400
In-Reply-To: <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 07:26 AM, Ian Campbell wrote:
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

Have you checked this for 32 bit as well as 64?  Based on my math your
next patch will still mess up the memset on 32 bit with the structure
being split somewhere just in front of hwtstamps.

Why not just take frags and move it to the start of the structure?  It
is already an unknown value because it can be either 16 or 17 depending
on the value of PAGE_SIZE, and since you are making changes to frags the
changes wouldn't impact the alignment of the other values later on since
you are aligning the end of the structure.  That way you would be
guaranteed that all of the fields that will be memset would be in the
last 64 bytes.

Thanks,

Alex
