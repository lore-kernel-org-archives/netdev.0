From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: ipv4: must add synchronization in
 udp_sk_rx_dst_set()
Date: Wed, 11 Dec 2013 14:46:51 -0800
Message-ID: <1386802011.19078.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131211003948.GA18825@redhat.com>
	 <1386723287.30495.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:43772 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab3LKWqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 17:46:53 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so10855779pbb.30
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 14:46:52 -0800 (PST)
In-Reply-To: <1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Unlike TCP, UDP input path does not hold the socket lock.

Before messing with sk->sk_rx_dst, we must use a spinlock, otherwise
multiple cpus could leak a refcount.

This patch also takes care of renewing a stale dst entry.
(When the sk->sk_rx_dst would not be used by IP early demux)

Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 net/ipv4/udp.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 16d246a51a02..62c19fdd102d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1599,12 +1599,21 @@ static void flush_stack(struct sock **stack, unsigned int count,
 		kfree_skb(skb1);
 }
 
-static void udp_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+/* For TCP sockets, sk_rx_dst is protected by socket lock
+ * For UDP, we use sk_dst_lock to guard against concurrent changes.
+ */
+static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 {
-	struct dst_entry *dst = skb_dst(skb);
+	struct dst_entry *old;
 
-	dst_hold(dst);
-	sk->sk_rx_dst = dst;
+	spin_lock(&sk->sk_dst_lock);
+	old = sk->sk_rx_dst;
+	if (likely(old != dst)) {
+		dst_hold(dst);
+		sk->sk_rx_dst = dst;
+		dst_release(old);
+	}
+	spin_unlock(&sk->sk_dst_lock);
 }
 
 /*
@@ -1737,10 +1746,11 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 	sk = skb_steal_sock(skb);
 	if (sk) {
+		struct dst_entry *dst = skb_dst(skb);
 		int ret;
 
-		if (unlikely(sk->sk_rx_dst == NULL))
-			udp_sk_rx_dst_set(sk, skb);
+		if (unlikely(sk->sk_rx_dst != dst))
+			udp_sk_rx_dst_set(sk, dst);
 
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
