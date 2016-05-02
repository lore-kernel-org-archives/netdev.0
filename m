From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 2 May 2016 18:00:36 +0200
Message-ID: <20160502180036.25bebdfe@redhat.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502094954.24cc9549@redhat.com>
	<1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Jonathan Morton <chromatix99@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971AbcEBQAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 12:00:41 -0400
In-Reply-To: <1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 May 2016 07:34:28 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-05-02 at 09:49 +0200, Jesper Dangaard Brouer wrote:
> 
> > What about using bulk free of SKBs here?
> > 
> > There is a very high probability that we are hitting SLUB slowpath,
> > which involves an expensive locked cmpxchg_double per packet.  Instead
> > we can amortize this cost via kmem_cache_free_bulk().
> > 
> > Maybe extend kfree_skb_list() to hide the slab/kmem_cache call?  
> 
> Sounds tricky, because of skb destructors. skb are complex objects.
> 
> For each skb, need to free the frags, skb->head, and skb.

It is not that complicated, inside kfree_skb_list(), we just call
skb_release_all(skb) on each SKB first, and then bulk free the SKB's
themselves in the end.  Example see, _kfree_skb_defer().

The question is where to store the SKB array needed by kmem_cache_free_bulk.

The easy option is just to use the stack of kfree_skb_list(), but we
have to be careful about the stack size, it might not be so good
because skb_release_all() can be deep and via skb_release_data() invoke
kfree_skb_list() a second time.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
