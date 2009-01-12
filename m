From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 12 Jan 2009 15:45:46 +0300
Message-ID: <20090112124545.GA10893@ioremap.net>
References: <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au> <20090112120257.GA5697@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:51898 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754764AbZALMpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 07:45:47 -0500
Content-Disposition: inline
In-Reply-To: <20090112120257.GA5697@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:02:57PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > Hmm... in any case: take 3
> > 
> > Yes this should fix the corruption but it kind of defeats the
> > purpose of splice by copying the data.
> 
> However, as we don't have a better fix yet, we probably should
> take Jarek's patch for now since data corruption is bad.

Iirc it copies data from skb to the new pipe page unconditionally while
it is needed only for skb->sendpage path, although it is not possible to
know what is the other side of the pipe (or not?).

What about storing a callback and private pointer in the shared info for
the skb and clone them during usual clone, and invoke the callback at
shared info freeing time, which in turn will call spd->spd_release()?

Given that we only need to protect linear part, it should be simple
enough and we will not need to mess with the pskb_expand* calls.

> This is a very hard problem, so in the end the only viable solution
> might be to get the drivers to switch to using page frags, like
> the Intel page split method.

As a long-term solution this sounds as the best case, but introduces
quite heavy overhead for the allocators. Right now we allocate
1500+shared_info rounded up to the nearest power of the two (2k), but
then we will either need to have own network allocator (I have one :) or
allocate PAGE_SIZE+shared_info rounded up to the pwoer of the two (i.e.
8k), which is unfeasible.

-- 
	Evgeniy Polyakov
