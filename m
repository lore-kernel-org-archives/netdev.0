From: josh@joshtriplett.org
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 10:45:02 -0800
Message-ID: <20150224184502.GB10713@cloud>
References: <20150224103918.GJ3713@acer.localdomain>
 <20150224.120944.866231994361475327.davem@davemloft.net>
 <20150224175014.GA29802@casper.infradead.org>
 <20150224.132603.842251066562193899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150224.132603.842251066562193899.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 01:26:03PM -0500, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Tue, 24 Feb 2015 17:50:14 +0000
> 
> > On 02/24/15 at 12:09pm, David Miller wrote:
> >> Thinking about this, if inserts occur during a pending resize, if the
> >> nelems of the table has exceeded even the grow threshold for the new
> >> table, it makes no sense to allow these async inserts as they are
> >> going to make the resize take longer and prolong the pain.
> > 
> > Let's say we start with an initial table size of 16K (we can make
> > this system memory depenend) and we grow by 8x. New inserts go
> > into the new table immediately so as soon as we have 12K entries
> > we'll grow right to 128K buckets. As we grow above 75K we'll start
> > growing to 1024K buckets. New entries already go to the 1024K
> > buckets at this point given that the first grow cycle should be
> > fast. The 2nd grow cycle would take an est 6 RCU grace periods.
> > This would also still give us a max of 8K bucket locks which
> > should be good enough as well.
> 
> Actually, first of all, let's not start with larger tables.
> 
> The network namespace folks showed clearly that hash tables
> are detrimental to per-ns memory costs.  So they definitely
> want us to start with extremely small tables.

Agreed; ideally, the initial table size would just use a single page for
the array of bucket heads, which would give 1024 buckets on 32-bit
systems or 512 on 64-bit systems.  That's more than enough for many
client systems, and for many single-application network namespaces.

> But once we know something is actively used, sure, increase
> the table grow rate as a response to demand.
> 
> So how feasible is it to grow by 4x, 8x, or other powers of
> two in one resize operation?

Quite feasible.  Actually, any integer multiple works fine, though I
think a power of two makes sense.  I'd suggest trying 4x with the same
workloads that had an issue at 2x, and seeing how that goes.

- Josh Triplett
