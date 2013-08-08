From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next] net: attempt high order allocations in
 sock_alloc_send_pskb()
Date: Thu, 08 Aug 2013 14:38:47 -0700
Message-ID: <1375997927.4004.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Rientjes <rientjes@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:33274 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966702Ab3HHViu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 17:38:50 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so567951pbc.11
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 14:38:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Adding paged frags skbs to af_unix sockets introduced a performance
regression on large sends because of additional page allocations, even
if each skb could carry at least 100% more payload than before.

We can instruct sock_alloc_send_pskb() to attempt high order
allocations.

Most of the time, it does a single page allocation instead of 8.

I added an additional parameter to sock_alloc_send_pskb() to
let other users to opt-in for this new feature on followup patches.

Tested:

Before patch :

$ netperf -t STREAM_STREAM 
STREAM STREAM TEST
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 2304  212992  212992    10.00    46861.15   

After patch :

$ netperf -t STREAM_STREAM 
STREAM STREAM TEST
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 2304  212992  212992    10.00    57981.11   


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Rientjes <rientjes@google.com>
---
Google-Bug-Id: 9198684

 drivers/net/macvtap.c  |    2 
 drivers/net/tun.c      |    2 
 include/net/sock.h     |    3 -
 net/core/sock.c        |  100 +++++++++++++++++++--------------------
 net/packet/af_packet.c |    2 
 net/unix/af_unix.c     |    6 +-
 6 files changed, 60 insertions(+), 55 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 182364a..8f6056d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -524,7 +524,7 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   err);
+				   err, 0);
 	if (!skb)
 		return NULL;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b163047..978d865 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -949,7 +949,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   &err);
+				   &err, 0);
 	if (!skb)
 		return ERR_PTR(err);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index ab6a8b7..e4bbcbf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1539,7 +1539,8 @@ extern struct sk_buff		*sock_alloc_send_pskb(struct sock *sk,
 						      unsigned long header_len,
 						      unsigned long data_len,
 						      int noblock,
-						      int *errcode);
+						      int *errcode,
+						      int max_page_order);
 extern void *sock_kmalloc(struct sock *sk, int size,
 			  gfp_t priority);
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
diff --git a/net/core/sock.c b/net/core/sock.c
index 83667de..c7cc8f1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1741,24 +1741,23 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 
 struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				     unsigned long data_len, int noblock,
-				     int *errcode)
+				     int *errcode, int max_page_order)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
+	unsigned long chunk;
 	gfp_t gfp_mask;
 	long timeo;
 	int err;
 	int npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+	struct page *page;
+	int i;
 
 	err = -EMSGSIZE;
 	if (npages > MAX_SKB_FRAGS)
 		goto failure;
 
-	gfp_mask = sk->sk_allocation;
-	if (gfp_mask & __GFP_WAIT)
-		gfp_mask |= __GFP_REPEAT;
-
 	timeo = sock_sndtimeo(sk, noblock);
-	while (1) {
+	while (!skb) {
 		err = sock_error(sk);
 		if (err != 0)
 			goto failure;
@@ -1767,50 +1766,52 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			goto failure;
 
-		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
-			skb = alloc_skb(header_len, gfp_mask);
-			if (skb) {
-				int i;
-
-				/* No pages, we're done... */
-				if (!data_len)
-					break;
-
-				skb->truesize += data_len;
-				skb_shinfo(skb)->nr_frags = npages;
-				for (i = 0; i < npages; i++) {
-					struct page *page;
-
-					page = alloc_pages(sk->sk_allocation, 0);
-					if (!page) {
-						err = -ENOBUFS;
-						skb_shinfo(skb)->nr_frags = i;
-						kfree_skb(skb);
-						goto failure;
-					}
-
-					__skb_fill_page_desc(skb, i,
-							page, 0,
-							(data_len >= PAGE_SIZE ?
-							 PAGE_SIZE :
-							 data_len));
-					data_len -= PAGE_SIZE;
-				}
+		if (atomic_read(&sk->sk_wmem_alloc) >= sk->sk_sndbuf) {
+			set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+			err = -EAGAIN;
+			if (!timeo)
+				goto failure;
+			if (signal_pending(current))
+				goto interrupted;
+			timeo = sock_wait_for_wmem(sk, timeo);
+			continue;
+		}
 
-				/* Full success... */
-				break;
-			}
-			err = -ENOBUFS;
+		err = -ENOBUFS;
+		gfp_mask = sk->sk_allocation;
+		if (gfp_mask & __GFP_WAIT)
+			gfp_mask |= __GFP_REPEAT;
+
+		skb = alloc_skb(header_len, gfp_mask);
+		if (!skb)
 			goto failure;
+
+		skb->truesize += data_len;
+
+		for (i = 0; npages > 0; i++) {
+			int order = max_page_order;
+
+			while (order) {
+				if (npages >= 1 << order) {
+					page = alloc_pages(sk->sk_allocation |
+							   __GFP_COMP | __GFP_NOWARN,
+							   order);
+					if (page)
+						goto fill_page;
+				}
+				order--;
+			}
+			page = alloc_page(sk->sk_allocation);
+			if (!page)
+				goto failure;
+fill_page:
+			chunk = min_t(unsigned long, data_len,
+				      PAGE_SIZE << order);
+			skb_fill_page_desc(skb, i, page, 0, chunk);
+			data_len -= chunk;
+			npages -= 1 << order;
 		}
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
-		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
-		err = -EAGAIN;
-		if (!timeo)
-			goto failure;
-		if (signal_pending(current))
-			goto interrupted;
-		timeo = sock_wait_for_wmem(sk, timeo);
 	}
 
 	skb_set_owner_w(skb, sk);
@@ -1819,6 +1820,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 interrupted:
 	err = sock_intr_errno(timeo);
 failure:
+	kfree_skb(skb);
 	*errcode = err;
 	return NULL;
 }
@@ -1827,7 +1829,7 @@ EXPORT_SYMBOL(sock_alloc_send_pskb);
 struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 				    int noblock, int *errcode)
 {
-	return sock_alloc_send_pskb(sk, size, 0, noblock, errcode);
+	return sock_alloc_send_pskb(sk, size, 0, noblock, errcode, 0);
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4cb28a7..6c53dd9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2181,7 +2181,7 @@ static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 		linear = len;
 
 	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   err);
+				   err, 0);
 	if (!skb)
 		return NULL;
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 99dc760..fee9e33 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1479,7 +1479,8 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 				 MAX_SKB_FRAGS * PAGE_SIZE);
 
 	skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
-				   msg->msg_flags & MSG_DONTWAIT, &err);
+				   msg->msg_flags & MSG_DONTWAIT, &err,
+				   PAGE_ALLOC_COSTLY_ORDER);
 	if (skb == NULL)
 		goto out;
 
@@ -1651,7 +1652,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		data_len = max_t(int, 0, size - SKB_MAX_HEAD(0));
 
 		skb = sock_alloc_send_pskb(sk, size - data_len, data_len,
-					   msg->msg_flags & MSG_DONTWAIT, &err);
+					   msg->msg_flags & MSG_DONTWAIT, &err,
+					   get_order(UNIX_SKB_FRAGS_SZ));
 		if (!skb)
 			goto out_err;
 
