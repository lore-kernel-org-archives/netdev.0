From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 11:40:28 +0000
Message-ID: <20150127114028.GG22262@casper.infradead.org>
References: <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
 <20150127112304.GA4548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150127112304.GA4548@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/15 at 10:23pm, Herbert Xu wrote:
> On Tue, Jan 27, 2015 at 11:16:04AM +0000, Thomas Graf wrote:
> > 
> > No objection. I have a patch prepared which allows the user to
> > provide ht->mutex himself so nfset can provide its own existing
> > mutex to rhashtable and lock out the resizes from inserts,
> > removals and dump iterations automatically That would restore the
> > old behaviour of the nfset API without major surgery.
> 
> If you take the mutex you might as well just make it synchronous.
> There is zero difference.
> 
> Maybe you misunderstood my email.  I'm not making it synchronous
> for everybody, just those that always take a lock on inserts/removals
> and therefore don't need per-bucket locks.

Understood. No objection, happy to review patches. I initially did
keep sync/async separate and it lead to considerable code duplication
and complexity. I figured that if a user needs sync insert they could
provide their own locking. I missed to allow controlling the async
resize though. Again, feel free to give a shot, no objections.

This is unrelated to resize run control though, the reason is that
I'm converting tcp_hashinfo et al and they require a hybrid approach.
The tables may be too big to construct a parallel data structure, we
don't want to hold off inserts or deletes while the expensive dump
is underway. Even though we can't build a shadow structure while
locking everybody else out, we still want to provide a way to somehow
achieve consistent information. I think that NLM_F_INTR with fallback
to restarting the dump is a good option and very easy to implement. In
that case, we want to lock out resize from dumping iterations but
still allow parallel insert/delete.
