From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Double free of dst_entry in ipv4_dst_destroy()
Date: Sun, 06 Dec 2015 17:58:35 -0800
Message-ID: <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
	 <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, predeep@us.ibm.com, mjtarsel@us.ibm.com
To: dwilder@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34826 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbbLGB6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 20:58:38 -0500
Received: by pacej9 with SMTP id ej9so116544021pac.2
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2015 17:58:37 -0800 (PST)
In-Reply-To: <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-12-06 at 13:03 -0800, Eric Dumazet wrote:

> But then when later we promote a skb->dst to a refctounted one
> (skb_dst_force(), we might make sure we abort the operation if __refcnt
> == 0 ( and DST_NOCACHE is in dst->flags)
> 

Minimum patch would be :

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
index db003438aaf5..a72688a288f5 100644
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
