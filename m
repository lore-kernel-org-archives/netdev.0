From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Mon, 16 Aug 2004 13:08:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816030826.GA8341@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040815195820.6b79b3fc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815195820.6b79b3fc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 15, 2004 at 07:58:20PM -0700, David S. Miller wrote:
> On Sat, 14 Aug 2004 10:34:28 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > BTW, it looks like you can remove inetdev_lock altogether.  All its
> > users already assume that they don't race against each other by
> > taking the rtnl lock.
> 
> I think it's needed at least for the:
> 
> 	dev->ip_ptr = idev;
> 	in_dev_get(idev);

You mean in_dev_hold?

> thing, isn't it?

I don't think so.  But there is a real bug here :)

The lock doesn't really do much since everyone who's holding
it (they're all in devinet.c) already hold the RTNL lock
(the rotten old lock perhaps :)

But the RCU change has created a real bug here.  Imagine this:

CPU0					CPU1
inetdev_init
	dev->ip_ptr = idev
					in_dev_get
						atomic_inc on refcnt

					in_dev_put => frees idev
	in_dev_hold(idev) => BUG

So we should reverse the two statements and add an smp_wmb().

Unfortunately the lock doesn't really help you at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
