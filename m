From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 15:12:19 +0300
Message-ID: <20090203121219.GB22427@ioremap.net>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <alpine.DEB.1.10.0902030458390.28633@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:36805 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930AbZBCMMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 07:12:24 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902030458390.28633@asgard.lang.hm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 05:05:14AM -0800, david@lang.hm (david@lang.hm) wrote:
> >Maybe just do not allow jumbo frames when memory is fragmented enough
> >and fallback to the smaller MTU in this case? With LRO/GRO stuff there
> >should be not that much of the overhead compared to multiple-page
> >copies.
> 
> 
> 1. define 'fragmented enough'

When allocator can not provide requested amount of data.

> 2. the packet size was already negotiated on your existing connections, 
> how are you going to change all those on the fly?

I.e. MTU can not be changed on-flight? Magic world.

> 3. what do you do when a remote system sends you a large packet? drop it 
> on the floor?

We already do just that when jumbo frame can not be allocated :)

> having some pool of large buffers to receive into (and copy out of those 
> buffers as quickly as possible) would cause a performance hit when things 
> get bad, but isn't that better than dropping packets?

It is a solution, but I think it will behave noticebly worse than
with decresed MTU.

> as for the number of buffers to use. make a reasonable guess. if you only 
> have a small number of packets around, use the buffers directly, as you 
> use more of them start copying, as useage climbs attempt to allocate more. 
> if you can't allocate more (and you have all of your existing ones in use) 
> you will have to drop the packet, but at that point are you really in any 
> worse shape than if you didn't have some mechanism to copy out of the 
> large buffers?

That's the main point: how to deal with broken hardware? I think (but
have no strong numbers though) that having 6 packets with 1500 MTU
combined into GRO/LRO frame will be processed way faster than copying 9k
MTU into 3 pages and process single skb.

-- 
	Evgeniy Polyakov
