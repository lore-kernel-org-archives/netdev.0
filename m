From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 17:01:04 +0200
Message-ID: <1338822064.2760.1834.camel@edumazet-glaptop>
References: <1337269380.3403.10.camel@edumazet-glaptop>
	 <20120517155621.GK14498@1wt.eu> <1337272404.3403.18.camel@edumazet-glaptop>
	 <20120517164016.GL14498@1wt.eu> <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64957 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760754Ab2FDPBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:01:09 -0400
Received: by eeit10 with SMTP id t10so1566275eei.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 08:01:08 -0700 (PDT)
In-Reply-To: <20120604141731.GA30226@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 17:17 +0300, Michael S. Tsirkin wrote:

> bnx2 and tg3 both do skb_reserve of at least NET_SKB_PAD
> after build_skb. You are saying it's not a must?
> 

32 would be the minimum. NETS_SKB_PAD is using a cache line (64 bytes
on most x86 current cpus) to avoid using half a cache line.

> Hmm so maybe we should teach the hypervisor to write data
> out at an offset. Interesting.
> 
> Another question is about very small packets truesize.
> build_skb sets truesize to frag_size but isn't
> this too small? We keep the whole page around, no?

We keep one page per cpu, at most.

For example on MTU=1500 and PAGE_SIZE=4096, one page is splitted into
two fragments, of 1500 + NET_SKB_PAD + align(shared_info), so its good
enough (this is very close from 2048 'truesize')

But yes, for some uses (wifi for example), we might use a full page per
skb, yet underestimate skb->truesize. Hopefully we can track these uses
and fix them.

ath9k for example could be changed, to be able to reassemble up to 3
frags instead of 2 frags, ie extending what did commit
0d95521ea74735826cb2e28bebf6a07392c75bfa (ath9k: use split rx
buffers to get rid of order-1 skb allocations)
