From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Sun, 29 Aug 2004 16:50:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829065031.GA786@gondor.apana.org.au>
References: <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040814062703.GA4806@gondor.apana.org.au> <20040815191450.77532d5d.davem@redhat.com> <20040816105131.GA11299@gondor.apana.org.au> <20040828234201.79556f6e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040828234201.79556f6e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 28, 2004 at 11:42:01PM -0700, David S. Miller wrote:
> On Mon, 16 Aug 2004 20:51:31 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > > > CPU0					CPU1
> > > > neigh_create
> > > > 					inet_del_ifa
> > > > 						notifier_call_chain
> > > > 							neigh_ifdown
> > > > 						inetdev_destroy
> > > > 	arp_constructor
> > > > 		neigh->parms =
> > > > 			in_dev->arp_parms
> > > > 							in_dev->dead = 1
> > > > 							in_dev->dev->ip_ptr =
> > > > 								NULL
> > > > 							neigh_parms_release
> > > > 	n->parms->neigh_setup => BUG
>
> > That maybe the case, but the race has nothing to do with neigh_setup.
> > 
> > Even if you remove neigh_setup altogether, the very next line in
> > neigh_create will dereference n->parms by looking up base_reachable_time.
> 
> Wait a second, how can neigh_ifdown() even find this thing?
> Firstly, neigh_create() takes a reference to the device, which
> in turn holds onto the inetdev preventing inetdev_destroy().

I'm not sure about this statement.  I can't see how holding a reference
on dev prevents you from deleting the primary address on dev which will
lead to the call chain on the right.

> Secondly, until neigh_create() takes the tbl lock, it is not in
> the hash tables and therefore neigh_ifdown() could not see it.

That part I agree with :) That's in fact what this race is about:
neigh_ifdown does not guarantee that the hash table will be without
references to idev.

> Thirdly, arp_constructor() does in_dev_get() and checks the
> return value.  If it fails, by racing with inetdev_destroy(),
> neigh_create() will return an error and not do bogus derefing.

In the above scenario, when arp_constructor() runs the in_dev is
still alive and well.  It only gets destroyed afterwards.

> I think that covers all the cases, right?
> (please prove me wrong, this looks too easy :-)

Not quite :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
