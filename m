From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 23:24:07 +1100
Message-ID: <20090107122407.GC25673@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38679 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751481AbZAGMYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:24:53 -0500
Content-Disposition: inline
In-Reply-To: <20090107122205.GA6051@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 01:22:05PM +0100, Willy Tarreau wrote:
>
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 5110b35..4c080cd 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -73,17 +73,13 @@ static struct kmem_cache *skbuff_fclone_cache __read_mostly;
> >  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
> >  				  struct pipe_buffer *buf)
> >  {
> > -	struct sk_buff *skb = (struct sk_buff *) buf->private;
> > -
> > -	kfree_skb(skb);
> > +	put_page(buf->page);
> >  }
> >  
> >  static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
> >  				struct pipe_buffer *buf)
> >  {
> > -	struct sk_buff *skb = (struct sk_buff *) buf->private;
> > -
> > -	skb_get(skb);
> > +	get_page(buf->page);
> >  }

Well this patch can only make it worse because not only are you
still ref counting skb->head with get_page, but you've also
completely removed the skb ref count which means that the corruption
can only occur sooner.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
