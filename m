From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix potential huge kmalloc() calls in TCP_REPAIR
Date: Wed, 18 Nov 2015 21:03:33 -0800
Message-ID: <1447909413.22599.191.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33855 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbbKSFDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 00:03:35 -0500
Received: by padhx2 with SMTP id hx2so68375681pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 21:03:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_send_rcvq() is used for re-injecting data into tcp receive queue.

Problems :

- No check against size is performed, allowed user to fool kernel in
  attempting very large memory allocations, eventually triggering
  OOM when memory is fragmented.

- In case of fault during the copy we do not return correct errno.

Lets use alloc_skb_with_frags() to cook optimal skbs.

Fixes: 292e8d8c8538 ("tcp: Move rcvq sending to tcp_input.c")
Fixes: c0e88ff0f256 ("tcp: Repair socket queues")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/tcp_input.c |   22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fdd88c3803a6..a4a0b6b3bcf2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4481,19 +4481,34 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
 int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct sk_buff *skb;
+	int err = -ENOMEM;
+	int data_len = 0;
 	bool fragstolen;
 
 	if (size == 0)
 		return 0;
 
-	skb = alloc_skb(size, sk->sk_allocation);
+	if (size > PAGE_SIZE) {
+		int npages = min_t(size_t, size >> PAGE_SHIFT, MAX_SKB_FRAGS);
+
+		data_len = npages << PAGE_SHIFT;
+		size = data_len + (size & ~PAGE_MASK);
+	}
+	skb = alloc_skb_with_frags(size - data_len, data_len,
+				   PAGE_ALLOC_COSTLY_ORDER,
+				   &err, sk->sk_allocation);
 	if (!skb)
 		goto err;
 
+	skb_put(skb, size - data_len);
+	skb->data_len = data_len;
+	skb->len = size;
+
 	if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
 		goto err_free;
 
-	if (memcpy_from_msg(skb_put(skb, size), msg, size))
+	err = skb_copy_datagram_from_iter(skb, 0, &msg->msg_iter, size);
+	if (err)
 		goto err_free;
 
 	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
@@ -4509,7 +4524,8 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 err_free:
 	kfree_skb(skb);
 err:
-	return -ENOMEM;
+	return err;
+
 }
 
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
