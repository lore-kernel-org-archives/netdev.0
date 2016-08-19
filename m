From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH] net: diag: support SOCK_DESTROY for UDP sockets
Date: Thu, 18 Aug 2016 19:29:19 -0700
Message-ID: <1471573759-23145-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34370 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753005AbcHSC32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:29:28 -0400
Received: by mail-pa0-f43.google.com with SMTP id fi15so11268987pac.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements SOCK_DESTROY for UDP sockets similar to what was done
for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
sockets.") A process with a UDP socket targeted for destroy is awakened
and recvmsg fails with ECONNABORTED giving the process notice that
it should close the socket.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/udp.h   |  8 ++++++++
 net/ipv4/udp.c      | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_diag.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udp.c      | 45 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 166 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 8894d7144189..5c3443634b4d 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -251,6 +251,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
 				  const struct sock *));
 void udp_err(struct sk_buff *, u32);
+int udp_abort(struct sock *sk, int err);
 int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
 int udp_push_pending_frames(struct sock *sk);
 void udp_flush_pending_frames(struct sock *sk);
@@ -274,6 +275,9 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
+struct sock *udp4_lib_lookup_full(struct net *net, __be32 saddr,
+				  __be16 sport, __be32 daddr, __be16 dport,
+				  int dif, struct udp_table *table);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
@@ -286,6 +290,10 @@ struct sock *__udp6_lib_lookup(struct net *net,
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
 
+struct sock *udp6_lib_lookup_full(struct net *net,
+				  const struct in6_addr *saddr, __be16 sport,
+				  const struct in6_addr *daddr, __be16 dport,
+				  int dif, struct udp_table *table);
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd65d08..e5b72a7165e1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -594,6 +594,47 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 #endif
 
+/* caller should hold rcu lock */
+struct sock *udp4_lib_lookup_full(struct net *net, __be32 saddr,
+				  __be16 sport, __be32 daddr, __be16 dport,
+				  int dif, struct udp_table *table)
+{
+	struct sock *sk;
+	int i;
+
+	for (i = 0; i <= table->mask; i++) {
+		struct udp_hslot *hslot = &table->hash[i];
+
+		sk_for_each_rcu(sk, &hslot->head) {
+			struct inet_sock *inet;
+
+			if (!net_eq(sock_net(sk), net) ||
+			    ipv6_only_sock(sk))
+				continue;
+
+			if (dif && sk->sk_bound_dev_if != dif)
+				continue;
+
+			if (sk->sk_family != PF_INET)
+				continue;
+
+			if (udp_sk(sk)->udp_port_hash != ntohs(sport))
+				continue;
+
+			inet = inet_sk(sk);
+			if (inet->inet_rcv_saddr != saddr  ||
+			    inet->inet_daddr     != daddr  ||
+			    inet->inet_dport     != dport)
+				continue;
+
+			return sk;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(udp4_lib_lookup_full);
+
 static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 				       __be16 loc_port, __be32 loc_addr,
 				       __be16 rmt_port, __be32 rmt_addr,
@@ -2192,6 +2233,22 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(udp_poll);
 
+int udp_abort(struct sock *sk, int err)
+{
+	lock_sock(sk);
+
+	sk->sk_err = err;
+	sk->sk_error_report(sk);
+	udp_disconnect(sk, 0);
+
+	release_sock(sk);
+
+	sock_put(sk);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_abort);
+
 struct proto udp_prot = {
 	.name		   = "UDP",
 	.owner		   = THIS_MODULE,
@@ -2223,6 +2280,7 @@ struct proto udp_prot = {
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
 	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.diag_destroy	   = udp_abort,
 };
 EXPORT_SYMBOL(udp_prot);
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 3d5ccf4b1412..9ed7ae064e08 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -165,12 +165,64 @@ static void udp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 	r->idiag_wqueue = sk_wmem_alloc_get(sk);
 }
 
+#ifdef CONFIG_INET_DIAG_DESTROY
+static int __udp_diag_destroy(struct sk_buff *in_skb,
+			      const struct inet_diag_req_v2 *req,
+			      struct udp_table *tbl)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct sock *sk;
+
+	rcu_read_lock();
+
+	if (req->sdiag_family == AF_INET)
+		sk = udp4_lib_lookup_full(net,
+				req->id.idiag_src[0], req->id.idiag_sport,
+				req->id.idiag_dst[0], req->id.idiag_dport,
+				req->id.idiag_if, tbl);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (req->sdiag_family == AF_INET6)
+		sk = udp6_lib_lookup_full(net,
+				(struct in6_addr *)req->id.idiag_src,
+				req->id.idiag_sport,
+				(struct in6_addr *)req->id.idiag_dst,
+				req->id.idiag_dport,
+				req->id.idiag_if, tbl);
+#endif
+	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+		sk = NULL;
+
+	rcu_read_unlock();
+
+	if (!sk)
+		return -ENOENT;
+
+	return sock_diag_destroy(sk, ECONNABORTED);
+}
+
+static int udp_diag_destroy(struct sk_buff *in_skb,
+			    const struct inet_diag_req_v2 *req)
+{
+	return __udp_diag_destroy(in_skb, req, &udp_table);
+}
+
+static int udplite_diag_destroy(struct sk_buff *in_skb,
+				const struct inet_diag_req_v2 *req)
+{
+	return __udp_diag_destroy(in_skb, req, &udplite_table);
+}
+
+#endif
+
 static const struct inet_diag_handler udp_diag_handler = {
 	.dump		 = udp_diag_dump,
 	.dump_one	 = udp_diag_dump_one,
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDP,
 	.idiag_info_size = 0,
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.destroy	 = udp_diag_destroy,
+#endif
 };
 
 static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
@@ -192,6 +244,9 @@ static const struct inet_diag_handler udplite_diag_handler = {
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDPLITE,
 	.idiag_info_size = 0,
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.destroy	 = udplite_diag_destroy,
+#endif
 };
 
 static int __init udp_diag_init(void)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 81e2f98b958d..5b697cff88ca 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -317,6 +317,50 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 #endif
 
+/* caller should hold rcu lock */
+struct sock *udp6_lib_lookup_full(struct net *net,
+				  const struct in6_addr *saddr, __be16 sport,
+				  const struct in6_addr *daddr, __be16 dport,
+				  int dif, struct udp_table *table)
+{
+	struct sock *sk;
+	int i;
+
+	for (i = 0; i <= table->mask; i++) {
+		struct udp_hslot *hslot = &table->hash[i];
+
+		sk_for_each_rcu(sk, &hslot->head) {
+			struct inet_sock *inet;
+
+			if (!net_eq(sock_net(sk), net) ||
+			    ipv6_only_sock(sk))
+				continue;
+
+			if (dif && sk->sk_bound_dev_if != dif)
+				continue;
+
+			if (sk->sk_family != PF_INET6)
+				continue;
+
+			if (udp_sk(sk)->udp_port_hash != ntohs(sport))
+				continue;
+
+			if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, saddr) ||
+			    !ipv6_addr_equal(&sk->sk_v6_daddr, daddr))
+				continue;
+
+			inet = inet_sk(sk);
+			if (inet->inet_dport != dport)
+				continue;
+
+			return sk;
+		}
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(udp6_lib_lookup_full);
+
 /*
  *	This should be easy, if there is something there we
  *	return it, otherwise we block.
@@ -1467,6 +1511,7 @@ struct proto udpv6_prot = {
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
 	.clear_sk	   = udp_v6_clear_sk,
+	.diag_destroy      = udp_abort,
 };
 
 static struct inet_protosw udpv6_protosw = {
-- 
2.1.4
