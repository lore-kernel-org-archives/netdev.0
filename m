From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix IP early demux races
Date: Mon, 14 Dec 2015 14:08:53 -0800
Message-ID: <1450130933.8474.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
	 <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449843809.9768.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449848913.9768.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449852442.9768.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151214112802.Horde.BK3A-grfQxyYIrszzKdCZg1@ltc.linux.ibm.com>
	 <1450110986.8474.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, predeep@us.ibm.com, mjtarsel@us.ibm.com
To: dwilder@us.ibm.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34412 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbbLNWIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 17:08:55 -0500
Received: by pfbo64 with SMTP id o64so33724894pfb.1
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 14:08:54 -0800 (PST)
In-Reply-To: <1450110986.8474.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

David Wilder reported crashes caused by dst reuse.

<quote David>
  I am seeing a crash on a distro V4.2.3 kernel caused by a double
  release of a dst_entry.  In ipv4_dst_destroy() the call to  
  list_empty() finds a poisoned next pointer, indicating the dst_entry  
  has already been removed from the list and freed. The crash occurs  
  18 to 24 hours into a run of a network stress exerciser.
</quote>

Thanks to his detailed report and analysis, we were able to understand
the core issue.

IP early demux can associate a dst to skb, after a lookup in TCP/UDP
sockets.

When socket cache is not properly set, we want to store into
sk->sk_dst_cache the dst for future IP early demux lookups,
by acquiring a stable refcount on the dst.

Problem is this acquisition is simply using an atomic_inc(),
which works well, unless the dst was queued for destruction from
dst_release() noticing dst refcount went to zero, if DST_NOCACHE
was set on dst.

We need to make sure current refcount is not zero before incrementing
it, or risk double free as David reported.

This patch, being a stable candidate, adds two new helpers, and use
them only from IP early demux problematic paths.

It might be possible to merge in net-next skb_dst_force() and
skb_dst_force_safe(), but I prefer having the smallest patch for stable
kernels : Maybe some skb_dst_force() callers do not expect skb->dst
can suddenly be cleared.

Can probably be backported back to linux-3.6 kernels

Reported-by: David J. Wilder <dwilder@us.ibm.com>
Tested-by: David J. Wilder <dwilder@us.ibm.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst.h   |   33 +++++++++++++++++++++++++++++++++
 include/net/sock.h  |    2 +-
 net/ipv4/tcp_ipv4.c |    5 ++---
 net/ipv6/tcp_ipv6.c |    3 +--
 4 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 1279f9b09791..c7329dcd90cc 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -322,6 +322,39 @@ static inline void skb_dst_force(struct sk_buff *skb)
 	}
 }
 
+/**
+ * dst_hold_safe - Take a reference on a dst if possible
+ * @dst: pointer to dst entry
+ *
+ * This helper returns false if it could not safely
+ * take a reference on a dst.
+ */
+static inline bool dst_hold_safe(struct dst_entry *dst)
+{
+	if (dst->flags & DST_NOCACHE)
+		return atomic_inc_not_zero(&dst->__refcnt);
+	dst_hold(dst);
+	return true;
+}
+
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
+		if (!dst_hold_safe(dst))
+			dst = NULL;
+
+		skb->_skb_refdst = (unsigned long)dst;
+	}
+}
+
 
 /**
  *	__skb_tunnel_rx - prepare skb for rx reinsert
diff --git a/include/net/sock.h b/include/net/sock.h
index c4205e0a3a2d..28790fe18206 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -817,7 +817,7 @@ void sk_stream_write_space(struct sock *sk);
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
 	/* dont let skb dst not refcounted, we are going to leave rcu lock */
-	skb_dst_force(skb);
+	skb_dst_force_safe(skb);
 
 	if (!sk->sk_backlog.tail)
 		sk->sk_backlog.head = skb;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index db003438aaf5..d8841a2f1569 100644
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
+	if (dst && dst_hold_safe(dst)) {
 		sk->sk_rx_dst = dst;
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e7aab561b7b4..6b8a8a9091fa 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -93,10 +93,9 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
-	if (dst) {
+	if (dst && dst_hold_safe(dst)) {
 		const struct rt6_info *rt = (const struct rt6_info *)dst;
 
-		dst_hold(dst);
 		sk->sk_rx_dst = dst;
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 		inet6_sk(sk)->rx_dst_cookie = rt6_get_cookie(rt);
