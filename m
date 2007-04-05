From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Move sk_setup_caps out of line
Date: Thu, 5 Apr 2007 12:46:21 +0200
Message-ID: <200704051246.21134.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47538 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966080AbXDEKqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 06:46:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It is far too large to be an inline and not in any hot paths.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.21-rc1-net/include/net/sock.h
===================================================================
--- linux-2.6.21-rc1-net.orig/include/net/sock.h
+++ linux-2.6.21-rc1-net/include/net/sock.h
@@ -1083,19 +1083,7 @@ static inline int sk_can_gso(const struc
 	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
 }
 
-static inline void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
-{
-	__sk_dst_set(sk, dst);
-	sk->sk_route_caps = dst->dev->features;
-	if (sk->sk_route_caps & NETIF_F_GSO)
-		sk->sk_route_caps |= NETIF_F_GSO_MASK;
-	if (sk_can_gso(sk)) {
-		if (dst->header_len)
-			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		else 
-			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
-	}
-}
+extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
 
 static inline void sk_charge_skb(struct sock *sk, struct sk_buff *skb)
 {
Index: linux-2.6.21-rc1-net/net/core/sock.c
===================================================================
--- linux-2.6.21-rc1-net.orig/net/core/sock.c
+++ linux-2.6.21-rc1-net/net/core/sock.c
@@ -970,6 +970,21 @@ out:
 
 EXPORT_SYMBOL_GPL(sk_clone);
 
+void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
+{
+	__sk_dst_set(sk, dst);
+	sk->sk_route_caps = dst->dev->features;
+	if (sk->sk_route_caps & NETIF_F_GSO)
+		sk->sk_route_caps |= NETIF_F_GSO_MASK;
+	if (sk_can_gso(sk)) {
+		if (dst->header_len)
+			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
+		else 
+			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
+	}
+}
+EXPORT_SYMBOL_GPL(sk_setup_caps);
+
 void __init sk_init(void)
 {
 	if (num_physpages <= 4096) {
