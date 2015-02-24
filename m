From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 13:26:03 -0500 (EST)
Message-ID: <20150224.132603.842251066562193899.davem@davemloft.net>
References: <20150224103918.GJ3713@acer.localdomain>
	<20150224.120944.866231994361475327.davem@davemloft.net>
	<20150224175014.GA29802@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150224175014.GA29802@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 24 Feb 2015 17:50:14 +0000

> On 02/24/15 at 12:09pm, David Miller wrote:
>> Thinking about this, if inserts occur during a pending resize, if the
>> nelems of the table has exceeded even the grow threshold for the new
>> table, it makes no sense to allow these async inserts as they are
>> going to make the resize take longer and prolong the pain.
> 
> Let's say we start with an initial table size of 16K (we can make
> this system memory depenend) and we grow by 8x. New inserts go
> into the new table immediately so as soon as we have 12K entries
> we'll grow right to 128K buckets. As we grow above 75K we'll start
> growing to 1024K buckets. New entries already go to the 1024K
> buckets at this point given that the first grow cycle should be
> fast. The 2nd grow cycle would take an est 6 RCU grace periods.
> This would also still give us a max of 8K bucket locks which
> should be good enough as well.

Actually, first of all, let's not start with larger tables.

The network namespace folks showed clearly that hash tables
are detrimental to per-ns memory costs.  So they definitely
want us to start with extremely small tables.

But once we know something is actively used, sure, increase
the table grow rate as a response to demand.

So how feasible is it to grow by 4x, 8x, or other powers of
two in one resize operation?
