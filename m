From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 19:15:55 +0100
Message-ID: <4214DF5B.3010608@trash.net>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020808020108000603000808"
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050217113654.GA10346@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020808020108000603000808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:

>I understand the inconsistency and agree that it should be fixed.
>However, I think the way you did it has created a new inconsistency.
>
>Tunnel mode SAs are not always used to carry subnets.  It can also
>be used for host-to-host configurations where the aim is to protect
>the IP header.  Therefore it would be inconsistent to look up a
>new route for host-to-host tunnel mode SAs.
>
>Perhaps we can simply expand the check to include local as well,
>i.e.,
>
>	if (local != fl->fl4_src || remote != fl->fl4_dst) {
>
>What do you think?
>  
>

I don't think this solves the inconsistency. By reuseing routes in tunnel
mode we allow routing by different criteria when the inner packet is headed
for the remote gateway. Your suggestion limits this a bit further, but we
can still have a situation where all packets going through a tunnel take
one path, except when the inner packet is heading for the remote gateway
itself. I think it is logically correct to reroute all packets in tunnel
mode, if we want to allow full policy routing for tunnel mode packets we
should hand tos and fwmark to xfrm_dst_lookup(). I don't think we should
do this currently because of a different problem. __xfrm4_find_bundle()
uses a different key than routing for looking up cached bundles. When the
original route was reused it is used even if fwmark/tos don't match. Fixing
this is easy, but it causes alot more cached bundles to exist. My last patch
limits this situation to transport mode because we always choose a new route
in tunnel mode based only on src/dst. Please see the attached patch for a
possible fix (ugly and compile tested only). If we want to do this for 
tunnel
mode we probably need a hash for the cached bundles first, which has its
own set of problems.

Regards
Patrick


--------------020808020108000603000808
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/net/xfrm.h 1.76 vs edited =====
--- 1.76/include/net/xfrm.h	2005-02-15 22:46:16 +01:00
+++ edited/include/net/xfrm.h	2005-02-17 18:57:39 +01:00
@@ -857,7 +857,7 @@
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
-extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
+extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family, int *is_tunnel);
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
===== net/ipv4/xfrm4_policy.c 1.15 vs edited =====
--- 1.15/net/ipv4/xfrm4_policy.c	2005-02-17 07:09:55 +01:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-02-17 19:04:45 +01:00
@@ -26,6 +26,7 @@
 __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 {
 	struct dst_entry *dst;
+	int is_tunnel = 0;
 
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
@@ -33,7 +34,13 @@
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET, &is_tunnel) &&
+		    (!is_tunnel || (!(xdst->u.rt.fl.fl4_tos ^ fl->fl4_tos) &
+		                                (IPTOS_RT_MASK|RTO_ONLINK) &&
+#ifdef CONFIG_IP_ROUTE_FWMARK
+		                      xdst->u.rt.fl.fl4_fwmark == fl->fl4_fwmark
+#endif
+		                    ))) {
 			dst_clone(dst);
 			break;
 		}
===== net/ipv6/xfrm6_policy.c 1.26 vs edited =====
--- 1.26/net/ipv6/xfrm6_policy.c	2005-02-17 07:09:55 +01:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-02-17 18:59:31 +01:00
@@ -50,7 +50,7 @@
 				 xdst->u.rt6.rt6i_src.plen);
 		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
 		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET6)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET6, NULL)) {
 			dst_clone(dst);
 			break;
 		}
===== net/xfrm/xfrm_policy.c 1.66 vs edited =====
--- 1.66/net/xfrm/xfrm_policy.c	2005-02-16 00:16:04 +01:00
+++ edited/net/xfrm/xfrm_policy.c	2005-02-17 18:59:03 +01:00
@@ -1021,7 +1021,7 @@
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
+	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC, NULL);
 }
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
@@ -1101,7 +1101,7 @@
  * still valid.
  */
 
-int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family)
+int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family, int *is_tunnel)
 {
 	struct dst_entry *dst = &xdst->u.dst;
 
@@ -1114,6 +1114,8 @@
 			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
+		if (is_tunnel && dst->xfrm->props.mode)
+			*is_tunnel = 1;
 		dst = dst->child;
 	} while (dst->xfrm);
 

--------------020808020108000603000808--
