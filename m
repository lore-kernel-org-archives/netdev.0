From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 5/5] udp: add recvmmsg implementation
Date: Fri, 25 Nov 2016 16:39:56 +0100
Message-ID: <68bfaa7480400457e712fb04ee781410d1bb9479.1480086321.git.pabeni@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59758 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755052AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skbs are extracted from the receive queue in burts, and a single
sk_rmem_alloc/forward allocated memory update is performed for
each burst.
MSG_PEEK and MSG_ERRQUEUE are not supported to keep the implementation
as simple as possible.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/udp.h   |   7 +++
 net/ipv4/udp.c      | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_impl.h |   3 ++
 net/ipv4/udplite.c  |   1 +
 net/ipv6/udp.c      |  16 +++++++
 net/ipv6/udp_impl.h |   3 ++
 net/ipv6/udplite.c  |   1 +
 7 files changed, 152 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 1661791..2bd63c9 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -308,6 +308,13 @@ struct sock *__udp6_lib_lookup(struct net *net,
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 
+int __udp_recvmmsg(struct sock *sk, struct mmsghdr __user *ummsg,
+		   unsigned int *vlen, unsigned int flags,
+		   struct timespec *timeout, const struct timespec64 *end_time,
+		   int (*udp_process_msg)(struct sock *sk, struct sk_buff *skb,
+					  struct msghdr *msg,
+					  unsigned int flags));
+
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d99429d..44f1326 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1467,6 +1467,126 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	return err;
 }
 
