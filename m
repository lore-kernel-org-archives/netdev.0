From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Wed, 11 Apr 2012 07:56:24 +0000
Message-ID: <1334130984.12209.195.camel@dagon.hellion.org.uk>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
	 <4F847CF9.3090701@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:41356 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab2DKH40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 03:56:26 -0400
In-Reply-To: <4F847CF9.3090701@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 19:33 +0100, Alexander Duyck wrote:
> On 04/10/2012 07:26 AM, Ian Campbell wrote:
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
> Have you checked this for 32 bit as well as 64?  Based on my math your
> next patch will still mess up the memset on 32 bit with the structure
> being split somewhere just in front of hwtstamps.

You mean 32 byte cache lines? If so then yes there is a split half way
through the structure in that case but there's no way all this data
could ever fit in a single 32 byte cache line. Not including the frags
or destructor_arg the region nr_frags up to and including dataref is 36
bytes on 32 bit and 40 bytes on 64 bit. I've not changed anything in
this respect.

If you meant 64 byte cache lines with 32 bit structure sizes then by my
calculations everything from destructor_arg (in fact a bit earlier, from
12 bytes before then) up to and including frag[0] is in the same 64 byte
cache line.

I find the easiest way to check is to use gdb and open code an offsetof
macro.

(gdb) print/d sizeof(struct skb_shared_info) - (unsigned long)&(((struct skb_shared_info *)0)->nr_frags)
$3 = 240
(gdb) print/d sizeof(struct skb_shared_info) - (unsigned long)&(((struct skb_shared_info *)0)->frags[1])
$4 = 192

So given 64 byte cache lines the interesting area starts at 240/64=3.75
cache lines from the (aligned) end and it finishes just before 192/64=3
cache lines from the end, so nr_frags through to frags[0] are therefore
on the same cache line.

Ian.
