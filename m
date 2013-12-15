From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: ipv4: do not use sk_dst_lock from softirq context
Date: Sun, 15 Dec 2013 10:53:46 -0800
Message-ID: <1387133626.19078.216.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:53434 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab3LOSxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 13:53:48 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so4615789pbc.1
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 10:53:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using sk_dst_lock from softirq context is not supported right now.

Instead of adding BH protection everywhere,
udp_sk_rx_dst_set() can instead use xchg(), as suggested
by David.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: 975022310233 ("udp: ipv4: must add synchronization in udp_sk_rx_dst_set()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 62c19fdd102d..f140048334ce 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1600,20 +1600,15 @@ static void flush_stack(struct sock **stack, unsigned int count,
 }
 
 /* For TCP sockets, sk_rx_dst is protected by socket lock
- * For UDP, we use sk_dst_lock to guard against concurrent changes.
+ * For UDP, we use xchg() to guard against concurrent changes.
  */
 static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 {
 	struct dst_entry *old;
 
-	spin_lock(&sk->sk_dst_lock);
-	old = sk->sk_rx_dst;
-	if (likely(old != dst)) {
-		dst_hold(dst);
-		sk->sk_rx_dst = dst;
-		dst_release(old);
-	}
-	spin_unlock(&sk->sk_dst_lock);
+	dst_hold(dst);
+	old = xchg(&sk->sk_rx_dst, dst);
+	dst_release(old);
 }
 
 /*
