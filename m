From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] packet: use percpu mmap tx frame pending refcount
Date: Sun, 12 Jan 2014 17:22:48 +0100
Message-ID: <1389543768-20234-4-git-send-email-dborkman@redhat.com>
References: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaALQW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 11:22:57 -0500
In-Reply-To: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In PF_PACKET's packet mmap(), we can avoid using one atomic_inc()
and one atomic_dec() call in skb destructor and use a percpu
reference count instead in order to determine if packets are
still pending to be sent out. Micro-benchmark with [1] that has
been slightly modified (that is, protcol = 0 in socket(2) and
bind(2)), example on an i7-3520M machine:

./packet_mm_tx -s7000 -m7200 -z700000 em1, avg over 2500 runs:

With patch:    4,022,015 cyc
Without patch: 4,812,994 cyc

time ./packet_mm_tx -s64 -c10000000 em1 > /dev/null, stable:

With patch:
  real         1m32.241s
  user         0m0.287s
  sys          1m29.316s

Without patch:
  real         1m38.386s
  user         0m0.265s
  sys          1m35.572s

In function tpacket_snd(), it is okay to use packet_read_pending()
since in fast-path we short-circuit the condition already with
ph != NULL, since we have next frames to process.

In case we have MSG_DONTWAIT, we also do not execute this path as
need_wait is false here anyway, and in case of _no_ MSG_DONTWAIT
flag, it is okay to call a packet_read_pending(), because when
we ever reach that path, we're done processing frames anyway and
only look if there are skbs still outstanding to be orphaned.

The BUG_ON() in tpacket_destruct_skb() we can remove as well. It
can _only_ be set from inside tpacket_snd() path and we made
sure to increase tx_ring.pending in any case before we called
po->xmit(skb). So testing for tx_ring.pending == 0 is not too
useful. Instead, it would rather have been useful to test if
lower layers didn't orphan the skb so that we're missing ring
slots being put back to TP_STATUS_AVAILABLE. But such a bug will
be caught in user space already as we end up realizing that we do
not have any TP_STATUS_AVAILABLE slots left anymore. Therefore,
we're all set.

Btw, in case of RX_RING path, we do not make use of the pending
member, therefore we also don't need to use up any percpu memory
here.

  [1] http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 65 +++++++++++++++++++++++++++++++++++++++++++++-----
 net/packet/diag.c      |  1 +
 net/packet/internal.h  |  2 +-
 3 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d5495d8..6803be98 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -89,6 +89,7 @@
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
 #include <linux/reciprocal_div.h>
+#include <linux/percpu.h>
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
 #endif
@@ -1168,6 +1169,46 @@ static void packet_increment_head(struct packet_ring_buffer *buff)
 	buff->head = buff->head != buff->frame_max ? buff->head+1 : 0;
 }
 
+static void packet_inc_pending(struct packet_ring_buffer *rb)
+{
+	this_cpu_inc(*rb->pending_refcnt);
+}
+
+static void packet_dec_pending(struct packet_ring_buffer *rb)
+{
+	this_cpu_dec(*rb->pending_refcnt);
+}
+
+static int packet_read_pending(const struct packet_ring_buffer *rb)
+{
+	int i, refcnt = 0;
+
+	/* We don't use pending refcount in rx_ring. */
+	if (rb->pending_refcnt == NULL)
+		return 0;
+
+	for_each_possible_cpu(i)
+		refcnt += *per_cpu_ptr(rb->pending_refcnt, i);
+
+	return refcnt;
+}
+
+static int packet_alloc_pending(struct packet_sock *po)
+{
+	po->rx_ring.pending_refcnt = NULL;
+
+	po->tx_ring.pending_refcnt = alloc_percpu(int);
+	if (unlikely(po->tx_ring.pending_refcnt == NULL))
+		return -ENOBUFS;
+
+	return 0;
+}
+
+static void packet_free_pending(struct packet_sock *po)
+{
+	free_percpu(po->tx_ring.pending_refcnt);
+}
+
 static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 {
 	struct sock *sk = &po->sk;
@@ -2014,8 +2055,7 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 		__u32 ts;
 
 		ph = skb_shinfo(skb)->destructor_arg;
-		BUG_ON(atomic_read(&po->tx_ring.pending) == 0);
-		atomic_dec(&po->tx_ring.pending);
+		packet_dec_pending(&po->tx_ring);
 
 		ts = __packet_set_timestamp(po, ph, skb);
 		__packet_set_status(po, ph, TP_STATUS_AVAILABLE | ts);
@@ -2236,7 +2276,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		skb_set_queue_mapping(skb, packet_pick_tx_queue(dev));
 		skb->destructor = tpacket_destruct_skb;
 		__packet_set_status(po, ph, TP_STATUS_SENDING);
-		atomic_inc(&po->tx_ring.pending);
+		packet_inc_pending(&po->tx_ring);
 
 		status = TP_STATUS_SEND_REQUEST;
 		err = po->xmit(skb);
@@ -2256,8 +2296,14 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		}
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
-	} while (likely((ph != NULL) || (need_wait &&
-					 atomic_read(&po->tx_ring.pending))));
+	} while (likely((ph != NULL) ||
+		/* Note: packet_read_pending() might be slow if we have
+		 * to call it as it's per_cpu variable, but in fast-path
+		 * we already short-circuit the loop with the first
+		 * condition, and luckily don't have to go that path
+		 * anyway.
+		 */
+		 (need_wait && packet_read_pending(&po->tx_ring))));
 
 	err = len_sum;
 	goto out_put;
@@ -2556,6 +2602,7 @@ static int packet_release(struct socket *sock)
 	/* Purge queues */
 
 	skb_queue_purge(&sk->sk_receive_queue);
+	packet_free_pending(po);
 	sk_refcnt_debug_release(sk);
 
 	sock_put(sk);
@@ -2717,6 +2764,10 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	po->num = proto;
 	po->xmit = dev_queue_xmit;
 
+	err = packet_alloc_pending(po);
+	if (err)
+		goto out2;
+
 	packet_cached_dev_reset(po);
 
 	sk->sk_destruct = packet_sock_destruct;
@@ -2749,6 +2800,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	preempt_enable();
 
 	return 0;
+out2:
+	sk_free(sk);
 out:
 	return err;
 }
@@ -3676,7 +3729,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 	if (!closing) {
 		if (atomic_read(&po->mapped))
 			goto out;
-		if (atomic_read(&rb->pending))
+		if (packet_read_pending(rb))
 			goto out;
 	}
 
diff --git a/net/packet/diag.c b/net/packet/diag.c
index a9584a2..533ce4f 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -3,6 +3,7 @@
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/packet_diag.h>
+#include <linux/percpu.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 0a87d7b..a47d5b5 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -64,7 +64,7 @@ struct packet_ring_buffer {
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
 
-	atomic_t		pending;
+	int __percpu		*pending_refcnt;
 
 	struct tpacket_kbdq_core	prb_bdqc;
 };
-- 
1.7.11.7
