From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Wed, 16 Jun 2004 22:10:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616121026.GA1169@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040615124334.GA25164@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2004 at 10:43:34PM +1000, herbert wrote:
> 
> So unless I'm missing something, we should get rid of dst->path and
> store the MTU in the xfrm dst's directly.

Actually that's still broken for nested tunnels.  If we get an ICMP
packet for a peer in the middle of the bundle, it is not easy to find
the corresponding dst's to update.

So how about this solution:

MTU Barriers
------------
We divide each bundle into segments with the property that within
each segment the local/remote addresses do not change.  For example,
the following nested template will be divided into two segments:

ipcomp/tunnel/192.168.0.2-192.168.0.1/
esp/transport//
<-------------Check MTU-------------->
esp/tunnel/10.0.0.2-10.0.0.1/

Between each pair of segments we will add an MTU-checking dst whose
path is set to the route entry of the corresponding local/remote
address.  For example, in the above scenario we'll add such a dst
after the esp/transport// SA and set its path to the route entry
for 192.168.0.2 to 192.168.0.1.

We will also store the computed MTU for each dst in itself at creation
time.  This is modified subsequently through update_pmtu.

As an example, let's say that we receive an ICMP packet where the
original header is from 192.168.0.2 to 192.168.0.1.  We will update
the MTU in the corresponding route entry, which will then cause the
dst_pmtu of the MTU-checking dst to be reduced.  If a subsequent large
packet is transmitted through the bundle, it should fail at the
MTU-checking dst and send back an ICMP error.  The error should then
filter through the bundle by update_pmtu.

This takes care of ICMP packets for IPsec peers in the middle of a bundle.

Flow Cache
----------
We will also modify the flow cache to store bundles instead of outgoing
policies (Incoming/forward policies will stay as is).  The reason is
that within each bundle, the MTU may still differ depending on the
final destination address.

Thus we will add another MTU-checking dst at the front of each bundle.
Its path will be set to the route entry that triggered the lookup.

This dst will then be stored inside the flow cache.

This takes care of ICMP packets for destination hosts over IPsec.

Conclusion
----------
Now the problem with all this is that it looks pretty complicated.
So I'd like to hear from you that this is all unnecessary and that
one of you already has a solution for it all :)

Seriously, I'd appreciate comments on this proposal or other proposals
about the interaction between PMTU and IPsec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
