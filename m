From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: irq safe sk_dst_[re]set()  and ipv4_sk_update_pmtu()
 fix
Date: Mon, 30 Jun 2014 01:26:23 -0700
Message-ID: <1404116783.15139.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406101726390.11647@dtop>
	 <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: dormando <dormando@rydia.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:39613 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaF3I02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 04:26:28 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so7607326wes.24
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 01:26:27 -0700 (PDT)
In-Reply-To: <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We have two different ways to handle changes to sk->sk_dst

First way (used by TCP) assumes socket lock is owned by caller, and use
no extra lock : __sk_dst_set() & __sk_dst_reset()

Another way (used by UDP) uses sk_dst_lock because socket lock is not
always taken. Note that sk_dst_lock is not softirq safe.

These ways are not inter changeable for a given socket type.

ipv4_sk_update_pmtu(), added in linux-3.8, added a race, as it used
the socket lock as synchronization, but users might be UDP sockets.

Instead of converting sk_dst_lock to a softirq safe version, use xchg()
as we did for sk_rx_dst in commit e47eb5dfb296b ("udp: ipv4: do not use
sk_dst_lock from softirq context")

In a follow up patch, we probably can remove sk_dst_lock, as it is
only used in IPv6.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Fixes: 9cb3a50c5f63e ("ipv4: Invalidate the socket cached route on pmtu events if possible")
---
 include/net/sock.h |   12 ++++++------
 net/ipv4/route.c   |   15 ++++++++-------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 173cae485de1..c556fd9b05ac 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1768,9 +1768,11 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
 static inline void
 sk_dst_set(struct sock *sk, struct dst_entry *dst)
 {
-	spin_lock(&sk->sk_dst_lock);
-	__sk_dst_set(sk, dst);
-	spin_unlock(&sk->sk_dst_lock);
+	struct dst_entry *old_dst;
+
+	sk_tx_queue_clear(sk);
+	old_dst = xchg(&sk->sk_dst_cache, dst);
+	dst_release(old_dst);
 }
 
 static inline void
@@ -1782,9 +1784,7 @@ __sk_dst_reset(struct sock *sk)
 static inline void
 sk_dst_reset(struct sock *sk)
 {
-	spin_lock(&sk->sk_dst_lock);
-	__sk_dst_reset(sk);
-	spin_unlock(&sk->sk_dst_lock);
+	sk_dst_set(sk, NULL);
 }
 
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 082239ffe34a..3162ea923ded 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1010,7 +1010,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
-	struct dst_entry *dst;
+	struct dst_entry *odst = NULL;
 	bool new = false;
 
 	bh_lock_sock(sk);
@@ -1018,16 +1018,17 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	if (!ip_sk_accept_pmtu(sk))
 		goto out;
 
-	rt = (struct rtable *) __sk_dst_get(sk);
+	odst = sk_dst_get(sk);
 
-	if (sock_owned_by_user(sk) || !rt) {
+	if (sock_owned_by_user(sk) || !odst) {
 		__ipv4_sk_update_pmtu(skb, sk, mtu);
 		goto out;
 	}
 
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
 
-	if (!__sk_dst_check(sk, 0)) {
+	rt = (struct rtable *)odst;
+	if (odst->obsolete && odst->ops->check(odst, 0) == NULL) {
 		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
@@ -1037,8 +1038,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 
 	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
 
-	dst = dst_check(&rt->dst, 0);
-	if (!dst) {
+	if (!dst_check(&rt->dst, 0)) {
 		if (new)
 			dst_release(&rt->dst);
 
@@ -1050,10 +1050,11 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	}
 
 	if (new)
-		__sk_dst_set(sk, &rt->dst);
+		sk_dst_set(sk, &rt->dst);
 
 out:
 	bh_unlock_sock(sk);
+	dst_release(odst);
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
