From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Wed, 23 Sep 2015 22:46:08 -0400
Message-ID: <20150924024608.GA25502@htj.duckdns.org>
References: <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:35584 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755794AbbIXCqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 22:46:14 -0400
Content-Disposition: inline
In-Reply-To: <20150924023010.GA27131@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Herbert.

On Thu, Sep 24, 2015 at 10:30:11AM +0800, Herbert Xu wrote:
> Well if someone provided helpers which
> 
> 1) uses smp_wmb and smp_rmb instead of full barriers;

This part is fine.

> 2) provides raw variants for the cases that barriers aren't needed

Hmm... It looks like I'm failing at communicating.  Lemme try again.
There are two situations where we do this.

1. When there are different locking contexts.  In this case, the write
   path is.  It's already protected by the spinlock so the barrier
   isn't necessary.

2. When the path is hot enough for the cost of smp_rmb() to matter and
   the specifics of individual deref allows for micro optimization and
   justifies the added overhead in terms of increased fragility,
   complexity and need for documentation.

In both cases, we want to make reasonable trade-offs like any other
choices we make.  We don't go off and run to one extreme or the other
just because barriers are involved.  One good measure to use is
whether the extra documentation necessary is justifiable.  In this
case, on each unprotected derefs, we want to explain why the
unprotected deref is okay and justified.

> then I'm more than happy to use them.
> 
> Having reviewed the situation again I'm even more convincend
> now that smp_load_acquire/smp_store_release aren't the appropriate
> primitives for us.  They are meant for situations that are similar
> to spin lock/unlock where you need to prevent all reads/writes from
> floating above or below the load/store, respectively.
>
> For our situation we only need write or read ordering, so they are
> literally the wrong tool for the job and will only cause confusion
> in future when someone tries to do a major rewrite of the code and
> they will be scratching their head as to why we needed locking-like
> semantics here.

store_release/load_acquire vs. wmb/rmb is a separate issue.  I no
longer have objections against using wmb/rmb pairs here although I do
wanna note that eventually I think release/acquire are likely to be
more prevalent but that's a separate discussion.

Thanks.

-- 
tejun
