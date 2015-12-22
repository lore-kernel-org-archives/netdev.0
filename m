From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Tue, 22 Dec 2015 15:05:09 -0500
Message-ID: <1450814710-17850-4-git-send-email-kraigatgoog@gmail.com>
References: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35032 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665AbbLVUFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:05:17 -0500
Received: by mail-qg0-f52.google.com with SMTP id o11so62697673qge.2
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 12:05:16 -0800 (PST)
In-Reply-To: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Expose socket options for setting a classic or extended BPF program
for use when selecting sockets in an SO_REUSEPORT group.  These options
can be used on the first socket to belong to a group before bind or
on any socket in the group after bind.

This change includes refactoring of the existing sk_filter code to
allow reuse of the existing BPF filter validation checks.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   |   3 +
 arch/avr32/include/uapi/asm/socket.h   |   3 +
 arch/frv/include/uapi/asm/socket.h     |   3 +
 arch/ia64/include/uapi/asm/socket.h    |   3 +
 arch/m32r/include/uapi/asm/socket.h    |   3 +
 arch/mips/include/uapi/asm/socket.h    |   3 +
 arch/mn10300/include/uapi/asm/socket.h |   3 +
 arch/parisc/include/uapi/asm/socket.h  |   3 +
 arch/powerpc/include/uapi/asm/socket.h |   3 +
 arch/s390/include/uapi/asm/socket.h    |   3 +
 arch/sparc/include/uapi/asm/socket.h   |   3 +
 arch/xtensa/include/uapi/asm/socket.h  |   3 +
 include/linux/filter.h                 |   2 +
 include/net/sock_reuseport.h           |  10 ++-
 include/net/udp.h                      |   5 +-
 include/uapi/asm-generic/socket.h      |   3 +
 net/core/filter.c                      | 120 +++++++++++++++++++++++++++------
 net/core/sock.c                        |  29 ++++++++
 net/core/sock_reuseport.c              |  88 ++++++++++++++++++++++--
 net/ipv4/udp.c                         |  14 ++--
 net/ipv4/udp_diag.c                    |   4 +-
 net/ipv6/udp.c                         |  14 ++--
 22 files changed, 282 insertions(+), 43 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 9a20821..c5fb9e6 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -92,4 +92,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 2b65ed6..9de0796 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 4823ad1..f02e484 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -85,5 +85,8 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 59be3d8..bce2916 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -94,4 +94,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 7bc4cb2..14aa4a6 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index dec3c85..5910fe2 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -103,4 +103,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index cab7d6d..58b1aa0 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -85,4 +85,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index a5cd40c..f9cf122 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -84,4 +84,7 @@
 #define SO_ATTACH_BPF		0x402B
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	0x402C
+#define SO_ATTACH_REUSEPORT_EBPF	0x402D
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index c046666..dd54f28 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -92,4 +92,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 296942d..d02e89d 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -91,4 +91,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index e6a16c4..d270ee9 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -81,6 +81,9 @@
 #define SO_ATTACH_BPF		0x0034
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	0x0035
+#define SO_ATTACH_REUSEPORT_EBPF	0x0036
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 4120af0..fd3b96d 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -96,4 +96,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 4165e9a..3561d3a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -447,6 +447,8 @@ void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
+int reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+int reuseport_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
diff --git a/include/net/sock_reuseport.h b/include/net/sock_reuseport.h
index f17d190..0b85acb 100644
--- a/include/net/sock_reuseport.h
+++ b/include/net/sock_reuseport.h
@@ -1,6 +1,8 @@
 #ifndef _SOCK_REUSEPORT_H
 #define _SOCK_REUSEPORT_H
 
+#include <linux/filter.h>
+#include <linux/skbuff.h>
 #include <linux/spinlock_types.h>
 #include <linux/types.h>
 #include <net/sock.h>
@@ -10,12 +12,18 @@ struct sock_reuseport {
 
 	u16			max_socks;	/* length of socks */
 	u16			num_socks;	/* elements in socks */
+	struct bpf_prog __rcu	*prog;		/* optional BPF sock selector */
 	struct sock		*socks[0];	/* array of sock pointers */
 };
 
 extern int reuseport_alloc(struct sock *sk);
 extern int reuseport_add_sock(struct sock *sk, const struct sock *sk2);
 extern void reuseport_detach_sock(struct sock *sk);
