From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 07:38:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617213832.GC14089@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru> <20040616231317.GA5742@gondor.apana.org.au> <20040617190158.GA10925@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040617190158.GA10925@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 11:01:58PM +0400, Alexey Kuznetsov wrote:
> 
> > 			But this is wrong because it assigns
> > a single MTU to all hosts behind an IPsec gateway, even though their
> > paths may well diverge beyond the gateway.
> 
> Diverge where exactly? On path where packets are transformed? PMTU discovery
> cannot do something clever for this case: we receive only small piece
> of transformed datagram, in the best case with SPI in it, so we
> can only update pmtu not even on bundle, but on even wider aggregate,
> on SA itself. This part is missing now, by the way, it is to be done
> inside error handlers in transformations.

Let's go for an exampe: We have an IPsec tunnel to our default gateway,

0.0.0.0/0[any] 0.0.0.0/0[any] any
out ispec
esp/tunnel/192.168.0.2-192.168.0.1/

Suppose that the MTU of 192.168.0.1 is 1500, and that the calculated MTU
for the bundle is 1430.

If there is a host 10.10.10.10 on the Internet or behind some sort
a VPN where the path from 192.168.0.1 to it has an MTU of 1200,
then by sending a 1430-byte packet to 10.10.10.10 from 192.168.0.2,
we will get back an ICMP packet saying that the largest MTU for
192.168.0.2-10.10.10.10 is 1200.

This will be successfully stored in the route entry.  But the route
entry's MTU is not used at all since the MTU of the bundle is deduced
from the MTU of the path, 192.168.0.1.  So we'll continue to send large
packets to 10.10.10.10.

> >From another hand, if it is an ICMP from beyond another end of tunnel,
> it is problem of original senders to handle them. Gateways even do not
> see such ICMPs, which are destined not for them.

Agreed.  But this falls apart when the gateway is the original sender :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
