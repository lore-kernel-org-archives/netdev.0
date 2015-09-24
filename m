From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 10:30:11 +0800
Message-ID: <20150924023010.GA27131@gondor.apana.org.au>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41936 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167AbbIXCah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 22:30:37 -0400
Content-Disposition: inline
In-Reply-To: <20150923155440.GB26647@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 11:54:40AM -0400, Tejun Heo wrote:
> 
> Hmm... lemme try again.  When using barriers or RCU, it's desirable to
> establish certain invariants because it usually is extremely easy to
> miss corner cases.  It is helpful to have an abstraction, even if just
> conceptual, where people can go "this thing is barrier / RCU protected
> to guarantee XYZ".  Going more towards RCU example, this is why we
> annotate variables as RCU protected to detect incorrect usages.  There
> sure are exceptions but most are of the sort "this is write path and
> protected by something else which is annotated differently".  Doing
> things this way makes it a lot easier to get right.

Well if someone provided helpers which

1) uses smp_wmb and smp_rmb instead of full barriers;
2) provides raw variants for the cases that barriers aren't needed

then I'm more than happy to use them.

Having reviewed the situation again I'm even more convincend
now that smp_load_acquire/smp_store_release aren't the appropriate
primitives for us.  They are meant for situations that are similar
to spin lock/unlock where you need to prevent all reads/writes from
floating above or below the load/store, respectively.

For our situation we only need write or read ordering, so they are
literally the wrong tool for the job and will only cause confusion
in future when someone tries to do a major rewrite of the code and
they will be scratching their head as to why we needed locking-like
semantics here.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