-extern struct sock *reuseport_select_sock(struct sock *sk, u32 hash);
+extern struct sock *reuseport_select_sock(struct sock *sk,
+					  u32 hash,
+					  struct sk_buff *skb,
+					  int hdr_len);
+extern struct bpf_prog *reuseport_attach_prog(struct sock *sk,
+					      struct bpf_prog *prog);
 
 #endif  /* _SOCK_REUSEPORT_H */
diff --git a/include/net/udp.h b/include/net/udp.h
index 3b5d7f9..2842541 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -258,7 +258,7 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       __be32 daddr, __be16 dport, int dif,
-			       struct udp_table *tbl);
+			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
@@ -266,7 +266,8 @@ struct sock *udp6_lib_lookup(struct net *net,
 struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *saddr, __be16 sport,
 			       const struct in6_addr *daddr, __be16 dport,
-			       int dif, struct udp_table *tbl);
+			       int dif, struct udp_table *tbl,
+			       struct sk_buff *skb);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 5c15c2a..fb8a416 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -87,4 +87,7 @@
 #define SO_ATTACH_BPF		50
 #define SO_DETACH_BPF		SO_DETACH_FILTER
 
+#define SO_ATTACH_REUSEPORT_CBPF	51
+#define SO_ATTACH_REUSEPORT_EBPF	52
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index c770196..81eeeae 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -50,6 +50,7 @@
 #include <net/cls_cgroup.h>
 #include <net/dst_metadata.h>
 #include <net/dst.h>
+#include <net/sock_reuseport.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1167,17 +1168,32 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 	return 0;
 }
 
-/**
- *	sk_attach_filter - attach a socket filter
- *	@fprog: the filter program
- *	@sk: the socket to use
- *
- * Attach the user's filter code. We first run some sanity checks on
- * it to make sure it does not explode on us later. If an error
- * occurs or there is insufficient memory for the filter a negative
- * errno code is returned. On success the return is zero.
- */
-int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
+static int __reuseport_attach_prog(struct bpf_prog *prog, struct sock *sk)
+{
+	struct bpf_prog *old_prog;
+	int err;
+
+	if (bpf_prog_size(prog->len) > sysctl_optmem_max)
+		return -ENOMEM;
+
+	if (sk_unhashed(sk)) {
+		err = reuseport_alloc(sk);
+		if (err)
+			return err;
+	} else if (!rcu_access_pointer(sk->sk_reuseport_cb)) {
+		/* The socket wasn't bound with SO_REUSEPORT */
+		return -EINVAL;
+	}
+
+	old_prog = reuseport_attach_prog(sk, prog);
+	if (old_prog)
+		bpf_prog_destroy(old_prog);
+
+	return 0;
+}
+
+static
+struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	unsigned int fsize = bpf_classic_proglen(fprog);
 	unsigned int bpf_fsize = bpf_prog_size(fprog->len);
@@ -1185,19 +1201,19 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	int err;
 
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
-		return -EPERM;
+		return ERR_PTR(-EPERM);
 
 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 
 	prog = bpf_prog_alloc(bpf_fsize, 0);
 	if (!prog)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
 		__bpf_prog_free(prog);
-		return -EFAULT;
+		return ERR_PTR(-EFAULT);
 	}
 
 	prog->len = fprog->len;
