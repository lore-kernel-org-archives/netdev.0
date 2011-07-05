From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 2/4] packet: Add fanout support.
Date: Tue, 05 Jul 2011 02:04:19 -0700 (PDT)
Message-ID: <20110705.020419.1998951566353182397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: victor@inliniac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab1GEJEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:04:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
sockets.  Two fanout policies are implemented:

1) Hashing based upon skb->rxhash

2) Pure round-robin

An AF_PACKET socket must be fully bound before it tries to add itself
to a fanout.  All AF_PACKET sockets trying to join the same fanout
must all have the same bind settings.

Fanouts are identified (within a network namespace) by a 16-bit ID.
The first socket to try to add itself to a fanout with a particular
ID, creates that fanout.  When the last socket leaves the fanout
(which happens only when the socket is closed), that fanout is
destroyed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/if_packet.h |    4 +
 net/packet/af_packet.c    |  252 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 251 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 7b31863..1efa1cb 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -49,6 +49,10 @@ struct sockaddr_ll {
 #define PACKET_VNET_HDR			15
 #define PACKET_TX_TIMESTAMP		16
 #define PACKET_TIMESTAMP		17
+#define PACKET_FANOUT			18
+
+#define PACKET_FANOUT_HASH		0
+#define PACKET_FANOUT_LB		1
 
 struct tpacket_stats {
 	unsigned int	tp_packets;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bb281bf..696d19c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -187,9 +187,11 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 
 static void packet_flush_mclist(struct sock *sk);
 
+struct packet_fanout;
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
+	struct packet_fanout	*fanout;
 	struct tpacket_stats	stats;
 	struct packet_ring_buffer	rx_ring;
 	struct packet_ring_buffer	tx_ring;
@@ -212,6 +214,24 @@ struct packet_sock {
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
+#define PACKET_FANOUT_MAX	256
+
+struct packet_fanout {
+#ifdef CONFIG_NET_NS
+	struct net		*net;
+#endif
+	int			num_members;
+	u16			id;
+	u8			type;
+	u8			pad;
+	atomic_t		rr_cur;
+	struct list_head	list;
+	struct sock		*arr[PACKET_FANOUT_MAX];
+	spinlock_t		lock;
+	atomic_t		sk_ref;
+	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
+};
+
 struct packet_skb_cb {
 	unsigned int origlen;
 	union {
@@ -227,6 +247,9 @@ static inline struct packet_sock *pkt_sk(struct sock *sk)
 	return (struct packet_sock *)sk;
 }
 
+static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
+static void __fanout_link(struct sock *sk, struct packet_sock *po);
+
 /* register_prot_hook must be invoked with the po->bind_lock held,
  * or from a context in which asynchronous accesses to the packet
  * socket is not possible (packet_create()).
@@ -235,7 +258,10 @@ static void register_prot_hook(struct sock *sk)
 {
 	struct packet_sock *po = pkt_sk(sk);
 	if (!po->running) {
-		dev_add_pack(&po->prot_hook);
+		if (po->fanout)
+			__fanout_link(sk, po);
+		else
+			dev_add_pack(&po->prot_hook);
 		sock_hold(sk);
 		po->running = 1;
 	}
@@ -253,7 +279,10 @@ static void __unregister_prot_hook(struct sock *sk, bool sync)
 	struct packet_sock *po = pkt_sk(sk);
 
 	po->running = 0;
-	__dev_remove_pack(&po->prot_hook);
+	if (po->fanout)
+		__fanout_unlink(sk, po);
+	else
+		__dev_remove_pack(&po->prot_hook);
 	__sock_put(sk);
 
 	if (sync) {
@@ -388,6 +417,197 @@ static void packet_sock_destruct(struct sock *sk)
 	sk_refcnt_debug_dec(sk);
 }
 
+static int fanout_rr_next(struct packet_fanout *f)
+{
+	int x = atomic_read(&f->rr_cur) + 1;
+
+	if (x >= f->num_members)
+		x = 0;
+
+	return x;
+}
+
+static struct sock *fanout_demux_hash(struct packet_fanout *f, struct sk_buff *skb)
+{
+	u32 idx, hash = skb->rxhash;
+
+	idx = ((u64)hash * f->num_members) >> 32;
+
+	return f->arr[idx];
+}
+
+static struct sock *fanout_demux_lb(struct packet_fanout *f, struct sk_buff *skb)
+{
+	int cur, old;
+
+	cur = atomic_read(&f->rr_cur);
+	while ((old = atomic_cmpxchg(&f->rr_cur, cur,
+				     fanout_rr_next(f))) != cur)
+		cur = old;
+	return f->arr[cur];
+}
+
+static int packet_rcv_fanout_hash(struct sk_buff *skb, struct net_device *dev,
+				  struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct packet_fanout *f = pt->af_packet_priv;
+	struct packet_sock *po;
+	struct sock *sk;
+
+	if (!net_eq(dev_net(dev), read_pnet(&f->net))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	skb_get_rxhash(skb);
+
+	sk = fanout_demux_hash(f, skb);
+	po = pkt_sk(sk);
+
+	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
+}
+
+static int packet_rcv_fanout_lb(struct sk_buff *skb, struct net_device *dev,
+				struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct packet_fanout *f = pt->af_packet_priv;
+	struct packet_sock *po;
+	struct sock *sk;
+
+	if (!net_eq(dev_net(dev), read_pnet(&f->net))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	sk = fanout_demux_lb(f, skb);
+	po = pkt_sk(sk);
+
+	return po->prot_hook.func(skb, dev, &po->prot_hook, orig_dev);
+}
+
+static DEFINE_MUTEX(fanout_mutex);
+static LIST_HEAD(fanout_list);
+
+static void __fanout_link(struct sock *sk, struct packet_sock *po)
+{
+	struct packet_fanout *f = po->fanout;
+
+	spin_lock(&f->lock);
+	f->arr[f->num_members] = sk;
+	smp_wmb();
+	f->num_members++;
+	spin_unlock(&f->lock);
+}
+
+static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
+{
+	struct packet_fanout *f = po->fanout;
+	int i;
+
+	spin_unlock(&f->lock);
+	for (i = 0; i < f->num_members; i++) {
+		if (f->arr[i] == sk)
+			break;
+	}
+	BUG_ON(i >= f->num_members);
+	f->arr[i] = f->arr[f->num_members - 1];
+	f->num_members--;
+	spin_unlock(&f->lock);
+}
+
+static int fanout_add(struct sock *sk, u16 id, u8 type)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_fanout *f, *match;
+	int err;
+
+	switch (type) {
+	case PACKET_FANOUT_HASH:
+	case PACKET_FANOUT_LB:
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (!po->running)
+		return -EINVAL;
+
+	if (po->fanout)
+		return -EALREADY;
+
+	mutex_lock(&fanout_mutex);
+	match = NULL;
+	list_for_each_entry(f, &fanout_list, list) {
+		if (f->id == id &&
+		    read_pnet(&f->net) == sock_net(sk)) {
+			match = f;
+			break;
+		}
+	}
+	if (!match) {
+		match = kzalloc(sizeof(*match), GFP_KERNEL);
+		if (match) {
+			write_pnet(&match->net, sock_net(sk));
+			match->id = id;
+			match->type = type;
+			atomic_set(&match->rr_cur, 0);
+			INIT_LIST_HEAD(&match->list);
+			spin_lock_init(&match->lock);
+			atomic_set(&match->sk_ref, 0);
+			match->prot_hook.type = po->prot_hook.type;
+			match->prot_hook.dev = po->prot_hook.dev;
+			switch (type) {
+			case PACKET_FANOUT_HASH:
+				match->prot_hook.func = packet_rcv_fanout_hash;
+				break;
+			case PACKET_FANOUT_LB:
+				match->prot_hook.func = packet_rcv_fanout_lb;
+				break;
+			}
+			match->prot_hook.af_packet_priv = match;
+			dev_add_pack(&match->prot_hook);
+			list_add(&match->list, &fanout_list);
+		}
+	}
+	err = -ENOMEM;
+	if (match) {
+		err = -EINVAL;
+		if (match->type == type &&
+		    match->prot_hook.type == po->prot_hook.type &&
+		    match->prot_hook.dev == po->prot_hook.dev) {
+			err = -ENOSPC;
+			if (atomic_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
+				__dev_remove_pack(&po->prot_hook);
+				po->fanout = match;
+				atomic_inc(&match->sk_ref);
+				__fanout_link(sk, po);
+				err = 0;
+			}
+		}
+	}
+	mutex_unlock(&fanout_mutex);
+	return err;
+}
+
+static void fanout_release(struct sock *sk)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_fanout *f;
+
+	f = po->fanout;
+	if (!f)
+		return;
+
+	po->fanout = NULL;
+
+	mutex_lock(&fanout_mutex);
+	if (atomic_dec_and_test(&f->sk_ref)) {
+		list_del(&f->list);
+		dev_remove_pack(&f->prot_hook);
+		kfree(f);
+	}
+	mutex_unlock(&fanout_mutex);
+}
 
 static const struct proto_ops packet_ops;
 
@@ -1398,6 +1618,8 @@ static int packet_release(struct socket *sock)
 	if (po->tx_ring.pg_vec)
 		packet_set_ring(sk, &req, 1, 1);
 
+	fanout_release(sk);
+
 	synchronize_net();
 	/*
 	 *	Now the socket is dead. No more input will appear.
@@ -1421,9 +1643,9 @@ static int packet_release(struct socket *sock)
 static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protocol)
 {
 	struct packet_sock *po = pkt_sk(sk);
-	/*
-	 *	Detach an existing hook if present.
-	 */
+
+	if (po->fanout)
+		return -EINVAL;
 
 	lock_sock(sk);
 
@@ -2133,6 +2355,17 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->tp_tstamp = val;
 		return 0;
 	}
+	case PACKET_FANOUT:
+	{
+		int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		return fanout_add(sk, val & 0xffff, val >> 16);
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -2231,6 +2464,15 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		val = po->tp_tstamp;
 		data = &val;
 		break;
+	case PACKET_FANOUT:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = (po->fanout ?
+		       ((u32)po->fanout->id |
+			((u32)po->fanout->type << 16)) :
+		       0);
+		data = &val;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.7.5.4

