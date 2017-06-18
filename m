From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 01/13] sock: allocate skbs from optmem
Date: Sun, 18 Jun 2017 18:44:02 -0400
Message-ID: <20170618224414.59012-2-willemdebruijn.kernel@gmail.com>
References: <20170618224414.59012-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35415 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753151AbdFRWoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 18:44:20 -0400
In-Reply-To: <20170618224414.59012-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add sock_omalloc and sock_ofree to be able to allocate control skbs,
for instance for looping errors onto sk_error_queue.

The transmit budget (sk_wmem_alloc) is involved in transmit skb
shaping, most notably in TCP Small Queues. Using this budget for
control packets would impact transmission.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h |  2 ++
 net/core/sock.c    | 27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 858891c36f94..6ab68442ceb9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1524,6 +1524,8 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
 void __sock_wfree(struct sk_buff *skb);
 void sock_wfree(struct sk_buff *skb);
+struct sk_buff *sock_omalloc(struct sock *sk, unsigned long size,
+			     gfp_t priority);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
 void sock_efree(struct sk_buff *skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index ad8a4bc84126..03261563f6a9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1890,6 +1890,33 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 }
 EXPORT_SYMBOL(sock_wmalloc);
 
+static void sock_ofree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	atomic_sub(skb->truesize, &sk->sk_omem_alloc);
+}
+
+struct sk_buff *sock_omalloc(struct sock *sk, unsigned long size,
+			     gfp_t priority)
+{
+	struct sk_buff *skb;
+
+	/* small safe race: SKB_TRUESIZE may differ from final skb->truesize */
+	if (atomic_read(&sk->sk_omem_alloc) + SKB_TRUESIZE(size) >
+	    sysctl_optmem_max)
+		return NULL;
+
+	skb = alloc_skb(size, priority);
+	if (!skb)
+		return NULL;
+
+	atomic_add(skb->truesize, &sk->sk_omem_alloc);
+	skb->sk = sk;
+	skb->destructor = sock_ofree;
+	return skb;
+}
+
 /*
  * Allocate a memory block from the socket's option memory buffer.
  */
-- 
2.13.1.518.g3df882009-goog
