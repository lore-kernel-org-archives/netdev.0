From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Mon, 8 Mar 2010 19:50:48 +0100
Message-ID: <201003081950.48384.arnd@arndb.de>
References: <20100228054012.GA7583@gondor.apana.org.au> <20100307024500.GA20126@gondor.apana.org.au> <20100307031151.GA7546@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:55924 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab0CHSvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:51:36 -0500
In-Reply-To: <20100307031151.GA7546@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 07 March 2010, Paul E. McKenney wrote:
> On Sun, Mar 07, 2010 at 10:45:00AM +0800, Herbert Xu wrote:
> > On Sat, Mar 06, 2010 at 11:00:00AM -0800, Paul E. McKenney wrote:
> 
> OK, just re-checked your patch, and it looks OK.
> 
> Also adding Arnd to CC.
> 
> Arnd, would it be reasonable to extend your RCU-sparse changes to have
> four different pointer namespaces, one for each flavor of RCU?  (RCU,
> RCU-bh, RCU-sched, and SRCU)?  Always a fan of making the computer do
> the auditing where reasonable.  ;-)

Yes, I guess that would be possible. I'd still leave out the rculist
from any annotations for now, as this would get even more complex then.

One consequence will be the need for new rcu_assign_pointer{,_bh,_sched}
macros that check the address space of the first argument, otherwise
you'd be able to stick anything in there, including non-__rcu pointers.

I've also found a few places (less than a handful) that use RCU to
protect per-CPU data. Not sure how to deal with that, because now
this also has its own named address space (__percpu), and it's probably
a bit too much to introduce all combinations of
{s,}rcu_{assign_pointer,dereference}{,_bh,_sched}{,_const}{,_percpu},
so I'm ignoring them for now.

> This could potentially catch the mismatched call_rcu()s, at least if the
> rcu_head could be labeled.

I haven't labeled the rcu_head at all so far, and I'm not sure if that's
necessary. What I've been thinking about is replacing typical code like

/* this is called with the writer-side lock held */
void foo_assign(struct foo *foo, struct bar *newbar)
{
	struct bar *bar = rcu_dereference_const(foo->bar); /* I just had to add 
							    this dereference */
	rcu_assign_pointer(foo->bar, newbar);
	if (bar)
		call_rcu(&bar->rcu, bar_destructor);
}

with the shorter

void foo_assign(struct foo *foo, struct bar *newbar)
{
	struct bar *bar = rcu_exchange(foo->bar, newbar);
	if (bar)
		call_rcu(&bar->rcu, bar_destructor);
}

Now we could combine this to

void foo_assign(struct foo *foo, struct bar *newbar)
{
	rcu_exchange_call(foo->bar, newbar, rcu, bar_destructor);
}

#define rcu_exchange_call(ptr, new, member, func) \
({ \
	typeof(new) old = rcu_exchange((ptr),(new)); \
	if (old) \
		call_rcu(&(old)->member, (func));	\
	old; \
})

and make appropriate versions of all the above rcu methods for this.
With some extra macro magic, this could even become type safe and
accept a function that takes a typeof(ptr) argument instead of the
rcu_head.

	Arnd
