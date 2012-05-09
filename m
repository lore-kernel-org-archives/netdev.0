From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Wed, 9 May 2012 10:36:31 +0100
Message-ID: <1336556191.25514.44.camel@zakaz.uk.xensource.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
	 <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
	 <20120507102441.GA18591@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:47251 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758939Ab2EIJgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 05:36:33 -0400
In-Reply-To: <20120507102441.GA18591@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 945b807..f009abb 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -697,31 +697,25 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
> >  }
> >  EXPORT_SYMBOL_GPL(skb_morph);
> >  
> > -/*	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
> > - *	@skb: the skb to modify
> > - *	@gfp_mask: allocation priority
> > - *
> > - *	This must be called on SKBTX_DEV_ZEROCOPY skb.
> > - *	It will copy all frags into kernel and drop the reference
> > - *	to userspace pages.
> > - *
> > - *	If this function is called from an interrupt gfp_mask() must be
> > - *	%GFP_ATOMIC.
> > - *
> > - *	Returns 0 on success or a negative error code on failure
> > - *	to allocate kernel memory to copy to.
> > +/*
> > + * If uarg != NULL copy and replace all frags.
> > + * If uarg == NULL then only copy and replace those which have a destructor
> > + * pointer.
> >   */
> > -int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> > +static int skb_copy_frags(struct sk_buff *skb, gfp_t gfp_mask,
> > +			  struct ubuf_info *uarg)
> >  {
> >  	int i;
> >  	int num_frags = skb_shinfo(skb)->nr_frags;
> >  	struct page *page, *head = NULL;
> > -	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
> >  
> >  	for (i = 0; i < num_frags; i++) {
> >  		u8 *vaddr;
> >  		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> >  
> > +		if (!uarg && !f->page.destructor)
> > +			continue;
> > +
> >  		page = alloc_page(GFP_ATOMIC);
> >  		if (!page) {
> >  			while (head) {
> > @@ -739,11 +733,16 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> >  		head = page;
> >  	}
> >  
> > -	/* skb frags release userspace buffers */
> > -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> > +	/* skb frags release buffers */
> > +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> > +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> > +		if (!uarg && !f->page.destructor)
> > +			continue;
> >  		skb_frag_unref(skb, i);
> > +	}
> >  
> > -	uarg->callback(uarg);
> > +	if (uarg)
> > +		uarg->callback(uarg);
> >  
> 
> So above we only linked up copied pages, but below we
> try to use the list for all frags. Looks like a bug,
> I think it needs to check destructor and uarg too.

You are absolutely correct. We need the same check in all three loops.

> 
> 
> >  	/* skb frags point to kernel buffers */
> >  	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> > @@ -752,10 +751,41 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> >  		head = (struct page *)head->private;
> >  	}
> >  
> > -	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> >  	return 0;
> >  }
