From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 10 Jun 2014 18:26:49 -0700
Message-ID: <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1406101726390.11647@dtop>
	 <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35235 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbaFKB0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 21:26:53 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so1292742pad.34
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:26:53 -0700 (PDT)
In-Reply-To: <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-10 at 18:12 -0700, Eric Dumazet wrote:

> 
> For the curious, another problem is in ipv4_sk_update_pmtu()
> 
> This can be called on UDP sockets, but from softirq context.
> 
> We cannot use sk_dst_lock because this lock is not softirq safe.
> 
> I guess we should use xchg() for sk_dst_set() and sk_dst_reset()

This would be something like this untested patch :

 include/net/sock.h |   12 ++++++------
 net/ipv4/route.c   |   15 ++++++++-------
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 21569cf456ed..04400978ceb5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1766,9 +1766,11 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
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
@@ -1780,9 +1782,7 @@ __sk_dst_reset(struct sock *sk)
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
index 5e676be3daeb..be9f2b1ac3ab 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1022,7 +1022,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
-	struct dst_entry *dst;
+	struct dst_entry *odst = NULL;
 	bool new = false;
 
 	bh_lock_sock(sk);
@@ -1030,16 +1030,17 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
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
@@ -1049,8 +1050,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 
 	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
 
-	dst = dst_check(&rt->dst, 0);
-	if (!dst) {
+	if (!dst_check(&rt->dst, 0)) {
 		if (new)
 			dst_release(&rt->dst);
 
@@ -1062,10 +1062,11 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	}
 
 	if (new)
-		__sk_dst_set(sk, &rt->dst);
+		sk_dst_set(sk, &rt->dst);
 
 out:
 	bh_unlock_sock(sk);
+	dst_release(odst);
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
