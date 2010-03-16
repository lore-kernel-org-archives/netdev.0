From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] NET_DMA: free skbs periodically
Date: Tue, 16 Mar 2010 10:22:44 -0500
Message-ID: <1268752964-4397-1-git-send-email-steve@digidescorp.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	"Steven J. Magnani" <steve@digidescorp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.digidescorp.com ([66.244.163.200]:53912 "EHLO
	digidescorp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758628Ab0CPPW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 11:22:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under NET_DMA, data transfer can grind to a halt when userland issues a
large read on a socket with a high RCVLOWAT (i.e., 512 KB for both).
This appears to be because the NET_DMA design queues up lots of memcpy 
operations, but doesn't issue or wait for them (and thus free the 
associated skbs) until it is time for tcp_recvmesg() to return. 
The socket hangs when its TCP window goes to zero before enough data is 
available to satisfy the read.

Periodically issue asynchronous memcpy operations, and free skbs for ones 
that have completed, to prevent sockets from going into zero-window mode.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2010-03-16 09:15:31.000000000 -0500
+++ b/net/ipv4/tcp.c	2010-03-16 09:59:06.000000000 -0500
@@ -1254,6 +1254,39 @@ static void tcp_prequeue_process(struct 
 	tp->ucopy.memory = 0;
 }
 
+#ifdef CONFIG_NET_DMA
+static void tcp_service_net_dma(struct sock *sk, bool wait)
+{
+	dma_cookie_t done, used;
+	dma_cookie_t last_issued;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (!tp->ucopy.dma_chan)
+		return;
+
+	last_issued = tp->ucopy.dma_cookie;
+	dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+
+	do {
+		if (dma_async_memcpy_complete(tp->ucopy.dma_chan,
+					      last_issued, &done,
+					      &used) == DMA_SUCCESS) {
+			/* Safe to free early-copied skbs now */
+			__skb_queue_purge(&sk->sk_async_wait_queue);
+			break;
+		} else {
+			struct sk_buff *skb;
+			while ((skb = skb_peek(&sk->sk_async_wait_queue)) &&
+			       (dma_async_is_complete(skb->dma_cookie, done,
+						      used) == DMA_SUCCESS)) {
+				__skb_dequeue(&sk->sk_async_wait_queue);
+				kfree_skb(skb);
+			}
+		}
+	} while (wait);
+}
+#endif
+
 static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 {
 	struct sk_buff *skb;
@@ -1546,6 +1579,10 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			/* __ Set realtime policy in scheduler __ */
 		}
 
+#ifdef CONFIG_NET_DMA
+		if (tp->ucopy.dma_chan)
+			dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+#endif
 		if (copied >= target) {
 			/* Do not sleep, just process backlog. */
 			release_sock(sk);
@@ -1554,6 +1591,7 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			sk_wait_data(sk, &timeo);
 
 #ifdef CONFIG_NET_DMA
+		tcp_service_net_dma(sk, false);  /* Don't block */
 		tp->ucopy.wakeup = 0;
 #endif
 
@@ -1633,6 +1671,9 @@ do_prequeue:
 						copied = -EFAULT;
 					break;
 				}
+
+				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
+
 				if ((offset + used) == skb->len)
 					copied_early = 1;
 
@@ -1702,27 +1743,9 @@ skip_copy:
 	}
 
 #ifdef CONFIG_NET_DMA
-	if (tp->ucopy.dma_chan) {
-		dma_cookie_t done, used;
-
-		dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
-
-		while (dma_async_memcpy_complete(tp->ucopy.dma_chan,
-						 tp->ucopy.dma_cookie, &done,
-						 &used) == DMA_IN_PROGRESS) {
-			/* do partial cleanup of sk_async_wait_queue */
-			while ((skb = skb_peek(&sk->sk_async_wait_queue)) &&
-			       (dma_async_is_complete(skb->dma_cookie, done,
-						      used) == DMA_SUCCESS)) {
-				__skb_dequeue(&sk->sk_async_wait_queue);
-				kfree_skb(skb);
-			}
-		}
+	tcp_service_net_dma(sk, true);  /* Wait for queue to drain */
+	tp->ucopy.dma_chan = NULL;
 
-		/* Safe to free early-copied skbs now */
-		__skb_queue_purge(&sk->sk_async_wait_queue);
-		tp->ucopy.dma_chan = NULL;
-	}
 	if (tp->ucopy.pinned_list) {
 		dma_unpin_iovec_pages(tp->ucopy.pinned_list);
 		tp->ucopy.pinned_list = NULL;

