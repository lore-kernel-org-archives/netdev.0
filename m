From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Double free of dst_entry in ipv4_dst_destroy()
Date: Fri, 11 Dec 2015 06:23:29 -0800
Message-ID: <1449843809.9768.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
	 <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, predeep@us.ibm.com, mjtarsel@us.ibm.com
To: dwilder@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33017 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbbLKOXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 09:23:32 -0500
Received: by pabur14 with SMTP id ur14so66497148pab.0
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 06:23:31 -0800 (PST)
In-Reply-To: <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-12-06 at 17:58 -0800, Eric Dumazet wrote:
> On Sun, 2015-12-06 at 13:03 -0800, Eric Dumazet wrote:
> 
> > But then when later we promote a skb->dst to a refctounted one
> > (skb_dst_force(), we might make sure we abort the operation if __refcnt
> > == 0 ( and DST_NOCACHE is in dst->flags)
> > 
> 
> Minimum patch would be :
> 

Here is a more complete patch, it should fix the issue I think :

diff --git a/include/net/dst.h b/include/net/dst.h
index 1279f9b09791..b9a3239f4296 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -322,6 +322,24 @@ static inline void skb_dst_force(struct sk_buff *skb)
 	}
 }
 
+/**
+ * skb_dst_force_safe - makes sure skb dst is refcounted
+ * @skb: buffer
+ *
+ * If dst is not yet refcounted and not destroyed, grab a ref on it.
+ */
+static inline void skb_dst_force_safe(struct sk_buff *skb)
+{
+	if (skb_dst_is_noref(skb)) {
+		struct dst_entry *dst = skb_dst(skb);
+
+		if (!atomic_inc_not_zero(&dst->__refcnt))
+			dst = NULL;
+
+		skb->_skb_refdst = (unsigned long)dst;
+	}
+}
+
 
 /**
  *	__skb_tunnel_rx - prepare skb for rx reinsert
diff --git a/include/net/sock.h b/include/net/sock.h
index b1d475b5db68..6367d1112c3d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -816,7 +816,7 @@ void sk_stream_write_space(struct sock *sk);
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	/* dont let skb dst not refcounted, we are going to leave rcu lock */
-	skb_dst_force(skb);
+	skb_dst_force_safe(skb);
 
 	if (!sk->sk_backlog.tail)
 		sk->sk_backlog.head = skb;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index db003438aaf5..00f21ba7435d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1493,7 +1493,7 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 	if (likely(sk->sk_rx_dst))
 		skb_dst_drop(skb);
 	else
-		skb_dst_force(skb);
+		skb_dst_force_safe(skb);
 
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
@@ -1721,8 +1721,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	if (dst) {
-		dst_hold(dst);
+	if (dst && atomic_inc_not_zero(&dst->__refcnt)) {
 		sk->sk_rx_dst = dst;
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e7aab561b7b4..4be69d177440 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -93,10 +93,9 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	if (dst) {
+	if (dst && atomic_inc_not_zero(&dst->__refcnt)) {
 		const struct rt6_info *rt = (const struct rt6_info *)dst;
 
-		dst_hold(dst);
 		sk->sk_rx_dst = dst;
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 		inet6_sk(sk)->rx_dst_cookie = rt6_get_cookie(rt);
