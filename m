From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Mon, 26 Jan 2015 08:20:00 +0000
Message-ID: <20150126082000.GA22262@casper.infradead.org>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/15 at 10:21am, Herbert Xu wrote:
> +int rhashtable_walk_start(struct rhashtable_iter *iter)
> +{
> +	struct rhashtable *ht = iter->ht;
> +	int err;
> +
> +	err = mutex_lock_interruptible(&ht->mutex);
> +	rcu_read_lock();
> +
> +	if (!err)
> +		mutex_unlock(&ht->mutex);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL_GPL(rhashtable_walk_start);

This doesn't seem to work for Netlink dumps as it would define
a RCU read side section across user read()s.

I assume you relying on RCU to defer the initial table relinking
in the resizing to be postponed. Wouldn't it be better to hold
the mutex instead, we could sleep during the dump.

> +/**
> + * rhashtable_walk_next - Return the next object and advance the iterator
> + * @iter:	Hash table iterator
> + *
> + * Note that you must call rhashtable_walk_stop when you are finished
> + * with the walk.
> + *
> + * Returns the next object or NULL when the end of the table is reached.
> + */
> +void *rhashtable_walk_next(struct rhashtable_iter *iter)
> +{
> +	const struct bucket_table *tbl;
> +	struct rhashtable *ht = iter->ht;
> +	struct rhash_head *p = iter->p;
> +
> +	tbl = rht_dereference_rcu(ht->tbl, ht);
> +
> +	if (p) {
> +		p = rht_dereference_bucket(p->next, tbl, iter->slot);
> +		goto next;
> +	}
> +
> +	for (; iter->slot < tbl->size; iter->slot++) {
> +		int skip = iter->skip;
> +
> +		iter->lock = bucket_lock(tbl, iter->slot);
> +		spin_lock_bh(iter->lock);
> +
> +		rht_for_each(p, tbl, iter->slot) {
> +			if (!skip)
> +				break;
> +			skip--;
> +		}
> +
> +next:
> +		if (!rht_is_a_nulls(p)) {
> +			iter->skip++;
> +			iter->p = p;
> +			return rht_obj(ht, p);

Same here, we leave the iterator with the bucket lock held.

> +		}
> +		spin_unlock_bh(iter->lock);
> +
> +		iter->skip = 0;
> +	}
> +
> +	iter->p = NULL;
> +	return NULL;
> +}
> +EXPORT_SYMBOL_GPL(rhashtable_walk_next);
