From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 09:59:09 +0000
Message-ID: <20150320095908.GG21258@acer.localdomain>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
 <20150320085509.GA16748@gondor.apana.org.au>
 <20150320092216.GE21258@acer.localdomain>
 <20150320092703.GA17081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35166 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbCTJ7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 05:59:14 -0400
Content-Disposition: inline
In-Reply-To: <20150320092703.GA17081@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.03, Herbert Xu wrote:
> On Fri, Mar 20, 2015 at 09:22:17AM +0000, Patrick McHardy wrote:
> >
> > I need the compare functions for transaction support to decide whether
> > an element is already activated or has been deactivated and, with a
> > further patch, for timeouts. Inactive and timed out elements are treated
> > as non-existant but are in case of transactions present in the hash
> > until the transaction is committed, in case of timeouts until GC.
> 
> I still don't understand what is in the compare callback.  Can
> you provide some code example?

Sure, for lookup / insert:

static bool nft_hash_cmp(void *ptr, void *arg)
{
        struct nft_hash_cmp_arg *x = arg;
        struct nft_hash_elem *he = ptr;

        if (nft_data_cmp(nft_set_ext_key(&he->ext), x->key, x->set->klen))
                return false;
        if (nft_hash_elem_expired(he))
                return false;
        if (!nft_hash_is_active(he, x->genmask))
                return false;
        return true;
}

static bool nft_hash_lookup(const struct nft_set *set,
                            const struct nft_data *key,
                            const struct nft_set_ext **ext)
{
        struct nft_hash *priv = nft_set_priv(set);
        const struct nft_hash_elem *he;
        struct nft_hash_cmp_arg arg = {
                .genmask = nft_genmask_cur(set->net) << NFT_HASH_GEN_SHIFT,
                .set     = set,
                .key     = key,
        };

        he = rhashtable_lookup_compare(&priv->ht, key, &nft_hash_cmp, &arg);
        if (he != NULL)                                                         
                *ext = &he->ext;

        return !!he;
}

static int nft_hash_insert(const struct nft_set *set,                           
                           const struct nft_set_elem *elem)
{
        struct nft_hash *priv = nft_set_priv(set);
        struct nft_hash_elem *he = elem->priv;
        struct nft_hash_cmp_arg arg = {
                .genmask = nft_genmask_next(set->net) << NFT_HASH_GEN_SHIFT,
                .set     = set,
                .key     = &elem->key,
        };

        nft_hash_set_inactive(set, he);
        if (!rhashtable_lookup_compare_insert(&priv->ht, &he->node,
                                              nft_hash_cmp, &arg))
                return -EEXIST;
        return 0;
}

> More importantly, why is that you can't lookup and then just do
> whatever you need to do in the caller of lookup? If you're planning
> on having multiple objects in the hash table with the same key then
> I'm afraid I'll have to say no because we want to use the chain
> length to determine whether we're being attacked and having multiple
> objects with the same key defeats that mechanism.

It's exactly that, there are multiple similar keys in the hash. Timed
out and inactive elements are treated as non-existant. Timeout could
be handled differently, but for transactions there is no other way
to implement this in order to provide atomic transaction semantics.

Consider f.i. the sequence:

- delete element X
- add element X

If we fail, we want the first X to be still active, otherwise the second
X becomes active and the first one inactive atomically. For this to work,
both need to be present in the hash already. Transactions can cover
an arbitrary amount of elements, so even if the case of a single similar
key could be handled otherwise, its not possible for multiple keys.

Regarding the chain length as trigger - I'm sorry, but this doesn't work
for us. I don't see why you would have to look at chain length. That
implies that you don't trust your hash function - why not fix that
instead?

> Of course many hash table users need to be able to keep multiple
> objects under the same key.  My suggestion would be to allocate
> your own linked list and have the linked list be the object that
> is inserted into the hash table.

That would require a huge amount of extra memory per element and having
millions of them is not unrealistic for our use case.
