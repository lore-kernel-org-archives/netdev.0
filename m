From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 net-next 2/6] net: sock: allow eBPF programs to be attached to sockets
Date: Mon,  1 Dec 2014 15:06:35 -0800
Message-ID: <1417475199-15950-3-git-send-email-ast@plumgrid.com>
References: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417475199-15950-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

introduce new setsockopt() command:

setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd, sizeof(prog_fd))

where prog_fd was received from syscall bpf(BPF_PROG_LOAD, attr, ...)
and attr->prog_type == BPF_PROG_TYPE_SOCKET_FILTER

setsockopt() calls bpf_prog_get() which increments refcnt of the program,
so it doesn't get unloaded while socket is using the program.

The same eBPF program can be attached to multiple sockets.

User task exit automatically closes socket which calls sk_filter_uncharge()
which decrements refcnt of eBPF program

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
v2: no changes

Note, I'm not happy about 'ifdef', but 'select or depend BPF_SYSCALL' will
make tinification folks cringe, so use ifdef until native eBPF use cases
become widespread.

 arch/alpha/include/uapi/asm/socket.h   |    3 +
 arch/avr32/include/uapi/asm/socket.h   |    3 +
 arch/cris/include/uapi/asm/socket.h    |    3 +
 arch/frv/include/uapi/asm/socket.h     |    3 +
 arch/ia64/include/uapi/asm/socket.h    |    3 +
 arch/m32r/include/uapi/asm/socket.h    |    3 +
 arch/mips/include/uapi/asm/socket.h    |    3 +
 arch/mn10300/include/uapi/asm/socket.h |    3 +
 arch/parisc/include/uapi/asm/socket.h  |    3 +
 arch/powerpc/include/uapi/asm/socket.h |    3 +
 arch/s390/include/uapi/asm/socket.h    |    3 +
 arch/sparc/include/uapi/asm/socket.h   |    3 +
 arch/xtensa/include/uapi/asm/socket.h  |    3 +
 include/linux/bpf.h                    |    4 ++
 include/linux/filter.h                 |    1 +
 include/uapi/asm-generic/socket.h      |    3 +
 net/core/filter.c                      |   97 +++++++++++++++++++++++++++++++-
 net/core/sock.c                        |   13 +++++
 18 files changed, 155 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index e2fe0700b3b4..9a20821b111c 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -89,4 +89,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 92121b0f5b98..2b65ed6b277c 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -82,4 +82,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index 60f60f5b9b35..e2503d9f1869 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -84,6 +84,9 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 2c6890209ea6..4823ad125578 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -82,5 +82,8 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 09a93fb566f6..59be3d87f86d 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -91,4 +91,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index e8589819c274..7bc4cb273856 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -82,4 +82,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 2e9ee8c55a10..dec3c850f36b 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -100,4 +100,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index f3492e8c9f70..cab7d6d50051 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -82,4 +82,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 7984a1cab3da..a5cd40cd8ee1 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -81,4 +81,7 @@
 
 #define SO_INCOMING_CPU		0x402A
 
+#define SO_ATTACH_BPF		0x402B
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 3474e4ef166d..c046666038f8 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -89,4 +89,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 8457636c33e1..296942d56e6a 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -88,4 +88,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 4a8003a94163..e6a16c40be5f 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -78,6 +78,9 @@
 
 #define SO_INCOMING_CPU		0x0033
 
+#define SO_ATTACH_BPF		0x0034
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index c46f6a696849..4120af086160 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -93,4 +93,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 75e94eaa228b..bbfceb756452 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -128,7 +128,11 @@ struct bpf_prog_aux {
 	struct work_struct work;
 };
 
+#ifdef CONFIG_BPF_SYSCALL
 void bpf_prog_put(struct bpf_prog *prog);
+#else
+static inline void bpf_prog_put(struct bpf_prog *prog) {}
+#endif
 struct bpf_prog *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index ca95abd2bed1..caac2087a4d5 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -381,6 +381,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+int sk_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 
 int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index f541ccefd4ac..5c15c2a5c123 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -84,4 +84,7 @@
 
 #define SO_INCOMING_CPU		49
 
+#define SO_ATTACH_BPF		50
+#define SO_DETACH_BPF		SO_DETACH_FILTER
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index 647b12265e18..8cc3c03078b3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -44,6 +44,7 @@
 #include <linux/ratelimit.h>
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
+#include <linux/bpf.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -813,8 +814,12 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 
 static void __bpf_prog_release(struct bpf_prog *prog)
 {
-	bpf_release_orig_filter(prog);
-	bpf_prog_free(prog);
+	if (prog->aux->prog_type == BPF_PROG_TYPE_SOCKET_FILTER) {
+		bpf_prog_put(prog);
+	} else {
+		bpf_release_orig_filter(prog);
+		bpf_prog_free(prog);
+	}
 }
 
 static void __sk_filter_release(struct sk_filter *fp)
@@ -1088,6 +1093,94 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
+#ifdef CONFIG_BPF_SYSCALL
+int sk_attach_bpf(u32 ufd, struct sock *sk)
+{
+	struct sk_filter *fp, *old_fp;
+	struct bpf_prog *prog;
+
+	if (sock_flag(sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+
+	prog = bpf_prog_get(ufd);
+	if (!prog)
+		return -EINVAL;
+
+	if (prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		/* valid fd, but invalid program type */
+		bpf_prog_put(prog);
+		return -EINVAL;
+	}
+
+	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp) {
+		bpf_prog_put(prog);
+		return -ENOMEM;
+	}
+	fp->prog = prog;
+
+	atomic_set(&fp->refcnt, 0);
+
+	if (!sk_filter_charge(sk, fp)) {
+		__sk_filter_release(fp);
+		return -ENOMEM;
+	}
+
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
+	rcu_assign_pointer(sk->sk_filter, fp);
+
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+
+	return 0;
+}
+
+/* allow socket filters to call
+ * bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
+ */
+static const struct bpf_func_proto *sock_filter_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	default:
+		return NULL;
+	}
+}
+
+static bool sock_filter_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	/* skb fields cannot be accessed yet */
+	return false;
+}
+
+static struct bpf_verifier_ops sock_filter_ops = {
+	.get_func_proto = sock_filter_func_proto,
+	.is_valid_access = sock_filter_is_valid_access,
+};
+
+static struct bpf_prog_type_list tl = {
+	.ops = &sock_filter_ops,
+	.type = BPF_PROG_TYPE_SOCKET_FILTER,
+};
+
+static int __init register_sock_filter_ops(void)
+{
+	bpf_register_prog_type(&tl);
+	return 0;
+}
+late_initcall(register_sock_filter_ops);
+#else
+int sk_attach_bpf(u32 ufd, struct sock *sk)
+{
+	return -EOPNOTSUPP;
+}
+#endif
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
diff --git a/net/core/sock.c b/net/core/sock.c
index 0725cf0cb685..9a56b2000c3f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -888,6 +888,19 @@ set_rcvbuf:
 		}
 		break;
 
+	case SO_ATTACH_BPF:
+		ret = -EINVAL;
+		if (optlen == sizeof(u32)) {
+			u32 ufd;
+
+			ret = -EFAULT;
+			if (copy_from_user(&ufd, optval, sizeof(ufd)))
+				break;
+
+			ret = sk_attach_bpf(ufd, sk);
+		}
+		break;
+
 	case SO_DETACH_FILTER:
 		ret = sk_detach_filter(sk);
 		break;
-- 
1.7.9.5
