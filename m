From: "David S. Miller" <davem@davemloft.net>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Sat, 28 Aug 2004 23:42:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040828234201.79556f6e.davem@davemloft.net>
References: <20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
	<20040814012513.GA721@gondor.apana.org.au>
	<20040814013030.GA2042@gondor.apana.org.au>
	<20040814050848.GA11874@gondor.apana.org.au>
	<20040814062703.GA4806@gondor.apana.org.au>
	<20040815191450.77532d5d.davem@redhat.com>
	<20040816105131.GA11299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040816105131.GA11299@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2004 20:51:31 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > > CPU0					CPU1
> > > neigh_create
> > > 					inet_del_ifa
> > > 						notifier_call_chain
> > > 							neigh_ifdown
> > > 						inetdev_destroy
> > > 	arp_constructor
> > > 		neigh->parms =
> > > 			in_dev->arp_parms
> > > 							in_dev->dead = 1
> > > 							in_dev->dev->ip_ptr =
> > > 								NULL
> > > 							neigh_parms_release
> > > 	n->parms->neigh_setup => BUG
> > 
> > Is there anything other than hostess_sv11.c, sealevel.c, and shaper.c
> > which are using n->parms->neigh_setup at all?
> > 
> > This seems to be a very obscure special case hack, which perhaps we
> > can removee entirely.
> 
> That maybe the case, but the race has nothing to do with neigh_setup.
> 
> Even if you remove neigh_setup altogether, the very next line in
> neigh_create will dereference n->parms by looking up base_reachable_time.

Wait a second, how can neigh_ifdown() even find this thing?
Firstly, neigh_create() takes a reference to the device, which
in turn holds onto the inetdev preventing inetdev_destroy().

Secondly, until neigh_create() takes the tbl lock, it is not in
the hash tables and therefore neigh_ifdown() could not see it.

Thirdly, arp_constructor() does in_dev_get() and checks the
return value.  If it fails, by racing with inetdev_destroy(),
neigh_create() will return an error and not do bogus derefing.

I think that covers all the cases, right?
(please prove me wrong, this looks too easy :-)
