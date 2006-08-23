From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 16/44] [XFRM] IPV6: Restrict bundle reusing
Date: Thu, 24 Aug 2006 00:02:17 +0900
Message-ID: <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:649 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964927AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

For outbound transformation, bundle is checked whether it is
suitable for current flow to be reused or not. In such IPv6 case
as below, transformation may apply incorrect bundle for the flow instead
of creating another bundle:

- The policy selector has destination prefix length < 128
  (Two or more addresses can be matched it)
- Its bundle holds dst entry of default route whose prefix length < 128
  (Previous traffic was used such route as next hop)
- The policy and the bundle were used a transport mode state and
  this time flow address is not matched the bundled state.

This issue is found by Mobile IPv6 usage to protect mobility signaling
by IPsec, but it is not a Mobile IPv6 specific.
This patch adds strict check to xfrm_bundle_ok() for each
state mode and address when prefix length is less than 128.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h      |   19 ++++++++++++++++++-
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_policy.c |    4 +++-
 net/xfrm/xfrm_policy.c  |    8 ++++++--
 4 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 86c1188..2078d84 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -870,6 +870,23 @@ xfrm_state_addr_check(struct xfrm_state 
 	return 0;
 }
 
+static __inline__ int
+xfrm_state_addr_flow_check(struct xfrm_state *x, struct flowi *fl,
+			   unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+		return __xfrm4_state_addr_check(x,
+						(xfrm_address_t *)&fl->fl4_dst,
+						(xfrm_address_t *)&fl->fl4_src);
+	case AF_INET6:
+		return __xfrm6_state_addr_check(x,
+						(xfrm_address_t *)&fl->fl6_dst,
+						(xfrm_address_t *)&fl->fl6_src);
+	}
+	return 0;
+}
+
 static inline int xfrm_state_kern(struct xfrm_state *x)
 {
 	return atomic_read(&x->tunnel_users);
@@ -1014,7 +1031,7 @@ extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
 extern void xfrm_flush_all_bundles(void);
-extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
+extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family, int strict);
 extern void xfrm_init_pmtu(struct dst_entry *dst);
 
 extern wait_queue_head_t km_waitq;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index e517981..42d8ded 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -33,7 +33,7 @@ __xfrm4_find_bundle(struct flowi *fl, st
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
 	    	    xdst->u.rt.fl.fl4_tos == fl->fl4_tos &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET, 0)) {
 			dst_clone(dst);
 			break;
 		}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index a3f68c8..729b474 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -50,7 +50,9 @@ __xfrm6_find_bundle(struct flowi *fl, st
 				 xdst->u.rt6.rt6i_src.plen);
 		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
 		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
-		    xfrm_bundle_ok(xdst, fl, AF_INET6)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET6,
+				   (xdst->u.rt6.rt6i_dst.plen != 128 ||
+				    xdst->u.rt6.rt6i_src.plen != 128))) {
 			dst_clone(dst);
 			break;
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f91cf69..c009d6f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1147,7 +1147,7 @@ static struct dst_entry *xfrm_dst_check(
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
+	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC, 0);
 }
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
@@ -1262,7 +1262,7 @@ EXPORT_SYMBOL(xfrm_init_pmtu);
  * still valid.
  */
 
-int xfrm_bundle_ok(struct xfrm_dst *first, struct flowi *fl, int family)
+int xfrm_bundle_ok(struct xfrm_dst *first, struct flowi *fl, int family, int strict)
 {
 	struct dst_entry *dst = &first->u.dst;
 	struct xfrm_dst *last;
@@ -1284,6 +1284,10 @@ int xfrm_bundle_ok(struct xfrm_dst *firs
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
 
+		if (strict && fl && dst->xfrm->props.mode != XFRM_MODE_TUNNEL &&
+		    !xfrm_state_addr_flow_check(dst->xfrm, fl, family))
+			return 0;
+
 		mtu = dst_mtu(dst->child);
 		if (xdst->child_mtu_cached != mtu) {
 			last = xdst;
-- 
1.4.0

