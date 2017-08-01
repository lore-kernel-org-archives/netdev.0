From: ilant@mellanox.com
Subject: [PATCH net-next 7/7] net: Allow IPsec GSO for local sockets
Date: Tue,  1 Aug 2017 12:49:10 +0300
Message-ID: <20170801094910.14895-8-ilant@mellanox.com>
References: <20170801094910.14895-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50051.outbound.protection.outlook.com ([40.107.5.51]:57152
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751352AbdHAJuI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 05:50:08 -0400
In-Reply-To: <20170801094910.14895-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

This patch allows local sockets to make use of XFRM GSO code path.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 include/net/xfrm.h | 19 +++++++++++++++++++
 net/core/sock.c    |  2 +-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a360100136c..18d7de34a5c3 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1858,6 +1858,20 @@ int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 		       struct xfrm_user_offload *xuo);
 bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
 
+static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
+{
+	struct xfrm_state *x = dst->xfrm;
+
+	if (!x || !x->type_offload)
+		return false;
+
+	if (x->xso.offload_handle && (x->xso.dev == dst->path->dev) &&
+	    !dst->child->xfrm)
+		return true;
+
+	return false;
+}
+
 static inline void xfrm_dev_state_delete(struct xfrm_state *x)
 {
 	struct xfrm_state_offload *xso = &x->xso;
@@ -1900,6 +1914,11 @@ static inline bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x
 {
 	return false;
 }
+
+static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
+{
+	return false;
+}
 #endif
 
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..e4b45d027d8b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1757,7 +1757,7 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	sk->sk_route_caps &= ~sk->sk_route_nocaps;
 	if (sk_can_gso(sk)) {
-		if (dst->header_len) {
+		if (dst->header_len && !xfrm_dst_offload_ok(dst)) {
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
-- 
2.11.0
