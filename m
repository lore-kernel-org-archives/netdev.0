From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Fri, 3 Sep 2004 09:00:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903090053.22c67bb9@dell_ss3.pdx.osdl.net>
References: <20040814050848.GA11874@gondor.apana.org.au>
	<20040814062703.GA4806@gondor.apana.org.au>
	<20040815191450.77532d5d.davem@redhat.com>
	<20040816105131.GA11299@gondor.apana.org.au>
	<20040828234201.79556f6e.davem@davemloft.net>
	<20040829065031.GA786@gondor.apana.org.au>
	<20040830230820.7514985d.davem@davemloft.net>
	<20040831104139.GA2124@gondor.apana.org.au>
	<20040901222118.0ce4bcc6.davem@davemloft.net>
	<20040902130605.GA32570@gondor.apana.org.au>
	<20040903133623.GA23179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040903133623.GA23179@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 23:36:23 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Sep 02, 2004 at 11:06:05PM +1000, herbert wrote:
> > 
> > > Can you work on the next bit you mentioned, making
> > > sure the corresponding idev is still alive when we add
> > > a neighbour with its neigh_parms to the hash table?
> > 
> > Sure.  Actually I prefer to do it by ref counting neigh_parms directly.
> > I'll send you a patch soon.
> 
> Here is the patch.
> 
> I've added a refcnt on neigh_parms as well as a dead flag.  The latter
> is checked under the tbl_lock before adding a neigh entry to the hash
> table.
> 
> The non-trivial bit of the patch is the first chunk of net/core/neighbour.c.
> I removed that line because not doing so would mean that I have to drop
> the reference to the parms right there.  That would've lead to race
> conditions since many places dereference neigh->parms without holding
> locks.  It's also unnecessary to reset n->parms since we're no longer
> in a hurry to see it go due to the new ref counting.
> 
> You'll also notice that I've put all dereferences of dev->*_ptr under
> the rcu_read_lock().  Without this we may get a neigh_parms that's
> already been released.

I haven't looked at the exact code in detail, but don't you need
use rcu_dereference() as well to make sure and get the smp_read_barrier_depends
on Alpha.
