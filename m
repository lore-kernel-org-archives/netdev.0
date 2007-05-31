From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved locking performance in rt_run_flush()
Date: Thu, 31 May 2007 16:26:26 -0700 (PDT)
Message-ID: <20070531.162626.91312503.davem@davemloft.net>
References: <20070514.030412.104035740.davem@davemloft.net>
	<E1Hpdhs-00069a-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750853AbXEaX0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 19:26:13 -0400
In-Reply-To: <E1Hpdhs-00069a-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 20 May 2007 15:11:48 +1000

> David Miller <davem@davemloft.net> wrote:
> > From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
> >> 
> >> The below patch changes rt_run_flush() to only take each spinlock
> >> protecting the rt_hash_table once instead of taking a spinlock for
> >> every hash table bucket (and ending up taking the same small set 
> >> of locks over and over).
> 
> ...
> 
> > I'm not ignoring it I'm just trying to brainstorm whether there
> > is a better way to resolve this inefficiency. :-)
> 
> The main problem I see with this is having to walk and free each
> chain with the lock held.  We could avoid this if we had a pointer
> in struct rtable to chain them up for freeing later.
> 
> I just checked and struct rtable is 236 bytes long on 32-bit but
> the slab cache pads it to 256 bytes so we've got some free space.
> I suspect 64-bit should be similar.

SLUB I believe packs more aggressively and won't pad things out like
that.  Therefore adding a member to rtable is much less attractive.

I've been considering various alternative ways to deal with this.

For 2.6.22 and -stable's sake we could allocate an array of pointers
of size N where N is the number of rtable hash slots per spinlock.
A big lock wraps around rt_run_flush() to protect these slots, and
then the loop is:

	grap_lock();
	for_each_hash_chain_for_lock(i) {
		rth = rt_hash_table[i].chain;
		if (rth) {
			rt_hash_table[i].chain = NULL;
			flush_chain[i % N] = rt;
		}
	}
	drop_lock();

	for (i = 0; i < N; i++) {
		struct rtable *rth = flush_chain[i];
		flush_chain[i] = NULL;
		while (rth) {
			struct rtable *next = rth->u.dst.rt_next;
			rt_free(rth);
			rth = next;
		}
	}

Holding a lock across the entire hash plucking has it's not nice
properties, but it's better than taking the same lock N times in
a row.

In the longer term, if I resurrect my dynamically sized rtable hash
patches (which I do intend to do), that code protected a lot of this
stuff with a seqlock and it might be possible to use that seqlock
solely to flush the lists in rt_run_flush().

Any better ideas?
