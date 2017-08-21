From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/8] net: Allow IPsec GSO for local sockets
Date: Mon, 21 Aug 2017 07:49:32 +0200
Message-ID: <1503294573-10206-8-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34946 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751019AbdHUFtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:43 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows local sockets to make use of XFRM GSO code path.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 include/net/xfrm.h | 19 +++++++++++++++++++
 net/core/sock.c    |  2 +-
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a36010..18d7de3 100644
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
index 742f68c..564f835 100644
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
2.7.4
