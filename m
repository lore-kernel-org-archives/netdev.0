From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Export skb_zerocopy() to zerocopy
 from one skb to another
Date: Fri, 24 May 2013 08:31:56 -0700
Message-ID: <1369409516.3301.407.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <d209be514b6eff718e0b6562da289faadd014806.1369406826.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34397 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310Ab3EXPb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 11:31:59 -0400
Received: by mail-pd0-f181.google.com with SMTP id bv13so2432180pdb.12
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 08:31:58 -0700 (PDT)
In-Reply-To: <d209be514b6eff718e0b6562da289faadd014806.1369406826.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 16:52 +0200, Thomas Graf wrote:
> Make the skb zerocopy logic written for nfnetlink queue available for
> use by other modules.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  include/linux/skbuff.h               |  2 ++
>  net/core/skbuff.c                    | 46 +++++++++++++++++++++++++++++++++++
>  net/netfilter/nfnetlink_queue_core.c | 47 +-----------------------------------
>  3 files changed, 49 insertions(+), 46 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2e0ced1..ff2cbe8 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2478,6 +2478,8 @@ extern int             skb_splice_bits(struct sk_buff *skb,
>  						unsigned int len,
>  						unsigned int flags);
>  extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
> +extern void	       skb_zerocopy(struct sk_buff *to, const struct sk_buff *from,
> +				    int len, int hlen);
>  extern void	       skb_split(struct sk_buff *skb,
>  				 struct sk_buff *skb1, const u32 len);
>  extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d629891..cb60bf6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2118,6 +2118,52 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
>  }
>  EXPORT_SYMBOL(skb_copy_and_csum_dev);
>  
> +void
> +skb_zerocopy(struct sk_buff *to, const struct sk_buff *from, int len, int hlen)
> +{
> +	int i, j = 0;
> +	int plen = 0; /* length of skb->head fragment */
> +	struct page *page;
> +	unsigned int offset;
> +
> +	/* dont bother with small payloads */
> +	if (len <= skb_tailroom(to)) {
> +		skb_copy_bits(from, 0, skb_put(to, len), len);
> +		return;
> +	}
> +
> +	if (hlen) {
> +		skb_copy_bits(from, 0, skb_put(to, hlen), hlen);
> +		len -= hlen;
> +	} else {
> +		plen = min_t(int, skb_headlen(from), len);
> +		if (plen) {
> +			page = virt_to_head_page(from->head);

Hmm. Big warning here : In the nfnetlink case, we specifically made sure
that this path was taken only if skb->head_frag was set (all incoming
packets have this property, but not outgoing ones yet)

This should be documented if we move it to net/core/skbuff.c, or we
should add a BUG_ON()

I see your openvswitch code seems OK.

Maybe also put in net/core/skbuff.c the code dealing with  this stuff ?

+       if (!skb->head_frag ||
+           skb_headlen(skb) < L1_CACHE_BYTES ||
+           skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS)
+               hlen = skb_headlen(skb);
+
+       if (skb_has_frag_list(skb))
+               hlen = skb->len;



> +			offset = from->data - (unsigned char *)page_address(page);
> +			__skb_fill_page_desc(to, 0, page, offset, plen);
> +			get_page(page);
> +			j = 1;
> +			len -= plen;
> +		}
> +	}
