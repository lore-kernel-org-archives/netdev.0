From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Sat, 19 Jun 2004 08:21:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618222110.GA23101@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru> <20040616231317.GA5742@gondor.apana.org.au> <20040617190158.GA10925@ms2.inr.ac.ru> <20040617213832.GC14089@gondor.apana.org.au> <20040618202551.GA2733@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040618202551.GA2733@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 19, 2004 at 12:25:51AM +0400, Alexey Kuznetsov wrote:
> 
> Well, I think they are just to be reflected directly in dst->pmtu.
> Apparently, incoming ICMPs are to be run not only through raw IP dsts
> but also though policy to find matching bundles and make
> dst->pmtu = min(new_pmtu, dst->pmtu) on them.

That solves the PMTU discovery issue, but it doesn't provide a way for
the user to set the MTU using

ip r r add 10.10.10.10 mtu 1200

So I think we should still keep the path but set the path to the
routing entry for 10.10.10.10 at the top level.  Similarly, we can
set the path at the segment boundaries (determined by a change in
the remote address or perhaps local + remote) to the corresponding
routing entries to solve the mid-level PMTU problem.
 
> It is not _within_. Bundles are created per address pair, in your
> case 192.168.0.2 -> 10.10.10.10 should be a separate bundle.

You're right.  I missed that.  That's going to be one huge bundle
list for the default gateway case :)
 
> Actually, this even does not change things comparing to existing
> understanding (not the code though :-(), because after we start
> to collect pmtu on SAs, we have to recalculate dst->pmtu too,
> it would be kind of expensive to run through bundle and take
> minimum of all the dst->pmtu-overhead_at_this_level for
> each packet, so we have to precalculate the result and store it
> at top level.

Absolutely.  If it weren't expensive I would've sent in a minimal
patch to get xfrm4_tunnel_check_size() to call get_mss() :)

What I'm thinking of is to set the dst->path in the way I've described
before, and then also store the dst_pmtu inside dst itself.  We can
then find out when the path's MTU changes due to ICMP messages by
comparing dst_pmtu(dst) with dst_metric(dst, RTAX_MTU).  If this
passes for all dst's in the bundle we keep going, otherwise we
start recalculating at the lowest dst.

BTW you have to store it at each level and not just the top (well,
at least for each tunnel SA) because xfrm4_tunnel_check_size needs
this for some reason.

In fact by doing this we can get rid of xfrm_get_mss() and replace
it with xfrm_state_get_mss() instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
