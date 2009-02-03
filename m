From: david@lang.hm
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 05:05:14 -0800 (PST)
Message-ID: <alpine.DEB.1.10.0902030458390.28633@asgard.lang.hm>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net>
 <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:34690 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281AbZBCMCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 07:02:33 -0500
In-Reply-To: <20090203114944.GA21957@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Feb 2009, Evgeniy Polyakov wrote:

> On Tue, Feb 03, 2009 at 10:24:31PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
>>> I even believe that for some hardware it is the only way to deal
>>> with the jumbo frames.
>>
>> Not necessarily.  Even if the hardware can only DMA into contiguous
>> memory, we can always allocate a sufficient number of contiguous
>> buffers initially, and then always copy them into fragmented skbs
>> at receive time.  This way the contiguous buffers are never
>> depleted.
>
> How many such preallocated frames is enough? Does it enough to have all
> sockets recv buffer sizes divided by the MTU size? Or just some of them,
> or... That will work but there are way too many corner cases.
>
>> Granted copying sucks, but this is really because the underlying
>> hardware is badly designed.  Also copying is way better than
>> not receiving at all due to memory fragmentation.
>
> Maybe just do not allow jumbo frames when memory is fragmented enough
> and fallback to the smaller MTU in this case? With LRO/GRO stuff there
> should be not that much of the overhead compared to multiple-page
> copies.


1. define 'fragmented enough'

2. the packet size was already negotiated on your existing connections, 
how are you going to change all those on the fly?

3. what do you do when a remote system sends you a large packet? drop it 
on the floor?

having some pool of large buffers to receive into (and copy out of those 
buffers as quickly as possible) would cause a performance hit when things 
get bad, but isn't that better than dropping packets?

as for the number of buffers to use. make a reasonable guess. if you only 
have a small number of packets around, use the buffers directly, as you 
use more of them start copying, as useage climbs attempt to allocate more. 
if you can't allocate more (and you have all of your existing ones in use) 
you will have to drop the packet, but at that point are you really in any 
worse shape than if you didn't have some mechanism to copy out of the 
large buffers?

David Lang
