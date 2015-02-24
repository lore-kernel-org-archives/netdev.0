From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 22:34:09 +0000
Message-ID: <20150224223409.GA1199@casper.infradead.org>
References: <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
 <20150224175014.GA29802@casper.infradead.org>
 <20150224.132603.842251066562193899.davem@davemloft.net>
 <20150224184502.GB10713@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: josh@joshtriplett.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48236 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbbBXWeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:34:14 -0500
Content-Disposition: inline
In-Reply-To: <20150224184502.GB10713@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/15 at 10:45am, josh@joshtriplett.org wrote:
> On Tue, Feb 24, 2015 at 01:26:03PM -0500, David Miller wrote:
> > Actually, first of all, let's not start with larger tables.
> > 
> > The network namespace folks showed clearly that hash tables
> > are detrimental to per-ns memory costs.  So they definitely
> > want us to start with extremely small tables.
> 
> Agreed; ideally, the initial table size would just use a single page for
> the array of bucket heads, which would give 1024 buckets on 32-bit
> systems or 512 on 64-bit systems.  That's more than enough for many
> client systems, and for many single-application network namespaces.

No objection at all. I certainly understand the implications to
netns. After all this is the reason why rhashtable exists. However,
the initial tabe size plus number of growth cycles has some
implications on max number of bucket locks (see below). So it's
a matter of balance that needs some thought and experimentation.

> > But once we know something is actively used, sure, increase
> > the table grow rate as a response to demand.
> > 
> > So how feasible is it to grow by 4x, 8x, or other powers of
> > two in one resize operation?
> 
> Quite feasible.  Actually, any integer multiple works fine, though I
> think a power of two makes sense.  I'd suggest trying 4x with the same
> workloads that had an issue at 2x, and seeing how that goes.

There is a side effect. We can't grow the number of bucket locks more
than 2x if we grow the table itself faster than 2x. So if we start
out with a table size of 512 and grow 4 times in a row we will end
up with a theoretical max bucket locks of 4K. Probably enough though.
