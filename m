From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 09:21:32 +1100
Message-ID: <20150126222132.GB30116@gondor.apana.org.au>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <20150126082000.GA22262@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55910 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691AbbAZWWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:22:04 -0500
Content-Disposition: inline
In-Reply-To: <20150126082000.GA22262@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2015 at 08:20:00AM +0000, Thomas Graf wrote:
> On 01/26/15 at 10:21am, Herbert Xu wrote:
> > +int rhashtable_walk_start(struct rhashtable_iter *iter)
> > +{
> > +	struct rhashtable *ht = iter->ht;
> > +	int err;
> > +
> > +	err = mutex_lock_interruptible(&ht->mutex);
> > +	rcu_read_lock();
> > +
> > +	if (!err)
> > +		mutex_unlock(&ht->mutex);
> > +
> > +	return err;
> > +}
> > +EXPORT_SYMBOL_GPL(rhashtable_walk_start);
> 
> This doesn't seem to work for Netlink dumps as it would define
> a RCU read side section across user read()s.

No it does not.  The start call roughly corresponds to the start
call in seq_file which does not span across reads.

> I assume you relying on RCU to defer the initial table relinking
> in the resizing to be postponed. Wouldn't it be better to hold
> the mutex instead, we could sleep during the dump.

Note that this is not the final solution but just the first step.
So right now it does not prevent/postpone resizes completely.  It's
only meant to be a strict improvement over what we currently have.

So indeed resizes will be stopped within a single read but not
across reads for seq_file.  Similarly for netlink dump resizes
will only be stopped for a single skb.

I will do the rest of what we discussed once I implement rehashing
since there will be dependencies on it.
 
> Same here, we leave the iterator with the bucket lock held.

This is intentional, it is what udp_diag does.  We'll have to do
this if you ever want to convert UDP sockets over to rhashtable
so we might as well do it now.

If you don't hold the bucket lock then anyone that recycles objects
like UDP will end up walking into the ether.

As before this is not held across reads but only within a read.
Please see patch #2.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
