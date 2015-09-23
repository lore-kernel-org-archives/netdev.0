From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 14:13:42 +0800
Message-ID: <20150923061342.GA19106@gondor.apana.org.au>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57911 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbbIWGO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 02:14:29 -0400
Content-Disposition: inline
In-Reply-To: <20150922161056.GB9761@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 12:10:56PM -0400, Tejun Heo wrote:
>
> That's a pentium pro era errata.  Virtually no working machine is
> affected by that anymore and nobody builds kernel with that option.
> In most cases, store_release and load_acquire are cheaper as they're
> more specific.  On x86, store_release and load_acquire boil down to
> compiler reordering barriers.  You're running in the opposite
> direction.

It doesn't matter on x86 but the semantics of smp_load_acquire
and smp_store_release explicitly includes a full barrier which
is something that we don't need.

> I mean, read this thread.  It's one subtle breakage after another, one
> confusion after another.  The problematic usages of memory barriers
> are usually of two types.

smp_load_acquire/store_release isn't some kind of magic dust
that you can just spread around to fix races.  Whoever is writing
the code had better understood what the code is doing or they will
end up creating more bugs.

Having said that, I very much appreciate the work you have done
in reviewing my patches and pointing out holes in them.  Please
continue to do so and I will look at any real issues that you
discover.

> 1. Misunderstand what barriers do and fail to, most frequently, pair
>    the barriers correctly.  This leads to things like lone smp_wmb()s
>    which don't do anything but provide false sense of security.

smp_store_release can give you exactly the same kind of false
sense of security.

> 2. The usage itself is correct but not properly documented and it's
>    not clear what's being synchronized.  Because there's nothing
>    inherently pairing the matching barrier pairs, w/o proper
>    documentation, it can be very challenging to track down what is
>    being synchronized making it difficult to tell this case from 1.
>    Note that this is another reason smp_store_release() and
>    smp_load_acquire() are just better.  Their specificity not only
>    makes them lighter but also makes it a lot easier to track down
>    what's going on.

Well if there is anything unclear in my patch please point them out
and I will rewrite and/or add comments where necessary.

> > The reason this one is OK is because we do not use nlk->portid or
> > try to get nlk from the hash table before we return to user-space.
> 
> What happens if somebody later adds code below that which happens to
> use portid?  You're creating a booby trap and the patch isn't even
> properly documenting what's going on.

The same thing can still happen even if you use smp_load_acquire.
Someone may add a read prior to it or add a second smp_load_acquire
and then screw up the logic as we have seen in netlink_bind.

As I said whoever is touching these lockless code paths need to
understand what is going on.  There is no easy way out.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
