From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 2/4] udp: copy skb->truesize in the first cache line
Date: Thu,  8 Dec 2016 11:41:55 -0800
Message-ID: <1481226117-31288-3-git-send-email-edumazet@google.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36524 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932232AbcLHTmH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:42:07 -0500
Received: by mail-pg0-f42.google.com with SMTP id f188so176480504pgc.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:42:07 -0800 (PST)
In-Reply-To: <1481226117-31288-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In UDP RX handler, we currently clear skb->dev before skb
is added to receive queue, because device pointer is no longer
available once we exit from RCU section.

Since this first cache line is always hot, lets reuse this space
to store skb->truesize and thus avoid a cache line miss at
udp_recvmsg()/udp_skb_destructor time while receive queue
spinlock is held.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |  9 ++++++++-
 net/ipv4/udp.c         | 13 ++++++++++---
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0cd92b0f2af5fe5a7c153435b8dc75833818..332e76756f54bee3b625ed8872c024a2bf53 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -645,8 +645,15 @@ struct sk_buff {
 		struct rb_node	rbnode; /* used in netem & tcp stack */
 	};
 	struct sock		*sk;
-	struct net_device	*dev;
 
+	union {
+		struct net_device	*dev;
+		/* Some protocols might use this space to store information,
+		 * while device pointer would be NULL.
+		 * UDP receive path is one user.
+		 */
+		unsigned long		dev_scratch;
+	};
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e6a68d66f3b218998d409527301d2a994e95..c608334d99aa5620858d9cceec500b2be944 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1188,10 +1188,14 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
 }
 
-/* Note: called with sk_receive_queue.lock held */
+/* Note: called with sk_receive_queue.lock held.
+ * Instead of using skb->truesize here, find a copy of it in skb->dev_scratch
+ * This avoids a cache line miss while receive_queue lock is held.
+ * Look at __udp_enqueue_schedule_skb() to find where this copy is done.
+ */
 void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(sk, skb->truesize, 1);
+	udp_rmem_release(sk, skb->dev_scratch, 1);
 }
 EXPORT_SYMBOL(udp_skb_destructor);
 
@@ -1246,6 +1250,10 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 		busy = busylock_acquire(sk);
 	}
 	size = skb->truesize;
+	/* Copy skb->truesize into skb->dev_scratch to avoid a cache line miss
+	 * in udp_skb_destructor()
+	 */
+	skb->dev_scratch = size;
 
 	/* we drop only if the receive buf is full and the receive
 	 * queue contains some other skb
@@ -1272,7 +1280,6 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	/* no need to setup a destructor, we will explicitly release the
 	 * forward allocated memory on dequeue
 	 */
-	skb->dev = NULL;
 	sock_skb_set_dropcount(sk, skb);
 
 	__skb_queue_tail(list, skb);
-- 
2.8.0.rc3.226.g39d4020
