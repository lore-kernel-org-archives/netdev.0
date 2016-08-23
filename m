From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2 net-next] net: diag: support SOCK_DESTROY for UDP sockets
Date: Mon, 22 Aug 2016 18:03:41 -0700
Message-ID: <1471914221-24213-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33729 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755182AbcHWBEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:04:23 -0400
Received: by mail-pa0-f47.google.com with SMTP id ti13so42503283pac.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 18:03:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements SOCK_DESTROY for UDP sockets similar to what was done
for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
sockets.") A process with a UDP socket targeted for destroy is awakened
and recvmsg fails with ECONNABORTED.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- changed socket lookup to __udp{4,6}_lib_lookup

 include/net/udp.h   |  1 +
 net/ipv4/udp.c      | 17 +++++++++++++++++
 net/ipv4/udp_diag.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udp.c      |  1 +
 4 files changed, 74 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 8894d7144189..ea53a87d880f 100644
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
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd65d08..d082800557da 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2192,6 +2192,22 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
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
@@ -2223,6 +2239,7 @@ struct proto udp_prot = {
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
 	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.diag_destroy	   = udp_abort,
 };
 EXPORT_SYMBOL(udp_prot);
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 3d5ccf4b1412..904c5a9d2680 100644
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
+		sk = __udp4_lib_lookup(net,
+				req->id.idiag_dst[0], req->id.idiag_dport,
+				req->id.idiag_src[0], req->id.idiag_sport,
+				req->id.idiag_if, tbl, NULL);
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (req->sdiag_family == AF_INET6)
+		sk = __udp6_lib_lookup(net,
+				(struct in6_addr *)req->id.idiag_dst,
+				req->id.idiag_dport,
+				(struct in6_addr *)req->id.idiag_src,
+				req->id.idiag_sport,
+				req->id.idiag_if, tbl, NULL);
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
index 81e2f98b958d..16512cf06e73 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1467,6 +1467,7 @@ struct proto udpv6_prot = {
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
 	.clear_sk	   = udp_v6_clear_sk,
+	.diag_destroy      = udp_abort,
 };
 
 static struct inet_protosw udpv6_protosw = {
-- 
2.1.4
