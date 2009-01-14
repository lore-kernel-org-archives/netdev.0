From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 14:51:24 +1100
Message-ID: <20090114035124.GA8409@gondor.apana.org.au>
References: <20090113.163705.130074998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49570 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752621AbZANDwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 22:52:07 -0500
Content-Disposition: inline
In-Reply-To: <20090113.163705.130074998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5110b35..05126da 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -70,12 +70,17 @@
> static struct kmem_cache *skbuff_head_cache __read_mostly;
> static struct kmem_cache *skbuff_fclone_cache __read_mostly;
> 
> +static void skb_release_data(struct sk_buff *skb);
> +
> static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>                                  struct pipe_buffer *buf)
> {
>        struct sk_buff *skb = (struct sk_buff *) buf->private;
> 
> -       kfree_skb(skb);
> +       if (skb)
> +               skb_release_data(skb);
> +       else
> +               put_page(buf->page);
> }

Unfortunately this won't work, not even for network destinations.

The reason is that this gets called as soon as the destination's
splice hook returns, for networking that means when sendpage returns.

So by that time we'll still be left with just a page reference
on a page where the slab memory may already have been freed.

To make this work we need to get the destination's splice hooks
to acquire this reference.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
