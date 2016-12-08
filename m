From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 1/4] udp: add busylocks in RX path
Date: Thu,  8 Dec 2016 11:41:54 -0800
Message-ID: <1481226117-31288-2-git-send-email-edumazet@google.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33205 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932414AbcLHTmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:42:05 -0500
Received: by mail-pg0-f47.google.com with SMTP id 3so177111375pgd.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:42:05 -0800 (PST)
In-Reply-To: <1481226117-31288-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Idea of busylocks is to let producers grab an extra spinlock
to relieve pressure on the receive_queue spinlock shared by consumer.

This behavior is requested only once socket receive queue is above
half occupancy.

Under flood, this means that only one producer can be in line
trying to acquire the receive_queue spinlock.

These busylock can be allocated on a per cpu manner, instead of a
per socket one (that would consume a cache line per socket)

This patch considerably improves UDP behavior under stress,
depending on number of NIC RX queues and/or RPS spread.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c | 43 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f5628ada47b53f0d92d08210e5d7e4132a10..e6a68d66f3b218998d409527301d2a994e95 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1195,10 +1195,36 @@ void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(udp_skb_destructor);
 
+/* Idea of busylocks is to let producers grab an extra spinlock
+ * to relieve pressure on the receive_queue spinlock shared by consumer.
+ * Under flood, this means that only one producer can be in line
+ * trying to acquire the receive_queue spinlock.
+ * These busylock can be allocated on a per cpu manner, instead of a
+ * per socket one (that would consume a cache line per socket)
+ */
+static int udp_busylocks_log __read_mostly;
+static spinlock_t *udp_busylocks __read_mostly;
+
+static spinlock_t *busylock_acquire(void *ptr)
+{
+	spinlock_t *busy;
+
+	busy = udp_busylocks + hash_ptr(ptr, udp_busylocks_log);
+	spin_lock(busy);
+	return busy;
+}
+
+static void busylock_release(spinlock_t *busy)
+{
+	if (busy)
+		spin_unlock(busy);
+}
+
 int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 	int rmem, delta, amt, err = -ENOMEM;
+	spinlock_t *busy = NULL;
 	int size;
 
 	/* try to avoid the costly atomic add/sub pair when the receive
@@ -1214,8 +1240,11 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	 * - Less cache line misses at copyout() time
 	 * - Less work at consume_skb() (less alien page frag freeing)
 	 */
-	if (rmem > (sk->sk_rcvbuf >> 1))
+	if (rmem > (sk->sk_rcvbuf >> 1)) {
 		skb_condense(skb);
+
+		busy = busylock_acquire(sk);
+	}
 	size = skb->truesize;
 
 	/* we drop only if the receive buf is full and the receive
@@ -1252,6 +1281,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk);
 
+	busylock_release(busy);
 	return 0;
 
 uncharge_drop:
@@ -1259,6 +1289,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 
 drop:
 	atomic_inc(&sk->sk_drops);
+	busylock_release(busy);
 	return err;
 }
 EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
@@ -2613,6 +2644,7 @@ EXPORT_SYMBOL(udp_flow_hashrnd);
 void __init udp_init(void)
 {
 	unsigned long limit;
+	unsigned int i;
 
 	udp_table_init(&udp_table, "UDP");
 	limit = nr_free_buffer_pages() / 8;
@@ -2623,4 +2655,13 @@ void __init udp_init(void)
 
 	sysctl_udp_rmem_min = SK_MEM_QUANTUM;
 	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
+
+	/* 16 spinlocks per cpu */
+	udp_busylocks_log = ilog2(nr_cpu_ids) + 4;
+	udp_busylocks = kmalloc(sizeof(spinlock_t) << udp_busylocks_log,
+				GFP_KERNEL);
+	if (!udp_busylocks)
+		panic("UDP: failed to alloc udp_busylocks\n");
+	for (i = 0; i < (1U << udp_busylocks_log); i++)
+		spin_lock_init(udp_busylocks + i);
 }
-- 
2.8.0.rc3.226.g39d4020
