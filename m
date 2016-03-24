From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFT Patch net 2/2] ipv6: add a socket release callback for datagram sockets
Date: Thu, 24 Mar 2016 12:25:36 -0700
Message-ID: <1458847536-7729-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: weiwan@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36798 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbcCXTZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:25:52 -0400
Received: by mail-pf0-f181.google.com with SMTP id u190so65564048pfb.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 12:25:51 -0700 (PDT)
In-Reply-To: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 8141ed9fcedb, this implements a socket
release callback function to check if an IPv6 socket cached
route got invalid during the time we owned the socket.
The function is used from udp, raw sockets.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/ipv6.h  |  1 +
 net/ipv6/datagram.c | 40 ++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c      |  1 +
 net/ipv6/udp.c      |  1 +
 4 files changed, 43 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0aeb97..890456d 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -959,6 +959,7 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
+void ip6_datagram_release_cb(struct sock *sk);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4281621..a743caa 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -231,6 +231,46 @@ int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *uaddr,
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_connect_v6_only);
 
+void ip6_datagram_release_cb(struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *final_p, final;
+	struct ipv6_txoptions *opt;
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+	struct rtable *rt;
+
+	rcu_read_lock();
+
+	dst = __sk_dst_get(sk);
+	if (!dst || !dst->obsolete || dst->ops->check(dst, 0)) {
+		rcu_read_unlock();
+		return;
+	}
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = sk->sk_protocol;
+	fl6.daddr = sk->sk_v6_daddr;
+	fl6.saddr = np->saddr;
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark;
+	fl6.fl6_dport = inet->inet_dport;
+	fl6.fl6_sport = inet->inet_sport;
+
+	rcu_read_lock();
+	opt = rcu_dereference(np->opt);
+	final_p = fl6_update_dst(&fl6, opt, &final);
+	rcu_read_unlock();
+
+	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
+	dst = !IS_ERR(rt) ? &rt->dst : NULL;
+	sk_dst_set(sk, dst);
+
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(ip6_datagram_release_cb);
+
 void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 		     __be16 port, u32 info, u8 *payload)
 {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fa59dd7..4319e65 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1235,6 +1235,7 @@ struct proto rawv6_prot = {
 	.recvmsg	   = rawv6_recvmsg,
 	.bind		   = rawv6_bind,
 	.backlog_rcv	   = rawv6_rcv_skb,
+	.release_cb	   = ip6_datagram_release_cb,
 	.hash		   = raw_hash_sk,
 	.unhash		   = raw_unhash_sk,
 	.obj_size	   = sizeof(struct raw6_sock),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fd25e44..0fdaf8f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1539,6 +1539,7 @@ struct proto udpv6_prot = {
 	.sendmsg	   = udpv6_sendmsg,
 	.recvmsg	   = udpv6_recvmsg,
 	.backlog_rcv	   = __udpv6_queue_rcv_skb,
+	.release_cb	   = ip6_datagram_release_cb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.rehash		   = udp_v6_rehash,
-- 
2.1.0
