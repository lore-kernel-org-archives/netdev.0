From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Sat, 05 Mar 2005 14:59:26 +0100
Message-ID: <4229BB3E.8020203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060402090104070606010006"
Cc: Maillist netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060402090104070606010006
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060402090104070606010006
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/05 13:01:49+01:00 kaber@coreworks.de 
#   [XFRM4]: Fix invalid key for lookup of cached bundles
#   
#   __xfrm4_find_bundle() uses a different key than routing for
#   looking up cached bundles. When the original route was
#   reused in transport mode it is used even if fwmark/tos
#   don't match. Also compare tos/fwmark for transport mode
#   bundles.
# 
# net/ipv4/xfrm4_policy.c
#   2005/03/05 13:01:41+01:00 kaber@coreworks.de +8 -0
#   [XFRM4]: Fix invalid key for lookup of cached bundles
#   
#   __xfrm4_find_bundle() uses a different key than routing for
#   looking up cached bundles. When the original route was
#   reused in transport mode it is used even if fwmark/tos
#   don't match. Also compare tos/fwmark for transport mode
#   bundles.
# 
# include/net/dst.h
#   2005/03/05 13:01:41+01:00 kaber@coreworks.de +1 -0
#   [XFRM4]: Fix invalid key for lookup of cached bundles
#   
#   __xfrm4_find_bundle() uses a different key than routing for
#   looking up cached bundles. When the original route was
#   reused in transport mode it is used even if fwmark/tos
#   don't match. Also compare tos/fwmark for transport mode
#   bundles.
# 
diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2005-03-05 13:03:37 +01:00
+++ b/include/net/dst.h	2005-03-05 13:03:37 +01:00
@@ -48,6 +48,7 @@
 #define DST_NOXFRM		2
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
+#define DST_XFRM_TUNNEL		16
 	unsigned long		lastuse;
 	unsigned long		expires;
 
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2005-03-05 13:03:37 +01:00
+++ b/net/ipv4/xfrm4_policy.c	2005-03-05 13:03:37 +01:00
@@ -33,6 +33,13 @@
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
+		    (dst->path->flags & DST_XFRM_TUNNEL ||
+		     (!(xdst->u.rt.fl.fl4_tos ^ fl->fl4_tos) & 
+		                  (IPTOS_RT_MASK|RTO_ONLINK)
+#ifdef CONFIG_IP_ROUTE_FWMARK
+		      && xdst->u.rt.fl.fl4_fwmark == fl->fl4_fwmark
+#endif
+		      )) &&
 		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
 			dst_clone(dst);
 			break;
@@ -97,6 +104,7 @@
 		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
 		if (err)
 			goto error;
+		rt->u.dst.flags |= DST_XFRM_TUNNEL;
 	} else {
 		dst_hold(&rt->u.dst);
 	}

--------------060402090104070606010006--
