From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/6] macvtap: zerocopy: validate vector length before
 pinning user pages
Date: Tue, 17 Apr 2012 09:19:19 +0300
Message-ID: <20120417061918.GA20905@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <20120416060807.14140.96229.stgit@intel-e5620-16-2.englab.nay.redhat.com>
 <1334559183.28012.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	xma@us.ibm.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab2DQHO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 03:14:26 -0400
Content-Disposition: inline
In-Reply-To: <1334559183.28012.45.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 16, 2012 at 08:53:03AM +0200, Eric Dumazet wrote:
> On Mon, 2012-04-16 at 14:08 +0800, Jason Wang wrote:
> > Currently we do not validate the vector length before calling
> > get_user_pages_fast(), host stack would be easily overflowed by
> > malicious guest driver who give us a descriptor with length greater
> > than MAX_SKB_FRAGS. Solve this problem by checking the free entries
> > before trying to pin user pages.
> > 
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > ---
> >  drivers/net/macvtap.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > index 7cb2684..d197a78 100644
> > --- a/drivers/net/macvtap.c
> > +++ b/drivers/net/macvtap.c
> > @@ -529,6 +529,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
> >  		}
> >  		base = (unsigned long)from->iov_base + offset;
> >  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> > +		if (i + size >= MAX_SKB_FRAGS)
> > +			return -EFAULT;
> >  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
> >  		if ((num_pages != size) ||
> >  		    (num_pages > MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
> > 
> 
> Hi Jason
> 
> Why is -EFAULT the right error code ?


skb_copy_datagram_from_iovec return -EFAULT on iovs
that are too large, too, so this is at least consistent.

-- 
MST