@@ -1205,13 +1221,31 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	err = bpf_prog_store_orig_filter(prog, fprog);
 	if (err) {
 		__bpf_prog_free(prog);
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 
 	/* bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
 	prog = bpf_prepare_filter(prog, NULL);
+	return prog;
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
+	struct bpf_prog *prog = __get_filter(fprog, sk);
+	int err;
+
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
@@ -1225,23 +1259,50 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
-int sk_attach_bpf(u32 ufd, struct sock *sk)
+int reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
-	struct bpf_prog *prog;
+	struct bpf_prog *prog = __get_filter(fprog, sk);
 	int err;
 
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	err = __reuseport_attach_prog(prog, sk);
+	if (err < 0) {
+		__bpf_prog_release(prog);
+		return err;
+	}
+
+	return 0;
+}
+
+static struct bpf_prog *__get_bpf(u32 ufd, struct sock *sk)
+{
+	struct bpf_prog *prog;
+
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
-		return -EPERM;
+		return ERR_PTR(-EPERM);
 
 	prog = bpf_prog_get(ufd);
 	if (IS_ERR(prog))
-		return PTR_ERR(prog);
+		return prog;
 
 	if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
 		bpf_prog_put(prog);
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 
+	return prog;
+}
+
+int sk_attach_bpf(u32 ufd, struct sock *sk)
+{
+	struct bpf_prog *prog = __get_bpf(ufd, sk);
+	int err;
+
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
 	err = __sk_attach_prog(prog, sk);
 	if (err < 0) {
 		bpf_prog_put(prog);
@@ -1251,6 +1312,23 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
+int reuseport_attach_bpf(u32 ufd, struct sock *sk)
+{
+	struct bpf_prog *prog = __get_bpf(ufd, sk);
+	int err;
+
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	err = __reuseport_attach_prog(prog, sk);
+	if (err < 0) {
+		bpf_prog_put(prog);
+		return err;
+	}
+
+	return 0;
+}
+
 #define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
 #define BPF_LDST_LEN			16U
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 565bab7..cc1709d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -134,6 +134,7 @@
 #include <linux/sock_diag.h>
 
 #include <linux/filter.h>
+#include <net/sock_reuseport.h>
 
 #include <trace/events/sock.h>
 
@@ -932,6 +933,32 @@ set_rcvbuf:
 		}
 		break;
 
+	case SO_ATTACH_REUSEPORT_CBPF:
+		ret = -EINVAL;
+		if (optlen == sizeof(struct sock_fprog)) {
+			struct sock_fprog fprog;
+
+			ret = -EFAULT;
+			if (copy_from_user(&fprog, optval, sizeof(fprog)))
+				break;
+
+			ret = reuseport_attach_filter(&fprog, sk);
+		}
+		break;
+
+	case SO_ATTACH_REUSEPORT_EBPF:
+		ret = -EINVAL;
+		if (optlen == sizeof(u32)) {
+			u32 ufd;
+
+			ret = -EFAULT;
+			if (copy_from_user(&ufd, optval, sizeof(ufd)))
+				break;
+
+			ret = reuseport_attach_bpf(ufd, sk);
+		}
+		break;
+
 	case SO_DETACH_FILTER:
 		ret = sk_detach_filter(sk);
 		break;
@@ -1443,6 +1470,8 @@ void sk_destruct(struct sock *sk)
 		sk_filter_uncharge(sk, filter);
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 	}
+	if (rcu_access_pointer(sk->sk_reuseport_cb))
+		reuseport_detach_sock(sk);
 
 	sock_disable_timestamp(sk, SK_FLAGS_TIMESTAMP);
 
diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index 963c8d5..448699f 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -1,10 +1,12 @@
 /*
  * To speed up listener socket lookup, create an array to store all sockets
  * listening on the same port.  This allows a decision to be made after finding
- * the first socket.
+ * the first socket.  An optional BPF program can also be configured for
+ * selecting the socket index from the array of available sockets.
  */
 
 #include <net/sock_reuseport.h>
+#include <linux/bpf.h>
 #include <linux/rcupdate.h>
 
 #define INIT_SOCKS 128
@@ -22,6 +24,7 @@ static struct sock_reuseport *__reuseport_alloc(u16 max_socks)
 
 	reuse->max_socks = max_socks;
 
+	RCU_INIT_POINTER(reuse->prog, NULL);
 	return reuse;
 }
 
@@ -67,6 +70,7 @@ static struct sock_reuseport *reuseport_grow(struct sock_reuseport *reuse)
 
 	more_reuse->max_socks = more_socks_size;
 	more_reuse->num_socks = reuse->num_socks;
