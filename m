From: Tom Lendacky <toml@us.ibm.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: 17 Jun 2003 14:57:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055879830.16368.7.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   That's perfectly fine, a 0-length prefix will cause a matche
   on all addresses.

Ok, I just wanted to verify that.  Here's a patch for your review.  I
call ipv6_addr_prefix on both of the rt6i addresses just in case they
aren't stored in prefix form at any point now or in the future.

Thanks,
Tom

diff -ur linux-2.5.71-orig/net/ipv6/xfrm6_policy.c linux-2.5.71-new/net/ipv6/xfrm6_policy.c
--- linux-2.5.71-orig/net/ipv6/xfrm6_policy.c	2003-06-14 14:18:02.000000000 -0500
+++ linux-2.5.71-new/net/ipv6/xfrm6_policy.c	2003-06-17 14:44:52.000000000 -0500
@@ -60,8 +60,23 @@
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
 		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-		if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr, &fl->fl6_dst) &&
-		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr, &fl->fl6_src) &&
+		struct in6_addr rt_dst_prefix, fl_dst_prefix,
+				rt_src_prefix, fl_src_prefix;
+
+		ipv6_addr_prefix(&rt_dst_prefix,
+				 &xdst->u.rt6.rt6i_dst.addr,
+				 xdst->u.rt6.rt6i_dst.plen);
+		ipv6_addr_prefix(&fl_dst_prefix,
+				 &fl->fl6_dst,
+				 xdst->u.rt6.rt6i_dst.plen);
+		ipv6_addr_prefix(&rt_src_prefix,
+				 &xdst->u.rt6.rt6i_src.addr,
+				 xdst->u.rt6.rt6i_src.plen);
+		ipv6_addr_prefix(&fl_src_prefix,
+				 &fl->fl6_src,
+				 xdst->u.rt6.rt6i_src.plen);
+		if (!ipv6_addr_cmp(&rt_dst_prefix, &fl_dst_prefix) &&
+		    !ipv6_addr_cmp(&rt_src_prefix, &fl_src_prefix) &&
 		    __xfrm6_bundle_ok(xdst, fl)) {
 			dst_clone(dst);
 			break;
@@ -133,7 +148,6 @@
 	dst_prev->child = &rt->u.dst;
 	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-		x->u.rt.fl = *fl;
 
 		dst_prev->dev = rt->u.dst.dev;
 		if (rt->u.dst.dev)
@@ -157,6 +171,8 @@
 		x->u.rt6.rt6i_node     = rt0->rt6i_node;
 		x->u.rt6.rt6i_gateway  = rt0->rt6i_gateway;
 		memcpy(&x->u.rt6.rt6i_gateway, &rt0->rt6i_gateway, sizeof(x->u.rt6.rt6i_gateway)); 
+		x->u.rt6.rt6i_dst      = rt0->rt6i_dst;
+		x->u.rt6.rt6i_src      = rt0->rt6i_src;	
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
