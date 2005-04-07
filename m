From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/*] [NET] Shave 8 bytes off dst_entry on 64-bit
Date: Thu, 7 Apr 2005 22:18:39 +1000
Message-ID: <20050407121839.GA9641@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This series of patches will be dedicated to the routing cache.

Before I start working on the routing cache itself, I need to fix
some of the issues with the multipath caching code (it happens to
be in the critical places where I'll be changing the code).  

I've already sent you one patch that disables the multipath cache
addition on the input path until we actually start using it.

The next problem I'm going to tackle is to do with how the multipath
cache entries are handled.

Currently they're added one by one and live a semi-independent life
once they're in the cache.

This is buggy since two CPUs could both get a routing cache miss and
then decide to add the multipath entries for the same route.  We will
then end up with two copies of the same route.

The solution is to create them all and then insert them all at once.

However, the fact that one route can now spawn a large number of 
routing entries on the chain is bad for chain length management
since

1) It may look like hash collision when it isn't.
2) It means that we have to walk over more entries when there is a collision.

The solution is to put the multipath entries of the same route onto
its own linked list and only link the head of the list into the routing
cache.

This solution requires the addition of a new pointer into rtable.

Well I felt guilty for doing that so that's why I'm sending you this
patch :)


This rearranges dst_entry so that we shave off 8 bytes on 64-bit
platforms when CLS_ROUTE is enabled.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll rearrange rtable next which will save us some more.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=route-2

===== include/net/dst.h 1.32 vs edited =====
--- 1.32/include/net/dst.h	2005-03-19 05:44:52 +11:00
+++ edited/include/net/dst.h	2005-04-07 11:06:20 +10:00
@@ -61,14 +61,14 @@
 	unsigned long		rate_last;	/* rate limiting for ICMP */
 	unsigned long		rate_tokens;
 
-	int			error;
-
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
 	struct xfrm_state	*xfrm;
 
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
+
+	int			error;
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;

--fUYQa+Pmc3FrFX/N--
