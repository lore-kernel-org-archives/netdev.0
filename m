From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Tue, 10 Apr 2012 16:19:19 +0100
Message-ID: <1334071159.5394.52.camel@zakaz.uk.xensource.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
	 <1334070301.5300.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:43676 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629Ab2DJPTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:19:22 -0400
In-Reply-To: <1334070301.5300.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 16:05 +0100, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> > As of the previous patch we align the end (rather than the start) of the struct
> > to a cache line and so, with 32 and 64 byte cache lines and the shinfo size
> > increase from the next patch, the first 8 bytes of the struct end up on a
> > different cache line to the rest of it so make sure it is something relatively
> > unimportant to avoid hitting an extra cache line on hot operations such as
> > kfree_skb.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  include/linux/skbuff.h |   15 ++++++++++-----
> >  net/core/skbuff.c      |    5 ++++-
> >  2 files changed, 14 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 0ad6a46..f0ae39c 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -265,6 +265,15 @@ struct ubuf_info {
> >   * the end of the header data, ie. at skb->end.
> >   */
> >  struct skb_shared_info {
> > +	/* Intermediate layers must ensure that destructor_arg
> > +	 * remains valid until skb destructor */
> > +	void		*destructor_arg;
> > +
> > +	/*
> > +	 * Warning: all fields from here until dataref are cleared in
> > +	 * __alloc_skb()
> > +	 *
> > +	 */
> >  	unsigned char	nr_frags;
> >  	__u8		tx_flags;
> >  	unsigned short	gso_size;
> > @@ -276,14 +285,10 @@ struct skb_shared_info {
> >  	__be32          ip6_frag_id;
> >  
> >  	/*
> > -	 * Warning : all fields before dataref are cleared in __alloc_skb()
> > +	 * Warning: all fields before dataref are cleared in __alloc_skb()
> >  	 */
> >  	atomic_t	dataref;
> >  
> > -	/* Intermediate layers must ensure that destructor_arg
> > -	 * remains valid until skb destructor */
> > -	void *		destructor_arg;
> > -
> >  	/* must be last field, see pskb_expand_head() */
> >  	skb_frag_t	frags[MAX_SKB_FRAGS];
> >  };
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index d4e139e..b8a41d6 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -214,7 +214,10 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
> >  
> >  	/* make sure we initialize shinfo sequentially */
> >  	shinfo = skb_shinfo(skb);
> > -	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> > +
> > +	memset(&shinfo->nr_frags, 0,
> > +	       offsetof(struct skb_shared_info, dataref)
> > +	       - offsetof(struct skb_shared_info, nr_frags));
> >  	atomic_set(&shinfo->dataref, 1);
> >  	kmemcheck_annotate_variable(shinfo->destructor_arg);
> >  
> 
> Not sure if we can do the same in build_skb()

I don't think there's any chance of there being a destructor_arg to
preserve in that case?

Regardless of that though I think for consistency it would be worth
pulling the common shinfo init out into a helper and using it in both
places.

I'll make that change.

Ian.

> 
> 
