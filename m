From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH 6/8] af_unix: Deliver message to several recipients in case of multicast
Date: Fri, 21 Jan 2011 14:39:46 +0000
Message-ID: <1295620788-6002-6-git-send-email-alban.crequy@collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Ian Molton <ian.molton@collabora.co.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unix_dgram_sendmsg() implements the delivery both for SOCK_DGRAM and
SOCK_SEQPACKET unix sockets.

The delivery is done in an atomic way; either the message is delivered to all
recipients or none, even in case of interruptions or errors.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Signed-off-by: Ian Molton <ian.molton@collabora.co.uk>
---
 net/unix/af_unix.c |  242 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 242 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fe0d3bb..4147d64 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1715,6 +1715,210 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	return err;
 }
 
+#ifdef CONFIG_UNIX_MULTICAST
+static void kfree_skb_sock_set(struct sock_set *set)
+{
+	int i;
+	for (i = set->offset ; i < set->cnt ; i++) {
+		if (set->items[i].skb) {
+			kfree_skb(set->items[i].skb);
+			set->items[i].skb = NULL;
+		}
+	}
+}
+
+static void unix_mcast_lock(struct unix_mcast_group *group,
+			    struct sock_set *set)
+{
+	int i;
+	for (i = 0 ; i < MCAST_LOCK_CLASS_COUNT ; i++) {
+		if (set->hash & (1 << i))
+			spin_lock_nested(&group->lock[i], i);
+	}
+}
+
+static void unix_mcast_unlock(struct unix_mcast_group *group,
+			      struct sock_set *set)
+{
+	int i;
+	for (i = MCAST_LOCK_CLASS_COUNT - 1 ; i >= 0 ; i--) {
+		if (set->hash & (1 << i))
+			spin_unlock(&group->lock[i]);
+	}
+}
+
+
+static int unix_dgram_sendmsg_multicast(struct sock_iocb *siocb,
+					struct sock *sk,
+					struct sk_buff *skb,
+					struct unix_mcast_group *group,
+					struct sock_set *others_set,
+					size_t len,
+					int max_level,
+					long timeo)
+{
+	int err;
+	int i;
+
+	BUG_ON(!others_set);
+
+restart:
+	for (i = others_set->offset ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
+		unsigned int pkt_len;
+		struct sk_filter *filter;
+
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		BUG_ON(others_set->items[i].skb);
+		BUG_ON(cur == NULL);
+
+		rcu_read_lock();
+		filter = rcu_dereference(cur->sk_filter);
+		if (filter)
+			pkt_len = sk_run_filter(skb, filter->insns);
+		else
+			pkt_len = 0xffffffff;
+		rcu_read_unlock();
+
+		if (pkt_len == 0) {
+			others_set->items[i].to_deliver = 0;
+			continue;
+		}
+
+		others_set->items[i].skb = skb_clone(skb, GFP_KERNEL);
+		if (!others_set->items[i].skb) {
+			kfree_skb_sock_set(others_set);
+			err = -ENOMEM;
+			goto out_free;
+		}
+		skb_set_owner_w(others_set->items[i].skb, sk);
+		err = unix_scm_to_skb(siocb->scm, others_set->items[i].skb,
+				      true);
+		if (err < 0)
+			goto out_free;
+		unix_get_secdata(siocb->scm, others_set->items[i].skb);
+		pskb_trim(others_set->items[i].skb, pkt_len);
+	}
+
+	for (i = others_set->offset ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
+
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		unix_state_lock(cur);
+
+		if (cur->sk_shutdown & RCV_SHUTDOWN) {
+			unix_state_unlock(cur);
+			kfree_skb(others_set->items[i].skb);
+			others_set->items[i].skb = NULL;
+				others_set->items[i].to_deliver = 0;
+				continue;
+		}
+
+		if (sk->sk_type != SOCK_SEQPACKET) {
+			err = security_unix_may_send(sk->sk_socket,
+						     cur->sk_socket);
+			if (err) {
+				unix_state_unlock(cur);
+				kfree_skb(others_set->items[i].skb);
+				others_set->items[i].skb = NULL;
+					others_set->items[i].to_deliver = 0;
+					continue;
+			}
+		}
+
+		if (unix_peer(cur) != sk && unix_recvq_full(cur)) {
+			kfree_skb(others_set->items[i].skb);
+			others_set->items[i].skb = NULL;
+
+			if (others_set->items[i].flags
+					& UNIX_MREQ_DROP_WHEN_FULL) {
+				/* Drop the skbs and continue */
+				unix_state_unlock(cur);
+				others_set->items[i].to_deliver = 0;
+				continue;
+			} else {
+				if (!timeo) {
+					unix_state_unlock(cur);
+					err = -EAGAIN;
+					goto out_free;
+				}
+
+				timeo = unix_wait_for_peer(cur, timeo);
+
+				err = sock_intr_errno(timeo);
+				if (signal_pending(current))
+					goto out_free;
+
+				kfree_skb_sock_set(others_set);
+				goto restart;
+			}
+		}
+		unix_state_unlock(cur);
+	}
+
+	unix_mcast_lock(group, others_set);
+	for (i = others_set->offset ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
+
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		BUG_ON(cur == NULL);
+		BUG_ON(others_set->items[i].skb == NULL);
+
+		unix_state_lock(cur);
+
+		if (sock_flag(cur, SOCK_DEAD)) {
+			unix_state_unlock(cur);
+
+			kfree_skb(others_set->items[i].skb);
+			others_set->items[i].skb = NULL;
+			others_set->items[i].to_deliver = 0;
+			continue;
+		}
+
+		if (sock_flag(cur, SOCK_RCVTSTAMP))
+			__net_timestamp(others_set->items[i].skb);
+
+		skb_queue_tail(&cur->sk_receive_queue,
+			       others_set->items[i].skb);
+		others_set->items[i].skb = NULL;
+		if (max_level > unix_sk(cur)->recursion_level)
+			unix_sk(cur)->recursion_level = max_level;
+
+		unix_state_unlock(cur);
+	}
+	unix_mcast_unlock(group, others_set);
+
+	for (i = others_set->offset ; i < others_set->cnt ; i++) {
+		struct sock *cur = others_set->items[i].s;
+
+		if (!others_set->items[i].to_deliver)
+			continue;
+
+		cur->sk_data_ready(cur, len);
+	}
+
+	kfree_skb(skb);
+	scm_destroy(siocb->scm);
+	up_sock_set(others_set);
+	return len;
+
+out_free:
+	kfree_skb(skb);
+	if (others_set) {
+		kfree_skb_sock_set(others_set);
+		up_sock_set(others_set);
+	}
+	return err;
+}
+#endif
+
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1735,6 +1939,10 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	long timeo;
 	struct scm_cookie tmp_scm;
 	int max_level;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct unix_mcast_group *group = NULL;
