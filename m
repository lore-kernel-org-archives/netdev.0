From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 05/12] net: Create and use new helper xfrm_dst_child().
Date: Wed, 25 Oct 2017 23:03:25 +0900 (KST)
Message-ID: <20171025.230325.1201318483362616226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751977AbdJYOD3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:03:29 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 5609C133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:03:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Only IPSEC routes have a non-NULL dst->child pointer.  And IPSEC
routes are identified by a non-NULL dst->xfrm pointer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h           |  9 +++++++++
 net/ipv4/xfrm4_mode_tunnel.c |  2 +-
 net/ipv6/xfrm6_mode_tunnel.c |  2 +-
 net/ipv6/xfrm6_policy.c      |  2 +-
 net/xfrm/xfrm_output.c       |  2 +-
 net/xfrm/xfrm_policy.c       | 12 ++++++------
 security/selinux/xfrm.c      |  2 +-
 7 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f002a2c5e33c..4fa951112873 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -994,6 +994,15 @@ struct xfrm_dst {
 };
 
 #ifdef CONFIG_XFRM
+static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
+{
+#ifdef CONFIG_XFRM
+	if (dst->xfrm)
+		return dst->child;
+#endif
+	return NULL;
+}
+
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 {
 	xfrm_pols_put(xdst->pols, xdst->num_pols);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index e6265e2c274e..7d885a44dc9d 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -62,7 +62,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
 		0 : (XFRM_MODE_SKB_CB(skb)->frag_off & htons(IP_DF));
 
-	top_iph->ttl = ip4_dst_hoplimit(dst->child);
+	top_iph->ttl = ip4_dst_hoplimit(xfrm_dst_child(dst));
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 02556e356f87..e66b94f46532 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -59,7 +59,7 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (x->props.flags & XFRM_STATE_NOECN)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
-	top_iph->hop_limit = ip6_dst_hoplimit(dst->child);
+	top_iph->hop_limit = ip6_dst_hoplimit(xfrm_dst_child(dst));
 	top_iph->saddr = *(struct in6_addr *)&x->props.saddr;
 	top_iph->daddr = *(struct in6_addr *)&x->id.daddr;
 	return 0;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 4ed9f8cc3b6a..e2e6cceef288 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -264,7 +264,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			in6_dev_put(xdst->u.rt6.rt6i_idev);
 			xdst->u.rt6.rt6i_idev = loopback_idev;
 			in6_dev_hold(loopback_idev);
-			xdst = (struct xfrm_dst *)xdst->u.dst.child;
+			xdst = (struct xfrm_dst *)xfrm_dst_child(&xdst->u.dst);
 		} while (xdst->u.dst.xfrm);
 
 		__in6_dev_put(loopback_idev);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 31a2e6d34dba..7fc0932d61ff 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -44,7 +44,7 @@ static int xfrm_skb_check_space(struct sk_buff *skb)
 
 static struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 {
-	struct dst_entry *child = dst_clone(skb_dst(skb)->child);
+	struct dst_entry *child = dst_clone(xfrm_dst_child(skb_dst(skb)));
 
 	skb_dst_drop(skb);
 	return child;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4838329bb43a..c68fb3327a68 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1635,7 +1635,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
 
-	for (dst_prev = dst0; dst_prev != dst; dst_prev = dst_prev->child) {
+	for (dst_prev = dst0; dst_prev != dst; dst_prev = xfrm_dst_child(dst_prev)) {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst_prev;
 
 		err = xfrm_fill_dst(xdst, dev, fl);
@@ -2570,7 +2570,7 @@ static int stale_bundle(struct dst_entry *dst)
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
 {
-	while ((dst = dst->child) && dst->xfrm && dst->dev == dev) {
+	while ((dst = xfrm_dst_child(dst)) && dst->xfrm && dst->dev == dev) {
 		dst->dev = dev_net(dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
@@ -2600,7 +2600,7 @@ static void xfrm_init_pmtu(struct dst_entry *dst)
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 		u32 pmtu, route_mtu_cached;
 
-		pmtu = dst_mtu(dst->child);
+		pmtu = dst_mtu(xfrm_dst_child(dst));
 		xdst->child_mtu_cached = pmtu;
 
 		pmtu = xfrm_state_mtu(dst->xfrm, pmtu);
@@ -2645,7 +2645,7 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 		    xdst->policy_genid != atomic_read(&xdst->pols[0]->genid))
 			return 0;
 
-		mtu = dst_mtu(dst->child);
+		mtu = dst_mtu(xfrm_dst_child(dst));
 		if (xdst->child_mtu_cached != mtu) {
 			last = xdst;
 			xdst->child_mtu_cached = mtu;
@@ -2659,7 +2659,7 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 			xdst->route_mtu_cached = mtu;
 		}
 
-		dst = dst->child;
+		dst = xfrm_dst_child(dst);
 	} while (dst->xfrm);
 
 	if (likely(!last))
@@ -2701,7 +2701,7 @@ static const void *xfrm_get_dst_nexthop(const struct dst_entry *dst,
 {
 	const struct dst_entry *path = dst->path;
 
-	for (; dst != path; dst = dst->child) {
+	for (; dst != path; dst = xfrm_dst_child(dst)) {
 		const struct xfrm_state *xfrm = dst->xfrm;
 
 		if (xfrm->props.mode == XFRM_MODE_TRANSPORT)
diff --git a/security/selinux/xfrm.c b/security/selinux/xfrm.c
index 56e354fcdfc6..928188902901 100644
--- a/security/selinux/xfrm.c
+++ b/security/selinux/xfrm.c
@@ -452,7 +452,7 @@ int selinux_xfrm_postroute_last(u32 sk_sid, struct sk_buff *skb,
 	if (dst) {
 		struct dst_entry *iter;
 
-		for (iter = dst; iter != NULL; iter = iter->child) {
+		for (iter = dst; iter != NULL; iter = xfrm_dst_child(iter)) {
 			struct xfrm_state *x = iter->xfrm;
 
 			if (x && selinux_authorizable_xfrm(x))
-- 
2.13.6
