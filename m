From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/7] ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code
Date: Wed, 11 Feb 2015 01:15:17 +0100
Message-ID: <7944793232a98f4c4ec8dbc7e0a539729c6ea0b3.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56180 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbBKAPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:15:36 -0500
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
In-Reply-To: <cover.1423610452.git.daniel@iogearbox.net>
References: <cover.1423610452.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Socket filter code and other subsystems with upcoming eBPF support
should not need to deal with the fact that we have CONFIG_BPF_SYSCALL
defined or not. Having the bpf syscall as a config option is a nice
thing and I'd expect it to stay that way for expert users (I presume
one day the default setting of it might change, though), but code
making use of it should not care if it's actually enabled or not.
Instead, hide this via header files and let the rest deal with it.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h |  27 +++++++--
 net/core/filter.c   | 166 ++++++++++++++++++++++++----------------------------
 2 files changed, 100 insertions(+), 93 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4fe1bd3..def0103 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -114,9 +114,6 @@ struct bpf_prog_type_list {
 	enum bpf_prog_type type;
 };
 
-int bpf_register_prog_type(struct bpf_prog_type_list *tl);
-void bpf_unregister_prog_type(struct bpf_prog_type_list *tl);
-
 struct bpf_prog;
 
 struct bpf_prog_aux {
@@ -130,11 +127,31 @@ struct bpf_prog_aux {
 };
 
 #ifdef CONFIG_BPF_SYSCALL
+int bpf_register_prog_type(struct bpf_prog_type_list *tl);
+void bpf_unregister_prog_type(struct bpf_prog_type_list *tl);
+
 void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
 #else
-static inline void bpf_prog_put(struct bpf_prog *prog) {}
+static inline int bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+	return 0;
+}
+
+static inline void bpf_unregister_prog_type(struct bpf_prog_type_list *tl)
+{
+}
+
+static inline struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void bpf_prog_put(struct bpf_prog *prog)
+{
+}
 #endif
-struct bpf_prog *bpf_prog_get(u32 ufd);
+
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index d76560f..306b860 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1020,6 +1020,46 @@ void bpf_prog_destroy(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_destroy);
 
+int sk_attach_bpf(u32 ufd, struct sock *sk)
+{
+	struct sk_filter *fp, *old_fp;
+	struct bpf_prog *prog;
+
+	if (sock_flag(sk, SOCK_FILTER_LOCKED))
+		return -EPERM;
+
+	prog = bpf_prog_get(ufd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	if (prog->aux->tl->type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		bpf_prog_put(prog);
+		return -EINVAL;
+	}
+
+	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp) {
+		bpf_prog_put(prog);
+		return -ENOMEM;
+	}
+
+	fp->prog = prog;
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
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+
+	return 0;
+}
+
 /**
  *	sk_attach_filter - attach a socket filter
  *	@fprog: the filter program
@@ -1094,94 +1134,6 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
-#ifdef CONFIG_BPF_SYSCALL
-int sk_attach_bpf(u32 ufd, struct sock *sk)
-{
-	struct sk_filter *fp, *old_fp;
-	struct bpf_prog *prog;
-
-	if (sock_flag(sk, SOCK_FILTER_LOCKED))
-		return -EPERM;
-
-	prog = bpf_prog_get(ufd);
-	if (IS_ERR(prog))
-		return PTR_ERR(prog);
-
-	if (prog->aux->tl->type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		/* valid fd, but invalid program type */
-		bpf_prog_put(prog);
-		return -EINVAL;
-	}
-
-	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
-	if (!fp) {
-		bpf_prog_put(prog);
-		return -ENOMEM;
-	}
-	fp->prog = prog;
-
-	atomic_set(&fp->refcnt, 0);
-
-	if (!sk_filter_charge(sk, fp)) {
-		__sk_filter_release(fp);
-		return -ENOMEM;
-	}
-
-	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
-	rcu_assign_pointer(sk->sk_filter, fp);
-
-	if (old_fp)
-		sk_filter_uncharge(sk, old_fp);
-
-	return 0;
-}
-
-/* allow socket filters to call
- * bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
- */
-static const struct bpf_func_proto *sock_filter_func_proto(enum bpf_func_id func_id)
-{
-	switch (func_id) {
-	case BPF_FUNC_map_lookup_elem:
-		return &bpf_map_lookup_elem_proto;
-	case BPF_FUNC_map_update_elem:
-		return &bpf_map_update_elem_proto;
-	case BPF_FUNC_map_delete_elem:
-		return &bpf_map_delete_elem_proto;
-	default:
-		return NULL;
-	}
-}
-
-static bool sock_filter_is_valid_access(int off, int size, enum bpf_access_type type)
-{
-	/* skb fields cannot be accessed yet */
-	return false;
-}
-
-static const struct bpf_verifier_ops sock_filter_ops = {
-	.get_func_proto = sock_filter_func_proto,
-	.is_valid_access = sock_filter_is_valid_access,
-};
-
-static struct bpf_prog_type_list sock_filter_type __read_mostly = {
-	.ops = &sock_filter_ops,
-	.type = BPF_PROG_TYPE_SOCKET_FILTER,
-};
-
-static int __init register_sock_filter_ops(void)
-{
-	return bpf_register_prog_type(&sock_filter_type);
-}
-late_initcall(register_sock_filter_ops);
-#else
-int sk_attach_bpf(u32 ufd, struct sock *sk)
-{
-	return -EOPNOTSUPP;
-}
-#endif
-
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
@@ -1241,3 +1193,41 @@ out:
 	release_sock(sk);
 	return ret;
 }
+
+static const struct bpf_func_proto *
+sock_filter_func_proto(enum bpf_func_id func_id)
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
+static bool sock_filter_is_valid_access(int off, int size,
+					enum bpf_access_type type)
+{
+	/* skb fields cannot be accessed yet */
+	return false;
+}
+
+static const struct bpf_verifier_ops sock_filter_ops = {
+	.get_func_proto = sock_filter_func_proto,
+	.is_valid_access = sock_filter_is_valid_access,
+};
+
+static struct bpf_prog_type_list sock_filter_type __read_mostly = {
+	.ops = &sock_filter_ops,
+	.type = BPF_PROG_TYPE_SOCKET_FILTER,
+};
+
+static int __init register_sock_filter_ops(void)
+{
+	return bpf_register_prog_type(&sock_filter_type);
+}
+late_initcall(register_sock_filter_ops);
-- 
1.9.3
