From: David Miller <davem@davemloft.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 18:15:44 -0500 (EST)
Message-ID: <20150223.181544.230510782345048771.davem@davemloft.net>
References: <CAADnVQ+kJu=Hb5oUMeQuchWe67nLo7AMnPUK0VJecRqYM0GHCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, tgraf@suug.ch, josh@joshtriplett.org,
	herbert@gondor.apana.org.au, kaber@trash.net,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQ+kJu=Hb5oUMeQuchWe67nLo7AMnPUK0VJecRqYM0GHCA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 23 Feb 2015 15:07:20 -0800

> Also 'count of pending inserts' is going to be very small and
> meaningless, since it will count the number of threads that
> are sleeping on insert and not very useful to predict future
> expansions.

Good point.

A way around this would be to allow batching.  So netfilter would
do something like:

	set->ops->batch_insert_start();
	nla_for_each_nested(attr, nla[NFTA_SET_ELEM_LIST_ELEMENTS], rem) {
		err = nft_add_set_elem(&ctx, set, attr);
		if (err < 0)
			break;

		set->nelems++;
	}
	set->ops->batch_insert_end();

And batch_insert_start and batch_insert_end would point to something
that calls new routines rhashtable_batch_insert_start() and
rhashtable_batch_insert_end().

Inside of this sequence, rhashtable_insert() calls queue to a list if
a table grow is in progress.

The pending list is processed by both rhashtable_batch_insert_end()
and table grow completion.
