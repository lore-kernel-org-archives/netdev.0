From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 6 Feb 2009 19:59:01 +0100
Message-ID: <20090206185901.GA2542@ami.dom.local>
References: <20090205.235258.257422341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:58580 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbZBFS6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 13:58:48 -0500
Content-Disposition: inline
In-Reply-To: <20090205.235258.257422341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 02/06/2009 08:52 AM:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 3 Feb 2009 09:41:08 +0000
> 
>> Yes, this looks reasonable. On the other hand, I think it would be
>> nice to get some opinions of slab folks (incl. Evgeniy) on the expected
>> efficiency of such a solution. (It seems releasing with put_page() will
>> always have some cost with delayed reusing and/or waste of space.)
> 
> I think we can't avoid using carved up pages for skb->data in the end.
> The whole kernel wants to speak in pages and be able to grab and
> release them in one way and one way only (get_page() and put_page()).
> 
> What do you think is more likely?  Us teaching the whole entire kernel
> how to hold onto SKB linear data buffers, or the networking fixing
> itself to operate on pages for it's header metadata? :-)
> 
> What we'll end up with is likely a hybrid scheme.  High speed devices
> will receive into pages.  And also the skb->data area will be page
> backed and held using get_page()/put_page() references.

So, after a full awakening I think I got your point at last! I thought
all the time we're trying to do something more general, and you're
seemingly focused on SG capable NICs, with myri10ge or niu as model
to follow. I'm OK with this. Very nice idea and much less work! (It's
only enough to CC all the maintainers !)

> It is not even worth optimizing for skb->data holding the entire
> packet, that's not the case that matters.
> 
> These skb->data areas will thus be 128 bytes plus the skb_shinfo
> structure blob.  They also will be recycled often, rather than held
> onto for long periods of time.
> 
> In fact we can optimize that even further in many ways, for example by
> dropping the skb->data backed memory once the skb is queued to the
> socket receive buffer.  That will make skb->data buffer lifetimes
> miniscule even under heavy receive load.
> 
> In that kind of situation, doing even the most stupidest page slicing
> algorithm, similar to what we do now with sk->sk_sndmsg_page, is
> more than adequate and things like NTA (purely to solve this problem)
> is overengineering.

This is 100% right, except if we try to do something with non-SG and/or
jumbos - IMHO this requires some overengineering.

Jarek P.
