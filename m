From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/5] soreuseport: infrastructure
Date: Mon, 14 Jan 2013 12:00:18 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f74.google.com ([209.85.215.74]:49672 "EHLO
	mail-la0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333Ab3ANUAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:00:21 -0500
Received: by mail-la0-f74.google.com with SMTP id ej20so288356lab.3
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 12:00:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Definitions and macros for implementing soreusport.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/random.h            |    6 ++++++
 include/net/sock.h                |    5 ++++-
 include/uapi/asm-generic/socket.h |    3 +--
 net/core/sock.c                   |    7 +++++++
 4 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/random.h b/include/linux/random.h
index d984608..347ce55 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -74,4 +74,10 @@ static inline int arch_get_random_int(unsigned int *v)
 }
 #endif
 
+/* Pseudo random number generator from numerical recipes. */
+static inline u32 next_pseudo_random32(u32 seed)
+{
+	return seed * 1664525 + 1013904223;
+}
+
 #endif /* _LINUX_RANDOM_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 182ca99..360b412 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -140,6 +140,7 @@ typedef __u64 __bitwise __addrpair;
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
+ *	@skc_reuseport: %SO_REUSEPORT setting
  *	@skc_bound_dev_if: bound device index if != 0
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
@@ -179,7 +180,8 @@ struct sock_common {
 
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
-	unsigned char		skc_reuse;
+	unsigned char		skc_reuse:4;
+	unsigned char		skc_reuseport:4;
 	int			skc_bound_dev_if;
 	union {
 		struct hlist_node	skc_bind_node;
@@ -297,6 +299,7 @@ struct sock {
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
+#define sk_reuseport		__sk_common.skc_reuseport
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2d32d07..331e322 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -22,8 +22,7 @@
 #define SO_PRIORITY	12
 #define SO_LINGER	13
 #define SO_BSDCOMPAT	14
-/* To add :#define SO_REUSEPORT 15 */
-
+#define SO_REUSEPORT	15
 #ifndef SO_PASSCRED /* powerpc only differs in these */
 #define SO_PASSCRED	16
 #define SO_PEERCRED	17
diff --git a/net/core/sock.c b/net/core/sock.c
index bc131d4..0040832 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -665,6 +665,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_REUSEADDR:
 		sk->sk_reuse = (valbool ? SK_CAN_REUSE : SK_NO_REUSE);
 		break;
+	case SO_REUSEPORT:
+		sk->sk_reuseport = valbool;
+		break;
 	case SO_TYPE:
 	case SO_PROTOCOL:
 	case SO_DOMAIN:
@@ -965,6 +968,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sk->sk_reuse;
 		break;
 
+	case SO_REUSEPORT:
+		v.val = sk->sk_reuseport;
+		break;
+
 	case SO_KEEPALIVE:
 		v.val = sock_flag(sk, SOCK_KEEPOPEN);
 		break;
-- 
1.7.7.3
