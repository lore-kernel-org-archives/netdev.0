From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 08:37:12 +0000
Message-ID: <20150323083712.GC16023@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150322130630.GA16023@casper.infradead.org>
 <20150323000707.GA9507@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54535 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbCWIhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 04:37:13 -0400
Content-Disposition: inline
In-Reply-To: <20150323000707.GA9507@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/15 at 11:07am, Herbert Xu wrote:
> On Sun, Mar 22, 2015 at 01:06:30PM +0000, Thomas Graf wrote:
> > On 03/22/15 at 12:17pm, Thomas Graf wrote:
> > > On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > > > +	struct bucket_table *new_tbl;
> > > > +	struct bucket_table *tbl;
> > > > +	int err;
> > > >  
> > > > -	ASSERT_RHT_MUTEX(ht);
> > > > +	if (size < ht->p.min_size)
> > > > +		size = ht->p.min_size;
> > > 
> > > We should only shrink if size < old_tbl->size
> > 
> > I found the check further down. Any particular reason why check
> > after allocation and then free again? Why do you want to avoid
> > the allocation inside the mutex?
> 
> It's just quality of code.  You should always try to minimise
> the locked sections.

So do you expect the user to replicate the new table size calculation
outside of rhashtable_shrink() to avoid the cost of a possible massive
memory allocation even if no shrinking will take place?

I think rhashtable_shrink() should fetch ht->tbl in an RCU section to
cheaply get the current table size and only do the allocation and take
the lock if the table size warrants for shrinking.
