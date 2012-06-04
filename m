From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 20:20:31 +0300
Message-ID: <20120604172030.GA32205@redhat.com>
References: <1337272404.3403.18.camel@edumazet-glaptop>
 <20120517164016.GL14498@1wt.eu>
 <1337273387.3403.24.camel@edumazet-glaptop>
 <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622Ab2FDRUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 13:20:55 -0400
Content-Disposition: inline
In-Reply-To: <1338822064.2760.1834.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 05:01:04PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 17:17 +0300, Michael S. Tsirkin wrote:
> 
> > bnx2 and tg3 both do skb_reserve of at least NET_SKB_PAD
> > after build_skb. You are saying it's not a must?
> > 
> 
> 32 would be the minimum. NETS_SKB_PAD is using a cache line (64 bytes
> on most x86 current cpus) to avoid using half a cache line.

OK so if we want to use build_skb we need to pad by at least
32 - 12 bytes or more likely 64-12. We lose 52 bytes per page
but save a copy of 128 bytes for medium sized packets.

> > Hmm so maybe we should teach the hypervisor to write data
> > out at an offset. Interesting.
> > 
> > Another question is about very small packets truesize.
> > build_skb sets truesize to frag_size but isn't
> > this too small? We keep the whole page around, no?
> 
> We keep one page per cpu, at most.
> 
> For example on MTU=1500 and PAGE_SIZE=4096, one page is splitted into
> two fragments, of 1500 + NET_SKB_PAD + align(shared_info), so its good
> enough (this is very close from 2048 'truesize')

I see. virtio allocates full 4K pages which works well for GSO
but it means smaller packets would get large truesize
wasting lots of memory.
So maybe we should keep copying packets < 128 bytes.

> But yes, for some uses (wifi for example), we might use a full page per
> skb, yet underestimate skb->truesize. Hopefully we can track these uses
> and fix them.
> 
> ath9k for example could be changed, to be able to reassemble up to 3
> frags instead of 2 frags, ie extending what did commit
> 0d95521ea74735826cb2e28bebf6a07392c75bfa (ath9k: use split rx
> buffers to get rid of order-1 skb allocations)
> 
> 
