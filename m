From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Sun, 06 Mar 2005 13:34:24 +0100
Message-ID: <422AF8D0.3010905@trash.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040302070806030602040204"
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040302070806030602040204
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>@@ -97,6 +104,7 @@
>> 		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
>> 		if (err)
>> 			goto error;
>>+		rt->u.dst.flags |= DST_XFRM_TUNNEL;
> 
> 
> This line doesn't look right.  rt is an entry in the IPv4 routing
> cache, right? If so why should its flags change when some bundle is
> created?

How about this one ? It keeps the DST_XFRM_TUNNEL flag and sets it on
the first xfrm_dst in a bundle. I know it doesn't really belong there,
but the alternatives are walking through the bundle an additional time
or having xfrm_bundle_ok() return if it is a tunnel-mode bundle, but in
that case we can only compare tos etc after the call to
xfrm_bundle_ok(), which is rather expensive. I also moved the oif check
to the checks performed only in transport mode, this reduces the number
of cached bundles in tunnel mode to one per src/dst if the selector
isn't narrower than that.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------040302070806030602040204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/net/dst.h 1.26 vs edited =====
--- 1.26/include/net/dst.h	2005-02-15 23:23:10 +01:00
+++ edited/include/net/dst.h	2005-03-06 12:50:54 +01:00
@@ -48,6 +48,7 @@
 #define DST_NOXFRM		2
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
+#define DST_XFRM_TUNNEL		16
 	unsigned long		lastuse;
 	unsigned long		expires;
 
===== net/ipv4/xfrm4_policy.c 1.15 vs edited =====
--- 1.15/net/ipv4/xfrm4_policy.c	2005-03-05 01:58:41 +01:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-03-06 13:26:44 +01:00
@@ -30,9 +30,15 @@
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
 		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
-		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
+		if (xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
+		    (dst->flags & DST_XFRM_TUNNEL ||
+		     (!(xdst->u.rt.fl.fl4_tos ^ fl->fl4_tos) & 
+		                  (IPTOS_RT_MASK|RTO_ONLINK) &&
+#ifdef CONFIG_IP_ROUTE_FWMARK
+		      xdst->u.rt.fl.fl4_fwmark == fl->fl4_fwmark &&
+#endif
+		      xdst->u.rt.fl.oif == fl->oif)) &&
 		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
 			dst_clone(dst);
 			break;
@@ -97,6 +103,7 @@
 		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
 		if (err)
 			goto error;
+		dst->flags |= DST_XFRM_TUNNEL;
 	} else {
 		dst_hold(&rt->u.dst);
 	}

--------------040302070806030602040204--
