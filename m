From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Mon, 23 Nov 2009 08:07:01 -0800
Message-ID: <1258992421.5022.19.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <4B063509.10006@gmail.com> <1258734101.11049.1.camel@localhost.localdomain>
	 <200911231138.30755.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44896 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbZKWQHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 11:07:05 -0500
In-Reply-To: <200911231138.30755.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-23 at 11:38 +1030, Rusty Russell wrote:
> How about:
>         struct page *end;
> 
>         /* Find end of list, sew whole thing into vi->pages. */
>         for (end = page; end->private; end = (struct page
> *)end->private);
>         end->private = (unsigned long)vi->pages;
>         vi->pages = page;

Yes, this looks nicer.

> > +void virtio_free_pages(void *buf)
> 
> This is a terrible name; it's specific to virtio_net, plus it should
> be
> static.  Just "free_pages" should be sufficient here I think.

> 
> This smells a lot like a for loop to me?
> 
>         struct page *i, *next;
> 
>         for (i = buf; next; i = next) {
>                 next = (struct page *)i->private;
>                 __free_pages(i, 0);
>         }
Agree, will change it.

> > +static int set_skb_frags(struct sk_buff *skb, struct page *page,
> > +                             int offset, int len)
> 
> A better name might be "skb_add_frag()"?
OK.

> > +             skb = (struct sk_buff *)buf;
> This cast is unnecessary, but a comment would be nice:
>         /* Simple case: the pointer is the 1514-byte skb */
> 
> > +     } else {

Without this cast there is a compile warning. 

> And a matching comment here:
> 
>         /* The pointer is a chain of pages. */
> 
OK.

> > +             if (unlikely(!skb)) {
> > +                     dev->stats.rx_dropped++;
> 
> Does this mean we leak all those pages?  Shouldn't we give_pages()
> here?

Yes, it should call give_pages here.


> > +                     offset = hdr_len + 6;
> 
> Really?  I can't see where the current driver does this 6 byte offset.
> There
> should be a header, then the packet...
> Ah, I see below that you set things up this way.  The better way to do
> this
> is to create a new structure to use in various places.
> 
>         struct padded_vnet_hdr {
>                 struct virtio_net_hdr hdr;
>                 /* This padding makes our packet 16 byte aligned */
>                 char padding[6];
>         };
> 
> However, I question whether making it 16 byte is the right thing: the
> ethernet header is 14 bytes long, so don't we want 8 bytes of padding?

Because in QEMU it requires 10 bytes header in a separately, so one page
is used to share between virtio_net_hdr header which is 10 bytes head
and rest of data. So I put 6 bytes offset here between two buffers. I
didn't look at the reason why a seperate buf is used for virtio_net_hdr
in QEMU.

> > +             }
> 
> I think you can move the memcpy outside the if, like so:
> 
>         memcpy(&hdr, p, hdr_len);

I didn't move it out, because num_buf = hdr->mhdr.num_buffers;

> > +             if (!len)
> > +                     give_pages(vi, page);
> > +             else {
> > +                     len = set_skb_frags(skb, page, copy + offset,
> len);
> > +                     /* process big packets */
> > +                     while (len > 0) {
> > +                             page = (struct page *)page->private;
> > +                             if (!page)
> > +                                     break;
> > +                             len = set_skb_frags(skb, page, 0,
> len);
> > +                     }
> > +                     if (page && page->private)
> > +                             give_pages(vi, (struct page
> *)page->private);
> >               }
> 
> I can't help but think this statement should be one loop somehow.
> Something
> like:
> 
>         offset += copy;
> 
>         while (len) {
>                 len = skb_add_frag(skb, page, offset, len);
>                 page = (struct page *)page->private;
>                 offset = 0;
>         }
>         if (page)
>                 give_pages(vi, page);

I was little bit worried about qemu messed up len (i saw code in
mergeable buffer checking len > PAGE_SIZE), so I put page checking
inside. I will change it outside if checking len is enough.

> > -static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t
> gfp)
> > +/* Returns false if we couldn't fill entirely (OOM). */
> > +static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
> 
> The result of trying to merge all the cases here is messy.  I'd split
> it
> inside the loop into: add_recvbuf_small(vi, gfp), add_recvbuf_big(vi,
> gfp)
> and add_recvbuf_mergeable(vi, gfp).
> 
> It'll also be easier for me to review each case then, as well as
> getting
> rid of the big packets if we decide to do that later.  You could even
> do
> that split as a separate patch, before this one.

Ok, will separate it.

> destroy_buf should really be called destroy_bufs().  And I don't think
> you
> use the vi->recv skb list in this case at all, so the loop which
> purges those
> should be under an "else {" of this branch.

Yes.

> This new parameter should be introduced as a separate patch.  It
> should also be
> called destroy_bufs.  It also returns an unsigned int.  I would call
> the callback
> something a little more informative, such as "destroy"; here and in
> the header.

Ok.

> ret is a bad name for this; how about buf?
Sure.

> Overall, the patch looks good.  But it would have been nicer if it
> were
> split into several parts: cleanups, new infrastructure, then the
> actual
> allocation change.

I will try to separate this patch.

Thanks
Shirley

