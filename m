From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 12:10:56 -0400
Message-ID: <20150922161056.GB9761@mtj.duckdns.org>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150922033856.GA7851@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert.

On Tue, Sep 22, 2015 at 11:38:56AM +0800, Herbert Xu wrote:
> On Mon, Sep 21, 2015 at 02:20:22PM -0400, Tejun Heo wrote:
> > store_release and load_acquire are different from the usual memory
> > barriers and can't be paired this way.  You have to pair store_release
> > and load_acquire.  Besides, it isn't a particularly good idea to
> 
> OK I've decided to drop the acquire/release helpers as they don't
> help us at all and simply pessimises the code by using full memory
> barriers (on some architectures) where only a write or read barrier
> is needed.

That's a pentium pro era errata.  Virtually no working machine is
affected by that anymore and nobody builds kernel with that option.
In most cases, store_release and load_acquire are cheaper as they're
more specific.  On x86, store_release and load_acquire boil down to
compiler reordering barriers.  You're running in the opposite
direction.

> > There's no reason to be overly smart here.  This isn't a crazy hot
> > path, write barriers tend to be very cheap, store_release more so.
> > Please just do smp_store_release() and note what it's paired with.
> 
> It's not about being overly smart.  It's about actually understanding
> what's going on with the code.  I've seen too many instances of
> people simply sprinkling synchronisation primitives around without
> any knowledge of what is happening underneath, which is just a recipe
> for creating hard-to-debug races.

I mean, read this thread.  It's one subtle breakage after another, one
confusion after another.  The problematic usages of memory barriers
are usually of two types.

1. Misunderstand what barriers do and fail to, most frequently, pair
   the barriers correctly.  This leads to things like lone smp_wmb()s
   which don't do anything but provide false sense of security.

2. The usage itself is correct but not properly documented and it's
   not clear what's being synchronized.  Because there's nothing
   inherently pairing the matching barrier pairs, w/o proper
   documentation, it can be very challenging to track down what is
   being synchronized making it difficult to tell this case from 1.
   Note that this is another reason smp_store_release() and
   smp_load_acquire() are just better.  Their specificity not only
   makes them lighter but also makes it a lot easier to track down
   what's going on.

So, when using barriers, we want to first pick the most specific
barrier pairs that suit the use case and clearly identify the matching
pairs and describe any subtlties if there's any.  Here, it's a
straight-forward writer to reader interlocking.

Once we meet the above criteria, we do want to be as simple as the use
case allows it to be.  e.g. if there are multiples readers,
encapsulate them and document them centrally.  If there are different
classes of readers and it's worthwhile to apply different
synchronization schemes to them, use separate helpers or clearly mark
and document exceptions with rationale.

> > I don't think you can skip load_acquire here just because this is the
> > second deref of the variable.  That doesn't change anything.  Race
> > condition could still happen between the first and second tests and
> > skipping the second would lead to the same kind of bug.
> 
> The reason this one is OK is because we do not use nlk->portid or
> try to get nlk from the hash table before we return to user-space.

What happens if somebody later adds code below that which happens to
use portid?  You're creating a booby trap and the patch isn't even
properly documenting what's going on.

> ---8<---
> The commit 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
> Fix autobind race condition that leads to zero port ID") created
> some new races that can occur due to inconcsistencies between the
> two port IDs.
> 
> Tejun is right that a barrier is unavoidable.  Therefore I am
> reverting to the original patch that used a boolean to indicate
> that a user netlink socket has been bound.
> 
> Barriers have been added where necessary to ensure that a valid
> portid and the hashed socket is visible.
> 
> I have also changed netlink_insert to only return EBUSY if the
> socket is bound to a portid different to the requested one.  This
> combined with only reading nlk->bound once in netlink_bind fixes
> a race where two threads that bind the socket at the same time
> with different port IDs may both succeed.
> 
> Fixes: 1f770c0a09da ("netlink: Fix autobind race condition that leads to zero port ID")
> Reported-by: Tejun Heo <tj@kernel.org>
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This is a pretty misguided use of barriers.

Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
