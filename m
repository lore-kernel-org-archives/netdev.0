From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 10/10] af_unix: Add a peer BPF for multicast Unix sockets
Date: Mon, 20 Feb 2012 17:33:49 +0100
Message-ID: <1329755629-10644-7-git-send-email-javier@collabora.co.uk>
References: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329755629-10644-1-git-send-email-javier@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multicast Unix domain sockets has an UNIX_ATTACH_FILTER setsockopt() operation
to attach a Berkeley Packet Filter to a remote peer.

This remote peer socket filter has to be a separate filter than the local one.
So the peer cannot replace it.

If local and peer filters are attached, both should be executed. First the peer
BPF and then the local one. Filters can have state and this shouldn't be
accesible to local filters.

Signed-off-by: Javier Martinez Canillas <javier@collabora.co.uk>
---
 include/linux/filter.h |    4 ++
 include/net/af_unix.h  |    1 +
 include/net/sock.h     |    4 ++
 net/core/filter.c      |  118 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/unix/af_unix.c     |   70 +++++++++++++++++++++++++---
 5 files changed, 189 insertions(+), 8 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8eeb205..1af808a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -155,6 +155,10 @@ extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
+#ifdef CONFIG_UNIX_MULTICAST
+extern int sk_attach_peer_filter(struct sock_fprog *fprog, struct sock *sk);
+extern int sk_detach_peer_filter(struct sock *sk);
+#endif
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 
 #ifdef CONFIG_BPF_JIT
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 80e793d..307852c 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -49,6 +49,7 @@ struct unix_skb_parms {
 #define UNIX_JOIN_GROUP		2
 #define UNIX_LEAVE_GROUP	3
 #define UNIX_ACCEPT_GROUP	4
+#define UNIX_ATTACH_FILTER	5
 
 /* Flags on unix_mreq */
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 91c1c8b..e502107 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -237,6 +237,7 @@ struct cg_proto;
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
   *	@sk_filter: socket filtering instructions
+  *     @sk_peer_filter: peer socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
@@ -303,6 +304,9 @@ struct sock {
 	int			sk_rcvbuf;
 
 	struct sk_filter __rcu	*sk_filter;
+#ifdef CONFIG_UNIX_MULTICAST
+	struct sk_filter __rcu	*sk_peer_filter;
+#endif
 	struct socket_wq __rcu	*sk_wq;
 
 #ifdef CONFIG_NET_DMA
diff --git a/net/core/filter.c b/net/core/filter.c
index 5dea452..5dd0890 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -587,6 +587,122 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
 
+#ifdef CONFIG_UNIX_MULTICAST
+
+int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk, bool local)
+{
+	struct sk_filter *fp, *old_fp;
+	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
+	int err;
+
+	/* Make sure new filter is there and in the right amounts. */
+	if (fprog->filter == NULL)
+		return -EINVAL;
+
+	fp = sock_kmalloc(sk, fsize+sizeof(*fp), GFP_KERNEL);
+	if (!fp)
+		return -ENOMEM;
+	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
+		sock_kfree_s(sk, fp, fsize+sizeof(*fp));
+		return -EFAULT;
+	}
+
+	atomic_set(&fp->refcnt, 1);
+	fp->len = fprog->len;
+	fp->bpf_func = sk_run_filter;
+
+	err = sk_chk_filter(fp->insns, fp->len);
+	if (err) {
+		sk_filter_uncharge(sk, fp);
+		return err;
+	}
+
+	bpf_jit_compile(fp);
+
+	if (local) {
+		old_fp = rcu_dereference_protected(sk->sk_filter,
+						   sock_owned_by_user(sk));
+		rcu_assign_pointer(sk->sk_filter, fp);
+	} else {
+		old_fp = rcu_dereference_protected(sk->sk_peer_filter,
+						   sock_owned_by_user(sk));
+		rcu_assign_pointer(sk->sk_peer_filter, fp);
+	}
+
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+	return 0;
+}
+
+/**
+ *	sk_attach_filter - attach a socket filter
+ *	@fprog: the filter program
+ *	@sk: the socket to use
+ *
+ * Attach the user's filter code. We first run some sanity checks on
+ * it to make sure it does not explode on us later. If an error
+ * occurs or there is insufficient memory for the filter a negative
+ * errno code is returned. On success the return is zero.
+ */
+int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
+{
+	return __sk_attach_filter(fprog, sk, true);
+}
+EXPORT_SYMBOL_GPL(sk_attach_filter);
+
+int __sk_detach_filter(struct sock *sk, bool local)
+{
+	int ret = -ENOENT;
+	struct sk_filter *filter;
+
+	if (local)
+		filter = rcu_dereference_protected(sk->sk_filter,
+						   sock_owned_by_user(sk));
+	else
+		filter = rcu_dereference_protected(sk->sk_peer_filter,
+						   sock_owned_by_user(sk));
+
+	if (filter) {
+		if (local)
+			RCU_INIT_POINTER(sk->sk_filter, NULL);
+		else
+			RCU_INIT_POINTER(sk->sk_peer_filter, NULL);
+		sk_filter_uncharge(sk, filter);
+		ret = 0;
+	}
+	return ret;
+}
+
+int sk_detach_filter(struct sock *sk)
+{
+	return __sk_detach_filter(sk, true);
+}
+EXPORT_SYMBOL_GPL(sk_detach_filter);
+
+/**
+ *	sk_attach_peer_filter - attach a remote socket filter
+ *	@fprog: the filter program
+ *	@sk: the socket to use
+ *
+ * Attach the user's filter code. We first run some sanity checks on
+ * it to make sure it does not explode on us later. If an error
+ * occurs or there is insufficient memory for the filter a negative
+ * errno code is returned. On success the return is zero.
+ */
+int sk_attach_peer_filter(struct sock_fprog *fprog, struct sock *sk)
+{
+	return __sk_attach_filter(fprog, sk, false);
+}
+EXPORT_SYMBOL_GPL(sk_attach_peer_filter);
+
+int sk_detach_peer_filter(struct sock *sk)
+{
+	return __sk_detach_filter(sk, false);
+}
+EXPORT_SYMBOL_GPL(sk_detach_peer_filter);
+
+#else
+
 /**
  *	sk_attach_filter - attach a socket filter
  *	@fprog: the filter program
@@ -652,3 +768,5 @@ int sk_detach_filter(struct sock *sk)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
+
+#endif
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 330c0a2..9439206 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -121,6 +121,7 @@ DEFINE_SPINLOCK(unix_table_lock);
 EXPORT_SYMBOL_GPL(unix_table_lock);
 #ifdef CONFIG_UNIX_MULTICAST
 #include <linux/sort.h>
+#include <linux/filter.h>
 
 static DEFINE_SPINLOCK(unix_multicast_lock);
 #endif
@@ -1767,8 +1768,10 @@ static int unix_dgram_sendmsg_multicast(struct sock_iocb *siocb,
 restart:
 	for (i = others_set->offset ; i < others_set->cnt ; i++) {
 		struct sock *cur = others_set->items[i].s;
-		unsigned int pkt_len;
+		unsigned int pkt_len = 0xffffffff;
+		unsigned int pkt_peer_len = 0xffffffff;
 		struct sk_filter *filter;
+		struct sk_filter *peer_filter;
 
 		if (!others_set->items[i].to_deliver)
 			continue;
@@ -1777,14 +1780,15 @@ restart:
 		BUG_ON(cur == NULL);
 
 		rcu_read_lock();
-		filter = rcu_dereference(cur->sk_filter);
-		if (filter)
-			pkt_len = sk_run_filter(skb, filter->insns);
-		else
-			pkt_len = 0xffffffff;
+
+		peer_filter = rcu_dereference(cur->sk_peer_filter);
+
+		if (peer_filter)
+			pkt_peer_len = sk_run_filter(skb, peer_filter->insns);
+
 		rcu_read_unlock();
 
-		if (pkt_len == 0) {
+		if (!pkt_peer_len) {
 			others_set->items[i].to_deliver = 0;
 			continue;
 		}
@@ -1795,13 +1799,33 @@ restart:
 			err = -ENOMEM;
 			goto out_free;
 		}
+
+		if (peer_filter)
+			pskb_trim(others_set->items[i].skb, pkt_peer_len);
+
+		rcu_read_lock();
+
+		filter = rcu_dereference(cur->sk_filter);
+
+		if (filter)
+			pkt_len = sk_run_filter(others_set->items[i].skb,
+						filter->insns);
+		rcu_read_unlock();
+
+		if (!pkt_len) {
+			others_set->items[i].to_deliver = 0;
+			continue;
+		}
+
+		if (filter)
+			pskb_trim(others_set->items[i].skb, pkt_len);
+
 		skb_set_owner_w(others_set->items[i].skb, sk);
 		err = unix_scm_to_skb(siocb->scm, others_set->items[i].skb,
 				      true);
 		if (err < 0)
 			goto out_free;
 		unix_get_secdata(siocb->scm, others_set->items[i].skb);
-		pskb_trim(others_set->items[i].skb, pkt_len);
 	}
 
 	for (i = others_set->offset ; i < others_set->cnt ; i++) {
@@ -2443,6 +2467,7 @@ static int unix_setsockopt(struct socket *sock, int level, int optname,
 #ifdef CONFIG_UNIX_MULTICAST
 	struct unix_mreq mreq;
 	int err = 0;
+	struct sock *other = NULL;
 
 	if (level != SOL_UNIX)
 		return -ENOPROTOOPT;
@@ -2458,6 +2483,35 @@ static int unix_setsockopt(struct socket *sock, int level, int optname,
 			return -EFAULT;
 		break;
 
+	case UNIX_ATTACH_FILTER:
+		err = -EINVAL;
+		if (sock->sk->sk_type != SOCK_SEQPACKET)
+			return err;
+
+		if (!unix_sk(sock->sk)->mcast_group)
+			return err;
+
+		other = unix_peer_get(sock->sk);
+		if (!other)
+			return err;
+
+		BUG_ON(unix_sk(other)->mcast_group);
+
+		if (optlen == sizeof(struct sock_fprog)) {
+			struct sock_fprog fprog;
+
+			err = -EFAULT;
+			if (copy_from_user(&fprog, optval, sizeof(fprog))) {
+				sock_put(other);
+				return err;
+			}
+
+			err = sk_attach_peer_filter(&fprog, other);
+		}
+		sock_put(other);
+		return err;
+		break;
+
 	default:
 		break;
 	}
-- 
1.7.7.6