+	struct sock_set *others_set = NULL;
+#endif
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1756,8 +1964,20 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sunaddr = NULL;
 		err = -ENOTCONN;
 		other = unix_peer_get(sk);
+
 		if (!other)
 			goto out;
+
+#ifdef CONFIG_UNIX_MULTICAST
+		group = unix_sk(other)->mcast_group;
+		if (group) {
+			others_set = unix_find_multicast_recipients(sk,
+				group, &err);
+
+			if (!others_set)
+				goto out;
+		}
+#endif
 	}
 
 	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
@@ -1795,6 +2015,28 @@ restart:
 					hash, &err);
 		if (other == NULL)
 			goto out_free;
+
+#ifdef CONFIG_UNIX_MULTICAST
+		group = unix_sk(other)->mcast_group;
+		if (group) {
+			others_set = unix_find_multicast_recipients(sk,
+				group, &err);
+
+			sock_put(other);
+			other = NULL;
+
+			if (!others_set)
+				goto out;
+		}
+	}
+
+	if (group) {
+		err = unix_dgram_sendmsg_multicast(siocb, sk, skb, group,
+			others_set, len, max_level, timeo);
+		if (err < 0)
+			goto out;
+		return err;
+#endif
 	}
 
 	if (sk_filter(other, skb) < 0) {
-- 
1.7.2.3
