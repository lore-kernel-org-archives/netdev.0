From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 1/4] packet: add BPF fanout mode
Date: Fri, 14 Aug 2015 11:50:24 -0400
Message-ID: <1439567427-19504-2-git-send-email-willemb@google.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33178 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbbHNPuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 11:50:35 -0400
Received: by qkfj126 with SMTP id j126so26883854qkf.0
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 08:50:34 -0700 (PDT)
In-Reply-To: <1439567427-19504-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add a fanout mode that accepts a BPF program to select a socket.

This avoids having to keep adding special case fanout modes. One
example use case is application layer load balancing. The QUIC
protocol, for instance, encodes a connection ID in UDP payload.

Also add socket option SOL_PACKET/PACKET_FANOUT_DATA that updates data
associated with the socket group. Fanout mode PACKET_FANOUT_BPF is the
only user so far.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/if_packet.h |  2 +
 net/packet/af_packet.c         | 97 +++++++++++++++++++++++++++++++++++++++++-
 net/packet/internal.h          |  5 ++-
 3 files changed, 102 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index d3d715f8c..d41280a 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -55,6 +55,7 @@ struct sockaddr_ll {
 #define PACKET_TX_HAS_OFF		19
 #define PACKET_QDISC_BYPASS		20
 #define PACKET_ROLLOVER_STATS		21
+#define PACKET_FANOUT_DATA		22
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
@@ -62,6 +63,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT_ROLLOVER		3
 #define PACKET_FANOUT_RND		4
 #define PACKET_FANOUT_QM		5
+#define PACKET_FANOUT_BPF		6
 #define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
 #define PACKET_FANOUT_FLAG_DEFRAG	0x8000
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5afe53..80d68c9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -92,6 +92,7 @@
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
 #endif
+#include <linux/bpf.h>
 
 #include "internal.h"
 
@@ -1410,6 +1411,22 @@ static unsigned int fanout_demux_qm(struct packet_fanout *f,
 	return skb_get_queue_mapping(skb) % num;
 }
 
+static unsigned int fanout_demux_bpf(struct packet_fanout *f,
+				     struct sk_buff *skb,
+				     unsigned int num)
+{
+	struct bpf_prog *prog;
+	unsigned int ret = 0;
+
+	rcu_read_lock();
+	prog = rcu_dereference(f->bpf_prog);
+	if (prog)
+		ret = BPF_PROG_RUN(prog, skb) % num;
+	rcu_read_unlock();
+
+	return ret;
+}
+
 static bool fanout_has_flag(struct packet_fanout *f, u16 flag)
 {
 	return f->flags & (flag >> 8);
@@ -1454,6 +1471,9 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	case PACKET_FANOUT_ROLLOVER:
 		idx = fanout_demux_rollover(f, skb, 0, false, num);
 		break;
+	case PACKET_FANOUT_BPF:
+		idx = fanout_demux_bpf(f, skb, num);
+		break;
 	}
 
 	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_ROLLOVER))
@@ -1502,6 +1522,72 @@ static bool match_fanout_group(struct packet_type *ptype, struct sock *sk)
 	return false;
 }
 
+static void fanout_init_data(struct packet_fanout *f)
+{
+	switch (f->type) {
+	case PACKET_FANOUT_LB:
+		atomic_set(&f->rr_cur, 0);
+		break;
+	case PACKET_FANOUT_BPF:
+		RCU_INIT_POINTER(f->bpf_prog, NULL);
+		break;
+	}
+}
+
+static void __fanout_set_data_bpf(struct packet_fanout *f, struct bpf_prog *new)
+{
+	struct bpf_prog *old;
+
+	spin_lock(&f->lock);
+	old = rcu_dereference_protected(f->bpf_prog, lockdep_is_held(&f->lock));
+	rcu_assign_pointer(f->bpf_prog, new);
+	spin_unlock(&f->lock);
+
+	if (old) {
+		synchronize_net();
+		bpf_prog_destroy(old);
+	}
+}
+
+static int fanout_set_data_bpf(struct packet_fanout *f, char __user *data,
+			       unsigned int len)
+{
+	struct bpf_prog *new;
+	struct sock_fprog fprog;
+	int ret;
+
+	if (len != sizeof(fprog))
+		return -EINVAL;
+	if (copy_from_user(&fprog, data, len))
+		return -EFAULT;
+
+	ret = bpf_prog_create_from_user(&new, &fprog, NULL);
+	if (ret)
+		return ret;
+
+	__fanout_set_data_bpf(f, new);
+	return 0;
+}
+
+static int fanout_set_data(struct packet_fanout *f, char __user *data,
+			   unsigned int len)
+{
+	switch (f->type) {
+	case PACKET_FANOUT_BPF:
+		return fanout_set_data_bpf(f, data, len);
+	default:
+		return -EINVAL;
+	};
+}
+
+static void fanout_release_data(struct packet_fanout *f)
+{
+	switch (f->type) {
+	case PACKET_FANOUT_BPF:
+		__fanout_set_data_bpf(f, NULL);
+	};
+}
+
 static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 {
 	struct packet_sock *po = pkt_sk(sk);
@@ -1519,6 +1605,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	case PACKET_FANOUT_CPU:
 	case PACKET_FANOUT_RND:
 	case PACKET_FANOUT_QM:
+	case PACKET_FANOUT_BPF:
 		break;
 	default:
 		return -EINVAL;
@@ -1561,10 +1648,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->id = id;
 		match->type = type;
 		match->flags = flags;
-		atomic_set(&match->rr_cur, 0);
 		INIT_LIST_HEAD(&match->list);
 		spin_lock_init(&match->lock);
 		atomic_set(&match->sk_ref, 0);
+		fanout_init_data(match);
 		match->prot_hook.type = po->prot_hook.type;
 		match->prot_hook.dev = po->prot_hook.dev;
 		match->prot_hook.func = packet_rcv_fanout;
@@ -1610,6 +1697,7 @@ static void fanout_release(struct sock *sk)
 	if (atomic_dec_and_test(&f->sk_ref)) {
 		list_del(&f->list);
 		dev_remove_pack(&f->prot_hook);
+		fanout_release_data(f);
 		kfree(f);
 	}
 	mutex_unlock(&fanout_mutex);
@@ -3529,6 +3617,13 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 
 		return fanout_add(sk, val & 0xffff, val >> 16);
 	}
+	case PACKET_FANOUT_DATA:
+	{
+		if (!po->fanout)
+			return -EINVAL;
+
+		return fanout_set_data(po->fanout, optval, optlen);
+	}
 	case PACKET_TX_HAS_OFF:
 	{
 		unsigned int val;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index e20b3e8..9ee4631 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -79,7 +79,10 @@ struct packet_fanout {
 	u16			id;
 	u8			type;
 	u8			flags;
-	atomic_t		rr_cur;
+	union {
+		atomic_t		rr_cur;
+		struct bpf_prog __rcu	*bpf_prog;
+	};
 	struct list_head	list;
 	struct sock		*arr[PACKET_FANOUT_MAX];
 	spinlock_t		lock;
-- 
2.5.0.276.gf5e568e
