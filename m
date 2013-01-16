From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH net-next] sk-filter: Add ability to lock a socket filter program
Date: Wed, 16 Jan 2013 22:55:49 +0100
Message-ID: <1358373349-22326-1-git-send-email-bernat@luffy.cx>
References: <20130116.162012.1782638746075880444.davem@davemloft.net>
Cc: Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:51450 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757702Ab3APV4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 16:56:25 -0500
In-Reply-To: <20130116.162012.1782638746075880444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While a privileged program can open a raw socket, attach some
restrictive filter and drop its privileges (or send the socket to an
unprivileged program through some Unix socket), the filter can still
be removed or modified by the unprivileged program. This commit adds a
socket option to lock the filter (SO_LOCK_FILTER) preventing any
modification of a socket filter program.

This is similar to OpenBSD BIOCLOCK ioctl on bpf sockets, except even
root is not allowed change/drop the filter.

The state of the lock can be read with getsockopt(). No error is
triggered if the state is not changed. -EPERM is returned when a user
tries to remove the lock or to change/remove the filter while the lock
is active. The check is done directly in sk_attach_filter() and
sk_detach_filter() and does not affect only setsockopt() syscall.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 Documentation/networking/filter.txt    |   11 +++++++++--
 arch/alpha/include/uapi/asm/socket.h   |    1 +
 arch/avr32/include/uapi/asm/socket.h   |    2 ++
 arch/cris/include/uapi/asm/socket.h    |    2 ++
 arch/frv/include/uapi/asm/socket.h     |    2 ++
 arch/h8300/include/uapi/asm/socket.h   |    2 ++
 arch/ia64/include/uapi/asm/socket.h    |    2 ++
 arch/m32r/include/uapi/asm/socket.h    |    2 ++
 arch/mips/include/uapi/asm/socket.h    |    1 +
 arch/mn10300/include/uapi/asm/socket.h |    2 ++
 arch/parisc/include/uapi/asm/socket.h  |    1 +
 arch/powerpc/include/uapi/asm/socket.h |    2 ++
 arch/s390/include/uapi/asm/socket.h    |    2 ++
 arch/sparc/include/uapi/asm/socket.h   |    1 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 ++
 include/net/sock.h                     |    1 +
 include/uapi/asm-generic/socket.h      |    2 ++
 net/core/filter.c                      |    6 ++++++
 net/core/sock.c                        |   11 +++++++++++
 19 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index bbf2005..cdb3e40 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -17,12 +17,12 @@ creating filters.
 
 LSF is much simpler than BPF. One does not have to worry about
 devices or anything like that. You simply create your filter
-code, send it to the kernel via the SO_ATTACH_FILTER ioctl and
+code, send it to the kernel via the SO_ATTACH_FILTER option and
 if your filter code passes the kernel check on it, you then
 immediately begin filtering data on that socket.
 
 You can also detach filters from your socket via the
-SO_DETACH_FILTER ioctl. This will probably not be used much
+SO_DETACH_FILTER option. This will probably not be used much
 since when you close a socket that has a filter on it the
 filter is automagically removed. The other less common case
 may be adding a different filter on the same socket where you had another
@@ -31,12 +31,19 @@ the old one and placing your new one in its place, assuming your
 filter has passed the checks, otherwise if it fails the old filter
 will remain on that socket.
 
+SO_LOCK_FILTER option allows to lock the filter attached to a
+socket. Once set, a filter cannot be removed or changed. This allows
+one process to setup a socket, attach a filter, lock it then drop
+privileges and be assured that the filter will be kept until the
+socket is closed.
+
 Examples
 ========
 
 Ioctls-
 setsockopt(sockfd, SOL_SOCKET, SO_ATTACH_FILTER, &Filter, sizeof(Filter));
 setsockopt(sockfd, SOL_SOCKET, SO_DETACH_FILTER, &value, sizeof(value));
+setsockopt(sockfd, SOL_SOCKET, SO_LOCK_FILTER, &value, sizeof(value));
 
 See the BSD bpf.4 manpage and the BSD Packet Filter paper written by
 Steven McCanne and Van Jacobson of Lawrence Berkeley Laboratory.
diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 097c157..755702e 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -77,5 +77,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 486df68..f3f38a0 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index b681b04..406b583 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -72,6 +72,8 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 871f89b..d8e1132 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -70,5 +70,7 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/uapi/asm/socket.h b/arch/h8300/include/uapi/asm/socket.h
index 90a2e57..c8b87a8 100644
--- a/arch/h8300/include/uapi/asm/socket.h
+++ b/arch/h8300/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 23d6759..f390896 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 5e7088a..6a89515 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 17307ab..9d11a77 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -90,5 +90,6 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
 
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index af5366b..ab702c4 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -70,4 +70,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index d9ff473..da2c8d3 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -69,6 +69,7 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		0x4024
 
+#define SO_LOCK_FILTER		0x4025
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index eb0b186..e6ca318 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -77,4 +77,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 436d07c..9ce60b6 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -76,4 +76,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index c83a937..fbbba57 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -66,6 +66,7 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		0x0027
 
+#define SO_LOCK_FILTER		0x0028
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 38079be..dbf3164 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -81,4 +81,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 182ca99..5a34e2f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -664,6 +664,7 @@ enum sock_flags {
 		     * Will use last 4 bytes of packet sent from
 		     * user-space instead.
 		     */
+	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 2d32d07..3f6a992 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -73,4 +73,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_LOCK_FILTER		44
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index 2ead2a9..2e20b55 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -721,6 +721,9 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
 	int err;
 
+	if (sock_flag(sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+
 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
 		return -EINVAL;
@@ -757,6 +760,9 @@ int sk_detach_filter(struct sock *sk)
 	int ret = -ENOENT;
 	struct sk_filter *filter;
 
+	if (sock_flag(sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+
 	filter = rcu_dereference_protected(sk->sk_filter,
 					   sock_owned_by_user(sk));
 	if (filter) {
diff --git a/net/core/sock.c b/net/core/sock.c
index bc131d4..8258fb7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -861,6 +861,13 @@ set_rcvbuf:
 		ret = sk_detach_filter(sk);
 		break;
 
+	case SO_LOCK_FILTER:
+		if (sock_flag(sk, SOCK_FILTER_LOCKED) && !valbool)
+			ret = -EPERM;
+		else
+			sock_valbool_flag(sk, SOCK_FILTER_LOCKED, valbool);
+		break;
+
 	case SO_PASSSEC:
 		if (valbool)
 			set_bit(SOCK_PASSSEC, &sock->flags);
@@ -1140,6 +1147,10 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 		goto lenout;
 
+	case SO_LOCK_FILTER:
+		v.val = sock_flag(sk, SOCK_FILTER_LOCKED);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
1.7.10.4
