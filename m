From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 09:43:21 +0000
Message-ID: <20150323094321.GE16023@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150322130630.GA16023@casper.infradead.org>
 <20150323000707.GA9507@gondor.apana.org.au>
 <20150323083712.GC16023@casper.infradead.org>
 <20150323092921.GB12506@gondor.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:54842 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbCWJnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:43:22 -0400
Content-Disposition: inline
In-Reply-To: <20150323092921.GB12506@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/15 at 08:29pm, Herbert Xu wrote:
> On Mon, Mar 23, 2015 at 08:37:12AM +0000, Thomas Graf wrote:
> >
> > I think rhashtable_shrink() should fetch ht->tbl in an RCU section to
> > cheaply get the current table size and only do the allocation and take
> > the lock if the table size warrants for shrinking.
> 
> Well you should never invoke rhashtable_shrink unless you actually
> wanted to shrink.  So this is something that you should have checked
> before rhashtable_shrink is called.

How? The calculation of the table size is embedded in
rhashtable_shrink(). Should every user have a copy of that
calculation algorithm?

Why not just:

	unlikely(ht->p.shrink && rht_shrink_below_30(..))

If you really care about that additional conditional we
can also add:

static inline int rhashtable_remove_and_shrink()
{
        int err;

        rcu_read_lock();

	tbl = rht_dereference_rcu(ht->tbl, ht);

        err = rhashtable_remove_fast();
        if (unlikely(!err && rht_shrink_below_30(ht, tbl)))
                schedule_work(&ht->run_work);

	rcu_read_unlock();

	return err;
}

I just think it's wrong to rip out all the shrinking logic and
require every single user to re-add its own copy.
