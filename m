From: Tom Lendacky <toml@us.ibm.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: 11 Jun 2003 12:20:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055352036.2610.42.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   Gcc emits a memcpy() check the assembly.  Structure assignment
   is a perfectly legal to do this.

Yes, that makes sense since the compiler doesn't complain.  I didn't
think to check the assembly.

As for the bug though, it appears that the "x->u.rt.fl = *fl" statement
shouldn't be performed in the IPv6 __xfrm6_bundle_create function.
Since the xfrm_dst structure is a union of the rtable structure and the
rt6_info structure (among others), setting the "x->u.rt.fl" is later
overwritten when statements such as "x->u.rt6.rt6i_... = ..." are
executed.  Should the IPv6 code be more like the IPv4 code?  A flowi
structure can be added to the rt6_info structure, rt6i_fl, which would
then allow the "x->u.rt.fl = *fl" to be changed to "x->u.rt6.rt6i_fl =
*fl".  And then the __xfrm6_find_bundle could make basically the same
checks as __xfrm4_find_bundle:

  if (xdst->u.rt6.rt6i_fl.oif == fl->oif &&
      !ipv6_addr_cmp(&xdst->u.rt6.rt6i_fl.fl6_dst, &fl->fl6_dst) &&
      !ipv6_addr_cmp(&xdst->u.rt6.rt6i_fl.fl6_src, &fl->fl6_src) && ...

I've tested this briefly and it appears to work, but I don't know all
of the intricacies of how this might effect other parts of the code.
I've attached a patch for review.  Let me know if this is ok (although
I'm leaving this afternoon for a long weekend and won't be back until
Monday).

Thanks,
Tom

diff -ur linux-2.5.70-orig/include/net/ip6_fib.h linux-2.5.70-new/include/net/ip6_fib.h
--- linux-2.5.70-orig/include/net/ip6_fib.h	2003-06-11 11:56:21.000000000 -0500
+++ linux-2.5.70-new/include/net/ip6_fib.h	2003-06-11 11:58:42.000000000 -0500
@@ -73,6 +73,8 @@
 	struct rt6key			rt6i_src;
 
 	u8				rt6i_protocol;
+
+	struct flowi			rt6i_fl;
 };
 
 struct fib6_walker_t
diff -ur linux-2.5.70-orig/net/ipv6/xfrm6_policy.c linux-2.5.70-new/net/ipv6/xfrm6_policy.c
--- linux-2.5.70-orig/net/ipv6/xfrm6_policy.c	2003-06-11 11:56:22.000000000 -0500
+++ linux-2.5.70-new/net/ipv6/xfrm6_policy.c	2003-06-11 11:58:52.000000000 -0500
@@ -60,8 +60,9 @@
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
 		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
-		if (!ipv6_addr_cmp(&xdst->u.rt6.rt6i_dst.addr, &fl->fl6_dst) &&
-		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_src.addr, &fl->fl6_src) &&
+		if (xdst->u.rt6.rt6i_fl.oif == fl->oif && 
+		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_fl.fl6_dst, &fl->fl6_dst) &&
+		    !ipv6_addr_cmp(&xdst->u.rt6.rt6i_fl.fl6_src, &fl->fl6_src) &&
 		    __xfrm6_bundle_ok(xdst, fl)) {
 			dst_clone(dst);
 			break;
@@ -133,7 +134,7 @@
 	dst_prev->child = &rt->u.dst;
 	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-		x->u.rt.fl = *fl;
+		x->u.rt6.rt6i_fl = *fl;
 
 		dst_prev->dev = rt->u.dst.dev;
 		if (rt->u.dst.dev)