+	more_reuse->prog = reuse->prog;
 
 	memcpy(more_reuse->socks, reuse->socks,
 	       reuse->num_socks * sizeof(struct sock *));
@@ -75,6 +79,10 @@ static struct sock_reuseport *reuseport_grow(struct sock_reuseport *reuse)
 		rcu_assign_pointer(reuse->socks[i]->sk_reuseport_cb,
 				   more_reuse);
 
+	/* Note: we use kfree_rcu here instead of reuseport_free_rcu so
+	 * that reuse and more_reuse can temporarily share a reference
+	 * to prog.
+	 */
 	kfree_rcu(reuse, rcu);
 	return more_reuse;
 }
@@ -116,6 +124,16 @@ int reuseport_add_sock(struct sock *sk, const struct sock *sk2)
 }
 EXPORT_SYMBOL(reuseport_add_sock);
 
+static void reuseport_free_rcu(struct rcu_head *head)
+{
+	struct sock_reuseport *reuse;
+
+	reuse = container_of(head, struct sock_reuseport, rcu);
+	if (reuse->prog)
+		bpf_prog_destroy(reuse->prog);
+	kfree(reuse);
+}
+
 void reuseport_detach_sock(struct sock *sk)
 {
 	struct sock_reuseport *reuse;
@@ -131,7 +149,7 @@ void reuseport_detach_sock(struct sock *sk)
 			reuse->socks[i] = reuse->socks[reuse->num_socks - 1];
 			reuse->num_socks--;
 			if (reuse->num_socks == 0)
-				kfree_rcu(reuse, rcu);
+				call_rcu(&reuse->rcu, reuseport_free_rcu);
 			break;
 		}
 	}
@@ -139,15 +157,53 @@ void reuseport_detach_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(reuseport_detach_sock);
 
+static struct sock *run_bpf(struct sock_reuseport *reuse, u16 socks,
+			    struct bpf_prog *prog, struct sk_buff *skb,
+			    int hdr_len)
+{
+	struct sk_buff *nskb = NULL;
+	u32 index;
+
+	if (skb_shared(skb)) {
+		nskb = skb_clone(skb, GFP_ATOMIC);
+		if (!nskb)
+			return NULL;
+		skb = nskb;
+	}
+
+	/* temporarily advance data past protocol header */
+	if (skb_headlen(skb) < hdr_len || !skb_pull_inline(skb, hdr_len)) {
+		consume_skb(nskb);
+		return NULL;
+	}
+	index = bpf_prog_run_save_cb(prog, skb);
+	__skb_push(skb, hdr_len);
+
+	consume_skb(nskb);
+
+	if (index >= socks)
+		return NULL;
+
+	return reuse->socks[index];
+}
+
 /**
  *  reuseport_select_sock - Select a socket from an SO_REUSEPORT group.
  *  @sk: First socket in the group.
- *  @hash: Use this hash to select.
+ *  @hash: When no BPF filter is available, use this hash to select.
+ *  @skb: skb to run through BPF filter.
+ *  @hdr_len: BPF filter expects skb data pointer at payload data.  If
+ *    the skb does not yet point at the payload, this parameter represents
+ *    how far the pointer needs to advance to reach the payload.
  *  Returns a socket that should receive the packet (or NULL on error).
  */
-struct sock *reuseport_select_sock(struct sock *sk, u32 hash)
+struct sock *reuseport_select_sock(struct sock *sk,
+				   u32 hash,
+				   struct sk_buff *skb,
+				   int hdr_len)
 {
 	struct sock_reuseport *reuse;
+	struct bpf_prog *prog;
 	struct sock *sk2 = NULL;
 	u16 socks;
 
@@ -158,12 +214,16 @@ struct sock *reuseport_select_sock(struct sock *sk, u32 hash)
 	if (!reuse)
 		goto out;
 
+	prog = rcu_dereference(reuse->prog);
 	socks = READ_ONCE(reuse->num_socks);
 	if (likely(socks)) {
 		/* paired with smp_wmb() in reuseport_add_sock() */
 		smp_rmb();
 
-		sk2 = reuse->socks[reciprocal_scale(hash, socks)];
+		if (prog && skb)
+			sk2 = run_bpf(reuse, socks, prog, skb, hdr_len);
+		else
+			sk2 = reuse->socks[reciprocal_scale(hash, socks)];
 	}
 
 out:
@@ -171,3 +231,21 @@ out:
 	return sk2;
 }
 EXPORT_SYMBOL(reuseport_select_sock);
