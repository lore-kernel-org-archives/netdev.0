From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Tue, 14 Aug 2007 10:01:28 -0700
Message-ID: <20070814170128.GA8243@linux.vnet.ibm.com>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au> <20070813060302.GF13410@linux.vnet.ibm.com> <46C13EE1.1000707@yahoo.com.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:58263 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764330AbXHNRBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 13:01:35 -0400
Content-Disposition: inline
In-Reply-To: <46C13EE1.1000707@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 03:34:25PM +1000, Nick Piggin wrote:
> Paul E. McKenney wrote:
> >On Mon, Aug 13, 2007 at 01:15:52PM +0800, Herbert Xu wrote:
> >
> >>Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> >>
> >>>On Sat, Aug 11, 2007 at 08:54:46AM +0800, Herbert Xu wrote:
> >>>
> >>>>Chris Snook <csnook@redhat.com> wrote:
> >>>>
> >>>>>cpu_relax() contains a barrier, so it should do the right thing.  For 
> >>>>>non-smp architectures, I'm concerned about interacting with interrupt 
> >>>>>handlers.  Some drivers do use atomic_* operations.
> >>>>
> >>>>What problems with interrupt handlers? Access to int/long must
> >>>>be atomic or we're in big trouble anyway.
> >>>
> >>>Reordering due to compiler optimizations.  CPU reordering does not
> >>>affect interactions with interrupt handlers on a given CPU, but
> >>>reordering due to compiler code-movement optimization does.  Since
> >>>volatile can in some cases suppress code-movement optimizations,
> >>>it can affect interactions with interrupt handlers.
> >>
> >>If such reordering matters, then you should use one of the
> >>*mb macros or barrier() rather than relying on possibly
> >>hidden volatile cast.
> >
> >
> >If communicating among CPUs, sure.  However, when communicating between
> >mainline and interrupt/NMI handlers on the same CPU, the barrier() and
> >most expecially the *mb() macros are gross overkill.  So there really
> >truly is a place for volatile -- not a large place, to be sure, but a
> >place nonetheless.
> 
> I really would like all volatile users to go away and be replaced
> by explicit barriers. It makes things nicer and more explicit... for
> atomic_t type there probably aren't many optimisations that can be
> made which volatile would disallow (in actual kernel code), but for
> others (eg. bitops, maybe atomic ops in UP kernels), there would be.
> 
> Maybe it is the safe way to go, but it does obscure cases where there
> is a real need for barriers.

I prefer burying barriers into other primitives.

> Many atomic operations are allowed to be reordered between CPUs, so
> I don't have a good idea for the rationale to order them within the
> CPU (also loads and stores to long and ptr types are not ordered like
> this, although we do consider those to be atomic operations too).
> 
> barrier() in a way is like enforcing sequential memory ordering
> between process and interrupt context, wheras volatile is just
> enforcing coherency of a single memory location (and as such is
> cheaper).

barrier() is useful, but it has the very painful side-effect of forcing
the compiler to dump temporaries.  So we do need something that is
not quite so global in effect.

> What do you think of this crazy idea?
> 
> /* Enforce a compiler barrier for only operations to location X.
>  * Call multiple times to provide an ordering between multiple
>  * memory locations. Other memory operations can be assumed by
>  * the compiler to remain unchanged and may be reordered
>  */
> #define order(x) asm volatile("" : "+m" (x))

There was something very similar discussed earlier in this thread,
with quite a bit of debate as to exactly what the "m" flag should
look like.  I suggested something similar named ACCESS_ONCE in the
context of RCU (http://lkml.org/lkml/2007/7/11/664):

	#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

The nice thing about this is that it works for both loads and stores.
Not clear that order() above does this -- I get compiler errors when
I try something like "b = order(a)" or "order(a) = 1" using gcc 4.1.2.

						Thanx, Paul
