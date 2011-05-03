From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V3 3/8] Add userspace buffers support in skb
Date: Tue, 03 May 2011 10:36:48 -0700
Message-ID: <1304444208.20660.24.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
	 <1303328877.19336.28.camel@localhost.localdomain>
	 <20110502105348.GA21706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110502105348.GA21706@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 13:53 +0300, Michael S. Tsirkin wrote:
> On Wed, Apr 20, 2011 at 12:47:57PM -0700, Shirley Ma wrote:
> > This patch adds userspace buffers support in skb. A new struct
> > skb_ubuf_info is needed to maintain the userspace buffers argument
> > and index, a callback is used to notify userspace to release the
> > buffers once lower device has done DMA (Last reference to that skb
> > has gone).
> > 
> > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > ---
> > 
> >  include/linux/skbuff.h |   14 ++++++++++++++
> >  net/core/skbuff.c      |   15 ++++++++++++++-
> >  2 files changed, 28 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index d0ae90a..47a187b 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -189,6 +189,16 @@ enum {
> >       SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
> >  };
> >  
> > +/* The callback notifies userspace to release buffers when skb DMA
> is done in
> > + * lower device, the desc is used to track userspace buffer index.
> > + */
> > +struct skb_ubuf_info {
> > +     /* support buffers allocation from userspace */
> > +     void            (*callback)(struct sk_buff *);
> > +     void            *arg;
> > +     size_t          desc;
> > +};
> > +
> >  /* This data is invariant across clones and lives at
> >   * the end of the header data, ie. at skb->end.
> >   */
> > @@ -211,6 +221,10 @@ struct skb_shared_info {
> >       /* Intermediate layers must ensure that destructor_arg
> >        * remains valid until skb destructor */
> >       void *          destructor_arg;
> > +
> > +     /* DMA mapping from/to userspace buffers */
> > +     struct skb_ubuf_info ubuf;
> > +
> >       /* must be last field, see pskb_expand_head() */
> >       skb_frag_t      frags[MAX_SKB_FRAGS];
> >  };
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 7ebeed0..822c07d 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -210,6 +210,8 @@ struct sk_buff *__alloc_skb(unsigned int size,
> gfp_t gfp_mask,
> >       shinfo = skb_shinfo(skb);
> >       memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> >       atomic_set(&shinfo->dataref, 1);
> > +     shinfo->ubuf.callback = NULL;
> > +     shinfo->ubuf.arg = NULL;
> >       kmemcheck_annotate_variable(shinfo->destructor_arg);
> >  
> >       if (fclone) {
> > @@ -327,7 +329,15 @@ static void skb_release_data(struct sk_buff
> *skb)
> >                       for (i = 0; i < skb_shinfo(skb)->nr_frags; i
> ++)
> >                               put_page(skb_shinfo(skb)->frags[i].page);
> >               }
> > -
> > +             /*
> > +              * if skb buf is from userspace, we need to notify the
> caller
> > +              * the lower device DMA has done;
> > +              */
> > +             if (skb_shinfo(skb)->ubuf.callback) {
> > +                     skb_shinfo(skb)->ubuf.callback(skb);
> > +                     skb_shinfo(skb)->ubuf.callback = NULL;
> > +                     skb_shinfo(skb)->ubuf.arg = NULL;
> > +             }
> >               if (skb_has_frag_list(skb))
> >                       skb_drop_fraglist(skb);
> >  
> 
> We probably don't need to touch arg if callback is NULL?

Yes.

> > @@ -480,6 +490,9 @@ bool skb_recycle_check(struct sk_buff *skb, int
> skb_size)
> >       if (irqs_disabled())
> >               return false;
> >  
> > +     if (shinfo->ubuf.callback)
> > +             return false;
> > +
> >       if (skb_is_nonlinear(skb) || skb->fclone !=
> SKB_FCLONE_UNAVAILABLE)
> >               return false;
> 
> This is not the only API unsupported for these skbs, is it?
> Probably need to check and fail there as well. 

Yes, I am going through all these skbs to make sure covering all.

Thanks
Shirley
