From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: PATCH v2 3/4] Defer skb allocation -- new recvbuf alloc &
	receive calls
Date: Tue, 15 Dec 2009 13:33:27 +0200
Message-ID: <20091215113327.GC13110@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260535613.30371.24.camel@localhost.localdomain> <20091213114320.GC7074@redhat.com> <1260828518.8716.105.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260828518.8716.105.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 14, 2009 at 02:08:38PM -0800, Shirley Ma wrote:
> On Sun, 2009-12-13 at 13:43 +0200, Michael S. Tsirkin wrote:
> > Interesting. I think skb_goodcopy will sometimes
> > set *page to NULL. Will the above crash then?
> 
> Nope, when *page is NULL, *len is 0.

Hmm. Yes, I see, it is here:
+       if (*len) {
+               *len = skb_set_frag(skb, *page, offset, *len);
+               *page = (struct page *)(*page)->private;
+       } else {
+               give_pages(vi, *page);
+               *page = NULL;
+       }

So what I would suggest is, have function
that just copies part of skb, and have
caller open-code allocating the skb and free up
pages as necessary.

> > don't put empty line here. if below is part of same logical block as
> > skb_goodcopy.
> Ok.
> 
> > Local variable shadows a parameter.
> > It seems gcc will let you get away with a warning,
> > but this is not legal C.
> Ok.
> 
> > > +
> > > +             i = skb_shinfo(skb)->nr_frags;
> > > +             if (i >= MAX_SKB_FRAGS) {
> > > +                     pr_debug("%s: packet too long %d\n",
> > skb->dev->name,
> > > +                              len);
> > 
> > If this happens, we have corrupted memory already.
> > We do need this check, but please put is before you increment
> > nr_frags.
> 
> It is before increase for mergeable buffer case. Only one page(one frag)
> per get_buf.
> 
> > > +                     skb->dev->stats.rx_length_errors++;
> > > +                     return skb;
> > 
> > This will propagate the error up the stack and corrupt
> > more memory.
> 
> I just copied the code from original code. There might not be a problem
> for mergeable buffer. I will double check.
> 
> > sizeof hdr->hdr
> Ok.
> 
> > > +
> > > +     skb_to_sgvec(skb, sg+1, 0, skb->len);
> > 
> > space around +
> Ok.
> 
> > > +
> > > +     err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, 2, skb);
> > > +     if (err < 0)
> > > +             kfree_skb(skb);
> > > +     else
> > > +             skb_queue_head(&vi->recv, skb);
> > 
> > So why are we queueing this still?
> This is for small packet. I didn't change that code since it will
> involve extra copy by using page.

What I am asking is why do we add skb in vi->recv.
Can't we use vq destoy hack here as well?

> > > +
> > > +     return err;
> > > +}
> > > +
> > > +static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp, bool
> > *oom)
> > > +{
> > > +     struct scatterlist sg[2 + MAX_SKB_FRAGS];
> > 
> > MAX_SKB_FRAGS + 2 will be more readable.
> > Also, create a macro for this constant and document
> > why does +2 make sense?
> 
> One is for big packet virtio_net_hdr, one is for goodcopy skb.


Maybe put this in a comment then.

> > Again, pls explain *why* do we want 16 byte alignment.
> > Also this code seems duplicated?
> > Please put structs at top of file where they
> > can be found.
> Ok.
> 
> > > +     };
> > > +
> > > +     offset = sizeof(struct padded_vnet_hdr);
> > > +
> > > +     for (i = total - 1; i > 0; i--) {
> > 
> > I prefer --i.
> Ok.
> 
> > Also, total is just a constant.
> > So simply MAX_SKB_FRAGS + 1 will be clearer.
> Ok.
> 
> > Why do we scan last to first?
> > If there's reason, please add a comment.
> We use page private to maintain next page, here there is no scan last to
> first, just add the new page in list head instead of list tail, which
> will require scan the list.

I mean the for loop: can it be for(i = 0, ..., ++i) just as well?
Why do you start at the end of buffer and decrement?

> > space around - .
> Ok.
> 
> > All the if (i == 1) handling on exit is really hard to grok.
> > How about moving common code out of this loop
> > into a function, and then you can
> >         for (i = total - 1; i > 1; i--) {
> >                 handle(i);
> >         }
> >         handle(1);
> >         handle(0);
> >         add_buf
> That works.
> 
> > do we really need *oom here and below?
> > We can just set err to ENOMEM, no?
> We could.
> 
> > Please do not return 0 on failure.
> 
> Ok.
