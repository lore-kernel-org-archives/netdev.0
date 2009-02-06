From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 6 Feb 2009 09:10:34 +0000
Message-ID: <20090206091034.GA4879@ff.dom.local>
References: <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090205.235258.257422341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:34350 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbZBFJKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:10:43 -0500
Content-Disposition: inline
In-Reply-To: <20090205.235258.257422341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 11:52:58PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 3 Feb 2009 09:41:08 +0000
> 
> > Yes, this looks reasonable. On the other hand, I think it would be
> > nice to get some opinions of slab folks (incl. Evgeniy) on the expected
> > efficiency of such a solution. (It seems releasing with put_page() will
> > always have some cost with delayed reusing and/or waste of space.)
> 
> I think we can't avoid using carved up pages for skb->data in the end.
> The whole kernel wants to speak in pages and be able to grab and
> release them in one way and one way only (get_page() and put_page()).
> 
> What do you think is more likely?  Us teaching the whole entire kernel
> how to hold onto SKB linear data buffers, or the networking fixing
> itself to operate on pages for it's header metadata? :-)

This idea looks very reasonable, except I wander why nobody else
didn't need this kind of mm interface. Another question is it seems
many mechanisms like fast searching, defragmentation etc. could be
reused.

> What we'll end up with is likely a hybrid scheme.  High speed devices
> will receive into pages.  And also the skb->data area will be page
> backed and held using get_page()/put_page() references.
> 
> It is not even worth optimizing for skb->data holding the entire
> packet, that's not the case that matters.
> 
> These skb->data areas will thus be 128 bytes plus the skb_shinfo
> structure blob.  They also will be recycled often, rather than held
> onto for long periods of time.

Looks fine, except: you mentioned dumb NICs, which would need this
page space on receive, anyway. BTW, don't they need this on transmit
again?

> In fact we can optimize that even further in many ways, for example by
> dropping the skb->data backed memory once the skb is queued to the
> socket receive buffer.  That will make skb->data buffer lifetimes
> miniscule even under heavy receive load.
> 
> In that kind of situation, doing even the most stupidest page slicing
> algorithm, similar to what we do now with sk->sk_sndmsg_page, is
> more than adequate and things like NTA (purely to solve this problem)
> is overengineering.

Hmm... I don't get it. It seems these slabs do a lot of advanced work,
and still some people like Evgeniy or Nick thought it's not enough,
and even found it worth of their time to rework this.

There is also a question of memory accounting: do you think admins
don't care if we give away say 25% additionally?

Jarek P.
