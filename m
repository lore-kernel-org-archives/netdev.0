From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v5 2/3] udp: implement memory accounting helpers
Date: Thu, 20 Oct 2016 22:31:09 +0200
Message-ID: <d932905c2581df9415449216eceeed1566290e3e.1476979679.git.pabeni@redhat.com>
References: <cover.1476979679.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1476979679.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Avoid using the generic helpers.
Use the receive queue spin lock to protect the memory
accounting operation, both on enqueue and on dequeue.

On dequeue perform partial memory reclaiming, trying to
leave a quantum of forward allocated memory.

On enqueue use a custom helper, to allow some optimizations:
- use a plain spin_lock() variant instead of the slightly
  costly spin_lock_irqsave(),
- avoid dst_force check, since the calling code has already
  dropped the skb dst

The above needs custom memory reclaiming on shutdown, provided
by the udp_destruct_sock().

v4 -> v5:
  - replace the mem_lock with the receive queue spin lock
  - ensure that the bh is always allowed to enqueue at least
    a skb, even if sk_rcvbuf is exceeded

v3 -> v4:
  - reworked memory accunting, simplifying the schema
  - provide an helper for both memory scheduling and enqueuing

v1 -> v2:
  - use a udp specific destrctor to perform memory reclaiming
  - remove a couple of helpers, unneeded after the above cleanup
  - do not reclaim memory on dequeue if not under memory
    pressure
  - reworked the fwd accounting schema to avoid potential
    integer overflow

Acked-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/net/udp.h |   4 ++
 net/ipv4/udp.c    | 108 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 112 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87..18f1e6b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -246,6 +246,9 @@ static inline __be16 udp_flow_src_port(struct net *net, struct sk_buff *skb,
 }
 
 /* net/ipv4/udp.c */
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len);
+int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb);
+
 void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
@@ -258,6 +261,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int udp_init_sock(struct sock *sk);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2..5e79992 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1172,6 +1172,114 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+static void udp_rmem_release(struct sock *sk, int size, int partial)
+{
+	int amt;
+
+	atomic_sub(size, &sk->sk_rmem_alloc);
+
+	spin_lock_bh(&sk->sk_receive_queue.lock);
+	sk->sk_forward_alloc += size;
+	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
+	sk->sk_forward_alloc -= amt;
+	spin_unlock_bh(&sk->sk_receive_queue.lock);
+
+	if (amt)
+		__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
+}
+
+static void udp_rmem_free(struct sk_buff *skb)
+{
+	udp_rmem_release(skb->sk, skb->truesize, 1);
+}
+
+int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
+{
+	struct sk_buff_head *list = &sk->sk_receive_queue;
+	int rmem, delta, amt, err = -ENOMEM;
+	int size = skb->truesize;
+
+	/* try to avoid the costly atomic add/sub pair when the receive
+	 * queue is full; always allow at least a packet
+	 */
+	rmem = atomic_read(&sk->sk_rmem_alloc);
+	if (rmem && (rmem + size > sk->sk_rcvbuf))
+		goto drop;
+
+	/* we drop only if the receive buf is full and the receive
+	 * queue contains some other skb
+	 */
+	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
+	if ((rmem > sk->sk_rcvbuf) && (rmem > size))
+		goto uncharge_drop;
+
+	skb_orphan(skb);
+
+	spin_lock(&list->lock);
+	if (size >= sk->sk_forward_alloc) {
+		amt = sk_mem_pages(size);
+		delta = amt << SK_MEM_QUANTUM_SHIFT;
+		if (!__sk_mem_raise_allocated(sk, delta, amt, SK_MEM_RECV)) {
+			err = -ENOBUFS;
+			spin_unlock(&list->lock);
+			goto uncharge_drop;
+		}
+
+		sk->sk_forward_alloc += delta;
+	}
+
+	sk->sk_forward_alloc -= size;
+
+	/* the skb owner in now the udp socket */
+	skb->sk = sk;
+	skb->destructor = udp_rmem_free;
+	skb->dev = NULL;
+	sock_skb_set_dropcount(sk, skb);
+
+	__skb_queue_tail(list, skb);
+	spin_unlock(&list->lock);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk);
+
+	return 0;
+
+uncharge_drop:
+	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
+
+drop:
+	atomic_inc(&sk->sk_drops);
+	return err;
+}
+EXPORT_SYMBOL_GPL(__udp_enqueue_schedule_skb);
+
+static void udp_destruct_sock(struct sock *sk)
+{
+	/* reclaim completely the forward allocated memory */
+	__skb_queue_purge(&sk->sk_receive_queue);
+	udp_rmem_release(sk, 0, 0);
+	inet_sock_destruct(sk);
+}
+
+int udp_init_sock(struct sock *sk)
+{
+	sk->sk_destruct = udp_destruct_sock;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_init_sock);
+
+void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
+{
+	if (unlikely(READ_ONCE(sk->sk_peek_off) >= 0)) {
+		bool slow = lock_sock_fast(sk);
+
+		sk_peek_offset_bwd(sk, len);
+		unlock_sock_fast(sk, slow);
+	}
+	consume_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_consume_udp);
+
 /**
  *	first_packet_length	- return length of first packet in receive queue
  *	@sk: socket
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
