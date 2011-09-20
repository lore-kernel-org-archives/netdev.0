From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] macvtap: fix the uninitialized var using in
 macvtap_alloc_skb()
Date: Tue, 20 Sep 2011 11:58:03 +0100
Message-ID: <1316516283.3891.27.camel@zakaz.uk.xensource.com>
References: <20110919094830.6272.40503.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	 <20110919095415.GD4501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110919095415.GD4501@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-09-19 at 12:54 +0300, Michael S. Tsirkin wrote:
> On Mon, Sep 19, 2011 at 05:48:31PM +0800, Jason Wang wrote:
> > Commit d1b08284 use new frag API but would leave f to be used
> > uninitialized, this patch fix it.
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Good catch. Makes absolute sense.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Agreed. I like this one better than the one I just sent out so:

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks Jason.

> 
> > ---
> >  drivers/net/macvtap.c |   12 +++++-------
> >  1 files changed, 5 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > index 7c3f84a..3da5578 100644
> > --- a/drivers/net/macvtap.c
> > +++ b/drivers/net/macvtap.c
> > @@ -453,7 +453,6 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
> >  	int copy = skb_headlen(skb);
> >  	int size, offset1 = 0;
> >  	int i = 0;
> > -	skb_frag_t *f;
> >  
> >  	/* Skip over from offset */
> >  	while (count && (offset >= from->iov_len)) {
> > @@ -503,14 +502,13 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
> >  		skb->truesize += len;
> >  		atomic_add(len, &skb->sk->sk_wmem_alloc);
> >  		while (len) {
> > -			__skb_fill_page_desc(
> > -				skb, i, page[i],
> > -				base & ~PAGE_MASK,
> > -				min_t(int, len, PAGE_SIZE - f->page_offset));
> > +			int off = base & ~PAGE_MASK;
> > +			int size = min_t(int, len, PAGE_SIZE - off);
> > +			__skb_fill_page_desc(skb, i, page[i], off, size);
> >  			skb_shinfo(skb)->nr_frags++;
> >  			/* increase sk_wmem_alloc */
> > -			base += f->size;
> > -			len -= f->size;
> > +			base += size;
> > +			len -= size;
> >  			i++;
> >  		}
> >  		offset1 = 0;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
