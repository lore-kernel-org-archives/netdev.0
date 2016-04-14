From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 3/6] sctp: export some functions for sctp_diag in inet_diag
Date: Thu, 14 Apr 2016 15:35:32 +0800
Message-ID: <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
 <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
 <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33171 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbcDNHfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 03:35:55 -0400
In-Reply-To: <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_diag_msg_common_fill is used to fill the diag msg common info,
we need to use it in sctp_diag as well, so export it.

inet_diag_msg_attrs_fill is used to fill some common attrs info between
sctp diag and tcp diag.

v2->v3:
- do not need to define and export inet_diag_get_handler any more.
  cause all the functions in it are in sctp_diag.ko, we just call
  them in sctp_diag.ko.

- add inet_diag_msg_attrs_fill to make codes clear.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/inet_diag.c | 67 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 41 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index bd591eb..70212bd 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -66,7 +66,7 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
-static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
+void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 {
 	r->idiag_family = sk->sk_family;
 
@@ -89,6 +89,7 @@ static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 	r->id.idiag_dst[0] = sk->sk_daddr;
 	}
 }
+EXPORT_SYMBOL_GPL(inet_diag_msg_common_fill);
 
 static size_t inet_sk_attr_size(void)
 {
@@ -104,13 +105,50 @@ static size_t inet_sk_attr_size(void)
 		+ 64;
 }
 
+int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
+			     struct inet_diag_msg *r, int ext,
+			     struct user_namespace *user_ns)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+
+	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
+		goto errout;
+
+	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
+	 * hence this needs to be included regardless of socket family.
+	 */
+	if (ext & (1 << (INET_DIAG_TOS - 1)))
+		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
+			goto errout;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (r->idiag_family == AF_INET6) {
+		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
+			if (nla_put_u8(skb, INET_DIAG_TCLASS,
+				       inet6_sk(sk)->tclass) < 0)
+				goto errout;
+
+		if (((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
+		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
+			goto errout;
+	}
+#endif
+
+	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
+	r->idiag_inode = sock_i_ino(sk);
+
+	return 0;
+errout:
+	return 1;
+}
+EXPORT_SYMBOL_GPL(inet_diag_msg_attrs_fill);
+
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		      struct sk_buff *skb, const struct inet_diag_req_v2 *req,
 		      struct user_namespace *user_ns,
 		      u32 portid, u32 seq, u16 nlmsg_flags,
 		      const struct nlmsghdr *unlh)
 {
-	const struct inet_sock *inet = inet_sk(sk);
 	const struct tcp_congestion_ops *ca_ops;
 	const struct inet_diag_handler *handler;
 	int ext = req->idiag_ext;
@@ -135,32 +173,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	r->idiag_timer = 0;
 	r->idiag_retrans = 0;
 
-	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
+	if (inet_diag_msg_attrs_fill(sk, skb, r, ext, user_ns))
 		goto errout;
 
-	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
-	 * hence this needs to be included regardless of socket family.
-	 */
-	if (ext & (1 << (INET_DIAG_TOS - 1)))
-		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
-			goto errout;
-
-#if IS_ENABLED(CONFIG_IPV6)
-	if (r->idiag_family == AF_INET6) {
-		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
-			if (nla_put_u8(skb, INET_DIAG_TCLASS,
-				       inet6_sk(sk)->tclass) < 0)
-				goto errout;
-
-		if (((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
-		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
-			goto errout;
-	}
-#endif
-
-	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
-	r->idiag_inode = sock_i_ino(sk);
-
 	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
 		struct inet_diag_meminfo minfo = {
 			.idiag_rmem = sk_rmem_alloc_get(sk),
-- 
2.1.0
