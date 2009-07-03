From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 11:40:07 -0400
Message-ID: <20090703154007.GC10256@Krystal>
References: <20090703140401.GA10256@Krystal> <20090703152951.GA28837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, jolsa@redhat.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, eric.dumazet@gmail.com,
	Paul.McKenney@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts5-srv.bellnexxia.net ([209.226.175.25]:64720 "EHLO
	tomts5-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519AbZGCPkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 11:40:06 -0400
Content-Disposition: inline
In-Reply-To: <20090703152951.GA28837@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> > 
> > Why don't we create a read_lock without acquire semantic instead (e.g.
> > read_lock_nomb(), or something with a better name like __read_lock()) ?
> > On architectures where memory barriers are needed to provide the acquire
> > semantic, it would be faster to do :
> > 
> > __read_lock();
> > smp_mb();
> > 
> > than :
> > 
> > read_lock(); <- e.g. lwsync + isync or something like that
> > smp_mb(); <- full sync.
> 
> Hmm, why do we even care when read_lock should just die?
> 

I guess you are proposing migration from rwlock to RCU ?

Well, in cases where critical sections are in the order of 20000
cycles or more, and with 8 to 64-core machines, there is no significant
gain in using RCU vs rwlocks, so the added complexity might not be
justified if the critical sections are very long.

But then it's a case by case thing. We would have to see what exactly is
protected by this read lock and how long the critical section is.
However, in any case, you are right: rwlocks are acceptable only for
long critical sections, for which we just don't care about one extra
memory barrier.

Instead of optimizing away these read-side rwlock barriers, we would
spend our time much more efficiently switching to RCU read side.

Mathieu

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
