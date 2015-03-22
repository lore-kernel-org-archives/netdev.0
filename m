From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Sun, 22 Mar 2015 23:04:15 +1100
Message-ID: <20150322120415.GA5238@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZarZ-0000v8-7e@gondolin.me.apana.org.au>
 <20150322115505.GD1185@casper.infradead.org>
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
Received: from ringil.hengli.com.au ([178.18.16.133]:43563 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbbCVMEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 08:04:37 -0400
Content-Disposition: inline
In-Reply-To: <20150322115505.GD1185@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 11:55:05AM +0000, Thomas Graf wrote:
> On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > @@ -134,6 +136,7 @@ struct rhashtable {
> >  	struct bucket_table __rcu	*tbl;
> >  	atomic_t			nelems;
> >  	bool                            being_destroyed;
> > +	unsigned int			key_len;
> 
> Why is this needed? It looks like you're always initializing this
> with ht->p.key_len

It's ht->p.key_len/4 if we use jhash2.
 
> > +	if (!__builtin_constant_p(params.key_len))
> > +		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
> 
> I don't understand this. It looks like you only consider
> params->key_len if it's constant.

If params->key_len is not constant, then params == ht->p.

> > +	else if (params.key_len) {
> > +		unsigned key_len = params.key_len;
> > +
> > +		if (params.hashfn)
> > +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> > +		else if (key_len & (sizeof(u32) - 1))
> > +			hash = jhash(key, key_len, tbl->hash_rnd);
> > +		else
> > +			hash = jhash2(key, key_len / sizeof(u32),
> > +				      tbl->hash_rnd);
> > +	} else {
> > +		unsigned key_len = ht->p.key_len;
> > +
> > +		if (params.hashfn)
> > +			hash = params.hashfn(key, key_len, tbl->hash_rnd);
> > +		else
> > +			hash = jhash(key, key_len, tbl->hash_rnd);
> 
> Why don't we opt-in to jhash2 in this case?

Because if key_len == 0 it means that key_len is not known at
compile-time.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
