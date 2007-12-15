From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 02:48:10 -0800
Message-ID: <20071215024810.20b8a5ae.akpm@linux-foundation.org>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au>
	<20071214002209.ac748206.akpm@linux-foundation.org>
	<20071214083037.GA15602@gondor.apana.org.au>
	<20071214.111514.03773174.davem@davemloft.net>
	<20071214151136.ae0f969b.akpm@linux-foundation.org>
	<20071215041827.GC25324@gondor.apana.org.au>
	<20071214214418.0ecd5e67.akpm@linux-foundation.org>
	<20071215061021.GA26247@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52834 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355AbXLOKsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 05:48:51 -0500
In-Reply-To: <20071215061021.GA26247@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Dec 2007 14:10:21 +0800 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Dec 14, 2007 at 09:44:18PM -0800, Andrew Morton wrote:
> >
> > That sounds like a bug in mutex_trylock() to me.
> 
> I was relying on
> 
> 	http://kerneltrap.org/mailarchive/linux-netdev/2007/9/28/325129
> 
> which seems to be a bogus claim now that I actually look at the
> source code.  So in that case I'm OK with your patch as long as
> it warns about hard IRQ usage.

When Eric said

> Way way deep in mutex debugging on the slowpath there is a unreadable
> and incomprehensible WARN_ON in muxtex_trylock that will trigger if
> you have 10 tons of debugging turned on, and you are in,
> interrupt context, and you manage to hit the slow path.  I think that
> is a pretty unlikely scenario.

I think he's still right.  That's if the warning which he managed to find
even still exists.

I think the change which Eric proposed is a good one: it converts
ASSERT_RTNL() from an atomic rmw which dirties a cacheline which will
sometimes be owned by a different CPU into a plain old read.  It's going to
make ASSERT_RTNL() heaps cheaper.

<looks at mutex_is_locked(), rofls at "static inline fastcall", fixes it>

Now as a separate issue we (ie: you) need to work out what _other_ things
you want ASSERT_RTNL to check apart from "rtnl must be held".

If you want to check that no locks are held (which I think is a bit weird,
but whatever) then add might_sleep().

If you want to check that we're not in interrupt context or whatever, then
add the checks and be happy.  might_sleep() will of course check for
in_interrupt(), in_irq(), etc so if you go with a might_sleep() then
nothing else needs to be added.

While doing this I'd also suggest that the thing should be uninlined -
it'll probably generate less text and it'll give considerably more
flexibility for adding new debug fetures.  Ones which might be controlled at
compile time or runtime. ie:

void __assert_rtnl(const char *file, int line);
#define ASSERT_RTNL() __assert_rtnl(__FILE__, __LINE__)

