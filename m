From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 21:10:16 +0800
Message-ID: <20071215131016.GA28705@gondor.apana.org.au>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org> <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2177 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751269AbXLONK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 08:10:26 -0500
Content-Disposition: inline
In-Reply-To: <20071215024810.20b8a5ae.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 02:48:10AM -0800, Andrew Morton wrote:
>
> When Eric said
> 
> > Way way deep in mutex debugging on the slowpath there is a unreadable
> > and incomprehensible WARN_ON in muxtex_trylock that will trigger if
> > you have 10 tons of debugging turned on, and you are in,
> > interrupt context, and you manage to hit the slow path.  I think that
> > is a pretty unlikely scenario.
> 
> I think he's still right.  That's if the warning which he managed to find
> even still exists.

Well at the very start he said:

: When mutex debugging is on taking a mutex complains if we are not
: allowed to sleep.  At that point we have called netif_tx_lock_bh
: so we are clearly not allowed to sleep.  Arguably this is not a
: problem for mutex_trylock.

This is what threw me off as it implied that we were warning about
ASSERT_RTNL calls in any atomic context, including those with just
soft IRQs disabled, which is an important distinction for the
networking subsystem.

Had he said that it was just IRQ handlers rather than soft IRQs
then we wouldn't be having this discussion now :)

> I think the change which Eric proposed is a good one: it converts
> ASSERT_RTNL() from an atomic rmw which dirties a cacheline which will
> sometimes be owned by a different CPU into a plain old read.  It's going to
> make ASSERT_RTNL() heaps cheaper.

I agree.  Although paths using ASSERT_RTNL shouldn't be performance
critical since the RTNL should only be held for control operations
as opposed to data transport.

> Now as a separate issue we (ie: you) need to work out what _other_ things
> you want ASSERT_RTNL to check apart from "rtnl must be held".

Since we have now established that ASSERT_RTNL never actually
warned about usage on paths with BH off, I think Eric's original
patch is fine as it is and I owe him an apology.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
