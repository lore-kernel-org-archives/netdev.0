From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: [net-next RFC 1/4] bindtosubnet: infrastructure
Date: Tue, 23 Feb 2016 15:27:42 +0000
Message-ID: <1456241265-5766-2-git-send-email-gilberto.bertin@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36199 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbcBWP1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:27:48 -0500
Received: by mail-wm0-f51.google.com with SMTP id g62so227926710wme.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:27:47 -0800 (PST)
In-Reply-To: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilberto Bertin <gilberto.bertin@gmail.com>
---
 include/net/sock.h                |  20 +++++++
 include/uapi/asm-generic/socket.h |   1 +
 net/core/sock.c                   | 111 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 132 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 14d3c07..7661652 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -123,6 +123,16 @@ typedef struct {
 #endif
 } socket_lock_t;
 
+struct ipv4_subnet {
+	__be32 net;
+	u_char plen;
+};
+
+struct ipv6_subnet {
+	struct in6_addr	net;
+	u_char plen;
+};
+
 struct sock;
 struct proto;
 struct net;
@@ -190,6 +200,13 @@ struct sock_common {
 	unsigned char		skc_ipv6only:1;
 	unsigned char		skc_net_refcnt:1;
 	int			skc_bound_dev_if;
+
+	unsigned char		skc_bind_to_subnet;
+	union {
+		struct ipv4_subnet skc_bind_subnet4;
+		struct ipv6_subnet skc_bind_subnet6;
+	};
+
 	union {
 		struct hlist_node	skc_bind_node;
 		struct hlist_nulls_node skc_portaddr_node;
@@ -342,6 +359,9 @@ struct sock {
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_reuseport		__sk_common.skc_reuseport
+#define sk_bind_to_subnet	__sk_common.skc_bind_to_subnet
+#define sk_bind_subnet4		__sk_common.skc_bind_subnet4
+#define sk_bind_subnet6		__sk_common.skc_bind_subnet6
 #define sk_ipv6only		__sk_common.skc_ipv6only
 #define sk_net_refcnt		__sk_common.skc_net_refcnt
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..e420333 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -30,6 +30,7 @@
 #define SO_SNDLOWAT	19
 #define SO_RCVTIMEO	20
 #define SO_SNDTIMEO	21
+#define SO_BINDTOSUBNET 22
 #endif
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
diff --git a/net/core/sock.c b/net/core/sock.c
index 0d91f7d..908193f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -613,6 +613,68 @@ out:
 	return ret;
 }
 
+static int sock_setbindtosubnet(struct sock *sk, char __user *optval,
+				int optlen)
+{
+	int ret = -ENOPROTOOPT;
+
+	if (sk->sk_family == AF_INET) {
+		struct ipv4_subnet bind_subnet4;
+
+		ret = -EFAULT;
+		if (optlen != sizeof(struct ipv4_subnet))
+			goto out;
+
+		if (copy_from_user(&bind_subnet4, optval,
+				   sizeof(struct ipv4_subnet)))
+			goto out;
+
+		ret = -EINVAL;
+		if (bind_subnet4.plen > 32)
+			goto out;
+
+		lock_sock(sk);
+
+		sk->sk_bind_to_subnet = 1;
+		sk->sk_bind_subnet4.net = bind_subnet4.net;
+		sk->sk_bind_subnet4.plen = bind_subnet4.plen;
+		sk_dst_reset(sk);
+
+		release_sock(sk);
+
+		ret = 0;
+	} else if (sk->sk_family == AF_INET6) {
+		struct ipv6_subnet bind_subnet6;
+
+		ret = -EFAULT;
+		if (optlen != sizeof(struct ipv6_subnet))
+			goto out;
+
+		if (copy_from_user(&bind_subnet6, optval,
+				   sizeof(struct ipv6_subnet)))
+			goto out;
+
+		ret = -EINVAL;
+		if (bind_subnet6.plen > 128)
+			goto out;
+
+		lock_sock(sk);
+
+		sk->sk_bind_to_subnet = 1;
+		memcpy(&sk->sk_bind_subnet6.net, &bind_subnet6.net,
+		       sizeof(struct in6_addr));
+		sk->sk_bind_subnet6.plen = bind_subnet6.plen;
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
@@ -653,6 +715,49 @@ out:
 	return ret;
 }
 
+static int sock_getbindtosubnet(struct sock *sk, char __user *optval,
+				int __user *optlen, int len)
+{
+	int ret;
+
+	if (sk->sk_bind_to_subnet == 0) {
+		len = 0;
+		goto zero;
+	}
+
+	if (sk->sk_family == AF_INET) {
+		ret = -EINVAL;
+		if (len < sizeof(struct ipv4_subnet))
+			goto out;
+
+		len = sizeof(struct ipv4_subnet);
+
+		ret = -EFAULT;
+		if (copy_to_user(optval, &sk->sk_bind_subnet4, len))
+			goto out;
+
+	} else if (sk->sk_family == AF_INET6) {
+		ret = -EINVAL;
+		if (len < sizeof(struct ipv6_subnet))
+			goto out;
+
+		len = sizeof(struct ipv6_subnet);
+
+		ret = -EFAULT;
+		if (copy_to_user(optval, &sk->sk_bind_subnet6, len))
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
@@ -701,6 +806,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	if (optname == SO_BINDTODEVICE)
 		return sock_setbindtodevice(sk, optval, optlen);
 
+	else if (optname == SO_BINDTOSUBNET)
+		return sock_setbindtosubnet(sk, optval, optlen);
+
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
@@ -1230,6 +1338,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_BINDTODEVICE:
 		return sock_getbindtodevice(sk, optval, optlen, len);
 
+	case SO_BINDTOSUBNET:
+		return sock_getbindtosubnet(sk, optval, optlen, len);
+
 	case SO_GET_FILTER:
 		len = sk_get_filter(sk, (struct sock_filter __user *)optval, len);
 		if (len < 0)
-- 
2.7.1
