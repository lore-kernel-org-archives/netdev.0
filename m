From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 16:41:38 +0300
Message-ID: <20120604134138.GA29814@redhat.com>
References: <20120517121800.GA18052@1wt.eu>
 <20120517150157.GA19274@1wt.eu>
 <1337269380.3403.10.camel@edumazet-glaptop>
 <20120517155621.GK14498@1wt.eu>
 <1337272404.3403.18.camel@edumazet-glaptop>
 <20120517164016.GL14498@1wt.eu>
 <1337273387.3403.24.camel@edumazet-glaptop>
 <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab2FDNmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 09:42:04 -0400
Content-Disposition: inline
In-Reply-To: <1338815213.2760.1806.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 03:06:53PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 15:37 +0300, Michael S. Tsirkin wrote:
> > On Thu, May 17, 2012 at 07:34:16PM +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > Please note I havent tested yet this patch, lacking hardware for this.
> > > 
> > > (tg3/bnx2/bnx2x use build_skb, r8169 does a copy of incoming frames,
> > > ixgbe uses fragments...)
> > 
> > virtio-net uses netdev_alloc_skb but maybe it should call
> > build_skb instead?
> > 
> > Also, it's not uncommon for drivers to copy short packets out to be able
> > to reuse pages.  virtio does this but I am guessing the logic is not
> > really virtio specific.
> > 
> > We could do
> > 	if (len < GOOD_COPY_LEN)
> > 		netdev_alloc_skb
> > 		memmov
> > 	else
> > 		build_skb
> > 
> > but maybe it makes sense to put this logic in build_skb?
> > 
> > 
> 
> I am not sure to understand the question.
> 
> If virtio-net uses netdev_alloc_skb(), all is good, you have nothing to
> change.
> 
> build_skb() is for drivers that allocate the memory to hold frame, and
> wait for NIC completion before allocating/populating the skb itself.
> 


This is generally what virtio does, take a look:
page_to_skb fills the first fragment and receive_mergeable fills the
rest (other modes are for legacy hardware).

The way hypervisor now works is this (we call it mergeable buffers):

- pages are passed to hardware
- hypervisor puts virtio specific stuff in first 12 bytes
  on first page
- following this, the rest of the first page and all following
  pages have data

The driver gets the 1st page, allocates the skb, copies out the 12 byte
header and copies the first 128 bytes of data into skb.
The rest if any is populated by the pages.

So I guess I'm asking for advice, would it make sense to switch to build_skb
and how best to handle the data copying above? Maybe it would help
if we changed the hypervisor to write the 12 bytes separately?
  


-- 
MST
