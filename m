From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Tue, 31 Aug 2004 20:41:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831104139.GA2124@gondor.apana.org.au>
References: <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040814062703.GA4806@gondor.apana.org.au> <20040815191450.77532d5d.davem@redhat.com> <20040816105131.GA11299@gondor.apana.org.au> <20040828234201.79556f6e.davem@davemloft.net> <20040829065031.GA786@gondor.apana.org.au> <20040830230820.7514985d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040830230820.7514985d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 30, 2004 at 11:08:20PM -0700, David S. Miller wrote:
> On Sun, 29 Aug 2004 16:50:31 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > Secondly, until neigh_create() takes the tbl lock, it is not in
> > > the hash tables and therefore neigh_ifdown() could not see it.
> > 
> > That part I agree with :) That's in fact what this race is about:
> > neigh_ifdown does not guarantee that the hash table will be without
> > references to idev.
> 
> I think we can clear this by putting neigh_parms_release() into an
> RCU handler.  It can't be in in_dev_rcu_put.

Yes that should go a long way in resolving this problem.  However it
is still tricky because the neighbour table doesn't refer to idev
directly.  So we'll need to go through contortions to make sure that
the corresponding idev is still alive when we add a neighbour with
its neigh_parms to the hash table.  Or better yet we should ref count
the neigh_parms directly.

> I also now believe that these sorts of races you are mentioning percolate
> out into ip_mc_destroy_dev().

Well last time I looked at it I concluded that it was safe.  It seems
that the references are either held by timers who are all taken down
at the very start of the destruction, or they're taken at places which
are under spin locks.

Did I miss something else?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
