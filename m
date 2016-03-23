From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 1/4] bindtoprefix: infrastructure
Date: Wed, 23 Mar 2016 02:26:03 +0000
Message-ID: <1458699966-3752-2-git-send-email-gilberto.bertin@gmail.com>
References: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Cc: tom@herbertland.com, markzzzsmith@gmail.com,
	Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33184 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbcC2Nhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 09:37:51 -0400
Received: by mail-wm0-f45.google.com with SMTP id r72so57406918wmg.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 06:37:50 -0700 (PDT)
In-Reply-To: <1458699966-3752-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 include/net/sock.h                |  20 +++++++
 include/uapi/asm-generic/socket.h |   1 +
 net/core/sock.c                   | 111 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 132 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index f5ea148..409d255 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -109,6 +109,16 @@ typedef struct {
 #endif
 } socket_lock_t;
 
+struct ipv4_prefix {
+	__be32 net;
+	u_char plen;
+};
+
+struct ipv6_prefix {
+	struct in6_addr	net;
+	u_char plen;
+};
+
 struct sock;
 struct proto;
 struct net;
@@ -176,6 +186,13 @@ struct sock_common {
 	unsigned char		skc_ipv6only:1;
 	unsigned char		skc_net_refcnt:1;
 	int			skc_bound_dev_if;
+
+	unsigned char		skc_bind_to_prefix;
+	union {
+		struct ipv4_prefix skc_bind_prefix4;
+		struct ipv6_prefix skc_bind_prefix6;
+	};
+
 	union {
 		struct hlist_node	skc_bind_node;
 		struct hlist_nulls_node skc_portaddr_node;
@@ -327,6 +344,9 @@ struct sock {
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_reuseport		__sk_common.skc_reuseport
+#define sk_bind_to_prefix	__sk_common.skc_bind_to_prefix
+#define sk_bind_prefix4		__sk_common.skc_bind_prefix4
+#define sk_bind_prefix6		__sk_common.skc_bind_prefix6
 #define sk_ipv6only		__sk_common.skc_ipv6only
 #define sk_net_refcnt		__sk_common.skc_net_refcnt
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index fb8a416..b4dd61f 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -30,6 +30,7 @@
 #define SO_SNDLOWAT	19
 #define SO_RCVTIMEO	20
 #define SO_SNDTIMEO	21
+#define SO_BINDTOPREFIX 22
 #endif
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
diff --git a/net/core/sock.c b/net/core/sock.c
index 6c1c8bc..e4c9c55 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -571,6 +571,68 @@ out:
 	return ret;
 }
 
+static int sock_setbindtoprefix(struct sock *sk, char __user *optval,
+				int optlen)
+{
+	int ret = -ENOPROTOOPT;
+
+	if (sk->sk_family == AF_INET) {
+		struct ipv4_prefix bind_prefix4;
+
+		ret = -EFAULT;
+		if (optlen != sizeof(struct ipv4_prefix))
+			goto out;
+
+		if (copy_from_user(&bind_prefix4, optval,
+				   sizeof(struct ipv4_prefix)))
+			goto out;
+
+		ret = -EINVAL;
+		if (bind_prefix4.plen > 32)
+			goto out;
+
+		lock_sock(sk);
+
+		sk->sk_bind_to_prefix = 1;
+		sk->sk_bind_prefix4.net = bind_prefix4.net;
+		sk->sk_bind_prefix4.plen = bind_prefix4.plen;
+		sk_dst_reset(sk);
+
+		release_sock(sk);
+
+		ret = 0;
+	} else if (sk->sk_family == AF_INET6) {
+		struct ipv6_prefix bind_prefix6;
+
+		ret = -EFAULT;
+		if (optlen != sizeof(struct ipv6_prefix))
+			goto out;
+
+		if (copy_from_user(&bind_prefix6, optval,
+				   sizeof(struct ipv6_prefix)))
+			goto out;
+
+		ret = -EINVAL;
+		if (bind_prefix6.plen > 128)
+			goto out;
+
+		lock_sock(sk);
+
+		sk->sk_bind_to_prefix = 1;
+		memcpy(&sk->sk_bind_prefix6.net, &bind_prefix6.net,
+		       sizeof(struct in6_addr));
+		sk->sk_bind_prefix6.plen = bind_prefix6.plen;
+		sk_dst_reset(sk);
+
+		release_sock(sk);
+
+		ret = 0;
+	}
+
+out:
+	return ret;
+}
+
 static int sock_getbindtodevice(struct sock *sk, char __user *optval,
 				int __user *optlen, int len)
 {
@@ -611,6 +673,49 @@ out:
 	return ret;
 }
 
+static int sock_getbindtoprefix(struct sock *sk, char __user *optval,
+				int __user *optlen, int len)
+{
+	int ret;
+
+	if (sk->sk_bind_to_prefix == 0) {
+		len = 0;
+		goto zero;
+	}
+
+	if (sk->sk_family == AF_INET) {
+		ret = -EINVAL;
+		if (len < sizeof(struct ipv4_prefix))
+			goto out;
+
+		len = sizeof(struct ipv4_prefix);
+
+		ret = -EFAULT;
+		if (copy_to_user(optval, &sk->sk_bind_prefix4, len))
+			goto out;
+
+	} else if (sk->sk_family == AF_INET6) {
+		ret = -EINVAL;
+		if (len < sizeof(struct ipv6_prefix))
+			goto out;
+
+		len = sizeof(struct ipv6_prefix);
+
+		ret = -EFAULT;
+		if (copy_to_user(optval, &sk->sk_bind_prefix6, len))
+			goto out;
+	}
+
+zero:
+	ret = -EFAULT;
+	if (put_user(len, optlen))
+		goto out;
+
+	ret = 0;
+out:
+	return ret;
+}
+
 static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 {
 	if (valbool)
@@ -659,6 +764,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	if (optname == SO_BINDTODEVICE)
 		return sock_setbindtodevice(sk, optval, optlen);
 
+	else if (optname == SO_BINDTOPREFIX)
+		return sock_setbindtoprefix(sk, optval, optlen);
+
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
@@ -1214,6 +1322,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_BINDTODEVICE:
 		return sock_getbindtodevice(sk, optval, optlen, len);
 
+	case SO_BINDTOPREFIX:
+		return sock_getbindtoprefix(sk, optval, optlen, len);
+
 	case SO_GET_FILTER:
 		len = sk_get_filter(sk, (struct sock_filter __user *)optval, len);
 		if (len < 0)
-- 
2.7.3
