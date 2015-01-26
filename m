From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Mon, 26 Jan 2015 10:09:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:51959 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbAZKKv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 05:10:51 -0500
In-Reply-To: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Some existing rhashtable users get too intimate with it by walking
> the buckets directly.  This prevents us from easily changing the
> internals of rhashtable.
> 
> This patch adds the helpers rhashtable_walk_init/next/end which
> will replace these custom walkers.
> 
> They are meant to be usable for both procfs seq_file walks as well
> as walking by a netlink dump.  The iterator structure should fit
> inside a netlink dump cb structure, with at least one element to
> spare.
...
> +/**
> + * rhashtable_walk_start - Start a hash table walk
> + * @iter:	Hash table iterator
> + *
> + * Start a hash table walk.
> + *
> + * Returns zero if successful.  Returns -EINTR if we couldn't
> + * obtain the resize lock.
> + */
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

That doesn't look right to me.
Surely you shouldn't be calling rcu_read_lock() when the mutex
request is interrupted.

So maybe:
	err = mutex_lock_interruptible(&ht->mutex);
	if (err)
		return err;
	rcu_read_lock();
	return 0;
}

	David
