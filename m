From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 2/7] packet: rollover prepare: per-socket state
Date: Wed,  6 May 2015 14:27:12 -0400
Message-ID: <1430936837-22655-3-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:35956 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbEFS1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:23 -0400
Received: by yhrr66 with SMTP id r66so4709149yhr.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:22 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Replace rollover state per fanout group with state per socket. Future
patches will add fields to the new structure.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 21 ++++++++++++++++++---
 net/packet/internal.h  |  6 +++++-
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 56f9c52..f8ec909 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1321,16 +1321,18 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 					  unsigned int idx, bool try_self,
 					  unsigned int num)
 {
+	struct packet_sock *po;
 	unsigned int i, j;
 
-	if (try_self && packet_rcv_has_room(pkt_sk(f->arr[idx]), skb))
+	po = pkt_sk(f->arr[idx]);
+	if (try_self && packet_rcv_has_room(po, skb))
 		return idx;
 
-	i = j = min_t(int, f->next[idx], num - 1);
+	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
 		if (i != idx && packet_rcv_has_room(pkt_sk(f->arr[i]), skb)) {
 			if (i != j)
-				f->next[idx] = i;
+				po->rollover->sock = i;
 			return i;
 		}
 
@@ -1468,6 +1470,12 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	if (po->fanout)
 		return -EALREADY;
 
+	if (type_flags & PACKET_FANOUT_FLAG_ROLLOVER) {
+		po->rollover = kzalloc(sizeof(*po->rollover), GFP_KERNEL);
+		if (!po->rollover)
+			return -ENOMEM;
+	}
+
 	mutex_lock(&fanout_mutex);
 	match = NULL;
 	list_for_each_entry(f, &fanout_list, list) {
@@ -1516,6 +1524,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	}
 out:
 	mutex_unlock(&fanout_mutex);
+	if (err) {
+		kfree(po->rollover);
+		po->rollover = NULL;
+	}
 	return err;
 }
 
@@ -1537,6 +1549,8 @@ static void fanout_release(struct sock *sk)
 		kfree(f);
 	}
 	mutex_unlock(&fanout_mutex);
+
+	kfree(po->rollover);
 }
 
 static const struct proto_ops packet_ops;
@@ -2863,6 +2877,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	spin_lock_init(&po->bind_lock);
 	mutex_init(&po->pg_vec_lock);
+	po->rollover = NULL;
 	po->prot_hook.func = packet_rcv;
 
 	if (sock->type == SOCK_PACKET)
diff --git a/net/packet/internal.h b/net/packet/internal.h
index fe6e20c..a9d33a2 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -82,12 +82,15 @@ struct packet_fanout {
 	atomic_t		rr_cur;
 	struct list_head	list;
 	struct sock		*arr[PACKET_FANOUT_MAX];
-	int			next[PACKET_FANOUT_MAX];
 	spinlock_t		lock;
 	atomic_t		sk_ref;
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
+struct packet_rollover {
+	int			sock;
+} ____cacheline_aligned_in_smp;
+
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
@@ -104,6 +107,7 @@ struct packet_sock {
 				has_vnet_hdr:1;
 	int			ifindex;	/* bound device		*/
 	__be16			num;
+	struct packet_rollover	*rollover;
 	struct packet_mclist	*mclist;
 	atomic_t		mapped;
 	enum tpacket_versions	tp_version;
-- 
2.2.0.rc0.207.ga3a616c
