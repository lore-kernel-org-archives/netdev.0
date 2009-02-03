From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 22:38:06 +1100
Message-ID: <200902032238.08497.nickpiggin@yahoo.com.au>
References: <20090126212130.GA4338@ioremap.net> <20090127074048.GA4197@ff.dom.local> <20090130.134227.123379239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, zbr@ioremap.net, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.mail.mud.yahoo.com ([209.191.84.77]:46818 "HELO
	smtp120.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751859AbZBCLig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 06:38:36 -0500
In-Reply-To: <20090130.134227.123379239.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009 08:42:27 David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 27 Jan 2009 07:40:48 +0000
>
> > I think the main problem is to respect put_page() more, and maybe you
> > mean to add this to your allocator too, but using slab pages for this
> > looks a bit complex to me, but I can miss something.
>
> Hmmm, Jarek's comments here made me realize that we might be
> able to do some hack with cooperation with SLAB.
>
> Basically the idea is that if the page count of a SLAB page
> is greater than one, SLAB will not use that page for new
> allocations.

Wouldn't your caller need to know what objects are already
allocated in that page too?


> It's cheesy and the SLAB developers will likely barf at the
> idea, but it would certainly work.

It is nasty, yes. Using the page allocator directly seeems
like a better approach.

And btw. be careful of using page->_count for anything, due
to speculative page references... basically it is useful only
to test zero or non-zero refcount. If designing a new scheme
for the network layer, it would be nicer to begin by using
say _mapcount or private or some other field in there for a
refcount (and I have a patch to avoid the atomic
put_page_testzero in page freeing for a caller that does their
own refcounting, so don't fear that extra overhead too much :)).


