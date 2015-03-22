From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Sun, 22 Mar 2015 12:32:57 +0000
Message-ID: <20150322123257.GI1185@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
 <20150322115505.GD1185@casper.infradead.org>
 <20150322120415.GA5238@gondor.apana.org.au>
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
Received: from casper.infradead.org ([85.118.1.10]:50304 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbCVMc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 08:32:59 -0400
Content-Disposition: inline
In-Reply-To: <20150322120415.GA5238@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 11:04pm, Herbert Xu wrote:
> On Sun, Mar 22, 2015 at 11:55:05AM +0000, Thomas Graf wrote:
> > On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > > @@ -134,6 +136,7 @@ struct rhashtable {
> > >  	struct bucket_table __rcu	*tbl;
> > >  	atomic_t			nelems;
> > >  	bool                            being_destroyed;
> > > +	unsigned int			key_len;
> > 
> > Why is this needed? It looks like you're always initializing this
> > with ht->p.key_len
> 
> It's ht->p.key_len/4 if we use jhash2.

Sure but why not just store key_len/4 in ht->p.key_len then if you
opt in to jhash2() in rhashtable_init()?

> > > +	if (!__builtin_constant_p(params.key_len))
> > > +		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
> > 
> > I don't understand this. It looks like you only consider
> > params->key_len if it's constant.
> 
> If params->key_len is not constant, then params == ht->p.

I must be missing something obvious. Who guarantees that? I can see
that's true for the current callers but what prevents anybody from
using rhashtable_lookup_fast() with a key length not known at compile
time and pass it as rhashtable_params?

> > > +	else if (params.key_len) {
> > > +		unsigned key_len = params.key_len;
> > > +
> > > +		if (params.hashfn)
> > > +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> > > +		else if (key_len & (sizeof(u32) - 1))
> > > +			hash = jhash(key, key_len, tbl->hash_rnd);
> > > +		else
> > > +			hash = jhash2(key, key_len / sizeof(u32),
> > > +				      tbl->hash_rnd);
> > > +	} else {
> > > +		unsigned key_len = ht->p.key_len;
> > > +
> > > +		if (params.hashfn)
> > > +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> > > +		else
> > > +			hash = jhash(key, key_len, tbl->hash_rnd);
> > 
> > Why don't we opt-in to jhash2 in this case?
> 
> Because if key_len == 0 it means that key_len is not known at
> compile-time.

I still don't get this. Why do we fall back to jhash2() if
params.key_len is set but not if only ht->p.key_len is set?
