From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 17:17:31 +0300
Message-ID: <20120604141731.GA30226@redhat.com>
References: <1337269380.3403.10.camel@edumazet-glaptop>
 <20120517155621.GK14498@1wt.eu>
 <1337272404.3403.18.camel@edumazet-glaptop>
 <20120517164016.GL14498@1wt.eu>
 <1337273387.3403.24.camel@edumazet-glaptop>
 <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22508 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab2FDOR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 10:17:57 -0400
Content-Disposition: inline
In-Reply-To: <1338818501.2760.1821.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 04:01:41PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 16:41 +0300, Michael S. Tsirkin wrote:
> 
> > This is generally what virtio does, take a look:
> > page_to_skb fills the first fragment and receive_mergeable fills the
> > rest (other modes are for legacy hardware).
> > 
> > The way hypervisor now works is this (we call it mergeable buffers):
> > 
> > - pages are passed to hardware
> > - hypervisor puts virtio specific stuff in first 12 bytes
> >   on first page
> > - following this, the rest of the first page and all following
> >   pages have data
> > 
> > The driver gets the 1st page, allocates the skb, copies out the 12 byte
> > header and copies the first 128 bytes of data into skb.
> > The rest if any is populated by the pages.
> > 
> > So I guess I'm asking for advice, would it make sense to switch to build_skb
> > and how best to handle the data copying above? Maybe it would help
> > if we changed the hypervisor to write the 12 bytes separately?
> >   
> 
> Thanks for these details.
> 
> Not sure 12 bytes of headroom would be enough (instead of the
> NET_SKB_PAD reserved in netdev_alloc_skb_ip_align(), but what could be
> done indeed is to use the first page as the skb->head, so using
> build_skb() indeed, removing one fragment, one (small) copy and one
> {put|get}_page() pair.
> 

bnx2 and tg3 both do skb_reserve of at least NET_SKB_PAD
after build_skb. You are saying it's not a must?

Hmm so maybe we should teach the hypervisor to write data
out at an offset. Interesting.

Another question is about very small packets truesize.
build_skb sets truesize to frag_size but isn't
this too small? We keep the whole page around, no?
