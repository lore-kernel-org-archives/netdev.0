From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] xfrm: provide correct dst in xfrm_neigh_lookup
Date: Sat, 25 Feb 2017 17:57:43 +0200
Message-ID: <1488038263-12447-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54151 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751231AbdBYQD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Feb 2017 11:03:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix xfrm_neigh_lookup to provide dst->path to the
neigh_lookup dst_ops method.

When skb is provided, the IP address in packet should already
match the dst->path address family. But for the non-skb case,
we should consider the last tunnel address as nexthop address.

Fixes: f894cbf847c9 ("net: Add optional SKB arg to dst_ops->neigh_lookup().")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/xfrm/xfrm_policy.c | 29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5f3e878..0806dcc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2836,14 +2836,8 @@ static unsigned int xfrm_mtu(const struct dst_entry *dst)
 	return mtu ? : dst_mtu(dst->path);
 }
 
-static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
-					   struct sk_buff *skb,
-					   const void *daddr)
-{
-	return dst->path->ops->neigh_lookup(dst, skb, daddr);
-}
-
-static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
+static const void *xfrm_get_dst_nexthop(const struct dst_entry *dst,
+					const void *daddr)
 {
 	const struct dst_entry *path = dst->path;
 
@@ -2857,6 +2851,25 @@ static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
 		else if (!(xfrm->type->flags & XFRM_TYPE_LOCAL_COADDR))
 			daddr = &xfrm->id.daddr;
 	}
+	return daddr;
+}
+
+static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
+					   struct sk_buff *skb,
+					   const void *daddr)
+{
+	const struct dst_entry *path = dst->path;
+
+	if (!skb)
+		daddr = xfrm_get_dst_nexthop(dst, daddr);
+	return path->ops->neigh_lookup(path, skb, daddr);
+}
+
+static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
+{
+	const struct dst_entry *path = dst->path;
+
+	daddr = xfrm_get_dst_nexthop(dst, daddr);
 	path->ops->confirm_neigh(path, daddr);
 }
 
-- 
1.9.3
