From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 02/21] udp: call dst_hold_safe() in udp_sk_rx_set_dst()
Date: Sat, 17 Jun 2017 10:42:25 -0700
Message-ID: <20170617174244.132862-3-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36170 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbdFQRne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:34 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so11096806pfd.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:34 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In udp_v4/6_early_demux() code, we try to hold dst->__refcnt for
dst with DST_NOCACHE flag. This is because later in udp_sk_rx_dst_set()
function, we will try to cache this dst in sk for connected case.
However, a better way to achieve this is to not try to hold dst in
early_demux(), but in udp_sk_rx_dst_set(), call dst_hold_safe(). This
approach is also more consistant with how tcp is handling it. And it
will make later changes simpler.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv4/udp.c | 19 +++++++++----------
 net/ipv6/udp.c | 11 +++++------
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2bc638c48b86..f3450f092d71 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1977,9 +1977,10 @@ static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 {
 	struct dst_entry *old;
 
-	dst_hold(dst);
-	old = xchg(&sk->sk_rx_dst, dst);
-	dst_release(old);
+	if (dst_hold_safe(dst)) {
+		old = xchg(&sk->sk_rx_dst, dst);
+		dst_release(old);
+	}
 }
 
 /*
@@ -2303,13 +2304,11 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	if (dst)
 		dst = dst_check(dst, 0);
 	if (dst) {
-		/* DST_NOCACHE can not be used without taking a reference */
-		if (dst->flags & DST_NOCACHE) {
-			if (likely(atomic_inc_not_zero(&dst->__refcnt)))
-				skb_dst_set(skb, dst);
-		} else {
-			skb_dst_set_noref(skb, dst);
-		}
+		/* set noref for now.
+		 * any place which wants to hold dst has to call
+		 * dst_hold_safe()
+		 */
+		skb_dst_set_noref(skb, dst);
 	}
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2e9b52bded2d..2b33847bf931 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -920,12 +920,11 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 	if (dst)
 		dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
 	if (dst) {
-		if (dst->flags & DST_NOCACHE) {
-			if (likely(atomic_inc_not_zero(&dst->__refcnt)))
-				skb_dst_set(skb, dst);
-		} else {
-			skb_dst_set_noref(skb, dst);
-		}
+		/* set noref for now.
+		 * any place which wants to hold dst has to call
+		 * dst_hold_safe()
+		 */
+		skb_dst_set_noref(skb, dst);
 	}
 }
 
-- 
2.13.1.518.g3df882009-goog