+static void udp_skb_bulk_destructor(struct sock *sk, int totalsize)
+{
+	udp_rmem_release(sk, totalsize, 1);
+}
+
+int __udp_recvmmsg(struct sock *sk, struct mmsghdr __user *mmsg,
+		   unsigned int *nr, unsigned int flags,
+		   struct timespec *timeout, const struct timespec64 *end_time,
+		   int (*process_msg)(struct sock *sk, struct sk_buff *skb,
+				      struct msghdr *msg,
+				      unsigned int flags))
+{
+	long timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	int datagrams = 0, err = 0, ret = 0, vlen = *nr;
+	struct sk_buff *skb, *next, *last;
+
+	if (flags & (MSG_PEEK | MSG_ERRQUEUE))
+		return -EOPNOTSUPP;
+
+again:
+	for (;;) {
+		skb = __skb_try_recv_datagram_batch(sk, flags, vlen - datagrams,
+						    udp_skb_bulk_destructor,
+						    &err);
+		if (skb)
+			break;
+
+		if ((err != -EAGAIN) || !timeo || (flags & MSG_DONTWAIT))
+			goto out;
+
+		/* no packets, and we are supposed to wait for the next */
+		if (timeout) {
+			long expires;
+
+			if (sock_recvmmsg_timeout(timeout, *end_time))
+				goto out;
+			expires = timeout->tv_sec * HZ +
+				  (timeout->tv_nsec >> 20);
+			if (expires + 1 < timeo)
+				timeo = expires + 1;
+		}
+
+		/* the queue was empty when tried to dequeue */
+		last = (struct sk_buff *)&sk->sk_receive_queue;
+		if (__skb_wait_for_more_packets(sk, &err, &timeo, last))
+			goto out;
+	}
+
+	for (; skb; skb = next) {
+		struct recvmmsg_ctx ctx;
+		int len;
+
+		next = skb->next;
+		err = recvmmsg_ctx_from_user(sk, mmsg, flags, datagrams, &ctx);
+		if (err < 0) {
+			kfree_skb(skb);
+			goto free_ctx;
+		}
+
+		/* process skb's until we find a valid one */
+		for (;;) {
+			len = process_msg(sk, skb, &ctx.msg_sys, flags);
+			if (len >= 0)
+				break;
+
+			/* only non csum errors are propagated to the caller */
+			if (len != -EINVAL) {
+				err = len;
+				goto free_ctx;
+			}
+
+			if (!next)
+				goto free_ctx;
+			skb = next;
+			next = skb->next;
+		}
+
+		err = recvmmsg_ctx_to_user(&mmsg, len, flags, &ctx);
+		if (err < 0)
+			goto free_ctx;
+
+		/* now we're sure the skb is fully processed, we can count it */
+		datagrams++;
+
+free_ctx:
+		recvmmsg_ctx_free(&ctx);
+		if (err < 0)
+			ret = err;
+	}
+
+	/* only handle waitforone after processing a full batch. */
+	if (datagrams && (flags & MSG_WAITFORONE))
+		flags |= MSG_DONTWAIT;
+
+	if (!ret && (datagrams < vlen)) {
+		cond_resched();
+		goto again;
+	}
+
+out:
+	*nr = datagrams;
+	return ret < 0 ? ret : -EAGAIN;
+}
+EXPORT_SYMBOL_GPL(__udp_recvmmsg);
+
+static int udp_process_msg(struct sock *sk, struct sk_buff *skb,
+			   struct msghdr *msg, unsigned int flags)
+{
+	return udp_process_skb(sk, skb, msg, msg_data_left(msg), flags,
+			       &msg->msg_namelen, 0, 0, skb->peeked);
+}
+
+int udp_recvmmsg(struct sock *sk, struct mmsghdr __user *ummsg,
+		 unsigned int *nr, unsigned int flags, struct timespec *timeout,
+		 const struct timespec64 *end_time)
+{
+	return __udp_recvmmsg(sk, ummsg, nr, flags, timeout, end_time,
+			      udp_process_msg);
+}
+
 int __udp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -2329,6 +2449,7 @@ struct proto udp_prot = {
 	.getsockopt	   = udp_getsockopt,
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
+	.recvmmsg	   = udp_recvmmsg,
 	.sendpage	   = udp_sendpage,
 	.release_cb	   = ip4_datagram_release_cb,
 	.hash		   = udp_lib_hash,
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 7e0fe4b..f11d608 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -23,6 +23,9 @@ int compat_udp_getsockopt(struct sock *sk, int level, int optname,
 #endif
 int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		int flags, int *addr_len);
+int udp_recvmmsg(struct sock *sk, struct mmsghdr __user *ummsg,
+		 unsigned int *nr, unsigned int flags, struct timespec *timeout,
+		 const struct timespec64 *end_time);
 int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 59f10fe..a0e7fe9 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -49,6 +49,7 @@ struct proto 	udplite_prot = {
 	.getsockopt	   = udp_getsockopt,
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
+	.recvmmsg	   = udp_recvmmsg,
 	.sendpage	   = udp_sendpage,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3218c64..2c034be 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -479,6 +479,21 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 }
 
+static int udp6_process_msg(struct sock *sk, struct sk_buff *skb,
+			    struct msghdr *msg, unsigned int flags)
+{
+	return udp6_process_skb(sk, skb, msg, msg_data_left(msg), flags,
+				&msg->msg_namelen, 0, 0, skb->peeked);
+}
+
+int udpv6_recvmmsg(struct sock *sk, struct mmsghdr __user *ummsg,
+		   unsigned int *nr, unsigned int flags,
+		   struct timespec *timeout, const struct timespec64 *end_time)
+{
+	return __udp_recvmmsg(sk, ummsg, nr, flags, timeout, end_time,
+			      udp6_process_msg);
+}
+
 void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    u8 type, u8 code, int offset, __be32 info,
 		    struct udp_table *udptable)
@@ -1443,6 +1458,7 @@ struct proto udpv6_prot = {
 	.getsockopt	   = udpv6_getsockopt,
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
+	.recvmmsg	   = udpv6_recvmmsg,
 	.release_cb	   = ip6_datagram_release_cb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index f6eb1ab..fe566db 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -26,6 +26,9 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		  int flags, int *addr_len);
+int udpv6_recvmmsg(struct sock *sk, struct mmsghdr __user *ummsg,
+		   unsigned int *nr, unsigned int flags,
+		   struct timespec *timeout, const struct timespec64 *end_time);
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 2784cc3..23d80ac 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -45,6 +45,7 @@ struct proto udplitev6_prot = {
 	.getsockopt	   = udpv6_getsockopt,
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
+	.recvmmsg	   = udpv6_recvmmsg,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
-- 
1.8.3.1
