From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 6/10] [IOAT] Struct changes for TCP recv offload to IOAT
Date: Thu, 20 Apr 2006 13:50:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201338530.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:33497 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751275AbWDTUuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:50:19 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr002.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKoJgv022352
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:19 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKoJ2u016079
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:19 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKoJhF021536
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:50:19 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Adds an async_wait_queue and some additional fields to tcp_sock, and a
dma_cookie_t to sk_buff.

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 include/linux/skbuff.h |    4 ++++
 include/linux/tcp.h    |    8 ++++++++
 include/net/sock.h     |    2 ++
 include/net/tcp.h      |    7 +++++++
 net/core/sock.c        |    6 ++++++

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 613b951..76861a8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/net.h>
 #include <linux/textsearch.h>
 #include <net/checksum.h>
+#include <linux/dmaengine.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -285,6 +286,9 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
+#ifdef CONFIG_NET_DMA
+	dma_cookie_t		dma_cookie;
+#endif
 
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 542d395..c90daa5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -18,6 +18,7 @@
 #define _LINUX_TCP_H
 
 #include <linux/types.h>
+#include <linux/dmaengine.h>
 #include <asm/byteorder.h>
 
 struct tcphdr {
@@ -233,6 +234,13 @@ struct tcp_sock {
 		struct iovec		*iov;
 		int			memory;
 		int			len;
+#ifdef CONFIG_NET_DMA
+		/* members for async copy */
+		struct dma_chan		*dma_chan;
+		int			wakeup;
+		struct dma_pinned_list	*pinned_list;
+		dma_cookie_t		dma_cookie;
+#endif
 	} ucopy;
 
 	__u32	snd_wl1;	/* Sequence for window update		*/
diff --git a/include/net/sock.h b/include/net/sock.h
index af2b054..190809c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -132,6 +132,7 @@ struct sock_common {
   *	@sk_receive_queue: incoming packets
   *	@sk_wmem_alloc: transmit queue bytes committed
   *	@sk_write_queue: Packet sending queue
+  *	@sk_async_wait_queue: DMA copied packets
   *	@sk_omem_alloc: "o" is "option" or "other"
   *	@sk_wmem_queued: persistent queue size
   *	@sk_forward_alloc: space allocated forward
@@ -205,6 +206,7 @@ struct sock {
 	atomic_t		sk_omem_alloc;
 	struct sk_buff_head	sk_receive_queue;
 	struct sk_buff_head	sk_write_queue;
+	struct sk_buff_head	sk_async_wait_queue;
 	int			sk_wmem_queued;
 	int			sk_forward_alloc;
 	gfp_t			sk_allocation;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9418f4d..54e4367 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -28,6 +28,7 @@
 #include <linux/cache.h>
 #include <linux/percpu.h>
 #include <linux/skbuff.h>
+#include <linux/dmaengine.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -820,6 +821,12 @@ static inline void tcp_prequeue_init(str
 	tp->ucopy.len = 0;
 	tp->ucopy.memory = 0;
 	skb_queue_head_init(&tp->ucopy.prequeue);
+#ifdef CONFIG_NET_DMA
+	tp->ucopy.dma_chan = NULL;
+	tp->ucopy.wakeup = 0;
+	tp->ucopy.pinned_list = NULL;
+	tp->ucopy.dma_cookie = 0;
+#endif
 }
 
 /* Packet is added to VJ-style prequeue for processing in process
diff --git a/net/core/sock.c b/net/core/sock.c
index a96ea7d..d2acd35 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -818,6 +818,9 @@ struct sock *sk_clone(const struct sock 
 		atomic_set(&newsk->sk_omem_alloc, 0);
 		skb_queue_head_init(&newsk->sk_receive_queue);
 		skb_queue_head_init(&newsk->sk_write_queue);
+#ifdef CONFIG_NET_DMA
+		skb_queue_head_init(&newsk->sk_async_wait_queue);
+#endif
 
 		rwlock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
@@ -1369,6 +1372,9 @@ void sock_init_data(struct socket *sock,
 	skb_queue_head_init(&sk->sk_receive_queue);
 	skb_queue_head_init(&sk->sk_write_queue);
 	skb_queue_head_init(&sk->sk_error_queue);
+#ifdef CONFIG_NET_DMA
+	skb_queue_head_init(&sk->sk_async_wait_queue);
+#endif
 
 	sk->sk_send_head	=	NULL;
 
-- 
1.2.6




