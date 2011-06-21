From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 02:53:34 -0700 (PDT)
Message-ID: <20110621.025334.547463578193934724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756208Ab1FUJxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 05:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adds demuxing support for AF_PACKET sockets.  It's just to give
people an idea, I've only build tested this patch.

Basically it allows to spread the AF_PACKET processing load amongst
several AF_PACKET sockets.  The distribution can either be based upon
hashing (PACKET_FANOUT_HASH) or round-robin based load-balancing
(PACKET_FANOUT_LB).

The hash based fanout takes advantage of the precomputed skb->rxhash
and only costs ~20 cpu cycles.

A restriction is that you must bind the AF_PACKET socket fully before
you add it to a fanout.

The encoding of the PACKET_FANOUT socket option argument is:

	(PACKET_FANOUT_{HASH,LB} << 16) | (ID & 0xffff)

All sockets adding themselves to the same fanout ID must all use
the same PACKET_FANOUT_* type and also must be bound to the same
device/protocol.

The implementation is agnostic to the type of AF_PACKET sockets in
use.  You can use mmap based, and non-mmap based, AF_PACKET sockets.
It simply doesn't care.

Signed-off-by: David S. Miller <davem@davemloft.net>

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
index 461b16f..e6af2eb 100644
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
@@ -212,6 +214,22 @@ struct packet_sock {
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
+#define PACKET_FANOUT_MAX	2048
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
+	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
+};
+
 struct packet_skb_cb {
 	unsigned int origlen;
 	union {
@@ -344,6 +362,164 @@ static void packet_sock_destruct(struct sock *sk)
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
+	u32 idx = ((u64)skb->rxhash * f->num_members) >> 32;
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
+	mutex_lock(&fanout_mutex);
+	match = NULL;
+	list_for_each_entry(f, &fanout_list, list) {
+		if (f->id == id) {
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
+		}
+	}
+	err = -ENOMEM;
+	if (match) {
+		err = -EINVAL;
+		if (match->type == type) {
+			err = -ENOSPC;
+			if (match->num_members < PACKET_FANOUT_MAX) {
+				__dev_remove_pack(&po->prot_hook);
+				po->fanout = match;
+				match->arr[match->num_members] = sk;
+				smp_wmb();
+				match->num_members++;
+				err = 0;
+			}
+		}
+	}
+	mutex_unlock(&fanout_mutex);
+	return err;
+}
+
+static void fanout_del(struct sock *sk)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	struct packet_fanout *f;
+	int i;
+
+	f = po->fanout;
+	po->fanout = NULL;
+
+	mutex_lock(&fanout_mutex);
+	for (i = 0; i < f->num_members; i++) {
+		if (f->arr[i] == sk)
+			break;
+	}
+	BUG_ON(i >= f->num_members);
+	f->arr[i] = f->arr[f->num_members - 1];
+	f->num_members--;
+
+	if (!f->num_members) {
+		list_del(&f->list);
+		dev_remove_pack(&f->prot_hook);
+		kfree(f);
+	}
+	mutex_unlock(&fanout_mutex);
+}
 
 static const struct proto_ops packet_ops;
 
@@ -1343,7 +1519,10 @@ static int packet_release(struct socket *sock)
 		 */
 		po->running = 0;
 		po->num = 0;
-		__dev_remove_pack(&po->prot_hook);
+		if (po->fanout)
+			fanout_del(sk);
+		else
+			__dev_remove_pack(&po->prot_hook);
 		__sock_put(sk);
 	}
 	if (po->prot_hook.dev) {
@@ -1396,9 +1575,11 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 		__sock_put(sk);
 		po->running = 0;
 		po->num = 0;
-		spin_unlock(&po->bind_lock);
-		dev_remove_pack(&po->prot_hook);
-		spin_lock(&po->bind_lock);
+		if (!po->fanout) {
+			spin_unlock(&po->bind_lock);
+			dev_remove_pack(&po->prot_hook);
+			spin_lock(&po->bind_lock);
+		}
 	}
 
 	po->num = protocol;
@@ -1413,7 +1594,8 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 		goto out_unlock;
 
 	if (!dev || (dev->flags & IFF_UP)) {
-		dev_add_pack(&po->prot_hook);
+		if (!po->fanout)
+			dev_add_pack(&po->prot_hook);
 		sock_hold(sk);
 		po->running = 1;
 	} else {
@@ -1542,7 +1724,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	if (proto) {
 		po->prot_hook.type = proto;
-		dev_add_pack(&po->prot_hook);
+		if (!po->fanout)
+			dev_add_pack(&po->prot_hook);
 		sock_hold(sk);
 		po->running = 1;
 	}
@@ -2109,6 +2292,17 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
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
@@ -2207,6 +2401,15 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
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
@@ -2260,7 +2463,8 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 			if (dev->ifindex == po->ifindex) {
 				spin_lock(&po->bind_lock);
 				if (po->num && !po->running) {
-					dev_add_pack(&po->prot_hook);
+					if (!po->fanout)
+						dev_add_pack(&po->prot_hook);
 					sock_hold(sk);
 					po->running = 1;
 				}
@@ -2530,7 +2734,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 	was_running = po->running;
 	num = po->num;
 	if (was_running) {
-		__dev_remove_pack(&po->prot_hook);
+		if (!po->fanout)
+			__dev_remove_pack(&po->prot_hook);
 		po->num = 0;
 		po->running = 0;
 		__sock_put(sk);
@@ -2568,7 +2773,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		sock_hold(sk);
 		po->running = 1;
 		po->num = num;
-		dev_add_pack(&po->prot_hook);
+		if (!po->fanout)
+			dev_add_pack(&po->prot_hook);
 	}
 	spin_unlock(&po->bind_lock);
 
