From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v3 02/13] sock: skb_copy_ubufs support for
 compound pages
Date: Thu, 22 Jun 2017 13:05:28 -0400 (EDT)
Message-ID: <20170622.130528.1762873686654379973.davem@davemloft.net>
References: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
        <20170621211816.53837-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621211816.53837-3-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 21 Jun 2017 17:18:05 -0400

> @@ -958,15 +958,20 @@ EXPORT_SYMBOL_GPL(skb_morph);
>   */
>  int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  {
> -	int i;
>  	int num_frags = skb_shinfo(skb)->nr_frags;
>  	struct page *page, *head = NULL;
>  	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
> +	int i, new_frags;
> +	u32 d_off;

Reverse christmas tree with the local variable declarations.

> +	page = head;
> +	d_off = 0;
> +	for (i = 0; i < num_frags; i++) {
> +		u8 *vaddr;
> +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> +		u32 f_off, f_size, copy;

Likewise.

> +		f_off = f->page_offset;
> +		f_size = f->size;
> +
> +		vaddr = kmap_atomic(skb_frag_page(f));

I looked at some kmap_atomic() implementations and I do not think
it supports compound pages.
