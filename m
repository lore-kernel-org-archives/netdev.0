From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 16/26] net: sock: allow eBPF programs to be attached to sockets
Date: Wed, 13 Aug 2014 00:57:27 -0700
Message-ID: <1407916658-8731-17-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

introduce new setsockopt() command:

int fd;
setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER_EBPF, &fd, sizeof(fd))

fd is associated with eBPF program priorly loaded via:

fd = syscall(__NR_bpf, BPF_PROG_LOAD, BPF_PROG_TYPE_SOCKET_FILTER,
             &prog, sizeof(prog));

setsockopt() calls bpf_prog_get() which increment refcnt of the program,
so it doesn't get unloaded while socket is using the program.

The same eBPF program can be attached to different sockets.

Program exit automatically closes socket which calls sk_filter_uncharge()
which decrements refcnt of eBPF program

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/alpha/include/uapi/asm/socket.h   |    2 +
 arch/avr32/include/uapi/asm/socket.h   |    2 +
 arch/cris/include/uapi/asm/socket.h    |    2 +
 arch/frv/include/uapi/asm/socket.h     |    2 +
 arch/ia64/include/uapi/asm/socket.h    |    2 +
 arch/m32r/include/uapi/asm/socket.h    |    2 +
 arch/mips/include/uapi/asm/socket.h    |    2 +
 arch/mn10300/include/uapi/asm/socket.h |    2 +
 arch/parisc/include/uapi/asm/socket.h  |    2 +
 arch/powerpc/include/uapi/asm/socket.h |    2 +
 arch/s390/include/uapi/asm/socket.h    |    2 +
 arch/sparc/include/uapi/asm/socket.h   |    2 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 include/linux/filter.h                 |    1 +
 include/uapi/asm-generic/socket.h      |    2 +
 net/core/filter.c                      |  135 +++++++++++++++++++++++++++++++-
 net/core/sock.c                        |   13 +++
 17 files changed, 175 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 3de1394bcab8..8c83c376b5ba 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 6e6cd159924b..498ef7220466 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/uapi/asm/socket.h b/arch/cris/include/uapi/asm/socket.h
index ed94e5ed0a23..0d5120724780 100644
--- a/arch/cris/include/uapi/asm/socket.h
+++ b/arch/cris/include/uapi/asm/socket.h
@@ -82,6 +82,8 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index ca2c6e6f31c6..81fba267c285 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -80,5 +80,7 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index a1b49bac7951..9cbb2e82fa7c 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -89,4 +89,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index 6c9a24b3aefa..587ac2fb4106 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index a14baa218c76..ab1aed2306db 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 6aa3ce1854aa..1c4f916d0ef1 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -80,4 +80,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index fe35ceacf0e7..d189bb79ca07 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -79,4 +79,6 @@
 
 #define SO_BPF_EXTENSIONS	0x4029
 
+#define SO_ATTACH_FILTER_EBPF	0x402a
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index a9c3e2e18c05..88488f24ae7f 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -87,4 +87,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e031332096d7..c5f26af90366 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -86,4 +86,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 54d9608681b6..667ed3fa63f2 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -76,6 +76,8 @@
 
 #define SO_BPF_EXTENSIONS	0x0032
 
+#define SO_ATTACH_FILTER_EBPF	0x0033
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 39acec0cf0b1..24f3e4434979 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -91,4 +91,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index f06913b29861..9b3f4173d1fd 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -78,6 +78,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+int sk_attach_filter_ebpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 
 int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index ea0796bdcf88..f41844e9ac07 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -82,4 +82,6 @@
 
 #define SO_BPF_EXTENSIONS	48
 
+#define SO_ATTACH_FILTER_EBPF	49
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/filter.c b/net/core/filter.c
index ed15874a9beb..0c8531aa6302 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -44,6 +44,7 @@
 #include <linux/ratelimit.h>
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
+#include <linux/bpf.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -844,8 +845,12 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 
 static void __bpf_prog_release(struct bpf_prog *prog)
 {
-	bpf_release_orig_filter(prog);
-	bpf_prog_free(prog);
+	if (prog->has_info) {
+		bpf_prog_put(prog);
+	} else {
+		bpf_release_orig_filter(prog);
+		bpf_prog_free(prog);
+	}
 }
 
 static void __sk_filter_release(struct sk_filter *fp)
@@ -1120,6 +1125,132 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
+int sk_attach_filter_ebpf(u32 ufd, struct sock *sk)
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
+	if (prog->info->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
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
+static struct bpf_func_proto sock_filter_funcs[] = {
+	[BPF_FUNC_map_lookup_elem] = {
+		.func = bpf_map_lookup_elem,
+		.gpl_only = false,
+		.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+		.arg1_type = ARG_CONST_MAP_PTR,
+		.arg2_type = ARG_PTR_TO_MAP_KEY,
+	},
+	[BPF_FUNC_map_update_elem] = {
+		.func = bpf_map_update_elem,
+		.gpl_only = false,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_CONST_MAP_PTR,
+		.arg2_type = ARG_PTR_TO_MAP_KEY,
+		.arg3_type = ARG_PTR_TO_MAP_VALUE,
+	},
+	[BPF_FUNC_map_delete_elem] = {
+		.func = bpf_map_delete_elem,
+		.gpl_only = false,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_CONST_MAP_PTR,
+		.arg2_type = ARG_PTR_TO_MAP_KEY,
+	},
+};
+
+/* allow socket filters to call
+ * bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
+ */
+static const struct bpf_func_proto *sock_filter_func_proto(enum bpf_func_id func_id)
+{
+	if (func_id < 0 || func_id >= ARRAY_SIZE(sock_filter_funcs))
+		return NULL;
+	return &sock_filter_funcs[func_id];
+}
+
+static const struct bpf_context_access {
+	int size;
+	enum bpf_access_type type;
+} sock_filter_ctx_access[] = {
+	[offsetof(struct sk_buff, mark)] = {
+		FIELD_SIZEOF(struct sk_buff, mark), BPF_READ
+	},
+	[offsetof(struct sk_buff, protocol)] = {
+		FIELD_SIZEOF(struct sk_buff, protocol), BPF_READ
+	},
+	[offsetof(struct sk_buff, queue_mapping)] = {
+		FIELD_SIZEOF(struct sk_buff, queue_mapping), BPF_READ
+	},
+};
+
+/* allow socket filters to access to 'mark', 'protocol' and 'queue_mapping'
+ * fields of 'struct sk_buff'
+ */
+static bool sock_filter_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	const struct bpf_context_access *access;
+
+	if (off < 0 || off >= ARRAY_SIZE(sock_filter_ctx_access))
+		return false;
+
+	access = &sock_filter_ctx_access[off];
+	if (access->size == size && (access->type & type))
+		return true;
+
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
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
diff --git a/net/core/sock.c b/net/core/sock.c
index 2714811afbd8..9603769accfb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -896,6 +896,19 @@ set_rcvbuf:
 		}
 		break;
 
+	case SO_ATTACH_FILTER_EBPF:
+		ret = -EINVAL;
+		if (optlen == sizeof(u32)) {
+			u32 ufd;
+
+			ret = -EFAULT;
+			if (copy_from_user(&ufd, optval, sizeof(ufd)))
+				break;
+
+			ret = sk_attach_filter_ebpf(ufd, sk);
+		}
+		break;
+
 	case SO_DETACH_FILTER:
 		ret = sk_detach_filter(sk);
 		break;
-- 
1.7.9.5