+
+struct bpf_prog *
+reuseport_attach_prog(struct sock *sk, struct bpf_prog *prog)
+{
+	struct sock_reuseport *reuse;
+	struct bpf_prog *old_prog;
+
+	spin_lock_bh(&reuseport_lock);
+	reuse = rcu_dereference_protected(sk->sk_reuseport_cb,
+					  lockdep_is_held(&reuseport_lock));
+	old_prog = rcu_dereference_protected(reuse->prog,
+					     lockdep_is_held(&reuseport_lock));
+	rcu_assign_pointer(reuse->prog, prog);
+	spin_unlock_bh(&reuseport_lock);
+
+	return old_prog;
+}
+EXPORT_SYMBOL(reuseport_attach_prog);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index de2e1c0..2c86e56 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -514,7 +514,7 @@ begin:
 				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash);
+				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -553,7 +553,7 @@ found:
  */
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable)
+		int dif, struct udp_table *udptable, struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -602,7 +602,8 @@ begin:
 				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -647,14 +648,14 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 
 	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
-				 udptable);
+				 udptable, skb);
 }
 
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
 	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
-				 &udp_table);
+				 &udp_table, NULL);
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
@@ -702,7 +703,8 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 	struct net *net = dev_net(skb->dev);
 
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
-			iph->saddr, uh->source, skb->dev->ifindex, udptable);
+			iph->saddr, uh->source, skb->dev->ifindex, udptable,
+			NULL);
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 6116604..df1966f 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -44,7 +44,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		sk = __udp4_lib_lookup(net,
 				req->id.idiag_src[0], req->id.idiag_sport,
 				req->id.idiag_dst[0], req->id.idiag_dport,
-				req->id.idiag_if, tbl);
+				req->id.idiag_if, tbl, NULL);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6)
 		sk = __udp6_lib_lookup(net,
@@ -52,7 +52,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 				req->id.idiag_sport,
 				(struct in6_addr *)req->id.idiag_dst,
 				req->id.idiag_dport,
-				req->id.idiag_if, tbl);
+				req->id.idiag_if, tbl, NULL);
 #endif
 	else
 		goto out_nosk;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c593319..d483c6b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -272,7 +272,7 @@ begin:
 				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash);
+				sk2 = reuseport_select_sock(sk, hash, NULL, 0);
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -310,7 +310,8 @@ found:
 struct sock *__udp6_lib_lookup(struct net *net,
 				      const struct in6_addr *saddr, __be16 sport,
 				      const struct in6_addr *daddr, __be16 dport,
-				      int dif, struct udp_table *udptable)
+				      int dif, struct udp_table *udptable,
+				      struct sk_buff *skb)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -358,7 +359,8 @@ begin:
 				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
-				sk2 = reuseport_select_sock(sk, hash);
+				sk2 = reuseport_select_sock(sk, hash, skb,
+							sizeof(struct udphdr));
 				if (sk2) {
 					result = sk2;
 					goto found;
@@ -407,13 +409,13 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 		return sk;
 	return __udp6_lib_lookup(dev_net(skb_dst(skb)->dev), &iph->saddr, sport,
 				 &iph->daddr, dport, inet6_iif(skb),
-				 udptable);
+				 udptable, skb);
 }
 
 struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport, int dif)
 {
-	return __udp6_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
+	return __udp6_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table, NULL);
 }
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
@@ -578,7 +580,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct net *net = dev_net(skb->dev);
 
 	sk = __udp6_lib_lookup(net, daddr, uh->dest, saddr, uh->source,
-			       inet6_iif(skb), udptable);
+			       inet6_iif(skb), udptable, skb);
 	if (!sk) {
 		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
 				   ICMP6_MIB_INERRORS);
-- 
2.6.0.rc2.230.g3dd15c0
