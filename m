From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 1/9] sock: allocate skbs from optmem
Date: Thu,  3 Aug 2017 16:29:37 -0400
Message-ID: <20170803202945.70750-2-willemdebruijn.kernel@gmail.com>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Add sock_omalloc and sock_ofree to be able to allocate control skbs,
for instance for looping errors onto sk_error_queue.

The transmit budget (sk_wmem_alloc) is involved in transmit skb
shaping, most notably in TCP Small Queues. Using this budget for
control packets would impact transmission.

Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 include/net/sock.h |  2 ++
 net/core/sock.c    | 27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 393c38e9f6aa..0f778d3c4300 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1531,6 +1531,8 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
 			     gfp_t priority);
 void __sock_wfree(struct sk_buff *skb);
 void sock_wfree(struct sk_buff *skb);
+struct sk_buff *sock_omalloc(struct sock *sk, unsigned long size,
+			     gfp_t priority);
 void skb_orphan_partial(struct sk_buff *skb);
 void sock_rfree(struct sk_buff *skb);
 void sock_efree(struct sk_buff *skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 742f68c9c84a..1261880bdcc8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1923,6 +1923,33 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
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
2.14.0.rc1.383.gd1ce394fe2-goog
