From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Mon, 23 Mar 2015 08:12:41 +1100
Message-ID: <20150322211241.GA7925@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
 <20150322115505.GD1185@casper.infradead.org>
 <20150322120415.GA5238@gondor.apana.org.au>
 <20150322123257.GI1185@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:51992 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbbCVVNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 17:13:16 -0400
Content-Disposition: inline
In-Reply-To: <20150322123257.GI1185@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 12:32:57PM +0000, Thomas Graf wrote:
> On 03/22/15 at 11:04pm, Herbert Xu wrote:
> > On Sun, Mar 22, 2015 at 11:55:05AM +0000, Thomas Graf wrote:
> > > On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > > > @@ -134,6 +136,7 @@ struct rhashtable {
> > > >  	struct bucket_table __rcu	*tbl;
> > > >  	atomic_t			nelems;
> > > >  	bool                            being_destroyed;
> > > > +	unsigned int			key_len;
> > > 
> > > Why is this needed? It looks like you're always initializing this
> > > with ht->p.key_len
> > 
> > It's ht->p.key_len/4 if we use jhash2.
> 
> Sure but why not just store key_len/4 in ht->p.key_len then if you
> opt in to jhash2() in rhashtable_init()?

Because that breaks rhashtable_compare/memcmp.

> 
> > > > +	if (!__builtin_constant_p(params.key_len))
> > > > +		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
> > > 
> > > I don't understand this. It looks like you only consider
> > > params->key_len if it's constant.
> > 
> > If params->key_len is not constant, then params == ht->p.
> 
> I must be missing something obvious. Who guarantees that? I can see
> that's true for the current callers but what prevents anybody from
> using rhashtable_lookup_fast() with a key length not known at compile
> time and pass it as rhashtable_params?

They shouldn't be doing that.  The whole point of this function
is to have it inlined so all external callers of it should be
supplying a constant parameter.  We could add a __ variant that
is only called by rhashtable if you like so we can enforce this
in rhashtable_lookup_fast.

> I still don't get this. Why do we fall back to jhash2() if
> params.key_len is set but not if only ht->p.key_len is set?

Because if params.key_len is not set then we have no idea whether
we should use jhash or jhash2 because ht->p.key_len cannot be
known at compile time.  This is only used by netfilter currently
as it has a key-length set at run-time.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
